// ------------------------------------------------------------------------------
//		BOS 库存管理表定义
//
//			bos_pccode
//
//			bos_provider			
//
//			bos_site
//			bos_site_sort
//
//			bos_kcmenu
//			bos_kcdish
//			bos_store
//			bos_hstore
//
//			bos_detail
//			bos_hdetail
//			bos_tmpdetail 
// ------------------------------------------------------------------------------
//		经销  &  代销 ：本质区别-- 代销可以修改成本价 !
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------
//	bos_pccode	:  BOS 营业点定义
// ------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "bos_pccode")
	drop table bos_pccode;
create table bos_pccode
(
	pccode		char(5)					not null,
	descript		varchar(24)				not null,
	descript1	varchar(24)				not null,
	sortlen		int default 2 			not null,	// 菜谱类别码的长度
	site			int default 0  		not null,  	// 是否有地点的管理: 0-无; 1-客房; 2-其他
	jxc			int default 0  		not null,  	// 是否有进销存管理: 0-no, 1-yes
	smode			char(1)	default '%' not null,	// 服务费   -- 却省值
	svalue		money		default 0 	not null,
	tmode			char(1)	default '%' not null,	// 附加费
	tvalue		money		default 0 	not null,
	dmode			char(1)	default '%' not null,	// 折扣
	dvalue		money		default 0 	not null,
	site0			char(5)	 				not null,	// 却省的地点
	tag			char(1)	default ''	not null,	// S=shop
	chgcod		char(5)					not null,		//  code in pccode
	flag			char(10)	default '00' not null,	-- 计算模式 第一位=服务费 第二位=折扣 0-计算不包含附加费, 1-计算包含附加费
	sequence		int		default 0	not null
)
exec sp_primarykey bos_pccode, pccode
create unique index index1 on bos_pccode(pccode)
create unique index index2 on bos_pccode(chgcod)
;
//insert bos_pccode
//	select pccode, descript1, descript2, 2, 0, 0,'%',0,'%',0,'%',0,pccode,'' from chgcod 
//		where charindex(modu, '03/09/06')>0 and servcode is null;
//select * from bos_pccode;


// ------------------------------------------------------------------------------------
// bos_provider ----- 供应商代码
// ------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "bos_provider")
	drop table bos_provider;
create table bos_provider
(
	accnt			char(7)		not null,			//帐号:主键
	sta			char(1)		not null,			//状态 I, O, 
	nation      char(3) 		not null,       	//国籍
	name			varchar(50)	not null,			//名称
	address  	varchar(60)	null,					//地址
	phone			varchar(30)	null,					//电话
	fax  			varchar(20)	null,					//传真
	zip  			char(10)		null,					//邮编
	c_name		varchar(40)	null,					//联系人
	intinfo		varchar(50)	null,					//互联网信息
	class			char(1)		null,					//级别:
	locksta     char(1)     null,       		//信用状态
	limit			money			default 0 	not null,	//限额(催帐用)
	arr			datetime		null,					//生效日期
	dep			datetime		null,					//有效日期,到明日为止
   mkt     		char(5)     null,       		//市场码
	pccodes		varchar(20)	default '' not null,  //费用码范围
	resby			char(10)		not null,					//建立人工号
	reserved		datetime	default getdate() not null, //建立时间,用系统时间,不可修改
	cby			char(10)		null,							//修改人工号
	changed		datetime		null,							//修改时间
	ref			varchar(90)	null,							//备注
	exp_m			money				null,
	exp_dt		datetime			null,
	exp_s			varchar(10)		null,
	logmark     int default 0 not null
);
exec sp_primarykey bos_provider,accnt
create unique index index1 on bos_provider(accnt)
create index index2 on bos_provider(name)
;


//------------------------------------------------------------------------------
// 地点码 -- 仓库，柜台，其他部门 等
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_site')
	drop table bos_site;
create table  bos_site (
	pccode	char(5)			not null,
	tag		char(2)			not null, 			// 类别:仓(仓库) - 柜(柜台) - 部(内部部门)
	site		char(5)			not null,  			// --- 注意： 内部部门本来与 pccode 无关，但是
	descript		varchar(24)		not null,		//  	有可能分开编辑可能更好，
	descript1	varchar(24)		not null			//		此时最好统一部门在不同的pccode 中，site 一致
)
exec sp_primarykey bos_site,site
create unique index site on bos_site(site);
insert bos_site select pccode, '仓', pccode, descript, descript1 from bos_pccode;


//------------------------------------------------------------------------------
// 地点的售货定义：定义该地点能够出售什么物品 
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_site_sort')
	drop table bos_site_sort;
