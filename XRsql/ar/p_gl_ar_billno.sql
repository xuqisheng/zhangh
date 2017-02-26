if exists(select * from sysobjects where name = "p_gl_ar_billno")
	drop proc p_gl_ar_billno;

create proc p_gl_ar_billno
	@pc_id			char(4),						// IP地址
	@mdi_id			integer,						// 唯一的账务窗口ID
	@accnt			char(10)						// 账号
as
declare
	@charge1			money,
	@count1			integer,
	@charge2			money,
	@count2			integer
// 1.取出相关的结账单号
create table #billno0
(
	billno			char(10)			not null,
)
// 所有
if @accnt = ''
	insert #billno0 select distinct b.billno from accnt_set a, ar_apply b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and (a.accnt = b.d_accnt or a.accnt = b.c_accnt)
// 指定账号
else
	insert #billno0 select distinct billno from ar_apply where d_accnt = @accnt or c_accnt = @accnt
// 2.取出结账单的相关信息
create table #billno1
(
	billno			char(10)			not null,
	amount			money				null,
	empno				char(10)			not null,
	log_date			datetime			null
)
--insert #billno1 select b.billno, sum(b.amount), b.empno, b.log_date
--	from #billno0 a, ar_apply b where a.billno = b.billno group by b.billno, b.empno, b.log_date
-- 新核销
insert #billno1 select b.billno, sum(b.amount), b.empno, b.log_date
	from #billno0 a, ar_apply b where a.billno = b.billno and d_accnt != '' group by b.billno, b.empno, b.log_date
--
select billno, amount, empno, log_date from #billno1 order by billno desc
return;
