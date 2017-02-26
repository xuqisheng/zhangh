-- ----------------------------------------------------------------------------------
-- 
--   			Internet �Ʒ�ϵͳ   ---  ��������˾ + ����չ����ѯ��˾
-- 				
-- ----------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------
--    int ԭʼ����
-- ----------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'int_src')
	drop table int_src;
create table int_src 
(
	log_date			datetime			not null,  -- FOXHIS ϵͳ����ʱ�� 
	src				varchar(255)	null
)
exec   sp_primarykey int_src, log_date
create unique index index1 on int_src(log_date)
;

-- ----------------------------------------------------------------------------------
-- 	�ƷѴ���ԭʼ��¼  --- �����¼��Ч,���ֹ���������
-- ----------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'int_err')
	drop table int_err;
create table int_err 
(
	log_date			datetime			not null,  -- FOXHIS ϵͳ����ʱ�� 
	src				varchar(255)	null
)
exec   sp_primarykey int_err, log_date
create unique index index1 on int_err(log_date)
;

-- ----------------------------------------------------------------------------------
--        FOXHIS �Ʒ���ˮ���ļ�
-- ----------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'intfolio')
	drop table intfolio;
create table intfolio 
(
	inumber			int				not null,
	log_date			datetime			not null,  -- FOXHIS ϵͳ����ʱ�� 
	int_user			varchar(16)		not null,  -- �û����� 
	date				datetime			not null,  -- ����ʱ�� 
	minute			int default 0	not null,  -- ʱ�� (����) 
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
--        FOXHIS �Ʒ���ˮ���ļ� (��ʷ)
-- ----------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'inthfolio')
	drop table inthfolio;
create table inthfolio 
(
	inumber			int				not null,
	log_date			datetime			not null,  -- FOXHIS ϵͳ����ʱ�� 
	int_user				varchar(16)		not null,  -- �û����� 
	date				datetime			not null,  -- ����ʱ�� 
	minute			int default 0	not null,  -- ʱ�� (����) 
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
--        �����ʺ���INTERNET�ʺŵĹ���
-- 					---->  ͨ�����Ĵ���������PMS����
-- ----------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'inttoact')
	drop table inttoact;
create table inttoact 
(
	int_user			varchar(16)		not null, -- �û����� 
	accnt				char(10)			not null, -- �����ʺ� 
	actdes			varchar(60)		null,
	occ				char(1) default 'F' not null, --  online ?
	date				datetime			null,  	-- ����ʱ�� 
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
	int_user			varchar(16)		not null, -- �û����� 
	accnt				char(10)			not null, -- �����ʺ�  
	actdes			varchar(60)		null,
	occ				char(1) default 'F' not null, --  online ?
	date				datetime			null,  -- ����ʱ�� 
	empno				char(10)			null,
	logmark			int default 0  not null
)
exec   sp_primarykey inttoact_log, int_user, logmark
create unique index index1 on inttoact_log(int_user, logmark)
;

--  ----------------------------------------------------------------------
-- 		INTERNET �û��ʺű��� ODBC �� .MDB ȡ��
-- 		
-- 				�˱���ϵͳÿһ�ν��� �� �û����������Ҫ���д���  ODBC->SYBASE
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
-- 		INTERNET �û��ʺŴ򿪹رձ�
--  ----------------------------------------------------------------------
if object_id('internet_pms') is not null
	drop table internet_pms
;
create table internet_pms (
	username			varchar(16)				not null,  
	tag				char(1)  default '0' not null,  --  0-�أ�1-��
	changed			char(1)  default 'T' not null,
	empno				char(10)					null,
	date				datetime					null
);
exec sp_primarykey internet_pms, username;
create unique index index1 on internet_pms(username)
;


