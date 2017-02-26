//==========================================================================
//	Table : guest  -- 客史档案
//
//		basecode:	guest_type, interest, language, 
//						salegrp, cuscls1, cuscls2, cuscls3, cuscls4, incomekey
//						guest_grade, religion, latency, blkcls, guest_sumtag 
//
//		table :
//				title, guest, guest_log, guest_del, saleid, master_income, blkmst,
//				guest_extra
//==========================================================================


// --------------------------------------------------------------------------
//  basecode : guest_class  -- 客史档案的类别
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='guest_class')
	delete basecode_cat where cat='guest_class';
insert basecode_cat select 'guest_class', '客史档案类别', 'Guest Class', 1;
delete basecode where cat='guest_class';
insert basecode(cat,code,descript,descript1,sys) select 'guest_class', 'F', '散客', 'fit','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_class', 'G', '团体', 'grp','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_class', 'C', '公司', 'comp','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_class', 'A', '旅行社', 'agent','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_class', 'S', '订房中心', 'source','T';


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


// --------------------------------------------------------------------------
//  basecode : guest_type  -- 客史档案的类型
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='guest_type')
	delete basecode_cat where cat='guest_type';
insert basecode_cat select 'guest_type', '客史档案类别', 'Guest Class', 3;
delete basecode where cat='guest_type';
insert basecode(cat,code,descript,descript1,sys) select 'guest_type', 'N', '普通', 'Normal','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_type', 'B', '黑名单', 'Black','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_type', 'C', '现付', 'Cashes','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_type', 'R', '记帐', 'Post','T';


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
//  basecode : blkcls  -- 黑名单类别
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='blkcls')
	delete basecode_cat where cat='blkcls';
insert basecode_cat select 'blkcls', '黑名单类别', 'blkcls', 1;
delete basecode where cat='blkcls';
insert basecode(cat,code,descript,descript1) select 'blkcls', 'A', '逃帐客人', '逃帐客人_ENG';
insert basecode(cat,code,descript,descript1) select 'blkcls', 'B', '常赖帐客人', '常赖帐客人_ENG';
insert basecode(cat,code,descript,descript1) select 'blkcls', 'C', '通缉犯', '通缉犯_ENG';


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
create unique index index1 on title(code);
insert title(code,descript,descript1,grp) select 'RAC','门市价','Rack','IND'
insert title(code,descript,descript1,grp) select 'PAK','包价客人','Package','IND'
;

// --------------------------------------------------------------------------
//  basecode : guest_grade  -- 客户信用等级
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='guest_grade')
	delete basecode_cat where cat='guest_grade';
insert basecode_cat select 'guest_grade', '客户信用等级', 'guest grade', 1;
delete basecode where cat='guest_grade';
insert basecode(cat,code,descript,descript1) select 'guest_grade', 'A', '信用等级1', '信用等级1_ENG';
insert basecode(cat,code,descript,descript1) select 'guest_grade', 'B', '信用等级2', '信用等级2_ENG';
insert basecode(cat,code,descript,descript1) select 'guest_grade', 'C', '信用等级3', '信用等级3_ENG';
insert basecode(cat,code,descript,descript1) select 'guest_grade', 'D', '信用等级4', '信用等级4_ENG';


// --------------------------------------------------------------------------
//  basecode : latency  -- 潜在客户类别
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='latency')
	delete basecode_cat where cat='latency';
insert basecode_cat select 'latency', '潜在客户类别', 'latency', 1;
delete basecode where cat='latency';
insert basecode(cat,code,descript,descript1,sys) select 'latency', '0', '非潜在客户', '非潜在客户_ENG','T';
insert basecode(cat,code,descript,descript1) select 'latency', 'A', '潜在客户1', '潜在客户1';
insert basecode(cat,code,descript,descript1) select 'latency', 'B', '潜在客户2', '潜在客户2';
insert basecode(cat,code,descript,descript1) select 'latency', 'C', '潜在客户3', '潜在客户3';
insert basecode(cat,code,descript,descript1) select 'latency', 'D', '潜在客户4', '潜在客户4';


// --------------------------------------------------------------------------
//  basecode : religion  -- 宗教
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='religion')
	delete basecode_cat where cat='religion';
insert basecode_cat select 'religion', '宗教', 'religion', 1;
delete basecode where cat='religion';
insert basecode(cat,code,descript,descript1) select 'religion', '1', '基督教', '基督教_ENG';
insert basecode(cat,code,descript,descript1) select 'religion', '2', '佛教', '佛教_ENG';
insert basecode(cat,code,descript,descript1) select 'religion', '3', '伊斯兰教', '伊斯兰教_ENG';


// -------------------------------------------------------------------------------------
//	客史档案 -- 包括客人和单位
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest")
	drop table guest;
