
/*
	发票库
*/

/* 发票领退登记表 */

if exists(select * from sysobjects where name = "invoice")
//	drop table invoice;

create table invoice
(
	numb     integer  not null,    /*批号*/  
   printtype  char(10) not null,  /*票据类别*/  
	bdate 	datetime not null,    /*领票日期*/
	gbound   varchar(255)  not null,       /*领票范围 : ef: 00001-00200 or 00020,00025,00040*/
	gnumb    integer  default 0 not null,  /*领票数量*/ 
	ubound   varchar(255)  null,           /*已使用发票范围*/ 
	unumb    integer  default 0 not null,  /*已使用发票数量*/ 
	bbound   varchar(255)  null,           /*废票范围*/ 
	bnumb    integer  default 0 not null,  /*废票数量*/ 
	rbound   varchar(255)  null,           /*剩票范围*/  
	rnumb    integer  default 0 not null,  /*剩票数量*/  
	empno    char(10)  not null,     /*领票人*/
	empno1   char(10)  not null,     /*领票经手人*/
	empno2   char(10)  null,         /*退票人*/
	empno3   char(10)  null,         /*退票经手人*/
	edate    datetime null,         /*退票日期*/
	sta      char(1) default '0',   /*状态 0:在用; 1:用完*/
	logmark  int      not null  ,    /*日志*/
	cby      char(10) default '',
	changed  datetime null 
)
;
create unique  index index1 on invoice(bdate) ;
create unique  index index2 on invoice(numb) ;

/* 发票领退登记表日志 */

if exists(select * from sysobjects where name = "invoice_log")
	drop table invoice_log;

create table invoice_log
(
	numb     integer  not null,    /*批号*/  
   printtype  char(10) not null,  /*票据类别*/  
	bdate 	datetime not null,    /*领票日期*/
	gbound   varchar(255)  not null,       /*领票范围 : ef: 00001-00200 or 00020,00025,00040*/
	gnumb    integer  default 0 not null,  /*领票数量*/ 
	ubound   varchar(255)  null,           /*已使用发票范围*/ 
	unumb    integer  default 0 not null,  /*已使用发票数量*/ 
	bbound   varchar(255)  null,           /*废票范围*/ 
	bnumb    integer  default 0 not null,  /*废票数量*/ 
	rbound   varchar(255)  null,           /*剩票范围*/  
	rnumb    integer  default 0 not null,  /*剩票数量*/  
	empno    char(10)  not null,     /*领票人*/
	empno1   char(10)  not null,     /*领票经手人*/
	empno2   char(10)  null,         /*退票人*/
	empno3   char(10)  null,         /*退票经手人*/
	edate    datetime null,         /*退票日期*/
	sta      char(1)  default '0',   /*状态 0:在用; 1:用完*/
	logmark  int      not null ,     /*日志*/
	cby      char(10) default '',
	changed  datetime null 
)
;
create unique  index index2 on invoice_log(numb,logmark) ;

/* 发票领退明细表 */

if exists(select * from sysobjects where name = "in_detail")
//	drop table in_detail;

create table in_detail
(
	printtype   char(10)  default 'bill' not null, /* abill:2:前台账单 check:发票 
																	  pbill:餐饮账单*/ 
	inno        char(12) not null,             /*发票号*/
	bnumb       int      default 0 not null,   /*发票申领的批号*/
	sta         char(1)  default '0' not null, /*0:没用;1:已用;2:报废*/
	accnt       char(10)  null,                /*该发票对应的账号*/
	billno      char(10) null,                 /*psr,票据打印保存的流水号*/
	pccode      char(3)  null,
	modu        char(2)  null,
	bdate       datetime  null,					 /*单据使用的帐务日期*/		
	empno       char(10)   null,
	shift       char(1)   null,
	credit      money     null,              /*金额*/ 
	modi        char(1) default 'F' not null,   /*消费内容是否有改动*/ 
	cdate			datetime null,
	cempno		char(10) null,
	logdate		datetime		null,					 /*单据使用的物理日期*/
	accntbillno      char(10) null             /*该发票对应的结账单号*/   
)
;
create unique  index index1 on in_detail(printtype,bnumb,inno) ;
create index index2 on in_detail(inno);
create index index3 on in_detail(empno,shift);
create index index4 on in_detail(accnt);

/* 发票打印记录表 */

if exists(select * from sysobjects where name = "in_print")
//	drop table in_print;

create table in_print
(
	printtype   char(10)  default 'abill' not null, /* abill:前台账单 acheck:发票  pbill:餐饮账单*/ 
	inno        char(12)  not null,             /*发票号*/
	accnt       char(10)  null,                /*该发票对应的账号*/
	billno      char(10)  null,                 /*该发票对应的账单号*/
	pccode      char(3)   null,
	modu        char(2)   null,
	bdate       datetime  null,					 /*单据使用的帐务日期*/		
	empno       char(10)  null,
	shift       char(1)   null,
	credit      money     null,             	 /*金额*/ 
	modi        char(1) 	 default 'F' not null,   /*消费内容是否有改动*/ 
	logdate		datetime	 null					 /*单据使用的物理日期*/
)
;
create unique  index index1 on in_print(printtype,inno);
create index index2 on in_print(inno);
create index index3 on in_print(empno,shift);
create index index4 on in_print(accnt);

