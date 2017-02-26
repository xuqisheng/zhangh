
-------------------------------------------------------------------------------
--	sc_remark : 大备注 = Notes 
--		
--		有多个问题没有解决 
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "sc_remark")
   drop table sc_remark;
create table sc_remark
(
	accnt			char(30)								not null,			-- 主体对象=预订主单, event, activity 等.
	owner			char(10)		default ''			not null,  			-- accnt owner atrib 系统代码，用户不能 - basecode (sc_note_owner)
	type			char(10)		default ''			not null,  			-- 用户可以自由定义 - basecode (sc_note_type)
	id				int			default 0			not null,			-- 流水号. 同一个类型的备注可以输入多行
	inter			char(1)		default 'T'			not null,			-- 内部/外部 备注
	title			varchar(50)	default ''			not null,			-- 标题。
																					-- ? 感觉会增加操作繁琐，可能不需要? -- 暂时不用 
	remark		text			default ''			null,					-- 
	resby			char(10)		default ''			not null,			--	创建
	reserved		datetime		default getdate()	not null,
	cby			char(10)		default ''			not null,			-- 修改
	changed		datetime		default getdate()	not null,
	logmark		int			default 0			not null				-- ? 需要日志吗 -- 暂时不用 
)
exec sp_primarykey sc_remark,accnt,owner,id
create unique index index1 on sc_remark(accnt,owner,id)
;


-------------------------------------------------------------------------------
--	sc_master_hung 
--
--	宾客主单挂起.  一个帐号可能有多次记录，但是有效的只能有一个
-- 
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "sc_master_hung" and type = 'U')
	drop table sc_master_hung;
create table sc_master_hung
(
	accnt		char(10)								not null,
	mode		char(1)		default 'R'			not null,		-- R-rooms, C-catering 
   sta		char(1)								not null,	   -- 状态：Cancel=X, Lost=L, F=refused
   status	char(1)		default 'I'			not null,	   -- 状态 : I-有效, X-无效
	reason	char(3)								not null,
	remark	varchar(100) default ''			not null,
   phone		varchar(20)	default ''			not null,	   -- 电话
   priority	char(3)								not null,	   -- 优先级
	crtby		char(10)		default ''			not null,      -- 创建
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
   sta		char(1)								not null,	   -- 状态：Cancel=X, Lost=L, F=refused
   status	char(1)		default 'I'			not null,	   -- 状态 : I-有效, X-无效
	reason	char(3)								not null,
	remark	varchar(100) default ''			not null,
   phone		varchar(20)	default ''			not null,	   -- 电话
   priority	char(3)								not null,	   -- 优先级
	crtby		char(10)		default ''			not null,      -- 创建
   crttime	datetime		default getdate() not null
)
exec sp_primarykey sc_master_hhung,crttime
create unique index index1 on sc_master_hhung(crttime)
create index index2 on sc_master_hhung(accnt,mode,sta,status)
create index index3 on sc_master_hhung(reason,crttime)
;



-------------------------------------------------------------------------------
--	sc_ressta : 预订状态
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "sc_ressta")
   drop table sc_ressta;
create table sc_ressta
(
	code			char(10)									not null,			-- SC 预订状态
	descript		varchar(60)		default ''			not null,  			-- 描述
	descript1	varchar(60)		default ''			not null,  			-- 描述
	definite		char(1)			default 'F'			not null,			-- 确认状态
	starsv		char(1)			default 'R'			not null,			-- 占房状态
	stapre		varchar(200)	default ''			not null,			-- 上一个状态
	stanext		varchar(200)	default ''			not null,			-- 下一个状态
	sys			char(1)			default 'F'			not null,			--	系统代码
	halt			char(1)			default 'F'			not null,			-- 停用?
	sequence		int				default 0			not null,			-- 次序
	grp			varchar(16)		default ''   		not null,			-- 归类
	center		char(1)			default 'F'   		not null,				-- center code ?
   color       int            default 0         not null,
	resocp		char(1)			default 'T'			not null,
	forevt		char(1)			default 'T'			not null,
	starting		char(1)			default 'F'			not null,			-- 起始状态 
	allowpick	char(1)			default 'F'			not null,			-- 订单可以分房
	restype		char(3)			default ''			not null,			-- 缺省预订类型 restype 
	showdiary	char(1)			default 'F'			not null,			-- 状态图显示 
	reasontype	char(10)			default ''			not null, 			-- 理由类型-CANCEL, LOST, REFUSED 
	cby			char(10)			default ''			null,
	changed		datetime			default getdate() null 
);
exec sp_primarykey sc_ressta,code
create unique index index1 on sc_ressta(code);
INSERT INTO sc_ressta VALUES ('INQ','问讯','Inquiry','F','W','','TEN,DEF','T','F',100,'W','F',65535,'T','T','T','F','NOG','T','','',NULL);
INSERT INTO sc_ressta VALUES ('WAIT','候补','Waitlist','F','W','','TEN,DEF','T','F',200,'W','F',128,'T','T','T','F','NOG','T','','',NULL);
INSERT INTO sc_ressta VALUES ('TEN','不确定','Tentative','F','R','','DEF,LOS','T','F',300,'R','F',16776960,'T','T','F','F','NOG','T','','',NULL);
INSERT INTO sc_ressta VALUES ('DEF','确定','Definite','T','R','','CAN,NS,ACT','T','F',400,'R','F',65280,'T','T','F','T','6PM','T','','',NULL);
INSERT INTO sc_ressta VALUES ('CAN','取消','Cancelled','F','X','','','T','F',600,'X','F',0,'T','T','F','F','','F','CANCEL','',NULL);
INSERT INTO sc_ressta VALUES ('LOS','丢失','Lost','F','X','','','T','F',700,'X','F',0,'T','T','F','F','','F','LOST','',NULL);
INSERT INTO sc_ressta VALUES ('NS','No-Show','No Show','F','N','','','T','F',800,'X','F',0,'T','T','F','F','','F','CANCEL','',NULL);
INSERT INTO sc_ressta VALUES ('ACT','实际','Actual','T','I','','','T','F',1000,'R','F',16711935,'T','T','F','T','CIN','T','','',NULL);

---------------------------------------------------------------
--	团体订房变化记录  - 
---------------------------------------------------------------
if exists(select * from sysobjects where name = "sc_grpblk_trace")
   drop table sc_grpblk_trace;
create table sc_grpblk_trace
(
	date			datetime								not null,			-- 营业日期
	accnt			char(10)								not null,
	foact			char(10)		default ''			not null,
	sta			char(1)								not null,
	status		char(10)								null,				-- 
	c_status		char(10)		default ''			null,				-- 宴会状态
	rmnum			int			default 0			not null
)
exec sp_primarykey sc_grpblk_trace,date,accnt
create unique index index1 on sc_grpblk_trace(date,accnt)
;




