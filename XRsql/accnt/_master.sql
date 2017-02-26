//==========================================================================
//Table : master
//
//diffrent from v5
//	modify:
//		accnt, groupno				char(7) -> char(10)
//		ratemode						--> package
//		tranlog						--> ratecode
//		src							char(1) -> char(3)
//		srqs		   				-->varchar(30)
//	delete:
//		ooroomno
//		oclass
//		class
//		archive		char(1)		default 'Y',/* 建挡标志 */
//		pcrec		   char(7)	null,		/*  联房标志账号  */
//		phonesta	   char(1)		null,		/* 分机等级 */
//		vodsta	   char(1)		null,		/* 分机等级 */
//		locksta		char(1)		default 'Y',/* 帐号控制状态(如冻结余额等) */
//		ref			varchar(80)		null,		/* 备注 */
//		exp_m			money				null,
//		exp_dt		datetime			null,
//		exp_s			varchar(10)		null,
//
//	add:
//		share
//		from guest table : 事由、签证、来地去地、
//
//
//==========================================================================
//
//
//==========================================================================


if exists(select * from sysobjects where name = "master" and type="U")
	drop table master;
create table master
(
	accnt		   char(10)						not null,	/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)		default '' 	not null,	/* 宾客档案号  */
	groupno		char(10)		default '' 	not null,	/* 所属团号  */
	type		   char(3)		default ''	not null,	/* 房间类型(cf. typim,block,pickup)  */
   otype       char(3)     default ''	not null,  	/* 更新前的房间类型  */
	up_type		char(3)     default ''	null,  		/* 从哪个房间类型升级  */
	up_reason	char(3)     default ''	not null,  	/* 升级原因  */
	rmnum			int			default 0	not null,
	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	/* 房号 */
	oroomno     char(5)     default ''	not null,  	/* 更新前的房号 */
	bdate		   datetime	   				not null,	/* 入住那天的营业日期=business date */
	sta			char(1)						not null,   /* 帐号状态(其说明见说明书) */
	osta        char(1)     default ''	not null,   /* 更新前的帐号状态 */
	ressta      char(1)     default ''	not null,   /* 结帐时保存的状态,用来撤消结帐并恢复到原状态 */
	exp_sta		char(1)		default '' 	null,			/*  团体房的房标  */										---
	sta_tm		char(1)		default '' 	not null,	/* 帐号状态(稽核用) */
	rmpoststa	char(1)		default '' 	not null,	/* 控制字段:过房费时用 */									---
	rmposted	   char(1)		default "F"	not null,	/* 从入住日起是否过过房费 */
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	/* 到店日期=arrival */
	dep			datetime	   				not null,	/* 离店日期=departure */
   resdep      datetime    				null,       /* 结帐时保存的离开日期,用来撤消结帐 */
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	/* 类别: ''-fit, g-grp, m-meet, a-armst */
	src			char(3)		default '' 	not null,	/* 来源 */
	market		char(3)		default '' 	not null,	/* 市场码 */
	restype		char(3)		default '' 	not null,	/* 预订类别 */
	channel		char(3)		default '' 	not null,	/* 渠道 */
	
	share		   char(1)		default '' 	not null,	/* 是否可以同住   */
	gstno		   int			default 1 	not null,   /* 成人 */
	children		int			default 0	not null,	/* 小孩 */
	rmreason	   char(1)		default ''	not null,	/* 换房理由 */

	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	packages		char(20)		default ''	not null,	/* 包价  */
	fixrate	   char(1)		default 'F'	not null,	/* 固定房价 */
	rmrate		money			default 0	not null,	/* 房间报价 */
	qtrate		money			default 0	not null,	/* 协议房间报价 */
	setrate		money			default 0	not null,	/* 与优惠及优惠理由一起决定实际房价 */
	rtreason	   char(3)		default ''	not null,	/* 房价优惠理由(cf.rtreason.dbf) */
	discount	   money			default 0	not null,	/* 优惠额 */
	discount1	money			default 0	not null,	/* 优惠比例 */
	addbed	   money			default 0 	not null,	/* 加床数量  */
	addbed_rate	money			default 0 	not null,	/* 加床价 */
	crib	   	money			default 0 	not null,	/* 婴儿床数量 */
	crib_rate	money			default 0 	not null,	/* 婴儿床价格 */

	paycode		char(4)		default ''	not null,	/* 结算方式 */
	limit		   money			default 0 	not null,	/* 限额(催帐用) */
	credcode		varchar(20)	default ''	not null,	/* 信用卡号码 */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* 订房人/委托人 */
	applicant	varchar(60)	default ''	not null,	/* 单位/委托单位 */
	araccnt		varchar(7)	default ''	not null,	/* AR帐号(与City ledger,travel agency结算用) */
	phone    	varchar(16)    			null,       /* 联系电话等 */

	visaid		char(1)		default ''	null,			/* 签证类别 */
	visabegin	datetime						null,		   /* 签证日期 */
	visaend		datetime						null,		   /* 签证有效期 */
	visano		varchar(20)					null,  		/* 签证号码 */
	visaunit		char(4)						null,    	/* 签证机关 */
   rjplace     char(3)     				null,       /* 入境口岸 */
	rjdate		datetime						null,		   /* 入境日期 */
	wherefrom	char(6)		default ''	not null,	/* 何地来 */
	whereto		char(6)		default ''	not null,	/* 何地去 */
	purpose		char(3)		default ''	not null,	/* 事由 */

	arrdate		datetime						null,			/* 到达信息 */
	arrinfo		varchar(30)					null,
	depdate		datetime						null,       /* 离开信息 */
	depinfo		varchar(30)					null,

	extra			char(15)		default ''	not null,	/* 附加信息 : 不打印房价\电话、vod、保密、
																		internet、允许记账、walkin、exp_s、共享  */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* 信用 */

	lastnumb	   int		default 0		not null,	/* account的number的总数 */
	lastinumb	int		default 0		not null,	/* account的inumber的总数 */

	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
	saccnt		char(10)		default ''	not null, 	/* 客房主账 */
	pcrec			char(10)		default ''	not null, 	/* 联房 */
	pcrec_pkg	char(10)		default ''	not null, 	/* Package Routing */
	resno			varchar(10)	default ''	not null, 	/* 预订编号 */
	crsno			varchar(20)	default ''	null, 		/* 国际网络预订编号 */

	resby			char(10)		default ''	not null,	/* 预订员信息 */
	restime		datetime						null,			
	ciby			char(10)		default ''	not null,	/* 登记员信息 */
	citime		datetime						null,
	coby			char(10)		default ''	not null,	/* 结账员信息 */
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	/* 退房员信息 */
	deptime		datetime						null,			
	cby			char(10)						not null,	/* 最新修改人信息 */
	changed		datetime						not null,	

	logmark     int    default 0 			not null
)
exec sp_primarykey master,accnt
create unique index  master on master(accnt)
create index  groupno on master(groupno,accnt)
create index  index3 on master (roomno)
create index  index4 on master (sta)
create index  arr    on master (arr)
;


