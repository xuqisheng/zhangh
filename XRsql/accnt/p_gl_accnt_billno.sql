if exists(select * from sysobjects where name = "p_gl_accnt_billno")
	drop proc p_gl_accnt_billno;

create proc p_gl_accnt_billno
	@pc_id			char(4),						// IP地址
	@mdi_id			integer,						// 唯一的账务窗口ID
	@roomno			char(5),						// 房号
	@accnt			char(10),					// 账号
	@subaccnt		integer,						// 子账号(如果@roomno = '99999', @subaccnt就是临时账夹的编号)
	@operation		char(20),
	@langid			integer = 0
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
if @roomno = '' and @accnt = ''
	begin
	insert #billno0 select distinct b.billno from accnt_set a, account b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt = b.accnt and b.billno like '[B,T]%'
	union select distinct b.billno from accnt_set a, haccount b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt = b.accnt and b.billno like '[B,T]%'
	end
// 指定房间
else if @accnt = ''
	begin
	insert #billno0 select distinct b.billno from accnt_set a, account b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0 and a.accnt = b.accnt and b.billno like '[B,T]%'
	union select distinct b.billno from accnt_set a, haccount b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0 and a.accnt = b.accnt and b.billno like '[B,T]%'
	end
// 指定团体或账号
else
	begin
	insert #billno0 select distinct billno from account
		where accnt = @accnt and billno like '[B,T]%'
	union select distinct billno from haccount
		where accnt = @accnt and billno like '[B,T]%'
	end
// 2.取出结账单的相关信息
create table #billno1
(
	billno			char(10)			not null,
	descript			char(20)			not null,
	amount			money				null,
	log_date			datetime			null
)
insert #billno1 select b.billno, b.billno, sum(b.charge), max(b.log_date)
	from #billno0 a, account b where a.billno = b.billno group by b.billno
insert #billno1 select b.billno, b.billno, sum(b.charge), max(b.log_date)
	from #billno0 a, haccount b where a.billno = b.billno group by b.billno
update #billno1 set log_date = a.date1 from billno a where #billno1.billno = a.billno
// 3.加上'所有选中账'
select @charge1 = 0, @count1 = 0, @charge2 = 0, @count2 = 0
select @charge1 = sum(a.charge * b.selected), @count1 = sum(b.selected)
	from account a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
select @charge2 = sum(a.charge * b.selected), @count2 = sum(b.selected)
	from haccount a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
if @count1 is null
	select @charge1 = 0, @count1 = 0
if @count2 is null
	select @charge2 = 0, @count2 = 0
if @count1 + @count2 > 0 and @langid = 0
	insert #billno1 values ('所有选中账', '所有选中账', @charge1 + @charge2, getdate())
else if @count1 + @count2 > 0
	insert #billno1 values ('所有选中账', 'Selected Details', @charge1 + @charge2, getdate())
// 加上'所有未结账'
if @operation = 'uncheckout'
	begin
	select @charge1 = 0, @count1 = 0
	select @charge1 = sum(a.charge), @count1 = count(1)
		from account a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.billno = ''
	if @count1 > 0 and @langid = 0
		insert #billno1 values ('所有未结账', '所有未结账', @charge1 + @charge2, getdate())
	else if @count1 > 0
		insert #billno1 values ('所有未结账', 'Valid Details', @charge1 + @charge2, getdate())
	//
	end
if @operation = 'cancelcheckout'
	delete #billno1 where not billno like 'B%'
select billno, descript, amount, log_date from #billno1 order by billno desc
return;
