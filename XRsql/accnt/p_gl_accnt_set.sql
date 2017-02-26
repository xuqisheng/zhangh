if exists(select * from sysobjects where name = "p_gl_accnt_set")
	drop proc p_gl_accnt_set;

create proc p_gl_accnt_set
	@pc_id				char(4),
	@mdi_id				integer,
	@langid				integer = 0
as
declare
	@class				char(1),
	@accnt				char(10),
	@groupno				char(10),
	@saccnt				char(10),
	@master				char(10),
	@pcrec				char(10),
	--
	@ccharge				money,
	@ccredit				money,
	@croomno				char(10),
	@cname				varchar(50),
	@csta					char(1),
	@charge				money,
	@credit				money,
	@roomno				char(10),
	@names				varchar(50),
	@stas					varchar(50),
	@allcharge			money,
	@allcredit			money,
	@allstas				varchar(50),
	@descript			char(50),
	@count				integer,
	--
	@descript1			char(50),
	@descript2			char(50),
	@descript3			char(50),
	@descript4			char(50),
	@descript5			char(50),
	@descript6			char(50),
	@descript7			char(50)

select @count = count(1) from selected_account where type = '2' and pc_id = @pc_id and mdi_id = @mdi_id
if @count = 0
	begin
	select 1, '�˻�������'
	return
	end
--
if @langid = 0
	select @descript1 = '������������', @descript2 = '������ص�λ�˻�', @descript3 = '������������',
		@descript4 = 'ͬ�п�������', @descript5 = '����ѡ�п�������', @descript6 = '�����˻�����', @descript7 = '��������'
else
	select @descript1 = "Group's bills", @descript2 = "House account's bills", @descript3 = "Group's bills",
		@descript4 = "Guest's bills of the party", @descript5 = "Selected guest's bills", @descript6 = "Part guest's bills", @descript7 = 'Bills'
--
create table #accnt
(
	roomno			char(5)			not null,					-- ���� 
	accnt				char(10)			not null,					-- �˺� 
	subaccnt			integer			not null,					-- ���˺� 
	haccnt			char(7)			not null,					-- ��ʷ������ 
	name				char(50)			not null,					-- ���� 
	sta				char(50)			not null,					-- �˻�״̬ 
	charge			money				not null,					-- ���� 
	credit			money				not null,					-- Ԥ�� 
	tree_level		integer			default 0 not null,		-- ״̬ 
	tree_children	char(1)			not null,					-- 
	tree_picture	char(1)			not null,					-- ͼ����� 
	tag				char(1)			not null,					-- ��ʾ״̬ 
	csta				integer			default 0 not null		-- ��ʱʹ�� 
)
delete accnt_set where pc_id = @pc_id and mdi_id = @mdi_id
if @count = 1 and @mdi_id > 0
	-- ֻ������һ���˺ţ� �����Զ���ͬ���������������������
	begin
--	select @class = b.class, @accnt = b.accnt, @groupno = b.groupno, @master = isnull(rtrim(b.master), '#'), @pcrec = isnull(rtrim(b.pcrec), '#')
	select @class = b.class, @accnt = b.accnt, @groupno = b.groupno, @saccnt = isnull(rtrim(b.saccnt), '#'), @master = isnull(rtrim(b.master), '#'), @pcrec = isnull(rtrim(b.pcrec), '#')
		from selected_account a, master b
		where a.type = '2' and a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.accnt = b.accnt
	if @class in ('G', 'M')
		begin
		-- 1.�����Ա�˺�
--		insert #accnt select isnull(rtrim(a.roomno), '#' + right(rtrim(a.master), 4)), a.accnt, 0, a.haccnt, b.name, a.sta, a.charge, a.credit, 2, '1', '2', '',
		insert #accnt select isnull(rtrim(a.roomno), '#' + right(rtrim(a.saccnt), 4)), a.accnt, 0, a.haccnt, b.name, a.sta, a.charge, a.credit, 2, '1', '2', '',
			(select count(1) from subaccnt c where c.type = '5' and c.accnt = a.accnt)
			from master a, guest b where a.groupno = @accnt and a.haccnt = b.no
		-- 2.���������˺�
		insert #accnt select a.roomno, a.accnt, 0, a.haccnt, b.name, a.sta, a.charge, a.credit, 1, '1', '2', '',
			(select count(1) from subaccnt c where c.type = '5' and c.accnt = a.accnt)
			from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
		select @descript = @descript1
		end
	else if @class in ('A', 'C')
		-- ����������ˡ�Ӧ����
		begin
		insert #accnt select a.roomno, a.accnt, 0, a.haccnt, b.name, a.sta, a.charge, a.credit, 1, '1', '2', '', 
			(select count(1) from subaccnt c where c.type = '5' and c.accnt = a.accnt)
			from master a, guest b where (accnt = @accnt or a.saccnt = @saccnt or a.master = @master or a.pcrec = @pcrec) and a.haccnt = b.no
--			from master a, guest b where (accnt = @accnt or a.master = @master or a.pcrec = @pcrec) and a.haccnt = b.no
		select @descript = @descript2
		end
	else if @groupno != ''
		-- ����������Ա��򿪸���������г�Ա
		begin
		-- 1.�����Ա�˺�
--		insert #accnt select isnull(rtrim(a.roomno), '#' + right(rtrim(a.master), 4)),
		insert #accnt select isnull(rtrim(a.roomno), '#' + right(rtrim(a.saccnt), 4)),
			a.accnt, 0, a.haccnt, b.name, a.sta, a.charge, a.credit, 2, '1', '2', '', 
			(select count(1) from subaccnt c where c.type = '5' and c.accnt = a.accnt)
			from master a, guest b where a.groupno = @groupno and a.haccnt = b.no
		-- 2.���������˺�
		insert #accnt select a.roomno, a.accnt, 0, a.haccnt, b.name, a.sta, a.charge, a.credit, 1, '1', '2', '',
			(select count(1) from subaccnt c where c.type = '5' and c.accnt = a.accnt)
			from master a, guest b where a.accnt = @groupno and a.haccnt = b.no
		select @descript = @descript3
		end
	else
		-- �����ɢ����򿪸ÿ��˵�������������
		begin
