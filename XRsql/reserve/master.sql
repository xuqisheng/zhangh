//==========================================================================
//Table : master
//
//			销售员，贵宾卡 ?
//==========================================================================

//--------------------------------------------------------------------------
//		master, master_till, master_last, master_log
//		master_middle, master_del, hmaster
//		master_remark
//--------------------------------------------------------------------------

if exists(select * from sysobjects where name = "master" and type="U")
	drop table master;
create table master
(
	accnt		   char(10)						not null,	/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)		default '' 	not null,	/* 宾客档案号  */
	groupno		char(10)		default '' 	not null,	/* 所属团号  */
	type		   char(5)		default ''	not null,	/* 房间类型(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* 更新前的房间类型  */
	up_type		char(5)     default ''	null,  		/* 从哪个房间类型升级  */
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

	artag1		char(3)		default '' 	not null,	/* 渠道 */
	artag2		char(3)		default '' 	not null,	/* 渠道 */
	
	share		   char(1)		default '' 	not null,	/* 是否可以同住   */
	gstno		   int			default 1 	not null,   /* 成人 */
	children		int			default 0	not null,	/* 小孩 */
	rmreason	   char(1)		default ''	not null,	/* 换房理由 */

	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	packages		varchar(50)		default ''	not null,	/* 包价  */
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

	paycode		char(6)		default ''	not null,	/* 结算方式 */
	limit		   money			default 0 	not null,	/* 限额(催帐用) */
	credcode		varchar(20)	default ''	not null,	/* 信用卡号码 */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* 订房人/委托人 */
	applicant	varchar(60)	default ''	not null,	/* 单位/委托单位 */
	araccnt		varchar(7)	default ''	not null,	/* AR帐号(与City ledger,travel agency结算用) */
	phone    	varchar(16)    			null,       /* 联系电话等 */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* 何地来 */
	whereto		char(6)		default ''	not null,	/* 何地去 */
	purpose		char(3)		default ''	not null,	/* 事由 */

	arrdate		datetime						null,			/* 到达信息 */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* 离开信息 */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* 附加信息: 1-永久账户 2-楼号  4-保密 5-保密房价 
                                                   6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* 信用 */

	lastnumb	   int		default 0		not null,	/* account的number的总数 */
	lastinumb	int		default 0		not null,	/* account的inumber的总数 */

	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
	master		char(10)		default ''	not null, 	/* 客房主账 */
	saccnt		char(10)		default ''	not null, 	/* 共享主账 */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* 联房 */
	pcrec_pkg	char(10)		default ''	not null, 	/* 联房 gaoliang */
	resno			varchar(10)	default ''	not null, 	/* 预订编号 */
	crsno			varchar(20)	default ''	null, 		/* 国际网络预订编号 */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* 贵宾卡 */
	saleid		varchar(10)		default ''	not null,	/* 销售员 */

	cmscode		varchar(10)		default ''	not null,	/* 佣金码 */
	cardcode		varchar(10)		default ''	not null,	/* 会员卡代码 */
	cardno		varchar(20)		default ''	not null,	/* 会员卡号码 */

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

