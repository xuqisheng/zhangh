------------------------------------------------------------------------------------
--
--	餐饮一般的代码表，如果没有明确归属的表结构请加入此文件中    cyj 20050922
--
------------------------------------------------------------------------------------

/*	营业点表,定义每个营业点的收费参数 */

create table pos_pccode
(
	pccode			char(3)		not null,						/*代码*/
	descript			char(16)		not null,						/*营业点的中文名称*/
	descript1		varchar(32)		 null,						/*营业点的英文名称*/
	teaup				char(1)		default 'T' not null,		/*是否起用茶位费*/
	name				char(8)		default '茶位费' not null,	/*茶位费名*/
	mode				char(3)		default '' null,				/*缺省模式代码*/
	serve_rate		money			default 0 not null,			/*服务费率*/		
	tax_rate			money			default 0 not null,			/*附加费率*/
	tea_charge1		money			default 0 not null,			/*早茶费*/
	tea_charge2		money			default 0 not null,			/*中茶费*/
	tea_charge3		money			default 0 not null,			/*晚茶费*/
	tea_charge4		money			default 0 not null,			/*夜茶费*/
	tea_charge5		money			default 0 not null,			/*五茶费*/
	dec_length		integer		default 2 not null,			/*金额的小数位数*/
	dec_mode			char(1)		default '0' not null,		/*抹零方式*/
	dec_id			int			default 0 not null,			/*零头去向, pos_plu.id*/
	daokou			char(1)		default 'F' not null,		/*倒扣,"T"/"F",在营业日报中取食品服务费的1/2,并扣减食品*/
	menu_dw_menu	char(30)    default 'd_cq_newpos_menu',   /*在w_cyj_pos_menu中该pccode对应的dw_menu */ 
	menu_dw_dish	char(30)    default 'd_cq_newpos_dish',   /*在w_cyj_pos_menu中该pccode对应的dw_dish */ 
	tblmap_dw_menu	char(30)    default 'd_cq_newpos_menu',  /*在w_cyj_pos_menu中该pccode对应的dw_menu */ 
	tblmap_dw_dish	char(30)    default 'd_cq_newpos_dish',  /*在w_cyj_pos_menu中该pccode对应的dw_dish */ 
	ground_bmp		char(50)		default '' not null,       /*台位图2的台位分布图*/
	quantity			int			default 0  not null,       /*桌数*/
	overquan			int			default 0  not null,       /*超预定数*/
	placecode		char(5)		default ''  null,   		   /*地点码*/
	deptno			char(5)		default '' not null,		   /*部门码*/
	language			char(10)		default 'chinese' not null, /*语种；餐厅账单设置默认语种*/
	remark			varchar(255) default '' null
   flag1          char(1)      NULL,
   printname1     char(3)      NULL,
   flag2          char(1)      NULL,
   printname2     char(3)      NULL,
   flag3          char(1)      NULL,
   printname3     char(3)      NULL

)
exec sp_primarykey pos_pccode,pccode
create unique index index1 on pos_pccode(pccode)
;

/*站点定义*/
CREATE TABLE pos_station 
(
	pc_id		 				char(4)		default '' not null,	
	descript					char(30)		default '' not null,
	descript1				char(30)		default '' not null,
	pccodes 					varchar(250)	default '' not null,
	printers					varchar(120)	default '' not null,
	tag 						char(4)		default '' not null,
	tag1 						char(1)		default 'F'not null,
	tag2 						char(1)		default 'F'not null,
	tag3 						char(1)		default 'F'not null,
	tag4 						char(1)		default 'F'not null,
	printname 				char(3)		default '' not null,				/*客人清单打印机*/
	flag						char(1)		default 'F'not null,				/*是否使用厨房打印出单*/
	printname1 				char(3)		default '' not null,				/*传菜部打印机*/
	flag1						char(1)		default 'F'not null,				/*是否使用厨房打印出单*/
	printname2 				char(3)		default '' not null,				/*厨师长打印机*/
	flag2						char(1)		default 'F'not null,				/*是否使用厨房打印出单*/
	login_win				varchar(30)		default '' not null,			/*触摸屏登录窗口*/
	podex_com				char(1)		default '' not null ,         /*接钱箱的串口号：空格为没接 */
   emp_com    				char(1)      NULL
);

