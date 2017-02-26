----------------------------------------------------------------
if not exists(select 1 from sysoption where catalog='reserve' and item='guest_card_calc')
	insert sysoption values ('reserve', 'guest_card_calc', 'FOX,POINT', '哪些guest_card是需要计算积分的。-- flag')

if not exists(select 1 from sysoption where catalog='vipcard' and item='exchange_rate')
	insert sysoption values ('vipcard', 'exchange_rate', '40', '积分兑换率（多少分算一块钱）');

-- 此项不再采用
--if not exists(select 1 from sysoption where catalog='vipcard' and item='no_match')
--	insert sysoption values ('vipcard', 'no_match', '^[^K]', '集团贵宾卡的卡号特征');
delete sysoption where catalog='vipcard' and item='no_match';

if not exists(select 1 from sysoption where catalog='hotel' and item='hotelid')    -- value = crs --> center
	insert sysoption values ('hotel', 'hotelid', 'XR', '成员酒店号');

if not exists(select 1 from sysoption where catalog='vipcard' and item='auto_no')
	insert sysoption values ('vipcard', 'auto_no', 'F', '自动产生贵宾卡号?');

if not exists(select 1 from sysoption where catalog='vipcard' and item='issue_mode')
	insert sysoption(catalog,item,value,remark) values( 'vipcard','issue_mode','STATUS', 'Vipcard Issue mode = STATUS / SINGLE / POOL ');

if not exists(select 1 from sysoption where catalog='vipcard' and item='query_grp_def')
	insert sysoption(catalog,item,value,remark) values( 'vipcard','query_grp_def','f', '读卡缺省是否勾-集团 ');

if not exists(select 1 from sysoption where catalog='vipcard' and item='lostcard_issue')
	insert sysoption(catalog,item,value,remark) values( 'vipcard','lostcard_issue','old', '挂失卡重新发卡，卡号如何处理呢？');
----------------------------------------------------------------



----------------------------------------------------------------


----------------------------------------------------------------
--	Table define 
--		vipcard, vipcard_log
--		vippoint, hvippoint
--		vipcard_type, 
--		vipptcode
--		vipdef1, vipdef2
--		vippack, vippack_def, vippack_set
--		datadown
--
----------------------------------------------------------------
--	vipcard -  卡号的集中管理
--		类型:	折扣卡	--->  可以对应AR账号,从而是记账卡
--						单位卡
--						个人卡
--				储值卡	
----------------------------------------------------------------
if exists(select * from sysobjects where name = "vipcard")
	drop table vipcard
