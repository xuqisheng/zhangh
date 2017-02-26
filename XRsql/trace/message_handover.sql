--------------------------------------------------------------------------------
--  交班本
--------------------------------------------------------------------------------

-- TABLE:交班本 message_handover
if exists(select * from sysobjects where name = "message_handover")
	drop table message_handover
;
create table message_handover 
(
	id				   int   							    not null,
	sender			char(10)		 default '' 	    not null,  -- 发送人
	senddate			datetime     default getdate() not null,  -- 发送时间 
	content			text			 default ''        not null,  -- 内容 
	tag				char(1)      default '0'       not null,  -- 状态 0-正常 2-已删除 
	history			text         default ''        not null   -- 历史 
)
exec sp_primarykey message_handover,id
create unique index index1 on message_handover(id)
;
