--------------------------------------------------------------------------------
--  TABLE:事务处理内容message_trace
--------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "message_trace")
	drop table message_trace
;
create table message_trace 
(
	id				   int   							    not null,
	sort				char(3)      default 'AFF'     not null,  -- 事务类别 basecode.cat = 'MsgTraceSort' 
	accnt          char(10)     default ''        not null,  -- 相关的宾客帐号
	sender			char(10)		 default '' 	    not null,  -- 发送人
	senddate			datetime     default getdate() not null,  -- 发送时间 
	recvaddr       varchar(254) default ''        not null,  -- 接受人|部门列表
	receiver       varchar(30)  default ''        not null,  -- 接受人|部门列表
	subject			varchar(128) default ''        not null,  -- 事务主题 
	content			text			 default ''        not null,  -- 事务内容 
	inure				datetime     default getdate() not null,  -- 生效时间
	abate 			datetime     default getdate() not null,  -- 失效时间
	tag				char(1)      default '0'       not null,  -- 事务状态 0-无须处理 1-未处理 2-已处理 3-已删除 4-已失效
	resolver 		char(10)		 default ''        not null,  -- 处理人
	resolvedate		datetime		 default getdate() not null,  -- 处理时间 
	remark			varchar(254) default ''        not null,  -- 处理备注 
	action         char(3)      default ''        not null,  -- 事务附加处理  basecode.cat = 'MsgTraceAction' 
	extdata        varchar(254) default ''        not null,  -- 附加消息 
	feetag         char(1)      default 'F'       not null,  -- 帐务状态 T-帐务已经入帐 F-没有入帐 
	feecode        char(5)      default ''        not null,  -- 费用码 = pccode
	amount			money			 default 0.00      not null,  -- 费用金额  
	chargeup       char(4)      default ''        not null,  -- 入帐人员
	chargeupdate   datetime     default getdate() not null,   -- 入帐时间 
	cby				char(10)		default '!' 	not null,	/* 最新修改人信息 */
	changed			datetime		default getdate()		not null 
)
exec sp_primarykey message_trace,id
create unique index index1 on message_trace(id)
;
-- history
if exists(select * from sysobjects where name = "message_trace_h")
	drop table message_trace_h
;
create table message_trace_h
(
	id				   int   							    not null,
	sort				char(3)      default 'AFF'     not null,  -- 事务类别 basecode.cat = 'MsgTraceSort' 
	accnt          char(10)     default ''        not null,  -- 相关的宾客帐号
	sender			char(10)		 default '' 	    not null,  -- 发送人
	senddate			datetime     default getdate() not null,  -- 发送时间 
	recvaddr       varchar(254) default ''        not null,  -- 接受人|部门列表
	receiver       varchar(30)  default ''        not null,  -- 接受人|部门列表
	subject			varchar(128) default ''        not null,  -- 事务主题 
	content			text			 default ''        not null,  -- 事务内容 
	inure				datetime     default getdate() not null,  -- 生效时间
	abate 			datetime     default getdate() not null,  -- 失效时间
	tag				char(1)      default '0'       not null,  -- 事务状态 0-无须处理 1-未处理 2-已处理 3-已删除 4-已失效
	resolver 		char(10)		 default ''        not null,  -- 处理人
	resolvedate		datetime		 default getdate() not null,  -- 处理时间 
	remark			varchar(254) default ''        not null,  -- 处理备注 
	action         char(3)      default ''        not null,  -- 事务附加处理  basecode.cat = 'MsgTraceAction' 
	extdata        varchar(254) default ''        not null,  -- 附加消息 
	feetag         char(1)      default 'F'       not null,  -- 帐务状态 T-帐务已经入帐 F-没有入帐 
	feecode        char(5)      default ''        not null,  -- 费用码 = pccode
	amount			money			 default 0.00      not null,  -- 费用金额  
	chargeup       char(4)      default ''        not null,  -- 入帐人员
	chargeupdate   datetime     default getdate() not null,   -- 入帐时间 
	cby				char(10)		default '!' 	not null,	/* 最新修改人信息 */
	changed			datetime		default getdate()		not null 
)
exec sp_primarykey message_trace_h,id
create unique index index1 on message_trace_h(id)
;
--------------------------------------------------------------------------------
--  MsgTraceSort
--------------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='MsgTraceSort')
	delete basecode_cat where cat='MsgTraceSort';
insert basecode_cat(cat,descript,descript1,len) select 'MsgTraceSort', '事务类别', 'MsgTraceSort', 3;

delete basecode where cat='MsgTraceSort';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'MsgTraceSort', 'AFF', '普通事务', 'Common Affair','F','F',0,'';

--------------------------------------------------------------------------------
--  MsgTraceAction
--------------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='MsgTraceAction')
	delete basecode_cat where cat='MsgTraceAction';
insert basecode_cat(cat,descript,descript1,len) select 'MsgTraceAction', '事务附加处理', 'MsgTraceAction', 3;

delete basecode where cat='MsgTraceAction';

--------------------------------------------------------------------------------
--  Trace Brief Help
--------------------------------------------------------------------------------
if not exists(select 1 from basecode where cat='BriefClass' and code = 'AffairHelp')
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'BriefClass', 'AffairHelp', '事务模板', 'Affair Help','T','F',0,''
;
