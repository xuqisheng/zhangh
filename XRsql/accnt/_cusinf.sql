//==========================================================================
//	Table : cusinf  -- 单位档案
//
//		basecode:	salegrp, cuscls1, cuscls2, cuscls3, cuscls4
//
//		table :
//				
//				saleid, cusinf, cusinf_log, cusinf_del,
//==========================================================================


// --------------------------------------------------------------------------
//  basecode : salegrp  -- 销售员组别
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='salegrp')
	delete basecode_cat where cat='salegrp';
insert basecode_cat select 'salegrp', '销售员组别', 'saler group', 1;
delete basecode where cat='salegrp';
insert basecode(cat,code,descript,descript1) select 'salegrp', 'A', '销售部', 'Sales Department';
insert basecode(cat,code,descript,descript1) select 'salegrp', 'B', '前厅部', 'Front Office Department';
insert basecode(cat,code,descript,descript1) select 'salegrp', 'C', '其他', 'Other';


// ----------------------------------------------------------------
// table :	saleid	= 销售员 
// ----------------------------------------------------------------
//exec sp_rename saleid, a_saleid;
if exists(select 1 from sysobjects where name = "saleid")
	drop table saleid;
create table  saleid
(
	code    		char(10)						not null,
	descript    varchar(30)	default ''	not null,
	descript1   varchar(30)	default ''	not null,
	grp			char(3)						not null,		// 组别
	empno			char(10)						not null			// 电脑工号
)
exec sp_primarykey saleid,code
create unique index index1 on saleid(code)
create unique index index2 on saleid(descript)
;
//insert saleid select code,descript,'',grpno,empno from a_saleid;
//drop table a_saleid;

// --------------------------------------------------------------------------
//  basecode : cuscls1  -- 客户（单位）档案类别-1
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='cuscls1')
	delete basecode_cat where cat='cuscls1';
insert basecode_cat select 'cuscls1', '客户（单位）档案类别-1', 'Unit Class - 1', 3;
delete basecode where cat='cuscls1';
insert basecode(cat,code,descript,descript1) 
	select 'cuscls1', code, des, '' from cuscls;

// --------------------------------------------------------------------------
//  basecode : cuscls2  -- 客户（单位）档案类别-2
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='cuscls2')
	delete basecode_cat where cat='cuscls2';
insert basecode_cat select 'cuscls2', '客户（单位）档案类别-2', 'Unit Class - 2', 3;
delete basecode where cat='cuscls2';
insert basecode(cat,code,descript,descript1) 
	select 'cuscls2', code, des, '' from cuscls1;

// --------------------------------------------------------------------------
//  basecode : cuscls3  -- 客户（单位）档案类别-3
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='cuscls3')
	delete basecode_cat where cat='cuscls3';
insert basecode_cat select 'cuscls3', '客户（单位）档案类别-3', 'Unit Class - 3', 3;
delete basecode where cat='cuscls3';
insert basecode(cat,code,descript,descript1) 
	select 'cuscls3', code, des, '' from cuscls2;

// --------------------------------------------------------------------------
//  basecode : cuscls4  -- 客户（单位）档案类别-4
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='cuscls4')
	delete basecode_cat where cat='cuscls4';
insert basecode_cat select 'cuscls4', '客户（单位）档案类别-4', 'Unit Class - 4', 3;
delete basecode where cat='cuscls4';
insert basecode(cat,code,descript,descript1) 
	select 'cuscls4', code, des, '' from cuscls3;



// ----------------------------------------------------------------
// 	table :	cusinf	客户(单位)档案
// ----------------------------------------------------------------
//	exec sp_rename cusinf, a_cusinf;
if exists(select * from sysobjects where name = "cusinf")
	drop table cusinf;