create table  guest
(
	no    		char(7)		 						not null,		// 档案号:电脑自动生成 
	sta			char(1)			default 'I' 	not null,		// 状态- I(n), O(ff), S(top), X(cancel)
	sno         varchar(15)		default ''		not null,   	// 客户号 单位自定义 
	cno         varchar(20)		default ''		not null,   	// 合同号码 

	hotelid		varchar(20)		default ''		not null,   	// Hotel ID.
	central		char(1)			default 'F'		not null,
	censeq		varchar(30)		default ''		not null,   	// Karis Seq.

	name		   varchar(50)	 						not null,	 	// 姓名: 本名 
	fname       varchar(30)		default ''		not null, 		// 英文名 
	lname			varchar(30)		default '' 		not null,		// 英文姓 
	name2		   varchar(50)		default '' 		not null,		// 扩充名字 
	name3		   varchar(50)		default '' 		not null,		// 扩充名字 
	name4		   varchar(255)	default '' 		not null,		// 扩充名字 
	class			char(1)			default ''		not null,		// 类别: 'F'=宾客 G=团体 C=公司；A=旅行社；S=订房中心 --> 固定代码； 
	type			char(1)			default 'N'		not null,		// 类型 -- N=普通/B=黑名单/C=现付/R=记账 
	grade			char(1)			default ''		not null,		// 信用等级
	latency		char(1)			default '0'		not null,		// 潜在客户 0 - 非潜在客户，其他表示类别

	class1		char(3)			default '0'		not null, 		// 附加类别	0=表示没有定义；
	class2		char(3)			default '0'		not null,
	class3		char(3)			default '0'		not null,
	class4		char(3)			default '0'		not null,
	src			char(3)			default ''		not null,		// 宾客来源
	market		char(3)			default ''		not null,		// 市场代码
	vip			char(3)			default '0'		not null,  		// vip 
	keep			char(1) 			default 'F'  	not null,  		// 保存 
	belong		varchar(15) 	default ''  	not null,  		// 档案归属 -- 比如餐饮需要独立的宾客当档案管理

	sex			char(1)			default '1'		not null,      // 性别:M,F 
	lang			char(1)			default 'C'		not null,		// 语种 
	title			char(3)			default ''		not null,		// 称呼 
	salutation	varchar(60)		default ''		not null,		// 称呼 

	birth       datetime								null,         	// 生日 		
	race			char(2)			default ''		not null, 		// 民族
	religion		char(2)			default ''		not null, 		// 宗教
	occupation	char(2)			default ''		not null,		// 职业 
	nation		char(3)			default ''		not null,	  // 国籍 

   idcls       char(3)     	default ''		not null,     	// 最新证件类别 
	ident		   char(20)	   	default ''		not null,     	// 最新证件号码 
	idend			datetime								null,		   	// 证件有效期			-- New
	cusno			char(7)			default ''		not null,		// 单位号 
	unit        varchar(60)		default ''		not null,		// 单位 

	cardcode		varchar(10)		default ''		not null,		// 信用卡型
	cardno		varchar(20)		default ''		not null,		// 信用卡号
	cardlevel	varchar(3)		default ''		not null,		// 级别

	country		char(3)			default ''		not null,	   // 国家 
	state			char(3)			default ''		not null,	   // 国家 
	town			varchar(40)		default ''		not null,		// 城市
	city  		char(6)			default ''		not null,      // 籍贯
	street	   varchar(100)		default ''		not null,		// 住址 
	zip			varchar(6)		default ''		not null,		// 邮政编码 
	mobile		varchar(20)		default ''		not null,		// 手机 
	phone			varchar(20)		default ''		not null,		// 电话 
	fax			varchar(20)		default ''		not null,		// 传真 
	wetsite		varchar(60)		default ''		not null,		// 网址 
	email			varchar(60)		default ''		not null,		// 电邮 

	country1		char(3)			default ''		not null,	   // 国家 
	state1		char(3)			default ''		not null,	   // 国家 
	town1			varchar(40)		default ''		not null,		// 城市
	city1  		char(6)			default ''		not null,      // 籍贯
	street1	   varchar(100)		default ''		not null,		// 住址 
	zip1			varchar(6)		default ''		not null,		// 邮政编码 
	mobile1		varchar(20)		default ''		not null,		// 手机 
	phone1		varchar(20)		default ''		not null,		// 电话 
	fax1			varchar(20)		default ''		not null,		// 传真 
	email1		varchar(60)		default ''		not null,		// 电邮 

	visaid		char(3)			default ''		null,			// 签证类别 
	visaend		datetime								null,		   // 签证有效期 
	visano		varchar(20)							null,  		// 签证号码 
	visaunit		char(4)								null,    	// 签证机关 
   rjplace     char(3)     						null,       // 入境口岸 
	rjdate		datetime								null,		   // 入境日期 

   srqs        varchar(30)		default ''		not null,   // 特殊要求 
	amenities  	varchar(30)		default ''		not null,	// 房间布置
   feature		varchar(30)		default ''		not null,   // 房间喜好1 
	rmpref		varchar(20)		default ''		not null,   // 房间喜好2 
   interest		varchar(30)		default ''		not null,   // 兴趣爱好 

	lawman		varchar(16)		default ''		null,			// 法定代表人
	regno			varchar(20)		default ''		null,			// 企业登记号
	bank			varchar(50)		default ''		null,			// 开户银行
	bankno		varchar(20)		default ''		null,			// 银行帐号
	taxno			varchar(20)		default ''		null,			// 税号
   liason      varchar(30)   	default ''		not null,   // 联系人
   liason1     varchar(30)   	default ''		null,     	// 联系方式
	extrainf		varchar(30)	 	default '' 		not null, 	// for gaoliang  
   refer1     	varchar(250) 	default ''		not null,   // 客房喜好
   refer2     	varchar(250) 	default ''		not null,   // 餐饮喜好
   refer3     	varchar(250) 	default ''		not null,   // 其他喜好 
   comment    	varchar(100) 	default ''		not null,   // 说明
   remark      text 									null,			// 备注 
	override		char(1)     	default 'F'		not null,	// 可以超额订房 

   arr         datetime      						null,  		// 有效日期
   dep         datetime      						null,			// 终止日期

	code1			char(10)			default ''		not null, 	// 房价码 
	code2			char(10)			default ''		not null, 	// 餐娱码 
	code3			char(10)			default ''		not null, 	// 备用 
	code4			char(10)			default ''		not null, 	// 备用 
	code5			char(10)			default ''		not null, 	// 备用 

	iata			varchar(30)		default ''		not null, 	// 旅行社
	flag			varchar(50)		default ''		not null, 

   saleid      char(12)      	default ''		not null,	// 销售员 

	araccnt1		char(10)     	default ''		not null,	// 应收帐号 
	araccnt2		char(10)     	default ''		not null,	// 应收帐号 
	master		char(7)     	default ''		not null,	// 主帐号 

	fv_date		datetime								null,			// 首次到店 
	fv_room		char(5)			default ''		not null,
	fv_rate		money				default 0		not null,
	lv_date		datetime								null,			// 上次到店 
	lv_room		char(5)			default ''		not null,
	lv_rate		money				default 0		not null,

   i_times     int 				default 0 		not null,   // 住店次数 
   x_times     int 				default 0 		not null,   // 取消预订次数 
   n_times     int 				default 0 		not null,   // 应到未到次数 
   l_times     int 				default 0 		not null,   // 其它次数 
   i_days      int 				default 0 		not null,   // 住店天数 

   fb_times1    int 				default 0 		not null,   // 餐饮次数 
   en_times2    int 				default 0 		not null,   // 娱乐次数 

   rm          money 			default 0 		not null, 	// 房租收入
   fb          money 			default 0 		not null, 	// 餐饮收入
   en          money 			default 0 		not null, 	// 娱乐收入
   mt          money 			default 0 		not null, 	// 会议收入
   ot          money 			default 0 		not null, 	// 其它收入
   tl          money 			default 0 		not null, 	// 总收入  

-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_dt3		datetime			null,
	exp_dt4		datetime			null,
	exp_dt5		datetime			null,
	exp_dt6		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,
	exp_s4		varchar(30)		null,
	exp_s5		varchar(30)		null,
	exp_s6		varchar(50)		null,

   crtby       char(10)								not null,	// 建立 
	crttime     datetime 		default getdate()	not null,
   cby         char(10)								not null,	// 修改 
	changed     datetime 		default getdate()	not null,
	logmark     int 				default 0 		not null
)
exec sp_primarykey guest,no
create unique index index1 on guest(no)
create index index2 on guest(name)
create index name2 on guest(name2)
create index name3 on guest(name3)
create index index3 on guest(street)
create index index4 on guest(ident)
create index index5 on guest(i_times)
create index index6 on guest(i_days)
create index index7 on guest(tl)
create index index8 on guest(rm)
create index index9 on guest(fb)
create index index10 on guest(en)
create index index11 on guest(ot)
create index index17 on guest(sno)
create index index18 on guest(changed)
;