exec sp_primarykey pos_station,pc_id
create unique index index1 on pos_station(pc_id)

;


/*	桌号 */
create table pos_tblsta
(
	tableno		char(6)		not null,							/*桌号*/
	type			char(3)		null,									/*类别*/
	pccode		char(3)		not null,							/*营业点*/
	descript1	char(10)		null,									/*中文*/
	descript2	char(20)		null,									/*外文*/
	maxno			integer		default	0	not null,			/*席位数*/
	sta			char(1)		default	'N'	not null,      /*N: 独占；S:可以拼台*/
	mode			char(1)		default	'0'	not null,		/*最低消费模式*/
	amount		money			default	0	not null,			/*最低消费金额*/
	min_id		int			default	0	not null,			/*最低消费差额保存菜号pos_plu.id*/
	area			char(2)     default '' not null,				/*区域，用于厨房打印*/
	regcode		char(2)     default '' not null,				/*区域，用于PDA点菜*/
	x				int			default 0  not null,	
	y				int			default 0  not null,	
	width			int			default 0  not null,	
	height		int			default 0  not null,
	tag			char(1)		default '0' not null,        	/*0: 餐台, 1: 包厢, R: 客房送餐专用*/	
	mapcode		char(3)		default '' not null,				/*餐位分布图序号*/
   modi        char(1)                  null,				/*是否维修*/
   reason      char(30)                 null,				/*维修理由*/
   placecode   char(5)                  null
)
exec sp_primarykey pos_tblsta,tableno
create unique index index1 on pos_tblsta(tableno)
create index index2 on pos_tblsta(pccode, tableno)
;

/*pos_dept服务员组别放入basecode = 'pos_depart' */
/*	抄单员,值台员,厨师的工号定义 */

create table pos_empno
(
	pccode	char(3)		null,			/*营业点*/
	deptno	char(2)		not null,	/*班组*/
	empno		char(10)		not null,	/*工号*/
	name		char(20)		not null		/*姓名*/
)
exec sp_primarykey pos_empno,empno
create unique index index1 on pos_empno(empno)
;




/*	模式代码及描述 */
create table pos_mode_name
(
	code			char(3)		not null,	/*代码*/
	name1			char(20)		not null,	/*中文名称*/
	name2			char(30)		null,			/*英文名称*/
	descript		char(255)	null,			/*描述*/
	descript1	char(255)	null			/*描述*/
)
exec sp_primarykey pos_mode_name,code
create unique index index1 on pos_mode_name(code)
;

/*	优惠模式,服务费模式,附加费模式代码及描述 */
create table pos_mode_descript
(
	type			char(1)		not null,	/*类型*/
	code			char(1)		not null,	/*代码*/
	name1			char(40)		not null,	/*中文描述*/
	name2			char(40)		null			/*英文描述*/
)
exec sp_primarykey pos_mode_descript,type,code
create unique index index1 on pos_mode_descript(type,code)
insert pos_mode_descript values('1','A','模式优惠Ｘ菜单优惠','')
insert pos_mode_descript values('1','B','模式优惠＋菜单优惠','')
insert pos_mode_descript values('1','C','以模式优惠为准','')
insert pos_mode_descript values('1','D','以菜单优惠为准','')
insert pos_mode_descript values('1','E','以较大的优惠为准','')
insert pos_mode_descript values('1','F','以较小的优惠为准','')
insert pos_mode_descript values('1','G','不优惠','')
//
insert pos_mode_descript values('2','A','以模式服务费率为准','')
insert pos_mode_descript values('2','B','以菜单服务费率为准','')
insert pos_mode_descript values('2','C','以较大的服务费率为准','')
insert pos_mode_descript values('2','D','以较小的服务费率为准','')
insert pos_mode_descript values('2','E','以模式服务费率为准(优惠服务费)','')
insert pos_mode_descript values('2','F','以菜单服务费率为准(优惠服务费)','')
insert pos_mode_descript values('2','G','以较大的服务费率为准(优惠服务费)','')
insert pos_mode_descript values('2','H','以较小的服务费率为准(优惠服务费)','')
insert pos_mode_descript values('2','I','优惠服务费','')
//
insert pos_mode_descript values('3','A','以模式附加费率为准','')
insert pos_mode_descript values('3','B','以菜单附加费率为准','')
insert pos_mode_descript values('3','C','以较大的附加费率为准','')
insert pos_mode_descript values('3','D','以较小的附加费率为准','')
insert pos_mode_descript values('3','E','以模式附加费率为准(优惠附加费)','')
insert pos_mode_descript values('3','F','以菜单附加费率为准(优惠附加费)','')
insert pos_mode_descript values('3','G','以较大的附加费率为准(优惠附加费)','')
insert pos_mode_descript values('3','H','以较小的附加费率为准(优惠附加费)','')
insert pos_mode_descript values('3','I','优惠附加费','')
;

