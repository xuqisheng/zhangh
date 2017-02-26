--------------------------------------------------------------------------------
--
-- 餐饮点菜收银类表结构
--
--------------------------------------------------------------------------------

/*	点菜菜单主单 */

create table pos_menu
(
	tag					char(1)		default ""	not null,	/*客人类别,"0"零点,"1"团体,"2"个人,"3"旅游团,"4工作餐,"5"自助餐*/
	tag1					char(1)		default ""	not null,	/*备用*/
	tag2					char(1)		default ""	not null,	/*备用*/
	tag3					char(1)		default ""	not null,	/*备用 -- 叫起 T*/
	source				char(3)		default ""	not null,	/*来源*/
	market				char(3)		default ""	not null,	/*市场*/
	menu					char(10)		default ""	not null,	/*菜单号*/
	tables				integer		default 1	not null,	/*桌数*/
	guest					integer		default 1	not null,	/*客人数*/
	date0					datetime		default getdate()	not null,	/*输入时间*/
	bdate					datetime		default getdate()	not null,	/*就餐时间*/
	shift					char(1)		default "1"	not null,
	deptno				char(2)		default ""	not null,	/*部门号*/
	pccode				char(3)		default ""	not null,	/*厅别*/
	posno					char(2)		default ""	not null,	/*收银点号*/
	tableno				char(6)		null,			/*桌号,对团体,其为桌号群中的第一个*/
	mode					char(3)		not null,			/*模式*/
	dsc_rate				money			default 0	not null,	/*优惠费率*/
	reason				char(3)		default ""	not null,	/*优惠理由*/
	tea_rate				money			default 0	not null,	/*茶位费*/
	serve_rate			money			default 0	not null,	/*服务费率*/
	tax_rate				money			default 0	not null,	/*附加费率*/
	srv					money			default 0 	not null,   /*服务费*/
	dsc					money			default 0 	not null,   /*折扣*/
	tax					money			default 0 	not null,   /*税*/
	amount				money			default 0	not null,	/*消费金额*/
	amount0				money			default 0	not null,	/*预留*/
	amount1				money			default 0	not null,	/*预留*/
	empno1				char(10)		default ''  not null,							/*服务员, 改用为开单人*/
	empno2				char(10)		default ''  not null,							/*备用, 改用为改单人*/
	empno3				char(10)		default ''  not null,		/*操作员, 改用为结账员*/
	sta					char(1)		default '2' not null,	/*状态,"1"预订,"2"登记,"3"结帐,"4"挂账,"5"重结,"7"删除*/
	paid					char(1)		default "0"	not null,	/*结帐状态,"0"未结,"1"已结,"2"被冲*/
	setmodes				char(4)		default ''  not null,							/*最后一次付款方式,最后位为*表示多笔付款*/
	cusno					char(10)		default ''  not null,							/*往来单位号*/
	haccnt				char(10)		default ''  not null,							/*客人号*/
	foliono				varchar(20)	null,							/*手工单号*/
	remark				varchar(80)	null,							/*备注*/
	roomno				char(5)		default ''  not null,							/**/
	accnt					char(10)		default ''  not null,							/**/
	lastnum				integer		default 0	not null,	/*明细帐行次*/
	pcrec					char(10)		default ''  not null,							/*并单*/
	pc_id					char(8)		default ''  not null,							/*最后一次操作的IP地址,只有未结单有效*/
	timestamp			timestamp	not null,					/*时间戳*/
   saleid            char(10)    default '' not null,		/*销售员	*/
	resno					char(10)		default '' not null,			/*预订号*/
	cardno				char(10)		default '' not null,			/*卡号*/
	checkid				char(20)		default '' not null,			/*发票号*/
	logmark				integer		default 0  not null,
	cby        			char(10)    NULL,								/*修改人*/
   changed    			datetime    NULL)								/*修改时间*/		
;
exec sp_primarykey pos_menu,menu
create unique index index1 on pos_menu(menu)
;

select * into pos_menu_log from pos_menu
exec sp_primarykey pos_menu_log,menu,logmark
create unique index index1 on pos_menu_log(menu,logmark)
;


