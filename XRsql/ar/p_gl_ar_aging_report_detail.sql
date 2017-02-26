------------------------------------------------------------------
--	������ϸ��(���������Ƶ�)
------------------------------------------------------------------
IF OBJECT_ID('dbo.p_gl_ar_aging_report_detail') IS NOT NULL
    DROP PROCEDURE dbo.p_gl_ar_aging_report_detail
;
create proc p_gl_ar_aging_report_detail
	@pc_id			char(4), 
	@dates			varchar(255), 
	@option			char(10), 
	@deptno			char(4) = 'ALL', 
	@artag			varchar(20) = 'ALL', 
	@deposit			char(1) = 'T'   -- �Ƿ��������
as

declare
	@count			integer, 
	@lastdate		datetime, 
	@date				datetime, 
	@empname			char(10), 
	@bno				varchar(10), 
	@bno1				varchar(10), 
	@bno2				varchar(10), 
	@pccode			char(5), 
	@total_pccode	char(5), 
	@mode				char(1),				-- d=detail  s=sumamry
	@arrepo			char(1)				-- ����ͳ�Ʒ�ʽ

delete arrepo where pc_id = @pc_id

-- Mode
if @option = 'summary'
	select @mode = 's', @option = 'A'
else
	select @mode = 'd'

-- Deposit
if rtrim(@deposit) is null 
	select @deposit = 'T'
if @deposit <> 'F' 
	select @deposit = 'T'

-- �Ƿ��������ͨ�� pccode �Ĵ�С���ж�
if @deposit = 'T'
	select @pccode = 'ZZZZZ'				-- ��������
else
	select @pccode = '9'						-- ����������

-- Record
if charindex('S', @option) > 0
	begin
	insert arrepo (pc_id, catalog, accnt, descript, name)
		select @pc_id, 'T/G', a.accnt, '', b.name
		from ar_master a, guest b where a.sta = 'S' and a.class != 'A' and a.haccnt = b.no
		union select @pc_id, 'T/G', a.accnt, '', b.name
		from har_master a, guest b where a.sta = 'S' and a.class != 'A' and a.haccnt = b.no
	end

if charindex('A', @option) > 0
	begin
	insert arrepo (pc_id, catalog, accnt, descript, name)
		select @pc_id, 'AR', a.accnt, '', b.name
		from ar_master a, guest b where a.class = 'A' and a.haccnt = b.no and (@artag='ALL' or charindex(rtrim(a.artag1), @artag) > 0)
		union select @pc_id, 'AR', a.accnt, '', b.name
		from har_master a, guest b where a.class = 'A' and a.haccnt = b.no and (@artag='ALL' or charindex(rtrim(a.artag1), @artag) > 0)
	end

-- ��ֹ���� = @dates �ĵ�һ������
select @count = 0, @lastdate = convert(datetime, substring(@dates, 1, 10))
--if exists (select 1 from ar_detail a, arrepo b where b.pc_id = @pc_id and a.accnt = b.accnt and a.bdate < @lastdate and a.audit = '0')
--	begin
--	select 1, '����' + substring(@dates, 1, 10) + 'ǰ����Ŀû�����'
--	return 0
--	end
-- ȥ����һ�����ڣ�=��ֹ���ڣ����������һ��������Զ�����ڣ��������㡮��Զ��
select @dates = ltrim(stuff(@dates, 1, 10, '')) + '1980/01/01'

-- 
select @bno = convert(char(10), @lastdate, 111)
select @bno = substring(@bno, 4, 1) + substring(@bno, 6, 2) + substring(@bno, 9, 2)
select @bno1 = 'B' + @bno, @bno2 = 'T' + @bno

