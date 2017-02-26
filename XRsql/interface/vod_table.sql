
//  basecode : cat = vod_grade


------------------------------------------------------------------------------------
--  		原始记录
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vod_src" and type="U")
	drop table vod_src;
create table vod_src 
(
    log_date datetime     not null,
    src      varchar(100) null
)
exec sp_primarykey 'vod_src', log_date
create unique nonclustered index index1 on vod_src(log_date)
;

------------------------------------------------------------------------------------
--  		计费错误原始记录  --- 如果记录有效,用手工输入帐务
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vod_err" and type="U")
	drop table vod_err;
create table vod_err 
(
    log_date datetime     not null,
    src      varchar(100) null
)
exec sp_primarykey 'vod_err', log_date
create unique nonclustered index index1 on vod_err(log_date)
;


if exists(select * from sysobjects where name = "vod_posterr" and type="U")
	drop table vod_posterr;
create table vod_posterr 
(
    logdate datetime     not null,
    des     varchar(100) not null
)
exec sp_primarykey 'vod_posterr', logdate
create unique nonclustered index index1 on vod_posterr(logdate)
;


------------------------------------------------------------------------------------
--       计费流水帐文件
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vodfolio" and type="U")
	drop table vodfolio;
create table vodfolio 
(
    inumber  int         not null,	
    log_date datetime    not null,		-- FOXHIS 系统入帐时间
    status   char(1)     not null,		-- 状态
    seq_id   varchar(10) not null,		-- 点播流水号
    usr_id   varchar(10) not null,		-- 客房编号
    pgm_name varchar(20) not null,		-- 点播内容的名称 
    p_time   datetime    not null,		-- 日期时间
    pgm_amt  money       not null,		-- 费用
    refer    char(10)    null,
    empno    char(10)    null,
    shift    char(1)     null
)
exec sp_primarykey 'vodfolio', inumber
create unique nonclustered index index1  on vodfolio(inumber)
create unique nonclustered index index2  on vodfolio(log_date)
;


------------------------------------------------------------------------------------
--       计费流水帐文件 - 历史
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vodhfolio" and type="U")
	drop table vodhfolio;
create table vodhfolio 
(
    inumber  int         not null,
    log_date datetime    not null,		-- FOXHIS 系统入帐时间
    status   char(1)     not null,		-- 状态
    seq_id   varchar(10) not null,		-- 点播流水号
    usr_id   varchar(10) not null,		-- 客房编号
    pgm_name varchar(20) not null,		-- 点播内容的名称 
    p_time   datetime    not null,		-- 日期时间
    pgm_amt  money       not null,		-- 费用
    refer    char(10)    null,
    empno    char(10)    null,
    shift    char(1)     null
)
exec sp_primarykey 'vodhfolio', inumber
create unique nonclustered index index1 on vodhfolio(inumber)
create unique nonclustered index index2 on vodhfolio(log_date)
;


------------------------------------------------------------------------------------
-- 		客房 VOD 等级
--			设定,取消,修改 ---> 前台,电脑房 均可全面操作
--			客人结帐离店 ---> 根据MASTER的状态变化操作(活用TRIGGER)
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vod_grd" and type="U")
	drop table vod_grd;
create table vod_grd 
(
    roomno    char(5)       not null,					-- 酒店客房编号
    changed   char(1)       default 'f' null,
    ograde    char(1)       null,						-- 状态变更
    grade     char(1)       not null,
    obox_addr varchar(10)   null,						-- 客房机顶盒地址
    box_addr  varchar(10)   null,
    gst_grd   char(1)       default '1' null,		-- 客房入主客人的级别 1->A, 3->B 
    gst_name  varchar(10)   default 'vod' not null,-- 客人姓名
    empno     char(10)      null,
    shift     char(1)       null,
    date      datetime      null,
    logmark   numeric(10,0) default 0  null
)
exec sp_primarykey 'vod_grd', roomno
create unique nonclustered index index1 on vod_grd(roomno)
;


------------------------------------------------------------------------------------
-- 		客房 VOD 等级  --- 日志文件
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vod_grd_log" and type="U")
	drop table vod_grd_log;
create table vod_grd_log 
(
    roomno    char(5)       not null,					-- 酒店客房编号
    changed   char(1)       default 'f' null,
    ograde    char(1)       null,						-- 状态变更
    grade     char(1)       not null,
    obox_addr varchar(10)   null,						-- 客房机顶盒地址
    box_addr  varchar(10)   null,
    gst_grd   char(1)       default '1' null,		-- 客房入主客人的级别 1->A, 3->B 
    gst_name  varchar(10)   default 'vod' not null,-- 客人姓名
    empno     char(10)      null,
    shift     char(1)       null,
    date      datetime      null,
    logmark   numeric(10,0) default 0  null
)
exec sp_primarykey 'vod_grd_log', roomno,logmark
create unique nonclustered index index1 on vod_grd_log(roomno,logmark)
;


------------------------------------------------------------------------------------
--  		排行榜 
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vod_board" and type="U")
	drop table vod_board;
create table vod_board 
(
    pc_id   char(4)     not null,
    no      int         not null,
    program varchar(20) default '?' not null,
    number  int         default 0 not null
)
exec sp_primarykey 'vod_board', pc_id,program
create unique nonclustered index index1 on vod_board(pc_id,program)
;


------------------------------------------------------------------------------------
--  		排行榜  (临时表)
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vod_board_tmp" and type="U")
	drop table vod_board_tmp;
create table vod_board_tmp 
(
    pc_id   char(4)     not null,
    program varchar(20) default '?' not null,
    number  int         default 0 not null
)
exec sp_primarykey 'vod_board_tmp', pc_id,program
create unique nonclustered index index1 on vod_board_tmp(pc_id,program)
;

