if exists(select * from sysobjects where name = 'p_gl_accnt_detail_transfer' and type = 'P')
	drop proc p_gl_accnt_detail_transfer;

create proc p_gl_accnt_detail_transfer
	@date						datetime,
	@empno					char(10),
	@shift					char(1),
	@langid					integer = 0,
	@option					char(10) = 'ALL'		-- FRONT:前台,AR:AR账,ALL:所有
as

if rtrim(@empno) is null
	select @empno = '%'
if rtrim(@shift) is null
	select @shift = '%'
select * into #account from account where 1 = 2
if @option in ('FRONT', 'ALL')
	insert #account select a.* from account a, billno b
		where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'T%' and a.billno = b.billno
		union select a.* from haccount a, billno b
		where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'T%' and a.billno = b.billno
if @option in ('AR', 'ALL')
	insert #account (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
	select a.ar_accnt, a.subaccnt, a.number, a.inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, a.charge, a.charge1, a.charge2,
		a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, a.credit, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
		a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
		from ar_account a, billno b
		where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'T%' and a.billno = b.billno
	union select a.ar_accnt, a.subaccnt, a.number, a.inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, a.charge, a.charge1, a.charge2,
		a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, a.credit, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
		a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
		from har_account a, billno b
		where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'T%' and a.billno = b.billno
--
delete #account where tofrom != 'TO'
update #account set number = 1, charge = - charge, credit = - credit
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
	billno			char(10)		null,							-- 结帐单号
	roomno			char(5)		null,							-- 房号
	accnt				char(10)		null,							-- 帐号
	name				char(50)		null,							-- 客人姓名
	to_roomno		char(5)		null,							-- 房号
	to_accnt			char(10)		null,							-- 帐号
	to_name			char(50)		null,							-- 客人姓名
	pccode			char(5)		null,							-- 费用码
	ref				char(50)		null,							-- 费用名称
	amount			money			default 0	null, 
	number			integer		default 0	null
)
if @langid = 0
	insert #detail select a.billno, a.roomno, a.accnt, name = '小计' + space(50), to_roomno = space(5), to_accnt = a.accntof, to_name = space(50), a.pccode, b.descript, amount = a.charge + a.credit, number
		from #account a, pccode b where a.pccode = b.pccode
else
	insert #detail select a.billno, a.roomno, a.accnt, name = 'SubToal' + space(50), to_roomno = space(5), to_accnt = a.accntof, to_name = space(50), a.pccode, b.descript1, amount = a.charge + a.credit, number
		from #account a, pccode b where a.pccode = b.pccode
--
update #detail set name = b.name, roomno = a.roomno from master a, guest b where #detail.accnt = a.accnt and a.haccnt = b.no
update #detail set name = b.name, roomno = a.roomno from hmaster a, guest b where #detail.accnt = a.accnt and a.haccnt = b.no
update #detail set name = b.name from ar_master a, guest b where #detail.accnt = a.accnt and a.haccnt = b.no
update #detail set name = b.name from har_master a, guest b where #detail.accnt = a.accnt and a.haccnt = b.no
update #detail set to_name = b.name, to_roomno = a.roomno from master a, guest b where #detail.to_accnt = a.accnt and a.haccnt = b.no
update #detail set to_name = b.name, to_roomno = a.roomno from hmaster a, guest b where #detail.to_accnt = a.accnt and a.haccnt = b.no
update #detail set to_name = b.name from ar_master a, guest b where #detail.to_accnt = a.accnt and a.haccnt = b.no
update #detail set to_name = b.name from har_master a, guest b where #detail.to_accnt = a.accnt and a.haccnt = b.no
select * from #detail
;