create table cusinf
(
	no         		char(7)	    						not null,   // 电脑档案号
	sno         	varchar(15)	   default ''		not null,   // 客户号 单位自定义   
	sta				char(1)			default 'I' 	not null,	// 状态- I(n), O(ff)
   name          	varchar(60)   	default ''		not null,  	// 单位名称
   name1         	varchar(60)   	default ''		not null, 
   name2         	varchar(60)   	default ''		not null, 
	type				char(3)			default ''		not null,	// 类型 -- n普通/b黑名单/c现付/r记账
	class				char(1)			default 'C'		not null,	// 类别: C=公司；A=旅行社；S=订房中心 --> 固定代码；
	class1			char(3)			default '0'		not null, 	// 附加类别	0=表示没有定义；
	class2			char(3)			default '0'		not null,
	class3			char(3)			default '0'		not null,
	class4			char(3)			default '0'		not null,
	keep				char(1) 			default 'F'  	not null,  	// 保存 

   country       	char(3) 			default 'CHN'	not null,  	// 国家
	birthplace  	char(6)			default ''		not null,	// 籍贯 城市
	address			varchar(60)		default '' 		not null,	// 地址
	address1			varchar(60)		default ''		null,			// 地址
	zip				varchar(6)		default ''		not null,	// 邮政编码
	phone				varchar(20)		default '' 		not null,
	fax				varchar(20)		default ''		not null,
	wetsite			varchar(30)		default ''		not null,	// 网址 
	email				varchar(30)		default ''		not null,	// 电邮 
	qq					varchar(30)		default ''		not null,	// qq, msn, icq

	lawman			varchar(16)		default ''		null,			// 法定代表人
	regno				varchar(20)		default ''		null,			// 企业登记号
   liason        	varchar(30)   	default ''		not null,     	// 联系人
   liason1       	varchar(30)   	default ''		null,     	// 联系方式
   arr           	datetime      						null,  		// 有效日期
   dep           	datetime      						null,			// 终止日期
	extrainf			varchar(30)	 	default '' 		not null,	// for gaoliang  
	comment			varchar(90)	 	default '' 		not null,	// 说明
   remark      	text 									null,			// 备注 
	override			char(1)     	default 'F'		not null,	// 可以超额订房 

	code1				char(10)			default ''		not null, 	// 房价码 
	code2				char(3)			default ''		not null, 	// 餐娱码 
	code3				char(3)			default ''		not null, 	// 备用 
	code4				char(3)			default ''		not null, 	// 备用 
	code5				char(3)			default ''		not null, 	// 备用 

   saleid      	char(10)      	default ''		not null,	// 销售员 

	araccnt1			char(7)     	default ''		not null,	// 应收帐号 
	araccnt2			char(7)     	default ''		not null,	// 应收帐号 

	fv_date			datetime								null,			// 首次到店 
	fv_room			char(5)			default ''		not null,
	fv_rate			money				default 0		not null,
	lv_date			datetime								null,			// 上次到店 
	lv_room			char(5)			default ''		not null,
	lv_rate			money				default 0		not null,

   i_times     	int 				default 0 		not null,   // 住店次数 
   x_times     	int 				default 0 		not null,   // 取消预订次数 
   n_times     	int 				default 0 		not null,   // 应到未到次数 
   l_times     	int 				default 0 		not null,   // 其它次数 
   i_days      	int 				default 0 		not null,   // 住店天数 
   tl          	money 			default 0 		not null, 	// 总收入  
   rm          	money 			default 0 		not null, 	// 房租收入
   rm_b        	money 			default 0 		not null, 	// 房租服务费收入
   rm_e        	money 			default 0 		not null, 	// 房租城建费收入
   fb          	money 			default 0 		not null, 	// 餐饮收入
   en          	money 			default 0 		not null, 	// 娱乐收入
   ot          	money 			default 0 		not null, 	// 其它收入

   crtby       	char(10)								not null,	// 建立 
	crttime     	datetime 		default getdate()	not null,
   cby         	char(10)								not null,	// 修改 
	changed     	datetime 		default getdate()	not null,
	logmark     	int 				default 0 		not null
)
exec sp_primarykey cusinf, no
create unique index index1 on cusinf(no)
create unique index index2 on cusinf(name)
create index index3 on cusinf(saleid)
create index index4 on cusinf(class)
create index index5 on cusinf(class1)
create index index6 on cusinf(class2)
create index index7 on cusinf(class3)
create index index8 on cusinf(sno)
;


// ----------------------------------------------------------------
// table :	cusinf_log	= log table for cusinf
// ----------------------------------------------------------------
if exists(select 1 from sysobjects where name = "cusinf_log")
	drop table cusinf_log;
select * into cusinf_log from cusinf where 1=2;
exec sp_primarykey cusinf_log, no, logmark
create unique index index1 on cusinf_log(no, logmark)
;


// ----------------------------------------------------------------
// table : cusinf_del	=	delete table for cusinf
// ----------------------------------------------------------------
if exists(select 1 from sysobjects where name = "cusinf_del")
	drop table cusinf_del;
select * into cusinf_del from cusinf where 1=2;
exec sp_primarykey cusinf_del, no
create unique index index1 on cusinf_del(no)
;

/*
insert cusinf 
  SELECT no,   
         sno,   
         sta,   
         name,'','',   
         '',   	-- type
         'C',   
         class,   
         class1,   
         class2,   
         class3,   
         'T',   -- keet
         nation,   
         '',   	-- birthplace
         isnull(address,''),'',
         isnull(zip,''),   
         isnull(phone,''),   
         isnull(fax,''),   
         isnull(wwwinfo,''),'','',
         lawman,   
         regno,   
         isnull(liason,''),   
         liason1,   
         arr,   
         dep,   
         '',   
         isnull(descript,''),   
         more,   
         'F', 
         '','','','','',
         saleid,   
         isnull(araccnt1,''),   
         isnull(araccnt2,''),
			null,'',0,   null,'',0,   

         i_times,   
         x_times,   
         n_times,   
         l_times,   
         i_days,   
         tl,   
         rm,   
         rm_b,   
         rm_e,   
         fb,   
         en,   
         ot,   
         cby,changed,cby,changed,logmark  
    FROM a_cusinf  ;

update cusinf set class='A' where name like '%旅%';
update cusinf set class='S' where name like '%订%' or name like '%网%' or name like '%携%' ;

*/