create table #ar_detail
(
	accnt				char(10)		not null,
	number			integer		not null,
	bdate				datetime		not null,
	charge			money			default 0 not null,
	credit			money			default 0 not null,
)
create table #ar_account (
	accnt				char(10)		null, 
	number			integer		not null,
	charge			money			null, 
	charge9			money			null, 
	credit			money			null, 
	credit9			money			null, 
	pccode			char(5)		null, 
	bdate				datetime		null,
	tag				char(1)		null,				-- �������:A.����,P.ǰ̨ת��,p.ǰ̨ת��ķ�����ϸ,T.��̨ת��,t.��̨ת�ʵķ�����ϸ,Z.ѹ����Ŀ,z.ѹ����Ŀ�ķ�����ϸ
	subtotal			char(1)		null				-- ��ǰ���Ƿ�����ϸ����:F.û��,T.��
)
select @arrepo = rtrim(value) from sysoption where catalog = 'ar' and item = 'ar_report'
select @total_pccode = rtrim(value) from sysoption where catalog = 'ar' and item = 'ar_account_pccode'
if @arrepo = 'N'
	begin
		-- new summary methold
		-- 1.δ����(������ѹ����)
		insert #ar_account select a.ar_accnt, a.ar_inumber, a.charge - a.charge9, a.charge9, a.credit - a.credit9, a.credit9, a.pccode, c.date, a.ar_tag, a.ar_subtotal
			from ar_account a, arrepo b,ar_detail c
			where b.pc_id = @pc_id and a.ar_accnt = b.accnt and c.date < @lastdate and a.ar_accnt = c.accnt and a.ar_inumber = c.number
		-- 2.��ֹ����֮��������Ŀ
		insert #ar_account select a.ar_accnt, a.ar_inumber, c.amount, 0, 0, 0, a.pccode, d.date, a.tag, a.ar_subtotal
			from ar_account a, arrepo b, ar_apply c,ar_detail d
			where b.pc_id = @pc_id and a.ar_accnt = b.accnt and d.date < @lastdate and (a.ar_accnt = c.d_accnt and a.ar_number = c.d_inumber and c.bdate >= @lastdate)
				and a.ar_accnt = d.accnt and a.ar_inumber = d.number
		insert #ar_account select a.ar_accnt, a.ar_inumber, c.amount, 0, 0, 0, a.pccode, a.date, a.tag, a.ar_subtotal
			from har_account a, arrepo b, ar_apply c,har_detail d
			where b.pc_id = @pc_id and a.ar_accnt = b.accnt and d.date < @lastdate and (a.ar_accnt = c.d_accnt and a.ar_number = c.d_inumber and c.bdate >= @lastdate)
				and a.ar_accnt = d.accnt and a.ar_inumber = d.number
		
		insert #ar_account select a.ar_accnt, a.ar_inumber, 0, 0, c.amount, 0, a.pccode, a.date, a.tag, a.ar_subtotal
			from ar_account a, arrepo b, ar_apply c,ar_detail d
			where b.pc_id = @pc_id and a.ar_accnt = b.accnt and d.date < @lastdate and (a.ar_accnt = c.c_accnt and a.ar_number = c.c_inumber and c.bdate >= @lastdate)
				and a.ar_accnt = d.accnt and a.ar_inumber = d.number
		
		insert #ar_account select a.ar_accnt, a.ar_inumber, 0, 0, c.amount, 0, a.pccode, a.date, a.tag, a.ar_subtotal
			from har_account a, arrepo b, ar_apply c,har_detail d
			where b.pc_id = @pc_id and a.ar_accnt = b.accnt and d.date < @lastdate and (a.ar_accnt = c.c_accnt and a.ar_number = c.c_inumber and c.bdate >= @lastdate)
				and a.ar_accnt = d.accnt and a.ar_inumber = d.number
	end
