/************************************************************/
/* 本SQL为 康乐系统 FOR V50 的 增加结构							 */
/*************************************************************/

/* 会费缴纳纪录表 */

if  exists(select * from sysobjects where name = "sp_tax" and type ="U")
	  drop table sp_tax;

create table sp_tax
(
	cardno		char(10)		default '' 			not null,			/*会员卡号*/
	type			char(2)		default '01' 		not null,			/*类别：1 -- 年费；2 -- 季费；3 -- 月费*/
	sdate			datetime		default getdate() not null, 			/*有效期的开始时间*/
	edate			datetime		default getdate() not null, 			/*有效期的结束时间*/
	amount		money			default 0 not null, 					 	/*会费*/
	logdate		datetime		null,   						/*输入时间*/
	empno			char(3)		default	''	not null,	/*操作员*/
	menu			char(10)		default	''	not null,	/*单号*/

)
exec sp_primarykey sp_tax,cardno,menu
create unique index index1 on sp_tax(cardno,menu)
;


/* 场地类别表 */

if  exists(select * from sysobjects where name = "sp_place_sort" and type ="U")
	  drop table sp_place_sort;

create table sp_place_sort
(	
	sort				char(2)		default '' 			not null,		/*类号*/
	name				char(30)		default '' 			not null,		/*名称*/
	pccode			char(30)		default '' 			not null,		/*chgcod.pccode*/
	period			int			default 30			not null,			/*显示的时间段,计次单位：分钟*/
	time				int			default 60			not null,		//计时定义
	bmp				varchar(255)	default ''		null
)
exec sp_primarykey sp_place_sort,sort
create unique index index1 on sp_place_sort(sort)
;

//INSERT INTO sp_place_sort VALUES (	'01',	'羽毛球',	'14',	30);
//INSERT INTO sp_place_sort VALUES (	'02',	'保龄球',	'14',	60);
//INSERT INTO sp_place_sort VALUES (	'03',	'乒乓球',	'14',	60);
//INSERT INTO sp_place_sort VALUES (	'04',	'网球场',	'14',	60);


/* 场地代码表 */

if  exists(select * from sysobjects where name = "sp_place" and type ="U")
	  drop table sp_place;

create table sp_place
(	
	sort				char(2)		default '' 			not null,			/*类号*/
	code				char(5)		default '' 			not null,			/*康乐场地号号*/
	placecode		char(5)		default '' 			not null,			/*统计场地号*/
	name				char(30)		default '' 			not null,			/*名称*/
	ename				char(40)		default ''		 	not null, 			/**/
	descript			char(100)	default '' 			not null, 			/*描述*/
	sta				char(1)		default '' 			not null,
	plucode			char(15)		default ''			not null,			/*对应sp_plu.code, 入dish账用*/
)
exec sp_primarykey sp_place,code
create unique index index1 on sp_place(code)
;

INSERT INTO sp_place VALUES (	'01',	'001',	'001',	'羽毛球场地1',	'',	'',	'',	'44014001');
INSERT INTO sp_place VALUES (	'01',	'002',	'002',	'羽毛球场地2',	'',	'',	'',	'44014001');
INSERT INTO sp_place VALUES (	'02',	'003',	'003',	'乒乓球桌1',	'',	'',	'',	'44014004');
INSERT INTO sp_place VALUES (	'02',	'004',	'004',	'乒乓球桌2',	'',	'',	'',	'44014004');
INSERT INTO sp_place VALUES (	'03',	'005',	'005',	'网球场地A',	'',	'',	'',	'44014002');
INSERT INTO sp_place VALUES (	'03',	'006',	'006',	'网球场地B',	'',	'',	'',	'44014002');
INSERT INTO sp_place VALUES (	'04',	'007',	'007',	'保龄球道1',	'',	'',	'',	'44014003');
INSERT INTO sp_place VALUES (	'04',	'008',	'008',	'保龄球道2',	'',	'',	'',	'44014003');
INSERT INTO sp_place VALUES (	'04',	'009',	'009',	'保龄球道3',	'',	'',	'',	'44014003');

