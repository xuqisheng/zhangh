--E64µÄ¹ý³Ì
drop proc p_clg_report_group_detail;
create proc p_clg_report_group_detail
	@date1	datetime,
	@date2	datetime
as
declare
	@accnt	char(10),
	@rmrev	money,
	@fbrev	money,
	@ttlrev	money
create table #goutput(
	accnt		char(10)		null,	
	roomno	char(5)		null,
	rmsta		char(3)		null,		
	company	varchar(50)	null,
	agent		varchar(50)	null)
create table #revenue(
	accnt		char(10)		null,
	rmrev		money			null,
	fbrev		money			null,
	total		money			null)

insert into #goutput select a.accnt,a.roomno,c.ocsta+c.sta,b.cusno,b.agent
 from master a,master_des b,rmsta c
 where a.accnt=b.accnt and a.roomno=c.roomno and a.class='F' and a.groupno<>'' and a.sta='I' and datediff(dd,a.arr,@date1)<=0 and datediff(dd,a.arr,@date2)>=0

declare c_accnt cursor for select accnt from #goutput
open c_accnt
fetch c_accnt into @accnt
while @@sqlstatus=0
begin
	select @rmrev=isnull(sum(a.charge),0) from account a,pccode b where a.accnt=@accnt and a.pccode=b.pccode and b.deptno7='rm'
	select @fbrev=isnull(sum(a.charge),0) from account a,pccode b where a.accnt=@accnt and a.pccode=b.pccode and b.deptno7='fb'
	select @ttlrev=isnull(sum(a.charge),0) from account a where a.accnt=@accnt
	insert into #revenue values(@accnt,@rmrev,@fbrev,@ttlrev)
	fetch c_accnt into @accnt
end
update #goutput set rmsta=a.eccocode from rmstamap a where a.code=rmsta
select a.blkcode,b.rmsta,a.arr,a.dep,a.setrate,b.agent,b.company,b.roomno,c.rmrev,c.fbrev,c.total from master a,#goutput b,#revenue c where a.accnt=b.accnt and b.accnt=c.accnt
;