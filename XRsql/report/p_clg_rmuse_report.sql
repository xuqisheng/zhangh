IF OBJECT_ID('dbo.p_clg_rmuse_report') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_rmuse_report
;
create proc p_clg_rmuse_report
	@begin		datetime,
	@end			datetime,
	@hall			char(100),
	@type			char(100)
as
---------------------------------------------
-- 客房状况报表
---------------------------------------------
declare
	@date1		datetime,
	@bfdate		datetime,
	@duringaudit	char(1),
	@totalrm			int

--
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bfdate = bdate from sysdata
else
	select @bfdate = bdate from accthead
--select @bfdate = dateadd(day, -1, @bdate)

if datediff(dd,@bfdate,@end)>0
	select @end	= @bfdate

create table #room	 (	date	datetime not null,
								roomno  		char(10) not null,
								occ	money		not null,
							  	vac	money 	not null,
								ooo	money		not null	 )
select @date1=@begin
while datediff(dd,@date1,@end)>=0
	begin
	insert #room select @date1,roomno,0,0,0 from rmsta where (rtrim(@hall) is null or charindex(rtrim(hall),@hall)>0) and (rtrim(@type) is null or charindex(','+rtrim(type)+',',','+rtrim(@type)+',')>0)
	select @date1=dateadd(dd,1,@date1)
	end
update #room set occ = isnull((select quantity from rmuserate a where a.roomno=#room.roomno and a.date=#room.date and sta='I'),0)
select @date1=@begin
while datediff(dd,@date1,@end)>=0
	begin
	update #room set ooo = (select count(roomno) from rm_ooo a where a.roomno=#room.roomno and datediff(dd,@date1,a.dbegin)<=0 and (status='I' or (status<>'I' and datediff(dd,@date1,a.date3)>0))) where date=@date1
	update #room set ooo = (select count(roomno) from hrm_ooo a where a.roomno=#room.roomno and datediff(dd,@date1,a.dbegin)<=0 and (status='I' or (status<>'I' and datediff(dd,@date1,a.date3)>0))) where ooo=0 and #room.date=@date1
	
	select @date1=dateadd(dd,1,@date1)
	end
update #room set vac = 1 where occ=0 and ooo=0
--select * from #room where roomno='245'
select roomno,sum(occ),100*sum(occ)/sum(occ+vac+ooo),sum(vac),100*sum(vac)/sum(occ+vac+ooo),sum(ooo),100*sum(ooo)/sum(occ+vac+ooo) from #room group by roomno order by roomno
return 0;
