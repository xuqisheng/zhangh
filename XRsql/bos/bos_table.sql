/*

 bos系统 或 第二收银系统 或 简易收银系统  表建构 
 modu = '09'
 客房中心，商务中心 的入账采用此模块
				2001/05/10			

bos_folio			费用单
bos_hfolio
bos_dish
bos_hdish

bos_account			款项
bos_haccount
bos_partout

bos_reason			优惠理由
bos_partfolio		前台补

bos_plu				菜谱
bos_sort

bos_posdef			站点定义
bos_station

bos_mode_name		模式

bos_tblsta			地点
bos_tblav

bos_empno			工号

bos_itemdef			输入定义

bos_extno			商务中心分机
bos_tmpdish			单据输入临时表

bosjie; ybosjie
bosdai; ybosdai

*/


/*
	bos费用汇总表
*/
if exists(select * from sysobjects where name = "bos_folio" and type="U")
	drop table bos_folio;

create table bos_folio
(
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,	/*本单建立或修改营业日,建立日由foliono识别*/
	bdate1      datetime   	null    ,	/*本单结帐或被冲消营业日*/
	foliono		char(10)	   not null,	/*序列号*/
	sfoliono		varchar(10)	default '' null,
	site			char(5)	   null,			/*地点*/
	sta			char(1)		not null,	/*状态,"M"手工输入未结,"P",电话转入未结, "H",电话转入未输,"O"已结,"C"冲帐,"X"销单,"T"直输总台后补*/
   setnumb     char(10)    null    ,   /*结帐序号*/ 
	modu			char(2)		not null,	/*模块号*/
	pccode		char(5)		not null,	/*费用码*/
	name	   	char(24)		null,			/*费用码描述*/
	posno       char(3)     not null,
	mode	      char(3)		null,			/* 系统码*/

	fee			money	default 0 		not null,   /*费用总额*/
	fee_base	   money	default 0 	   not null,	/*基本费*/
	fee_serve	money	default 0 	   not null,	/*服务费*/
	fee_tax  	money	default 0 	   not null,	/*附加费*/
	fee_disc 	money	default 0 	   not null,	/*折扣费*/

	serve_type 	char(1)	default '0' not null,	/*服务费方式   0:比例 1:金额*/
	serve_value money		default 0   not null,	/*服务费数值*/
	tax_type  	char(1)	default '0' not null,	/*附加费方式   0:比例 1:金额*/
	tax_value  	money		default 0   not null,	/*附加费数值*/
	disc_type   char(1)	default '0' not null,	/*优惠方式   0:比例 1:金额*/
	disc_value	 money	default 0 	not null,	/*优惠比例*/
	reason		char(3)					null,			/*优惠原因*/

	pfee		   money	default 0 	   not null,   /*原费用总额*/
	pfee_base	money	default 0 	   not null,	/*原基本费*/
	pfee_serve	money	default 0 	   not null,	/*原服务费*/
	pfee_tax 	money	default 0 	   not null,	/*原附加费*/

	refer		   varchar(40)	   null,			/*备注 -- 可以放电话号码 */
	empno1		char(10)			not null,	/*录入或修改工号*/
	shift1		char(1)			not null,	/*班号*/
	empno2		char(10)			null,			/*结帐或冲消工号*/
	shift2		char(1)			null,			/*班号*/
	checkout	   char(4)			null,			/*结帐锁定标志位*/
	site0	   	char(5) default '' not null,			/**/
	chgcod		char(5) default '' not null
)
exec sp_primarykey bos_folio,foliono
create unique index index1 on bos_folio(foliono)
create unique index index2 on bos_folio(setnumb,foliono)
create index index3 on bos_folio(sta);

/*
	bos历史费用汇总表
*/
if exists(select * from sysobjects where name = "bos_hfolio" and type="U")
	drop table bos_hfolio;

