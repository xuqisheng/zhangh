if exists(select * from sysobjects where name = "p_gl_accnt_haccount_list4")
	drop proc p_gl_accnt_haccount_list4;

create proc p_gl_accnt_haccount_list4
	@pc_id			char(4),						// IP��ַ
	@mdi_id			integer,						// Ψһ�����񴰿�ID
	@roomno			char(5),						// ����
	@accnt			char(10),					// �˺�
	@subaccnt		integer						// ���˺�(���@roomno = '99999', @subaccnt������ʱ�˼еı��)
as
declare
	@selected		integer

delete account_temp where pc_id = @pc_id and mdi_id = @mdi_id
insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
	select @pc_id, @mdi_id, a.accnt, a.number, a.mode1, a.billno, 1 from account a, billno_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and b.billno = a.billno
	union select @pc_id, @mdi_id, a.accnt, a.number, a.mode1, a.billno, 1 from haccount a, billno_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and b.billno = a.billno
if exists (select 1 from billno_temp where pc_id = @pc_id and mdi_id = @mdi_id and billno = '����δ����' and selected = 1)
	begin
	// ��������
	if @roomno = '' and @accnt != ''
		begin
		if @subaccnt = 0
			insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
				select @pc_id, @mdi_id, accnt, number, mode1, billno, 1 from account
				where accnt = @accnt and billno = ''
		else
			insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
				select @pc_id, @mdi_id, accnt, number, mode1, billno, 1 from account
				where accnt = @accnt and subaccnt = @subaccnt and billno = ''
		end
	// ����
	else if @roomno = ''
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
			select @pc_id, @mdi_id, a.accnt, a.number, mode1, billno, 1 from account a, accnt_set b
			where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.subaccnt = @subaccnt and a.accnt = b.accnt and a.billno = ''
	// ��ʱ�˼�
	else if @roomno = '99999'
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
			select @pc_id, @mdi_id, a.accnt, a.number, mode1, billno, 1 from account a, account_folder b
			where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.folder = @subaccnt and a.accnt = b.accnt and a.number = b.number and a.billno = ''
	// ָ������
	else if @accnt = ''
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
			select @pc_id, @mdi_id, a.accnt, a.number, mode1, billno, 1 from account a, accnt_set b
			where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.roomno = @roomno and b.subaccnt = 0 and b.accnt = a.accnt and a.billno = ''
	// ָ���˺�
	else if @subaccnt = 0
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
			select @pc_id, @mdi_id, accnt, number, mode1, billno, 1 from account
			where accnt = @accnt and billno = ''
	// ָ���˼�
	else
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
			select @pc_id, @mdi_id, accnt, number, mode1, billno, 1 from account
			where accnt = @accnt and subaccnt = @subaccnt and billno = ''
	// ɾ���ѱ�ѡ����ʱ�˼е���ϸ����
	if @roomno != '99999'
		delete account_temp from account_folder a where account_temp.pc_id = a.pc_id and account_temp.mdi_id = a.mdi_id
			and account_temp.accnt = a.accnt and account_temp.number = a.number and a.pc_id = @pc_id and a.mdi_id = @mdi_id
	end
select 0, ''
return
;