/*场地状态信息*/

if exists(select * from sysobjects where name = "sp_plaav" and type ="U")
	  drop table sp_plaav;

create table sp_plaav
(
	menu				char(10)		not null,								/*主单号*/
	placecode		char(5)		not null,								/*场地号*/
	inumber			integer		default 0  not null,					
	empno				char(3)		default '' not null,					/*服务员*/
	bdate				datetime		not null,								/*日期*/
	shift				char(1)		not null,								/*班号*/
	sta				char(1)		not null,								/*状态: R -- 预定；O -- 维修；X -- 取消; I -- 使用; D -- 结账, G -- 预定转登记*/
	stime				datetime		default	getdate()	not null,	/*开始时间*/
	etime				datetime		null		,								/*截止时间*/
	amount			money			default 0   not null,				/*场租费*/
	dishtype			char(1)		default 'F' not null,				/*插入dish入账标志*/
	dnumber			int			default 0   not null,				/*入账后dish.id,inumber*/	
	resno				char(10)		default ''	null
)
exec sp_primarykey sp_plaav, menu, placecode, inumber
create unique index index1 on sp_plaav(menu, placecode, inumber)
;
select * into sp_hplaav from sp_plaav where 1=2;
create unique index index1 on sp_hplaav(menu, placecode, inumber)
;

/*场地使用简单纪录信息*/

if exists(select * from sysobjects where name = "sp_pla_use" and type ="U")
	  drop table sp_pla_use;

create table sp_pla_use
(
	placecode		char(5)		not null,								/*场地号*/
	no					char(10)		not null,
	inumber			integer		not null,
	sno				char(20)		not null,								/*卡号明码*/
	empno				char(3)		default '' not null,					/*服务员*/
	sta				char(1)		default '' not null,
	bdate				datetime		not null,								/*日期*/
	stime				datetime		default	getdate()	not null,	/*开始时间*/
	etime				datetime		null		,								/*截止时间*/
	amount			money			default 0   not null					/*场租费*/
)
;
create unique index index1 on sp_pla_use(no,inumber,bdate)
;


if exists(select * from sysobjects where name = "sp_vipcard" and type ="U")
	  drop table sp_vipcard;

create table sp_vipcard
(
	no					char(10)		default '' not null,					/*卡号*/
	card_type		char(1)		default ''	not null,				//卡类型
	type				char(1)		default '' not null,					//记次标记,是否记次，1-N，2-记总次数,3-分场地记次
	allow_times		money 		default 0  not null,					//允许使用总次数(针对记总次数的有效)
	use_times		money 		default	0 not null,					//已经使用的次数(针对记总次数的有效)
	pccodes			char(255)	default ''	not null,				//该卡适用于哪些营业点
	places			char(255)	default	''	not null,				//该卡适用于哪些场地
	bdate				datetime		not null,	
	empno				char(10)		default '' not null
	
)
;
create unique index index1 on sp_vipcard(no)
;

if exists(select * from sysobjects where name = "sp_place_times" and type ="U")
	  drop table sp_place_times;

create table sp_place_times
(
	no					char(10)		default '' not null,					/*卡号*/
	inumber			integer		default 0	not null,
	sort				char(2)		default '' not null,					//场地号
	begin_date		datetime			not null,	
	end_date			datetime			not null,
	allow_times		money 		default 0  not null,					//允许使用总次数(针对记总次数的有效)
	use_times		money 		default	0 not null,					//已经使用的次数(针对记总次数的有效)
	type				char(1)		default '' not null,					//是不是优惠的标记
	
	
)
;
create unique index index1 on sp_place_times(no,inumber,sort)
;

/*场地维修单信息*/

