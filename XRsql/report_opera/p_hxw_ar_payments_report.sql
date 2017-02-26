/*
  FOR 洲际 假日报表使用 ar_payments 报表  2006.09.13 
*/

if exists (select * from sysobjects where name ='p_hxw_ar_payments_report' and type ='P')
	drop proc p_hxw_ar_payments_report;
create proc p_hxw_ar_payments_report
	@date          datetime,
	@langid			integer = 0
as
declare
	@billno        char(10),  
	@empno			char(10),
	@bdate			datetime,
	@shift			char(1),
	@log_date		datetime,
	@ref				varchar(50),
	@pay_for			varchar(20),
	@pay_by			varchar(20),
	@cnumber			integer
--
create table #apply
(
	type				char(1)		null,
	accnt				char(10)		null,
	number			integer		null,
	inumber			integer		null,
	pnumber			integer		null,
	guestname		char(50)		null,
	guestname2		char(50)		null,
	tag				char(1)		null,
	ref				char(50)		null,
	ref1				char(10)		null,
	ref2				char(100)	null,
	pccode			char(5)		null,
	charge			money			null,
	credit			money			null,
	apply_charge	money			null,
	apply_credit	money			null,
	empno				char(10)		null,
	bdate				datetime		null,
	shift				char(1)		null,
	date				datetime		null,
	log_date			datetime		null,
	billno         char(10)    null

)



declare c_billno cursor  for select billno from billno where datediff (dd,date1,@date)=0 
open  c_billno


fetch c_billno into @billno
while @@sqlstatus=0
	begin	
		select @empno = empno1, @shift = shift1, @bdate = bdate, @log_date = date1 
			from billno where billno = @billno
		if @@rowcount = 0
			select @empno = min(empno), @shift = min(shift), @bdate = min(bdate), @log_date = min(log_date)
				from ar_apply where billno = @billno
		insert #apply (type, accnt, number, inumber, apply_credit,billno) select 'C', c_accnt, c_inumber, c_number, sum(amount),@billno
			from ar_apply where billno = @billno group by c_accnt, c_number, c_inumber
		insert #apply (type, accnt, number, inumber, apply_charge,billno) select 'D', d_accnt, d_inumber, d_number, sum(amount),@billno
			from ar_apply where billno = @billno group by d_accnt, d_number, d_inumber
		-- 新核销
		delete #apply where accnt = '' and number = 0 and inumber = 0
		-- 找出主账（汇总账）
//		update #apply set pnumber = a.ar_pnumber
//			from ar_account a where #apply.accnt = a.ar_accnt and #apply.number = a.ar_number
//		update #apply set pnumber = a.ar_pnumber
//			from har_account a where #apply.accnt = a.ar_accnt and #apply.number = a.ar_number
//		
//		insert #apply (type, accnt, number, inumber, apply_charge, apply_credit) select type, accnt, pnumber, 0, sum(apply_charge), sum(apply_credit)
//			from #apply where pnumber != 0 group by type, accnt, pnumber
//		
//		update #apply set inumber = a.ar_inumber from ar_account a
//			where #apply.inumber = 0 and #apply.accnt = a.ar_accnt and #apply.number = a.ar_number
//		update #apply set inumber = a.ar_inumber from har_account a
//			where #apply.inumber = 0 and #apply.accnt = a.ar_accnt and #apply.number = a.ar_number
		--
		update #apply set guestname = a.guestname, guestname2 = a.guestname2
			from ar_detail a where #apply.accnt = a.accnt and #apply.inumber = a.number
		update #apply set guestname = a.guestname, guestname2 = a.guestname2
			from har_detail a where #apply.accnt = a.accnt and #apply.inumber = a.number
		update #apply set tag = a.ar_tag, ref = a.ref, ref1 = a.ref1, ref2 = a.ref2, pccode = a.pccode, charge = a.charge, credit = a.credit, 
			empno = a.empno, bdate = a.bdate, shift = a.shift, date = a.date, log_date = a.log_date
			from ar_account a where #apply.accnt = a.ar_accnt and #apply.number = a.ar_number
		update #apply set tag = a.ar_tag, ref = a.ref, ref1 = a.ref1, ref2 = a.ref2, pccode = a.pccode, charge = a.charge, credit = a.credit, 
			empno = a.empno, bdate = a.bdate, shift = a.shift, date = a.date, log_date = a.log_date
			from har_account a where #apply.accnt = a.ar_accnt and #apply.number = a.ar_number
		--

		fetch c_billno into @billno
	end
close c_billno
deallocate cursor c_billno

select @empno, @bdate, @shift, @log_date, type, accnt, number, inumber, guestname, guestname2,
	tag, ref, ref1, ref2, pccode, charge, credit, isnull(apply_charge, 0), isnull(apply_credit, 0), empno, bdate, shift, date, log_date,billno
	from #apply order by accnt, inumber, number
return 0
;


exec p_hxw_ar_payments_report '2006.09.13',0;