else
	begin
	-- 1.δ����(������ѹ����)
	insert #ar_account select a.ar_accnt, a.ar_inumber, a.charge - a.charge9, a.charge9, a.credit - a.credit9, a.credit9, a.pccode, a.bdate, a.ar_tag, a.ar_subtotal
		from ar_account a, arrepo b
		where b.pc_id = @pc_id and a.ar_accnt = b.accnt and a.bdate < @lastdate
	-- 2.��ֹ����֮��������Ŀ
	insert #ar_account select a.ar_accnt, a.ar_inumber, c.amount, 0, 0, 0, a.pccode, a.bdate, a.tag, a.ar_subtotal
		from ar_account a, arrepo b, ar_apply c
		where b.pc_id = @pc_id and a.ar_accnt = b.accnt and a.bdate < @lastdate and (a.ar_accnt = c.d_accnt and a.ar_number = c.d_inumber and c.bdate >= @lastdate)
	insert #ar_account select a.ar_accnt, a.ar_inumber, c.amount, 0, 0, 0, a.pccode, a.bdate, a.tag, a.ar_subtotal
		from har_account a, arrepo b, ar_apply c
		where b.pc_id = @pc_id and a.ar_accnt = b.accnt and a.bdate < @lastdate and (a.ar_accnt = c.d_accnt and a.ar_number = c.d_inumber and c.bdate >= @lastdate)
	insert #ar_account select a.ar_accnt, a.ar_inumber, 0, 0, c.amount, 0, a.pccode, a.bdate, a.tag, a.ar_subtotal
		from ar_account a, arrepo b, ar_apply c
		where b.pc_id = @pc_id and a.ar_accnt = b.accnt and a.bdate < @lastdate and (a.ar_accnt = c.c_accnt and a.ar_number = c.c_inumber and c.bdate >= @lastdate)
	insert #ar_account select a.ar_accnt, a.ar_inumber, 0, 0, c.amount, 0, a.pccode, a.bdate, a.tag, a.ar_subtotal
		from har_account a, arrepo b, ar_apply c
		where b.pc_id = @pc_id and a.ar_accnt = b.accnt and a.bdate < @lastdate and (a.ar_accnt = c.c_accnt and a.ar_number = c.c_inumber and c.bdate >= @lastdate)
	end
--
delete #ar_account where subtotal = 'T'
-- update #ar_account set pccode = (select min(pccode) from pccode where deptno2 = 'TOR') where pccode = ''
update #ar_account set pccode = @total_pccode where not pccode in (select pccode from pccode where pccode < @pccode)
create index index1 on #ar_account(accnt, pccode, bdate)
-- ׼��#ar_detail
insert #ar_detail (accnt, number, bdate, charge, credit)
	select accnt, number, bdate, sum(charge), sum(credit)
	from #ar_account group by accnt, number, bdate
