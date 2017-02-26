// 为ar_audit准备原始明细账
if exists(select * from sysobjects where name = "p_gl_ar_preaudit1")
	drop proc p_gl_ar_preaudit1;

create proc p_gl_ar_preaudit1
	@pc_id				char(4),
	@mdi_id				integer,
	@accnt				char(10),
	@number				integer
as
declare
	@foaccnt				char(10),					-- 前台账号
	@fonumber			integer,
	@fobillno			char(10),
	@charge				money,
	@credit				money,
	@pccode				char(10),
	@ref					char(24)

create table #account_temp
(
	accnt					char(10),					-- 账号
	number				integer						-- 账次
)

delete ar_audit where pc_id = @pc_id and mdi_id = @mdi_id
select @foaccnt = accnt, @fonumber = number, @charge = charge
	from ar_account where ar_accnt = @accnt and ar_inumber = @number and ar_tag = 'P'
select @fobillno = billno, @credit = credit from account where accnt = @foaccnt and number = @fonumber
if @fobillno is null
	select @fobillno = billno, @credit = credit from haccount where accnt = @foaccnt and number = @fonumber
-- 前台已结
if @charge = @credit and @fobillno like 'B%'
	begin
	insert #account_temp
		select accnt, number from account where billno = @fobillno
		union select accnt, number from haccount where billno = @fobillno
	delete #account_temp where accnt = @foaccnt and number = @fonumber
	insert ar_audit select @pc_id, @mdi_id, 'F', a.*
		from account a, #account_temp b where b.accnt = a.accnt and b.number = a.number
		union select @pc_id, @mdi_id, 'F', a.*
		from haccount a, #account_temp b where b.accnt = a.accnt and b.number = a.number
	delete ar_audit where pc_id = @pc_id and mdi_id = @mdi_id and pccode = '9'
	end
-- 前台未结
else
	begin
	select @pccode = isnull((select value from sysoption where catalog = 'ar' and item = 'ar_account_pccode'), '1000')
	select @ref = descript from pccode where pccode = @pccode
	insert ar_audit (pc_id, mdi_id, type, accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
		select @pc_id, @mdi_id, 'F', ar_accnt, subaccnt, ar_number, ar_inumber, modu_id, log_date, bdate, date, @pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, ar_tag, reason,
		tofrom, accntof, subaccntof, @ref, ref1, ref2, roomno, groupno, mode, billno
		from ar_account  where ar_accnt = @accnt and ar_inumber = @number and ar_tag = 'P'
	end
select 0, ''
return 0
;