create table bos_hfolio
(
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,	/*本单建立或修改营业日,建立日由foliono识别*/
	bdate1      datetime   	null    ,	/*本单结帐或被冲消营业日*/
	foliono		char(10)	   not null,	/*序列号*/
	sfoliono		varchar(10)	default '' null,
	site			char(5)	   null,			/*地点*/
	sta			char(1)		not null,	/*状态,"M"手工输入未结,"P",电话转入未结, "H",电话转入未输,"O"已结,"C"冲帐, "T"直输总台后补*/
   setnumb     char(10)    null    ,   /*结帐序号*/ 
	modu			char(2)		not null,	/*模块号*/
	pccode		char(5)		not null,	/*费用码*/
	name	   	char(24)		null,			/*费用码描述*/
	posno       char(3)     not null,
	mode	      char(3)		null,			/* 系统码*/

	fee			money	default 0 		not null,   /*费用总额*/
	fee_base	   money	default 0 	   not null,	/*基本费*/
	fee_serve	money	default 0 	   not null,	/*服务费*/
	fee_tax  	money	default 0 	   not null,	/*附加费*/
	fee_disc 	money	default 0 	   not null,	/*折扣费*/

	serve_type 	char(1)	default '0' not null,	/*服务费方式   0:比例 1:金额*/
	serve_value money		default 0   not null,	/*服务费数值*/
	tax_type  	char(1)	default '0' not null,	/*附加费方式   0:比例 1:金额*/
	tax_value  	money		default 0   not null,	/*附加费数值*/
	disc_type   char(1)	default '0' not null,	/*优惠方式   0:比例 1:金额*/
	disc_value	 money	default 0 	not null,	/*优惠比例*/
	reason		char(3)					null,			/*优惠原因*/

	pfee		   money	default 0 	   not null,   /*原费用总额*/
	pfee_base	money	default 0 	   not null,	/*原基本费*/
	pfee_serve	money	default 0 	   not null,	/*原服务费*/
	pfee_tax 	money	default 0 	   not null,	/*原附加费*/

	refer		   varchar(40)	   null,			/*备注*/
	empno1		char(10)			not null,	/*录入或修改工号*/
	shift1		char(1)			not null,	/*班号*/
	empno2		char(10)			null,			/*结帐或冲消工号*/
	shift2		char(1)			null,			/*班号*/
	checkout	   char(4)			null,			/*结帐锁定标志位*/
	site0	   	char(5) default '' not null,			/**/
	chgcod		char(5) default '' not null
)
exec sp_primarykey bos_hfolio,foliono
create unique index index1 on bos_hfolio(foliono)
create unique index index2 on bos_hfolio(setnumb,foliono)
create index index4 on bos_hfolio(bdate1);
create index index3 on bos_hfolio(sta);

/*
	bos费用明细表
*/
if exists(select * from sysobjects where name = "bos_dish" and type="U")
	drop table bos_dish;

create table bos_dish
(
	foliono		char(10)	   not null,	/*bos_folio号*/
	id          int         not null,   /*序列号*/       
	sta			char(1)		not null,		/*状态,'M'免;"C"冲帐*/
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,	/*本单建立或修改营业日,建立日由foliono识别*/
	bdate1      datetime   	null    ,	/*本单结帐或被冲消营业日*/
	pccode		char(5)		not null,	/*费用码*/
   code     	char(8)     not null,   /*菜谱明细码*/ 
	name	   	varchar(18)	null,			/*菜谱名称*/
	price       money       not null,   /*单价*/  
	number      money  default 0 not null,   /*数量*/
	unit        char(4)     null,   		/*单位*/  

	fee			money	default 0 		not null,   /*费用总额*/
	fee_base	   money	default 0 	   not null,	/*基本费*/
	fee_serve	money	default 0 	   not null,	/*服务费*/
	fee_tax  	money	default 0 	   not null,	/*附加费*/
	fee_disc 	money	default 0 	   not null,	/*折扣费*/

	serve_type 	char(1)	default '0' not null,	/*服务费方式   0:比例 1:金额*/
	serve_value money		default 0   not null,	/*服务费数值*/
	tax_type  	char(1)	default '0' not null,	/*附加费方式   0:比例 1:金额*/
	tax_value  	money		default 0   not null,	/*附加费数值*/
	disc_type   char(1)	default '0' not null,	/*优惠方式   0:比例 1:金额*/
	disc_value	 money	default 0 	not null,	/*优惠比例*/
	reason		char(3)					null,			/*优惠原因*/

	pfee		   money	default 0 	   not null,   /*原费用总额*/
	pfee_base	money	default 0 	   not null,	/*原基本费*/
	pfee_serve	money	default 0 	   not null,	/*原服务费*/
	pfee_tax 	money	default 0 	   not null,	/*原附加费*/

	refer		   varchar(80)	   null,		/*备注 -- 包含电话的说明 */
	empno1		char(10)		not null,	/*录入或修改工号*/
	shift1		char(1)		not null,	/*班号*/
	empno2		char(10)		null,		/*结帐或冲消工号*/
	shift2		char(1)		null,		/*班号*/
	amount0		money default 0  not null
)
exec sp_primarykey bos_dish,foliono,id
create unique index index1 on bos_dish(foliono,id)
create index index2 on bos_dish(sta);


