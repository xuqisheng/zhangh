--菜谱定义
--1.三层关系,菜本,菜类,菜
--2.可直接定义与辅料的对应关系
--3.可直接定义与厨房的对应关系
--4.可直接定义与模式的对应关系
--5.可直接定义与报表数据项的对应关系
--6.可直接定义是否吧台管理
--7.关于与辅料的对应关系和与厨房的对应关系是否通过对照表定义,还是直接在菜本,菜类和菜的表里定义,优待研究???
--8.价格定义:每个餐厅可对应三个价格,每个价格对应一个成本价
--9.触摸屏的类别定义及与菜谱的关系定义


/*	历史菜谱描述表 */


create table pos_pluid
(
	pluid			int   	not null,					/* 序码 */
	descript		char(40)	not null, 					/* 描述 */
	date0			datetime	null							/* 备用 */
)
;
exec sp_primarykey pos_pluid,pluid
create unique index index1 on pos_pluid(pluid)
;

/*	厨房菜本 */


create table pos_plucode
(
	pluid			int   						not null, 	/* 序码 */
	plucode		char(2)		default '' not null,		/* 代码*/
	descript		char(20)		default '' not null,		/* 描述*/				
	descript1	char(32)		default '' not null,		/* 描述*/
	pccodes		char(200)   default ''  not null,   /* 可用于的餐厅号串*/
	picorder		char(1)   	default 'F' not null     /* 菜本是否可以通过图片点菜 */
)
;
exec sp_primarykey pos_plucode,pluid,plucode
create unique index index1 on pos_plucode(pluid,plucode)
;


/*	当前菜类 */


create table pos_sort
(
	pluid			int							  not null,		/*菜谱序号*/
	plucode		char(2)						  not null,		/*菜本*/
	sort			char(4)						  not null,		/*代码*/
	name1			varchar(30)					  not null,		/*中文描述*/
	name2			varchar(50)		default '' not null,		/*英文描述*/
	condgp1		varchar(100)	default '' not null,		/*对应所需辅料的选择*/		
	condgp2		varchar(100)	default '' not null,		/*对应可选辅料的选择*/
	tocode		varchar(100)	default '' not null,		/*对应报表数据项的选择*/
	cost_f		money				default 0  not null,	   /*菜类毛利率*/
	empno			char(10)						  null,			/*操作员工号*/
	date			datetime						  null,			/*日期(与日志保持一致)*/
	halt			char(1)			default 'F' not null,   /*是否停用*/
	logmark		integer			default 0  not null,
   picpath char(60)     NULL,
   tail    char(2)      NULL,									/*备用*/
   kit     char(5)      DEFAULT '###' NULL            /*物流出品库*/  
	
)
exec sp_primarykey pos_sort,sort
create unique index index1 on pos_sort(sort)
;


/*	菜类汇集 */


select * into pos_sort_all from pos_sort
exec sp_primarykey pos_sort_all,pluid,sort
create unique index index1 on pos_sort_all(pluid,sort)
;

/*	菜类汇集 */


select * into pos_sort_log from pos_sort
exec sp_primarykey pos_sort_log,pluid,sort,logmark
create unique index index1 on pos_sort_log(pluid,sort,logmark)
;


/*	菜谱, 以菜本为单位 */


create table pos_plu
(
	pluid			int				not null,						/*菜谱序号*/
	plucode		char(2)			not null,						/*菜本号*/
	sort			char(4)			not null,						/*类*/
	code			char(6)			not null,						/*代码*/
	id				int				not null,						/*唯一内码*/
	name1			varchar(30)		default '' 			not null,/*中文描述*/
	name2			varchar(50)		default '' 			not null,/*英文描述*/
	helpcode		char(10)			default '' 			not null,/*助记符*/
   helpcode1   char(10)    	DEFAULT '' 			NOT NULL,/*快捷码*/
	menu			char(5)			default '11111'	not null,/*早,中,晚,夜,五的共享*/
	special		char(1)			default ''			not null,/*特优折扣码标志,S - 计时 */
	timecode		char(3)			default ''			not null,/*时段码*/
	flag0			char(1)			default 'F'			not null,/*套菜*/
	flag1			char(1)			default 'F'			not null,/*海鲜*/
	flag2			char(1)			default 'F'			not null,/*早茶*/
	flag3			char(1)			default 'F'			not null,/*自助餐*/
	flag4			char(1)			default 'F'			not null,/*推荐*/
	flag5			char(1)			default 'F'			not null,/*常用菜*/
	flag6			char(1)			default 'F'			not null,/*临时锁菜*/
	flag7			char(1)			default '1'			not null,/*分级*/
	flag8			char(1)			default 'F'			not null,/*出菜口打印*/
	flag9			char(1)			default 'F'			not null,/*厨师长打印*/
	flag10		char(1)			default 'F'			not null,/*合并打印*/
	flag11		char(1)			default 'F'			not null,/*临时菜*/
	flag12		char(1)			default 'F'			not null,/*外卖*/
	flag13		char(1)			default 'F'			not null,/**/
	flag14		char(1)			default 'F'			not null,/**/
	flag15		char(1)			default 'F'			not null,/**/
	flag16		char(1)			default 'F'			not null,/**/
	flag17		char(1)			default 'F'			not null,/**/
	flag18		char(1)			default 'F'			not null,/**/
	flag19		char(1)			default 'F'			not null,/*预付处理标记*/
	condgp1		char(100)		default '' 			not null,/*对应所需辅料的选择*/		
	condgp2		char(100)		default '' 			not null,/*对应可选辅料的选择*/
	tocode		char(100)		default ''			not null,/*对应报表数据项的选择*/
	sta		 	char(1)			default ''  		not null,/*在用状态*/
	th_sort	 	char(3)			default ''  		not null,/*触摸屏上显示的类别, basecode=touch_sort*/
	p_number		int				default 1			not null,/*厨房打印份数*/
	picpath		char(60)			default ''        null,		/*菜图片的路径*/
	empno			char(10)			default '' 			not null,/*操作员工号*/
	date			datetime			default '' 			not null,/*日期(与日志保持一致)*/
	logmark		int				default 0   		not null,/*日志序号*/ 
	remark		varchar(255)	default '' 			not null /*操作员工号*/

)
exec sp_primarykey pos_plu,id
create unique index index1 on pos_plu(pluid,code)
create unique index index2 on pos_plu(id)
create index index3 on pos_plu(sort,code)
;

