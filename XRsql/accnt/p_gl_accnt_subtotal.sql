if exists(select * from sysobjects where name = "p_gl_accnt_subtotal")
	drop proc p_gl_accnt_subtotal;

create proc p_gl_accnt_subtotal
	@pc_id				char(4),						// IP��ַ
	@mdi_id				integer,						// Ψһ�����񴰿�ID
	@roomno				char(5),						// ����
	@accnt				char(10),					// �˺�
	@subaccnt			integer,						// ���˺�(���@roomno = '99999', @subaccnt������ʱ�˼еı��)
	@operation			char(10) = 'pccode',
	@langid				integer = 0
as

create table #subtotal
(
	ref1					char(10)			not null,
	ref2					char(50)			null,
	amount				money				null,
	amount1				money				null,
	code					char(10)			not null
)
if @operation = 'pccode'
	begin
	insert #subtotal select a.pccode, a.ref, amount = sum(a.charge + a.credit), amount1 = sum(a.charge - a.credit), a.pccode
		from account a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
		group by a.pccode, a.ref
	insert #subtotal select a.pccode, a.ref, amount = sum(a.charge + a.credit), amount1 = sum(a.charge - a.credit), a.pccode
		from haccount a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
		group by a.pccode, a.ref
	if @langid != 0
		update #subtotal set ref2 = a.descript1 from pccode a where #subtotal.ref1 = a.pccode
	end
else
	begin
	insert #subtotal select '', '', amount = sum(a.charge - a.credit), amount1 = sum(a.charge - a.credit), isnull(rtrim(a.accntof), a.accnt)
		from account a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
		group by isnull(rtrim(a.accntof), a.accnt)
	insert #subtotal select '', '', amount = sum(a.charge - a.credit), amount1 = sum(a.charge - a.credit), isnull(rtrim(a.accntof), a.accnt)
		from haccount a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
		group by isnull(rtrim(a.accntof), a.accnt)
	update #subtotal set ref1 = isnull(rtrim(a.roomno), a.accnt), ref2 = b.name from master a, guest b
		where #subtotal.code = a.accnt and a.haccnt = b.no
	update #subtotal set ref1 = isnull(rtrim(a.roomno), a.accnt), ref2 = b.name from hmaster a, guest b
		where #subtotal.code = a.accnt and a.haccnt = b.no
	end
select ref1, ref2, sum(amount), sum(amount1), code, selected = 0
	from #subtotal group by ref1, ref2, code order by ref1
return
;
