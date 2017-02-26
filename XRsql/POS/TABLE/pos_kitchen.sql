------------------------------------------------------------------------------
--厨房打印表结构定义
--1.打印控制站点的定义(餐厅比较多,厨房比较多的情况适合使用,通常情况下只需一个)
--2.打印机的定义(包括打印机名称的设置,IP地址等)
--3.厨房定义(一个厨房对应一个打印机,一个备用打印机,一个打印控制站点)
--4.菜谱厨房定义(哪个餐厅点的哪个菜对应哪几个厨房)
------------------------------------------------------------------------------


--打印控制站点定义

create table pos_pserver
(
	code			char(3)		not null,	/*控制站点的代码*/
	descript 	char(40)		not null,	/*中文描述*/
	descript1	char(40)		null,			/*英文描述*/
	pc_id			char(4)		not null		/*控制站点的IP*/
)
exec sp_primarykey pos_pserver,code
create unique index index1 on pos_pserver(code)

;

--打印机定义

create table pos_printer
(
	code			char(3)			not null,				/*打印机代码*/
	descript 	char(40)			not null,				/*中文描述*/
	descript1	char(40)			null,						/*英文描述*/
	name			char(100) 		not null,				/*系统打印机名称*/
	pc_id			char(15)   	 	null,						/*打印机对应打印服务器的IP*/
	oid			char(50)			null,						/*打印机的资源信息*/
	sta			char(1)			null,						/*打印机当前状态,1-正常,2-缺纸,3-其他错误*/
	sta1			char(1)			null,						/*打印机当前状态刷新*/
	set0			char(1)			default 'T' not null,/*是否逐个打印*/
	set1			char(1)			default 'T' not null,/*是否打印辅料*/
	set2			char(1)     	default 'T' not null,/*辅料是否颜色区分*/
	set3			char(1)			default 'T' not null,/*是否用条形码显示*/
	set4			char(1)			default 'T' not null,/*是否打印菜价*/
	set5			char(1)			default 'T' not null,/*备用设置*/
	set6			char(1)     	default 'T' not null,/*备用设置*/
	set7			char(1)			default 'T' not null,/*备用设置*/
	set8			char(1)     	default 'T' not null,/*备用设置*/
	set9			char(1)			default 'T' not null,/*备用设置*/
	value_nr       char(20)  	DEFAULT ''	NOT NULL,
   value_paperoff char(20)  	DEFAULT '' 	NOT NULL,
   value_off      char(20)  	DEFAULT '' 	NOT NULL,
   linktype       char(1)   	DEFAULT '1' NOT NULL,
	printer			char(3)		default '' 	not null,
	pcode				char(3)		default '' 	not null,
	dish_chk			char(4)		default ''	not null  /*划单出菜的PC_ID*/
   value_printing char(20)  	NULL,                 /*正在打印状态*/
   comm           char(2)   	NULL                  /*连到电脑的串口*/
	
)
exec sp_primarykey pos_printer,code
create unique index index1 on pos_printer(code)

;

--厨房定义


--菜谱厨房定义

create table pos_prnscope
(
	pccode		char(3)		default '' not null,	/*与pos_pccode对应的餐厅pccode*/
	plucode  	char(2)		default '' not null,	/*菜本号*/
	plusort		char(4)		default '' not null,	/*菜类号*/
	id				integer		default 0  not null,	/*菜的ID号*/
	kitchens		char(20)		default '' not null,	/*所对应的厨房,可以为多个(***#***#***#)*/
	pluid			integer		default 0  not null  /*菜谱号*/
)
exec sp_primarykey pos_prnscope,pluid, pccode,plusort,id
create unique index index1 on pos_prnscope(pluid, pccode,plusort,id)
;


/*估清单  当前剩余数量 = number + number2 - number1 */
if exists(select * from sysobjects where name = "pos_assess" and type ="U")
	drop table pos_assess
