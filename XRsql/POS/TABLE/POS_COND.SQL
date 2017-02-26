
--辅料定义
--1.辅料分三层关系,也可以只定义两层(辅料组,辅料成员,辅料明细)
--2.辅料包括烹饪要求
--3.包含吧台管理明细


--辅料组定义
create table pos_condgp
(
	code			char(4)						 not null,		/*辅料组代码*/
	descript 	char(40)						 not null,		/*中文描述*/
	descript1	char(40)						 null,			/*英文描述*/
	flag			char(1)		default	''  not null,		/*标记(P-配料,B-吧台管理,C-烹饪要求F-辅料)*/
	dish_use		char(1)		default 'F'	 not null,
   pccodes     char(100)   NULL								/*该类烧法适用餐厅范围*/
)
exec sp_primarykey pos_condgp,code
create unique index index1 on pos_condgp(code)

;

--辅料成员定义
create table pos_condst
(
	condid		integer		default 0  not null,						/*辅料类代码*/
	descript 	char(40)		default '' not null,						/*中文描述*/
	descript1	char(40)		null,											/*英文描述*/
	helpcode		char(20)		not null,									/*帮助码*/
	unit			char(4)		default '' not null,						/*单位*/
	price			money			default 0  not null,						/*价格*/
	empflag		char(1)		default '' not null,						/*管到人的工号标识*/
	barflag		char(1)		default '' not null,						/*管到吧台的工号标识*/
	condgp		char(100)	not null	,									/*所属辅料组,支持多个辅料组*/	
	sequence		char(6)		default '' not null,						/*次序*/
	empno			char(10)		default '' not null,						/*操作员工号*/
	date			datetime		default '' not null,						/*日期(与日志保持一致)*/
	logmark		int			default 0  not null,						/*日志序号*/ 
	wpcode		char(12)		default '' not null						/*同其他物流系统衔接*/ 
	
)
exec sp_primarykey pos_condst,condid
create unique index index1 on pos_condst(condid)

;

--辅料成员定义
if exists(select * from sysobjects where name = "pos_condst_log" and type ="U")
	drop table pos_condst_log;

create table pos_condst_log
(
	condid		integer		default 0  not null,						/*辅料类代码*/
	descript 	char(40)		default '' not null,						/*中文描述*/
	descript1	char(40)		null,											/*英文描述*/
	helpcode		char(20)		not null,									/*帮助码*/
	unit			char(4)		default '' not null,						/*单位*/
	price			money			default 0  not null,						/*价格*/
	empflag		char(1)		default '' not null,						/*管到人的工号标识*/
	barflag		char(1)		default '' not null,						/*管到吧台的工号标识*/
	condgp		char(100)	not null	,									/*所属辅料组,支持多个辅料组*/	
	sequence		char(6)		default '' not null,						/*次序*/
	empno			char(10)		default '' not null,						/*操作员工号*/
	date			datetime		default '' not null,						/*日期(与日志保持一致)*/
	logmark		int			default 0  not null,						/*日志序号*/ 
	wpcode		char(12)		default '' not null						/*同其他物流系统衔接*/ 
	
)
exec sp_primarykey pos_condst_log,condid,logmark
create unique index index1 on pos_condst_log(condid,logmark)

;

--辅料明细定义
if exists(select * from sysobjects where name = "pos_conddtl" and type ="U")
	drop table pos_conddtl;

create table pos_conddtl
(
	condid		integer		default 0	not null,	/*所属辅料成员*/
	inumber		integer		default 0	not null,	/*辅料明细代码*/
	descript 	char(40)		default ''	not null,	/*中文描述*/
	descript1	char(40)						null,			/*英文描述*/
	unit			char(4)		default ''	not null		/*单位*/	
)
exec sp_primarykey pos_conddtl,condid,inumber
create unique index index1 on pos_conddtl(condid,inumber)

;

--	临时菜配料输入临时存放表
CREATE TABLE pos_condbuf 
(
    menu      char(10)    DEFAULT '' NOT NULL,				-- pos_order.menu
    inumber   int         DEFAULT 0 NOT NULL,				-- pos_order.inumber
    inumber0  int         DEFAULT 0 NOT NULL,
    bdate     datetime    NOT NULL,	
    id    	  int         DEFAULT 0 NOT NULL,				-- pos_condst.condid or pos_plu.id
    descript  varchar(40) DEFAULT '' NOT NULL,	         -- 配料名称
    descript1 varchar(40) DEFAULT '' NOT NULL,	         -- 配料名称1
    unit      char(4)     DEFAULT '' NOT NULL,	         -- 单位
    number    money       DEFAULT 0 NOT NULL,	         -- 数量
    price     money       DEFAULT 0 NOT NULL,	         -- 单价
    amount    money       DEFAULT 0 NOT NULL,	         -- 金额
    type      char(1)     DEFAULT '0' NOT NULL           -- '0' - 菜谱, '1' - 配料
)

EXEC sp_primarykey 'pos_condbuf', menu,inumber,inumber0

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON pos_condbuf(menu,inumber,inumber0)
;