if exists(select * from sysobjects where name = "sp_plaooo" and type ="U")
	  drop table sp_plaooo;

create table sp_plaooo
(
	menu				char(10)		not null,								/*电脑单号*/
	inumber			int			default 0  not null,					/*流水号*/
	sno				char(10)		not null,								/*维修单号*/
	placecode		char(5)		not null,								/*场地号*/
	empno				char(3)		default '' not null,					/*维修员*/
	bdate				datetime		not null,								/*账务日期*/
	shift				char(1)		not null,								/*班别*/
	sta				char(1)		default 'O' not null,				/*状态：O - 维修; D - 修改*/
	logdate			datetime		not null,								/*时间*/
	stime				datetime		default	getdate()	not null,	/*开始时间*/
	etime				datetime		null										/*截止时间*/
)
exec sp_primarykey sp_plaooo, menu,inumber
create unique index index1 on sp_plaooo(menu, inumber)
;
select * into sp_hplaooo from sp_plaooo where 1=2;
create unique index index1 on sp_hplaooo(menu, inumber)
;
/*	预订主单 */

if  exists(select * from sysobjects where name = "sp_reserve" and type ="U")
	drop table sp_reserve
;
create table sp_reserve
(
	resno					char(10)				not null,
	tag					char(1)				not null,	/*就餐类别*/
	bdate					datetime				not null,	/*就餐日期 -- 对应账务日期*/
	date0					datetime				not null,	/*就餐日期,时间*/
	shift					char(1)				not null,
	name					varchar(50)			null,       /*联系人*/
	unit					varchar(60)			not null,	/*主方单位*/
	phone					char(20)				null,
	tables				integer default 1	not null,	/*桌数*/
	guest					integer				not null,	/*客人数*/
	standent				money default 0	not null,   /*标准*/
	stdunit				char(1)				null,       /*标准单位*/  
	stdno					char(2)				null,
	deptno				char(2)				not null,	/*部门号*/
	pccode				char(2)				not null,	/*厅别*/
	tableno				char(4)				null,			/*桌号,对团体,其为桌号群中的第一个*/
	paymth				char(1) default '0' not null, /*支付方式*/
	mode					char(3)				null,			/*模式*/
	sta					char(1)				not null,	/*状态,"1"预订,"2"确认,"7"登记*/
	cusno					char(7)				null,			/*往来单位号*/
	haccnt				char(7)				null,			/*客人号*/
	tranlog				char(10)				null,			/*协议号*/
	menu_header			text					null,			/*菜式安排*/
	menu_detail			text					null,			/*菜式安排*/
	menu_footer			text					null,			/*菜式安排*/
	remark				text					null,			/*备注*/
	menu					char(10)				null,			/*登记后的菜单号*/
	amount				money default 0	null,			/*消费金额*/
	doc					varchar(250)		null,			/*ole 文档*/
	empno					char(3)				not null,	/*操作员*/
	date					datetime	default getdate()	not null,	/*输入时间*/
	email					char(30)	default '' not null,	/**/
	unitto	 			char(40) default '' null,		/*客方单位*/
	araccnt				char(7)	default '' null,     /*记账账号*/
	accnt					char(10)	default '' null,     /*全局预定账号*/
	flag					char(10)	default '' null,     /*附加态*/ 
	logmark				int	   default 0      ,
   saleid            char(3)  default '' not null ,     /*销售员*/            
	systype				char(2)	default '' not null,
	cardno				char(10)	default ''	not null
)
exec sp_primarykey sp_reserve,  resno
create unique index index1 on sp_reserve(menu, resno)
create index index2 on sp_reserve(bdate, resno)
create index index3 on sp_reserve(name, bdate)
;
if not exists(select 1 from pos_reserve where resno = 'R999999999')
	insert into pos_reserve (	resno	,tag,	bdate,date0,shift,name,	unit,phone,tables,guest,standent,stdunit,deptno,pccode,mode,sta,empno,date,email,flag, logmark)
