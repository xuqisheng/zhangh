--------------------------------------------------------------------------------
--  TABLE:消息服务处理message_notify_type
--------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "message_notify_type")
	drop table message_notify_type
;
create table message_notify_type 
(
	msgsort			char(32)     default ''        not null,  -- 类别
   descript   		varchar(60)  default ''			 not null,  -- 描述
   descript1  		varchar(60)  default ''   		 not null,  -- 描述1
	msgmode			char(1)      default '0'       not null,  -- 处理方式 0--通知 1--业务 
   msgwin  		   varchar(60)  default ''   		 not null,  -- 消息处理窗口，接受参数msgid
	usefullife     char(5)      default '0'       not null,  -- 有效时间 0-不控制 1--永久 M..---分钟 H..--小时 D..--天 
	msgfirst			char(1)      default '0' 	    not null,  -- 是否立即显示 0-否 1-是
	msgroll			char(1)      default '0' 	    not null,  -- 是否滚动 0-否 1-是
	msgicon			char(1)      default '0' 	    not null,  -- 是否显示图标 0-否 1-是
	msgrec			char(1)      default '0' 	    not null   -- 是否记录 0-否 1-是
)
exec sp_primarykey message_notify_type,msgsort
create unique index index1 on message_notify_type(msgsort)
;
--------------------------------------------------------------------------------
--  DATA
--------------------------------------------------------------------------------
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'SYS_RUNINTERFACE','Foxhis 服务器','Foxhis Sercice','0','','M10','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXNOTIFY','Foxhis 通知消息','Foxhis Notify','0','','M30','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXMAIL','Foxhis 邮局','Foxhis Mail','0','','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXTRACE','Foxhis Trace ','Foxhis Trace ','1','w_trace_affair_qa','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXRMCHKIN','报房申请','Room Check In','1','','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXRMCHKINOK','报房查房完成','Room Check In Ok','1','','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXRMCHKOUT','查房申请','Room Check Out','1','','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXRMCHKOUTOK','查房完成','Room Check Out Ok','1','','0','0','1','1','1' 
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'Q-ROOM','Q-Room','Q-Room','1','','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'DISC-ROOM','矛盾房','Discrepart Room','1','','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'ACNT_PHONE','电话记费遗漏','Losing Account for Phone','0','','M30','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'CRS_NOTIFY','CRS 通知消息','CRS Notify','0','','M04','0','1','1','1'  
; 



--------------------------------------------------------------------------------
--  TABLE:消息服务处理message_notify 
--------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "message_notify")
	drop table message_notify
;
create table message_notify 
(
	msgid				char(32) 						    not null,
	msgsort  		char(32)     default ''        not null,  -- 类别 
	msgdate			datetime     default getdate() not null,  -- 时间 
	msgfrom			varchar(10)  default '' 	    not null,  -- 发送 (empno)
	msgfrom1  		varchar(32)  default '' 	    not null,  -- 发送 (pc_id@appid)
	msgto          varchar(254) default ''        not null,  -- 接受 (empno or dept addr) e.g. FOX or <D:0>
	msgto1         varchar(254) default ''        not null,  -- 接受 (pc_id list) e.g. ,2.22,0.22,
	msgtext			varchar(254) default ''        not null,  -- 内容
	msgdata			varchar(254) default ''        not null,  -- 消息数据
	status			char(1)      default '0'       not null,  -- 状态 0-未处理 1-已处理
	reader			text                               null   -- 处理：(date time,empno,op,pc_id@appid\r\n)*
)
exec sp_primarykey message_notify,msgid
create unique index index1 on message_notify(msgid)
;