;
create table vipcard
(
	no					char(20)								not null,	-- 卡号	
	sno				varchar(20)		default ''		not null,	-- 卡号(凸码),一般等于no. 兼容老系统
	mno				char(20)			default ''		not null,	-- 主卡号
	sta				char(1)			default 'I' 	not null,	-- 状态=I-有效,X-销卡,L-挂失,M-损坏,O-停用
	type				char(3)								not null,  	-- 类别  table=vipcard_type
	class				char(3)								not null,  	-- 系统类别  basecode=vipcard_class
	src				char(3)								not null,  	-- 系统类别  basecode=vipcard_src
	center			char(1)			default 'F'		not null,

	name		   	varchar(50)	 						not null,	 	-- 卡上姓名

	code1				varchar(60)		default ''		not null, 		-- 房价码串
	code2				varchar(30)		default ''		not null, 		-- 餐娱码串 
	code3				varchar(30)		default ''		not null, 		-- 备用 
	code4				varchar(30)		default ''		not null, 		-- 备用 
	code5				varchar(30)		default ''		not null, 		-- 备用 

	araccnt1			char(10)			default ''		null,			-- AR账号(前), 如果是打折卡可为空
	araccnt2			char(10)			default ''		null,			-- AR账号(后), 如果是打折卡可为空
	kno				char(7)			default ''		null,			-- 购买主体
	cno				char(7)			default ''		null,			-- 单位号(对应 guest)
	hno				char(7)			default ''		null,			-- 持卡人(对应 guest)

	arr				datetime								null,  		-- 有效日期
	dep				datetime								null,			-- 终止日期
	password			varchar(10)		default '' 		not null, 	-- for gaoliang
	pwd_q				varchar(30)		default ''		null,			-- 密码提示问题
	pwd_a				varchar(30)		default ''		null,			--	密码提示答案
	crc				varchar(20)		default '' 		not null, 	-- 系统生成的随机数
	extrainf			varchar(30)		default '' 		not null, 	-- for gaoliang
	postctrl			char(1)			default 'F' 	not null, 	-- 签单控制
	flag		   	varchar(40)	 	default ''		not null,	-- 标记

	limit				money				default 0	 	not null, 	-- 限额
	charge   		money       	DEFAULT 0	 	 NOT NULL,	-- 积分
	credit   		money       	DEFAULT 0	 	 NOT NULL,
	lastnumb 		int         	DEFAULT 0	 	 NOT NULL,

	fv_date			datetime								null,				-- 首次到店 
	fv_room			char(5)			default ''		not null,
	fv_rate			money				default 0		not null,
	lv_date			datetime								null,				-- 上次到店 
	lv_room			char(5)			default ''		not null,
	lv_rate			money				default 0		not null,

   i_times			integer			default 0 		not null,		-- 住店次数 
   x_times			integer			default 0 		not null,		-- 取消预订次数 
   n_times			integer			default 0 		not null,		-- 应到未到次数 
   l_times			integer			default 0 		not null,		-- 其它次数 
   i_days			integer			default 0 		not null,		-- 住店天数 

   fb_times1		integer			default 0 		not null,		-- 餐饮次数 
   en_times2		integer			default 0 		not null,		-- 娱乐次数 

   rm					money 			default 0 		not null, 		-- 房租收入
   fb					money 			default 0 		not null, 		-- 餐饮收入
   en					money 			default 0 		not null, 		-- 娱乐收入
   mt					money 			default 0 		not null, 		-- 会议收入
   ot					money 			default 0 		not null, 		-- 其它收入
   tl					money 			default 0 		not null, 		-- 总收入  

	hotelid			varchar(20)		default ''		not null,   -- Hotel ID.
	saleid		   varchar(50)	 	default ''		not null,	-- 销售员
	resby				char(10)			default ''		not null,	-- 建立工号  
	reserved			datetime								null,	
	ciby				char(10)			default ''		not null,	-- 发行工号  
	citime			datetime								null,	
	cby				char(10)			default ''		not null,	-- 修改工号  
	changed			datetime								null,			
	ref				varchar(255)						null,			-- 备注
	exp_s1			varchar(20)							null,
	exp_s2			varchar(20)							null,
	exp_s3			varchar(20)							null,
	exp_s4			varchar(20)							null,
	exp_s5			varchar(20)							null,
	exp_s6			varchar(64)							null,
	exp_s7			varchar(64)							null,
	exp_s8			varchar(64)							null,
	exp_s9			varchar(64)							null,
	exp_s0			varchar(64)							null,
	exp_m1			money									null,
	exp_m2			money									null,
	exp_m3			money									null,
	exp_dt1			datetime								null,
	exp_dt2			datetime								null,
	exp_dt3			datetime								null,
	logmark			integer			default 0 		not null
)
exec sp_primarykey vipcard, no
create unique index index1 on vipcard(no)
create index index2 on vipcard(sno)
;

-----------------------------
--	vipcard_log
-----------------------------
if exists(select * from sysobjects where name = "vipcard_log")
	drop table vipcard_log;
