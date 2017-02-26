-- ----------------------------------------------------------------------------------
-- 
--   			Internet 计费系统   ---  杭州西软公司 + 杭州展望咨询公司
-- 				
-- ----------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------
--    int 原始数据
-- ----------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'int_src')
	drop table int_src;
create table int_src 
(
	log_date			datetime			not null,  -- FOXHIS 系统入帐时间 
	src				varchar(255)	null
)
exec   sp_primarykey int_src, log_date
create unique index index1 on int_src(log_date)
;

-- ----------------------------------------------------------------------------------
-- 	计费错误原始记录  --- 如果记录有效,用手工输入帐务
-- ----------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'int_err')
	drop table int_err;
create table int_err 
(
	log_date			datetime			not null,  -- FOXHIS 系统入帐时间 
	src				varchar(255)	null
)
exec   sp_primarykey int_err, log_date
create unique index index1 on int_err(log_date)
;

-- ----------------------------------------------------------------------------------
--        FOXHIS 计费流水帐文件
-- ----------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'intfolio')
	drop table intfolio;
create table intfolio 
(
	inumber			int				not null,
	log_date			datetime			not null,  -- FOXHIS 系统入帐时间 
	int_user			varchar(16)		not null,  -- 用户编码 
	date				datetime			not null,  -- 日期时间 
	minute			int default 0	not null,  -- 时间 (分钟) 
	amount			money	default 0 not null,
	refer				char(10)			null,		  --  
	empno				char(10)			null,
	shift				char(1)			null
)
exec   sp_primarykey intfolio, inumber
create unique index index1 on intfolio(inumber)
create unique index index2 on intfolio(log_date)
;


-- ----------------------------------------------------------------------------------
--        FOXHIS 计费流水帐文件 (历史)
-- ----------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'inthfolio')
	drop table inthfolio;
create table inthfolio 
(
	inumber			int				not null,
	log_date			datetime			not null,  -- FOXHIS 系统入帐时间 
	int_user				varchar(16)		not null,  -- 用户编码 
	date				datetime			not null,  -- 日期时间 
	minute			int default 0	not null,  -- 时间 (分钟) 
	amount			money	default 0 not null,
	refer				char(10)			null,		  --  
	empno				char(10)			null,
	shift				char(1)			null
)
exec   sp_primarykey inthfolio, inumber
create unique index index1 on inthfolio(inumber)
create unique index index2 on inthfolio(log_date)
;


-- ----------------------------------------------------------------------------------
--        宾客帐号与INTERNET帐号的关联
-- 					---->  通过他的触发器进行PMS控制
-- ----------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'inttoact')
	drop table inttoact;
create table inttoact 
(
	int_user			varchar(16)		not null, -- 用户编码 
	accnt				char(10)			not null, -- 宾客帐号 
	actdes			varchar(60)		null,
	occ				char(1) default 'F' not null, --  online ?
	date				datetime			null,  	-- 日期时间 
	empno				char(10)			null,
	logmark			int default 0  not null
)
exec   sp_primarykey inttoact, int_user
create unique index index1 on inttoact(int_user)
;
if exists(select * from sysobjects where name = 'inttoact_log')
	drop table inttoact_log;
create table inttoact_log
(
	int_user			varchar(16)		not null, -- 用户编码 
	accnt				char(10)			not null, -- 宾客帐号  
	actdes			varchar(60)		null,
	occ				char(1) default 'F' not null, --  online ?
	date				datetime			null,  -- 日期时间 
	empno				char(10)			null,
	logmark			int default 0  not null
)
exec   sp_primarykey inttoact_log, int_user, logmark
create unique index index1 on inttoact_log(int_user, logmark)
;

--  ----------------------------------------------------------------------
-- 		INTERNET 用户帐号表，用 ODBC 从 .MDB 取得
-- 		
-- 				此表在系统每一次进入 或 用户管理结束都要进行传输  ODBC->SYBASE
--  ----------------------------------------------------------------------
if object_id('internet_users') is not null
	drop table internet_users
;
create table internet_users (
	id					int					not null,
	username			varchar(16)			not null,
	fullname			varchar(60) 		null,
	password			varchar(32)			null,
	pop3password	varchar(32) 		null,
	ipaddress		varchar(15) 		null,
	userbe			smallint 			null,
	workgroup 		varchar(64)			not null,
	www				bit					not null, 
	ftp				bit					not null,
	email				bit					not null, 
	socks				bit					not null,
	monthlimit		real					not null,
	totallimit		real					not null,
	monthcount		real					not null,
	totalcount		real					not null,
	isextermailaddress	bit					not null,
	extermailaddress		varchar(100)  		null
);
exec sp_primarykey internet_users, username;
create unique index index1 on internet_users(username)
create unique index index2 on internet_users(id)
create index index3 on internet_users(ipaddress)
;

--  ----------------------------------------------------------------------
-- 		INTERNET 用户帐号打开关闭表
--  ----------------------------------------------------------------------
if object_id('internet_pms') is not null
	drop table internet_pms
;
create table internet_pms (
	username			varchar(16)				not null,  
	tag				char(1)  default '0' not null,  --  0-关，1-开
	changed			char(1)  default 'T' not null,
	empno				char(10)					null,
	date				datetime					null
);
exec sp_primarykey internet_pms, username;
create unique index index1 on internet_pms(username)
;