/* 账单发票元素*/
/* 尺寸单位为毫米mm*/
/* pb 每1000点在横坐标=58mm,纵坐标=66mm*/
if exists(select * from sysobjects where name = "billunit")
//	drop table billunit;

create table billunit
(
	printtype         char(10),       /*账单类别*/
	language 	      char(20),       /*账单类别*/
	descript          char(20),       /*账单描述*/
	paperwidth        int default 200,           /*账单宽*/
	paperlength       int default 200,           /*账单长*/
	headbordheight    int default 20,           /*头高*/
	headheight   		int default 20, 			 /*头上每行高*/	
	headlength   		int default 200, 			 /*头上每行长*/	 
	headrow      		int default 3, 			 /*头上行数*/	 
	headx        		int default 2, 			 /*头上每行开始坐标*/	 
	detailheight 		int default 0,  			 /*账单内容每行高*/	
	detaillength 		int default 200,   			 /*账单内容每行长*/	
	detailrow    		int default 10,  			 /*账单内容行数*/	 
	detailx     		int default 20, 			 /*账单内容每行开始坐标*/	 
	sumheight    		int default 20,  			 /*账单地脚每行高*/ 
	sumlength    		int default 20,  			 /*账单地脚每行长*/  
	sumrow       		int default 20,  			 /*账单地脚行数*/  
	sumx         		int default 200,  			 /*账单地脚每行开始坐标*/	 
	papertype         char(1)  null,      		/**/
	syntax	         text,      		/**/
	detail_syntax	   text,      		/**/
	summary_syntax	   text,      		/**/
	inumber	         int default 0,      		/**/
	savemodi          char(1) default 'F'      		/**/
)
;
create unique  index index2 on billunit(printtype) ;

/* 帐次审计纪录 */
if exists(select 1  from sysobjects where type ='U' and name ='au_remark') 
	drop table au_remark ;
create table au_remark
(
	aubdate			datetime default getdate()  not null,
	type        char(3) default 'act',         /* 类别 act,acth  前台帐务；pos, post, posh 餐饮账务 hos 客房点收银; bus 商务收银; */
	auaccnt     char(10) default  '',          /*账号, 菜单号*/
	aunumber    int default 0	,               /*帐次*/ 
	nempno      char(10) default  '',           /*夜审员*/
	ndate       datetime  null,                /*夜审时间*/
	ncheck      char(1) default 'N',           /*对否*/
	nremark     varchar(64) default '',        /*备注*/
	dempno      char(10) default  '',           /*日审员*/ 
	ddate       datetime  null,                /*日审时间*/ 
	dcheck      char(1) default 'N',           /*对否*/    
	dremark     varchar(64) default ''         /*备注*/
	
)

create unique  index index1 on au_remark(type,auaccnt,aunumber) ;

/* 历史帐次审计纪录 */
if exists(select 1  from sysobjects where type ='U' and name ='au_hremark') 
//	drop table au_hremark ;
create table au_hremark
(
	aubdate			datetime default getdate()  not null,
	type        char(3) default 'act',         /* 类别 act,acth  前台帐务；pos, post, posh 餐饮账务 hos 客房点收银; bus 商务收银; */
	auaccnt     char(10) default  '',          /*账号, 菜单号*/
	aunumber    int default 0	,               /*帐次*/ 
	nempno      char(10) default  '',           /*夜审员*/
	ndate       datetime  null,                /*夜审时间*/
	ncheck      char(1) default 'N',           /*对否*/
	nremark     varchar(64) default '',        /*备注*/
	dempno      char(10) default  '',           /*日审员*/ 
	ddate       datetime  null,                /*日审时间*/ 
	dcheck      char(1) default 'N',           /*对否*/    
	dremark     varchar(64) default ''         /*备注*/
	
)

create unique  index index1 on au_hremark(type,auaccnt,aunumber) ;

exec p_hry_manage_auth_function 50,'invoice!modi','票据领退','01#02#04#07','S';
exec p_hry_manage_auth_function 50,'invoice!sele','票据查询','01#02#04#07','S';
exec p_hry_manage_auth_function 50,'invoice!discard','票据报废','01#02#04#07','S';
exec p_hry_manage_auth_function 50,'invoice!discard-other','报废他人票据','01#02#04#07','S';

/* 前台收银是否要打定金单 */
insert into sysoption 	values('account', 'earnest', 'T')   	;
/* 前台收银打单(或发票)时是否要输入单号 */
insert into sysoption 	values('account', 'input_billno', 'T')   	;
/* 综合收银打单(或发票)时是否要输入单号 */
insert into sysoption 	values('pos', 'input_billno', 'T')   	;


/*
  用于记录非正常使用票据的记录信息
*/
if exists(select * from sysobjects where name = "in_recode")
	drop table in_recode;