values('R999999999', '1', '1994/06/30', '1994/06/30','1', 'CYJ','WestLake', '88231199',1, 10, 2000, '1','','10','000','1','CYJ',getdate(),'','',1 )
;
if  exists(select * from sysobjects where name = "sp_hreserve" and type ="U")
	drop table sp_hreserve;

select * into sp_hreserve from sp_reserve where 1=2;

exec sp_primarykey sp_hreserve, resno
create unique index index1 on sp_hreserve(resno)
create index index2 on sp_hreserve(bdate, resno)
create index index3 on sp_hreserve(name, bdate)
;



/* 点菜明细菜单 */

if  exists(select * from sysobjects where name = "sp_dish" and type ="U")
	 drop table sp_dish
;
create table sp_dish
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
	number		money			not null,					/*数量*/
	amount		money			not null,					/*金额*/
	empno			char(10)		null,							/*输入员工号*/
	bdate			datetime		not null,
	date0			datetime		default getdate()	not null,	/*输入(点)时间*/
	date1			datetime		null, 							 	/*烧菜时间, 计时菜的开始时间*/
	date2			datetime		null,   								/*出菜时间, 计时菜的结束时间*/
	special		char(1)		default	''		not	null,		/*特优折扣码标志, T:特优折扣, X: 特殊类, S:计时类*/
	sta			char(1)		default	'0'	not	null,		/*状态*/
	flag			char(10)		default	''		not 	null,		/*附加态*/   /* c:已上传厨房, d:缺菜, o:已出菜, r:还在计时, s:停止计时, t:上桌, m:套菜*/
	reason		char(3)		default	''		not 	null,		/*优惠原因*/
	remark		varchar(30)	default	''		not 	null,		/*备注*/
	id_cancel	integer		default	0	not null,					/*调整对应明细*/ 
	id_master	integer		default	0	not null,					/*明细到标准的指针*/
	empno1		char(10)		default	''	not null,					/*厨师技师*/
	empno2		char(10)		default	''	not null,					/*划单员*/
	empno3		char(10)		default	''	not null,					/*销售员*/
	orderno		varchar(10)	default  '' not null,					/*小单号*/
	srv			money			default 0 	not null,         /*服务费*/
	dsc			money			default 0 	not null,         /*折扣*/
	tax			money			default 0 	not null,         /*税*/
	tableno		char(6)		default	''	not null,			/*台号*/
	siteno		char(2)		default	''	not null				/*座位号*/
)
exec sp_primarykey sp_dish,menu,inumber
create unique index index1 on sp_dish(menu,inumber)
;

if  exists(select * from sysobjects where name = "sp_hdish" and type ="U")
	 drop table sp_hdish
;
select * into sp_hdish from sp_dish
exec sp_primarykey sp_hdish,menu,inumber
create unique index index1 on sp_hdish(menu,inumber)
;

if  exists(select * from sysobjects where name = "sp_tdish" and type ="U")
	 drop table sp_tdish
;
select * into sp_tdish from sp_dish
exec sp_primarykey sp_tdish,menu,inumber
create unique index index1 on sp_tdish(menu,inumber)
;

/*	点菜菜单主单 */

if  exists(select * from sysobjects where name = "sp_menu" and type ="U")
	drop table sp_menu
