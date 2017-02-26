--------------------------------------------------------------------------------
-- GUEST:leaveword/location
--------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "message_leaveword")
	drop table message_leaveword
;
create table message_leaveword 
(
	id				   int   							    not null,
	sort				char(3)      default 'LWD'     not null,  -- ������� basecode.cat = 'MsgLeaveWordSort' 
	accnt          char(10)     default ''        not null,  -- ��صı����ʺ�
	sender			char(10)		 default '' 	    not null,  -- ������
	senddate			datetime     default getdate() not null,  -- ����ʱ�� 
	content			text			 default ''        not null,  -- �������� 
	inure				datetime     default getdate() not null,  -- ��Чʱ��
	abate 			datetime     default getdate() not null,  -- ʧЧʱ��
	tag				char(1)      default '0'       not null,  -- ����״̬ 0-���봦�� 1-δ���� 2-�Ѵ��� 3-��ɾ�� 4-�Ѿ�ʧЧ  
	lamp           char(1)      default '0'       not null,  -- ����״̬ 0-���봦�� 1-δ��   2-�ѿ�   3-�ѹ�
	status			varchar(254) default ''        not null,  -- ��ǰ״̬
	history			text         default ''        not null   -- ��ʷ�����¼ 
)
exec sp_primarykey message_leaveword,id
create unique index index1 on message_leaveword(id)
;
-- history 
if exists(select * from sysobjects where name = "message_leaveword_h")
	drop table message_leaveword_h
;
create table message_leaveword_h
(
	id				   int   							    not null,
	sort				char(3)      default 'LWD'     not null,  -- ������� basecode.cat = 'MsgLeaveWordSort' 
	accnt          char(10)     default ''        not null,  -- ��صı����ʺ�
	sender			char(10)		 default '' 	    not null,  -- ������
	senddate			datetime     default getdate() not null,  -- ����ʱ�� 
	content			text			 default ''        not null,  -- �������� 
	inure				datetime     default getdate() not null,  -- ��Чʱ��
	abate 			datetime     default getdate() not null,  -- ʧЧʱ��
	tag				char(1)      default '0'       not null,  -- ����״̬ 0-���봦�� 1-δ���� 2-�Ѵ��� 3-��ɾ�� 4-�Ѿ�ʧЧ  
	lamp           char(1)      default '0'       not null,  -- ����״̬ 0-���봦�� 1-δ��   2-�ѿ�   3-�ѹ�
	status			varchar(254) default ''        not null,  -- ��ǰ״̬
	history			text         default ''        not null   -- ��ʷ�����¼ 
)
exec sp_primarykey message_leaveword_h,id
create unique index index1 on message_leaveword_h(id)
;

--------------------------------------------------------------------------------
--  MsgLeaveWordSort
--------------------------------------------------------------------------------
if not exists(select 1 from basecode_cat where cat='MsgLeaveWordSort')
	insert basecode_cat(cat,descript,descript1,len) 
	select 'MsgLeaveWordSort', '�������', 'Leave Word Sort', 3
;

delete basecode where cat='MsgLeaveWordSort'
;
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'MsgLeaveWordSort', 'LWD', '��ͨ����', 'Common Leave Word','T','F',0,''
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'MsgLeaveWordSort', 'LOC', '���ͷ�λ', 'Guest Location','T','F',0,''
;
--------------------------------------------------------------------------------
--  LeaveWord Brief Help
--------------------------------------------------------------------------------
if not exists(select 1 from basecode where cat='BriefClass' and code = 'MsgLWD')
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'BriefClass', 'MsgLWD', '�������԰���', 'Leave Word Help','T','F',0,''
;
if not exists(select 1 from basecode where cat='BriefClass' and code = 'MsgLOC')
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'BriefClass', 'MsgLOC', '���ͷ�λ����', 'Guest Location Help','T','F',0,''
;