create table  bos_site_sort (
	site		char(5)			not null,
	sort		varchar(20)	default '%' not null
);
exec sp_primarykey bos_site_sort,site,sort
create unique index site on bos_site_sort(site,sort)
;
insert bos_site_sort select site,'%' from bos_site;

//------------------------------------------------------------------------------
//		
//		物品流动单据主库  ------- 当前
//		主单类型: 入<出>库, 损耗, 冲销, 盘存, 调拨
//
//		这里的单据号码由电脑单号和手工单号组成
//			单据只能“建立”和“冲销当日”，所以不需要LOG字段
//			冲销单据时,改变状态,填满冲销字段即可;
//
//------------------------------------------------------------------------------

// 主表
if exists (select 1 from sysobjects where name = 'bos_kcmenu')
	drop table bos_kcmenu
;
create table  bos_kcmenu (
	folio		char(10)			not null,				// 电脑单号(日期+流水号)
	pccode 	char(5)			not null,
	sfolio	varchar(20),								// 手工号码
	site0		char(5)			not null,				// 原始地点
	site1		char(5)	default '' not null,  		// 地点
	act_date	datetime			not null,				// 业务发生日期
	bdate		datetime			not null,				// 营业日期
	flag		char(2)			not null,				// 主单类型: 入<出>库, 损耗, 冲销, 盘存, 调拨
	sta		char(1)			not null,				// 状态== I, X, O, D
	tag1		char(2)			null,						// 损耗原因
	tag2		char(2)			null,						// 保留字段
	tag3		char(10)			null,						// 保留字段
	tag4		char(10)			null,						// 保留字段
	amount	money	default 0 not null,				// 总金额
	refer		varchar(50)		null,						// 备注
	sby		char(10)			null,						// 审核
	sdate		datetime			null,
	cby		char(10)			not null,				// 创建
	cdate		datetime	default getdate()	not null,
	dby		char(10)			null,						// 冲销	
	ddate		datetime			null,
	dreason	varchar(20)		null,						// 冲销原因
	pc_id		char(4)			null,						// 独占标志
	logmark	int default 0	not null
)
exec sp_primarykey bos_kcmenu, folio
create unique index fno on bos_kcmenu(folio)
create index sfno on bos_kcmenu(sfolio)
create index cby on bos_kcmenu(cby, folio)
create index bdate on bos_kcmenu(bdate, folio)
create index actdate on bos_kcmenu(act_date, folio)
;

//------------------------------------------------------------------------------
// 明细单据  -- 要求同单据，代码唯一
//				其他情况开新单
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_kcdish')
	drop table bos_kcdish
;
create table  bos_kcdish (
	folio		char(10)			not null,				// 电脑单号(日期+流水号)
	code		char(8)			not null,				// 代码
	name		varchar(18)		null,						
	number	money	default 0 not null,				// 数量
	price		money	default 0 not null,				// 进价
	amount	money	default 0 not null,				// 成本金额
	price1	money	default 0 not null,				// 销售单价
	amount1	money	default 0 not null,				// 销售金额
	profit	money	default 0 not null,				// 进销差价
	ref		varchar(20)		null						// 备注
)
exec sp_primarykey bos_kcdish, folio, code
create unique index code on bos_kcdish(folio,code)
;
// ----------> 老版本的结构修改 sql 如下
//exec sp_rename 'bos_kcdish.number0', price1;
//exec sp_rename 'bos_kcdish.price0', amount1;
//exec sp_rename 'bos_kcdish.amount0', profit;


//------------------------------------------------------------------------------
//	各点存货纪录报告  ---  实时信息
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_store')
	drop table bos_store