/*
	bos历史费用明细表
*/
if exists(select * from sysobjects where name = "bos_hdish" and type="U")
	drop table bos_hdish;

create table bos_hdish
(
	foliono		char(10)	   not null,	/*bos_folio号*/
	id          int         not null,   /*序列号*/       
	sta			char(1)		not null,		/*状态,'M'免;"C"冲帐*/
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,	/*本单建立或修改营业日,建立日由foliono识别*/
	bdate1      datetime   	null    ,	/*本单结帐或被冲消营业日*/
	pccode		char(5)		not null,	/*费用码*/
   code     	char(8)     not null,   /*菜谱明细码*/ 
	name	   	varchar(18)	null,			/*菜谱名称*/
	price       money       not null,   /*单价*/  
	number      money  default 0 not null,   /*数量*/
	unit        char(4)     null,   		/*单位*/  

	fee			money	default 0 		not null,   /*费用总额*/
	fee_base	   money	default 0 	   not null,	/*基本费*/
	fee_serve	money	default 0 	   not null,	/*服务费*/
	fee_tax  	money	default 0 	   not null,	/*附加费*/
	fee_disc 	money	default 0 	   not null,	/*折扣费*/

	serve_type 	char(1)	default '0' not null,	/*服务费方式   0:比例 1:金额*/
	serve_value money		default 0   not null,	/*服务费数值*/
	tax_type  	char(1)	default '0' not null,	/*附加费方式   0:比例 1:金额*/
	tax_value  	money		default 0   not null,	/*附加费数值*/
	disc_type   char(1)	default '0' not null,	/*优惠方式   0:比例 1:金额*/
	disc_value	 money	default 0 	not null,	/*优惠比例*/
	reason		char(3)					null,			/*优惠原因*/

	pfee		   money	default 0 	   not null,   /*原费用总额*/
	pfee_base	money	default 0 	   not null,	/*原基本费*/
	pfee_serve	money	default 0 	   not null,	/*原服务费*/
	pfee_tax 	money	default 0 	   not null,	/*原附加费*/

	refer		   varchar(80)	   null,		/*备注 -- 包含电话的说明 */
	empno1		char(10)		not null,	/*录入或修改工号*/
	shift1		char(1)		not null,	/*班号*/
	empno2		char(10)		null,		/*结帐或冲消工号*/
	shift2		char(1)		null,		/*班号*/
	amount0		money default 0  not null
)
exec sp_primarykey bos_hdish,foliono,id
create unique index index1 on bos_hdish(foliono,id)
create index index2 on bos_hdish(sta);


/*
	商务中心结帐临时款项表
*/

if exists(select * from sysobjects where name = "bos_partout" and type="U")
	drop table bos_partout;

create table bos_partout
(
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,				/*营业时间*/
	setnumb     char(10)    null    ,   			/*结帐序号*/
	code		   char(5)		not null,				/*内部码*/
	code1	 	   char(5)		not null,				/*外部码*/
	reason	   char(3)		default '' not null,	/*折扣款待理由*/
	name		   char(24)	   null,		   			/*款项码描述*/
	amount		money	default 0 not null,			/*金额*/
	empno		   char(10)		not null,				/*工号*/
	shift		   char(1)		not null,				/*班号*/
	room		   char(5)		null,						/*转帐房号*/
	accnt		   char(10)		null,						/*转帐帐号*/
	tranlog     char(10)    null,						/*协议码*/
	cusno       char(7)     null,						/*单位码*/
	cardtype     char(10)     null,						/*卡号*/
	cardno      char(20)     null,						/*卡号*/
	quantity		money	default 0 not null,			/*积分*/			
	ref			varchar(100)	null,
	modu			char(2)		null,
	checkout	   char(4)		null						/*结帐锁定标志位*/
)
exec sp_primarykey bos_partout,checkout,code
create unique index index1 on bos_partout(checkout,code);