;
create table pos_assess
(
	bdate			datetime		not null,
	id				int			not null,				 /*pos_plu.id*/
	unit			char(4)		null,						 /*单位*/
	number		money			default 0 not null,   /*当日可用数量*/  
	number1		money			default 0 not null,   /*当日已用数量*/  
	number2		money			default 0 not null,   /*调整数量*/  
	empno			char(10)		null,						 /*操作员工号*/
	logdate		datetime		null,						 /*日期*/
	payout		char(1)		null						 /*T:卖光, 用于事先没设估清数，点菜员临时设置*/	
)
exec sp_primarykey pos_assess,bdate,id
create unique index index1 on pos_assess(bdate,id)
;

/* 厨房打印 --  */

if exists(select * from sysobjects where name = "pos_dishcard" and type="U")
	 drop table pos_dishcard
;
create table pos_dishcard
(
	menu  		char(10)  		not null,  				// 账单号
	tableno		char(6)	 		not null,
	printid		integer   		not null,   			// 厨房打印序号序号
  	inumber 		integer   		not null,   			// 序号
  	id		 		integer   		not null,   			// 菜号
  	sta   		char(1)   		not null,       		// 状态 - 
  	code  		char(15)  		not null,       		// 代码
  	name1 		char(20)  		not null,       		// 中文名
  	name2 		char(30)  		null, 	      		// 英文
  	unit    		char(4) 			null,       			// 单位
  	price  		money   			null,        			// 单价
  	number  		money   			default 1	not null,// 份数

	p_number  	int				not null,				//打印份数
	p_number1 	int 				not null,         	//打印份数(查看)

  	empno  		char(10)  		null,       			// 操作员
	date			datetime			not null,				// 时间 -- 同一次打单的时间一致，可以同时打印
																	//    这中间的分类按class 
  	changed 		char(1)  		default 'F' not null,// 打印标志  T=已经打印,F=未打印,
																	//H=表示合并打印
																	//K=厨师长打印
																	//B=出菜口打印
	changed1 	char(1)  		default 'F' not null,// 打印标志 (查看)
	times			integer			default 0	not null,// 打印次数  -- 可以重打，但是要求权限 !
  	pc_id   		char(4) 			null,   					// 工作站点
	printer		char(20) 		default ''  not null,// 打印机
	printer1		char(20) 		default ''  not null,// 打印机(查看)

	refer			varchar(20)		null, 					// 打印补充说明
	cook			varchar(100) 	default '' 	null,		// 烹饪特殊要求
	bdate			datetime			null,
	p_sort		char(3)			null,						//打印级别
	foliono		integer			default 0	null,		/*按流水号打印时原来的打印号*/
	siteno		char(2)			default ''	not null, /*座位号*/
	pdate			datetime			null 						/*打印时间*/

)
exec sp_primarykey pos_dishcard, printid,changed1
create unique index index11 on pos_dishcard(printid,changed1)
create index index2 on pos_dishcard(code)
create index index3 on pos_dishcard(date,menu)
;
if exists(select * from sysobjects where name = "pos_hdishcard" and type="U")
	 drop table pos_hdishcard;
select * into pos_hdishcard from pos_dishcard ;
exec sp_primarykey pos_hdishcard, bdate,printid,changed1
create index index3 on pos_hdishcard(bdate,printid,changed1)
;