/*	模式定义 */
create table pos_mode_def
(
	code					char(3)		not null,						/*模式代码*/
	type					char(1)		not null,						/* 1.优惠 2.服务费 3.附加费 */
	deptcode				char(4)		not null,						/*营业点代码(0201.02)*/
	plucode				char(15)		not null,						/*菜单代码(A.A01.A010001)*/
	rate					money			default 0 not null,						/*预先比例*/
	reason				char(2)		default '' not null,			/*预先理由*/
	mode					char(1)		not null							/*再次模式
				1. 优惠
					A.模式优惠Ｘ菜单优惠[price=price0*(1-discount)*(1-fee_rate)]
					B.模式优惠＋菜单优惠[price=price0*(1-discount-fee_rate)]
					C.以模式优惠为准[price=price0*(1-discount)]
					D.以菜单优惠为准[price=price0*(1-fee_rate)]
					E.以较大的优惠为准[price=price0*(1-max(discount,fee_rate))]
					F.以较小的优惠为准[price=price0*(1-min(discount,fee_rate))]
					G.不优惠[price=price0]
				2. 服务费
					A.以模式服务费率为准[serve_charge0=price0*serve_rate,serve_charge=price0*serve_rate]
					B.以菜单服务费率为准[serve_charge0=price0*menu_rate,serve_charge=price0*menu_rate]
					C.以较大的服务费率为准[serve_charge0=price0*max(serve_rate,menu_rate),serve_charge=price0*max(serve_rate,menu_rate)]
					D.以较小的服务费率为准[serve_charge0=price0*min(serve_rate,menu_rate),serve_charge=price0*min(serve_rate,menu_rate)]
					E.以模式服务费率为准(优惠服务费)[serve_charge0=price0*serve_rate,serve_charge=price*serve_rate]
					F.以菜单服务费为准率(优惠服务费)[serve_charge0=price0*menu_rate,serve_charge=price*menu_rate]
					G.以较大的服务费率为准(优惠服务费)[serve_charge0=price0*max(serve_rate,menu_rate),serve_charge=price*max(serve_rate,menu_rate)]
					H.以较小的服务费率为准(优惠服务费)[serve_charge0=price0*min(serve_rate,menu_rate),serve_charge=price*min(serve_rate,menu_rate)]
					I.优惠服务费[serve_charge0=price0*menu_rate,serve_charge=0]
				3. 附加费
					A.以模式附加费率为准[tax_charge0=price0*tax_rate,tax_charge=price0*tax_rate]
					B.以菜单附加费率为准[tax_charge0=price0*menu_rate,tax_charge=price0*menu_rate]
					C.以较大的附加费率为准[tax_charge0=price0*max(tax_rate,menu_rate),tax_charge=price0*max(tax_rate,menu_rate)]
					D.以较小的附加费率为准[tax_charge0=price0*min(tax_rate,menu_rate),tax_charge=price0*min(tax_rate,menu_rate)]
					C.以模式附加费率为准(优惠附加费)[tax_charge0=price0*tax_rate,tax_charge=price*tax_rate]
					D.以菜单附加费为准率(优惠附加费)[tax_charge0=price0*menu_rate,tax_charge=price*menu_rate]
					G.以较大的附加费为准率(优惠附加费)[tax_charge0=price0*max(tax_rate,menu_rate),tax_charge=price*max(tax_rate,menu_rate)]
					H.以较小的附加费为准率(优惠附加费)[tax_charge0=price0*min(tax_rate,menu_rate),tax_charge=price*min(tax_rate,menu_rate)]
					I.优惠附加费[tax_charge0=price0*menu_rate,tax_charge=0]*/
)
exec sp_primarykey pos_mode_def,code,type,deptcode,plucode
create unique index index1 on pos_mode_def(code,type,deptcode,plucode)
;