/*
	商务中心款项表
*/

if exists(select * from sysobjects where name = "bos_account" and type="U")
	drop table bos_account;

create table bos_account
(
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,				/*营业时间*/
	setnumb     char(10)    null    ,   			/*结帐序号*/
	code		   char(5)		not null,				/*内部码*/
	code1	 	   char(5)		not null,				/*外部码*/
	reason	   char(3)		default '' not null,	/*折扣款待理由*/
	name		   char(24)	   null,		   			/*款项码描述*/
	amount		money	default 0 not null,			/*金额*/
	empno		   char(10)		not null,				/*工号*/
	shift		   char(1)		not null,				/*班号*/
	room		   char(5)		null,						/*转帐房号*/
	accnt		   char(10)		null,						/*转帐帐号*/
	tranlog     char(10)    null,						/*协议码*/
	cusno       char(7)     null,						/*单位码*/
	cardtype     char(10)     null,						/*卡号*/
	cardno      char(20)     null,						/*卡号*/
	quantity		money	default 0 not null,			/*积分*/			
	ref			varchar(100)	null,
	modu			char(2)		null,
	checkout	   char(4)		null						/*结帐锁定标志位*/
)
exec sp_primarykey bos_account,setnumb,code
create unique index index1 on bos_account(setnumb,code);


/*
	商务中心历史款项表
*/

if exists(select * from sysobjects where name = "bos_haccount" and type="U")
	drop table bos_haccount;

create table bos_haccount
(
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,				/*营业时间*/
	setnumb     char(10)    null    ,   			/*结帐序号*/
	code		   char(5)		not null,				/*内部码*/
	code1	 	   char(5)		not null,				/*外部码*/
	reason	   char(3)		default '' not null,	/*折扣款待理由*/
	name		   char(24)	   null,		   			/*款项码描述*/
	amount		money	default 0 not null,			/*金额*/
	empno		   char(10)		not null,				/*工号*/
	shift		   char(1)		not null,				/*班号*/
	room		   char(5)		null,						/*转帐房号*/
	accnt		   char(10)		null,						/*转帐帐号*/
	tranlog     char(10)    null,						/*协议码*/
	cusno       char(7)     null,						/*单位码*/
	cardtype     char(10)     null,						/*卡号*/
	cardno      char(20)     null,						/*卡号*/
	quantity		money	default 0 not null,			/*积分*/			
	ref			varchar(100)	null,
	modu			char(2)		null,
	checkout	   char(4)		null						/*结帐锁定标志位*/
)
exec sp_primarykey bos_haccount,setnumb,code
create unique index index1 on bos_haccount(setnumb,code)
;

///*
//	优惠理由
//*/
//if exists(select * from sysobjects where name = "bos_reason" and type ="U")
//	drop table bos_reason;
//create table bos_reason
//(
//	code		char(3)		not null,	/*代码*/
//	key0		char(3)		not null,	/*refer to reason0*/
//	descript	varchar(16)		not null,	/*描述*/
//	percent	money			not null,	/*比例*/
//	day		money			default 0 	not null,
//	month		money			default 0 	not null,
//	year		money			default 0 	not null,
//)
//exec sp_primarykey bos_reason,code
//create unique index index1 on bos_reason(code)
//;
//insert bos_reason values ('01','A01','徐斌优惠',0,0,0,0)
//insert bos_reason values ('02','A02','何仁尧优惠',0,0,0,0)
//;


/*
	总台手工输入费用,bos后补明细对照表
*/
if exists(select * from sysobjects where name = "bos_partfolio" and type="U")
	drop table bos_partfolio;

