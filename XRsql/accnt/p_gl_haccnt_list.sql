if exists(select * from sysobjects where name = "p_gl_haccnt_list")
	drop proc p_gl_haccnt_list;

create proc p_gl_haccnt_list
	@pc_id			char(4),						// IP��ַ
	@mdi_id			integer,						// Ψһ�����񴰿�ID
	@roomno			char(5),						// ����
	@accnt			char(10),					// �˺�
	@subaccnt		integer,						// ���˺�(���@roomno = '99999', @subaccnt������ʱ�˼еı��)
	@operation		char(10)
as

delete account_temp where pc_id = @pc_id and mdi_id = @mdi_id
// ��������
if @roomno = '' and @accnt != ''
	begin
	if @subaccnt = 0
		insert account_temp 
			select @pc_id, @mdi_id, accnt, number, billno, 0 from haccount
			where accnt = @accnt
	else
		insert account_temp 
			select @pc_id, @mdi_id, accnt, number, billno, 0 from haccount
			where accnt = @accnt and subaccnt = @subaccnt
	end
// ����
else if @roomno = ''
	insert account_temp 
		select @pc_id, @mdi_id, a.accnt, a.number, billno, 0 from haccount a, accnt_set b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.subaccnt = @subaccnt and a.accnt = b.accnt
// ��ʱ�˼�
else if @roomno = '99999'
	insert account_temp 
		select @pc_id, @mdi_id, a.accnt, a.number, billno, 0 from haccount a, account_folder b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.folder = @subaccnt and a.accnt = b.accnt and a.number = b.number
// ָ������
else if @accnt = ''
	insert account_temp 
		select @pc_id, @mdi_id, a.accnt, a.number, billno, 0 from haccount a, accnt_set b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.roomno = @roomno and b.subaccnt = 0 and b.accnt = a.accnt
// ָ���˺�
else if @subaccnt = 0
	insert account_temp 
		select @pc_id, @mdi_id, accnt, number, billno, 0 from haccount
		where accnt = @accnt
// ָ���˼�
else
	insert account_temp 
		select @pc_id, @mdi_id, accnt, number, billno, 0 from haccount
		where accnt = @accnt and subaccnt = @subaccnt
// ɾ���ѱ�ѡ����ʱ�˼е���ϸ����
if @roomno != '99999'
	delete account_temp from account_folder a where account_temp.pc_id = a.pc_id and account_temp.mdi_id = a.mdi_id
		and account_temp.accnt = a.accnt and account_temp.number = a.number and a.pc_id = @pc_id and a.mdi_id = @mdi_id
if @operation = 'uncheckout'
	delete account_temp where billno != ''
	
// ���ؽ��
select a.accnt, a.subaccnt, a.number, a.pccode, a.argcode, a.empno, a.shift, a.log_date, a.ref, a.ref1, a.ref2,
		a.modu_id, amount = a.charge + a.credit, amount1 = a.charge - a.credit, a.quantity,
		crradjt, tran_accnt = a.tofrom + a.accntof, a.bdate, a.date, a.roomno, a.billno, selected = 0, tag = ''
 from haccount a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
 order by a.log_date
return
;