/*
	餐位分布图代码
*/
create table  pos_mapcode (
	code			char(3)		default ''	not null,	/*代码*/
	descript		char(20)		default ''	not null,	/*描述*/
	ground_bmp	char(50)		default ''  not null    /*台位图2的台位分布图*/
	);
exec sp_primarykey pos_mapcode,code
;

/*
	计时收费定义
*/
create table pos_timecode
(
	timecode			char(3)				not null,
	descript       char(20)          not null
)
exec sp_primarykey pos_timecode,timecode
create unique index index1 on pos_timecode(timecode)

;

/*
	计时收费定义明细部分
*/
create table pos_time_code
(
	timecode			char(3)				not null,
	number  		   integer			   not null,
   bdate          char(5)           not null,
   edate          char(5)           not null,
   minute         integer           not null,
   amount         money             not null
)
exec sp_primarykey pos_time_code,timecode,number
create unique index index1 on pos_time_code(timecode,number)
;


/*
	典型点菜单
*/

create table  pos_menu_std (
		menu			char(10)	 not null,						/*单号*/
		name1			varchar(30)	default ''	not null,	/*中文名*/
		name2			varchar(50)	default ''	not null,	/*外文名*/
		price			money			not null,
		cusno			char(7)		default ''  not null,	/*cusinf.no*/
		gstid			char(7)		default ''  not null,	/*hgstinf.no*/
		id				int			default 0 	not null,	/*大于零，则已经编入菜谱*/
		remark		varchar(100)	null							/*备注*/
		);
exec sp_primarykey pos_menu_std,menu
;

/*
	典型点菜单明细内容
*/
create table  pos_dish_std (
	menu			char(10)	 not null,						/*单号*/
	id				int		 not null,						/*菜唯一号*/
	name1			varchar(30)	default ''	not null,	/*中文名*/
	name2			varchar(50)	default ''	not null,	/*外文名*/
	unit			char(4)		default ''	not null,	/*计量单位*/
	number		money			not null,					/*数量*/
	price			money			not null						/*金额*/
	);
exec sp_primarykey pos_dish_std,menu,id
;

drop  TABLE pos_detail_jie ;
CREATE TABLE pos_detail_jie 
(
    date    datetime NOT NULL,
    deptno  char(2)  NOT NULL,
    posno   char(2)  NOT NULL,
    pccode  char(3)  NOT NULL,
    shift   char(1)  NOT NULL,
    empno   char(10) NOT NULL,
    menu    char(10) NOT NULL,
    code    char(15) NOT NULL,
    id      int      NOT NULL,
    type    char(5)  DEFAULT ''	 NOT NULL,
    name1   char(20) NOT NULL,
    name2   char(20) NULL,
    number  money    DEFAULT 0	 NOT NULL,
    amount0 money    DEFAULT 0	 NOT NULL,
    amount1 money    DEFAULT 0	 NOT NULL,
    amount2 money    DEFAULT 0	 NOT NULL,
    amount3 money    DEFAULT 0	 NOT NULL,
    serve0  money    DEFAULT 0	 NOT NULL,
    serve1  money    DEFAULT 0	 NOT NULL,
    serve2  money    DEFAULT 0	 NOT NULL,
    serve3  money    DEFAULT 0	 NOT NULL,
    tax0    money    DEFAULT 0	 NOT NULL,
    tax1    money    DEFAULT 0	 NOT NULL,
    tax2    money    DEFAULT 0	 NOT NULL,
    tax3    money    DEFAULT 0	 NOT NULL,
    reason1 char(3)  NULL,
    reason2 char(3)  NULL,
    reason3 char(3)  DEFAULT ''	 NOT NULL,
    special char(1)  NULL,
    tocode  char(3)  DEFAULT ''	 NOT NULL
);
create unique index index1 on pos_detail_jie(date,menu,code,id, type,reason3);