-- begin 
while char_length(@dates) > 0
	begin
	select @count = @count + 1, @date = convert(datetime, substring(@dates, 1, 10)), @dates = substring(@dates, 11, 255)
	if @count = 1
		insert arrepo (pc_id, catalog, accnt, bdate, descript, amount1, amount)
			select @pc_id, 'AR', accnt, bdate, right(space(10) + convert(char(10), number), 10), charge - credit, charge - credit
			from #ar_detail where bdate >= @date and bdate < @lastdate
	else if @count = 2
		insert arrepo (pc_id, catalog, accnt, bdate, descript, amount2, amount)
			select @pc_id, 'AR', accnt, bdate, right(space(10) + convert(char(10), number), 10), charge - credit, charge - credit
			from #ar_detail where bdate >= @date and bdate < @lastdate
	else if @count = 3
		insert arrepo (pc_id, catalog, accnt, bdate, descript, amount3, amount)
			select @pc_id, 'AR', accnt, bdate, right(space(10) + convert(char(10), number), 10), charge - credit, charge - credit
			from #ar_detail where bdate >= @date and bdate < @lastdate
	else if @count = 4
		insert arrepo (pc_id, catalog, accnt, bdate, descript, amount4, amount)
			select @pc_id, 'AR', accnt, bdate, right(space(10) + convert(char(10), number), 10), charge - credit, charge - credit
			from #ar_detail where bdate >= @date and bdate < @lastdate
	else if @count = 5
		insert arrepo (pc_id, catalog, accnt, bdate, descript, amount5, amount)
			select @pc_id, 'AR', accnt, bdate, right(space(10) + convert(char(10), number), 10), charge - credit, charge - credit
			from #ar_detail where bdate >= @date and bdate < @lastdate
	else if @count = 6
		insert arrepo (pc_id, catalog, accnt, bdate, descript, amount6, amount)
			select @pc_id, 'AR', accnt, bdate, right(space(10) + convert(char(10), number), 10), charge - credit, charge - credit
			from #ar_detail where bdate >= @date and bdate < @lastdate
	else if @count = 7
		insert arrepo (pc_id, catalog, accnt, bdate, descript, amount7, amount)
			select @pc_id, 'AR', accnt, bdate, right(space(10) + convert(char(10), number), 10), charge - credit, charge - credit
			from #ar_detail where bdate >= @date and bdate < @lastdate
	else if @count = 8
		insert arrepo (pc_id, catalog, accnt, bdate, descript, amount8, amount)
			select @pc_id, 'AR', accnt, bdate, right(space(10) + convert(char(10), number), 10), charge - credit, charge - credit
			from #ar_detail where bdate >= @date and bdate < @lastdate
	else if @count = 9
		insert arrepo (pc_id, catalog, accnt, bdate, descript, amount9, amount)
			select @pc_id, 'AR', accnt, bdate, right(space(10) + convert(char(10), number), 10), charge - credit, charge - credit
			from #ar_detail where bdate >= @date and bdate < @lastdate
	else
		insert arrepo (pc_id, catalog, accnt, bdate, descript, amount10, amount)
			select @pc_id, 'AR', accnt, bdate, right(space(10) + convert(char(10), number), 10), charge - credit, charge - credit
			from #ar_detail where bdate >= @date and bdate < @lastdate

	select @lastdate = @date
	end
-- ��������
delete arrepo where amount1 = 0 and amount2 =0 and amount3 = 0 and amount4 = 0 and amount5 =0 and amount6 = 0 and
	amount7 = 0 and amount8 = 0 and amount9 = 0 and amount10 = 0 and pc_id = @pc_id
update arrepo set name = b.name from ar_master a, guest b
	where arrepo.pc_id = @pc_id and arrepo.accnt = a.accnt and a.haccnt = b.no
update arrepo set name = b.name from har_master a, guest b
	where arrepo.pc_id = @pc_id and arrepo.accnt = a.accnt and a.haccnt = b.no
update arrepo set guestname = a.guestname, roomno = a.roomno from ar_detail a
	where arrepo.pc_id = @pc_id and arrepo.accnt = a.accnt and convert(integer, arrepo.descript) = a.number
update arrepo set guestname = a.guestname, roomno = a.roomno from ar_detail a
	where arrepo.pc_id = @pc_id and arrepo.accnt = a.accnt and convert(integer, arrepo.descript) = a.number
//
//-- �������ܼ�¼
//if @mode = 's'
//	begin
//	select * into #arrepo from arrepo where 1=2
//	insert #arrepo select * from arrepo where pc_id = @pc_id
//	delete arrepo where pc_id = @pc_id
//	insert arrepo (pc_id, catalog, accnt, name, amount1, amount2, amount3, amount4, amount5, amount6, amount7, amount8, amount9, amount10, amount)
//		select @pc_id, 'AR', a.code, a.descript, sum(c.amount1), sum(c.amount2), sum(c.amount3), sum(c.amount4), sum(c.amount5), 
//		sum(c.amount6), sum(c.amount7), sum(c.amount8), sum(c.amount9), sum(c.amount10), sum(c.amount)	
//		from basecode a, ar_master b , #arrepo c
//		where a.code = b.artag1 and b.accnt = c.accnt and a.cat = 'artag1' and c.pc_id = @pc_id
//		group by a.code, a.descript
//	end
//
select 0, ''
return 0
;