// 厨房打印缓冲区打印,记录最近一次打印,如果打印机出问题,在备用打印机上把缓冲区重新打印一遍
CREATE TABLE pos_dishcard_buf 
(
    menu      char(10)     NOT NULL,
    tableno   char(6)      NOT NULL,
    printid   int          NOT NULL,
    inumber   int          NOT NULL,
    id        int          NOT NULL,
    sta       char(1)      NOT NULL,
    code      char(15)     NOT NULL,
    name1     char(20)     NOT NULL,
    name2     char(30)     NULL,
    unit      char(4)      NULL,
    price     money        NULL,
    number    money        DEFAULT 1	 NOT NULL,
    p_number  int          NOT NULL,
    p_number1 int          NOT NULL,
    empno     char(10)     NULL,
    date      datetime     NOT NULL,
    changed   char(1)      DEFAULT 'F' NOT NULL,
    changed1  char(1)      DEFAULT 'F' NOT NULL,
    times     int          DEFAULT 0	 NOT NULL,
    pc_id     char(4)      NULL,
    printer   char(20)     DEFAULT '' NOT NULL,      // 存放上次用到的打印机
    printer1  char(20)     DEFAULT '' NOT NULL,      // 
    refer     varchar(20)  NULL,
    cook      varchar(100) DEFAULT '' 	 NULL,
    bdate     datetime     NULL,
    p_sort    char(3)      NULL,
    foliono   int          DEFAULT 0	 NULL,
    siteno    char(2)      DEFAULT ''	 NOT NULL,
    pdate     datetime     NULL,
	 printer_err char(3)    default '' not null      // 出故障的打印机  
);
EXEC sp_primarykey 'pos_dishcard_buf', printid,changed1;
CREATE UNIQUE NONCLUSTERED INDEX index11
    ON pos_dishcard_buf(printid,changed1);
CREATE NONCLUSTERED INDEX index2
    ON pos_dishcard_buf(code);
CREATE NONCLUSTERED INDEX index3
    ON pos_dishcard_buf(date,menu)
;
if exists(select * from sysobjects where name = "pos_pdishcard" and type="U")
	 drop table pos_pdishcard;
select * into pos_pdishcard from pos_dishcard ;
exec sp_primarykey pos_pdishcard, printid,changed1
create index index3 on pos_pdishcard(printid,changed1)
;
/*-----打印流水号控制------*/
if exists(select * from sysobjects where name = "pos_fdishcard" and type="U")
	 drop table pos_fdishcard
;
create table pos_fdishcard
(
	foliono			integer			default 0	not null,		/*流水号*/
	printid			integer			default ''	not null,		/*流水号对应的所有打印号串*/
	printer			char(3)			default ''	not null,		/*对应打印机*/
	ptype				char(1)			default ''	not null,		/*打印类型*/
	times				integer			default 0	not null,		/*打印次数*/
	p_number			integer			default 0	not null,		/*打印份数*/
	date				datetime			null
	
)
;
exec sp_primarykey pos_fdishcard, foliono,printid
;
create unique index index1 on pos_fdishcard(foliono,printid)
;

insert into basecode_cat (cat,descript,descript1,len,flag,center)
select 'pos_print_sta','餐饮打印机状态', 'Pos Printer Status',1,'','F';
insert into basecode (cat,code,descript,descript1,sys,halt,sequence,grp,center)
select 'pos_print_sta','0','正常','NR','T','F',100,'F','F';
insert into basecode (cat,code,descript,descript1,sys,halt,sequence,grp,center)
select 'pos_print_sta','1','缺纸','No Paper','T','F',200,'F','F';
insert into basecode (cat,code,descript,descript1,sys,halt,sequence,grp,center)
select 'pos_print_sta','2','脱机','Off Line','T','F',300,'F','F';
insert into basecode (cat,code,descript,descript1,sys,halt,sequence,grp,center)
select 'pos_print_sta','9','其他','Other','T','F',400,'F','F';

// 餐单打印单号纪录，用于查询是否有漏单
CREATE TABLE dbo.pos_ktprn 
(
    bdate   datetime NULL,
    menu    char(10) DEFAULT ''	 NOT NULL,
    code    char(10) DEFAULT ''	 NOT NULL,
    prnname char(30) DEFAULT ''	 NOT NULL,
    prntype char(10) DEFAULT ''	 NOT NULL,
    inumber int      DEFAULT 0	 NOT NULL,
    logdate datetime NULL
)
;
EXEC sp_primarykey 'dbo.pos_ktprn', bdate,menu,prnname,prntype,inumber,logdate
;
CREATE NONCLUSTERED INDEX index10
    ON dbo.pos_ktprn(bdate,menu,prnname,inumber)
;


