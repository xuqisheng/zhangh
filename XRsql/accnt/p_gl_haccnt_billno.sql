if exists(select * from sysobjects where name = "p_gl_haccnt_billno")
	drop proc p_gl_haccnt_billno;

create proc p_gl_haccnt_billno
	@pc_id			char(4),						// IP地址
	@mdi_id			integer,						// 唯一的账务窗口ID
	@roomno			char(5),						// 房号
	@accnt			char(10),					// 账号
	@subaccnt		integer,						// 子账号(如果@roomno = '99999', @subaccnt就是临时账夹的编号)
	@operation		char(10)
as
declare
	@charge			money,
	@count			integer
// 1.取出相关的结账单号
create table #billno0
(
	billno			char(10)			not null,
)
// 所有
if @roomno = '' and @accnt = ''
	insert #billno0 select distinct b.billno from accnt_set a, haccount b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt = b.accnt and b.billno like '[B,T]%'
// 指定房间
else if @accnt = ''
	insert #billno0 select distinct b.billno from accnt_set a, haccount b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0 and a.accnt = b.accnt and b.billno like '[B,T]%'
// 指定团体或账号
else
	insert #billno0 select distinct billno from haccount
		where accnt = @accnt and billno like '[B,T]%'
// 2.取出结账单的相关信息
create table #billno1
(
	billno			char(10)			not null,
	amount			money				null,
	log_date			datetime			null
)
insert #billno1 select b.billno, sum(b.charge), max(b.log_date)
	from #billno0 a, haccount b where a.billno = b.billno group by b.billno
update #billno1 set log_date = a.date1 from billno a where #billno1.billno = a.billno
// 3.加上'所有选中账'
select @charge = sum(a.charge * b.selected), @count = sum(b.selected)
	from haccount a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
if @count > 0
	insert #billno1 values ('所有选中账', @charge, getdate())
// 加上'所有未结账'，实际上无效
if @operation = 'uncheckout'
	begin
	select @charge = sum(a.charge), @count = count(1)
		from haccount a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.billno = ''
	if @count > 0
		insert #billno1 values ('所有未结账', @charge, getdate())
	end
//
select billno, amount, log_date from #billno1 order by billno desc
return
;