--		insert #accnt select isnull(rtrim(a.roomno), '#' + right(rtrim(a.master), 4)),
		insert #accnt select isnull(rtrim(a.roomno), '#' + right(rtrim(a.saccnt), 4)),
			a.accnt, 0, a.haccnt, b.name, a.sta, a.charge, a.credit, 2, '1', '2', '', 
			(select count(1) from subaccnt c where c.type = '5' and c.accnt = a.accnt)
			from master a, guest b where (accnt = @accnt or a.saccnt = @saccnt or a.master = @master or a.pcrec = @pcrec) and a.haccnt = b.no
--			from master a, guest b where (accnt = @accnt or a.master = @master or a.pcrec = @pcrec) and a.haccnt = b.no
		select @descript = @descript4
		end
	end
else
	-- ����������˺ţ� ��ֻ��ָ����������
	begin
	insert #accnt select a.roomno, a.accnt, 0, a.haccnt, b.name, a.sta, a.charge, a.credit, 2, '1', '2', '', 
		(select count(1) from subaccnt d where d.type = '5' and d.accnt = a.accnt)
		from master a, guest b, selected_account c
		where c.pc_id = @pc_id and c.mdi_id = @mdi_id and c.accnt = a.accnt and a.haccnt = b.no
	if @mdi_id >= 0
		select @descript = @descript5
	else
		select @descript = @descript6
	update #accnt set tree_level = tree_level - 1 where roomno = ''
	end
select @allcharge = sum(charge), @allcredit = sum(credit) from #accnt
-- 2.���뷿��
update #accnt set name = '[' + rtrim(accnt) + ']' + name where roomno = ''
select @count = 0, @charge = 0, @credit = 0, @names = '', @allstas = ''
declare c_accnt cursor for select roomno, name, sta, charge, credit from #accnt where accnt != '' order by roomno
open c_accnt
fetch c_accnt into @croomno, @cname, @csta, @ccharge, @ccredit
while @@sqlstatus = 0 
	begin
	if @croomno != @roomno or @roomno = ''
		begin
		if @count = 1 and @roomno != ''
			update #accnt set name = '[' + rtrim(roomno) + ']' + name, tree_level = 1 where roomno = @roomno
		else if @count > 1 and @roomno != ''
			insert #accnt select @roomno, '', 0, '', '[' + rtrim(@roomno) + ']' + @descript7, @stas, @charge, @credit, 1,'1', '1', '', @count
		else if @count > 1
			insert #accnt select @roomno, '', 0, '', @names, @stas, @charge, @credit, 1, '1', '1', '', @count
		select @count = 0, @roomno = @croomno, @names = @cname, @stas = @csta, @charge = 0, @credit = 0
		end
	select @count = @count + 1, @names = @names + rtrim(';' + @cname), @charge = @charge + @ccharge, @credit = @credit + @ccredit
	if charindex(@csta, @stas) = 0
		select @stas = @csta + @stas
	if charindex(@csta, @allstas) = 0
		select @allstas = @csta + @allstas
	fetch c_accnt into @croomno, @cname, @csta, @ccharge, @ccredit
	end
if @count = 1 and @roomno != ''
	update #accnt set name = '[' + isnull(rtrim(roomno), rtrim(accnt)) + ']' + name, tree_level = 1 where roomno = @roomno
else if @count > 1 and @roomno != ''
	insert #accnt select @roomno, '', 0, '', '[' + rtrim(@roomno) + ']' + @descript7, @stas, @charge, @credit, 1, '1', '1', '', @count
else if @count > 1 
	insert #accnt select @roomno, '', 0, '', @names, @stas, @charge, @credit, 1, '1', '1', '', @count
close c_accnt
deallocate cursor c_accnt
-- 3.�������˺�
insert #accnt select b.roomno, b.accnt, a.subaccnt, b.haccnt, a.name, b.sta, 0, 0, b.tree_level + 1, '0', '3', '', 0
	from subaccnt a, #accnt b
	where a.type = '5' and a.accnt = b.accnt and b.csta > 1
-- 4.����Root
select @count = count(1) from #accnt where tree_level = 1
if @count > 1
	insert #accnt select '', '', 0, '', @descript, @allstas, isnull(@allcharge, 0), isnull(@allcredit, 0), 0, '1', '0', '', 9
else
	update #accnt set tree_level = tree_level - 1
--
update #accnt set tree_children = '0' where csta < 2
update #accnt set sta = 'I' where charindex('I', sta) > 0
update #accnt set sta = 'R' where charindex('R', sta) > 0
update #accnt set sta = 'S' where charindex('S', sta) > 0
update #accnt set sta = 'O' where charindex('O', sta) > 0
update #accnt set sta = substring(sta, 1, 1) where char_length(rtrim(sta)) > 1
update #accnt set csta = a.sequence from basecode a where #accnt.sta = a.code and a.cat = 'mststa'
update #accnt set csta = isnull((select a.csta from #accnt a where a.roomno = #accnt.roomno and a.accnt = ''), csta) where roomno != ''
update #accnt set roomno=' '+substring(a.roomno,1,4) from rmsta a where #accnt.roomno=a.roomno and a.type='PM' 
insert accnt_set select @pc_id, @mdi_id, * from #accnt
select 0, ''
return
;
