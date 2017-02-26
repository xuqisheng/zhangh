if exists(select * from sysobjects where name = "p_gl_haccnt_billno")
	drop proc p_gl_haccnt_billno;

create proc p_gl_haccnt_billno
	@pc_id			char(4),						// IP��ַ
	@mdi_id			integer,						// Ψһ�����񴰿�ID
	@roomno			char(5),						// ����
	@accnt			char(10),					// �˺�
	@subaccnt		integer,						// ���˺�(���@roomno = '99999', @subaccnt������ʱ�˼еı��)
	@operation		char(10)
as
declare
	@charge			money,
	@count			integer
// 1.ȡ����صĽ��˵���
create table #billno0
(
	billno			char(10)			not null,
)
// ����
if @roomno = '' and @accnt = ''
	insert #billno0 select distinct b.billno from accnt_set a, haccount b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt = b.accnt and b.billno like '[B,T]%'
// ָ������
else if @accnt = ''
	insert #billno0 select distinct b.billno from accnt_set a, haccount b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0 and a.accnt = b.accnt and b.billno like '[B,T]%'
// ָ��������˺�
else
	insert #billno0 select distinct billno from haccount
		where accnt = @accnt and billno like '[B,T]%'
// 2.ȡ�����˵��������Ϣ
create table #billno1
(
	billno			char(10)			not null,
	amount			money				null,
	log_date			datetime			null
)
insert #billno1 select b.billno, sum(b.charge), max(b.log_date)
	from #billno0 a, haccount b where a.billno = b.billno group by b.billno
update #billno1 set log_date = a.date1 from billno a where #billno1.billno = a.billno
// 3.����'����ѡ����'
select @charge = sum(a.charge * b.selected), @count = sum(b.selected)
	from haccount a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
if @count > 0
	insert #billno1 values ('����ѡ����', @charge, getdate())
// ����'����δ����'��ʵ������Ч
if @operation = 'uncheckout'
	begin
	select @charge = sum(a.charge), @count = count(1)
		from haccount a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.billno = ''
	if @count > 0
		insert #billno1 values ('����δ����', @charge, getdate())
	end
//
select billno, amount, log_date from #billno1 order by billno desc
return
;