// -------------------------------------------------------------------------------------
//	客史档案日志
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_log")
	drop table guest_log;
create table  guest_log
(
	no    		char(7)		 						not null,		// 档案号:电脑自动生成 
	sta			char(1)			default 'I' 	not null,		// 状态- I(n), O(ff), S(top), X(cancel)
	sno         varchar(15)		default ''		not null,   	// 客户号 单位自定义 
	cno         varchar(20)		default ''		not null,   	// 合同号码 

	hotelid		varchar(20)		default ''		not null,   	// Hotel ID.
	central		char(1)			default 'F'		not null,
	censeq		varchar(30)		default ''		not null,   	// Karis Seq.

	name		   varchar(50)	 						not null,	 	// 姓名: 本名 
	fname       varchar(30)		default ''		not null, 		// 英文名 
	lname			varchar(30)		default '' 		not null,		// 英文姓 
	name2		   varchar(50)		default '' 		not null,		// 扩充名字 
	name3		   varchar(50)		default '' 		not null,		// 扩充名字 
	name4		   varchar(255)	default '' 		not null,		// 扩充名字 
	class			char(1)			default ''		not null,		// 类别: 'F'=宾客 G=团体 C=公司；A=旅行社；S=订房中心 --> 固定代码； 
	type			char(1)			default 'N'		not null,		// 类型 -- N=普通/B=黑名单/C=现付/R=记账 
	grade			char(1)			default ''		not null,		// 信用等级
	latency		char(1)			default '0'		not null,		// 潜在客户 0 - 非潜在客户，其他表示类别

	class1		char(3)			default '0'		not null, 		// 附加类别	0=表示没有定义；
	class2		char(3)			default '0'		not null,
	class3		char(3)			default '0'		not null,
	class4		char(3)			default '0'		not null,
	src			char(3)			default ''		not null,		// 宾客来源
	market		char(3)			default ''		not null,		// 市场代码
	vip			char(3)			default '0'		not null,  		// vip 
	keep			char(1) 			default 'F'  	not null,  		// 保存 
	belong		varchar(15) 	default ''  	not null,  		// 档案归属 -- 比如餐饮需要独立的宾客当档案管理

	sex			char(1)			default '1'		not null,      // 性别:M,F 
	lang			char(1)			default 'C'		not null,		// 语种 
	title			char(3)			default ''		not null,		// 称呼 
	salutation	varchar(60)		default ''		not null,		// 称呼 

	birth       datetime								null,         	// 生日 		
	race			char(2)			default ''		not null, 		// 民族
	religion		char(2)			default ''		not null, 		// 宗教
	occupation	char(2)			default ''		not null,		// 职业 
	nation		char(3)			default ''		not null,	  // 国籍 

   idcls       char(3)     	default ''		not null,     	// 最新证件类别 
	ident		   char(20)	   	default ''		not null,     	// 最新证件号码 
	idend			datetime								null,		   	// 证件有效期			-- New
	cusno			char(7)			default ''		not null,		// 单位号 
	unit        varchar(60)		default ''		not null,		// 单位 

	cardcode		varchar(10)		default ''		not null,		// 信用卡型
	cardno		varchar(20)		default ''		not null,		// 信用卡号
	cardlevel	varchar(3)		default ''		not null,		// 级别

	country		char(3)			default ''		not null,	   // 国家 
	state			char(3)			default ''		not null,	   // 国家 
	town			varchar(40)		default ''		not null,		// 城市
	city  		char(6)			default ''		not null,      // 籍贯
	street	   varchar(100)		default ''		not null,		// 住址 
	zip			varchar(6)		default ''		not null,		// 邮政编码 
	mobile		varchar(20)		default ''		not null,		// 手机 
	phone			varchar(20)		default ''		not null,		// 电话 
	fax			varchar(20)		default ''		not null,		// 传真 
	wetsite		varchar(60)		default ''		not null,		// 网址 
	email			varchar(60)		default ''		not null,		// 电邮 

	country1		char(3)			default ''		not null,	   // 国家 
	state1		char(3)			default ''		not null,	   // 国家 
	town1			varchar(40)		default ''		not null,		// 城市
	city1  		char(6)			default ''		not null,      // 籍贯
	street1	   varchar(100)		default ''		not null,		// 住址 
	zip1			varchar(6)		default ''		not null,		// 邮政编码 
	mobile1		varchar(20)		default ''		not null,		// 手机 
	phone1		varchar(20)		default ''		not null,		// 电话 
	fax1			varchar(20)		default ''		not null,		// 传真 
	email1		varchar(60)		default ''		not null,		// 电邮 

	visaid		char(3)			default ''		null,			// 签证类别 
	visaend		datetime								null,		   // 签证有效期 
	visano		varchar(20)							null,  		// 签证号码 
	visaunit		char(4)								null,    	// 签证机关 
   rjplace     char(3)     						null,       // 入境口岸 
	rjdate		datetime								null,		   // 入境日期 

   srqs        varchar(30)		default ''		not null,   // 特殊要求 
	amenities  	varchar(30)		default ''		not null,	// 房间布置
   feature		varchar(30)		default ''		not null,   // 房间喜好1 
	rmpref		varchar(20)		default ''		not null,   // 房间喜好2 
   interest		varchar(30)		default ''		not null,   // 兴趣爱好 

	lawman		varchar(16)		default ''		null,			// 法定代表人
	regno			varchar(20)		default ''		null,			// 企业登记号
	bank			varchar(50)		default ''		null,			// 开户银行
	bankno		varchar(20)		default ''		null,			// 银行帐号
	taxno			varchar(20)		default ''		null,			// 税号
   liason      varchar(30)   	default ''		not null,   // 联系人
   liason1     varchar(30)   	default ''		null,     	// 联系方式
	extrainf		varchar(30)	 	default '' 		not null, 	// for gaoliang  
   refer1     	varchar(250) 	default ''		not null,   // 客房喜好
   refer2     	varchar(250) 	default ''		not null,   // 餐饮喜好
   refer3     	varchar(250) 	default ''		not null,   // 其他喜好 
   comment    	varchar(100) 	default ''		not null,   // 说明
   remark      text 									null,			// 备注 
	override		char(1)     	default 'F'		not null,	// 可以超额订房 

   arr         datetime      						null,  		// 有效日期
   dep         datetime      						null,			// 终止日期

	code1			char(10)			default ''		not null, 	// 房价码 
	code2			char(10)			default ''		not null, 	// 餐娱码 
	code3			char(10)			default ''		not null, 	// 备用 
	code4			char(10)			default ''		not null, 	// 备用 
	code5			char(10)			default ''		not null, 	// 备用 

	iata			varchar(30)		default ''		not null, 	// 旅行社
	flag			varchar(50)		default ''		not null, 

   saleid      char(12)      	default ''		not null,	// 销售员 

	araccnt1		char(10)     	default ''		not null,	// 应收帐号 
	araccnt2		char(10)     	default ''		not null,	// 应收帐号 
	master		char(7)     	default ''		not null,	// 主帐号 

	fv_date		datetime								null,			// 首次到店 
	fv_room		char(5)			default ''		not null,
	fv_rate		money				default 0		not null,
	lv_date		datetime								null,			// 上次到店 
	lv_room		char(5)			default ''		not null,
	lv_rate		money				default 0		not null,

   i_times     int 				default 0 		not null,   // 住店次数 
   x_times     int 				default 0 		not null,   // 取消预订次数 
   n_times     int 				default 0 		not null,   // 应到未到次数 
   l_times     int 				default 0 		not null,   // 其它次数 
   i_days      int 				default 0 		not null,   // 住店天数 

   fb_times1    int 				default 0 		not null,   // 餐饮次数 
   en_times2    int 				default 0 		not null,   // 娱乐次数 

   rm          money 			default 0 		not null, 	// 房租收入
   fb          money 			default 0 		not null, 	// 餐饮收入
   en          money 			default 0 		not null, 	// 娱乐收入
   mt          money 			default 0 		not null, 	// 会议收入
   ot          money 			default 0 		not null, 	// 其它收入
   tl          money 			default 0 		not null, 	// 总收入  

-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_dt3		datetime			null,
	exp_dt4		datetime			null,
	exp_dt5		datetime			null,
	exp_dt6		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,
	exp_s4		varchar(30)		null,
	exp_s5		varchar(30)		null,
	exp_s6		varchar(50)		null,

   crtby       char(10)								not null,	// 建立 
	crttime     datetime 		default getdate()	not null,
   cby         char(10)								not null,	// 修改 
	changed     datetime 		default getdate()	not null,
	logmark     int 				default 0 		not null
)
exec sp_primarykey guest_log,no,logmark
create unique index index1 on guest_log(no, logmark)
;