create table vipcard_log
(
	no					char(20)								not null,	-- 卡号	
	sno				varchar(20)		default ''		not null,	-- 卡号(凸码),一般等于no. 兼容老系统
	mno				char(20)			default ''		not null,	-- 主卡号
	sta				char(1)			default 'I' 	not null,	-- 状态=I-有效,X-销卡,L-挂失,M-损坏,O-停用
	type				char(3)								not null,  	-- 类别  table=vipcard_type
	class				char(3)								not null,  	-- 系统类别  basecode=vipcard_class
	src				char(3)								not null,  	-- 系统类别  basecode=vipcard_src
	center			char(1)			default 'F'		not null,

	name		   	varchar(50)	 						not null,	 	-- 卡上姓名

	code1				varchar(60)		default ''		not null, 		-- 房价码串
	code2				varchar(30)		default ''		not null, 		-- 餐娱码串 
	code3				varchar(30)		default ''		not null, 		-- 备用 
	code4				varchar(30)		default ''		not null, 		-- 备用 
	code5				varchar(30)		default ''		not null, 		-- 备用 

	araccnt1			char(10)			default ''		null,			-- AR账号(前), 如果是打折卡可为空
	araccnt2			char(10)			default ''		null,			-- AR账号(后), 如果是打折卡可为空
	kno				char(7)			default ''		null,			-- 购买主体
	cno				char(7)			default ''		null,			-- 单位号(对应 guest)
	hno				char(7)			default ''		null,			-- 持卡人(对应 guest)

	arr				datetime								null,  		-- 有效日期
	dep				datetime								null,			-- 终止日期
	password			varchar(10)		default '' 		not null, 	-- for gaoliang
	pwd_q				varchar(30)		default ''		null,			-- 密码提示问题
	pwd_a				varchar(30)		default ''		null,			--	密码提示答案
	crc				varchar(20)		default '' 		not null, 	-- 系统生成的随机数
	extrainf			varchar(30)		default '' 		not null, 	-- for gaoliang
	postctrl			char(1)			default 'F' 	not null, 	-- 签单控制
	flag		   	varchar(40)	 	default ''		not null,	-- 标记

	limit				money				default 0	 	not null, 	-- 限额
	charge   		money       	DEFAULT 0	 	 NOT NULL,	-- 积分
	credit   		money       	DEFAULT 0	 	 NOT NULL,
	lastnumb 		int         	DEFAULT 0	 	 NOT NULL,

	fv_date			datetime								null,				-- 首次到店 
	fv_room			char(5)			default ''		not null,
	fv_rate			money				default 0		not null,
	lv_date			datetime								null,				-- 上次到店 
	lv_room			char(5)			default ''		not null,
	lv_rate			money				default 0		not null,

   i_times			integer			default 0 		not null,		-- 住店次数 
   x_times			integer			default 0 		not null,		-- 取消预订次数 
   n_times			integer			default 0 		not null,		-- 应到未到次数 
   l_times			integer			default 0 		not null,		-- 其它次数 
   i_days			integer			default 0 		not null,		-- 住店天数 

   fb_times1		integer			default 0 		not null,		-- 餐饮次数 
   en_times2		integer			default 0 		not null,		-- 娱乐次数 

   rm					money 			default 0 		not null, 		-- 房租收入
   fb					money 			default 0 		not null, 		-- 餐饮收入
   en					money 			default 0 		not null, 		-- 娱乐收入
   mt					money 			default 0 		not null, 		-- 会议收入
   ot					money 			default 0 		not null, 		-- 其它收入
   tl					money 			default 0 		not null, 		-- 总收入  

	hotelid			varchar(20)		default ''		not null,   -- Hotel ID.
	saleid		   varchar(50)	 	default ''		not null,	-- 销售员
	resby				char(10)			default ''		not null,	-- 建立工号  
	reserved			datetime								null,	
	ciby				char(10)			default ''		not null,	-- 发行工号  
	citime			datetime								null,	
	cby				char(10)			default ''		not null,	-- 修改工号  
	changed			datetime								null,			
	ref				varchar(255)						null,			-- 备注
	exp_s1			varchar(20)							null,
	exp_s2			varchar(20)							null,
	exp_s3			varchar(20)							null,
	exp_s4			varchar(20)							null,
	exp_s5			varchar(20)							null,
	exp_s6			varchar(64)							null,
	exp_s7			varchar(64)							null,
	exp_s8			varchar(64)							null,
	exp_s9			varchar(64)							null,
	exp_s0			varchar(64)							null,
	exp_m1			money									null,
	exp_m2			money									null,
	exp_m3			money									null,
	exp_dt1			datetime								null,
	exp_dt2			datetime								null,
	exp_dt3			datetime								null,
	logmark			integer			default 0 		not null
)
exec sp_primarykey vipcard_log, no, logmark
create unique index index1 on vipcard_log(no, logmark)
;


// lgfl_des for vipcard 
delete lgfl_des where columnname like 'v_%';

