
if exists(select 1 from sysobjects where name = 'p_cyj_pos_checkout_check' and type ='P')
	drop  proc p_cyj_pos_checkout_check;
create proc p_cyj_pos_checkout_check
	@pc_id			char(4),
	@menus			char(255),
	@accnt			char(10),
	@langid			integer = 0
as
--------------------------------------------------------------------------------------------
-- 餐饮结账检查信息
--------------------------------------------------------------------------------------------
declare
	@routing			char(10),
	@comsg			char(10),
	@message			char(10),
	@menumsg			char(10),
	@location		char(10),
	@remark			char(10),
	@rental			char(10),
	@accedits		char(10)    

create table #message
(
	accnt				char(10)				default '' not null,
	roomno			char(5)				default '' not null,
	name				char(50)				default '' not null,
	msg_type			char(2)				default '' not null,
	msg_descript	char(10)				default '' not null,
	msg_content		char(255)			default '' not null
)
if @langid = 0
	select @remark ='备注',@menumsg='餐单联单', @routing = '分账', @comsg = '结账提示', @message = '留言', @location = '去向', @rental = '租赁', @accedits ='定金'
else
	select @remark ='remark',@menumsg='Menu Union', @routing = 'Routing', @comsg = 'C/O Msg', @message = 'Message', @location = 'Location', @rental = 'Rental', @accedits ='Accs'

									
if (select count(1) from pos_menu where charindex(menu, @menus)>0) > 1  -- 联单信息
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select menu, '00', @menumsg, '桌号:'+convert(char(6), tableno)+' 人数: '+convert(char(6),guest)+' 金额:'+convert(char(12), amount) from pos_menu where charindex(menu, @menus) >0
if (select count(1) from pos_menu where charindex(menu, @menus)>0 and rtrim(remark) is not null )  >= 1  -- 有备注
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select menu, '00', @remark, '桌号:'+convert(char(6), tableno) + '   ' + remark from pos_menu where charindex(menu, @menus) >0 and rtrim(remark) is not null
if @accnt <> ''										-- 转账结账
	begin
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, '00', @comsg, b.comsg from master b where b.accnt = @accnt 
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, '80', @message, convert(char(255), b.content) from message_leaveword b where b.accnt = @accnt 
		and b.sort = 'LWD' and b.tag < '2' and b.inure < getdate() and b.abate >= getdate()
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, '90', @location, convert(char(255), b.content) from message_leaveword b where b.accnt = @accnt 
		and b.sort = 'LOC' and b.tag < '2' and b.inure < getdate() and b.abate >= getdate()
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, 'A0', @rental, c.name from res_av b, res_plu c where  b.accnt = @accnt and b.sta in ('I', 'R') and b.resid = c.resid
	end

-- 定金信息
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.menu, 'B0', @accedits, a.remark+' '+paycode+'  金额:'+convert(char(14), a.amount) 
	from pos_pay a,pos_menu b  where charindex(b.menu, @menus) >0 and b.resno = a.menu and a.sta ='1' and rtrim(ltrim(a.menu0)) is null


update #message set roomno = a.roomno, name = b.name
	from master a, guest b where #message.accnt = a.accnt and a.haccnt = b.no
-- 返回结果
select accnt, roomno, name, msg_type, msg_descript, msg_content
	from #message where msg_content != '' order by roomno, msg_type
return;