// -------------------------------------------------------------------------------------
//		被删除的客史档案
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_del")
	drop table guest_del;
create table  guest_del
(
	no    		char(7)		 						not null,		// 档案号:电脑自动生成 
	sta			char(1)			default 'I' 	not null,		// 状态- I(n), O(ff), S(top), X(cancel)
	sno         varchar(15)		default ''		not null,   	// 客户号 单位自定义 
	cno         varchar(20)		default ''		not null,   	// 合同号码 

	hotelid		varchar(20)		default ''		not null,   	// Hotel ID.
	central		char(1)			default 'F'		not null,
	censeq		varchar(30)		default ''		not null,   	// Karis Seq.

	name		   varchar(50)	 						not null,	 	// 姓名: 本名 
	fname       varchar(30)		default ''		not null, 		// 英文名 
	lname			varchar(30)		default '' 		not null,		// 英文姓 
	name2		   varchar(50)		default '' 		not null,		// 扩充名字 
	name3		   varchar(50)		default '' 		not null,		// 扩充名字 
	name4		   varchar(255)	default '' 		not null,		// 扩充名字 
	class			char(1)			default ''		not null,		// 类别: 'F'=宾客 G=团体 C=公司；A=旅行社；S=订房中心 --> 固定代码； 
	type			char(1)			default 'N'		not null,		// 类型 -- N=普通/B=黑名单/C=现付/R=记账 
	grade			char(1)			default ''		not null,		// 信用等级
	latency		char(1)			default '0'		not null,		// 潜在客户 0 - 非潜在客户，其他表示类别

	class1		char(3)			default '0'		not null, 		// 附加类别	0=表示没有定义；
	class2		char(3)			default '0'		not null,
	class3		char(3)			default '0'		not null,
	class4		char(3)			default '0'		not null,
	src			char(3)			default ''		not null,		// 宾客来源
	market		char(3)			default ''		not null,		// 市场代码
	vip			char(3)			default '0'		not null,  		// vip 
	keep			char(1) 			default 'F'  	not null,  		// 保存 
	belong		varchar(15) 	default ''  	not null,  		// 档案归属 -- 比如餐饮需要独立的宾客当档案管理

	sex			char(1)			default '1'		not null,      // 性别:M,F 
	lang			char(1)			default 'C'		not null,		// 语种 
	title			char(3)			default ''		not null,		// 称呼 
	salutation	varchar(60)		default ''		not null,		// 称呼 

	birth       datetime								null,         	// 生日 		
	race			char(2)			default ''		not null, 		// 民族
	religion		char(2)			default ''		not null, 		// 宗教
	occupation	char(2)			default ''		not null,		// 职业 
	nation		char(3)			default ''		not null,	  // 国籍 

   idcls       char(3)     	default ''		not null,     	// 最新证件类别 
	ident		   char(20)	   	default ''		not null,     	// 最新证件号码 
	idend			datetime								null,		   	// 证件有效期			-- New
	cusno			char(7)			default ''		not null,		// 单位号 
	unit        varchar(60)		default ''		not null,		// 单位 

	cardcode		varchar(10)		default ''		not null,		// 信用卡型
	cardno		varchar(20)		default ''		not null,		// 信用卡号
	cardlevel	varchar(3)		default ''		not null,		// 级别

	country		char(3)			default ''		not null,	   // 国家 
	state			char(3)			default ''		not null,	   // 国家 
	town			varchar(40)		default ''		not null,		// 城市
	city  		char(6)			default ''		not null,      // 籍贯
	street	   varchar(100)		default ''		not null,		// 住址 
	zip			varchar(6)		default ''		not null,		// 邮政编码 
	mobile		varchar(20)		default ''		not null,		// 手机 
	phone			varchar(20)		default ''		not null,		// 电话 
	fax			varchar(20)		default ''		not null,		// 传真 
	wetsite		varchar(60)		default ''		not null,		// 网址 
	email			varchar(60)		default ''		not null,		// 电邮 

	country1		char(3)			default ''		not null,	   // 国家 
	state1		char(3)			default ''		not null,	   // 国家 
	town1			varchar(40)		default ''		not null,		// 城市
	city1  		char(6)			default ''		not null,      // 籍贯
	street1	   varchar(100)		default ''		not null,		// 住址 
	zip1			varchar(6)		default ''		not null,		// 邮政编码 
	mobile1		varchar(20)		default ''		not null,		// 手机 
	phone1		varchar(20)		default ''		not null,		// 电话 
	fax1			varchar(20)		default ''		not null,		// 传真 
	email1		varchar(60)		default ''		not null,		// 电邮 

	visaid		char(3)			default ''		null,			// 签证类别 
	visaend		datetime								null,		   // 签证有效期 
	visano		varchar(20)							null,  		// 签证号码 
	visaunit		char(4)								null,    	// 签证机关 
   rjplace     char(3)     						null,       // 入境口岸 
	rjdate		datetime								null,		   // 入境日期 

   srqs        varchar(30)		default ''		not null,   // 特殊要求 
	amenities  	varchar(30)		default ''		not null,	// 房间布置
   feature		varchar(30)		default ''		not null,   // 房间喜好1 
	rmpref		varchar(20)		default ''		not null,   // 房间喜好2 
   interest		varchar(30)		default ''		not null,   // 兴趣爱好 

	lawman		varchar(16)		default ''		null,			// 法定代表人
	regno			varchar(20)		default ''		null,			// 企业登记号
	bank			varchar(50)		default ''		null,			// 开户银行
	bankno		varchar(20)		default ''		null,			// 银行帐号
	taxno			varchar(20)		default ''		null,			// 税号
   liason      varchar(30)   	default ''		not null,   // 联系人
   liason1     varchar(30)   	default ''		null,     	// 联系方式
	extrainf		varchar(30)	 	default '' 		not null, 	// for gaoliang  
   refer1     	varchar(250) 	default ''		not null,   // 客房喜好
   refer2     	varchar(250) 	default ''		not null,   // 餐饮喜好
   refer3     	varchar(250) 	default ''		not null,   // 其他喜好 
   comment    	varchar(100) 	default ''		not null,   // 说明
   remark      text 									null,			// 备注 
	override		char(1)     	default 'F'		not null,	// 可以超额订房 

   arr         datetime      						null,  		// 有效日期
   dep         datetime      						null,			// 终止日期

	code1			char(10)			default ''		not null, 	// 房价码 
	code2			char(10)			default ''		not null, 	// 餐娱码 
	code3			char(10)			default ''		not null, 	// 备用 
	code4			char(10)			default ''		not null, 	// 备用 
	code5			char(10)			default ''		not null, 	// 备用 

	iata			varchar(30)		default ''		not null, 	// 旅行社
	flag			varchar(50)		default ''		not null, 

   saleid      char(12)      	default ''		not null,	// 销售员 

	araccnt1		char(10)     	default ''		not null,	// 应收帐号 
	araccnt2		char(10)     	default ''		not null,	// 应收帐号 
	master		char(7)     	default ''		not null,	// 主帐号 

	fv_date		datetime								null,			// 首次到店 
	fv_room		char(5)			default ''		not null,
	fv_rate		money				default 0		not null,
	lv_date		datetime								null,			// 上次到店 
	lv_room		char(5)			default ''		not null,
	lv_rate		money				default 0		not null,

   i_times     int 				default 0 		not null,   // 住店次数 
   x_times     int 				default 0 		not null,   // 取消预订次数 
   n_times     int 				default 0 		not null,   // 应到未到次数 
   l_times     int 				default 0 		not null,   // 其它次数 
   i_days      int 				default 0 		not null,   // 住店天数 

   fb_times1    int 				default 0 		not null,   // 餐饮次数 
   en_times2    int 				default 0 		not null,   // 娱乐次数 

   rm          money 			default 0 		not null, 	// 房租收入
   fb          money 			default 0 		not null, 	// 餐饮收入
   en          money 			default 0 		not null, 	// 娱乐收入
   mt          money 			default 0 		not null, 	// 会议收入
   ot          money 			default 0 		not null, 	// 其它收入
   tl          money 			default 0 		not null, 	// 总收入  

-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_dt3		datetime			null,
	exp_dt4		datetime			null,
	exp_dt5		datetime			null,
	exp_dt6		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,
	exp_s4		varchar(30)		null,
	exp_s5		varchar(30)		null,
	exp_s6		varchar(50)		null,

   crtby       char(10)								not null,	// 建立 
	crttime     datetime 		default getdate()	not null,
   cby         char(10)								not null,	// 修改 
	changed     datetime 		default getdate()	not null,
	logmark     int 				default 0 		not null
)
exec sp_primarykey guest_del,no
create unique index index1 on guest_del(no)
create index index2 on guest_del(name)
create index index17 on guest_del(sno)
;


