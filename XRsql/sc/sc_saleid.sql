
-------------------------------------------------------------------------------------
-- table :	salegrp	= 销售员小组 group or team 
--
--		小组的领导如何界定？ - 可能是多个人。或者直接主管一个，但是有这个权限的很多
-------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "salegrp")
	drop table salegrp;
create table  salegrp
(
	code    		char(10)						not null,
	descript    varchar(50)	default ''	not null,
	descript1   varchar(50)	default ''	not null,
	leader		varchar(50)	default ''	not null,	-- 组长
	grp			char(10)		default ''	not null,	-- 暂时无用
	halt			char(1)		default 'F'	not null,
	sequence		int			default 0	not null
)
exec sp_primarykey salegrp,code
create unique index index1 on salegrp(code)
;


-- ----------------------------------------------------------------
-- table :	saleid	= 销售员 
-- ----------------------------------------------------------------
if exists(select 1 from sysobjects where name = "saleid")
	drop table saleid;
create table  saleid
(
	code    		char(10)								not null,		-- 代码 
	sta			char(1)			default 'I'		not null,		-- I=有效 S=Inactive O=terminal - 系统固定代码
	name		   varchar(50)	 						not null,	 	-- 姓名: 本名 

	dept			char(10)								not null,		-- 酒店部门	- basecode - dept - len(code)=1 and code<>'0' 
	job			char(10)								null,				-- 酒店 job title - basecode - htljob 
	extension	varchar(10)							null,				-- 分机
	grp			char(10)								not null,		-- 销售组别	- salegrp 
	territory 	varchar(30)							not null,		-- 销售区域 - 代码多选 basecode - territory 
	fulltime		char(1)			default 'T'		not null,
	arr0        datetime      						null,  			-- 进入酒店工作时间
   arr         datetime      						null,  			-- 有效日期
   dep         datetime      						null,				-- 终止日期
	empno			char(10)			default ''		not null,		-- 电脑工号

	fname       varchar(30)		default ''		not null, 		-- 英文名 
	lname			varchar(30)		default '' 		not null,		-- 英文姓 
	name2		   varchar(50)		default '' 		not null,		-- 扩充名字 
	name3		   varchar(50)		default '' 		not null,		-- 扩充名字 
	sex			char(1)			default '1'		not null,      -- 性别:M,F 
   idcls       char(3)     	default ''		not null,     	-- 最新证件类别 
	ident		   char(20)	   	default ''		not null,     	-- 最新证件号码 
	lang			char(1)			default 'C'		not null,		-- 语种 
	birth       datetime								null,         	-- 生日 		
	nation		char(3)			default ''		not null,		-- 国籍 
	country		char(3)			default ''		not null,	   -- 国家 
	state			char(3)			default ''		not null,	   -- 国家 
	town			varchar(40)		default ''		not null,		-- 城市
	street	   varchar(60)		default ''		not null,		-- 住址 
	zip			varchar(6)		default ''		not null,		-- 邮政编码 
	mobile		varchar(30)		default ''		not null,		-- 手机 
	phone			varchar(30)		default ''		not null,		-- 电话 
	fax			varchar(30)		default ''		not null,		-- 传真 
	wetsite		varchar(50)		default ''		not null,		-- 网址 
	email			varchar(50)		default ''		not null,		-- 电邮 

	remark		text									null,
	sequence		int				default 0		not null,

-- 预留字段
	exp_m1		money									null,
	exp_m2		money									null,
	exp_dt1		datetime								null,
	exp_dt2		datetime								null,
	exp_s1		varchar(10)							null,
	exp_s2		varchar(10)							null,
	exp_s3		varchar(10)							null,

   crtby       char(10)								not null,	// 建立 
	crttime     datetime 		default getdate()	not null,
   cby         char(10)								not null,	// 修改 
	changed     datetime 		default getdate()	not null,
	logmark     int 				default 0 		not null
)
exec sp_primarykey saleid,code
create unique index index1 on saleid(code)
create unique index index2 on saleid(name)
create unique index index3 on saleid(name2)
;

if exists(select 1 from sysobjects where name = "saleid_log")
	drop table saleid_log;
create table  saleid_log
(
	code    		char(10)								not null,		-- 代码 
	sta			char(1)			default 'I'		not null,		-- I=有效 S=Inactive O=terminal - 系统固定代码
	name		   varchar(50)	 						not null,	 	-- 姓名: 本名 

	dept			char(10)								not null,		-- 酒店部门	- basecode - dept - len(code)=1 and code<>'0' 
	job			char(10)								null,				-- 酒店 job title - basecode - htljob 
	extension	varchar(10)							null,				-- 分机
	grp			char(10)								not null,		-- 销售组别	- salegrp 
	territory 	varchar(30)							not null,		-- 销售区域 - 代码多选 basecode - territory 
	fulltime		char(1)			default 'T'		not null,
	arr0        datetime      						null,  			-- 进入酒店工作时间
   arr         datetime      						null,  			-- 有效日期
   dep         datetime      						null,				-- 终止日期
	empno			char(10)			default ''		not null,		-- 电脑工号

	fname       varchar(30)		default ''		not null, 		-- 英文名 
	lname			varchar(30)		default '' 		not null,		-- 英文姓 
	name2		   varchar(50)		default '' 		not null,		-- 扩充名字 
	name3		   varchar(50)		default '' 		not null,		-- 扩充名字 
	sex			char(1)			default '1'		not null,      -- 性别:M,F 
   idcls       char(3)     	default ''		not null,     	-- 最新证件类别 
	ident		   char(20)	   	default ''		not null,     	-- 最新证件号码 
	lang			char(1)			default 'C'		not null,		-- 语种 
	birth       datetime								null,         	-- 生日 		
	nation		char(3)			default ''		not null,		-- 国籍 
	country		char(3)			default ''		not null,	   -- 国家 
	state			char(3)			default ''		not null,	   -- 国家 
	town			varchar(40)		default ''		not null,		-- 城市
	street	   varchar(60)		default ''		not null,		-- 住址 
	zip			varchar(6)		default ''		not null,		-- 邮政编码 
	mobile		varchar(30)		default ''		not null,		-- 手机 
	phone			varchar(30)		default ''		not null,		-- 电话 
	fax			varchar(30)		default ''		not null,		-- 传真 
	wetsite		varchar(50)		default ''		not null,		-- 网址 
	email			varchar(50)		default ''		not null,		-- 电邮 

	remark		text									null,
	sequence		int				default 0		not null,

-- 预留字段
	exp_m1		money									null,
	exp_m2		money									null,
	exp_dt1		datetime								null,
	exp_dt2		datetime								null,
	exp_s1		varchar(10)							null,
	exp_s2		varchar(10)							null,
	exp_s3		varchar(10)							null,

   crtby       char(10)								not null,	// 建立 
	crttime     datetime 		default getdate()	not null,
   cby         char(10)								not null,	// 修改 
	changed     datetime 		default getdate()	not null,
	logmark     int 				default 0 		not null
)
exec sp_primarykey saleid_log,code,logmark
create unique index index1 on saleid_log(code,logmark)
;