;
create table  bos_store (
	id			char(6)		not null,
	pccode	char(5)		not null,
	site		char(5)		not null,			// 存货点
	code		char(8)		not null,			// 代码
	number0	money	default 0	not null,	// 上期结余
	amount0	money	default 0 	not null,	// 
	sale0		money	default 0 	not null,	// 
	profit0	money	default 0 	not null,	// 
	number1	money	default 0	not null,	// 入库
	amount1	money	default 0 	not null,	// 
	sale1		money	default 0 	not null,	// 
	profit1	money	default 0 	not null,	// 
	number2	money	default 0	not null,	// 损耗
	amount2	money	default 0 	not null,	// 
	sale2		money	default 0 	not null,	// 
	profit2	money	default 0 	not null,	// 
	number3	money	default 0	not null,	// 盘存
	amount3	money	default 0 	not null,	// 
	sale3		money	default 0 	not null,	// 
	profit3	money	default 0 	not null,	// 
	number4	money	default 0	not null,	// 调拨
	amount4	money	default 0 	not null,	// 
	sale4		money	default 0 	not null,	// 
	profit4	money	default 0 	not null,	// 
	number5	money	default 0	not null,	// 销售
	amount5	money	default 0 	not null,	// 
	sale5		money	default 0 	not null,	// 
	disc		money	default 0 	not null,	// 
	profit5	money	default 0 	not null,	// 
	number6	money	default 0	not null,	// 领料
	amount6	money	default 0 	not null,	// 
	sale6		money	default 0 	not null,	// 
	profit6	money	default 0 	not null,	// 
	number7	money	default 0	not null,	// 调成本价
	amount7	money	default 0 	not null,	// 
	sale7		money	default 0 	not null,	// 
	profit7	money	default 0 	not null,	// 
	number8	money	default 0	not null,	// 调销售价
	amount8	money	default 0 	not null,	// 
	sale8		money	default 0 	not null,	// 
	profit8	money	default 0 	not null,	// 
	number9	money	default 0	not null,	// 余额
	amount9	money	default 0 	not null,	// 
	sale9		money	default 0 	not null,	// 
	profit9	money	default 0 	not null,	// 
	price0	money	default 0 	not null,	// 进价
	price1	money	default 0 	not null		// 售价
)
exec sp_primarykey bos_store, pccode,site,code
create unique index siteno on bos_store(pccode,site,code)
;

//------------------------------------------------------------------------------
//	各点存货纪录报告  ---  历史信息
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_hstore')
	drop table bos_hstore
;
create table  bos_hstore (
	id			char(6)		not null,
	pccode	char(5)		not null,
	site		char(5)		not null,			// 存货点
	code		char(8)		not null,			// 代码
	number0	money	default 0	not null,	// 上期结余
	amount0	money	default 0 	not null,	// 
	sale0		money	default 0 	not null,	// 
	profit0	money	default 0 	not null,	// 
	number1	money	default 0	not null,	// 入库
	amount1	money	default 0 	not null,	// 
	sale1		money	default 0 	not null,	// 
	profit1	money	default 0 	not null,	// 
	number2	money	default 0	not null,	// 损耗
	amount2	money	default 0 	not null,	// 
	sale2		money	default 0 	not null,	// 
	profit2	money	default 0 	not null,	// 
	number3	money	default 0	not null,	// 盘存
	amount3	money	default 0 	not null,	// 
	sale3		money	default 0 	not null,	// 
	profit3	money	default 0 	not null,	// 
	number4	money	default 0	not null,	// 调拨
	amount4	money	default 0 	not null,	// 
	sale4		money	default 0 	not null,	// 
	profit4	money	default 0 	not null,	// 
	number5	money	default 0	not null,	// 销售
	amount5	money	default 0 	not null,	// 
	sale5		money	default 0 	not null,	// 
	disc		money	default 0 	not null,	// 
	profit5	money	default 0 	not null,	// 
	number6	money	default 0	not null,	// 领料
	amount6	money	default 0 	not null,	// 
	sale6		money	default 0 	not null,	// 
	profit6	money	default 0 	not null,	// 
	number7	money	default 0	not null,	// 调成本价
	amount7	money	default 0 	not null,	// 
	sale7		money	default 0 	not null,	// 
	profit7	money	default 0 	not null,	// 
	number8	money	default 0	not null,	// 调销售价
	amount8	money	default 0 	not null,	// 
	sale8		money	default 0 	not null,	// 
	profit8	money	default 0 	not null,	// 
	number9	money	default 0	not null,	// 余额
	amount9	money	default 0 	not null,	// 
	sale9		money	default 0 	not null,	// 
	profit9	money	default 0 	not null,	// 
	price0	money	default 0 	not null,	// 进价
	price1	money	default 0 	not null		// 售价
)
exec sp_primarykey bos_hstore,id,pccode,site,code
create unique index siteno on bos_hstore(id,pccode,site,code)
;


//------------------------------------------------------------------------------
//		物品流动明细账 --- 当前
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_detail')
	drop table bos_detail;