// -------------------------------------------------------------------------------------
//	黑名单信息 -- 档案信息放在 guest 表中
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "blkmst")
	drop table blkmst;
create table  blkmst
(
	no    		char(7)		 						not null,		// 档案号
	class			char(1)			default '' 		not null,		// 黑名单类别
	remark		varchar(255)	default ''		not null
)
exec sp_primarykey blkmst,no
create unique index index1 on blkmst(no)
;


// --------------------------------------------------------------------------
//  basecode : incomekey  -- 消费类别
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='incomekey')
	delete basecode_cat where cat='incomekey';
insert basecode_cat select 'incomekey', '消费类别', 'incomekey', 10;
delete basecode where cat='incomekey';
insert basecode(cat,code,descript,descript1,sys) select 'incomekey', 'I_GUESTS', '入住人数', 'i_guests','T';
insert basecode(cat,code,descript,descript1,sys) select 'incomekey', 'I_TIMES', '入住次数', 'i_times','T';
insert basecode(cat,code,descript,descript1,sys) select 'incomekey', 'N_TIMES', 'noshow 次数', 'noshow times','T';
insert basecode(cat,code,descript,descript1,sys) select 'incomekey', 'X_TIMES', '取消次数', 'cancel times','T';



// -------------------------------------------------------------------------------------
//		客户消费信息
//
//		消费记录关系: guest->master->master_income
//
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "master_income")
	drop table master_income;
