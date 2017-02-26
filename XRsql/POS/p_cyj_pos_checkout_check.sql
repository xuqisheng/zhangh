
if exists(select 1 from sysobjects where name = 'p_cyj_pos_checkout_check' and type ='P')
	drop  proc p_cyj_pos_checkout_check;
create proc p_cyj_pos_checkout_check
	@pc_id			char(4),
	@menus			char(255),
	@accnt			char(10),
	@langid			integer = 0
as
--------------------------------------------------------------------------------------------
-- �������˼����Ϣ
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
	select @remark ='��ע',@menumsg='�͵�����', @routing = '����', @comsg = '������ʾ', @message = '����', @location = 'ȥ��', @rental = '����', @accedits ='����'
else
	select @remark ='remark',@menumsg='Menu Union', @routing = 'Routing', @comsg = 'C/O Msg', @message = 'Message', @location = 'Location', @rental = 'Rental', @accedits ='Accs'

									
if (select count(1) from pos_menu where charindex(menu, @menus)>0) > 1  -- ������Ϣ
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select menu, '00', @menumsg, '����:'+convert(char(6), tableno)+' ����: '+convert(char(6),guest)+' ���:'+convert(char(12), amount) from pos_menu where charindex(menu, @menus) >0
if (select count(1) from pos_menu where charindex(menu, @menus)>0 and rtrim(remark) is not null )  >= 1  -- �б�ע
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select menu, '00', @remark, '����:'+convert(char(6), tableno) + '   ' + remark from pos_menu where charindex(menu, @menus) >0 and rtrim(remark) is not null
if @accnt <> ''										-- ת�˽���
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

-- ������Ϣ
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.menu, 'B0', @accedits, a.remark+' '+paycode+'  ���:'+convert(char(14), a.amount) 
	from pos_pay a,pos_menu b  where charindex(b.menu, @menus) >0 and b.resno = a.menu and a.sta ='1' and rtrim(ltrim(a.menu0)) is null


update #message set roomno = a.roomno, name = b.name
	from master a, guest b where #message.accnt = a.accnt and a.haccnt = b.no
-- ���ؽ��
select accnt, roomno, name, msg_type, msg_descript, msg_content
	from #message where msg_content != '' order by roomno, msg_type
return;