if exists(select * from sysobjects where name = "master_till" and type="U")
	drop table master_till;
select * into master_till from master where 1=2;
exec sp_primarykey master_till,accnt
create unique index  master_till on master_till(accnt)
create index  groupno on master_till(groupno,accnt)
create index  index3 on master_till (roomno)
create index  index4 on master_till (sta)
create index  arr    on master_till (arr)
;


if exists(select * from sysobjects where name = "master_last" and type="U")
	drop table master_last;
select * into master_last from master where 1=2;
exec sp_primarykey master_last,accnt
create unique index  master_last on master_last(accnt)
create index  groupno on master_last(groupno,accnt)
create index  index3 on master_last (roomno)
create index  index4 on master_last (sta)
create index  arr    on master_last (arr)
;


if exists(select * from sysobjects where name = "hmaster" and type="U")
	drop table hmaster;
select * into hmaster from master where 1=2;
exec sp_primarykey hmaster,accnt
create unique index  hmaster on hmaster(accnt)
create index  groupno on hmaster(groupno,accnt)
create index  index3 on hmaster (roomno)
;


if exists(select * from sysobjects where name = "master_log" and type="U")
	drop table master_log;
select * into master_log from master where 1=2;
exec sp_primarykey master_log, accnt, logmark
create unique index master_log on master_log(accnt, logmark)
;