select * into pos_hmenu from pos_menu
EXEC sp_primarykey pos_hmenu, menu
CREATE UNIQUE NONCLUSTERED INDEX index1   ON dbo.pos_hmenu(menu)
CREATE NONCLUSTERED INDEX index2    ON dbo.pos_hmenu(bdate)
CREATE NONCLUSTERED INDEX index3    ON dbo.pos_hmenu(bdate,pccode)
CREATE NONCLUSTERED INDEX index_haccnt    ON dbo.pos_hmenu(haccnt)
CREATE NONCLUSTERED INDEX index_cusno     ON dbo.pos_hmenu(cusno)
;

select * into pos_tmenu from pos_menu
exec sp_primarykey pos_tmenu,menu
create unique index index1 on pos_tmenu(menu)
;


/* 点菜明细菜单 */

if  exists(select * from sysobjects where name = "pos_dish" and type ="U")
	 drop table pos_dish
;
create table pos_dish
(
	menu			char(10)		not null,					/*菜单号*/
	inumber		integer		not null,					/*明细帐行次*/
	plucode		char(2)		not null,					/*菜本号*/
	sort			char(4)		not null,					/*菜类*/
	code			char(6)		not null,					/*菜号*/
	id				int			not null,					/*菜内码*/
	printid		int			default 0	not null,	/*打印条码唯一号*/
	name1			varchar(30)	default ''	not null,	/*中文名*/
	name2			varchar(50)	default ''	not null,	/*外文名*/
	unit			char(4)		default ''	not null,	/*计量单位*/
	number		money			default 0   not null,	/*数量*/
	price			money			default 0   not null,	/*单价*/
	amount		money			default 0   not null,	/*金额*/
	pinumber		integer		default 1   not null,	/*对应菜价序号 pos_price.inumber*/
	pamount		money			default 0   not null,	/*成本金额*/
	empno			char(10)		null,							/*输入员工号*/
	bdate			datetime		not null,
	date0			datetime		default getdate()	not null,	/*输入(点)时间*/
	date1			datetime		null, 							 	/*烧菜时间, 计时菜的开始时间*/
	date2			datetime		null,   								/*出菜时间, 计时菜的结束时间*/
	special		char(1)		default	''		not	null,		/*特优折扣码标志, T:特优折扣, X: 特殊类, S:计时类*/
	sta			char(1)		default	'0'	not	null,		/*状态*/
	flag			varchar(30)	default	''		not 	null,		/*附加态*/   /* 21=送厨标记、28=有配料、29=菜价被修改过、30=打印标记*/
	flag19		char(1)		default	''				null,		/*对应菜谱的flag19*/	
	flag19_use	char(20)		default  ''				null,		/*使用记录*/		
	reason		char(3)		default	''		not 	null,		/*优惠原因*/
	remark		varchar(50)	default	''		not 	null,		/*备注*/
	id_cancel	integer		default	0	not null,					/*调整对应明细*/ 
	id_master	integer		default	0	not null,					/*明细到标准的指针*/
	empno1		char(10)		default	''	not null,					/*销售员厨师技师*/
	empno2		char(10)		default	''	not null,					/*划单员*/
	empno3		char(10)		default	''	not null,					/*最后改单人,如冲菜单菜折扣等*/
	orderno		varchar(10)	default  '' not null,					/*小单号*/
	srv			money			default 0 	not null,         /*服务费*/
	srv0			money			default 0 	not null,         /*服务费-原值*/
	srv_dsc		money			default 0 	not null,         /*服务费-折扣*/
	dsc			money			default 0 	not null,         /*折扣*/
	tax			money			default 0 	not null,         /*税*/
	tax0			money			default 0 	not null,         /*税-原值*/
	tax_dsc		money			default 0 	not null,         /*税-折扣*/
	tableno		char(6)		default	''	not null,			/*台号*/
	siteno		char(2)		default	''	not null,			/*座位号*/
	outno		   char(2)		default	''	not null,			/*出菜序号,主要用于西餐出菜次序*/
	kitchen		char(20)		default  '' null,					/*厨房*/
	cook1			varchar(50)	default	''	null,					/*备用*/
	kit_ref		varchar(30) default ''  null,					/*厨房指令*/
	cook			varchar(50)	default	''	null					/*烹饪要求*/
	
)
exec sp_primarykey pos_dish,menu,inumber
create unique index index1 on pos_dish(menu,inumber)
;

if  exists(select * from sysobjects where name = "pos_hdish" and type ="U")
	 drop table pos_hdish
;
select * into pos_hdish from pos_dish
exec sp_primarykey pos_hdish,menu,inumber
create unique index index1 on pos_hdish(menu,inumber)
CREATE NONCLUSTERED INDEX index_menu ON dbo.pos_hdish(menu)
;