;
create table sp_menu
(
	tag					char(1)		default ""	not null,	/*客人类别,"0"零点,"1"团体,"2"个人,"3"旅游团,"4工作餐,"5"自助餐*/
	tag1					char(1)		default ""	not null,	/*备用*/
	tag2					char(1)		default ""	not null,	/*备用*/
	tag3					char(1)		default ""	not null,	/*备用 -- 叫起 T*/
	menu					char(10)		default ""	not null,	/*菜单号*/
	tables				integer		default 1	not null,	/*桌数*/
	guest					integer		default 1	not null,	/*客人数*/
	date0					datetime		default getdate()	not null,	/*输入时间*/
	bdate					datetime		default getdate()	not null,	/*就餐时间*/
	shift					char(1)		default "1"	not null,
	deptno				char(2)		default ""	not null,	/*部门号*/
	pccode				char(3)		default ""	not null,	/*厅别*/
	posno					char(2)		default ""	not null,	/*收银点号*/
	tableno				char(4)		null,			/*桌号,对团体,其为桌号群中的第一个*/
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
	empno1				char(10)		null,							/*服务员*/
	empno2				char(10)		null,							/*备用*/
	empno3				char(10)		default '' not null,		/*操作员*/
	sta					char(1)		default '2' not null,	/*状态,"1"预订,"2"登记,"3"结帐,"5"重结,"7"删除*/
	paid					char(1)		default "0"	not null,	/*结帐状态,"0"未结,"1"已结,"2"被冲*/
	setmodes				char(4)		null,			/*最后一次付款方式,最后位为*表示多笔付款*/
	cusno					char(10)		null,			/*往来单位号*/
	haccnt				char(10)		null,			/*客人号*/
	tranlog				varchar(10)	null,			/*协议号*/
	foliono				varchar(20)	null,			/*手工单号*/
	remark				varchar(40)	null,			/*备注*/
	roomno				char(5)		null,			/**/
	accnt					char(10)		null,			/**/
	lastnum				integer		default 0	not null,	/*明细帐行次*/
	pcrec					char(10)		null,			/*并单*/
	pc_id					char(8)		null,			/*最后一次操作的IP地址,只有未结单有效*/
	timestamp			timestamp	not null,	/*时间戳*/
	guestid				char(10)		null	,		/*客人号*/
   saleid            char(10)    default '' not null,
	empno1_name       char(8)     default '' not null,
	cardno				char(20)		default '' not null
)
exec sp_primarykey sp_menu,menu
create unique index index1 on sp_menu(menu)
create index index2 on sp_menu(cusno)
create index index3 on sp_menu(haccnt)
;

if  exists(select * from sysobjects where name = "sp_hmenu" and type ="U")
	 drop table sp_hmenu
;
select * into sp_hmenu from sp_menu
exec sp_primarykey sp_hmenu,menu
create unique index index1 on sp_hmenu(menu)
create index index2 on sp_hmenu(cusno)
create index index3 on sp_hmenu(haccnt)
create index index4 on sp_hmenu(tranlog)
create index index5 on sp_hmenu(bdate)
;

if  exists(select * from sysobjects where name = "sp_tmenu" and type ="U")
	 drop table sp_tmenu
;
select * into sp_tmenu from sp_menu
exec sp_primarykey sp_tmenu,menu
create unique index index1 on sp_tmenu(menu)
;


if exists(select * from sysobjects where type ='U' and name = 'sp_menu_bill')
	drop table sp_menu_bill
;
create table sp_menu_bill
(
	menu			char(10) default ''  not null,				/*  */
	hline			int 		default 0   not null,				/* 已打印行 */
	hpage			int 		default 0   not null,				/* 已打印页 */
	inumber		int		default 0   not null,				/* 已打印菜序号 */
	hamount		money		default 0 	not null,				/*记录已打印的金额*/
	dsc			money		default 0   not null,				/*折扣  */
	srv			money		default 0   not null,				/*服务费  */
	tax			money		default 0   not null	,				/*税  */
	bill			integer	default 0	not null
)
;
exec sp_primarykey sp_menu_bill,menu
create unique index index1 on sp_menu_bill(menu)
;
/*  付款  */

if exists(select * from sysobjects where type ='U' and name = 'sp_pay')
	drop table sp_pay
