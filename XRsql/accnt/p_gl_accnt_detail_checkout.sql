if exists(select * from sysobjects where name = 'p_gl_accnt_detail_checkout' and type = 'P')
	drop proc p_gl_accnt_detail_checkout;

create proc p_gl_accnt_detail_checkout
	@date						datetime,
	@empno					char(10),
	@shift					char(1),
   @langid              integer = 0,
	@option					char(10) = 'ALL'		-- FRONT:前台,AR:AR账,ALL:所有
as

if rtrim(@empno) is null
	select @empno = '%'
if rtrim(@shift) is null
	select @shift = '%'
select * into #account from account where 1 = 2
if @option in ('FRONT', 'ALL')
	insert #account select a.* from account a, billno b
		where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'B%' and a.billno = b.billno
		union select a.* from haccount a, billno b
		where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'B%' and a.billno = b.billno
if @option in ('AR', 'ALL')
	begin
	create table #ar_apply
	(
		d_accnt		char(10)		not null,
		d_inumber	integer		not null,
		c_accnt		char(10)		not null,
		c_inumber	integer		not null,
		amount		money			default 0 not null,
		billno		char(10)		not null
	)
	insert #ar_apply select a.d_accnt, a.d_inumber, '', 0, isnull(sum(a.amount), 0), a.billno
		from ar_apply a, billno b
		where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'B%' and a.billno = b.billno
		group by a.d_accnt, a.d_inumber, a.billno
	insert #ar_apply select '', 0, a.c_accnt, a.c_inumber, isnull(sum(a.amount), 0), a.billno
		from ar_apply a, billno b
		where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'B%' and a.billno = b.billno
		group by a.c_accnt, a.c_inumber, a.billno
	delete #ar_apply where d_accnt = '' and d_inumber = 0 and c_accnt = '' and c_inumber = 0
	
	insert #account (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
		select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, b.amount, a.charge1, a.charge2,
		a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, a.credit, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
		a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
		from ar_account a, #ar_apply b where b.d_accnt = a.ar_accnt and b.d_inumber = a.ar_number
		union select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, b.amount, a.charge1, a.charge2,
		a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, a.credit, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
		a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
		from har_account a, #ar_apply b where b.d_accnt = a.ar_accnt and b.d_inumber = a.ar_number
	insert #account (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
		select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, a.charge, a.charge1, a.charge2,
		a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, b.amount, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
		a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
		from ar_account a, #ar_apply b where b.c_accnt = a.ar_accnt and b.c_inumber = a.ar_number
		union select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, a.charge, a.charge1, a.charge2,
		a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, b.amount, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
		a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
		from har_account a, #ar_apply b where b.c_accnt = a.ar_accnt and b.c_inumber = a.ar_number
	end
-- 别人的结算款作定金处理
update #account set argcode = '98' where argcode = '99' and @empno != '%' and empno != @empno
update #account set number = 1
--
insert #account (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
	select '', 0, 0, 0, '', getdate(), @date, @date, a.pccode, '', 0, sum(a.charge), 0, 0,
		0, 0, 0, 0, 0, 0, sum(a.credit), 0, '', '', '', '', '', '',
		'', '', 0, a.ref, '', '', '', '', '', a.billno
	from #account a where (select count(distinct b.roomno) from #account b where b.billno = a.billno) > 1
	group by a.billno, a.pccode, a.ref
--
create table #detail
(
	dc1				char(1)		null,							-- 大类代码
	dc2				char(10)		null,							-- 大类描述
	billno			char(10)		null,							-- 结帐单号
	roomno			char(5)		null,							-- 房号
	accnt				char(10)		null,							-- 帐号
	name				char(50)		null,							-- 客人姓名
	pccode			char(5)		null,							-- 费用码
	ref				char(50)		null,							-- 费用名称
	amount			money			default 0	null, 
	number			integer		default 0	null
)
if @langid = 0
	insert #detail select dc1 = '0', dc2 = '消费', a.billno, a.roomno, a.accnt, name = '小计' + space(50), a.pccode, b.descript, amount = a.charge, number
		from #account a, pccode b where a.pccode < '9' and a.pccode = b.pccode
		union all select dc1 = '1', dc2 = '冲抵定金', a.billno, a.roomno, a.accnt, name = '小计' + space(50), a.pccode, b.descript, amount = a.credit, number
		from #account a, pccode b where a.argcode = '98' and a.pccode > '9' and a.pccode = b.pccode
		union all select dc1 = '2', dc2 = '结账补差', a.billno, a.roomno, a.accnt, name = '小计' + space(50), a.pccode, b.descript, amount = a.credit, number
		from #account a, pccode b where a.argcode = '99' and a.pccode > '9' and a.pccode = b.pccode
else
	insert #detail select dc1 = '0', dc2 = 'Department', a.billno, a.roomno, a.accnt, name = 'Subtotal' + space(50), a.pccode, b.descript1, amount = a.charge, number
		from #account a, pccode b where a.pccode < '9' and a.pccode = b.pccode
		union all select dc1 = '1', dc2 = 'Deposit', a.billno, a.roomno, a.accnt, name = 'Subtotal' + space(50), a.pccode, b.descript1, amount = a.credit, number
		from #account a, pccode b where a.argcode = '98' and a.pccode > '9' and a.pccode = b.pccode
		union all select dc1 = '2', dc2 = 'Pay', a.billno, a.roomno, a.accnt, name = 'Subtotal' + space(50), a.pccode, b.descript1, amount = a.credit, number
		from #account a, pccode b where a.argcode = '99' and a.pccode > '9' and a.pccode = b.pccode
update #detail set name = b.name from master a, guest b where #detail.accnt = a.accnt and a.haccnt = b.no
update #detail set name = b.name from hmaster a, guest b where #detail.accnt = a.accnt and a.haccnt = b.no
update #detail set name = b.name from ar_master a, guest b where #detail.accnt = a.accnt and a.haccnt = b.no
update #detail set name = b.name from har_master a, guest b where #detail.accnt = a.accnt and a.haccnt = b.no
select * from #detail
;
