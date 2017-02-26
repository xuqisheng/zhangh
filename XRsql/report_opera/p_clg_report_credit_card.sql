--F22的过程
drop proc p_clg_report_credit_card;
create proc p_clg_report_credit_card
	@s_date	datetime,
	@e_date	datetime
as
declare
	@accnt	char(10),
	@rmrev	money,
	@fbrev	money,
	@other	money,
	@ttlrev	money
create table #goutput(
	accnt		char(10)		null,
	roomno	char(5)		null,
	name		varchar(50)	null,
	arr		datetime		null,
	dep		datetime		null,
	cardno	char(20)		null,
	expiry	datetime		null,
	amount	money			null)
create table #revenue(
	accnt		char(10),
	rmrev		money,
	fbrev		money,
	nonrev	money,
	other		money,
	total		money)

insert into #goutput
select a.accnt,a.roomno,c.name,a.arr,a.dep,b.cardno,b.expiry_date,b.amount from master a,accredit b,guest c
	where a.haccnt=c.no and a.accnt=b.accnt and datediff(dd,a.dep,@s_date)<=0 and datediff(dd,a.dep,@e_date)>=0 and a.class='F'
union
select a.accnt,a.roomno,c.name,a.arr,a.dep,b.cardno,b.expiry_date,b.amount from hmaster a,accredit b,guest c
	where a.haccnt=c.no and a.accnt=b.accnt and datediff(dd,a.dep,@s_date)<=0 and datediff(dd,a.dep,@e_date)>=0 and a.class='F'

declare c_accnt cursor for select accnt from #goutput
open c_accnt
fetch c_accnt into @accnt
while @@sqlstatus=0
begin
	select @rmrev=isnull(sum(a.charge),0) from account a,pccode b where a.accnt=@accnt and a.pccode=b.pccode and b.deptno7='rm'
	select @fbrev=isnull(sum(a.charge),0) from account a,pccode b where a.accnt=@accnt and a.pccode=b.pccode and b.deptno7='fb'
	--总消费金额=sum(charge)
	select @ttlrev=isnull(sum(a.charge),0) from account a where a.accnt=@accnt
	select @rmrev=@rmrev+isnull(sum(a.charge),0) from haccount a,pccode b where a.accnt=@accnt and a.pccode=b.pccode and b.deptno7='rm'
	select @fbrev=@fbrev+isnull(sum(a.charge),0) from haccount a,pccode b where a.accnt=@accnt and a.pccode=b.pccode and b.deptno7='fb'
	select @ttlrev=@ttlrev+isnull(sum(a.charge),0) from haccount a where a.accnt=@accnt
	select @other=@ttlrev - @rmrev - @fbrev
	insert into #revenue values(@accnt,@rmrev,@fbrev,0,@other,@ttlrev)
	fetch c_accnt into @accnt
end
	
select roomno,name,arr,dep,cardno,expiry,b.rmrev,b.fbrev,b.other,b.nonrev,b.total,amount
 from #goutput,#revenue b where #goutput.accnt=b.accnt order by dep,roomno
;