;
create table sp_pay
(
	menu			char(10)		not null,								/* 单号,预定号 */
	number		integer		default 1 not null,					/* 序号 */
	inumber		integer		default 1 not null,					/* 关联序号 */
	paycode		char(3)		not null,								/* 付款方式 */
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
	bank			char(10)		default''	not null,
	credit		money			default 0	not null,
	cardno		char(20)		default ''	not null,
	ref			char(40)		default ''	not null,
	quantity		money			default 0	not null
)
exec sp_primarykey sp_pay, menu,number
create unique index index1 on sp_pay(menu, number)
;

if  exists(select * from sysobjects where name = "sp_tpay" and type ="U")
	 drop table sp_tpay
;
select * into sp_tpay from sp_pay
exec sp_primarykey sp_tpay,menu,number
create unique index index1 on sp_tpay(menu,number)
;

if  exists(select * from sysobjects where name = "sp_hpay" and type ="U")
	 drop table sp_hpay
;
select * into sp_hpay from sp_pay
exec sp_primarykey sp_hpay,menu,number
create unique index index1 on sp_hpay(menu,number)
;


/*	预订主单 */

if  exists(select * from sysobjects where name = "sp_reserve" and type ="U")
	drop table sp_reserve
;
create table sp_reserve
(
	resno					char(10)				not null,
	tag					char(1)				not null,	/*就餐类别*/
	bdate					datetime				not null,	/*就餐日期 -- 对应账务日期*/
	date0					datetime				not null,	/*就餐日期,时间*/
	shift					char(1)				not null,
	name					varchar(50)			null,       /*联系人*/
	unit					varchar(60)			not null,	/*主方单位*/
	phone					char(20)				null,
	tables				integer default 1	not null,	/*桌数*/
	guest					integer				not null,	/*客人数*/
	standent				money default 0	not null,   /*标准*/
	stdunit				char(1)				null,       /*标准单位*/  
	stdno					char(2)				null,
	deptno				char(2)				not null,	/*部门号*/
	pccode				char(3)				not null,	/*厅别*/
	tableno				char(4)				null,			/*桌号,对团体,其为桌号群中的第一个*/
	paymth				char(1) default '0' not null, /*支付方式*/
	mode					char(3)				null,			/*模式*/
	sta					char(1)				not null,	/*状态,"1"预订,"2"确认,"7"登记*/
	cusno					char(7)				null,			/*往来单位号*/
	haccnt				char(10)				null,			/*客人号*/
	tranlog				char(10)				null,			/*协议号*/
	menu_header			text					null,			/*菜式安排*/
	menu_detail			text					null,			/*菜式安排*/
	menu_footer			text					null,			/*菜式安排*/
	remark				text					null,			/*备注*/
	menu					char(10)				null,			/*登记后的菜单号*/
	amount				money default 0	null,			/*消费金额*/
	doc					varchar(250)		null,			/*ole 文档*/
	empno					char(10)				not null,	/*操作员*/
	date					datetime	default getdate()	not null,	/*输入时间*/
	email					char(30)	default '' not null,	/**/
	unitto	 			char(40) default '' null,		/*客方单位*/
	araccnt				char(10)	default '' null,     /*记账账号*/
	accnt					char(10)	default '' null,     /*全局预定账号*/
	flag					varchar(50)	default '' null,     /*附加态*/ 
	logmark				int	   default 0      ,
   saleid            char(10)  default '' not null,     /*销售员*/            
	reserveplu			text						null	,			/*预定时点的菜*/
	cardno				char(10)	default '' not null
)
exec sp_primarykey sp_reserve,  resno
create unique index index1 on sp_reserve(menu, resno)
create index index2 on sp_reserve(bdate, resno)
create index index3 on sp_reserve(name, bdate)
;
if not exists(select 1 from sp_reserve where resno = 'R999999999')
	insert into sp_reserve (	resno	,tag,	bdate,date0,shift,name,	unit,phone,tables,guest,standent,stdunit,deptno,pccode,mode,sta,empno,date,email,flag, logmark)