-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,					-- cutoff date 
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- 团体主单 - 对应团体成员公共 profile 
	exp_s2		varchar(10)		null,					-- 预定联系人 guest.haccnt
	exp_s3		varchar(10)		null,					-- 中央预订号码
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

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
create table master_till
(
	accnt		   char(10)						not null,	/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)		default '' 	not null,	/* 宾客档案号  */
	groupno		char(10)		default '' 	not null,	/* 所属团号  */
	type		   char(5)		default ''	not null,	/* 房间类型(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* 更新前的房间类型  */
	up_type		char(5)     default ''	null,  		/* 从哪个房间类型升级  */
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

	artag1		char(3)		default '' 	not null,	/* 渠道 */
	artag2		char(3)		default '' 	not null,	/* 渠道 */
	
	share		   char(1)		default '' 	not null,	/* 是否可以同住   */
	gstno		   int			default 1 	not null,   /* 成人 */
	children		int			default 0	not null,	/* 小孩 */
	rmreason	   char(1)		default ''	not null,	/* 换房理由 */

	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	packages		varchar(50)		default ''	not null,	/* 包价  */
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

	paycode		char(6)		default ''	not null,	/* 结算方式 */
	limit		   money			default 0 	not null,	/* 限额(催帐用) */
	credcode		varchar(20)	default ''	not null,	/* 信用卡号码 */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* 订房人/委托人 */
	applicant	varchar(60)	default ''	not null,	/* 单位/委托单位 */
	araccnt		varchar(7)	default ''	not null,	/* AR帐号(与City ledger,travel agency结算用) */
	phone    	varchar(16)    			null,       /* 联系电话等 */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* 何地来 */
	whereto		char(6)		default ''	not null,	/* 何地去 */
	purpose		char(3)		default ''	not null,	/* 事由 */

	arrdate		datetime						null,			/* 到达信息 */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* 离开信息 */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* 附加信息: 1-永久账户  4-保密 5-保密房价 
                                                   6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* 信用 */

	lastnumb	   int		default 0		not null,	/* account的number的总数 */
	lastinumb	int		default 0		not null,	/* account的inumber的总数 */

	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
	master		char(10)		default ''	not null, 	/* 客房主账 */
	saccnt		char(10)		default ''	not null, 	/* 共享主账 */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* 联房 */
	pcrec_pkg	char(10)		default ''	not null, 	/* 联房 gaoliang */
	resno			varchar(10)	default ''	not null, 	/* 预订编号 */
	crsno			varchar(20)	default ''	null, 		/* 国际网络预订编号 */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* 贵宾卡 */
	saleid		varchar(10)		default ''	not null,	/* 销售员 */

	cmscode		varchar(10)		default ''	not null,	/* 佣金码 */
	cardcode		varchar(10)		default ''	not null,	/* 会员卡代码 */
	cardno		varchar(20)		default ''	not null,	/* 会员卡号码 */

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

-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- 团体主单 - 对应团体成员公共 profile 
	exp_s2		varchar(10)		null,					-- 预定联系人 guest.haccnt
	exp_s3		varchar(10)		null,					-- 中央预订号码
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

	logmark     int    default 0 			not null
);
exec sp_primarykey master_till,accnt
create unique index  master_till on master_till(accnt)
;


if exists(select * from sysobjects where name = "master_last" and type="U")
	drop table master_last;
create table master_last
(
	accnt		   char(10)						not null,	/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)		default '' 	not null,	/* 宾客档案号  */
	groupno		char(10)		default '' 	not null,	/* 所属团号  */
	type		   char(5)		default ''	not null,	/* 房间类型(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* 更新前的房间类型  */
	up_type		char(5)     default ''	null,  		/* 从哪个房间类型升级  */
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

	artag1		char(3)		default '' 	not null,	/* 渠道 */
	artag2		char(3)		default '' 	not null,	/* 渠道 */
	
	share		   char(1)		default '' 	not null,	/* 是否可以同住   */
	gstno		   int			default 1 	not null,   /* 成人 */
	children		int			default 0	not null,	/* 小孩 */
	rmreason	   char(1)		default ''	not null,	/* 换房理由 */

	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	packages		varchar(50)		default ''	not null,	/* 包价  */
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

	paycode		char(6)		default ''	not null,	/* 结算方式 */
	limit		   money			default 0 	not null,	/* 限额(催帐用) */
	credcode		varchar(20)	default ''	not null,	/* 信用卡号码 */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* 订房人/委托人 */
	applicant	varchar(60)	default ''	not null,	/* 单位/委托单位 */
	araccnt		varchar(7)	default ''	not null,	/* AR帐号(与City ledger,travel agency结算用) */
	phone    	varchar(16)    			null,       /* 联系电话等 */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* 何地来 */
	whereto		char(6)		default ''	not null,	/* 何地去 */
	purpose		char(3)		default ''	not null,	/* 事由 */

	arrdate		datetime						null,			/* 到达信息 */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* 离开信息 */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* 附加信息: 1-永久账户  4-保密 5-保密房价 
                                                   6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* 信用 */

	lastnumb	   int		default 0		not null,	/* account的number的总数 */
	lastinumb	int		default 0		not null,	/* account的inumber的总数 */

	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
	master		char(10)		default ''	not null, 	/* 客房主账 */
	saccnt		char(10)		default ''	not null, 	/* 共享主账 */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* 联房 */
	pcrec_pkg	char(10)		default ''	not null, 	/* 联房 gaoliang */
	resno			varchar(10)	default ''	not null, 	/* 预订编号 */
	crsno			varchar(20)	default ''	null, 		/* 国际网络预订编号 */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* 贵宾卡 */
	saleid		varchar(10)		default ''	not null,	/* 销售员 */

	cmscode		varchar(10)		default ''	not null,	/* 佣金码 */
	cardcode		varchar(10)		default ''	not null,	/* 会员卡代码 */
	cardno		varchar(20)		default ''	not null,	/* 会员卡号码 */

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