create table in_recode
(
	numb     integer  not null,    /*批号*/  
   empno    char(12) not null,    /*工号*/
	bdate 	datetime not null,    /*营业日期*/
   log_date datetime not null,    /*发生日期*/
   btype    char(10) not null,    /*票据种类*/
	billnum  char(25) not null,    /*领票范围 : ef: 00001-00200 or 00020,00025,00040*/
   billno   char(10) null,        /*账单号*/
   ref    	varchar(100) null,
	accnt    char(10) not null,
	sta      char(1)  default '1' not null      /*1:没申领, 2:已被打印, 3:已被报废, 4:他人领的*/
)
;
create unique  index index1 on in_recode(empno,bdate,billnum,btype,log_date) 
;
/*
  用于记录所有票据的打印记录信息
*/
if exists(select * from sysobjects where name = "in_allprint")
	drop table in_allprint;

create table in_allprint
(
	printtype   char(10)  default 'bill' not null, /* abill:2:前台账单 check:发票 
																	  pbill:餐饮账单*/ 
	inno        char(12) not null,            	 /*票据号*/
	accnt       char(10)  null,            		 /*该票据对应的账号*/
	billno      char(10) null,            			 /*psr,票据打印保存的流水号*/
	modu        char(2)  null,
	bdate       datetime  null,						 /*营业时间*/		
	log_date    datetime  null,					    /*打印时间*/		
	empno       char(10)   null,
	shift       char(1)   null,
	credit0     money     null,		             /*原金额*/ 
	credit1     money     null,		             /*新金额*/ 
	modi        char(1) default 'F' not null,   	 /*消费内容是否有改动*/ 
	remark0     varchar(40),                      /*原内容*/
	remark1     varchar(40),                      /*新内容*/
	sta			char(1) default '0' not null,      /*0:正常，1:没申领, 2:已被打印, 3:已被报废, 4:他人领的*/
	detailno		char(10) default '' not null,
	accntbillno      char(10) null            	 /*该票据对应的结账单号*/
)
;
create unique  index index1 on in_allprint(printtype,inno,log_date);
create index index2 on in_allprint(inno);
create index index3 on in_allprint(printtype);
create index index4 on in_allprint(accnt);
create index index5 on in_allprint(empno,bdate,shift);


insert into sysoption 	values('account', 'earnest', 'F','');
insert into sysoption 	values('audit', 'bill', 'T', '') ;



/*
// 前台账单明细内容
if exists(select 1  from sysobjects where type ='U' and name ='in_bill_detail') 
	drop table in_bill_detail ;
create table in_bill_detail
(
	billno      char(10)  not null,                         /*主键*/
	printtype   char(10)  default 'abill' not null,         /* 账单类别 ; */
	inno        char(12)  default  '' not null,                 /*账单号*/
	code        char(3)   default  '' not null,                
	charge      money     default 0,        
	credit      money    default  0,       
	item        varchar(100)  null ,
	log_date    datetime  
)
;
create unique  index index1 on in_bill_detail(printtype,inno,code,item,log_date) ;

// 前台帐单头
if exists(select 1  from sysobjects where type ='U' and name ='in_bill_head') 
	drop table in_bill_head ;
create table in_bill_head
(
	billno      char(10)  not null,                         /*主键*/
	printtype   char(10)  default 'abill' not null,         /* 账单类别 ; */
	inno        char(12)  default  '' not null,                 /*账单号*/
	name        varchar(40)   default  '' not null,                
	fir         varchar(60)   default '',        
	room        char(5)   default  '',           
	rooms       int,
	guests      int,
	arr         datetime,
	dep         datetime,
	qtrate      money default 0,
	setrate     money default 0,
	remark      varchar(200),
	log_date    datetime
)
;
create unique  index index1 on in_bill_head(printtype,inno,log_date) ;


// 前台帐单头修改内容
if exists(select 1  from sysobjects where type ='U' and name ='in_billmodi_head') 
	drop table in_billmodi_head ;
create table in_billmodi_head
(
	billno      char(10)  not null,                         /*主键*/
	printtype   char(10)  default 'abill' not null,         /* 账单类别 ; */
	inno        char(12)  default  '' not null,                 /*账单号*/
	name        varchar(40)   default  '' not null,                
	fir         varchar(60)   default '',        
	room        char(5)   default  '',           
	rooms       int,
	guests      int,
	arr         datetime,
	dep         datetime,
	qtrate      money default 0,
	setrate     money default 0,
	remark      varchar(200),
	log_date    datetime
)
;
create unique  index index1 on in_billmodi_head(printtype,inno,log_date) ;


// 前台账单明细修改内容

if exists(select 1  from sysobjects where type ='U' and name ='in_billmodi_detail') 
	drop table in_billmodi_detail ;
create table in_billmodi_detail
(
	billno      char(10)  not null,                         /*主键*/
	printtype   char(10)  default 'abill' not null,         /* 账单类别 ; */
	inno        char(12)  default  '' not null,                 /*账单号*/
	code        char(3)   default  '' not null,                
	charge      money     default 0,        
	credit      money    default  0,       
	item        varchar(100)  null ,
	log_date    datetime,
	modi        char(1)  default 'T'  
)
;
create unique  index index1 on in_billmodi_detail(printtype,inno,code,item,log_date) ;
*/