create table bos_partfolio
(
	accnt        char(10) not null,     /*账号*/ 
	number       int     not null,     /*帐次*/
	foliono      char(10) not null     /*bos_folio*/
);
exec sp_primarykey bos_partfolio,accnt,number 
create unique index index1 on bos_partfolio(accnt,number);
create unique index index2 on bos_partfolio(foliono);


/*
	bos菜单
*/
if exists(select * from sysobjects where name = "bos_plu" and type ="U")
	drop table bos_plu;
create table bos_plu
(
	pccode   char(5)		not null,	/*营业点*/
   code     char(8)     not null,   /*代码*/
	name		varchar(18)		not null,	/*描述*/
	ename		varchar(30)		null,			/*描述*/
	helpcode	varchar(10)		null,			/*助记符*/
	standent	varchar(12)		null,			/*规格,废弃!!!*/
	unit		char(4)		null,			/*单位*/
	sort		char(4)		not null,	/*菜类*/
	hlpcode	varchar(8)		null,			/*菜类助记符*/
	price		money			not null,	/*价格*/
	menu		char(4)		not null,	/*早,中,晚,夜的共享*/
   dscmark  char(1)     null,       /*折扣特优码标志*/
	surmark  char(1)     null,       /*T:需收服务费,F:不收服务费*/
	taxmark  char(1)     null,       /*T:需收附加税,F:不收附加税*/
	discmark char(1)     null,       /*T:可打折,F:不打折*/
	provider	char(7)		default '' null,
	number	money	default 0 not null,  // 库存数量和金额
	amount	money default 0 not null,
	site		varchar(8) default '' null,  // 存放地点
	class		char(3)	 	not null			// 类别
)
exec sp_primarykey bos_plu,pccode,code
create unique index index1 on bos_plu(pccode,code)
// create unique index index2 on bos_plu(pccode,name)
create index index3 on bos_plu(pccode,helpcode)
;

/*
	bos菜类
*/

if exists(select * from sysobjects where name = "bos_sort" and type ="U")
	drop table bos_sort;
create table bos_sort
(
	pccode		char(5)			not null,	/*营业点*/
	sort			char(8)			not null,	/*类别*/
	name			varchar(12)		not null,	/*描述*/
	ename			varchar(20)		null,			/*描述*/
	hlpcode		varchar(8)		null,			/*助记符*/
	surmark     char(1)     	null,       /*T:需收服务费,F:不收服务费*/
	taxmark     char(1)     	null,       /*T:需收附加税,F:不收附加税*/
	discmark    char(1)     	null,       /*T:可打折,F:不打折*/
)
exec sp_primarykey bos_sort,pccode,sort
create unique index index1 on bos_sort(pccode,sort)
create unique index index2 on bos_sort(pccode,name)
;


/*
	收银点表,定义每个收银点管辖的营业点
*/

if exists(select * from sysobjects where name = "bos_posdef" and type ="U")
	drop table bos_posdef;
create table bos_posdef
(
	posno			char(2)				not null,	/*收银点码*/
	modu			char(2)				not null,	/*模块号*/
	mode			char(1)				not null,	/*0-all, 1-folio, 2-dish*/
	descript		varchar(20)			not null,	/*收银点名*/
	descript1	varchar(20)			not null,	/*收银点名*/
   pccodes		varchar(120)		null,	 	   /*营业点集合*/		
	fax1			char(5)				null,			/*发送传真的费用码 国内*/
	fax2			char(5)				null,			/*发送传真的费用码 国际*/
	sites			varchar(100) default ''	not null,			/*柜台号码*/
	def			char(1)		default 'F'			/*缺省采用*/
)
exec sp_primarykey bos_posdef,posno,modu
create unique index index1 on bos_posdef(posno,modu)
;
insert bos_posdef select '01', '03', '0', '客房中心', '','','','', '','T'
insert bos_posdef select '02', '06', '0', '商务中心', '','','','', '','T'
insert bos_posdef select '03', '09', '0', '商场购物', '','','','', '','T'
insert bos_posdef select '04', '66', '0', '康乐收银', '','','','', '','T'
;

/*
	工作站表
*/
if exists(select * from sysobjects where name = "bos_station" and type ="U")
	drop table bos_station;