create table  bos_detail (
	pccode 	char(5)			not null,
	site		char(5)			not null,				// 地点
	code		char(8)			not null,				// 代码
	id			char(6)			not null,				// 帐务周期
	ii			int				not null,				// 帐务序号
	flag		char(2)			not null,				// 单据类型 -- 入/领/损/调/盘/售/内/外   -- + 续
	descript	varchar(20)		null,						// 描述: 售-表明客房/续-起初余额
	folio		char(10)			not null,				// 电脑单号(日期+流水号)
	sfolio	varchar(20)		null,						// 手工号码
	fid		int	default 0	not null,			// 帐务序号
	rsite		char(5)	default '' not null,  		// 相关地点
	bdate		datetime			not null,				// 营业日期
	act_date	datetime			not null,				// 业务发生日期
	log_date	datetime			not null,				// 电脑入账日期
	empno		char(10)			null,						// 

	number	money	default 0 not null,				// 数量		-------- 当前业务
	amount0	money	default 0 not null,				// 进价
	amount	money	default 0 not null,				// 售价
	disc		money	default 0 not null,				// 折扣
	profit	money	default 0 not null,				// 进销差价

	gnumber	money	default 0 not null,				// 数量		---------  余额
	gamount0	money	default 0 not null,				// 进价
	gamount	money	default 0 not null,				// 售价
	gprofit	money	default 0 not null,				// 进销差价

	price0	money	default 0 not null,				// 进价
	price1	money	default 0 not null,				// 售价
)
exec sp_primarykey bos_detail,pccode,site,code,ii
create unique index index1 on bos_detail(pccode,site,code,ii)
create index sfno on bos_detail(sfolio)
create index fno on bos_detail(folio)
create index bdate on bos_detail(bdate)
create index actdate on bos_detail(act_date)
create index code on bos_detail(code,folio)
create index empno on bos_detail(empno,folio)
;


//------------------------------------------------------------------------------
//		物品流动明细账 --- 历史
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_hdetail')
	drop table bos_hdetail;
create table  bos_hdetail (
	pccode 	char(5)			not null,
	site		char(5)			not null,				// 地点
	code		char(8)			not null,				// 代码
	id			char(6)			not null,				// 帐务周期
	ii			int				not null,				// 帐务序号
	flag		char(2)			not null,				// 单据类型 -- 入/领/损/调/盘/售/内/外   -- + 续
	descript	varchar(20)		null,						// 描述: 售-表明客房/续-起初余额
	folio		char(10)			not null,				// 电脑单号(日期+流水号)
	sfolio	varchar(20)		null,						// 手工号码
	fid		int	default 0	not null,			// 帐务序号
	rsite		char(5)	default '' not null,  		// 相关地点
	bdate		datetime			not null,				// 营业日期
	act_date	datetime			not null,				// 业务发生日期
	log_date	datetime			not null,				// 电脑入账日期
	empno		char(10)			null,						// 

	number	money	default 0 not null,				// 数量		-------- 当前业务
	amount0	money	default 0 not null,				// 进价
	amount	money	default 0 not null,				// 售价
	disc		money	default 0 not null,				// 折扣
	profit	money	default 0 not null,				// 进销差价

	gnumber	money	default 0 not null,				// 数量		---------  余额
	gamount0	money	default 0 not null,				// 进价
	gamount	money	default 0 not null,				// 售价
	gprofit	money	default 0 not null,				// 进销差价

	price0	money	default 0 not null,				// 进价
	price1	money	default 0 not null,				// 售价
)
exec sp_primarykey bos_hdetail,id,pccode,site,code,ii
create unique index index1 on bos_hdetail(id,pccode,site,code,ii)
create index sfno on bos_hdetail(sfolio)
create index fno on bos_hdetail(folio)
create index bdate on bos_hdetail(bdate)
create index actdate on bos_hdetail(act_date)
create index code on bos_hdetail(code,folio)
create index empno on bos_hdetail(empno,folio)
;


// ------------------------------------------------------------------------------
// 临时表 === 明细账来源 --- 物流单据 和 销售单据 
// ------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_tmpdetail' and type='U')
	drop table bos_tmpdetail;
create table bos_tmpdetail 
(
	modu_id	char(2)			not null,
	pc_id		char(4)			not null,
	folio		char(10)			not null,				// 电脑单号(日期+流水号)
	sfolio	varchar(20),								// 手工号码
	site		char(5)	default '' not null,  		// 地点
	rsite		char(5)	default '' not null,  		// 相关地点
	act_date	datetime			not null,				// 业务发生日期
	bdate		datetime			not null,				// 营业日期
	flag		char(2)			not null,				// 主单类型: 入<出>库, 损耗, 冲销, 盘存, 调拨
	cby		char(10)			not null,				// 创建
	cdate		datetime	default getdate()	not null,
	fid		int				not null,				// 物流单据=0  销售单据=id
	code		char(8)			not null,				// 代码
	number	money	default 0 not null,				// 数量
	amount	money	default 0 not null,				// 成本金额
	amount1	money	default 0 not null,				// 销售金额
	disc		money	default 0 not null,				// 折扣
	profit	money	default 0 not null,				// 进销差价
	ref		varchar(20)		null						// 备注
)
exec sp_primarykey bos_tmpdetail,modu_id,pc_id,folio,site,code,fid
create unique index index1 on bos_tmpdetail(modu_id,pc_id,folio,site,code,fid)
;
