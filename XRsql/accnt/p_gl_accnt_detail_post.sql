if exists(select * from sysobjects where name = 'p_gl_accnt_detail_post' and type = 'P')
	drop proc p_gl_accnt_detail_post;

create proc p_gl_accnt_detail_post
	@date						datetime,
	@empno					char(10),
	@shift					char(1),
	@langid					integer = 0,
	@option					char(10) = 'ALL'		-- FRONT:ǰ̨,AR:AR��,ALL:����
as

if rtrim(@empno) is null
	select @empno = '%'
if rtrim(@shift) is null
	select @shift = '%'
select * into #account from account where 1 = 2
if @option in ('FRONT', 'ALL')
	insert #account select * from account where bdate = @date and empno like @empno and shift like @shift
		union select * from haccount where bdate = @date and empno like @empno and shift like @shift
update #account set argcode = '98' where argcode = '99' and billno = ''
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
-- �������Ľ������������
update #account set number = 1
--
create table #detail
(
	dc1				char(1)		null,							-- �������
	dc2				char(10)		null,							-- ��������
	roomno			char(5)		null,							-- ����
	accnt				char(10)		null,							-- �ʺ�
	name				char(50)		null,							-- ��������
	pccode			char(5)		null,							-- ������
	ref				char(50)		null,							-- ��������
	amount			money			default 0	null, 
)
if @langid = 0
	insert #detail select dc1 = '0', dc2 = '����', a.roomno, a.accnt, name = 'С��' + space(50), a.pccode, b.descript, amount = a.charge
		from #account a, pccode b where a.pccode < '9' and a.pccode = b.pccode
		union all select dc1 = '1', dc2 = '����', a.roomno, a.accnt, name = 'С��' + space(50), a.pccode, b.descript, amount = a.credit
		from #account a, pccode b where a.argcode = '98' and a.pccode > '9' and a.pccode = b.pccode
		union all select dc1 = '2', dc2 = '���˲���', a.roomno, a.accnt, name = 'С��' + space(50), a.pccode, b.descript, amount = a.credit
		from #account a, pccode b where a.argcode = '99' and a.pccode > '9' and a.pccode = b.pccode
else
	insert #detail select dc1 = '0', dc2 = 'Department', a.roomno, a.accnt, name = 'Subtotal' + space(50), a.pccode, b.descript1, amount = a.charge
		from #account a, pccode b where a.pccode < '9' and a.pccode = b.pccode
		union all select dc1 = '1', dc2 = 'Deposit', a.roomno, a.accnt, name = 'Subtotal' + space(50), a.pccode, b.descript1, amount = a.credit
		from #account a, pccode b where a.argcode = '98' and a.pccode > '9' and a.pccode = b.pccode
		union all select dc1 = '2', dc2 = 'Pay', a.roomno, a.accnt, name = 'Subtotal' + space(50), a.pccode, b.descript1, amount = a.credit
		from #account a, pccode b where a.argcode = '99' and a.pccode > '9' and a.pccode = b.pccode
update #detail set name = b.name from master a, guest b where #detail.accnt = a.accnt and a.haccnt = b.no
update #detail set name = b.name from hmaster a, guest b where #detail.accnt = a.accnt and a.haccnt = b.no
update #detail set name = b.name from ar_master a, guest b where #detail.accnt = a.accnt and a.haccnt = b.no
update #detail set name = b.name from har_master a, guest b where #detail.accnt = a.accnt and a.haccnt = b.no
select * from #detail
;