create table bos_station
(
	netaddress	char(4)		not null,	/*网络地址*/
	posno			char(2)		not null,	/*收银点*/
   printer		char(1)		not null,	/*多次打单."T"/"F"*/
	adjuhead		int			default 0	not null,	/*打印调整*/
	adjurow		int			default 0	not null,	/*打印调整*/
)
exec sp_primarykey bos_station,netaddress,posno
create unique index index1 on bos_station(netaddress,posno)
;
insert bos_station(netaddress,posno,printer)
	values('1.01', '01', 'T')
;


/*
	模式代码及描述
*/
if exists(select * from sysobjects where name = "bos_mode_name" and type ="U")
	drop table bos_mode_name;

create table bos_mode_name
(
	code			char(3)			not null,	/*代码*/
	descript		varchar(20)		not null,	/*中文名称*/
	descript1	varchar(30)		null,			/*英文名称*/
	remark		varchar(255)	null,			/*描述*/
)
exec sp_primarykey bos_mode_name,code
create unique index index1 on bos_mode_name(code)
;


/*
	地点
*/
if exists(select * from sysobjects where name = "bos_tblsta" and type ="U")
	drop table bos_tblsta;
//create table bos_tblsta
//(
//	tableno		char(4)		not null,							/*桌号*/
//	type			char(3)		null,									/*类别*/
//	pccode		char(3)		not null,							/*营业点*/
//	descript1	char(10)		null,									/*描述1*/
//	descript2	char(10)		null,									/*描述2*/
//	maxno			integer		default	0	not null,			/*席位数*/
//	sta			char(1)		default	'N'	not null,
//	mode			char(1)		default	'0'	not null,		/*最低消费模式*/
//	amount		money			default	0	not null,			/*最低消费金额*/
//	code			char(15)		default '' not null				/*零头去向*/
//)
//exec sp_primarykey bos_tblsta,tableno
//create unique index index1 on bos_tblsta(tableno)
//create index index2 on bos_tblsta(pccode, tableno)
//;

/*
	席位状态表
*/
if exists(select * from sysobjects where name = "bos_tblav" and type ="U")
	drop table bos_tblav;
//create table bos_tblav
//(
//	menu				char(10)		not null,								/*主单号*/
//	tableno			char(4)		not null,								/*桌号*/
//	id					integer		default 0 not null,
//	bdate				datetime		not null,								/*日期*/
//	shift				char(1)		not null,								/*班号*/
//	sta				char(1)		not null,								/*状态*/
//	begin_time		datetime		default	getdate()	not null,	/*计时开始时间*/
//	end_time			datetime		null										/*计时截止时间*/
//)
//exec sp_primarykey bos_tblav,menu,tableno,id
//create unique index index1 on bos_tblav(menu,tableno,id)
//;

/*
	BOS 工号定义
*/
if exists(select * from sysobjects where name = "bos_empno" and type ="U")
	drop table bos_empno;
create table bos_empno
(
	empno		char(10)		not null,	/*工号*/
	name		char(20)		not null,	/*姓名*/
)
exec sp_primarykey bos_empno,empno
create unique index index1 on bos_empno(empno)
;

/*
	BOS 入账界面子项定义
*/
if exists(select * from sysobjects where name = "bos_itemdef" and type ="U")
	drop table bos_itemdef;
create table bos_itemdef
(
	posno		char(2)			not null,	/*收银点   ZZ = 客房中心快速入账定义《系统内定》*/
	define	varchar(20)		null			/*不显示的定义*/
)
exec sp_primarykey bos_itemdef,posno
create unique index index1 on bos_itemdef(posno)
;


/*
	商务中心分机设定
*/
if exists(select * from sysobjects where name = "bos_extno" and type ="U")
	drop table bos_extno;
create table bos_extno
(
	code		char(8)			not null,
	posno		char(2)			not null
)
exec sp_primarykey bos_extno,code
create unique index index1 on bos_extno(code)
;

/*
	bos 临时表
*/
if exists(select * from sysobjects where name = "bos_tmpdish" and type="U")
	drop table bos_tmpdish;

