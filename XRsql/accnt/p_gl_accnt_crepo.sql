if exists (select * from sysobjects where name ='p_gl_accnt_crepo' and type ='P')
	drop proc p_gl_accnt_crepo;
create proc p_gl_accnt_crepo
	@pc_id			char(4),
	@date				datetime,
	@empno			char(10),
	@shift			char(1),
	@langid			integer = 0,
	@option			char(10) = 'ALL'		-- FRONT:前台,AR:AR账,ALL:所有
as

declare
	@en_str			varchar(40),
	@ds_str			varchar(40),
	@billno			char(10),
	@empname			char(10)

create table #daycred
(
	tag				char(1)	default'A' not null,
	deptno			char(5)	default '' not null,
	pccode			char(5)	default '' not null,
	descript			char(16)	default '' not null,
	amount1			money		default 0 not null,
	amount2			money		default 0 not null,
	amount3			money		default 0 not null,
	amount4			money		default 0 not null,
	amount5			money		default 0 not null,
	amount6			money		default 0 not null
)
--
if rtrim(@empno) is null
	select @empno = '%'
if rtrim(@shift) is null
	select @shift = '%'
select @en_str = isnull((select value from sysoption where catalog = 'audit' and item = 'en_str'), '')
select @ds_str = isnull((select value from sysoption where catalog = 'audit' and item = 'ds_str'), '')
-- 准备营业项目和付款方式 
insert #daycred (tag, deptno, pccode, descript) select isnull(b.grp, 'A'), a.deptno, a.pccode, a.descript
	from pccode a, basecode b where a.deptno *= b.code and b.cat = 'chgcod_deptno'
-- 1. 处理当天发生 
select * into #account from account where 1 = 2
if @option in ('FRONT', 'ALL')
	insert #account select * from account where bdate = @date and empno like @empno and shift like @shift
		union select * from haccount where bdate = @date and empno like @empno and shift like @shift
if @option in ('AR', 'ALL')
	insert #account (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
	select accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno
		from ar_account where bdate = @date and empno like @empno and shift like @shift and ar_tag = 'A'
	union select accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno
		from har_account where bdate = @date and empno like @empno and shift like @shift and ar_tag = 'A'
-- 删除当天的冲账转账明细
delete #account where not (crradjt in ('', 'AD', 'CT') or (crradjt like 'L%' and tofrom = ''))
-- 删除当天转销定金中产生的明细(仅限于不能调整付款的系统)
--delete #account where argcode in ('98', '99') and crradjt = 'AD'
update #account set argcode = '98' where argcode = '99' and not billno like 'B%'
update #account set argcode = '98' from billno b
	where #account.argcode = '99' and #account.billno = b.billno and #account.empno != b.empno1
-- 1.1 录入费用
update #daycred set amount4 = amount4 + isnull((select sum(charge) from #account a
	where a.pccode = #daycred.pccode), 0)
-- 1.2 预付
update #daycred set amount4 = amount4 + isnull((select sum(credit) from #account a, pccode b
	where a.argcode in ('98') and a.credit > 0 and a.pccode = b.pccode and b.pccode = #daycred.pccode), 0)
	where #daycred.pccode > '9'
-- 1.3 调整预付
update #daycred set amount5 = amount5 + isnull((select sum(credit) from #account a, pccode b
	where a.argcode in ('98') and a.credit < 0 and a.pccode = b.pccode and b.pccode = #daycred.pccode), 0)
	where #daycred.pccode > '9'
-- 1.4 实际收款
update #daycred set amount6 = amount6 + isnull((select sum(credit) from #account a, pccode b
	where a.pccode = b.pccode and b.pccode = #daycred.pccode), 0) where #daycred.pccode > '9'
-- 2. 处理当天结帐 
truncate table #account
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
update #account set argcode = '98' where argcode = '99' and not billno like 'B%'
-- 别人的结算款作定金处理
update #account set argcode = '98' where argcode = '99' and @empno != '%' and empno != @empno
-- 2.1 费用
update #daycred set amount2 = amount2 + isnull((select sum(charge + charge2) from #account a
	where a.pccode = #daycred.pccode), 0)
-- 2.2 折扣
update #daycred set amount3 = amount3 - isnull((select sum(charge2) from #account a
	where a.pccode = #daycred.pccode), 0)
-- 2.3 实收
update #daycred set amount3 = amount6 - amount4 - amount5 where #daycred.pccode > '9'
-- 2.4 只有输入的金额小于零的定金才记入冲减预付
update #daycred set amount2 = amount2
	+ isnull((select sum(credit) from #account a, pccode b where a.argcode in ('98') and a.billno != '' and a.pccode = b.pccode and b.pccode = #daycred.pccode), 0)
	- isnull((select sum(credit) from #account a, pccode b where a.argcode in ('98') and a.credit < 0 and a.billno = '' and a.pccode = b.pccode and b.pccode = #daycred.pccode), 0)
 	where #daycred.pccode > '9'
--not (a.credit > 0 or a.crradjt in ('AD'))
-- 2.5 结账总额
update #daycred set amount1 = amount2 + amount3
-- 2.6 倒扣
declare billno_cursor cursor for
	select distinct billno from #account
	where argcode in ('98', '99') and charindex(tag, @en_str + '#' + @ds_str) > 0
open billno_cursor
fetch billno_cursor into @billno
while @@sqlstatus = 0
	begin
	delete apportion_jie where pc_id = @pc_id
	delete apportion_dai where pc_id = @pc_id
	delete apportion_jiedai where pc_id = @pc_id
	insert apportion_jie select @pc_id, accnt, number, pccode, tag, charge from #account
		where billno = @billno and pccode < '9'
	insert apportion_dai
		select @pc_id, a.tag, sum(a.credit), isnull(b.code, ''), '' from #account a, reason b
		where a.billno = @billno and a.pccode > '9' and a.reason *= b.code
		group by a.tag, isnull(b.code, '')
	update apportion_dai set accnt = isnull((select min(a.accnt) from #account a where a.billno = @billno), '')
		where pc_id = @pc_id
	exec p_gl_audit_apportion @pc_id, '004'
	update #daycred set amount5 = amount5 - isnull((select sum(a.charge) from apportion_jiedai a
		where a.pc_id = @pc_id and a.pccode = #daycred.pccode and charindex(a.paycode, @en_str + '#' + @ds_str) > 0), 0)
	fetch billno_cursor into @billno
	end
close billno_cursor
deallocate cursor billno_cursor
-- 2.7 收入合计
update #daycred set amount6 = amount4 + amount5 where pccode < '9'
--
insert #daycred select a.tag, a.deptno, '', b.descript, sum(a.amount1), sum(a.amount2), sum(a.amount3), sum(a.amount4), sum(a.amount5), sum(a.amount6)
	from #daycred a, basecode b where a.deptno = b.code and b.cat = 'chgcod_deptno'
	group by a.tag, a.deptno, b.descript
-- 贷方 
--
if @empno = '%'
	select @empname = "所有收银员"
select descript, amount1, amount2, amount3, amount4, amount5, amount6, tag, pccode, @empno
	from #daycred where ((tag = 'A') or (tag = '1' and pccode = '') or (tag = '2' and pccode != ''))
	and (amount1 != 0 or amount2 != 0 or amount3 != 0 or amount4 != 0 or amount5 != 0 or amount6 != 0)
	order by tag, deptno, pccode
return 0;