create table  master_income
(
	accnt				char(10)							not null,
	master			char(10)			default''	not null,
	pccode			char(5)			default ''	not null,
	item				varchar(10)		default ''	not null,
	amount1			money		default 0			not null,
	amount2			money		default 0			not null
)
exec sp_primarykey master_income,accnt,pccode,item
create unique index index1 on master_income(accnt,pccode,item)
;


// -------------------------------------------------------------------------------------
//	客史档案附加信息
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_extra")
	drop table guest_extra;
create table  guest_extra
(
	no    		char(7)		 						not null,
	item			char(10)								not null,	// 信息关键字 ratecode,posmode
	value       varchar(30)							not null		// 取值
)
exec sp_primarykey guest_extra,no,item,value
create unique index index1 on guest_extra(no,item,value)
;



// -------------------------------------------------------------------------------------
//	客史档案 简表 -- 包括客人和单位
//	
//		from x50204, delete the table 
// -------------------------------------------------------------------------------------
//if exists(select * from sysobjects where name = "hguest")
//	drop table hguest;
//create table  hguest
//(
//	no    		char(7)		 						not null,		// 档案号:电脑自动生成 
//	sta			char(1)			default 'I' 	not null,		// 状态- I(n), O(ff), S(top), X(cancel)
//	sno         varchar(15)		default ''		not null,   	// 客户号 单位自定义 
//	name		   varchar(50)	 						not null,	 	// 姓名: 本名 
//	fname       varchar(30)		default ''		not null, 		// 英文名 
//	lname			varchar(30)		default '' 		not null,		// 英文姓 
//	name2		   varchar(50)		default '' 		not null,		// 扩充名字 
//	name3		   varchar(50)		default '' 		not null,		// 扩充名字 
//	name4		   varchar(255)	default '' 		not null,		// 扩充名字 
//
//	class			char(1)			default ''		not null,		// 类别: 'F'=宾客 G=团体 C=公司；A=旅行社；S=订房中心 --> 固定代码； 
//	type			char(1)			default 'N'		not null,		// 类型 -- N=普通/B=黑名单/C=现付/R=记账 
//
//	class1		varchar(3)			default '0'		not null, 		// 附加类别	0=表示没有定义；
//	class2		varchar(3)			default '0'		not null,
//	class3		varchar(3)			default '0'		not null,
//	class4		varchar(3)			default '0'		not null,
//	vip			char(3)				default '0'		not null,  		// vip 
//
//	sex			char(1)				default '1'		not null,      // 性别:M,F 
//	birth       datetime								null,         	// 生日
//	nation		varchar(3)			default ''		not null,	  // 国籍 
//
//	country		char(3)			default ''		not null,	   // 国家 
//	state			char(3)			default ''		not null,
//	town			varchar(40)		default ''		not null,		// 城市
//	city  		varchar(6)			default ''		not null,      // 籍贯 城市 
//	street	   varchar(100)			default ''		not null,		// 住址 
//
//   idcls       varchar(3)     	default ''		not null,     	// 最新证件类别 
//	ident		   varchar(20)	   	default ''		not null,     	// 最新证件号码 
//	cusno			varchar(7)			default ''		not null,		// 单位号 
//	unit        varchar(60)			default ''		not null,		// 单位 
//   liason      varchar(30)   		default ''		not null,   // 联系人
//   saleid      varchar(12)      	default ''		not null		// 销售员 
//)
//exec sp_primarykey hguest,no
//create unique index index1 on hguest(no)
//create index index2 on hguest(name)
//create index index3 on hguest(street)
//create index index4 on hguest(ident)
//create index index5 on hguest(sno)
//create index index6 on hguest(class)
//create index index7 on hguest(country)
//create index index8 on hguest(saleid)
//create index index9 on hguest(unit)
//create index index11 on hguest(class1)
//create index index12 on hguest(class2)
//;