-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- 团体主单 - 对应团体成员公共 profile 
	exp_s2		varchar(10)		null,					-- 预定联系人 guest.haccnt
	exp_s3		varchar(10)		null,					-- 中央预订号码
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

	logmark     int    default 0 			not null
);
exec sp_primarykey master_last,accnt
create unique index  master_last on master_last(accnt)
;


if exists(select * from sysobjects where name = "master_log" and type="U")
	drop table master_log;
create table master_log
(
	accnt		   char(10)						not null,	/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)		default '' 	not null,	/* 宾客档案号  */
	groupno		char(10)		default '' 	not null,	/* 所属团号  */
	type		   char(5)		default ''	not null,	/* 房间类型(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* 更新前的房间类型  */
	up_type		char(5)     default ''	null,  		/* 从哪个房间类型升级  */
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

	artag1		char(3)		default '' 	not null,	/* 渠道 */
	artag2		char(3)		default '' 	not null,	/* 渠道 */
	
	share		   char(1)		default '' 	not null,	/* 是否可以同住   */
	gstno		   int			default 1 	not null,   /* 成人 */
	children		int			default 0	not null,	/* 小孩 */
	rmreason	   char(1)		default ''	not null,	/* 换房理由 */

	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	packages		varchar(50)		default ''	not null,	/* 包价  */
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

	paycode		char(6)		default ''	not null,	/* 结算方式 */
	limit		   money			default 0 	not null,	/* 限额(催帐用) */
	credcode		varchar(20)	default ''	not null,	/* 信用卡号码 */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* 订房人/委托人 */
	applicant	varchar(60)	default ''	not null,	/* 单位/委托单位 */
	araccnt		varchar(7)	default ''	not null,	/* AR帐号(与City ledger,travel agency结算用) */
	phone    	varchar(16)    			null,       /* 联系电话等 */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* 何地来 */
	whereto		char(6)		default ''	not null,	/* 何地去 */
	purpose		char(3)		default ''	not null,	/* 事由 */

	arrdate		datetime						null,			/* 到达信息 */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* 离开信息 */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* 附加信息: 1-永久账户  4-保密 5-保密房价 
                                                   6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* 信用 */

	lastnumb	   int		default 0		not null,	/* account的number的总数 */
	lastinumb	int		default 0		not null,	/* account的inumber的总数 */

	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
	master		char(10)		default ''	not null, 	/* 客房主账 */
	saccnt		char(10)		default ''	not null, 	/* 共享主账 */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* 联房 */
	pcrec_pkg	char(10)		default ''	not null, 	/* 联房 gaoliang */
	resno			varchar(10)	default ''	not null, 	/* 预订编号 */
	crsno			varchar(20)	default ''	null, 		/* 国际网络预订编号 */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* 贵宾卡 */
	saleid		varchar(10)		default ''	not null,	/* 销售员 */

	cmscode		varchar(10)		default ''	not null,	/* 佣金码 */
	cardcode		varchar(10)		default ''	not null,	/* 会员卡代码 */
	cardno		varchar(20)		default ''	not null,	/* 会员卡号码 */

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

-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- 团体主单 - 对应团体成员公共 profile 
	exp_s2		varchar(10)		null,					-- 预定联系人 guest.haccnt
	exp_s3		varchar(10)		null,					-- 中央预订号码
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

	logmark     int    default 0 			not null
);
exec sp_primarykey master_log, accnt, logmark
create unique index master_log on master_log(accnt, logmark)
;


