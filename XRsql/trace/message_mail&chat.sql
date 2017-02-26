--------------------------------------------------------------------------------
--  职员留言
--------------------------------------------------------------------------------

-- TABLE:职员留言消息内容message_mail
if exists(select * from sysobjects where name = "message_mail")
	drop table message_mail
;
create table message_mail 
(
	id				   int   							    not null,
	sort				char(1)      default '0'       not null,  -- 留言类别 0-单人 1-多人 2-全体
	sender			char(10)		 default ''	    	 not null,  -- 发送人
	senddate			datetime     default getdate() not null,  -- 发送时间 
	receiver       varchar(254) default ''        not null,  -- 接受人|部门列表
	subject			varchar(128) default ''        not null,  -- 留言主题 
	content			text			 default ''        not null,  -- 留言内容
	status			char(1)      default '1'       not null   -- 留言状态 0-草稿 1-已发送 3-已删除
)
exec sp_primarykey message_mail,id
create unique index index1 on message_mail(id)
;

-- TABLE:职员留言消息接收message_mailrecv
if exists(select * from sysobjects where name = "message_mailrecv")
	drop table message_mailrecv
;
create table message_mailrecv
(
	id				   int   							    not null,  -- 对应message_mail.id
	receiver  		char(10)		 default ''        not null,  -- 接受人 
	recvdate		   datetime		 default getdate() not null,  -- 处理时间 
	tag				char(1)      default '1'       not null,  -- 留言状态 0-未处理 1-阅读 2-回复 3-已删除 4-不再有效
	reid			   int   		 default 0		    not null   -- 回复单的原始对应ID
)
create index index1 on message_mailrecv(id,receiver)
;

-- TABLE:职员聊天内容message_chat
if exists(select * from sysobjects where name = "message_chat")
	drop table message_chat
;
create table message_chat
(
	id				   int   							    not null,
	sort    			char(1)      default '1'       not null,  -- 状态 1-个人 2-广播 
	sender			char(10)		 default ''		    not null,  -- 发送人
	senddate			datetime     default getdate() not null,  -- 发送时间 
	content			text			 default ''        not null,  -- 留言内容
	receiver  		char(10)		 default ''        not null,  -- 接受人 
	tag    			char(1)      default '1'       not null   -- 状态 0-未处理 1-阅读 2-已删除
)
exec sp_primarykey message_chat,id
create unique index index1 on message_chat(id)
;