if  exists(select * from sysobjects where name = "pos_tdish" and type ="U")
	 drop table pos_tdish
;
select * into pos_tdish from pos_dish
exec sp_primarykey pos_tdish,menu,inumber
create unique index index1 on pos_tdish(menu,inumber)
;
if  exists(select * from sysobjects where name = "pos_order" and type ="U")
	drop table pos_order
;
create table pos_order
(
	pc_id			char(4)		not null,							/*编辑的站点*/
	menu			char(10)		default '' not null,				/**/
	inumber		int			not null,							/*输入序号 */	
	orderno		char(10)		not null,							/*order号*/
	id				int			not null,							/*菜唯一码*/
	sort			char(4)		not null,							/*菜类*/
	code			char(6)		not null,							/*菜码*/
	pinumber		integer		default 0  not null,				/*价格序号*/
	unit			char(4)		not null,							/*单位*/
	price			money			not null,						/*单价*/	
	number		money			not null,						/*数量*/
	amount		money			not null,						/*金额*/
	name1			char(30)		not null,
	name2			char(50)		not null,
	sta			char(1)		null,								/*状态 */
	flag			varchar(30)	default ''	not null,  		/*标识码 与pos_plu的标识对应;套菜在输入dish时要关联pos_dish_pcid*/
	special		char(1)		null,								/*标志*/
	empno1		char(10)		null,								/*技师，厨师*/
	empno2		char(10)		null,								/*销售员*/
	inumber1		int			default 0 not null,			/*关联行码，套菜明细关联*/
	tableno		char(6)		default '' not null,			/*台号*/
	siteno		char(2)		default '' not null,			/*位号*/
	outno		   char(2)		default	''	not null,			/*出菜序号,主要用于西餐出菜次序*/
	cook			varchar(200)		null,						/*附加项描述*/
	remark		char(30)		null,								/*备注*/
	kitchen		char(20)		null,								/*厨房代码*/
	kit_ref		varchar(30) null								/*厨房指令*/						
)
exec sp_primarykey pos_order,pc_id,inumber
create unique index index1 on pos_order(pc_id,inumber)
;

/*  菜单数据打印纪录  */

if exists(select * from sysobjects where type ='U' and name = 'pos_menu_bill')
	drop table pos_menu_bill
;
create table pos_menu_bill
(
	menu			char(10) default ''  not null,				/*  */
	hline			int 		default 0   not null,				/* 已打印行 */
	hpage			int 		default 0   not null,				/* 已打印页 */
	inumber		int		default 0   not null,				/* 已打印菜序号 */
	hamount		money		default 0 	not null,				/*记录已打印的金额*/
	dsc			money		default 0   not null,				/*折扣  */
	srv			money		default 0   not null,				/*服务费  */
	tax			money		default 0   not null,				/*税  */
	bill			int		default 0   not null,				/*  */
	payamount	money		default 0   not null,				/* 实收 */
	oddamount	money		default 0   not null					/* 找零 */
)
;
exec sp_primarykey pos_menu_bill,menu
create unique index index1 on pos_menu_bill(menu)
;

/*  付款  */

if exists(select * from sysobjects where type ='U' and name = 'pos_pay')
	drop table pos_pay
;
create table pos_pay
(
	menu			char(10)		not null,								/* 单号,预定号 */
	number		integer		default 1 not null,					/* 序号 */
	inumber		integer		default 1 not null,					/* 关联序号 */
	paycode		char(5)		not null,								/* 付款方式 */
	accnt			char(10)		default ''  not null,				/* 转账账号 */
	roomno		char(5)		default ''  not null,				/* 转账房号 */
	foliono		char(20)		default ''  not null,				/* 单号 */
	amount		money			default 0   not null,				/* 金额 */
	sta			char(1)		default '0' not null,				/* 状态: 0 -- 定金， 2 - 使用定金， 3 - 结账款 */
	crradjt		char(2)		default 'NR' not null,				/* 状态: NR-- 正常， C -- 被冲， CO -- 冲, 用于重结*/
	reason		char(3)		default '0' not null,				/* 优惠原因 */
	empno			char(10)		not null,								/* 工号  */
	bdate			datetime		not null,								/* 营业日期 */
	shift			char(1)		not null,								/* 班别 */
	log_date		datetime		default getdate() not null,		/* 时间 */
	remark		char(60)		default '' not null,					/* 备注 */
	menu0			char(10)		default '' not null,					/* 定金的单号预定号，或使用定金的单号预定号 */
	bank			char(10)		default '' not null,					/* 信用卡：发卡行 */
	credit		money			default 0  not null,					/* 备用 */
	cardno		char(20)		default '' not null,					/* 卡号 */
	ref			char(40)		default '' not null,					/* 备注 */
	quantity		money			default 0  not null					/* 数量 */
)
exec sp_primarykey pos_pay, menu,number
create unique index index1 on pos_pay(menu, number)
;