//--------------------------------------------------------------------------
//		master_middle  团体成员模版等等
//--------------------------------------------------------------------------
if exists(select * from sysobjects where name = "master_middle" and type="U")
	drop table master_middle;
create table master_middle
(
	accnt		   char(10)						not null,	/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)		default '' 	not null,	/* 宾客档案号  */
	groupno		char(10)		default '' 	not null,	/* 所属团号  */
	type		   char(5)		default ''	not null,	/* 房间类型(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* 更新前的房间类型  */
	up_type		char(5)     default ''	null,  		/* 从哪个房间类型升级  */
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

	artag1		char(3)		default '' 	not null,	/* 渠道 */
	artag2		char(3)		default '' 	not null,	/* 渠道 */
	
	share		   char(1)		default '' 	not null,	/* 是否可以同住   */
	gstno		   int			default 1 	not null,   /* 成人 */
	children		int			default 0	not null,	/* 小孩 */
	rmreason	   char(1)		default ''	not null,	/* 换房理由 */

	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	packages		varchar(50)		default ''	not null,	/* 包价  */
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

	paycode		char(6)		default ''	not null,	/* 结算方式 */
	limit		   money			default 0 	not null,	/* 限额(催帐用) */
	credcode		varchar(20)	default ''	not null,	/* 信用卡号码 */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* 订房人/委托人 */
	applicant	varchar(60)	default ''	not null,	/* 单位/委托单位 */
	araccnt		varchar(7)	default ''	not null,	/* AR帐号(与City ledger,travel agency结算用) */
	phone    	varchar(16)    			null,       /* 联系电话等 */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* 何地来 */
	whereto		char(6)		default ''	not null,	/* 何地去 */
	purpose		char(3)		default ''	not null,	/* 事由 */

	arrdate		datetime						null,			/* 到达信息 */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* 离开信息 */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* 附加信息: 1-永久账户  4-保密 5-保密房价 
                                                   6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* 信用 */

	lastnumb	   int		default 0		not null,	/* account的number的总数 */
	lastinumb	int		default 0		not null,	/* account的inumber的总数 */

	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
	master		char(10)		default ''	not null, 	/* 客房主账 */
	saccnt		char(10)		default ''	not null, 	/* 共享主账 */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* 联房 */
	pcrec_pkg	char(10)		default ''	not null, 	/* 联房 gaoliang */
	resno			varchar(10)	default ''	not null, 	/* 预订编号 */
	crsno			varchar(20)	default ''	null, 		/* 国际网络预订编号 */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* 贵宾卡 */
	saleid		varchar(10)		default ''	not null,	/* 销售员 */

	cmscode		varchar(10)		default ''	not null,	/* 佣金码 */
	cardcode		varchar(10)		default ''	not null,	/* 会员卡代码 */
	cardno		varchar(20)		default ''	not null,	/* 会员卡号码 */

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

-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- 团体主单 - 对应团体成员公共 profile 
	exp_s2		varchar(10)		null,					-- 预定联系人 guest.haccnt
	exp_s3		varchar(10)		null,					-- 中央预订号码
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

	logmark     int    default 0 			not null
);
exec sp_primarykey master_middle,groupno,accnt
create unique index  master_middle on master_middle(groupno,accnt)
;


//--------------------------------------------------------------------------
//		master_del  删除
//--------------------------------------------------------------------------
if exists(select * from sysobjects where name = "master_del" and type="U")
	drop table master_del;