CREATE TABLE pos_hcondbuf 
(
    menu      char(10)    DEFAULT '' NOT NULL,				-- pos_order.menu
    inumber   int         DEFAULT 0 NOT NULL,				-- pos_order.inumber
    inumber0  int         DEFAULT 0 NOT NULL,
    bdate     datetime    NOT NULL,	
    id    	  int         DEFAULT 0 NOT NULL,				-- pos_condst.condid or pos_plu.id
    descript  varchar(40) DEFAULT '' NOT NULL,	         -- 配料名称
    descript1 varchar(40) DEFAULT '' NOT NULL,	         -- 配料名称1
    unit      char(4)     DEFAULT '' NOT NULL,	         -- 单位
    number    money       DEFAULT 0 NOT NULL,	         -- 数量
    price     money       DEFAULT 0 NOT NULL,	         -- 单价
    amount    money       DEFAULT 0 NOT NULL,	         -- 金额
    type      char(1)     DEFAULT '0' NOT NULL           -- '0' - 菜谱, '1' - 配料
)

EXEC sp_primarykey 'pos_hcondbuf', menu,inumber,inumber0

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON pos_hcondbuf(menu,inumber,inumber0)
;



/* 吧台酒水库进销存 表结构*/

/* 吧台代码 */
if exists(select 1 from sysobjects where name = 'pos_store' and type ='U')
	drop table pos_store;
create table pos_store 
(
	code 			char(3) 		not null,
	descript		char(20)		not null,
	descript1	char(50)		null,
	pccodes		char(100)	not null,      				/*吧台对应的营业点*/
	empno			char(10)		default ''	not null,      /*管到人*/
	sup			char(6)		null,								/*所属仓库*/
)
;
exec sp_primarykey pos_store,code
create unique index index1 on pos_store(code)
;



/*	配料销售明细表 */

if exists(select * from sysobjects where name = "pos_sale" and type ="U")
	drop table pos_sale;

create table pos_sale
(
	type			char(1)	default '0' not null,			/*'0' 通过菜品销售\ '1' 通过原料销售*/
	menu			char(10)	not null,							/*单号*/
	inumber		integer	not null,							/*DISH序号*/
	pccode		char(3)	not null,							/*营业点*/
	storecode	char(3) 	not null,							/*仓库代码*/
	id				integer	default 0	not null,			/*菜ID号*/
	number		money		default 0   not null,			/*菜份量*/
	amount		money		default 0   not null,			/*销售金额*/
	pnumb			integer	default 0	not null,			/*价格序号*/
	condid		integer	default 0	not null,			/*辅料成员的ID号*/
	unit			char(4)	default ''	not null,			/*单位*/
	descript		char(40)	default ''  not null,			/*配料描述*/
	number0		money		default 0	not null,			/*配料销售数量*/
	amount0		money		default 0   not null,			/*配料销售金额*/
	empno			char(10) default ''	not null,			/*操作员工号*/
	bdate 		datetime					not null,			/*营业日期*/
	logdate		datetime					not null				/*日志日期*/
)
;
exec sp_primarykey pos_sale,type, menu,inumber,condid
create unique index index1 on pos_sale(type,menu,inumber,condid)
;

/*	配料历史销售明细表 */

if exists(select * from sysobjects where name = "pos_hsale" and type ="U")
	drop table pos_hsale;

create table pos_hsale
(
	type			char(1)	default '0' not null,			/*'0' 通过菜品销售\ '1' 通过原料销售*/
	menu			char(10)	not null,							/*单号*/
	inumber		integer	not null,							/*DISH序号*/
	pccode		char(3)	not null,							/*营业点*/
	storecode	char(3) 	not null,							/*仓库代码*/
	id				integer	default 0	not null,			/*菜ID号*/
	number		money		default 0   not null,			/*菜份量*/
	amount		money		default 0   not null,			/*销售金额*/
	pnumb			integer	default 0	not null,			/*价格序号*/
	condid		integer	default 0	not null,			/*辅料成员的ID号*/
	unit			char(4)	default ''	not null,			/*单位*/
	descript		char(40)	default ''  not null,			/*配料描述*/
	number0		money		default 0	not null,			/*配料销售数量*/
	amount0		money		default 0   not null,			/*配料销售金额*/
	empno			char(10) default ''	not null,			/*操作员工号*/
	bdate 		datetime					not null,			/*营业日期*/
	logdate		datetime					not null				/*日志日期*/
)
;
exec sp_primarykey pos_hsale,type,menu,inumber,condid
create unique index index1 on pos_hsale(type,menu,inumber,condid)
;


/* 从物流库倒入入库单 */
if exists(select 1 from sysobjects where name = 'pos_store_sup' and type ='U')
	drop table pos_store_sup;
create table pos_store_sup
(
	bdate			datetime		default getdate() not null, /*营业日期日期*/
	supcode		char(10)		not null,     /*吧台、部门代码*/
	code 			char(12) 	not null,     /*物品代码*/
	descript		char(30)    not null,	  /*物品名称*/ 
	descript1	char(60)    null,
	number		money			not null,     /* 数量 */
	amount		money			not null,     /* 金额 */
	remark		varchar(20)	null          /* 备注 */
)
;
exec sp_primarykey pos_store_sup,supcode,code
create unique index index1 on pos_store_sup(supcode, code)
;	



