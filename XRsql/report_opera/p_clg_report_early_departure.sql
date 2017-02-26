--E68,69的过程
drop proc p_clg_report_early_departure;
create proc p_clg_report_early_departure
	@bdate	datetime,
	@retmode	char(1)
as
declare
	@accnt	char(10),
	@rmrev	money,
	@fbrev	money,
	@ttlrev	money
create table #goutput(
	accnt		char(10)		null,
	haccnt	char(7)		null,
	roomno	char(5)		null,
	name		varchar(50)	null,
	memtype	char(10)		null,
	memnum	char(20)		null,
	type		char(5)		null,
	arr		datetime		null,
	dep		datetime		null,
	odep		datetime		null,
	rate		money			null,
	company	varchar(50)	null,
	agent		varchar(50)	null,
	src		char(10)		null)
create table #revenue(
	accnt		char(10),
	rmrev		money,
	fbrev		money,
	total		money)

insert into #goutput select a.accnt,a.haccnt,a.roomno,b.haccnt,'','',a.type,a.arr,a.dep,d.dep,a.setrate,b.cusno,b.agent,a.src
 from master a,master_des b,master_till d
 where a.accnt=b.accnt and a.accnt=d.accnt and a.class='F' and a.sta='O'
 and exists(select 1 from master_till d where a.accnt=d.accnt and d.sta='I' and datediff(dd,d.dep,@bdate)<0)

update #goutput set memtype=b.cardcode,memnum=b.cardno from guest_card b where haccnt=b.no and b.cardcode='PCR'
--所有-All
if @retmode='A'
	select roomno,name,memtype,memnum,type,arr,dep,odep,rate,company,agent,src from #goutput
--会员-Mem-PCR
if @retmode='M'
begin
	declare c_accnt cursor for select accnt from #goutput where memtype='PCR'
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
	select roomno,name,memtype,memnum,type,arr,dep,odep,rate,b.rmrev,b.fbrev,b.total from #goutput,#revenue b where #goutput.accnt=b.accnt and memtype='PCR'
end
;