----------------------------------------------------------------------------------
--
--	餐饮预定类表结构
--
----------------------------------------------------------------------------------
create table pos_reserve_plu
(
	resno			char(10)			default ''  not null,
	plu_id		integer			default 0	not null,
	inumber		integer			default 0	not null,
	descript		char(30)			default ''	not null,
	number		money				default 0	not null,
	cook			char(255)		default ''	null,
	price_id		integer			default 0	not null,
	remark		char(255)		default ''	null
)
;
exec sp_primarykey pos_reserve_plu,resno,plu_id,inumber
create unique index index1 on pos_reserve_plu(resno,plu_id,inumber)
;
/*	预订主单 */

create table pos_reserve
(
	resno					char(10)				not null,
	tag					char(1)				not null,	/*就餐类别*/
	bdate					datetime				not null,	/*输入日期 -- 对应账务日期*/
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
	reserveplu			text						null,				/*预定时点的菜*/
	meet					char(1)	default 'N'	not null,     /*本预定是否有会议信息*/      -- 040524 add
	more					char(1)	default 'N'	not null,     /*本预定是否要订多餐*/        -- 040524 add
	meetname				varchar(60)	default 'N'	not null,  /*会议，活动名称*/   		     -- 040531 add
	ci_date				datetime,								     /*登记日期,含时间*/	
	ciy					char(10) default '' not null,								     /*登记人*/	
	cby					char(10) default '' not null,									 /*修改人*/	
	cg_date				datetime										  /*修改时间*/	

)
exec sp_primarykey pos_reserve,  resno
create unique index index1 on pos_reserve(menu, resno)
create index index2 on pos_reserve(bdate, resno)
create index index3 on pos_reserve(name, bdate)
;

if  exists(select * from sysobjects where name = "pos_hreserve" and type ="U")
	drop table pos_hreserve;
select * into pos_hreserve from pos_reserve where 1=2;
exec sp_primarykey pos_hreserve,  resno
create unique index index1 on pos_hreserve(menu, resno)
create index index2 on pos_hreserve(bdate, resno)
create index index3 on pos_hreserve(name, bdate)
;

if  exists(select * from sysobjects where name = "pos_reserve_log" and type ="U")
	drop table pos_reserve_log
;
select * into pos_reserve_log from pos_reserve
exec sp_primarykey pos_reserve_log,resno,logmark
create unique index index1 on pos_reserve_log(resno,logmark)
;

