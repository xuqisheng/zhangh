--------------------------------------------------------------------------------
-- GUEST:leaveword/location
--------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "message_leaveword")
	drop table message_leaveword
;
create table message_leaveword 
(
	id				   int   							    not null,
	sort				char(3)      default 'LWD'     not null,  -- 留言类别 basecode.cat = 'MsgLeaveWordSort' 
	accnt          char(10)     default ''        not null,  -- 相关的宾客帐号
	sender			char(10)		 default '' 	    not null,  -- 发送人
	senddate			datetime     default getdate() not null,  -- 发送时间 
	content			text			 default ''        not null,  -- 留言内容 
	inure				datetime     default getdate() not null,  -- 生效时间
	abate 			datetime     default getdate() not null,  -- 失效时间
	tag				char(1)      default '0'       not null,  -- 留言状态 0-无须处理 1-未处理 2-已处理 3-已删除 4-已经失效  
	lamp           char(1)      default '0'       not null,  -- 留言状态 0-无须处理 1-未开   2-已开   3-已关
	status			varchar(254) default ''        not null,  -- 当前状态
	history			text         default ''        not null   -- 历史处理记录 
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
	sort				char(3)      default 'LWD'     not null,  -- 留言类别 basecode.cat = 'MsgLeaveWordSort' 
	accnt          char(10)     default ''        not null,  -- 相关的宾客帐号
	sender			char(10)		 default '' 	    not null,  -- 发送人
	senddate			datetime     default getdate() not null,  -- 发送时间 
	content			text			 default ''        not null,  -- 留言内容 
	inure				datetime     default getdate() not null,  -- 生效时间
	abate 			datetime     default getdate() not null,  -- 失效时间
	tag				char(1)      default '0'       not null,  -- 留言状态 0-无须处理 1-未处理 2-已处理 3-已删除 4-已经失效  
	lamp           char(1)      default '0'       not null,  -- 留言状态 0-无须处理 1-未开   2-已开   3-已关
	status			varchar(254) default ''        not null,  -- 当前状态
	history			text         default ''        not null   -- 历史处理记录 
)
exec sp_primarykey message_leaveword_h,id
create unique index index1 on message_leaveword_h(id)
;

--------------------------------------------------------------------------------
--  MsgLeaveWordSort
--------------------------------------------------------------------------------
if not exists(select 1 from basecode_cat where cat='MsgLeaveWordSort')
	insert basecode_cat(cat,descript,descript1,len) 
	select 'MsgLeaveWordSort', '留言类别', 'Leave Word Sort', 3
;

delete basecode where cat='MsgLeaveWordSort'
;
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'MsgLeaveWordSort', 'LWD', '普通留言', 'Common Leave Word','T','F',0,''
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'MsgLeaveWordSort', 'LOC', '宾客方位', 'Guest Location','T','F',0,''
;
--------------------------------------------------------------------------------
--  LeaveWord Brief Help
--------------------------------------------------------------------------------
if not exists(select 1 from basecode where cat='BriefClass' and code = 'MsgLWD')
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'BriefClass', 'MsgLWD', '宾客留言帮助', 'Leave Word Help','T','F',0,''
;
if not exists(select 1 from basecode where cat='BriefClass' and code = 'MsgLOC')
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'BriefClass', 'MsgLOC', '宾客方位帮助', 'Guest Location Help','T','F',0,''
;