values('R999999999', '1', '1994/06/30', '1994/06/30','1', 'CYJ','WestLake', '88231199',1, 10, 2000, '1','','10','000','1','CYJ',getdate(),'','',1 )
;
if  exists(select * from sysobjects where name = "sp_hreserve" and type ="U")
	drop table sp_hreserve;
select * into sp_hreserve from sp_reserve where 1=2;
exec sp_primarykey sp_hreserve,  resno
create unique index index1 on sp_hreserve(menu, resno)
create index index2 on sp_hreserve(bdate, resno)
create index index3 on sp_hreserve(name, bdate)
;

if  exists(select * from sysobjects where name = "sp_reserve_log" and type ="U")
	drop table sp_reserve_log
;
select * into sp_reserve_log from sp_reserve
exec sp_primarykey sp_reserve_log,resno,logmark
create unique index index1 on sp_reserve_log(resno,logmark)
;

if exists(select * from sysobjects where name = "sp_operate" and type ="U")
	  drop table sp_operate;

CREATE TABLE sp_operate
 (
	class 			char(1)  default ''  not null,
	descript			char(20) default ''	not null,
	descript1 		char(40)	default ''	not null
)
;
create unique index index1 on sp_operate(class,descript)
;



if exists(select * from sysobjects where name = "sp_color_define" and type ="U")
	  drop table sp_color_define;

CREATE TABLE sp_color_define
 (
	number			integer	default 0	not null,
	color				char(20) default ''	not null,
	descript			char(40)	default ''	not null
)
;
create unique index index1 on sp_color_define(number)
;


//教练
if exists(select * from sysobjects where name = "sp_dlmaster" and type ="U")
	  drop table sp_dlmaster;

create table sp_dlmaster
(
	empno				char(10)		default '' not null,					
	name				char(50)		default '' not null,
	skill				char(100)	default '' null,						//技能
	remark			char(100)	default '' null,
	bdate				datetime		default '' not null
	
)
;
create unique index index1 on sp_dlmaster(empno)
;

//教练计划
if exists(select * from sysobjects where name = "sp_guest" and type ="U")
	  drop table sp_guest;

create table sp_guest
(
	cardno			char(20)		default '' not null,	
	date0				datetime		not null,
	high				money			default	0 null,
	weight			money			default  0  null,
	ill				char(100)	default '' null,
	marry				char(1)		default 'F' null,
	content			text			default '' null,
	sta				char(1)		default '' not null,	 
	bdate				datetime		default '' not null
)
;
create unique index index1 on sp_guest(cardno)
;



//教练计划
if exists(select * from sysobjects where name = "sp_plan" and type ="U")
	  drop table sp_plan;

create table sp_plan
(
	cardno			char(20)		default '' not null,	
	inumber			integer		default 0  not null,
	date0				datetime		not null,
	title				char(100)	default '' not null,
	intent         text        default		null,				//	训练目的	
	content			text			default '' null,			//指导内容
	feel				text			default '' null,			//自我感觉
	mind				text			default '' null,        //教练意见
	master			char(10)		default '' not null,
	sta				char(1)		default '' not null,	 
	bdate				datetime		default '' not null,
	empno				char(10)		default '' not null
)
;
create unique index index1 on sp_plan(cardno,inumber)
;

//投诉
if exists(select * from sysobjects where name = "sp_mind" and type ="U")
	  drop table sp_mind;

create table sp_mind
(
	class				char(20)		default '' not null,	
	date0				datetime		default '' not null,
	inumber			integer		default 0  not null,
	cardno			char(20)		default '' null,
	name				char(60)		default '' not null,
	content			text			default '' null,			//投诉内容
	result			text			default '' null,			//解决
	bdate				datetime		default '' not null,
	empno				char(10)		default '' not null
)
;
create unique index index1 on sp_mind(class,inumber)
;

//提醒
if exists(select * from sysobjects where name = "sp_remind" and type ="U")
	  drop table sp_remind;