create table master_del
(
	accnt		   char(10)						not null,	/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)		default '' 	not null,	/* 宾客档案号  */
	groupno		char(10)		default '' 	not null,	/* 所属团号  */
	type		   char(5)		default ''	not null,	/* 房间类型(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* 更新前的房间类型  */
	up_type		char(5)     default ''	null,  		/* 从哪个房间类型升级  */
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

	artag1		char(3)		default '' 	not null,	/* 渠道 */
	artag2		char(3)		default '' 	not null,	/* 渠道 */
	
	share		   char(1)		default '' 	not null,	/* 是否可以同住   */
	gstno		   int			default 1 	not null,   /* 成人 */
	children		int			default 0	not null,	/* 小孩 */
	rmreason	   char(1)		default ''	not null,	/* 换房理由 */

	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	packages		varchar(50)		default ''	not null,	/* 包价  */
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

	paycode		char(6)		default ''	not null,	/* 结算方式 */
	limit		   money			default 0 	not null,	/* 限额(催帐用) */
	credcode		varchar(20)	default ''	not null,	/* 信用卡号码 */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* 订房人/委托人 */
	applicant	varchar(60)	default ''	not null,	/* 单位/委托单位 */
	araccnt		varchar(7)	default ''	not null,	/* AR帐号(与City ledger,travel agency结算用) */
	phone    	varchar(16)    			null,       /* 联系电话等 */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* 何地来 */
	whereto		char(6)		default ''	not null,	/* 何地去 */
	purpose		char(3)		default ''	not null,	/* 事由 */

	arrdate		datetime						null,			/* 到达信息 */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* 离开信息 */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* 附加信息: 1-永久账户  4-保密 5-保密房价 
                                                   6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* 信用 */

	lastnumb	   int		default 0		not null,	/* account的number的总数 */
	lastinumb	int		default 0		not null,	/* account的inumber的总数 */

	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
	master		char(10)		default ''	not null, 	/* 客房主账 */
	saccnt		char(10)		default ''	not null, 	/* 共享主账 */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* 联房 */
	pcrec_pkg	char(10)		default ''	not null, 	/* 联房 gaoliang */
	resno			varchar(10)	default ''	not null, 	/* 预订编号 */
	crsno			varchar(20)	default ''	null, 		/* 国际网络预订编号 */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* 贵宾卡 */
	saleid		varchar(10)		default ''	not null,	/* 销售员 */

	cmscode		varchar(10)		default ''	not null,	/* 佣金码 */
	cardcode		varchar(10)		default ''	not null,	/* 会员卡代码 */
	cardno		varchar(20)		default ''	not null,	/* 会员卡号码 */

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

-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- 团体主单 - 对应团体成员公共 profile 
	exp_s2		varchar(10)		null,					-- 预定联系人 guest.haccnt
	exp_s3		varchar(10)		null,					-- 中央预订号码
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

	logmark     int    default 0 			not null
);
exec sp_primarykey master_del,accnt
create unique index  master_del on master_del(accnt)
;


if exists(select * from sysobjects where name = "hmaster" and type="U")
	drop table hmaster;
create table hmaster
(
	accnt		   char(10)						not null,	/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)		default '' 	not null,	/* 宾客档案号  */
	groupno		char(10)		default '' 	not null,	/* 所属团号  */
	type		   char(5)		default ''	not null,	/* 房间类型(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* 更新前的房间类型  */
	up_type		char(5)     default ''	null,  		/* 从哪个房间类型升级  */
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

	artag1		char(3)		default '' 	not null,	/* 渠道 */
	artag2		char(3)		default '' 	not null,	/* 渠道 */
	
	share		   char(1)		default '' 	not null,	/* 是否可以同住   */
	gstno		   int			default 1 	not null,   /* 成人 */
	children		int			default 0	not null,	/* 小孩 */
	rmreason	   char(1)		default ''	not null,	/* 换房理由 */

	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	packages		varchar(50)		default ''	not null,	/* 包价  */
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

	paycode		char(6)		default ''	not null,	/* 结算方式 */
	limit		   money			default 0 	not null,	/* 限额(催帐用) */
	credcode		varchar(20)	default ''	not null,	/* 信用卡号码 */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* 订房人/委托人 */
	applicant	varchar(60)	default ''	not null,	/* 单位/委托单位 */
	araccnt		varchar(7)	default ''	not null,	/* AR帐号(与City ledger,travel agency结算用) */
	phone    	varchar(16)    			null,       /* 联系电话等 */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* 何地来 */
	whereto		char(6)		default ''	not null,	/* 何地去 */
	purpose		char(3)		default ''	not null,	/* 事由 */

	arrdate		datetime						null,			/* 到达信息 */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* 离开信息 */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* 附加信息: 1-永久账户  4-保密 5-保密房价 
                                                   6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* 信用 */

	lastnumb	   int		default 0		not null,	/* account的number的总数 */
	lastinumb	int		default 0		not null,	/* account的inumber的总数 */

	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
	master		char(10)		default ''	not null, 	/* 客房主账 */
	saccnt		char(10)		default ''	not null, 	/* 共享主账 */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* 联房 */
	pcrec_pkg	char(10)		default ''	not null, 	/* 联房 gaoliang */
	resno			varchar(10)	default ''	not null, 	/* 预订编号 */
	crsno			varchar(20)	default ''	null, 		/* 国际网络预订编号 */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* 贵宾卡 */
	saleid		varchar(10)		default ''	not null,	/* 销售员 */

	cmscode		varchar(10)		default ''	not null,	/* 佣金码 */
	cardcode		varchar(10)		default ''	not null,	/* 会员卡代码 */
	cardno		varchar(20)		default ''	not null,	/* 会员卡号码 */

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

