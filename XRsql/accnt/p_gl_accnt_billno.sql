if exists(select * from sysobjects where name = "p_gl_accnt_billno")
	drop proc p_gl_accnt_billno;

create proc p_gl_accnt_billno
	@pc_id			char(4),						// IP��ַ
	@mdi_id			integer,						// Ψһ�����񴰿�ID
	@roomno			char(5),						// ����
	@accnt			char(10),					// �˺�
	@subaccnt		integer,						// ���˺�(���@roomno = '99999', @subaccnt������ʱ�˼еı��)
	@operation		char(20),
	@langid			integer = 0
as
declare
	@charge1			money,
	@count1			integer,
	@charge2			money,
	@count2			integer
// 1.ȡ����صĽ��˵���
create table #billno0
(
	billno			char(10)			not null,
)
// ����
if @roomno = '' and @accnt = ''
	begin
	insert #billno0 select distinct b.billno from accnt_set a, account b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt = b.accnt and b.billno like '[B,T]%'
	union select distinct b.billno from accnt_set a, haccount b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt = b.accnt and b.billno like '[B,T]%'
	end
// ָ������
else if @accnt = ''
	begin
	insert #billno0 select distinct b.billno from accnt_set a, account b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0 and a.accnt = b.accnt and b.billno like '[B,T]%'
	union select distinct b.billno from accnt_set a, haccount b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0 and a.accnt = b.accnt and b.billno like '[B,T]%'
	end
// ָ��������˺�
else
	begin
	insert #billno0 select distinct billno from account
		where accnt = @accnt and billno like '[B,T]%'
	union select distinct billno from haccount
		where accnt = @accnt and billno like '[B,T]%'
	end
// 2.ȡ�����˵��������Ϣ
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
// 3.����'����ѡ����'
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
	insert #billno1 values ('����ѡ����', '����ѡ����', @charge1 + @charge2, getdate())
else if @count1 + @count2 > 0
	insert #billno1 values ('����ѡ����', 'Selected Details', @charge1 + @charge2, getdate())
// ����'����δ����'
if @operation = 'uncheckout'
	begin
	select @charge1 = 0, @count1 = 0
	select @charge1 = sum(a.charge), @count1 = count(1)
		from account a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.billno = ''
	if @count1 > 0 and @langid = 0
		insert #billno1 values ('����δ����', '����δ����', @charge1 + @charge2, getdate())
	else if @count1 > 0
		insert #billno1 values ('����δ����', 'Valid Details', @charge1 + @charge2, getdate())
	//
	end
if @operation = 'cancelcheckout'
	delete #billno1 where not billno like 'B%'
select billno, descript, amount, log_date from #billno1 order by billno desc
return;