// -----------------------------------------------------------------------
// guest_xfttl  
//
//	这个表的设计有两种方式： 
// 
//		1 每个月设置多个列，用来表示不同的项目 - 好处是统计与显示简单 
//		2 每个月一列，不用的项目采用不同的行 - 好处是可以灵活的增加统计项目
// -----------------------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "guest_xfttl")
   drop table guest_xfttl;
create table guest_xfttl
(
	hotelid		varchar(20)		default '' not null,		-- 酒店代码
	no				char(7)			default ''	not null,	-- 档案号码
	year			char(4)			default ''	not null,	-- 年度
	tag			varchar(10)		default ''	not null,	-- 项目 basecode (cat = guest_sumtag)
	ttl			money				default 0 not null,		-- 合计数
	m1				money				default 0 not null,
	m2				money				default 0 not null,
	m3				money				default 0 not null,
	m4				money				default 0 not null,
	m5				money				default 0 not null,
	m6				money				default 0 not null,
	m7				money				default 0 not null,
	m8				money				default 0 not null,
	m9				money				default 0 not null,
	m10			money				default 0 not null,
	m11			money				default 0 not null,
	m12			money				default 0 not null
);
exec sp_primarykey guest_xfttl, hotelid, no, year, tag
create unique index index1 on guest_xfttl(hotelid, no, year, tag)
;


// --------------------------------------------------------------------------
//  basecode : guest_sumtag  -- 客史档案的消费统计项目 
// --------------------------------------------------------------------------
delete basecode where cat='guest_sumtag';
delete basecode_cat where cat='guest_sumtag';
insert basecode_cat(cat,descript,descript1,len) select 'guest_sumtag', '客史档案的消费统计项目', 'Guest Summary Item', 10;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'guest_sumtag', 'RM', '房费', 'Room','T',100;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'guest_sumtag', 'FB', '餐费', 'F&b','T',200;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'guest_sumtag', 'OT', '其他', 'Other','T',300;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'guest_sumtag', 'TTL', '总收入', 'Total','T',350;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'guest_sumtag', 'NIGHTS', '房晚', 'Nigths','T',400;


