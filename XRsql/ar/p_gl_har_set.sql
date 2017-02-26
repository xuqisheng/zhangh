if exists(select * from sysobjects where name = "p_gl_har_set")
	drop proc p_gl_har_set;

create proc p_gl_har_set
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
	select 1, '账户不存在'
	return
	end
//
if @langid = 0
	select @descript1 = '整个团体账务', @descript2 = '所有相关单位账户', @descript3 = '整个团体账务',
		@descript4 = '同行客人账务', @descript5 = '所有选中客人账务', @descript6 = '部分账户账务', @descript7 = '房间账务'
else
	select @descript1 = "Group's bills", @descript2 = "House account's bills", @descript3 = "Group's bills",
		@descript4 = "Guest's bills of the party", @descript5 = "Selected guest's bills", @descript6 = "Part guest's bills", @descript7 = 'Bills'
//
create table #accnt
(
	roomno			char(5)			not null,					/* 房号 */
	accnt				char(10)			not null,					/* 账号 */
	subaccnt			integer			not null,					/* 子账号 */
	haccnt			char(7)			not null,					/* 历史档案号 */
	name				char(50)			not null,					/* 描述 */
	sta				char(50)			not null,					/* 账户状态 */
	charge			money				not null,					/* 消费 */
	credit			money				not null,					/* 预付 */
	tree_level		integer			default 0 not null,		/* 状态 */
	tree_children	char(1)			not null,					/* */
	tree_picture	char(1)			not null,					/* 图标序号 */
	tag				char(1)			not null,					/* 显示状态 */
	csta				integer			default 0 not null		/* 临时使用 */
)
delete accnt_set where pc_id = @pc_id and mdi_id = @mdi_id
if @count = 1 and @mdi_id > 0
	// 只传进来一个账号， 程序自动打开联房客人账务
	begin
	select @class = b.class, @accnt = b.accnt, @master = isnull(rtrim(b.master), '#'), @pcrec = isnull(rtrim(b.pcrec), '#')
		from selected_account a, har_master b
		where a.type = '2' and a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.accnt = b.accnt
	insert #accnt select '', a.accnt, 0, a.haccnt, b.name, a.sta, a.charge, a.credit, 1, '1', '2', '', 
		(select count(1) from hsubaccnt c where c.type = '5' and c.accnt = a.accnt)
		from har_master a, guest b where (accnt = @accnt or a.master = @master or a.pcrec = @pcrec) and a.haccnt = b.no
	select @descript = @descript2
	end
else
	// 传进来多个账号， 则只打开指定客人账务
	begin
	insert #accnt select '', a.accnt, 0, a.haccnt, b.name, a.sta, a.charge, a.credit, 2, '1', '2', '', 
		(select count(1) from hsubaccnt d where d.type = '5' and d.accnt = a.accnt)
		from har_master a, guest b, selected_account c
		where c.pc_id = @pc_id and c.mdi_id = @mdi_id and c.accnt = a.accnt and a.haccnt = b.no
	if @mdi_id >= 0
		select @descript = @descript5
	else
		select @descript = @descript6
	update #accnt set tree_level = tree_level - 1 where roomno = ''
	end
select @allcharge = sum(charge), @allcredit = sum(credit) from #accnt
// 2.插入子账号
insert #accnt select b.roomno, b.accnt, a.subaccnt, b.haccnt, a.name, b.sta, 0, 0, b.tree_level + 1, '0', '3', '', 0
	from hsubaccnt a, #accnt b
	where a.type = '5' and a.accnt = b.accnt and b.csta > 1
// 3.插入Root
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
update #accnt set sta = substring(sta, 1, 1) where char_length(rtrim(sta)) > 1
update #accnt set csta = a.sequence from basecode a where #accnt.sta = a.code and a.cat = 'mststa'
update #accnt set csta = isnull((select a.csta from #accnt a where a.roomno = #accnt.roomno and a.accnt = ''), csta) where roomno != ''
insert accnt_set select @pc_id, @mdi_id, * from #accnt
select 0, ''
return;
