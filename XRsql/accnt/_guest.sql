//==========================================================================
//	Table : guest  -- 客史档案
//
//		basecode:	gsttype, interest, language, 
//
//		table :
//				title, guest, guest_log, guest_del
//==========================================================================


// --------------------------------------------------------------------------
//  basecode : gsttype  -- 客史档案的类别
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='gsttype')
	delete basecode_cat where cat='gsttype';
insert basecode_cat select 'gsttype', '客史档案类别', 'Guest Type', 3;
delete basecode where cat='gsttype';
insert basecode(cat,code,descript,descript1) select 'gsttype', '0', '普通客人', 'Normal Guest';
insert basecode(cat,code,descript,descript1) select 'gsttype', '1', '熟客', 'Frequent Guest';
insert basecode(cat,code,descript,descript1) select 'gsttype', '2', '贵宾卡', 'Vip Card Guest';



// --------------------------------------------------------------------------
//  basecode : interest  -- 爱好
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='interest')
	delete basecode_cat where cat='interest';
insert basecode_cat select 'interest', '爱好', 'Interest', 3;
delete basecode where cat='interest';
insert basecode(cat,code,descript,descript1) select 'interest', 'TH', '戏剧', 'Theatre';
insert basecode(cat,code,descript,descript1) select 'interest', 'TE', '网球', 'Tennis';
insert basecode(cat,code,descript,descript1) select 'interest', 'GO', '高尔夫', 'Golf';
insert basecode(cat,code,descript,descript1) select 'interest', 'MU', '博物馆', 'Museum';
insert basecode(cat,code,descript,descript1) select 'interest', 'SP', '运动', 'Sports';
insert basecode(cat,code,descript,descript1) select 'interest', 'DI', '美食', 'Fine Dining';




// --------------------------------------------------------------------------
//  basecode : language  -- 语种
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='language')
	delete basecode_cat where cat='language';
insert basecode_cat select 'language', '语种', 'language', 1;
delete basecode where cat='language';
insert basecode(cat,code,descript,descript1) select 'language', 'C', '中文', 'Chinese';
insert basecode(cat,code,descript,descript1) select 'language', 'E', '英语', 'English';
insert basecode(cat,code,descript,descript1) select 'language', 'J', '日文', 'Japanese';
insert basecode(cat,code,descript,descript1) select 'language', 'G', '德文', 'German';
insert basecode(cat,code,descript,descript1) select 'language', 'K', '韩文', 'Korean';


// ------------------------------------------------------------------------------
//	guest title : 称谓
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "title")
   drop table title;
create table title
(
	code			char(3)						not null,
	descript    char(20)						not null,
	descript1   varchar(30)	default ''	not null,
	grp			varchar(16)	default ''	not null,
	sequence		int		default 0		not null,
)
exec sp_primarykey title,code
create unique index index1 on title(code)
;
insert title(code,descript,descript1,grp) select 'RAC','门市价','Rack','IND'
insert title(code,descript,descript1,grp) select 'PAK','包价客人','Package','IND'
;


// -------------------------------------------------------------------------------------
//	客史档案
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest")
	drop table guest;