create table sp_remind
(
	menu				char(20)		default '' not null,	
	inumber			integer		default 0  not null,
	placecode		char(5)		default '' not null,
	stime				datetime		default 0  not null,
	etime				datetime		default '' not null,
	name				char(60)		default '' not null,
	empno				char(10)		default '' not null,
	times				integer		default 0  null
)
;
create unique index index1 on sp_remind(menu,inumber,placecode)
;

//存物柜
if exists(select * from sysobjects where name = "sp_locker" and type ="U")
	  drop table sp_locker;

create table sp_locker
(
	code				char(5)		default '' not null,	
	descript			char(10)		default ''   null,
	descript1		char(10)		default ''   null
)
;
create unique index index1 on sp_locker(code)
;

if exists(select * from sysobjects where name = "sp_rent" and type ="U")
	  drop table sp_rent;

create table sp_rent
(
	code				char(5)		default '' not null,    //寄存柜号码
	inumber			integer		default 0  not null,
	cardno			char(20)		default '' not null,
	sex				char(1)		default '' not null,
	name				char(50)		default ''	not null,
	stime				datetime		not null,
	etime				datetime		not null,
	menu				char(10)		default '' not null,	
	amount			money			default 0 not null,
	pay				char(50)		default '' not null
)
;
create unique index index1 on sp_rent(code,inumber)
;


if exists(select * from sysobjects where name = "sp_analyse" and type ="U")
	  drop table sp_analyse;

create table sp_analyse
(
	id					integer				not null,
	descript			char(100)			not null,
	descript1		char(100)			not null,
	datawindow		char(50)				not null,
	parm				char(200)			null,
)
;
create unique index index1 on sp_analyse(descript)
;

////卡使用场地定义coach
//if exists(select * from sysobjects where name = "sp_vipcard_define" and type ="U")
//	  drop table sp_vipcard_define;
//
//create table sp_vipcard_define
//(
//	card_type		char(1)		default '' not null,					/*卡类别*/
//	class				char(1)		default '' not null,					//定义的类型1-适用区域定义，2-场地定义
//	inumber			integer		default 0	not null,
//	sort				char(2)		default '' not null,					//场地号
//	allow_times		money 		default 0  not null,					//允许使用次数
//	pccodes			char(255)	default '' not null,					//允许使用的营业项目
//	places			char(255)	default '' not null					//允许使用的康乐营业项目
//	
//)
//;
//create unique index index1 on sp_vipcard_define(card_type,inumber)
//;
////优惠策略明细
//if exists(select * from sysobjects where name = "sp_benefit_detail" and type ="U")
//	  drop table sp_benefit_detail;
//
//create table sp_benefit_detail
//(
//	card_type		char(1)		default '' not null,					/*卡类别*/
//	class				char(1)		default ''  not null,				//策略编号
//	inumber			integer		default 0	not null,
//	sort				char(2)		default '' not null,					//场地号
//	allow_times		money 		default 0  not null,					//允许使用次数
//	
//	
//)
//;
//create unique index index1 on sp_benefit_detail(card_type,class,inumber)
//;
////优惠策略定义
//if exists(select * from sysobjects where name = "sp_vipcard_benefit" and type ="U")
//	  drop table sp_vipcard_benefit;
//
//create table sp_vipcard_benefit
//(
//	card_type		char(1)		default '' not null,					/*卡类别*/
//	class				char(1)		default ''  not null,				//策略编号
//	inumber			integer		default 0	not null,
//	descript			char(60)		default '' not null,					//策略名称
//	descript1		char(60)		default '' not null,					//策略名称
//	begin_date		datetime		not null,
//	end_date			datetime		not null,
//	used				char(1)		default 'F' not null	,				//当前使用标记
//	alway				char(1)		default 'F' not null					//是否一只使用的标记
//	
//	
//)
//;
//create unique index index1 on sp_vipcard_benefit(card_type,class,inumber)
//;
//
//