drop  TABLE pos_detail_dai ;
CREATE TABLE pos_detail_dai (
	date 				datetime		not null ,
	menu 				char(10)		not null ,
	paycode 			char(5)		not null ,
	amount 			money			not null ,
	reason3 			char(3)		not null 
);
create unique index index1 on pos_detail_dai(date,menu,paycode,reason3);


// --------------------------------------------------------------------------
// 综合收银收入借方明细统计，本表为中间值，所有收入统计均可由本表生成 
// --------------------------------------------------------------------------
create table pos_detail_jie_link
(
	pc_id			char(4)	not	null,
   pccode		char(3)	not	null,			/*费用码*/
   shift			char(1)	not	null,			/*班别*/
   empno			char(10)	not	null,			/*工号*/
   menu			char(10)	not	null,			/*菜单号*/
	code			char(15)	not	null,			/*菜号*/
	name1			char(20)	not	null,			/*菜名*/
	id				integer	not	null,			/*点菜序号*/
	type			char(5)	default	''	not	null,			/*统计类型'空格'原价或特优码折扣，'DSC'.DSC折扣，'ENT'.ENT款待*/
	amount0		money		default	0	not	null,			/*原金额*/
	amount1		money		default	0	not	null,			/*预先优惠金额(按优惠模式中的优惠理由)*/
	amount2		money		default	0	not	null,			/*优惠金额(按菜单中的优惠理由)*/
	amount3		money		default	0	not	null,			/*优惠金额(按付款中的优惠理由)*/
	reason3		char(3)	default	''	not	null,			/*特优码折扣，DSC折扣，ENT款待的优惠理由*/
	special		char(1)	null,									/*对应pos_plu的special*/
	tocode		char(3)	default	''	not	null,			/*对应pos_itemdef的code*/
	date			datetime not null
)
exec sp_primarykey pos_detail_jie_link,pc_id,menu,code,id,type,reason3
create unique index index1 on pos_detail_jie_link(pc_id,menu,code,id,type,reason3)
;

CREATE TABLE pos_int_pccode (
	class 		char(1)		default ''	not null,
	pccode 		char(5)		default ''	not null,
	int_code 	char(5)		default ''	not null,
	name1 		char(20)		default ''	not null,
	name2 		char(30)		default ''	not null,
	shift 		char(1)		default ''	null,
	pos_pccode	char(3)		default ''	null,
	itemcode 	char(3)		default ''	null,
	start_time 	char(8)		default ''	null,
	end_tiem 	char(8)		default ''	null,
	end_time 	char(8)		default ''	null
);
exec sp_primarykey pos_int_pccode,class,pccode,shift,pos_pccode
create unique index index1 on pos_int_pccode(class,pccode,shift,pos_pccode)
;


if exists(select * from sysobjects where name = "pos_tblmap" and type ="U")
	 drop table pos_tblmap
;

create table pos_tblmap
(
	pc_id			char(4)		  default ''	not null,
	pccode		char(3)		  default ''	not null,
	tableno 		char(16)      default space(16) not null,
	descript		char(20)		  default ''	not null,
	menu			char(10)      default space(10) not null,
	sta			char(1)       default space(1) not null,
	bdate			datetime		  ,
	shift			char(1)		  not null,
	tables		integer			,
	guests		integer			,
	empno3		char(10)			,
	amount		money				,
	pcrec			char(10),	
	resno			char(10)        
)

;

/*餐饮前台系统数据联结定义*/
insert into basecode_cat(cat, descript, descript1) select 'pos_trans_front', '餐饮前台系统数据联结','Pos Front Transaction';
insert into basecode (cat,code,descript,descript1) select 'pos_trans_front', '1', '192.168.2.20:pos1','前台系统';
insert into basecode (cat,code,descript,descript1) select 'pos_trans_front', '2', '192.168.2.2:x50203','x50203前台系统';