-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- 团体主单 - 对应团体成员公共 profile 
	exp_s2		varchar(10)		null,					-- 预定联系人 guest.haccnt
	exp_s3		varchar(10)		null,					-- 中央预订号码
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

-- 因为删除 hguest 增加的部分字段  
	name		   varchar(50)	 						not null,	 	// 姓名: 本名 
	fname       varchar(30)		default ''		not null, 		// 英文名 
	lname			varchar(30)		default '' 		not null,		// 英文姓 
	name2		   varchar(50)		default '' 		not null,		// 扩充名字 
	name3		   varchar(50)		default '' 		not null,		// 扩充名字 
	name4		   varchar(255)	default '' 		not null,		// 扩充名字 
	class1		varchar(3)		default '0'		not null, 		// 附加类别	0=表示没有定义；
	class2		varchar(3)		default '0'		not null,
	class3		varchar(3)		default '0'		not null,
	class4		varchar(3)		default '0'		not null,
	vip			char(3)			default '0'		not null,  		// vip 
	sex			char(1)			default '1'		not null,      // 性别:M,F 
	birth       datetime								null,         	// 生日
	nation		varchar(3)		default ''		not null,	   // 国籍 
	country		char(3)			default ''		not null,	   // 国家 
	state			char(3)			default ''		not null,
	town			varchar(40)		default ''		not null,		// 城市
	city  		varchar(6)		default ''		not null,      // 籍贯 城市 
	street	   varchar(60)		default ''		not null,		// 住址 
   idcls       varchar(3)     default ''		not null,     	// 最新证件类别 
	ident		   varchar(20)	   default ''		not null,     	// 最新证件号码 
	pextra		varchar(255)	null,									// 可能记录的其他额外内容 

	logmark     int    			default 0 		not null
);
exec sp_primarykey hmaster,accnt
create unique index  hmaster on hmaster(accnt)
create index  groupno on hmaster(groupno,accnt)
create index  index3 on hmaster (roomno)
create index  index4 on hmaster (haccnt)
create index  index5 on hmaster (cusno)
create index  index6 on hmaster (agent)
create index  index7 on hmaster (source)
create index  master on hmaster (master)
create index  pcrec on hmaster (pcrec)
create index  exp_s2 on hmaster (exp_s2,dep)
create index  bdate on hmaster (bdate,class,sta,market)
create index  arr on hmaster (arr,class,sta)
;


// ------------------------------------------------------------------------------
//	master_remark : 大备注
// ------------------------------------------------------------------------------
//if exists(select * from sysobjects where name = "master_remark")
//   drop table master_remark;
//create table master_remark
//(
//	accnt			char(10)						not null,
//	remark		text		default ''		null
//)
//exec sp_primarykey master_remark,accnt
//create unique index index1 on master_remark(accnt)
//;


//update master set extra=rtrim(extra)+'000000000000000' ; 
//update master_till set extra=rtrim(extra)+'000000000000000' ; 
//update master_last set extra=rtrim(extra)+'000000000000000' ; 
//update master_log set extra=rtrim(extra)+'000000000000000' ; 
//update master_del set extra=rtrim(extra)+'000000000000000' ; 
//update master_middle set extra=rtrim(extra)+'000000000000000' ; 
//update hmaster set extra=rtrim(extra)+'000000000000000' ; 
//