/*	菜谱汇集 */


create table pos_plu_all
(
	pluid			int				not null,						/*菜谱序号*/
	plucode		char(2)			not null,						/*菜本号*/
	sort			char(4)			not null,						/*类*/
	code			char(6)			not null,						/*代码*/
	id				int				not null,						/*唯一内码*/
	name1			varchar(30)		default '' 			not null,/*中文描述*/
	name2			varchar(50)		default '' 			not null,/*英文描述*/
	helpcode		char(10)			default '' 			not null,/*助记符*/
   helpcode1   char(10)    	DEFAULT '' 			NOT NULL,/*快捷码*/
	menu			char(5)			default '11111'	not null,/*早,中,晚,夜,五的共享*/
	special		char(1)			default ''			not null,/*特优折扣码标志,S - 计时 */
	timecode		char(3)			default ''			not null,/*时段码*/
	flag0			char(1)			default 'F'			not null,/*套菜*/
	flag1			char(1)			default 'F'			not null,/*海鲜*/
	flag2			char(1)			default 'F'			not null,/*早茶*/
	flag3			char(1)			default 'F'			not null,/*自助餐*/
	flag4			char(1)			default 'F'			not null,/*推荐*/
	flag5			char(1)			default 'F'			not null,/*常用菜*/
	flag6			char(1)			default 'F'			not null,/*临时锁菜*/
	flag7			char(1)			default '1'			not null,/*分级*/
	flag8			char(1)			default 'F'			not null,/*出菜口打印*/
	flag9			char(1)			default 'F'			not null,/*厨师长打印*/
	flag10		char(1)			default 'F'			not null,/*合并打印*/
	flag11		char(1)			default 'F'			not null,/*临时菜*/
	flag12		char(1)			default 'F'			not null,/**/
	flag13		char(1)			default 'F'			not null,/**/
	flag14		char(1)			default 'F'			not null,/**/
	flag15		char(1)			default 'F'			not null,/**/
	flag16		char(1)			default 'F'			not null,/**/
	flag17		char(1)			default 'F'			not null,/**/
	flag18		char(1)			default 'F'			not null,/**/
	flag19		char(1)			default 'F'			not null,/*菜谱的特殊标记，对应basecode..cat=plu_flag19,如定金等*/
	condgp1		char(100)		default '' 			not null,/*对应所需辅料的选择*/		
	condgp2		char(100)		default '' 			not null,/*对应可选辅料的选择*/
	tocode		char(100)		default ''			not null,/*对应报表数据项的选择*/
	sta		 	char(1)			default ''  		not null,/*在用状态*/
	th_sort	 	char(3)			default ''  		not null,/*触摸屏上显示的类别, basecode=touch_sort*/
	p_number		int				default 1			not null,/*厨房打印份数*/
	picpath		char(60)			default ''        null,		/*菜图片的路径*/
	empno			char(10)			default '' 			not null,/*操作员工号*/
	date			datetime			default '' 			not null,/*日期(与日志保持一致)*/
	logmark		int				default 0   		not null	/*日志序号*/ 
)
exec sp_primarykey pos_plu_all,id
create unique index index1 on pos_plu_all(pluid,code)
create unique index index2 on pos_plu_all(id)
;

/*	菜谱日志 */


