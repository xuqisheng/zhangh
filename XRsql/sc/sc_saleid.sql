
-------------------------------------------------------------------------------------
-- table :	salegrp	= ����ԱС�� group or team 
--
--		С����쵼��ν綨�� - �����Ƕ���ˡ�����ֱ������һ�������������Ȩ�޵ĺܶ�
-------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "salegrp")
	drop table salegrp;
create table  salegrp
(
	code    		char(10)						not null,
	descript    varchar(50)	default ''	not null,
	descript1   varchar(50)	default ''	not null,
	leader		varchar(50)	default ''	not null,	-- �鳤
	grp			char(10)		default ''	not null,	-- ��ʱ����
	halt			char(1)		default 'F'	not null,
	sequence		int			default 0	not null
)
exec sp_primarykey salegrp,code
create unique index index1 on salegrp(code)
;


-- ----------------------------------------------------------------
-- table :	saleid	= ����Ա 
-- ----------------------------------------------------------------
if exists(select 1 from sysobjects where name = "saleid")
	drop table saleid;
create table  saleid
(
	code    		char(10)								not null,		-- ���� 
	sta			char(1)			default 'I'		not null,		-- I=��Ч S=Inactive O=terminal - ϵͳ�̶�����
	name		   varchar(50)	 						not null,	 	-- ����: ���� 

	dept			char(10)								not null,		-- �Ƶ겿��	- basecode - dept - len(code)=1 and code<>'0' 
	job			char(10)								null,				-- �Ƶ� job title - basecode - htljob 
	extension	varchar(10)							null,				-- �ֻ�
	grp			char(10)								not null,		-- �������	- salegrp 
	territory 	varchar(30)							not null,		-- �������� - �����ѡ basecode - territory 
	fulltime		char(1)			default 'T'		not null,
	arr0        datetime      						null,  			-- ����Ƶ깤��ʱ��
   arr         datetime      						null,  			-- ��Ч����
   dep         datetime      						null,				-- ��ֹ����
	empno			char(10)			default ''		not null,		-- ���Թ���

	fname       varchar(30)		default ''		not null, 		-- Ӣ���� 
	lname			varchar(30)		default '' 		not null,		-- Ӣ���� 
	name2		   varchar(50)		default '' 		not null,		-- �������� 
	name3		   varchar(50)		default '' 		not null,		-- �������� 
	sex			char(1)			default '1'		not null,      -- �Ա�:M,F 
   idcls       char(3)     	default ''		not null,     	-- ����֤����� 
	ident		   char(20)	   	default ''		not null,     	-- ����֤������ 
	lang			char(1)			default 'C'		not null,		-- ���� 
	birth       datetime								null,         	-- ���� 		
	nation		char(3)			default ''		not null,		-- ���� 
	country		char(3)			default ''		not null,	   -- ���� 
	state			char(3)			default ''		not null,	   -- ���� 
	town			varchar(40)		default ''		not null,		-- ����
	street	   varchar(60)		default ''		not null,		-- סַ 
	zip			varchar(6)		default ''		not null,		-- �������� 
	mobile		varchar(30)		default ''		not null,		-- �ֻ� 
	phone			varchar(30)		default ''		not null,		-- �绰 
	fax			varchar(30)		default ''		not null,		-- ���� 
	wetsite		varchar(50)		default ''		not null,		-- ��ַ 
	email			varchar(50)		default ''		not null,		-- ���� 

	remark		text									null,
	sequence		int				default 0		not null,

-- Ԥ���ֶ�
	exp_m1		money									null,
	exp_m2		money									null,
	exp_dt1		datetime								null,
	exp_dt2		datetime								null,
	exp_s1		varchar(10)							null,
	exp_s2		varchar(10)							null,
	exp_s3		varchar(10)							null,

   crtby       char(10)								not null,	// ���� 
	crttime     datetime 		default getdate()	not null,
   cby         char(10)								not null,	// �޸� 
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
	code    		char(10)								not null,		-- ���� 
	sta			char(1)			default 'I'		not null,		-- I=��Ч S=Inactive O=terminal - ϵͳ�̶�����
	name		   varchar(50)	 						not null,	 	-- ����: ���� 

	dept			char(10)								not null,		-- �Ƶ겿��	- basecode - dept - len(code)=1 and code<>'0' 
	job			char(10)								null,				-- �Ƶ� job title - basecode - htljob 
	extension	varchar(10)							null,				-- �ֻ�
	grp			char(10)								not null,		-- �������	- salegrp 
	territory 	varchar(30)							not null,		-- �������� - �����ѡ basecode - territory 
	fulltime		char(1)			default 'T'		not null,
	arr0        datetime      						null,  			-- ����Ƶ깤��ʱ��
   arr         datetime      						null,  			-- ��Ч����
   dep         datetime      						null,				-- ��ֹ����
	empno			char(10)			default ''		not null,		-- ���Թ���

	fname       varchar(30)		default ''		not null, 		-- Ӣ���� 
	lname			varchar(30)		default '' 		not null,		-- Ӣ���� 
	name2		   varchar(50)		default '' 		not null,		-- �������� 
	name3		   varchar(50)		default '' 		not null,		-- �������� 
	sex			char(1)			default '1'		not null,      -- �Ա�:M,F 
   idcls       char(3)     	default ''		not null,     	-- ����֤����� 
	ident		   char(20)	   	default ''		not null,     	-- ����֤������ 
	lang			char(1)			default 'C'		not null,		-- ���� 
	birth       datetime								null,         	-- ���� 		
	nation		char(3)			default ''		not null,		-- ���� 
	country		char(3)			default ''		not null,	   -- ���� 
	state			char(3)			default ''		not null,	   -- ���� 
	town			varchar(40)		default ''		not null,		-- ����
	street	   varchar(60)		default ''		not null,		-- סַ 
	zip			varchar(6)		default ''		not null,		-- �������� 
	mobile		varchar(30)		default ''		not null,		-- �ֻ� 
	phone			varchar(30)		default ''		not null,		-- �绰 
	fax			varchar(30)		default ''		not null,		-- ���� 
	wetsite		varchar(50)		default ''		not null,		-- ��ַ 
	email			varchar(50)		default ''		not null,		-- ���� 

	remark		text									null,
	sequence		int				default 0		not null,

-- Ԥ���ֶ�
	exp_m1		money									null,
	exp_m2		money									null,
	exp_dt1		datetime								null,
	exp_dt2		datetime								null,
	exp_s1		varchar(10)							null,
	exp_s2		varchar(10)							null,
	exp_s3		varchar(10)							null,

   crtby       char(10)								not null,	// ���� 
	crttime     datetime 		default getdate()	not null,
   cby         char(10)								not null,	// �޸� 
	changed     datetime 		default getdate()	not null,
	logmark     int 				default 0 		not null
)
exec sp_primarykey saleid_log,code,logmark
create unique index index1 on saleid_log(code,logmark)
;