insert lgfl_des(columnname,descript,descript1,tag) select 'v_sta','状态','Status','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_sno','自编码','Hand No','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_class','类别','Class','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_type','类别1','Type','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_code1','房价码','Ratecode','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_code2','POS模式','POS Mode','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_araccnt1','AR账号','AR# 1','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_araccnt2','AR账号2','AR# 2','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_name','描述','Name','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_cno','单位','Comp.','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_hno','客人','Profile','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_arr','到达','Arr.','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_dep','离开','Dep.','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_password','密码','Password','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_extrainf','附加信息','Extra','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_postctrl','签单控制','Post Ctrl.','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_limit','信用限额','LImit','V';
insert lgfl_des(columnname,descript,descript1,tag) select 'v_ref','备注','Remark','V';


if exists(select * from sysobjects where type ="U" and name = "vippoint")
   drop table vippoint;
create table vippoint
(
	no				char(20)		not null,							/* 卡号 */
	number		integer		not null,							/* 物理序列号,每个账号分别从1开始 */
	log_date		datetime		default getdate() not null,	/* 生成日期 */
	hotelid		varchar(20)	default '' not null,				/* 成员酒店号 */
	bdate			datetime		not null,							/* 营业日期 */
	expiry_date	datetime		default getdate() not null,	/* 积分有效期 */
	quantity		money			default 0 not null,				/* 数量 */
	charge		money			default 0 not null,				/* 借方数,记录客人消费 */
	credit		money			default 0 not null,				/* 贷方数,记录客人定金及结算款 */
	balance		money			default 0 not null,				/* 新加字段 */
	fo_modu_id	char(2)		not null,							/* 模块号 */
	fo_accnt		char(10)		default '' not null,				/* 获得(使用)积分的前台账号 */
	fo_number	integer		default 0 not null,				/* 使用积分的前台账次 */		
	fo_billno	char(10)		default '' not null,				/* 使用积分的前台结帐单号 */
	
	m1				money			default 0	not null,			// 房费 / 消费金额
	m2				money			default 0	not null,			// 餐费 / 成本金额
	m3				money			default 0	not null,			// 其他 / 兑换比率
	m4				money			default 0	not null,
	m5				money			default 0	not null,
	m9				money			default 0	not null,
	calc			varchar(10)	default ''	not null,			/* 计算规则 */

	shift			char(1)		not null,							/* 操作员班号 */
	empno			char(10)		not null,							/* 操作员工号 */
	tag			char(3)		null,									/* 标志 */

	ref			char(24)		default '' null,					/* 费用（账务）描述 */
	ref1			char(10)		default '' null,					/* 单号 */
	ref2			char(50)		default '' null,					/* 摘要 */

	empno0		char(10)						null,					/* 分账（工号） */
	date0			datetime						null,					/* 分账（时间） */
	shift0		char(1)						null,					/* 分账（班号） */
	mode1			char(10)						null,					/* 稽核用 */
	pnumber		integer		default 0 	null,					/* 同一个包的号码与第一条的inumber相同 */
	package		char(3)						null,					/* 分账标志 */

	localok		char(1)		default 'T'	not null,
	sendout		char(1)		default 'F'	not null,

	exp_s1		varchar(20)	default ''	null,
	exp_s2		varchar(20)	default ''	null,
	exp_s3		varchar(20)	default ''	null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null

)
;
exec   sp_primarykey vippoint, no, number
create unique index index1 on vippoint(no, number)
create index index2 on vippoint(bdate)
;



if exists(select * from sysobjects where type ="U" and name = "hvippoint")
   drop table hvippoint;
