/* 生成收付明细 */
if exists ( select * from sysobjects where name = 'p_gl_accnt_detail_scjj' and type ='P')
	drop proc p_gl_accnt_detail_scjj;
create proc p_gl_accnt_detail_scjj
	@pc_id			char(4), 
	@date				datetime,
	@empno			char(10), 
	@shift			char(1) = ''
as

declare
	@tail				char(2), 
	@modu_id			char(2), 
	@tocode			char(3), 
	@pccode			char(5), 
	@key0				char(3), 
	@billno			char(10), 
	@menu				char(10), 
	@setnumb			char(10), 
	@refer			char(15)

create table #detail
(
	pc_id				char(4)	not null,							/*  */
	billno			char(10)	default '' not null,				/* 结帐单号(前台帐务) */
	deptno			char(5)	default '' not null,				/* 部门码 */
	pccode			char(5)	default '' not null,				/* 费用码 */
	descript			char(24)	default '' not null,				/* 项目描述 */
	charge			money		default 0 not null,				/* 金额 */
	paycode			char(5)	default '' not null,				/* 付款方式 */
	bankcode			char(3)	default '' not null,				/* 刷卡行 */
	tag				integer	default 1 not null				/* 付款方式数量 */
)

if rtrim(@empno) is null
	select @empno = '%'
if rtrim(@shift) is null
	select @shift = '%'
select * into #account from account where 1 = 2
insert #account 
	select a.* from account a, billno b
	where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'B%' and a.billno = b.billno
	union select a.* from haccount a, billno b
	where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'B%' and a.billno = b.billno
update #account set pccode = '901' where pccode = '902'
update #account set pccode = '903' where pccode = '904'
//
declare billno_cursor cursor for select billno from billno 
	where bdate = @date and empno1 like @empno and billno like 'B%' and empno2 is null
open billno_cursor
fetch billno_cursor into @billno
while @@sqlstatus = 0
	begin
	delete apportion_jie where pc_id = @pc_id
	delete apportion_dai where pc_id = @pc_id
	delete apportion_jiedai where pc_id = @pc_id
	insert apportion_jie select @pc_id, accnt, number, pccode, tag, charge from #account
		where billno = @billno and pccode < '9'
//	insert apportion_dai select @pc_id, a.pccode, sum(a.credit), isnull(b.type, ''), '' from #account a, reason b
//		where a.billno = @billno and a.pccode > '9' and a.reason *= b.code group by a.pccode, isnull(b.type, '')
// waiter : 刷卡行代码
	insert apportion_dai select @pc_id, a.pccode, sum(a.credit), a.waiter, '' from #account a
		where a.billno = @billno and a.pccode > '9' group by a.pccode, a.waiter
	update apportion_dai set accnt = isnull((select min(a.accnt) from apportion_jie a where a.pc_id = @pc_id), '')
		where pc_id = @pc_id
	exec p_gl_audit_apportion @pc_id
	if exists (select 1 from apportion_jiedai where pc_id = @pc_id and accnt = '')
		update apportion_jiedai set pccode = '009', accnt = (select min(a.accnt) from apportion_dai a 
			where a.pc_id = @pc_id and a.paycode = apportion_jiedai.paycode and a.key0 = apportion_jiedai.key0)
			where pc_id = @pc_id and accnt = ''
	insert #detail (pc_id, billno, pccode, charge, paycode, bankcode)
		select @pc_id, @billno, pccode, sum(charge), paycode, key0
		from apportion_jiedai where pc_id = @pc_id group by pccode, paycode, key0
	fetch billno_cursor into @billno
	end
close billno_cursor
deallocate cursor billno_cursor
// 客房其他、代收项目要单列
//update #detail set deptno = a.deptno, descript = b.descript from pccode a, basecode b
//	where #detail.pccode = a.pccode and a.deptno = b.code and b.cat = 'chgcod_deptno' and b.grp = '1'
//update #detail set deptno = a.deptno, descript = a.descript from pccode a, basecode b
//	where #detail.pccode = a.pccode and a.deptno = b.code and b.cat = 'chgcod_deptno' and b.grp = '2'
update #detail set deptno = a.deptno, descript = b.descript from pccode a, basecode b
	where #detail.pccode = a.pccode and a.deptno = b.code and b.cat = 'chgcod_deptno' and (b.grp = '1' and a.deptno <> '07')
update #detail set deptno = a.deptno, descript = a.descript from pccode a, basecode b
	where #detail.pccode = a.pccode and a.deptno = b.code and b.cat = 'chgcod_deptno' and (b.grp = '2' or a.deptno = '07')
update #detail set tag = (select count(distinct a.paycode) from #detail a where a.billno = #detail.billno)
	where pc_id = @pc_id
