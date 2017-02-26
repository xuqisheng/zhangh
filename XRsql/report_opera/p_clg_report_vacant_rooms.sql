--E72的过程,计算分房数
drop proc p_clg_report_vacant_rooms;
create proc p_clg_report_vacant_rooms
	@bdate datetime
as
declare
	@roomno	char(5),
	@haccnt	char(7),
	@arr		datetime,
	@dep		datetime,
	@gstno	int,
	@children	int
create table #goutput(
	roomno	char(5),
	type		char(5),
	ocsta		char(3),
	sta		char(3),
	name		varchar(50),
	arr		datetime,
	dep		datetime,
	ressta	char(12),
	adults	int,
	children	int,
	nblock	datetime)
--vacant
insert into #goutput select roomno,type,'VAC','','',null,null,'',null,null,null from rmsta where ocsta='V'
--Due Out
insert into #goutput select roomno,type,'OCC','','',null,null,'Due Out',null,null,null from rmsta
	where exists(select 1 from master where sta='I' and datediff(dd,dep,@bdate)=0 and rmsta.roomno=master.roomno)
update #goutput set sta=b.eccocode from rmsta a,rmstamap b where a.roomno=#goutput.roomno and a.ocsta+a.sta=b.code
--显示详细信息的是Due Out和Due In的主单
declare c_1 cursor for select distinct roomno from master where charindex(sta,'IR')>0 and roomno<>''
declare c_2 cursor for select haccnt,arr,dep,gstno,children from master
	where (sta='I' or (sta='R' and datediff(dd,arr,@bdate)=0)) and roomno=@roomno order by arr
declare c_3 cursor for select arr from master where sta='R' and datediff(dd,arr,@bdate)<0 and roomno=@roomno order by arr

open c_1
fetch c_1 into @roomno
while @@sqlstatus=0
begin
	open c_2
	fetch c_2 into @haccnt,@arr,@dep,@gstno,@children
	--只做一次，取最近的预定或登记
	if @@sqlstatus=0
		update #goutput set name=@haccnt,arr=@arr,dep=@dep,adults=@gstno,children=@children where roomno=@roomno
	close c_2
	--同样只一次，取下一次预定日期
	open c_3
	fetch c_3 into @arr
	if @@sqlstatus=0
		update #goutput set nblock=@arr where roomno=@roomno
	close c_3
	
	fetch c_1 into @roomno
end
close c_1

deallocate cursor c_1
deallocate cursor c_2

update #goutput set ressta='Due In' where ocsta='VAC' and datediff(dd,arr,@bdate)=0
update #goutput set name=a.name from guest a where a.no=#goutput.name

select * from #goutput order by roomno
;