create table  guest
(
	no    		char(7)		 						not null,		/* 档案号:电脑自动生成 */
	sno         varchar(15)		default ''		not null,   	/* 客户号 单位自定义 */

	name		   varchar(50)	 						not null,	 	/* 姓名: 本名 */
	fname       varchar(30)		default ''		not null, 		/* 英文名 */
	lname			varchar(30)		default '' 		not null,		/* 英文姓 */
	name2		   varchar(50)		default '' 		not null,		/* 扩充名字 */
	name3		   varchar(50)		default '' 		not null,		/* 扩充名字 */
	sex			char(1)			default 'M'		not null,      /* 性别:M,F */
	lang			char(1)			default 'C'		not null,		/* 语种 */
	title			char(3)			default ''		not null,		/* 称呼 */
	salutation	varchar(60)		default ''		not null,		/* 称呼 */

	type			char(3)			default ''		not null,		/* 类型 -- n普通/b黑名单/c现付/r记账 */
	class			char(3)			default ''		not null,		/* 类别 */
	vip			char(1)			default '0'		not null,  		/* vip */
	keep			char(1) 			default 'F'  	not null,  		/* 保存 */

	birth       datetime								null,         	/* 生日 */		
	birthplace  char(6)			default ''		not null,      /* 籍贯 城市 */
	race			char(2)			default ''		not null, 		/* 民族 */
	occupation	char(2)			default ''		not null,		/* 职业 */
	country		char(3)			default ''		not null,	  /* 国家 */
	nation		char(3)			default ''		not null,	  /* 国籍 */

   idcls       char(3)     	default ''		not null,     	/* 最新证件类别 */
	ident		   char(20)	   	default ''		not null,     	/* 最新证件号码 */
	cusno			char(7)			default ''		not null,		/* 单位号 */
	unit        varchar(60)		default ''		not null,		/* 单位 */
	address	   varchar(60)		default ''		not null,		/* 住址 */
	address1	   varchar(60)		default ''		not null,		/* 住址 */
	zip			varchar(6)		default ''		not null,		/* 邮政编码 */
	handset		varchar(20)		default ''		not null,		/* 手机 */
	phone			varchar(20)		default ''		not null,		/* 电话 */
	fax			varchar(20)		default ''		not null,		/* 传真 */
	wetsite		varchar(30)		default ''		not null,		/* 网址 */
	email			varchar(30)		default ''		not null,		/* 电邮 */
	qq				varchar(30)		default ''		not null,		/* qq, msn, icq */

	visaid		char(1)			default ''		null,			/* 签证类别 */
	visabegin	datetime								null,		   /* 签证日期 */
	visaend		datetime								null,		   /* 签证有效期 */
	visano		varchar(20)							null,  		/* 签证号码 */
	visaunit		char(4)								null,    	/* 签证机关 */
   rjplace     char(3)     						null,       /* 入境口岸 */
	rjdate		datetime								null,		   /* 入境日期 */

   srqs        varchar(30)		default ''		not null,       /* 特殊要求 */
   feature		varchar(30)		default ''		not null,       /* 房间喜好1 */
	rmpref		varchar(20)		default ''		not null,       /* 房间喜好2 */
   interest		varchar(30)		default ''		not null,       /* 兴趣爱好 */
   refer      	varchar(250) 	default ''		not null,       /* 其他喜好 */
	extrainf		varchar(30)	 	default '' 		not null, 		 /* for gaoliang */ 
   remark      text 									null,				/* 备注 */
	override		char(1)     	default 'F'		not null,		/* 可以超额订房 */

	code1			char(10)			default ''		not null, 	/* 房价码 */
	code2			char(3)			default ''		not null, 	/* 餐娱码 */
	code3			char(3)			default ''		not null, 	/* 备用 */
	code4			char(3)			default ''		not null, 	/* 备用 */
	code5			char(3)			default ''		not null, 	/* 备用 */

   saleid      char(12)      	default ''		not null,	/* 销售员 */

	araccnt1		char(7)     	default ''		not null,	/* 应收帐号 */
	araccnt2		char(7)     	default ''		not null,	/* 应收帐号 */

	fv_date		datetime								null,			/* 首次到店 */
	fv_room		char(5)			default ''		not null,
	fv_rate		money				default 0		not null,
	lv_date		datetime								null,			/* 上次到店 */
	lv_room		char(5)			default ''		not null,
	lv_rate		money				default 0		not null,

   i_times     int 				default 0 		not null,   /* 住店次数 */
   x_times     int 				default 0 		not null,   /* 取消预订次数 */
   n_times     int 				default 0 		not null,   /* 应到未到次数 */
   l_times     int 				default 0 		not null,   /* 其它次数 */
   i_days      int 				default 0 		not null,   /* 住店天数 */
   tl          money 			default 0 		not null, 	/* 总收入  */
   rm          money 			default 0 		not null, 	/* 房租收入*/
   rm_b        money 			default 0 		not null, 	/* 房租服务费收入*/
   rm_e        money 			default 0 		not null, 	/* 房租城建费收入*/
   fb          money 			default 0 		not null, 	/* 餐饮收入*/
   en          money 			default 0 		not null, 	/* 娱乐收入*/
   ot          money 			default 0 		not null, 	/* 其它收入*/

   crtby       char(10)								not null,	/* 建立 */
	crttime     datetime 		default getdate()	not null,
   cby         char(10)								not null,	/* 修改 */
	changed     datetime 		default getdate()	not null,
	logmark     int 				default 0 		not null
)
exec sp_primarykey guest,no
create unique index index1 on guest(no)
create index index2 on guest(name)
create index index3 on guest(address)
create index index4 on guest(ident)
create index index5 on guest(i_times)
create index index6 on guest(i_days)
create index index7 on guest(tl)
create index index8 on guest(rm)
create index index9 on guest(fb)
create index index10 on guest(en)
create index index11 on guest(ot)
create index index17 on guest(sno)
;

// -------------------------------------------------------------------------------------
//	客史档案日志
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_log")
	drop table guest_log;
select * into guest_log from guest where 1=2;
exec sp_primarykey guest_log,no,logmark
create unique index index1 on guest_log(no, logmark)
;


// -------------------------------------------------------------------------------------
//		被删除的客史档案
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_del")
	drop table guest_del;
select * into guest_del from guest where 1=2;
exec sp_primarykey guest_del,no
create unique index index1 on guest_del(no)
create index index2 on guest_del(name)
create index index17 on guest_del(sno)
;

/*
insert guest 
  SELECT no,   
         isnull(sno,''),   
         name,   
         '','','','',   
         sex,   
         'C',   
         '',   
         '',   
         inman,   
         '0',   
         vip,   
         'T',   
         birth,   
         isnull(birthplace,''),   
         race,   
         isnull(occupation,''),   
         nation,   
         nation,   
         idcls,   
         ident,   
         isnull(cusno,   ''),
         isnull(fir,   ''),
         isnull(address,''),   
         '',   
         isnull(zip,''),   
         '',   
         ename,   
         '','','','',   
         '',null,null,'','','',null,
         isnull(srqs,   ''),
         '',   
         '',   
         '',   
         isnull(ref,   ''),
         extrainf,   
         remark,   
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
         cby,   
         changed,   
         cby,   
         changed,   
         logmark  
    FROM hgstinf;


*/