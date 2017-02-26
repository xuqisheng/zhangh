--E34
drop proc p_clg_report_mem_stay_dtl;
create proc p_clg_report_mem_stay_dtl	
as
declare
	@accnt	char(10),
	@rmrev	money,
	@fbrev	money,
	@telrev	money,
	@other	money,
	@ttlrev	money
create table #goutput(
	accnt		char(10)		null,
	haccnt	char(7)		null,
	roomno	char(5)		null,
	name		varchar(50)	null,
	memtype	char(10)		null,
	memnum	char(20)		null,
	market	char(3)		null,
	rtcode	char(10)		null,
	arr		datetime		null,
	dep		datetime		null,
	nights	int			null,
	rate		money			null,
	paycode	char(6)		null)
create table #revenue(
	accnt		char(10),
	rmrev		money,
	fbrev		money,
	telrev	money,
	other		money,
	total		money)

insert into #goutput select a.accnt,a.haccnt,a.roomno,b.haccnt,'','',a.market,a.ratecode,a.arr,a.dep,datediff(dd,a.arr,a.dep),a.setrate,a.paycode
 from master a,master_des b
 where a.accnt=b.accnt and a.class='F' and a.sta='I'

update #goutput set memtype=b.cardcode,memnum=b.cardno from guest_card b where haccnt=b.no and b.cardcode='PCR'

declare c_accnt cursor for select accnt from #goutput where memtype='PCR'
open c_accnt
fetch c_accnt into @accnt
while @@sqlstatus=0
begin
	select @rmrev=isnull(sum(a.charge),0) from account a,pccode b where a.accnt=@accnt and a.pccode=b.pccode and b.deptno7='rm'
	select @fbrev=isnull(sum(a.charge),0) from account a,pccode b where a.accnt=@accnt and a.pccode=b.pccode and b.deptno7='fb'
	select @telrev=isnull(sum(a.charge),0) from account a,pccode b where a.accnt=@accnt and a.pccode=b.pccode and deptno='40'
	select @ttlrev=isnull(sum(a.charge),0) from account a where a.accnt=@accnt
	select @other=@ttlrev - @rmrev - @fbrev - @telrev
	insert into #revenue values(@accnt,@rmrev,@fbrev,@telrev,@other,@ttlrev)
	fetch c_accnt into @accnt
end

select roomno,name,memtype,memnum,market,rtcode,arr,dep,nights,rate,b.rmrev,b.fbrev,b.telrev,b.other,b.total,paycode
 from #goutput,#revenue b where #goutput.accnt=b.accnt and memtype='PCR';