create table hvippoint
(
	no				char(20)		not null,							/* 卡号 */
	number		integer		not null,							/* 物理序列号,每个账号分别从1开始 */
	log_date		datetime		default getdate() not null,	/* 生成日期 */
	hotelid		varchar(20)	default '' not null,				/* 成员酒店号 */
	bdate			datetime		not null,							/* 营业日期 */
	expiry_date	datetime		default getdate() not null,	/* 积分有效期 */
	quantity		money			default 0 not null,				/* 数量 */
	charge		money			default 0 not null,				/* 借方数,记录客人消费 */
	credit		money			default 0 not null,				/* 贷方数,记录客人定金及结算款 */
	balance		money			default 0 not null,				/* 新加字段 */
	fo_modu_id	char(2)		not null,							/* 模块号 */
	fo_accnt		char(10)		default '' not null,				/* 获得(使用)积分的前台账号 */
	fo_number	integer		default 0 not null,				/* 使用积分的前台账次 */		
	fo_billno	char(10)		default '' not null,				/* 使用积分的前台结帐单号 */
	
	m1				money			default 0	not null,
	m2				money			default 0	not null,
	m3				money			default 0	not null,
	m4				money			default 0	not null,
	m5				money			default 0	not null,
	m9				money			default 0	not null,
	calc			varchar(10)	default ''	not null,			/* 计算规则 */

	shift			char(1)		not null,							/* 操作员班号 */
	empno			char(10)		not null,							/* 操作员工号 */
	tag			char(3)		null,									/* 标志 */

	ref			char(24)		default '' null,					/* 费用（账务）描述 */
	ref1			char(10)		default '' null,					/* 单号 */
	ref2			char(50)		default '' null,					/* 摘要 */

	empno0		char(10)						null,					/* 分账（工号） */
	date0			datetime						null,					/* 分账（时间） */
	shift0		char(1)						null,					/* 分账（班号） */
	mode1			char(10)						null,					/* 稽核用 */
	pnumber		integer		default 0 	null,					/* 同一个包的号码与第一条的inumber相同 */
	package		char(3)						null,					/* 分账标志 */

	localok		char(1)		default 'T'	not null,
	sendout		char(1)		default 'F'	not null,

	exp_s1		varchar(20)	default ''	null,
	exp_s2		varchar(20)	default ''	null,
	exp_s3		varchar(20)	default ''	null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null

)
;
exec   sp_primarykey hvippoint, no, number
create unique index index1 on hvippoint(no, number)
create index index2 on hvippoint(bdate)
;


------------------------------------------------------
--	贵宾卡类别
------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "vipcard_type")
   drop table vipcard_type;
create table vipcard_type
(
	code			char(3)			not null,					
	descript		varchar(50)	default ''	not null,
	descript1	varchar(50)	default '' not null,	
	calc			char(10)		default '' not null,	   -- vipptcode
	guestcard	char(10)		default '' not null,		 -- guest_card_type 
	mustread		char(1)		default 'F'	not null,
	center		char(1)		default 'F'	not null,
	halt      	char(1)     DEFAULT 'F' NOT NULL,		
	issmode		char(10)		DEFAULT 'STATUS' NOT NULL,    --  发行模式 STATUS / SINGLE / POOL 
	sequence		int			default 0 	not null
);
EXEC sp_primarykey 'vipcard_type', code;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON vipcard_type(code)
CREATE UNIQUE NONCLUSTERED INDEX index3 ON vipcard_type(guestcard)
CREATE UNIQUE NONCLUSTERED INDEX index2 ON vipcard_type(descript)
;
insert vipcard_type values( 'A', '金陵贵宾会员', 'Jinling Elite Membership', '0', 'JL1', 'T', 'F', 'F', 10);
insert vipcard_type values( 'B', '金陵金卡贵宾会员', 'Jinling Gold Membership', '0', 'JL2', 'T', 'F', 'F', 20);
insert vipcard_type values( 'C', '金陵铂金卡贵宾会员', 'Jinling Platinum Membership', '0', 'JL3', 'T', 'F', 'F', 30);


------------------------------------------------------
--	积分计算代码
------------------------------------------------------
if object_id('vipptcode') is not null
	drop table vipptcode;
CREATE TABLE vipptcode 
(
    code      char(10)    NOT NULL,						// 返佣码编号
    descript  varchar(60) NOT NULL,						// 中文描述
    descript1 varchar(60) NOT NULL,						// 英文描述
    halt      char(1)     DEFAULT 'F' NOT NULL,		// 停用标志    T －停用  F － 否 
	sequence		int		default 0 	not null
);
EXEC sp_primarykey 'vipptcode', code;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON vipptcode(code)
CREATE UNIQUE NONCLUSTERED INDEX index2 ON vipptcode(descript)
;
insert vipptcode values('0', '普通', 'Nomal', 'F', 100);
insert vipptcode values('1', '贵宾', 'Vip', 'F', 200);

------------------------------------------------------
--	积分计算代码 - items
------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "vipdef1")
   drop table vipdef1;