// 预收订金
truncate table #account
insert #account
	select * from account where bdate = @date and empno like @empno and shift like @shift
	union select * from haccount where bdate = @date and empno like @empno and shift like @shift
update #account set pccode = '901' where pccode = '902'
update #account set pccode = '903' where pccode = '904'
delete #account where not (crradjt in ('', 'AD', 'CT') or (crradjt like 'L%' and tofrom = ''))
update #account set billno = '' where billno like 'T%'
update #account set argcode = '98' where argcode = '99' and billno = ''
insert #detail (pc_id, deptno, pccode, descript, charge, paycode)
	select @pc_id, '999', '', '预付订金', sum(credit), pccode
	from #account where argcode in ('98') and credit > 0 group by pccode
//
create table #detail_scjj
(
	bdate				datetime,							/*  */
	paycode			char(5)	default '' not null,				/* 付款方式 */
	deptno			char(5)	default '' not null,				/* 部门码 */
	descript			char(24)	default '' not null,				/* 项目描述 */
	charge			money		default 0 not null,				/* 金额 */
	descript1		char(54)	default '' not null,				/* 付款方式描述 */
	billno			char(10)	default '' not null,				/*  */
	empno				char(10)	default '' not null,				/* 员工工号 */
	amount			money		default 0 not null,				/* 实收金额 */
	bankcode			char(3)	default '' not null,				/* 刷卡行 */
	descript2		char(24)	default '' not null,				/* 刷卡行描述 */
	commission		money		default 0 not null				/* 佣金 */
)
insert #detail_scjj (bdate, paycode, deptno, descript, charge, descript1, bankcode)
	select @date, b.pccode, a.deptno, a.descript, sum(a.charge), b.descript, a.bankcode
	from #detail a, pccode b
	where pc_id = @pc_id and a.tag = 1 and a.paycode = b.pccode
	group by b.pccode, a.deptno, a.descript, b.descript, a.bankcode
//
insert #detail_scjj (bdate, paycode, deptno, descript, charge, descript1, billno, bankcode)
	select @date, b.pccode, a.deptno, a.descript, sum(a.charge), b.descript, a.billno, a.bankcode
	from #detail a, pccode b
	where pc_id = @pc_id and a.tag > 1 and a.paycode = b.pccode
	group by b.pccode, a.deptno, a.descript, b.descript, a.billno, a.bankcode
update #detail_scjj set descript2 = a.descript from basecode a where #detail_scjj.bankcode = a.code and a.cat = 'bankcode'
update #detail_scjj set commission = a.commission
	from bankcard a where #detail_scjj.paycode = a.pccode and #detail_scjj.bankcode = a.bankcode
//
if @empno = '%'
	select @empno = '所有收银员'
update #detail_scjj set empno = @empno, amount = isnull((select sum(a.credit) from #account a
	where a.pccode = #detail_scjj.paycode and a.waiter = #detail_scjj.bankcode and not a.billno in 
	(select c.billno from #detail_scjj c where c.billno <> '')), 0)
	where billno = ''
update #detail_scjj set empno = @empno, amount = isnull((select sum(a.credit) from #account a, pccode b
	where a.billno = #detail_scjj.billno and a.pccode = b.pccode and b.pccode = #detail_scjj.paycode), 0)
	where billno <> ''
//
update #detail_scjj set descript1 = rtrim(descript1) + '  --  ' + descript2 where descript2 <> ''

// -- 每组最少 7 行 ---〉〉〉 加上下面这些，会有错
declare	@b_date datetime, @g_paycode char(5),@g_des char(54), @g_billno char(10), @g_cnt int,
			@g_empno char(10), @g_amount money, @g_com money
declare	c_add cursor for select bdate,paycode,descript1,billno,empno,amount,commission,count(1) 
	from #detail_scjj group by bdate,paycode,descript1,billno,empno,amount,commission
open c_add
fetch c_add into @b_date,@g_paycode,@g_des,@g_billno,@g_empno,@g_amount,@g_com,@g_cnt
while @@sqlstatus = 0
begin
	while @g_cnt < 7 
	begin
		insert #detail_scjj(bdate,paycode,descript1,billno,deptno,empno,amount,commission) 
			values(@b_date,@g_paycode,@g_des,@g_billno,'aa',@g_empno,@g_amount,@g_com)
		select @g_cnt = @g_cnt + 1
	end
	fetch c_add into @b_date,@g_paycode,@g_des,@g_billno,@g_empno,@g_amount,@g_com,@g_cnt
end
close c_add
deallocate cursor c_add

//
select bdate, paycode, deptno, descript, charge, descript1, billno, empno, amount, commission
	from #detail_scjj order by billno, descript1, deptno
;