create table bos_tmpdish
(
	modu_id		char(2)		not null,
	pc_id			char(4)		not null,
	id          int         not null,      /*序列号*/
	sta			char(1)		not null,		/*状态,'I'=正常 'M'=免 "C"=冲帐 */
   code     	char(8)     not null,   /*菜谱明细码*/ 
	name	   	varchar(18)	null,			/*菜谱名称*/
	price       money       not null,   /*单价*/  
	number      money  default 0 not null,   /*数量*/
	unit        char(4)     null,   		/*单位*/  
	pfee_base	money	default 0 	   not null,	/*原基本费*/
	serve_type 	char(1)	default '0' not null,	/*服务费方式   0:比例 1:金额*/
	serve_value money		default 0   not null,	/*服务费数值*/
	tax_type  	char(1)	default '0' not null,	/*附加费方式   0:比例 1:金额*/
	tax_value  	money		default 0   not null,	/*附加费数值*/
	disc_type   char(1)	default '0' not null,	/*优惠方式   0:比例 1:金额*/
	disc_value	 money	default 0 	not null		/*优惠比例*/
)
exec sp_primarykey bos_tmpdish,modu_id, pc_id, id
create unique index index1 on bos_tmpdish(modu_id, pc_id, id)
;

if exists ( select * from sysobjects where name = 'bosjie' and type ='U')
	drop table bosjie;
create table bosjie
(
   date          datetime default getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	code          char(5)  default '' not null,
	descript      char(24)  default '' not null,
	fee_bas       money    default 0  not null,
	fee_sur       money    default 0  not null,
	fee_tax       money    default 0  not null,
	fee_dsc	      money    default 0  not null,
	fee_ent	      money    default 0  not null,
	fee_ttl	      money    default 0  not null,
	fee_basm      money    default 0  not null,
	fee_surm      money    default 0  not null,
	fee_taxm      money    default 0  not null,
	fee_dscm      money    default 0  not null,
	fee_entm      money    default 0  not null,
	fee_ttlm      money    default 0  not null,
	daymark       char(1)  default '' not null
)
exec sp_primarykey bosjie,shift,empno,code
create unique index index1 on bosjie(shift,empno,code)
;

if exists ( select * from sysobjects where name = 'ybosjie' and type ='U')
   drop table ybosjie;
create table ybosjie
(
   date          datetime default getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	code          char(5)  default '' not null,
	descript      char(24)  default '' not null,
	fee_bas       money    default 0  not null,
	fee_sur       money    default 0  not null,
	fee_tax       money    default 0  not null,
	fee_dsc	     money    default 0  not null,
	fee_ent	     money    default 0  not null,
	fee_ttl	     money    default 0  not null,
	fee_basm      money    default 0  not null,
	fee_surm      money    default 0  not null,
	fee_taxm      money    default 0  not null,
	fee_dscm      money    default 0  not null,
	fee_entm      money    default 0  not null,
	fee_ttlm      money    default 0  not null,
	daymark       char(1)  default '' not null
)
exec sp_primarykey ybosjie,date,shift,empno,code;
create unique index index1 on ybosjie(date,shift,empno,code);

if exists ( select * from sysobjects where name = 'bosdai' and type ='U')
   drop table bosdai;
create table bosdai
(
   date          datetime default    getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	paycode       char(5)  default '' not null,
	paytail       char(1)  default '' not null,
	descript      char(24) default '' not null,
	creditd       money    default 0  not null,
	creditm       money    default 0  not null,
	daymark       char(1)  default '' not null
)
exec sp_primarykey bosdai,shift,empno,paycode,paytail
create unique index index1 on bosdai(shift,empno,paycode,paytail)
;

if exists ( select * from sysobjects where name = 'ybosdai' and type ='U')
   drop table ybosdai;
create table ybosdai
(
   date          datetime default    getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	paycode       char(5)  default '' not null,
	paytail       char(1)  default '' not null,
	descript      char(24) default '' not null,
	creditd       money    default 0  not null,
	creditm       money    default 0  not null,
	daymark       char(1)  default '' not null
)
exec sp_primarykey ybosdai,date,shift,empno,paycode,paytail
create unique index index1 on ybosdai(date,shift,empno,paycode,paytail)
;

