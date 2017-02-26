// -------------------------------------------------------------------------------------
//	客史档案 -- 包括客人和单位
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_sync")
	drop table guest_sync;
create table  guest_sync
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
	wetsite		varchar(30)		default ''		not null,		// 网址 
	email			varchar(30)		default ''		not null,		// 电邮 

	country1		char(3)			default ''		not null,	   // 国家 
	state1		char(3)			default ''		not null,	   // 国家 
	town1			varchar(40)		default ''		not null,		// 城市
	city1  		char(6)			default ''		not null,      // 籍贯
	street1	   varchar(100)		default ''		not null,		// 住址 
	zip1			varchar(6)		default ''		not null,		// 邮政编码 
	mobile1		varchar(20)		default ''		not null,		// 手机 
	phone1		varchar(20)		default ''		not null,		// 电话 
	fax1			varchar(20)		default ''		not null,		// 传真 
	email1		varchar(30)		default ''		not null,		// 电邮 

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
exec sp_primarykey guest_sync,no
create unique index index1 on guest_sync(no)
;