select * into pos_plu_log from pos_plu
create unique index index1 on pos_plu_log(id,logmark)
;

/*	价格对照表 */


create table pos_price
(
	pccode		char(3)	not null,							/* 营业点代码,'###'代表所有*/
	id				integer	default 0	not null,			/*菜ID号*/
	inumber		integer	default 0	not null,			/*价格序号*/
	unit			char(4)	default ''	not null,			/*单位*/
	price			money		default 0	not null,			/*价格*/
	cost			money		default 0	not null,			/*成本价*/
	cost_f		money		default 0	not null,			/*毛利率*/
	halt			char(1)	default 'F' not null,			/*停用标记*/
	logmark		integer	default 0	not null,
	empno			char(10) default '' not null,			   
	log_date    datetime	 not null
)
;
exec sp_primarykey pos_price,id,inumber
create unique index index1 on pos_price(id,inumber)
;

/*价格日志*/

select * into pos_price_log from pos_price
create unique index index1 on pos_price_log(id,inumber,logmark)
;

/*	价格与配料份量的对照表 */


create table pos_pldef_price
(
	pccode		char(3)	not null,							/* 营业点代码,'###'代表所有*/
	id				integer	default 0	not null,			/*菜ID号*/
	inumber		integer	default 0	not null,			/*价格序号*/
	condid		integer	default 0	not null,			/*辅料成员的ID号*/
	unit			char(4)	default ''	not null,			/*单位*/
	descript		char(40)	default ''  not null,			/*配料描述*/
	number		money		default 0	not null				/*配料数量*/
	
)
;
exec sp_primarykey pos_pldef_price,id,inumber,condid
create unique index index1 on pos_pldef_price(id,inumber,condid)
;

/*
		关于‘组合菜’的报表项目分摊	组合菜: 早餐, 婚宴, 工作餐, ......
*/

create table pos_plu_sep
(
	pccode		varchar(5)		not null,					// 代码 = deptno + pccode
	id				integer			not null,					//	菜代码
	code			varchar(15)		not null,					// 代码
	tag			char(1)			not null,					// 类别 -- %-百分比  $-金额(不再采用)
	itemcode		char(3)			not null,					// 报表项目
	itempart		money	default 0 not null					// 项目比例 或者 金额   <金额=0 表示其他>
)
exec sp_primarykey pos_plu_sep,pccode,id,itemcode
create unique index index1 on pos_plu_sep(pccode,id,itemcode)

;
/*
套菜明细组成
*/
CREATE TABLE pos_std 
(
	plucode 		char(2)		default '' not null,
	std_id 		integer		default 0  not null,
	id 			integer		default 0  not null,
	number 		money			default 0  not null,
	unit			char(4)		default 0  not null,
	price			money			default 0  not null,
	sequence		int			default 0  not null,
   sort     	char(1) NULL,                      /*出菜道次*/
   pinumber 	int     NULL
);
exec sp_primarykey pos_std,std_id,id
create unique index index1 on pos_std(std_id,id)

;
/*客人喜好菜式*/
CREATE TABLE pos_hgsplu 
(
	haccnt 		char(10)			default '' 	not null,
	id 			integer			default 0   not null,
	pinumber		integer			default 0	not null,
	remark 		char(100)		default ''  null	
);
exec sp_primarykey pos_hgsplu,haccnt,id,pinumber
create unique index index1 on pos_hgsplu(haccnt,id,pinumber)
;

// 菜谱从文件导入临时存放
CREATE TABLE pos_plu_file (
    pccode   char(3)  DEFAULT ''	 NOT NULL,
    pcdes    char(16) DEFAULT ''	 NOT NULL,
    plucode  char(2)  DEFAULT ''	 NOT NULL,
    pludes   char(20) DEFAULT ''	 NOT NULL,
    sort     char(4)  DEFAULT ''	 NOT NULL,
    sortname char(30) DEFAULT ''	 NOT NULL,
    code     char(6)  DEFAULT ''	 NOT NULL,
    id       int      DEFAULT ''	 NOT NULL,
    name1    char(30) DEFAULT ''	 NOT NULL,
    name2    char(50) DEFAULT ''	 NOT NULL,
    unit1    char(4)  DEFAULT ''	 NOT NULL,
    price1   money    DEFAULT 0	 NOT NULL,
    unit2    char(4)  DEFAULT ''	 NOT NULL,
    price2   money    DEFAULT 0	 NOT NULL,
    unit3    char(4)  DEFAULT ''	 NOT NULL,
    price3   money    DEFAULT 0	 NOT NULL,
    unit4    char(4)  DEFAULT ''	 NOT NULL,
    price4   money    DEFAULT 0	 NOT NULL,
    unit5    char(4)  DEFAULT ''	 NOT NULL,
    price5   money    DEFAULT 0	 NOT NULL
);
EXEC sp_primarykey 'pos_plu_file', plucode


