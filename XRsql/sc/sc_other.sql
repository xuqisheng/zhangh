
-------------------------------------------------------------------------------
--	sc_remark : ��ע = Notes 
--		
--		�ж������û�н�� 
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "sc_remark")
   drop table sc_remark;
create table sc_remark
(
	accnt			char(30)								not null,			-- �������=Ԥ������, event, activity ��.
	owner			char(10)		default ''			not null,  			-- accnt owner atrib ϵͳ���룬�û����� - basecode (sc_note_owner)
	type			char(10)		default ''			not null,  			-- �û��������ɶ��� - basecode (sc_note_type)
	id				int			default 0			not null,			-- ��ˮ��. ͬһ�����͵ı�ע�����������
	inter			char(1)		default 'T'			not null,			-- �ڲ�/�ⲿ ��ע
	title			varchar(50)	default ''			not null,			-- ���⡣
																					-- ? �о������Ӳ������������ܲ���Ҫ? -- ��ʱ���� 
	remark		text			default ''			null,					-- 
	resby			char(10)		default ''			not null,			--	����
	reserved		datetime		default getdate()	not null,
	cby			char(10)		default ''			not null,			-- �޸�
	changed		datetime		default getdate()	not null,
	logmark		int			default 0			not null				-- ? ��Ҫ��־�� -- ��ʱ���� 
)
exec sp_primarykey sc_remark,accnt,owner,id
create unique index index1 on sc_remark(accnt,owner,id)
;


-------------------------------------------------------------------------------
--	sc_master_hung 
--
--	������������.  һ���ʺſ����ж�μ�¼��������Ч��ֻ����һ��
-- 
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "sc_master_hung" and type = 'U')
	drop table sc_master_hung;
create table sc_master_hung
(
	accnt		char(10)								not null,
	mode		char(1)		default 'R'			not null,		-- R-rooms, C-catering 
   sta		char(1)								not null,	   -- ״̬��Cancel=X, Lost=L, F=refused
   status	char(1)		default 'I'			not null,	   -- ״̬ : I-��Ч, X-��Ч
	reason	char(3)								not null,
	remark	varchar(100) default ''			not null,
   phone		varchar(20)	default ''			not null,	   -- �绰
   priority	char(3)								not null,	   -- ���ȼ�
	crtby		char(10)		default ''			not null,      -- ����
   crttime	datetime		default getdate() not null
)
exec sp_primarykey sc_master_hung,crttime
create unique index index1 on sc_master_hung(crttime)
create index index2 on sc_master_hung(accnt,mode,sta,status)
create index index3 on sc_master_hung(reason,crttime)
;

if exists(select * from sysobjects where name = "sc_master_hhung" and type = 'U')
	drop table sc_master_hhung;
create table sc_master_hhung
(
	accnt		char(10)								not null,
	mode		char(1)		default 'R'			not null,		-- R-rooms, C-catering 
   sta		char(1)								not null,	   -- ״̬��Cancel=X, Lost=L, F=refused
   status	char(1)		default 'I'			not null,	   -- ״̬ : I-��Ч, X-��Ч
	reason	char(3)								not null,
	remark	varchar(100) default ''			not null,
   phone		varchar(20)	default ''			not null,	   -- �绰
   priority	char(3)								not null,	   -- ���ȼ�
	crtby		char(10)		default ''			not null,      -- ����
   crttime	datetime		default getdate() not null
)
exec sp_primarykey sc_master_hhung,crttime
create unique index index1 on sc_master_hhung(crttime)
create index index2 on sc_master_hhung(accnt,mode,sta,status)
create index index3 on sc_master_hhung(reason,crttime)
;



-------------------------------------------------------------------------------
--	sc_ressta : Ԥ��״̬
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "sc_ressta")
   drop table sc_ressta;
create table sc_ressta
(
	code			char(10)									not null,			-- SC Ԥ��״̬
	descript		varchar(60)		default ''			not null,  			-- ����
	descript1	varchar(60)		default ''			not null,  			-- ����
	definite		char(1)			default 'F'			not null,			-- ȷ��״̬
	starsv		char(1)			default 'R'			not null,			-- ռ��״̬
	stapre		varchar(200)	default ''			not null,			-- ��һ��״̬
	stanext		varchar(200)	default ''			not null,			-- ��һ��״̬
	sys			char(1)			default 'F'			not null,			--	ϵͳ����
	halt			char(1)			default 'F'			not null,			-- ͣ��?
	sequence		int				default 0			not null,			-- ����
	grp			varchar(16)		default ''   		not null,			-- ����
	center		char(1)			default 'F'   		not null,				-- center code ?
   color       int            default 0         not null,
	resocp		char(1)			default 'T'			not null,
	forevt		char(1)			default 'T'			not null,
	starting		char(1)			default 'F'			not null,			-- ��ʼ״̬ 
	allowpick	char(1)			default 'F'			not null,			-- �������Էַ�
	restype		char(3)			default ''			not null,			-- ȱʡԤ������ restype 
	showdiary	char(1)			default 'F'			not null,			-- ״̬ͼ��ʾ 
	reasontype	char(10)			default ''			not null, 			-- ��������-CANCEL, LOST, REFUSED 
	cby			char(10)			default ''			null,
	changed		datetime			default getdate() null 
);
exec sp_primarykey sc_ressta,code
create unique index index1 on sc_ressta(code);
INSERT INTO sc_ressta VALUES ('INQ','��Ѷ','Inquiry','F','W','','TEN,DEF','T','F',100,'W','F',65535,'T','T','T','F','NOG','T','','',NULL);
INSERT INTO sc_ressta VALUES ('WAIT','��','Waitlist','F','W','','TEN,DEF','T','F',200,'W','F',128,'T','T','T','F','NOG','T','','',NULL);
INSERT INTO sc_ressta VALUES ('TEN','��ȷ��','Tentative','F','R','','DEF,LOS','T','F',300,'R','F',16776960,'T','T','F','F','NOG','T','','',NULL);
INSERT INTO sc_ressta VALUES ('DEF','ȷ��','Definite','T','R','','CAN,NS,ACT','T','F',400,'R','F',65280,'T','T','F','T','6PM','T','','',NULL);
INSERT INTO sc_ressta VALUES ('CAN','ȡ��','Cancelled','F','X','','','T','F',600,'X','F',0,'T','T','F','F','','F','CANCEL','',NULL);
INSERT INTO sc_ressta VALUES ('LOS','��ʧ','Lost','F','X','','','T','F',700,'X','F',0,'T','T','F','F','','F','LOST','',NULL);
INSERT INTO sc_ressta VALUES ('NS','No-Show','No Show','F','N','','','T','F',800,'X','F',0,'T','T','F','F','','F','CANCEL','',NULL);
INSERT INTO sc_ressta VALUES ('ACT','ʵ��','Actual','T','I','','','T','F',1000,'R','F',16711935,'T','T','F','T','CIN','T','','',NULL);

---------------------------------------------------------------
--	���嶩���仯��¼  - 
---------------------------------------------------------------
if exists(select * from sysobjects where name = "sc_grpblk_trace")
   drop table sc_grpblk_trace;
create table sc_grpblk_trace
(
	date			datetime								not null,			-- Ӫҵ����
	accnt			char(10)								not null,
	foact			char(10)		default ''			not null,
	sta			char(1)								not null,
	status		char(10)								null,				-- 
	c_status		char(10)		default ''			null,				-- ���״̬
	rmnum			int			default 0			not null
)
exec sp_primarykey sc_grpblk_trace,date,accnt
create unique index index1 on sc_grpblk_trace(date,accnt)
;