create table vipdef1
(
	code			char(10)			not null,							/* 积分计算代码 */
	pccode		varchar(5)		not null,							/* 费用码 */
	base			money				default 1 not null,				/* 起步 */
	step			money				default 1 not null,				/* 步长 */
	rate			money				default 0 not null,				/* 消费、积分的换算率 */
	cby			char(10)			not null,							/* 用户名 */
	changed		datetime			default getdate() not null,	/* 修改时间 */
)
;
exec   sp_primarykey vipdef1, code, pccode
create unique index index1 on vipdef1(code, pccode)
;

insert vipdef1(code,pccode,base,step,rate,cby,changed)
	select a.code, b.pccode, 1, 1, 1, 'FOX', getdate() 
		from vipptcode a, pccode b where b.pccode < '9';
update vipdef1 set rate=1.209 where code='0';
update vipdef1 set rate=1.451 where code='1';

------------------------------------------------------
--	积分计算 时间关联
------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "vipdef2")
   drop table vipdef2;
create table vipdef2
(
	type			char(1)			not null,							/* 类别B:生日;D:DATETYPE;U:用户自定义 */
	code			char(1)			not null,							/* 费用码 */
	descript		varchar(50)		null,									/* 描述 */
	descript1	varchar(50)		null,									/* 描述 */
	starting		datetime			null,									/* 开始日期 */
	ending		datetime			null,									/* 截至日期 */
	rate			money				default 1 not null,				/* 消费、积分的换算率 */
	cby			char(10)			not null,							/* 用户名 */
	changed		datetime			default getdate() not null,	/* 修改时间 */
)
;
exec   sp_primarykey vipdef2, type, code, starting, ending
create unique index index1 on vipdef2(type, code, starting, ending)
;
insert vipdef2 values('B', '', '生日', 'Birthday', null, null, 1, 'FOX', getdate());
insert vipdef2 select 'D', code, descript, descript1, null, null, 1, 'FOX', getdate() from rmrate_factor;


--------------------------------------------------------------------------
-- 贵宾卡 包价代码
--------------------------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "vippack")
   drop table vippack
;
create table vippack
(
	code			char(10)						not null,
	cat			char(10)		default ''	not null,
	descript		varchar(50)	default ''	null,
	descript1	varchar(50)	default ''	null,
	begin_		datetime						null,
	end_			datetime						null,
	rate			money			default 0	not null,
	point			int			default 0	not null,
	hotelcat		varchar(20)	default ''	not null,
	hotelid		varchar(100)	default ''	not null,   -- ???
	remark		varchar(255) default '' not null,
	halt			char(1)		default 'F'	not null,
	sequence		int			default 0	not null,
	cby			char(10)						not null,
	changed		datetime		default getdate() not null,
	logmark		int			default 0	not null
)
exec   sp_primarykey vippack, code
create unique index index1 on vippack(code)
;

--------------------------------------------------------------------------
--  basecode : vippack_item  -- 中国 姓
--------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vippack_item')
	delete basecode_cat where cat='vippack_item';
insert basecode_cat(cat,descript,descript1,len) 
	select 'vippack_item', '贵宾卡包价项目', 'Vipcard Packages Items', 10;
delete basecode where cat='vippack_item';
insert basecode(cat,code,descript,descript1) values('vippack_item', 'RateCode', '房价码', 'Rate Code');
insert basecode(cat,code,descript,descript1) values('vippack_item', 'PosMode', 'POS 模式', 'POS Mode');
insert basecode(cat,code,descript,descript1) values('vippack_item', 'Points', '积分', 'Points');
insert basecode(cat,code,descript,descript1) values('vippack_item', 'RoomNights', '房晚', 'Room Nights');
insert basecode(cat,code,descript,descript1) values('vippack_item', 'SpoTimes', '康乐次数', 'SPO Times');

--------------------------------------------------------------------------
-- 贵宾卡 包价代码 定义
--------------------------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "vippack_def")
   drop table vippack_def
;
create table vippack_def
(
	code			char(10)						not null,
	id				int			default 0	not null,
	item			char(10)						not null,   -- RateCode, PosMode, Points, RoomNights,SpoTimes, 
	value1		varchar(30)	default ''	not null,	-- 项目值：字符型
	value2		money			default 0	not null,	-- 项目值：数字型
	begin_		datetime						null,			-- 有效期间开始
	valid			char(10)		default ''	not null,	-- 有效期长度 = Y1, M3, D15, 2004/12/12
	limit			varchar(100) default ''	null,			-- 限制说明
	remark		varchar(255) default ''	null,
	sequence		int			default 0	not null
)
exec   sp_primarykey vippack_def, code, id
create unique index index1 on vippack_def(code, id)
;

