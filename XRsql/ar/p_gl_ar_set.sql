if exists(select * from sysobjects where name = "p_gl_ar_set")
	drop proc p_gl_ar_set;

create proc p_gl_ar_set
	@pc_id				char(4),
	@mdi_id				integer,
	@langid				integer = 0
as
declare
	@class				char(1),
	@accnt				char(10),
	@master				char(10),
	@pcrec				char(10),
	//
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
	//
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
//
if @langid = 0
	select @descript1 = '������������', @descript2 = '������ص�λ�˻�', @descript3 = '������������',
		@descript4 = 'ͬ�п�������', @descript5 = '����ѡ�п�������', @descript6 = '�����˻�����', @descript7 = '��������'
else
	select @descript1 = "Group's bills", @descript2 = "House account's bills", @descript3 = "Group's bills",
		@descript4 = "Guest's bills of the party", @descript5 = "Selected guest's bills", @descript6 = "Part guest's bills", @descript7 = 'Bills'
//
create table #accnt
(
	roomno			char(5)			not null,					/* ���� */
	accnt				char(10)			not null,					/* �˺� */
	subaccnt			integer			not null,					/* ���˺� */
	haccnt			char(7)			not null,					/* ��ʷ������ */
	name				char(50)			not null,					/* ���� */
	sta				char(50)			not null,					/* �˻�״̬ */
	charge			money				not null,					/* ���� */
	credit			money				not null,					/* Ԥ�� */
	tree_level		integer			default 0 not null,		/* ״̬ */
	tree_children	char(1)			not null,					/* */
	tree_picture	char(1)			not null,					/* ͼ����� */
	tag				char(1)			not null,					/* ��ʾ״̬ */
	csta				integer			default 0 not null		/* ��ʱʹ�� */
)
delete accnt_set where pc_id = @pc_id and mdi_id = @mdi_id
if @count = 1 and @mdi_id > 0
	// ֻ������һ���˺ţ� �����Զ���������������
	begin
--	select @class = b.class, @accnt = b.accnt, @groupno = b.groupno, @master = isnull(rtrim(b.master), '#'), @pcrec = isnull(rtrim(b.pcrec), '#')
	select @class = b.class, @accnt = b.accnt, @master = isnull(rtrim(b.master), '#'), @pcrec = isnull(rtrim(b.pcrec), '#')
		from selected_account a, ar_master b
		where a.type = '2' and a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.accnt = b.accnt
	insert #accnt select '', a.accnt, 0, a.haccnt, b.name, a.sta, a.charge, a.credit, 1, '1', '2', '', 
		(select count(1) from subaccnt c where c.type = '5' and c.accnt = a.accnt)
		from ar_master a, guest b where (accnt = @accnt or a.master = @master or a.pcrec = @pcrec) and a.haccnt = b.no
--			from ar_master a, guest b where (accnt = @accnt or a.master = @master or a.pcrec = @pcrec) and a.haccnt = b.no
	select @descript = @descript2
	end
else
	// ����������˺ţ� ��ֻ��ָ����������
	begin
	insert #accnt select '', a.accnt, 0, a.haccnt, b.name, a.sta, a.charge, a.credit, 2, '1', '2', '', 
		(select count(1) from subaccnt d where d.type = '5' and d.accnt = a.accnt)
		from ar_master a, guest b, selected_account c
		where c.pc_id = @pc_id and c.mdi_id = @mdi_id and c.accnt = a.accnt and a.haccnt = b.no
	if @mdi_id >= 0
		select @descript = @descript5
	else
		select @descript = @descript6
	update #accnt set tree_level = tree_level - 1 where roomno = ''
	end
select @allcharge = sum(charge), @allcredit = sum(credit) from #accnt
// 2.�������˺�
insert #accnt select b.roomno, b.accnt, a.subaccnt, b.haccnt, a.name, b.sta, 0, 0, b.tree_level + 1, '0', '3', '', 0
	from subaccnt a, #accnt b
	where a.type = '5' and a.accnt = b.accnt and b.csta > 1
// 3.����Root
select @count = count(1) from #accnt where tree_level = 1
if @count > 1
	begin
	select @allstas = ''
	declare c_accnt cursor for select sta from #accnt where accnt != '' order by accnt
	open c_accnt
	fetch c_accnt into @csta
	while @@sqlstatus = 0 
		begin
		if charindex(@csta, @allstas) = 0
			select @allstas = @csta + @allstas
		fetch c_accnt into @csta
		end
	close c_accnt
	deallocate cursor c_accnt
	insert #accnt select '', '', 0, '', @descript, @allstas, isnull(@allcharge, 0), isnull(@allcredit, 0), 0, '1', '0', '', 9
	end
else
	update #accnt set tree_level = tree_level - 1
//
update #accnt set tree_children = '0' where csta < 2
update #accnt set sta = 'I' where charindex('I', sta) > 0
update #accnt set sta = 'R' where charindex('R', sta) > 0
update #accnt set sta = 'S' where charindex('S', sta) > 0
update #accnt set sta = 'O' where charindex('O', sta) > 0
update #accnt set sta = substring(sta, 1, 1) where char_length(rtrim(sta)) > 1
update #accnt set csta = a.sequence from basecode a where #accnt.sta = a.code and a.cat = 'mststa'
update #accnt set csta = isnull((select a.csta from #accnt a where a.roomno = #accnt.roomno and a.accnt = ''), csta) where roomno != ''
insert accnt_set select @pc_id, @mdi_id, * from #accnt
select 0, ''
return
;
