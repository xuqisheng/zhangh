--------------------------------------------------------------------------------
--  ���౾
--------------------------------------------------------------------------------

-- TABLE:���౾ message_handover
if exists(select * from sysobjects where name = "message_handover")
	drop table message_handover
;
create table message_handover 
(
	id				   int   							    not null,
	sender			char(10)		 default '' 	    not null,  -- ������
	senddate			datetime     default getdate() not null,  -- ����ʱ�� 
	content			text			 default ''        not null,  -- ���� 
	tag				char(1)      default '0'       not null,  -- ״̬ 0-���� 2-��ɾ�� 
	history			text         default ''        not null   -- ��ʷ 
)
exec sp_primarykey message_handover,id
create unique index index1 on message_handover(id)
;