if  exists(select * from sysobjects where name = "pos_tpay" and type ="U")
	 drop table pos_tpay
;
select * into pos_tpay from pos_pay
exec sp_primarykey pos_tpay,menu,number
create unique index index1 on pos_tpay(menu,number)
;

if  exists(select * from sysobjects where name = "pos_hpay" and type ="U")
	 drop table pos_hpay
;
select * into pos_hpay from pos_pay
exec sp_primarykey pos_hpay,menu,number
create unique index index1 on pos_hpay(menu,number)
;


/*
	席位状态表
*/
if exists(select * from sysobjects where name = "pos_tblav" and type ="U")
	 drop table pos_tblav;

create table pos_tblav
(
	menu				char(10)		not null,								/*主单号*/
	tableno			char(6)		not null,								/*桌号*/
	inumber			integer		default 0  not null,
	empno				char(10)		default '' not null,					/*值台员*/
	bdate				datetime		not null,								/*日期*/
	shift				char(1)		not null,								/*班号*/
	sta				char(1)		not null,								/*状态 0 : 取消 1 : 预定 7 : 开台 */
	begin_time		datetime		default	getdate()	not null,	/*娱乐包厢开始计时时间*/
	end_time			datetime		null,										/*娱乐包厢计时截止时间*/
	pcrec				char(10)		null,										/*联单号*/
	amount			money			default	0				not null		/*金额*/
)
exec sp_primarykey pos_tblav, menu, tableno, inumber
create unique index index1 on pos_tblav(menu, tableno, inumber)
;


/* 套菜,标准菜的组成 */

if exists(select 1 from sysobjects where name='pos_std' and type='U')
   drop table pos_std;
create table pos_std
(
	plucode		char(2)		not null,					/* 菜本号 */
	std_id		int			not null,					/* 标准菜代码 */
	id				int			not null,       			/* 具体明细菜代码 */
	number		money			default 1 not null,		/* 具体明细菜数量 */
	unit			char(4)		default  '' not null,	/* 具体明细菜单位 */
	price			money			default 0 not null,		/* 具体明细菜单价 */
	sequence		int			default 0 not null,		/* 序号 */
	sort			char(1)		default '1' not null,	/* 批次 */
	pinumber		int			default 0 not null		/* pos_price.inumber */
)
;
exec sp_primarykey pos_std,plucode,std_id,id
create unique index index1 on pos_std(plucode,std_id,id);

/*
	缺菜了又被点的纪录
*/
if  exists(select * from sysobjects where name = "pos_nodish" and type ="U")
	drop table pos_nodish
;
create table  pos_nodish (
	bdate			datetime			default getdate()	not null,
	id				int				default 0 	not null,						/*pos_plu.id*/
	code			char(6)			default '' 	not null,
	name1			char(30)			default ''	not null,		
	name2			char(50)			default ''	not null,
	unit			char(4)			default ''  not null,
	number		money				default 0   not null							/*数量*/			
	);
exec sp_primarykey pos_nodish,bdate,id
create unique index index1 on pos_nodish(bdate, id)
;

/*
  临时菜谱存放
*/
create table pos_plu_temp
(
	plucode				char(2)		not null,
	sort					char(4)		not null,
	id						int			not null,
	name1					char(30)		not null,
	helpcode				char(10)		not null,
	unit					char(4)		not null,
	price					money default 0		not null
)

exec sp_primarykey pos_plu_temp,id
create unique index index1 on pos_plu_temp(id)
create unique index index2 on pos_plu_temp(name1)
;
// 结账临时纪录存放表，零头
CREATE TABLE pos_checkout (
	pc_id 			char(8)		not null,
	menu 				char(10)	default ''	not null,
	menu1 			char(10)	default ''	not null,
	id 				int		default 0	not null,
	number 			int		default 0	not null,
	paycode 			char(5)	null,
	amount 			money		default 0	not null,
	remark 			char(15) null
)
;