--------------------------------------------------------------------------
-- 贵宾卡 包价定义
--------------------------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "vippack_set")
   drop table vippack_set
;
create table vippack_set
(
	no				char(20)						not null,	-- 卡号	
	code			char(10)						not null,
	id				int			default 0	not null,
	item			char(10)						not null,   -- RateCode, PosMode, Points, RoomNights,SpoTimes, 
	value1		varchar(30)	default ''	not null,	-- 项目值：字符型
	value2		money			default 0	not null,	-- 项目值：数字型
	begin_		datetime						null,			-- 有效期间开始
	valid			char(10)		default ''	not null,	-- 有效期长度 = Y1, M3, D15, 2004/12/12
	limit			varchar(100) default ''	null,			-- 限制说明
	remark		varchar(255) default ''	null,
	sequence		int			default 0	not null
)
exec   sp_primarykey vippack_set, no, code, id
create unique index index1 on vippack_set(no, code, id)
;

----------------------------------------------------------------
--	数据传输纪录 == 中央 -〉酒店
----------------------------------------------------------------
if exists(select * from sysobjects where name = "datadown")
	drop table datadown
;
create table datadown
(
	date				datetime								not null,
	type				char(20)								not null,	-- 卡号	
	no					varchar(20)		default ''		not null,	-- 卡号(凸码),一般等于no. 兼容老系统
	empno				char(10)			default ''		not null,	-- 修改工号  
	remark			varchar(20)							null	
)
exec sp_primarykey datadown, date, type, no
create unique index index1 on datadown(date, type, no)
create index index2 on datadown(no)
;

----------------------------------------------------------------
--	制卡池
----------------------------------------------------------------
if exists(select * from sysobjects where name = "vipcard_pool")
	drop table vipcard_pool
;
create table vipcard_pool
(
	type				char(10)								not null,
	pc_id				char(4)								not null,
	no					char(20)								not null
)
exec sp_primarykey vipcard_pool, type, pc_id, no
create unique index index1 on vipcard_pool(type, pc_id, no)
;

----------------------------------------------------------------
--	本地贵宾卡远程记账撤销
----------------------------------------------------------------
if exists(select * from sysobjects where name = "vipcocar")
	drop table vipcocar
;
create table vipcocar
(
	id					char(10)								not null,
	cardno			char(20)								not null,	-- 卡号 vipcard.no
	cardtype			char(10)								not null,	-- 卡类 vipcard.guestcard
	cardar			char(10)								not null,	-- 		vipcard.araccnt1
	bdate				datetime								not null,
	modu_id			char(2)								not null,
	acttype			char(10)			default ''		not null,	-- 帐务类型 F(ront), B(os), P(os)
	accnt				char(10)								not null,	--	账号
	number			int				default 0		not null,	-- 帐次
	code				char(10)			default ''		not null,	-- 付款代码 eg. bos_account
	amount			money				default 0		not null,	
	empno				char(10)			default ''		not null,	-- 撤销工号
	shift				char(1)			default ''		not null,
	log_date			datetime								null,			-- 撤销时间
	sendout			char(1)			default 'F'		not null,	-- 已经与中央同步？
	sendby			char(10)			default ''		not null,
	sendshift		char(1)			default ''		not null,
	sendtime			datetime								null
)
exec sp_primarykey vipcocar,id
create unique index index1 on vipcocar(id)
create unique index index2 on vipcocar(cardno,cardtype,acttype,accnt,number,code)
;


----------------------------------------------------------------
--	换卡发行，转账纪录
----------------------------------------------------------------
if exists(select * from sysobjects where name = "vipcard_tranlog")
	drop table vipcard_tranlog
;
create table vipcard_tranlog
(
	no					varchar(20)		default ''		not null,
	number			int				default 0		not null,
	no1				varchar(20)		default ''		not null,
	number1			int				default 0		not null,
	empno				char(10)			default ''		not null,
	logdate			datetime								not null
)
exec sp_primarykey vipcard_tranlog, no, number
create unique index index1 on vipcard_tranlog(no, number)
;
