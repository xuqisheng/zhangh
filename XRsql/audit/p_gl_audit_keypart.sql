if exists(select * from sysobjects where name = "p_gl_audit_keypart")
	drop proc p_gl_audit_keypart;

create proc p_gl_audit_keypart
	@ret			integer		out, 
	@msg			varchar(70)	out
as

declare
	@billno		char(10), 
	@setnumb		char(10), 
	@bdate		datetime,
	@lic_buy_1	varchar(255),
	@lic_buy_2	varchar(255)

select @ret = 0, @msg = ''
select @bdate = bdate from sysdata
update account set argcode = '98' where argcode = '99' and not billno like 'B%'
update account set argcode = '98' from billno b
	where account.argcode = '99' and account.billno = b.billno and account.empno != b.empno1
select @billno = convert(char(10), @bdate, 111)
select @setnumb = substring(@billno, 3, 2) + substring(@billno, 6, 2) + substring(@billno, 9, 2) + '%'
select @billno = 'B' + substring(@billno, 4, 1) + substring(@billno, 6, 2) + substring(@billno, 9, 2) + '%'
-- 1.发生数
truncate table gltemp
	-- 应收账发生
insert gltemp (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
	charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
	tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno, package)
	select ar_accnt, subaccnt, ar_number, ar_inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
	charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, ar_tag, reason,
	tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno, ar_subtotal
	from ar_account  where bdate = @bdate
	-- 去掉压缩账目和当天审核的账目
delete gltemp where not (tag in ('A', 'T', 't') and package = 'F' or tag in ('P'))
	-- 前台转到应收的特别处理(当天的前台账目不能审核)
update gltemp set pccode = '', argcode = '' where charge != 0 and argcode > '9'
	-- 前台发生
insert gltemp select * from account where bdate = @bdate
-- 2.收回数
truncate table outtemp
	-- 前台收回
insert outtemp select * from account where billno like @billno
	-- 应收账收回
CREATE TABLE #ar_apply         ---- add by zjl
(
	d_accnt		char(10)		not null,
	d_inumber	integer		not null,
	c_accnt		char(10)		not null,
	c_inumber	integer		not null,
	amount		money			default 0 not null,
	billno		char(10)		not null
)
insert #ar_apply select d_accnt, d_inumber, '', 0, isnull(sum(amount), 0), billno
	from ar_apply where billno like @billno group by d_accnt, d_inumber, billno
insert #ar_apply select '', 0, c_accnt, c_inumber, isnull(sum(amount), 0), billno
	from ar_apply where billno like @billno group by c_accnt, c_inumber, billno
delete #ar_apply where d_accnt = '' and d_inumber = 0 and c_accnt = '' and c_inumber = 0

insert outtemp (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
	charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
	tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
	select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, b.amount, a.charge1, a.charge2,
	a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, a.credit, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
	a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
	from ar_account a, #ar_apply b where b.billno like @billno and b.d_accnt = a.ar_accnt and b.d_inumber = a.ar_number
	union select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, b.amount, a.charge1, a.charge2,
	a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, a.credit, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
	a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
	from har_account a, #ar_apply b where b.billno like @billno and b.d_accnt = a.ar_accnt and b.d_inumber = a.ar_number
insert outtemp (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
	charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
	tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
	select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, a.charge, a.charge1, a.charge2,
	a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, b.amount, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
	a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
	from ar_account a, #ar_apply b where b.billno like @billno and b.c_accnt = a.ar_accnt and b.c_inumber = a.ar_number
	union select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, a.charge, a.charge1, a.charge2,
	a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, b.amount, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
	a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
	from har_account a, #ar_apply b where b.billno like @billno and b.c_accnt = a.ar_accnt and b.c_inumber = a.ar_number
-- 3.信用卡
truncate table ar_creditcard
update ar_detail set audit = '1' where bdate = @bdate and audit in ('0', '2') and charge = 0 and charge0 = 0 and credit = 0 and credit0 = 0
insert ar_creditcard select *, '', 0 from ar_detail where audit = '2'
update ar_creditcard set pccode = a.pccode, argcode = a.argcode, waiter = a.waiter
	from ar_account a where ar_creditcard.accnt = a.ar_accnt and ar_creditcard.number = a.ar_inumber
--
-- 修改错误的市场码
--update master set market = 'XXX', cby = 'SYSTEM', changed = getdate(), logmark = logmark + 1
--	where class = 'F' and groupno = '' and not market in (select code from mktcode where grp! = 'GRP')
--update master set market = 'GRI', cby = 'SYSTEM', changed = getdate(), logmark = logmark + 1
--	where (class in ('G', 'M') or substring(groupno, 1, 1) in ('G', 'M')) and not market in (select code from mktcode where grp = 'GRP')
update gltemp set tag = a.market from master a where gltemp.accnt = a.accnt
update gltemp set tag = a.market from master a where gltemp.accntof = a.accnt and tofrom in ('', 'FM')
update outtemp set tag = a.market from master a where outtemp.accnt = a.accnt
update outtemp set tag = a.market from master a where outtemp.accntof = a.accnt and tofrom in ('', 'FM')
-- 维护账务库的charge1
update gltemp set charge1 = charge + charge2 - charge3 - charge4 - charge5
update outtemp set charge1 = charge + charge2 - charge3 - charge4 - charge5
--
return @ret
;