exec sp_primarykey pos_checkout,pc_id,menu,id;
create unique index index1 on pos_checkout(pc_id,menu,id)
;


// 餐饮费用分类定义
CREATE TABLE pos_deptcls (
	code 			char(2),
	descript 	char(16),			// 中文
	descript1 	char(32),			// 英文
	deptpat 		char(30)
);
exec sp_primarykey pos_deptcls,code
create unique index index1 on pos_deptcls(code)
;

// 餐饮报表代码定义
drop  TABLE pos_namedef ;
CREATE TABLE pos_namedef (
	deptno 	char(2),				 	//部门号
	code 		char(3),					//
	descript char(12),				//中文
	descript1 char(24)				//英文
);
exec sp_primarykey pos_namedef,deptno,code;
create unique index index1 on pos_namedef(deptno,code);

// 点菜烹饪要求，
CREATE TABLE pos_order_cook (
	menu	 			char(10)  default ''	not null,				 
	inumber			integer 	 default 0	not null,			 // pos_order.inumber
	inumber0  		integer   default 0	not null,			 // 
	sta				char(1)   default '0'	not null,		 // 1 -  ORDER ; 0 - DISH
	id					integer   default 0	not null,			 //  pos_plu.id or pos_condst.condid
	type				char(1)   default '0'	not null,		 // 0 -  pos_plu ; 1 - pos_condst 
	descript  		char(24)  default ''	not null,			 // 描述
	number			money   	 default 0	not null,			 // 数量
	unit				char(4)	 default ''	not null,			 // 
	price				money		 default 0	not null,          // 单价
	amount			money     default 0	not null,        	 // 金额
	date0				datetime	 default getdate() null
);
exec sp_primarykey pos_order_cook,menu,inumber,inumber0,sta;
create unique index index1 on pos_order_cook(menu,inumber,inumber0,sta);

// 早餐使用纪录
create table pos_bkfuse(
	bdate				datetime,
	roomno			char(6),
	accnt				char(10)   not null,
	inumber			int,
	pccode			char(3),     --  餐厅号
	number			money     default 1 not null ,      -- 份数
	empno				char(10)   not null,
	logdate			datetime   not null,
	amount   		money    NULL,
	pc_id    		char(4)  NULL,
	transfer 		char(1)  NULL
)
;
exec sp_primarykey pos_bkfuse,bdate,roomno,inumber;
create unique index index1 on pos_bkfuse(bdate,roomno,inumber);

// 早餐使用纪录
create table pos_ybkfuse(
	bdate				datetime,
	roomno			char(6),
	accnt				char(10)   not null,
	inumber			int,
	pccode			char(3),     --  餐厅号
	number			money     default 1 not null ,      -- 份数
	empno				char(10)   not null,
	logdate			datetime   not null,
	amount   		money    NULL,
	pc_id    		char(4)  NULL,
	transfer 		char(1)  NULL
)
;
create unique index index1 on pos_ybkfuse(bdate,roomno,inumber);


// 餐单操作状态
create table pos_menu_op(
	menu				char(10)   default '' not null,
	pc_id				char(4)    default '' not null,
	optype			char(10)   default '' not null,      -- 操作类别order :点菜,check ：结账
	empno				char(10)   not null,
	logdate			datetime   not null
)
;
exec sp_primarykey pos_menu_op,menu,pc_id,optype;
create unique index index1 on pos_menu_op(menu,pc_id,optype);


/*欢乐时光, 时间段定义*/
CREATE TABLE pos_season (
	code 			char(3)    default '' not null,             // 
	descript 	char(30)   default '' not null,             // 
	descript1 	char(40)   default '' not null,             //
	begin_ 		datetime   default getdate() not null,      // 有效期开始时间  
	end_ 			datetime   default getdate() not null,      // 有效期结束时间  
	day 			char(250)  default '' not null,             // 天     
	week 			char(14)   default '' not null,             // 星期
	shift			char(1)    default '' not null,             // 餐段
	sequence 	char(5)    default '100' not null
);
create unique index index1 on pos_season(code);

/*欢乐时光, 菜价定义*/
CREATE TABLE pos_happytime (
	id				int     default 0  not null,	 				// 菜ID	
	inumber		int     default 0  not null,              // pos_price.inumber
	code			char(3) default '' not null,					// pos_season.code
	price			money   default 0  not null,              // 菜价
);
create unique index index1 on pos_happytime(id,inumber,code);

