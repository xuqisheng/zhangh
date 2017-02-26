//==========================================================================
//Table : sc_master
//
//			= fidelio business block 
//==========================================================================

//--------------------------------------------------------------------------
//		sc_master, sc_master_till, sc_master_last, sc_master_log, sc_hmaster
//		sc_master_del
//--------------------------------------------------------------------------

if exists(select * from sysobjects where name = "sc_master" and type="U")
	drop table sc_master;
create table sc_master
(
	accnt		   char(10)						not null,	-- 帐号:主键(其生成见说明书)  
	foact		   char(10)	default ''			not null,	-- block 状态：1=来源 2=当前位置  F=FO, S=SC 
	haccnt		char(7)		default '' 	not null,	-- 宾客档案号  
--	groupno		char(10)		default '' 	not null,	-- 所属团号  
	type		   char(5)		default ''	not null,	-- 房间类型(cf. typim,block,pickup)  
   otype       char(5)     default ''	not null,  	-- 更新前的房间类型  
--	up_type		char(5)     default ''	null,  		-- 从哪个房间类型升级  
--	up_reason	char(3)     default ''	not null,  	-- 升级原因  
	rmnum			int			default 0	not null,
--	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	-- 房号 
	oroomno     char(5)     default ''	not null,  	-- 更新前的房号 
	bdate		   datetime	   				not null,	-- 入住那天的营业日期=business date 
	sta			char(1)						not null,   -- 帐号状态(其说明见说明书) 
	osta        char(1)     default ''	not null,   -- 更新前的帐号状态 
--	ressta      char(1)     default ''	not null,   -- 结帐时保存的状态,用来撤消结帐并恢复到原状态 
--	exp_sta		char(1)		default '' 	null,			--  团体房的房标  										---
	sta_tm		char(1)		default '' 	not null,	-- 帐号状态(稽核用) 
--	rmpoststa	char(1)		default '' 	not null,	-- 控制字段:过房费时用 									---
--	rmposted	   char(1)		default "F"	not null,	-- 从入住日起是否过过房费 
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	-- 到店日期=arrival 
	dep			datetime	   				not null,	-- 离店日期=departure 
--   resdep      datetime    				null,       -- 结帐时保存的离开日期,用来撤消结帐 
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	-- 类别: F-fit, G-grp, M-meet, A-armst, C-House accounts
	src			char(3)		default '' 	not null,	-- 来源 
	market		char(3)		default '' 	not null,	-- 市场码 
	restype		char(3)		default '' 	not null,	-- 预订类别 
	channel		char(3)		default '' 	not null,	-- 渠道 

--	artag1		char(3)		default '' 	not null,	-- 渠道 
--	artag2		char(3)		default '' 	not null,	-- 渠道 
	
--	share		   char(1)		default '' 	not null,	-- 是否可以同住   
	gstno		   int			default 1 	not null,   -- 成人 
	children		int			default 0	not null,	-- 小孩 
--	rmreason	   char(1)		default ''	not null,	-- 换房理由 

	ratecode    char(10)    default '' 	not null,	-- 房价码  
	packages		varchar(50)		default ''	not null,	-- 包价  
--	fixrate	   char(1)		default 'F'	not null,	-- 固定房价 
--	rmrate		money			default 0	not null,	-- 房间报价 
--	qtrate		money			default 0	not null,	-- 协议房间报价 
	setrate		money			default 0	not null,	-- 与优惠及优惠理由一起决定实际房价 
--	rtreason	   char(3)		default ''	not null,	-- 房价优惠理由(cf.rtreason.dbf) 
--	discount	   money			default 0	not null,	-- 优惠额 
--	discount1	money			default 0	not null,	-- 优惠比例 
--	addbed	   money			default 0 	not null,	-- 加床数量  
--	addbed_rate	money			default 0 	not null,	-- 加床价 
--	crib	   	money			default 0 	not null,	-- 婴儿床数量 
--	crib_rate	money			default 0 	not null,	-- 婴儿床价格 

	paycode		char(6)		default ''	not null,	-- 结算方式 
	limit		   money			default 0 	not null,	-- 限额(催帐用) 
	credcode		varchar(20)	default ''	not null,	-- 信用卡号码 
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
--	applname    varchar(30)    			null,       -- 订房人/委托人 
--	applicant	varchar(60)	default ''	not null,	-- 单位/委托单位 
	araccnt		varchar(7)	default ''	not null,	-- AR帐号(与City ledger,travel agency结算用) 
--	phone    	varchar(16)    			null,       -- 联系电话等 
--	fax    		varchar(16)    			null,       -- fax 
--	email    	varchar(30)    			null,       -- email 

	wherefrom	char(6)		default ''	not null,	-- 何地来 
	whereto		char(6)		default ''	not null,	-- 何地去 
	purpose		char(3)		default ''	not null,	-- 事由 

	arrdate		datetime						null,			-- 到达信息 
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       -- 离开信息 
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	-- 附加信息: 1-永久账户  4-保密 5-保密房价 
                                                   -- 6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom 

	charge		money			default 0	not null,
	credit 		money			default 0	not null,
	accredit		money			default 0	not null,	-- 信用 

	lastnumb	   int			default 0	not null,	-- account的number的总数 
	lastinumb	int			default 0	not null,	-- account的inumber的总数 

	srqs		   varchar(30)	default ''	not null,	-- 特殊要求 
	amenities  	varchar(30)	default ''	not null,	-- 房间布置 
	master		char(10)		default ''	not null, 	-- 客房主账 
	saccnt		char(10)		default ''	not null, 	-- 共享主账 
	blkcode		char(10)		default ''	not null,	-- 
	pcrec			char(10)		default ''	not null, 	-- 联房 
	pcrec_pkg	char(10)		default ''	not null, 	-- 联房 gaoliang 
	resno			varchar(10)	default ''	not null, 	-- 预订编号 
	crsno			varchar(20)	default ''	null, 		-- 国际网络预订编号 
	ref			varchar(255)	default ''	null, 		-- comment 
	comsg			varchar(255)	default ''	null, 		-- c/o msg 
--	card			varchar(7)		default ''	not null,	-- 贵宾卡 
	saleid		varchar(10)		default ''	not null,	-- 销售员 

	cmscode		varchar(10)		default ''	not null,	-- 佣金码 
	cardcode		varchar(10)		default ''	not null,	-- 会员卡代码 
	cardno		varchar(20)		default ''	not null,	-- 会员卡号码 

-- sales 
	contact		char(10)		default ''		not null,	-- 联系人
	name			varchar(50)	default ''		null,			-- block name 
	name2			varchar(50)	default ''		null,
	blockcode	varchar(20)	default ''		not null,
	status		char(10)							not null,	
	btype			char(10)	default ''			not null,	-- business type 
	bscope		char(1)		default '0'		not null,	-- 业务范畴 0=blk+catering 1=blk 2=catering 
	potential	varchar(30)						null,
	saleid2		varchar(10)		default ''	not null,	-- 销售员
	peakrms		int								null,		-- 房数
	avrate		money								null,		-- 平均房价

	cutoff		datetime							null,
	follow		datetime							null,
	decision		datetime							null,
	rmlistdate	datetime							null,		-- room list date 
	currency		varchar(10)						null,		-- 货币
	tracecode	varchar(30)						null,
	triggers		varchar(30)						null,
	
	porterage	char(1)		default 'F'		not null,	-- 交通
	ptgrate		money 		default 0		not null,
	breakfast	char(1)		default 'F'		not null,	-- 早餐
	bfrate		money 		default 0		not null,
	bfdes			varchar(30)						null,


-- catering 
	c_status		char(10)	default ''		not null,	-- 宴会状态
	c_attendees	int			default 0		not null,	-- 人数
	c_guaranteed	char(3)	default 'F'		not null,	-- 保证 for c_attendees
	c_infoboard	varchar(100)					null,			-- 标牌
	c_follow		datetime							null,
	c_decision	datetime							null,
	c_function	varchar(40)						null,			-- 功能描述
	c_contract	varchar(20)						null,			-- 合约编号
	c_detailok	char(1)			default 'F'	not null,	-- 细节完成 ？
	c_distributed	char(1)		default 'F'	not null,	-- 信息发布了？
	c_saleid		varchar(10)		default ''	not null,	-- 销售员

	resby			char(10)		default ''	not null,	-- 预订员信息 
	restime		datetime						null,			
	defby			char(10)		default ''	not null,	-- 确认信息 
	deftime		datetime						null,			
	tfby			char(10)		default ''	not null,	-- to fo 信息 
	tftime		datetime						null,
	coby			char(10)		default ''	not null,	-- 结账员信息 
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	-- 退房员信息 
	deptime		datetime						null,			

	cby			char(10)						not null,	-- 最新修改人信息 
	changed		datetime						not null,	

-- 预留字段
	exp_m1		money							null,
	exp_m2		money							null,
	exp_m3		money							null,
	exp_m4		money							null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null,
	exp_dt3		datetime						null,
	exp_dt4		datetime						null,
	exp_s1		varchar(30)					null,
	exp_s2		varchar(30)					null,
	exp_s3		varchar(30)					null,
	exp_s4		varchar(30)					null,
	exp_s5		varchar(60)					null,
	exp_s6		varchar(100)				null,

	logmark     int    default 0 			not null
)
exec sp_primarykey sc_master,accnt
create unique index  sc_master on sc_master(accnt)
create index  sta on sc_master (sta, arr)
create index  arr on sc_master (arr, sta)
create index  haccnt on sc_master (haccnt, sta, arr)
create index  cusno on sc_master (cusno, sta, arr)
create index  agent on sc_master (agent, sta, arr)
create index  source on sc_master (source, sta, arr)
create index  resby on sc_master (resby)
create index  tfby on sc_master (tfby)
create index  contact on sc_master (contact,arr)
create index  saleid on sc_master (saleid,arr)
create index  blockcode on sc_master (blockcode)
;



if exists(select * from sysobjects where name = "sc_master_till" and type="U")
	drop table sc_master_till;
create table sc_master_till
(
	accnt		   char(10)						not null,	-- 帐号:主键(其生成见说明书)  
	foact		   char(10)	default ''			not null,	-- block 状态：1=来源 2=当前位置  F=FO, S=SC 
	haccnt		char(7)		default '' 	not null,	-- 宾客档案号  
--	groupno		char(10)		default '' 	not null,	-- 所属团号  
	type		   char(5)		default ''	not null,	-- 房间类型(cf. typim,block,pickup)  
   otype       char(5)     default ''	not null,  	-- 更新前的房间类型  
--	up_type		char(5)     default ''	null,  		-- 从哪个房间类型升级  
--	up_reason	char(3)     default ''	not null,  	-- 升级原因  
	rmnum			int			default 0	not null,
--	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	-- 房号 
	oroomno     char(5)     default ''	not null,  	-- 更新前的房号 
	bdate		   datetime	   				not null,	-- 入住那天的营业日期=business date 
	sta			char(1)						not null,   -- 帐号状态(其说明见说明书) 
	osta        char(1)     default ''	not null,   -- 更新前的帐号状态 
--	ressta      char(1)     default ''	not null,   -- 结帐时保存的状态,用来撤消结帐并恢复到原状态 
--	exp_sta		char(1)		default '' 	null,			--  团体房的房标  										---
	sta_tm		char(1)		default '' 	not null,	-- 帐号状态(稽核用) 
--	rmpoststa	char(1)		default '' 	not null,	-- 控制字段:过房费时用 									---
--	rmposted	   char(1)		default "F"	not null,	-- 从入住日起是否过过房费 
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	-- 到店日期=arrival 
	dep			datetime	   				not null,	-- 离店日期=departure 
--   resdep      datetime    				null,       -- 结帐时保存的离开日期,用来撤消结帐 
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	-- 类别: F-fit, G-grp, M-meet, A-armst, C-House accounts
	src			char(3)		default '' 	not null,	-- 来源 
	market		char(3)		default '' 	not null,	-- 市场码 
	restype		char(3)		default '' 	not null,	-- 预订类别 
	channel		char(3)		default '' 	not null,	-- 渠道 

--	artag1		char(3)		default '' 	not null,	-- 渠道 
--	artag2		char(3)		default '' 	not null,	-- 渠道 
	
--	share		   char(1)		default '' 	not null,	-- 是否可以同住   
	gstno		   int			default 1 	not null,   -- 成人 
	children		int			default 0	not null,	-- 小孩 
--	rmreason	   char(1)		default ''	not null,	-- 换房理由 

	ratecode    char(10)    default '' 	not null,	-- 房价码  
	packages		varchar(50)		default ''	not null,	-- 包价  
--	fixrate	   char(1)		default 'F'	not null,	-- 固定房价 
--	rmrate		money			default 0	not null,	-- 房间报价 
--	qtrate		money			default 0	not null,	-- 协议房间报价 
	setrate		money			default 0	not null,	-- 与优惠及优惠理由一起决定实际房价 
--	rtreason	   char(3)		default ''	not null,	-- 房价优惠理由(cf.rtreason.dbf) 
--	discount	   money			default 0	not null,	-- 优惠额 
--	discount1	money			default 0	not null,	-- 优惠比例 
--	addbed	   money			default 0 	not null,	-- 加床数量  
--	addbed_rate	money			default 0 	not null,	-- 加床价 
--	crib	   	money			default 0 	not null,	-- 婴儿床数量 
--	crib_rate	money			default 0 	not null,	-- 婴儿床价格 

	paycode		char(6)		default ''	not null,	-- 结算方式 
	limit		   money			default 0 	not null,	-- 限额(催帐用) 
	credcode		varchar(20)	default ''	not null,	-- 信用卡号码 
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
--	applname    varchar(30)    			null,       -- 订房人/委托人 
--	applicant	varchar(60)	default ''	not null,	-- 单位/委托单位 
	araccnt		varchar(7)	default ''	not null,	-- AR帐号(与City ledger,travel agency结算用) 
--	phone    	varchar(16)    			null,       -- 联系电话等 
--	fax    		varchar(16)    			null,       -- fax 
--	email    	varchar(30)    			null,       -- email 

	wherefrom	char(6)		default ''	not null,	-- 何地来 
	whereto		char(6)		default ''	not null,	-- 何地去 
	purpose		char(3)		default ''	not null,	-- 事由 

	arrdate		datetime						null,			-- 到达信息 
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       -- 离开信息 
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	-- 附加信息: 1-永久账户  4-保密 5-保密房价 
                                                   -- 6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom 

	charge		money			default 0	not null,
	credit 		money			default 0	not null,
	accredit		money			default 0	not null,	-- 信用 

	lastnumb	   int			default 0	not null,	-- account的number的总数 
	lastinumb	int			default 0	not null,	-- account的inumber的总数 

	srqs		   varchar(30)	default ''	not null,	-- 特殊要求 
	amenities  	varchar(30)	default ''	not null,	-- 房间布置 
	master		char(10)		default ''	not null, 	-- 客房主账 
	saccnt		char(10)		default ''	not null, 	-- 共享主账 
	blkcode		char(10)		default ''	not null,	-- 
	pcrec			char(10)		default ''	not null, 	-- 联房 
	pcrec_pkg	char(10)		default ''	not null, 	-- 联房 gaoliang 
	resno			varchar(10)	default ''	not null, 	-- 预订编号 
	crsno			varchar(20)	default ''	null, 		-- 国际网络预订编号 
	ref			varchar(255)	default ''	null, 		-- comment 
	comsg			varchar(255)	default ''	null, 		-- c/o msg 
--	card			varchar(7)		default ''	not null,	-- 贵宾卡 
	saleid		varchar(10)		default ''	not null,	-- 销售员 

	cmscode		varchar(10)		default ''	not null,	-- 佣金码 
	cardcode		varchar(10)		default ''	not null,	-- 会员卡代码 
	cardno		varchar(20)		default ''	not null,	-- 会员卡号码 

-- sales 
	contact		char(10)		default ''		not null,	-- 联系人
	name			varchar(50)	default ''		null,			-- block name 
	name2			varchar(50)	default ''		null,
	blockcode	varchar(20)	default ''		not null,
	status		char(10)							not null,	
	btype			char(10)	default ''			not null,	-- business type 
	bscope		char(1)		default '0'		not null,	-- 业务范畴 0=blk+catering 1=blk 2=catering 
	potential	varchar(30)						null,
	saleid2		varchar(10)		default ''	not null,	-- 销售员
	peakrms		int								null,		-- 房数
	avrate		money								null,		-- 平均房价

	cutoff		datetime							null,
	follow		datetime							null,
	decision		datetime							null,
	rmlistdate	datetime							null,		-- room list date 
	currency		varchar(10)						null,		-- 货币
	tracecode	varchar(30)						null,
	triggers		varchar(30)						null,
	
	porterage	char(1)		default 'F'		not null,	-- 交通
	ptgrate		money 		default 0		not null,
	breakfast	char(1)		default 'F'		not null,	-- 早餐
	bfrate		money 		default 0		not null,
	bfdes			varchar(30)						null,


-- catering 
	c_status		char(10)	default ''		not null,	-- 宴会状态
	c_attendees	int			default 0		not null,	-- 人数
	c_guaranteed	char(3)	default 'F'		not null,	-- 保证 for c_attendees
	c_infoboard	varchar(100)					null,			-- 标牌
	c_follow		datetime							null,
	c_decision	datetime							null,
	c_function	varchar(40)						null,			-- 功能描述
	c_contract	varchar(20)						null,			-- 合约编号
	c_detailok	char(1)			default 'F'	not null,	-- 细节完成 ？
	c_distributed	char(1)		default 'F'	not null,	-- 信息发布了？
	c_saleid		varchar(10)		default ''	not null,	-- 销售员

	resby			char(10)		default ''	not null,	-- 预订员信息 
	restime		datetime						null,			
	defby			char(10)		default ''	not null,	-- 确认信息 
	deftime		datetime						null,			
	tfby			char(10)		default ''	not null,	-- to fo 信息 
	tftime		datetime						null,
	coby			char(10)		default ''	not null,	-- 结账员信息 
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	-- 退房员信息 
	deptime		datetime						null,			

	cby			char(10)						not null,	-- 最新修改人信息 
	changed		datetime						not null,	

-- 预留字段
	exp_m1		money							null,
	exp_m2		money							null,
	exp_m3		money							null,
	exp_m4		money							null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null,
	exp_dt3		datetime						null,
	exp_dt4		datetime						null,
	exp_s1		varchar(30)					null,
	exp_s2		varchar(30)					null,
	exp_s3		varchar(30)					null,
	exp_s4		varchar(30)					null,
	exp_s5		varchar(60)					null,
	exp_s6		varchar(100)				null,

	logmark     int    default 0 			not null
);
exec sp_primarykey sc_master_till,accnt
create unique index  sc_master_till on sc_master_till(accnt)
;


if exists(select * from sysobjects where name = "sc_master_last" and type="U")
	drop table sc_master_last;
create table sc_master_last
(
	accnt		   char(10)						not null,	-- 帐号:主键(其生成见说明书)  
	foact		   char(10)	default ''			not null,	-- block 状态：1=来源 2=当前位置  F=FO, S=SC 
	haccnt		char(7)		default '' 	not null,	-- 宾客档案号  
--	groupno		char(10)		default '' 	not null,	-- 所属团号  
	type		   char(5)		default ''	not null,	-- 房间类型(cf. typim,block,pickup)  
   otype       char(5)     default ''	not null,  	-- 更新前的房间类型  
--	up_type		char(5)     default ''	null,  		-- 从哪个房间类型升级  
--	up_reason	char(3)     default ''	not null,  	-- 升级原因  
	rmnum			int			default 0	not null,
--	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	-- 房号 
	oroomno     char(5)     default ''	not null,  	-- 更新前的房号 
	bdate		   datetime	   				not null,	-- 入住那天的营业日期=business date 
	sta			char(1)						not null,   -- 帐号状态(其说明见说明书) 
	osta        char(1)     default ''	not null,   -- 更新前的帐号状态 
--	ressta      char(1)     default ''	not null,   -- 结帐时保存的状态,用来撤消结帐并恢复到原状态 
--	exp_sta		char(1)		default '' 	null,			--  团体房的房标  										---
	sta_tm		char(1)		default '' 	not null,	-- 帐号状态(稽核用) 
--	rmpoststa	char(1)		default '' 	not null,	-- 控制字段:过房费时用 									---
--	rmposted	   char(1)		default "F"	not null,	-- 从入住日起是否过过房费 
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	-- 到店日期=arrival 
	dep			datetime	   				not null,	-- 离店日期=departure 
--   resdep      datetime    				null,       -- 结帐时保存的离开日期,用来撤消结帐 
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	-- 类别: F-fit, G-grp, M-meet, A-armst, C-House accounts
	src			char(3)		default '' 	not null,	-- 来源 
	market		char(3)		default '' 	not null,	-- 市场码 
	restype		char(3)		default '' 	not null,	-- 预订类别 
	channel		char(3)		default '' 	not null,	-- 渠道 

--	artag1		char(3)		default '' 	not null,	-- 渠道 
--	artag2		char(3)		default '' 	not null,	-- 渠道 
	
--	share		   char(1)		default '' 	not null,	-- 是否可以同住   
	gstno		   int			default 1 	not null,   -- 成人 
	children		int			default 0	not null,	-- 小孩 
--	rmreason	   char(1)		default ''	not null,	-- 换房理由 

	ratecode    char(10)    default '' 	not null,	-- 房价码  
	packages		varchar(50)		default ''	not null,	-- 包价  
--	fixrate	   char(1)		default 'F'	not null,	-- 固定房价 
--	rmrate		money			default 0	not null,	-- 房间报价 
--	qtrate		money			default 0	not null,	-- 协议房间报价 
	setrate		money			default 0	not null,	-- 与优惠及优惠理由一起决定实际房价 
--	rtreason	   char(3)		default ''	not null,	-- 房价优惠理由(cf.rtreason.dbf) 
--	discount	   money			default 0	not null,	-- 优惠额 
--	discount1	money			default 0	not null,	-- 优惠比例 
--	addbed	   money			default 0 	not null,	-- 加床数量  
--	addbed_rate	money			default 0 	not null,	-- 加床价 
--	crib	   	money			default 0 	not null,	-- 婴儿床数量 
--	crib_rate	money			default 0 	not null,	-- 婴儿床价格 

	paycode		char(6)		default ''	not null,	-- 结算方式 
	limit		   money			default 0 	not null,	-- 限额(催帐用) 
	credcode		varchar(20)	default ''	not null,	-- 信用卡号码 
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
--	applname    varchar(30)    			null,       -- 订房人/委托人 
--	applicant	varchar(60)	default ''	not null,	-- 单位/委托单位 
	araccnt		varchar(7)	default ''	not null,	-- AR帐号(与City ledger,travel agency结算用) 
--	phone    	varchar(16)    			null,       -- 联系电话等 
--	fax    		varchar(16)    			null,       -- fax 
--	email    	varchar(30)    			null,       -- email 

	wherefrom	char(6)		default ''	not null,	-- 何地来 
	whereto		char(6)		default ''	not null,	-- 何地去 
	purpose		char(3)		default ''	not null,	-- 事由 

	arrdate		datetime						null,			-- 到达信息 
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       -- 离开信息 
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	-- 附加信息: 1-永久账户  4-保密 5-保密房价 
                                                   -- 6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom 

	charge		money			default 0	not null,
	credit 		money			default 0	not null,
	accredit		money			default 0	not null,	-- 信用 

	lastnumb	   int			default 0	not null,	-- account的number的总数 
	lastinumb	int			default 0	not null,	-- account的inumber的总数 

	srqs		   varchar(30)	default ''	not null,	-- 特殊要求 
	amenities  	varchar(30)	default ''	not null,	-- 房间布置 
	master		char(10)		default ''	not null, 	-- 客房主账 
	saccnt		char(10)		default ''	not null, 	-- 共享主账 
	blkcode		char(10)		default ''	not null,	-- 
	pcrec			char(10)		default ''	not null, 	-- 联房 
	pcrec_pkg	char(10)		default ''	not null, 	-- 联房 gaoliang 
	resno			varchar(10)	default ''	not null, 	-- 预订编号 
	crsno			varchar(20)	default ''	null, 		-- 国际网络预订编号 
	ref			varchar(255)	default ''	null, 		-- comment 
	comsg			varchar(255)	default ''	null, 		-- c/o msg 
--	card			varchar(7)		default ''	not null,	-- 贵宾卡 
	saleid		varchar(10)		default ''	not null,	-- 销售员 

	cmscode		varchar(10)		default ''	not null,	-- 佣金码 
	cardcode		varchar(10)		default ''	not null,	-- 会员卡代码 
	cardno		varchar(20)		default ''	not null,	-- 会员卡号码 

-- sales 
	contact		char(10)		default ''		not null,	-- 联系人
	name			varchar(50)	default ''		null,			-- block name 
	name2			varchar(50)	default ''		null,
	blockcode	varchar(20)	default ''		not null,
	status		char(10)							not null,	
	btype			char(10)	default ''			not null,	-- business type 
	bscope		char(1)		default '0'		not null,	-- 业务范畴 0=blk+catering 1=blk 2=catering 
	potential	varchar(30)						null,
	saleid2		varchar(10)		default ''	not null,	-- 销售员
	peakrms		int								null,		-- 房数
	avrate		money								null,		-- 平均房价

	cutoff		datetime							null,
	follow		datetime							null,
	decision		datetime							null,
	rmlistdate	datetime							null,		-- room list date 
	currency		varchar(10)						null,		-- 货币
	tracecode	varchar(30)						null,
	triggers		varchar(30)						null,
	
	porterage	char(1)		default 'F'		not null,	-- 交通
	ptgrate		money 		default 0		not null,
	breakfast	char(1)		default 'F'		not null,	-- 早餐
	bfrate		money 		default 0		not null,
	bfdes			varchar(30)						null,


-- catering 
	c_status		char(10)	default ''		not null,	-- 宴会状态
	c_attendees	int			default 0		not null,	-- 人数
	c_guaranteed	char(3)	default 'F'		not null,	-- 保证 for c_attendees
	c_infoboard	varchar(100)					null,			-- 标牌
	c_follow		datetime							null,
	c_decision	datetime							null,
	c_function	varchar(40)						null,			-- 功能描述
	c_contract	varchar(20)						null,			-- 合约编号
	c_detailok	char(1)			default 'F'	not null,	-- 细节完成 ？
	c_distributed	char(1)		default 'F'	not null,	-- 信息发布了？
	c_saleid		varchar(10)		default ''	not null,	-- 销售员

	resby			char(10)		default ''	not null,	-- 预订员信息 
	restime		datetime						null,			
	defby			char(10)		default ''	not null,	-- 确认信息 
	deftime		datetime						null,			
	tfby			char(10)		default ''	not null,	-- to fo 信息 
	tftime		datetime						null,
	coby			char(10)		default ''	not null,	-- 结账员信息 
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	-- 退房员信息 
	deptime		datetime						null,			

	cby			char(10)						not null,	-- 最新修改人信息 
	changed		datetime						not null,	

-- 预留字段
	exp_m1		money							null,
	exp_m2		money							null,
	exp_m3		money							null,
	exp_m4		money							null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null,
	exp_dt3		datetime						null,
	exp_dt4		datetime						null,
	exp_s1		varchar(30)					null,
	exp_s2		varchar(30)					null,
	exp_s3		varchar(30)					null,
	exp_s4		varchar(30)					null,
	exp_s5		varchar(60)					null,
	exp_s6		varchar(100)				null,

	logmark     int    default 0 			not null
);
exec sp_primarykey sc_master_last,accnt
create unique index  sc_master_last on sc_master_last(accnt)
;


if exists(select * from sysobjects where name = "sc_master_log" and type="U")
	drop table sc_master_log;
create table sc_master_log
(
	accnt		   char(10)						not null,	-- 帐号:主键(其生成见说明书)  
	foact		   char(10)	default ''			not null,	-- block 状态：1=来源 2=当前位置  F=FO, S=SC 
	haccnt		char(7)		default '' 	not null,	-- 宾客档案号  
--	groupno		char(10)		default '' 	not null,	-- 所属团号  
	type		   char(5)		default ''	not null,	-- 房间类型(cf. typim,block,pickup)  
   otype       char(5)     default ''	not null,  	-- 更新前的房间类型  
--	up_type		char(5)     default ''	null,  		-- 从哪个房间类型升级  
--	up_reason	char(3)     default ''	not null,  	-- 升级原因  
	rmnum			int			default 0	not null,
--	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	-- 房号 
	oroomno     char(5)     default ''	not null,  	-- 更新前的房号 
	bdate		   datetime	   				not null,	-- 入住那天的营业日期=business date 
	sta			char(1)						not null,   -- 帐号状态(其说明见说明书) 
	osta        char(1)     default ''	not null,   -- 更新前的帐号状态 
--	ressta      char(1)     default ''	not null,   -- 结帐时保存的状态,用来撤消结帐并恢复到原状态 
--	exp_sta		char(1)		default '' 	null,			--  团体房的房标  										---
	sta_tm		char(1)		default '' 	not null,	-- 帐号状态(稽核用) 
--	rmpoststa	char(1)		default '' 	not null,	-- 控制字段:过房费时用 									---
--	rmposted	   char(1)		default "F"	not null,	-- 从入住日起是否过过房费 
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	-- 到店日期=arrival 
	dep			datetime	   				not null,	-- 离店日期=departure 
--   resdep      datetime    				null,       -- 结帐时保存的离开日期,用来撤消结帐 
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	-- 类别: F-fit, G-grp, M-meet, A-armst, C-House accounts
	src			char(3)		default '' 	not null,	-- 来源 
	market		char(3)		default '' 	not null,	-- 市场码 
	restype		char(3)		default '' 	not null,	-- 预订类别 
	channel		char(3)		default '' 	not null,	-- 渠道 

--	artag1		char(3)		default '' 	not null,	-- 渠道 
--	artag2		char(3)		default '' 	not null,	-- 渠道 
	
--	share		   char(1)		default '' 	not null,	-- 是否可以同住   
	gstno		   int			default 1 	not null,   -- 成人 
	children		int			default 0	not null,	-- 小孩 
--	rmreason	   char(1)		default ''	not null,	-- 换房理由 

	ratecode    char(10)    default '' 	not null,	-- 房价码  
	packages		varchar(50)		default ''	not null,	-- 包价  
--	fixrate	   char(1)		default 'F'	not null,	-- 固定房价 
--	rmrate		money			default 0	not null,	-- 房间报价 
--	qtrate		money			default 0	not null,	-- 协议房间报价 
	setrate		money			default 0	not null,	-- 与优惠及优惠理由一起决定实际房价 
--	rtreason	   char(3)		default ''	not null,	-- 房价优惠理由(cf.rtreason.dbf) 
--	discount	   money			default 0	not null,	-- 优惠额 
--	discount1	money			default 0	not null,	-- 优惠比例 
--	addbed	   money			default 0 	not null,	-- 加床数量  
--	addbed_rate	money			default 0 	not null,	-- 加床价 
--	crib	   	money			default 0 	not null,	-- 婴儿床数量 
--	crib_rate	money			default 0 	not null,	-- 婴儿床价格 

	paycode		char(6)		default ''	not null,	-- 结算方式 
	limit		   money			default 0 	not null,	-- 限额(催帐用) 
	credcode		varchar(20)	default ''	not null,	-- 信用卡号码 
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
--	applname    varchar(30)    			null,       -- 订房人/委托人 
--	applicant	varchar(60)	default ''	not null,	-- 单位/委托单位 
	araccnt		varchar(7)	default ''	not null,	-- AR帐号(与City ledger,travel agency结算用) 
--	phone    	varchar(16)    			null,       -- 联系电话等 
--	fax    		varchar(16)    			null,       -- fax 
--	email    	varchar(30)    			null,       -- email 

	wherefrom	char(6)		default ''	not null,	-- 何地来 
	whereto		char(6)		default ''	not null,	-- 何地去 
	purpose		char(3)		default ''	not null,	-- 事由 

	arrdate		datetime						null,			-- 到达信息 
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       -- 离开信息 
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	-- 附加信息: 1-永久账户  4-保密 5-保密房价 
                                                   -- 6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom 

	charge		money			default 0	not null,
	credit 		money			default 0	not null,
	accredit		money			default 0	not null,	-- 信用 

	lastnumb	   int			default 0	not null,	-- account的number的总数 
	lastinumb	int			default 0	not null,	-- account的inumber的总数 

	srqs		   varchar(30)	default ''	not null,	-- 特殊要求 
	amenities  	varchar(30)	default ''	not null,	-- 房间布置 
	master		char(10)		default ''	not null, 	-- 客房主账 
	saccnt		char(10)		default ''	not null, 	-- 共享主账 
	blkcode		char(10)		default ''	not null,	-- 
	pcrec			char(10)		default ''	not null, 	-- 联房 
	pcrec_pkg	char(10)		default ''	not null, 	-- 联房 gaoliang 
	resno			varchar(10)	default ''	not null, 	-- 预订编号 
	crsno			varchar(20)	default ''	null, 		-- 国际网络预订编号 
	ref			varchar(255)	default ''	null, 		-- comment 
	comsg			varchar(255)	default ''	null, 		-- c/o msg 
--	card			varchar(7)		default ''	not null,	-- 贵宾卡 
	saleid		varchar(10)		default ''	not null,	-- 销售员 

	cmscode		varchar(10)		default ''	not null,	-- 佣金码 
	cardcode		varchar(10)		default ''	not null,	-- 会员卡代码 
	cardno		varchar(20)		default ''	not null,	-- 会员卡号码 

-- sales 
	contact		char(10)		default ''		not null,	-- 联系人
	name			varchar(50)	default ''		null,			-- block name 
	name2			varchar(50)	default ''		null,
	blockcode	varchar(20)	default ''		not null,
	status		char(10)							not null,	
	btype			char(10)	default ''			not null,	-- business type 
	bscope		char(1)		default '0'		not null,	-- 业务范畴 0=blk+catering 1=blk 2=catering 
	potential	varchar(30)						null,
	saleid2		varchar(10)		default ''	not null,	-- 销售员
	peakrms		int								null,		-- 房数
	avrate		money								null,		-- 平均房价

	cutoff		datetime							null,
	follow		datetime							null,
	decision		datetime							null,
	rmlistdate	datetime							null,		-- room list date 
	currency		varchar(10)						null,		-- 货币
	tracecode	varchar(30)						null,
	triggers		varchar(30)						null,
	
	porterage	char(1)		default 'F'		not null,	-- 交通
	ptgrate		money 		default 0		not null,
	breakfast	char(1)		default 'F'		not null,	-- 早餐
	bfrate		money 		default 0		not null,
	bfdes			varchar(30)						null,


-- catering 
	c_status		char(10)	default ''		not null,	-- 宴会状态
	c_attendees	int			default 0		not null,	-- 人数
	c_guaranteed	char(3)	default 'F'		not null,	-- 保证 for c_attendees
	c_infoboard	varchar(100)					null,			-- 标牌
	c_follow		datetime							null,
	c_decision	datetime							null,
	c_function	varchar(40)						null,			-- 功能描述
	c_contract	varchar(20)						null,			-- 合约编号
	c_detailok	char(1)			default 'F'	not null,	-- 细节完成 ？
	c_distributed	char(1)		default 'F'	not null,	-- 信息发布了？
	c_saleid		varchar(10)		default ''	not null,	-- 销售员

	resby			char(10)		default ''	not null,	-- 预订员信息 
	restime		datetime						null,			
	defby			char(10)		default ''	not null,	-- 确认信息 
	deftime		datetime						null,			
	tfby			char(10)		default ''	not null,	-- to fo 信息 
	tftime		datetime						null,
	coby			char(10)		default ''	not null,	-- 结账员信息 
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	-- 退房员信息 
	deptime		datetime						null,			

	cby			char(10)						not null,	-- 最新修改人信息 
	changed		datetime						not null,	

-- 预留字段
	exp_m1		money							null,
	exp_m2		money							null,
	exp_m3		money							null,
	exp_m4		money							null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null,
	exp_dt3		datetime						null,
	exp_dt4		datetime						null,
	exp_s1		varchar(30)					null,
	exp_s2		varchar(30)					null,
	exp_s3		varchar(30)					null,
	exp_s4		varchar(30)					null,
	exp_s5		varchar(60)					null,
	exp_s6		varchar(100)				null,

	logmark     int    default 0 			not null
);
exec sp_primarykey sc_master_log, accnt, logmark
create unique index sc_master_log on sc_master_log(accnt, logmark)
;


//--------------------------------------------------------------------------
//		sc_master_del  删除
//--------------------------------------------------------------------------
if exists(select * from sysobjects where name = "sc_master_del" and type="U")
	drop table sc_master_del;
create table sc_master_del
(
	accnt		   char(10)						not null,	-- 帐号:主键(其生成见说明书)  
	foact		   char(10)	default ''			not null,	-- block 状态：1=来源 2=当前位置  F=FO, S=SC 
	haccnt		char(7)		default '' 	not null,	-- 宾客档案号  
--	groupno		char(10)		default '' 	not null,	-- 所属团号  
	type		   char(5)		default ''	not null,	-- 房间类型(cf. typim,block,pickup)  
   otype       char(5)     default ''	not null,  	-- 更新前的房间类型  
--	up_type		char(5)     default ''	null,  		-- 从哪个房间类型升级  
--	up_reason	char(3)     default ''	not null,  	-- 升级原因  
	rmnum			int			default 0	not null,
--	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	-- 房号 
	oroomno     char(5)     default ''	not null,  	-- 更新前的房号 
	bdate		   datetime	   				not null,	-- 入住那天的营业日期=business date 
	sta			char(1)						not null,   -- 帐号状态(其说明见说明书) 
	osta        char(1)     default ''	not null,   -- 更新前的帐号状态 
--	ressta      char(1)     default ''	not null,   -- 结帐时保存的状态,用来撤消结帐并恢复到原状态 
--	exp_sta		char(1)		default '' 	null,			--  团体房的房标  										---
	sta_tm		char(1)		default '' 	not null,	-- 帐号状态(稽核用) 
--	rmpoststa	char(1)		default '' 	not null,	-- 控制字段:过房费时用 									---
--	rmposted	   char(1)		default "F"	not null,	-- 从入住日起是否过过房费 
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	-- 到店日期=arrival 
	dep			datetime	   				not null,	-- 离店日期=departure 
--   resdep      datetime    				null,       -- 结帐时保存的离开日期,用来撤消结帐 
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	-- 类别: F-fit, G-grp, M-meet, A-armst, C-House accounts
	src			char(3)		default '' 	not null,	-- 来源 
	market		char(3)		default '' 	not null,	-- 市场码 
	restype		char(3)		default '' 	not null,	-- 预订类别 
	channel		char(3)		default '' 	not null,	-- 渠道 

--	artag1		char(3)		default '' 	not null,	-- 渠道 
--	artag2		char(3)		default '' 	not null,	-- 渠道 
	
--	share		   char(1)		default '' 	not null,	-- 是否可以同住   
	gstno		   int			default 1 	not null,   -- 成人 
	children		int			default 0	not null,	-- 小孩 
--	rmreason	   char(1)		default ''	not null,	-- 换房理由 

	ratecode    char(10)    default '' 	not null,	-- 房价码  
	packages		varchar(50)		default ''	not null,	-- 包价  
--	fixrate	   char(1)		default 'F'	not null,	-- 固定房价 
--	rmrate		money			default 0	not null,	-- 房间报价 
--	qtrate		money			default 0	not null,	-- 协议房间报价 
	setrate		money			default 0	not null,	-- 与优惠及优惠理由一起决定实际房价 
--	rtreason	   char(3)		default ''	not null,	-- 房价优惠理由(cf.rtreason.dbf) 
--	discount	   money			default 0	not null,	-- 优惠额 
--	discount1	money			default 0	not null,	-- 优惠比例 
--	addbed	   money			default 0 	not null,	-- 加床数量  
--	addbed_rate	money			default 0 	not null,	-- 加床价 
--	crib	   	money			default 0 	not null,	-- 婴儿床数量 
--	crib_rate	money			default 0 	not null,	-- 婴儿床价格 

	paycode		char(6)		default ''	not null,	-- 结算方式 
	limit		   money			default 0 	not null,	-- 限额(催帐用) 
	credcode		varchar(20)	default ''	not null,	-- 信用卡号码 
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
--	applname    varchar(30)    			null,       -- 订房人/委托人 
--	applicant	varchar(60)	default ''	not null,	-- 单位/委托单位 
	araccnt		varchar(7)	default ''	not null,	-- AR帐号(与City ledger,travel agency结算用) 
--	phone    	varchar(16)    			null,       -- 联系电话等 
--	fax    		varchar(16)    			null,       -- fax 
--	email    	varchar(30)    			null,       -- email 

	wherefrom	char(6)		default ''	not null,	-- 何地来 
	whereto		char(6)		default ''	not null,	-- 何地去 
	purpose		char(3)		default ''	not null,	-- 事由 

	arrdate		datetime						null,			-- 到达信息 
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       -- 离开信息 
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	-- 附加信息: 1-永久账户  4-保密 5-保密房价 
                                                   -- 6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom 

	charge		money			default 0	not null,
	credit 		money			default 0	not null,
	accredit		money			default 0	not null,	-- 信用 

	lastnumb	   int			default 0	not null,	-- account的number的总数 
	lastinumb	int			default 0	not null,	-- account的inumber的总数 

	srqs		   varchar(30)	default ''	not null,	-- 特殊要求 
	amenities  	varchar(30)	default ''	not null,	-- 房间布置 
	master		char(10)		default ''	not null, 	-- 客房主账 
	saccnt		char(10)		default ''	not null, 	-- 共享主账 
	blkcode		char(10)		default ''	not null,	-- 
	pcrec			char(10)		default ''	not null, 	-- 联房 
	pcrec_pkg	char(10)		default ''	not null, 	-- 联房 gaoliang 
	resno			varchar(10)	default ''	not null, 	-- 预订编号 
	crsno			varchar(20)	default ''	null, 		-- 国际网络预订编号 
	ref			varchar(255)	default ''	null, 		-- comment 
	comsg			varchar(255)	default ''	null, 		-- c/o msg 
--	card			varchar(7)		default ''	not null,	-- 贵宾卡 
	saleid		varchar(10)		default ''	not null,	-- 销售员 

	cmscode		varchar(10)		default ''	not null,	-- 佣金码 
	cardcode		varchar(10)		default ''	not null,	-- 会员卡代码 
	cardno		varchar(20)		default ''	not null,	-- 会员卡号码 

-- sales 
	contact		char(10)		default ''		not null,	-- 联系人
	name			varchar(50)	default ''		null,			-- block name 
	name2			varchar(50)	default ''		null,
	blockcode	varchar(20)	default ''		not null,
	status		char(10)							not null,	
	btype			char(10)	default ''			not null,	-- business type 
	bscope		char(1)		default '0'		not null,	-- 业务范畴 0=blk+catering 1=blk 2=catering 
	potential	varchar(30)						null,
	saleid2		varchar(10)		default ''	not null,	-- 销售员
	peakrms		int								null,		-- 房数
	avrate		money								null,		-- 平均房价

	cutoff		datetime							null,
	follow		datetime							null,
	decision		datetime							null,
	rmlistdate	datetime							null,		-- room list date 
	currency		varchar(10)						null,		-- 货币
	tracecode	varchar(30)						null,
	triggers		varchar(30)						null,
	
	porterage	char(1)		default 'F'		not null,	-- 交通
	ptgrate		money 		default 0		not null,
	breakfast	char(1)		default 'F'		not null,	-- 早餐
	bfrate		money 		default 0		not null,
	bfdes			varchar(30)						null,


-- catering 
	c_status		char(10)	default ''		not null,	-- 宴会状态
	c_attendees	int			default 0		not null,	-- 人数
	c_guaranteed	char(3)	default 'F'		not null,	-- 保证 for c_attendees
	c_infoboard	varchar(100)					null,			-- 标牌
	c_follow		datetime							null,
	c_decision	datetime							null,
	c_function	varchar(40)						null,			-- 功能描述
	c_contract	varchar(20)						null,			-- 合约编号
	c_detailok	char(1)			default 'F'	not null,	-- 细节完成 ？
	c_distributed	char(1)		default 'F'	not null,	-- 信息发布了？
	c_saleid		varchar(10)		default ''	not null,	-- 销售员

	resby			char(10)		default ''	not null,	-- 预订员信息 
	restime		datetime						null,			
	defby			char(10)		default ''	not null,	-- 确认信息 
	deftime		datetime						null,			
	tfby			char(10)		default ''	not null,	-- to fo 信息 
	tftime		datetime						null,
	coby			char(10)		default ''	not null,	-- 结账员信息 
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	-- 退房员信息 
	deptime		datetime						null,			

	cby			char(10)						not null,	-- 最新修改人信息 
	changed		datetime						not null,	

-- 预留字段
	exp_m1		money							null,
	exp_m2		money							null,
	exp_m3		money							null,
	exp_m4		money							null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null,
	exp_dt3		datetime						null,
	exp_dt4		datetime						null,
	exp_s1		varchar(30)					null,
	exp_s2		varchar(30)					null,
	exp_s3		varchar(30)					null,
	exp_s4		varchar(30)					null,
	exp_s5		varchar(60)					null,
	exp_s6		varchar(100)				null,

	logmark     int    default 0 			not null
);
exec sp_primarykey sc_master_del,accnt
create unique index  sc_master_del on sc_master_del(accnt)
;


if exists(select * from sysobjects where name = "sc_hmaster" and type="U")
	drop table sc_hmaster;
create table sc_hmaster
(
	accnt		   char(10)						not null,	-- 帐号:主键(其生成见说明书)  
	foact		   char(10)	default ''			not null,	-- block 状态：1=来源 2=当前位置  F=FO, S=SC 
	haccnt		char(7)		default '' 	not null,	-- 宾客档案号  
--	groupno		char(10)		default '' 	not null,	-- 所属团号  
	type		   char(5)		default ''	not null,	-- 房间类型(cf. typim,block,pickup)  
   otype       char(5)     default ''	not null,  	-- 更新前的房间类型  
--	up_type		char(5)     default ''	null,  		-- 从哪个房间类型升级  
--	up_reason	char(3)     default ''	not null,  	-- 升级原因  
	rmnum			int			default 0	not null,
--	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	-- 房号 
	oroomno     char(5)     default ''	not null,  	-- 更新前的房号 
	bdate		   datetime	   				not null,	-- 入住那天的营业日期=business date 
	sta			char(1)						not null,   -- 帐号状态(其说明见说明书) 
	osta        char(1)     default ''	not null,   -- 更新前的帐号状态 
--	ressta      char(1)     default ''	not null,   -- 结帐时保存的状态,用来撤消结帐并恢复到原状态 
--	exp_sta		char(1)		default '' 	null,			--  团体房的房标  										---
	sta_tm		char(1)		default '' 	not null,	-- 帐号状态(稽核用) 
--	rmpoststa	char(1)		default '' 	not null,	-- 控制字段:过房费时用 									---
--	rmposted	   char(1)		default "F"	not null,	-- 从入住日起是否过过房费 
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	-- 到店日期=arrival 
	dep			datetime	   				not null,	-- 离店日期=departure 
--   resdep      datetime    				null,       -- 结帐时保存的离开日期,用来撤消结帐 
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	-- 类别: F-fit, G-grp, M-meet, A-armst, C-House accounts
	src			char(3)		default '' 	not null,	-- 来源 
	market		char(3)		default '' 	not null,	-- 市场码 
	restype		char(3)		default '' 	not null,	-- 预订类别 
	channel		char(3)		default '' 	not null,	-- 渠道 

--	artag1		char(3)		default '' 	not null,	-- 渠道 
--	artag2		char(3)		default '' 	not null,	-- 渠道 
	
--	share		   char(1)		default '' 	not null,	-- 是否可以同住   
	gstno		   int			default 1 	not null,   -- 成人 
	children		int			default 0	not null,	-- 小孩 
--	rmreason	   char(1)		default ''	not null,	-- 换房理由 

	ratecode    char(10)    default '' 	not null,	-- 房价码  
	packages		varchar(50)		default ''	not null,	-- 包价  
--	fixrate	   char(1)		default 'F'	not null,	-- 固定房价 
--	rmrate		money			default 0	not null,	-- 房间报价 
--	qtrate		money			default 0	not null,	-- 协议房间报价 
	setrate		money			default 0	not null,	-- 与优惠及优惠理由一起决定实际房价 
--	rtreason	   char(3)		default ''	not null,	-- 房价优惠理由(cf.rtreason.dbf) 
--	discount	   money			default 0	not null,	-- 优惠额 
--	discount1	money			default 0	not null,	-- 优惠比例 
--	addbed	   money			default 0 	not null,	-- 加床数量  
--	addbed_rate	money			default 0 	not null,	-- 加床价 
--	crib	   	money			default 0 	not null,	-- 婴儿床数量 
--	crib_rate	money			default 0 	not null,	-- 婴儿床价格 

	paycode		char(6)		default ''	not null,	-- 结算方式 
	limit		   money			default 0 	not null,	-- 限额(催帐用) 
	credcode		varchar(20)	default ''	not null,	-- 信用卡号码 
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
--	applname    varchar(30)    			null,       -- 订房人/委托人 
--	applicant	varchar(60)	default ''	not null,	-- 单位/委托单位 
	araccnt		varchar(7)	default ''	not null,	-- AR帐号(与City ledger,travel agency结算用) 
--	phone    	varchar(16)    			null,       -- 联系电话等 
--	fax    		varchar(16)    			null,       -- fax 
--	email    	varchar(30)    			null,       -- email 

	wherefrom	char(6)		default ''	not null,	-- 何地来 
	whereto		char(6)		default ''	not null,	-- 何地去 
	purpose		char(3)		default ''	not null,	-- 事由 

	arrdate		datetime						null,			-- 到达信息 
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       -- 离开信息 
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	-- 附加信息: 1-永久账户  4-保密 5-保密房价 
                                                   -- 6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom 

	charge		money			default 0	not null,
	credit 		money			default 0	not null,
	accredit		money			default 0	not null,	-- 信用 

	lastnumb	   int			default 0	not null,	-- account的number的总数 
	lastinumb	int			default 0	not null,	-- account的inumber的总数 

	srqs		   varchar(30)	default ''	not null,	-- 特殊要求 
	amenities  	varchar(30)	default ''	not null,	-- 房间布置 
	master		char(10)		default ''	not null, 	-- 客房主账 
	saccnt		char(10)		default ''	not null, 	-- 共享主账 
	blkcode		char(10)		default ''	not null,	-- 
	pcrec			char(10)		default ''	not null, 	-- 联房 
	pcrec_pkg	char(10)		default ''	not null, 	-- 联房 gaoliang 
	resno			varchar(10)	default ''	not null, 	-- 预订编号 
	crsno			varchar(20)	default ''	null, 		-- 国际网络预订编号 
	ref			varchar(255)	default ''	null, 		-- comment 
	comsg			varchar(255)	default ''	null, 		-- c/o msg 
--	card			varchar(7)		default ''	not null,	-- 贵宾卡 
	saleid		varchar(10)		default ''	not null,	-- 销售员 

	cmscode		varchar(10)		default ''	not null,	-- 佣金码 
	cardcode		varchar(10)		default ''	not null,	-- 会员卡代码 
	cardno		varchar(20)		default ''	not null,	-- 会员卡号码 

-- sales 
	contact		char(10)		default ''		not null,	-- 联系人
	name			varchar(50)	default ''		null,			-- block name 
	name2			varchar(50)	default ''		null,
	blockcode	varchar(20)	default ''		not null,
	status		char(10)							not null,	
	btype			char(10)	default ''			not null,	-- business type 
	bscope		char(1)		default '0'		not null,	-- 业务范畴 0=blk+catering 1=blk 2=catering 
	potential	varchar(30)						null,
	saleid2		varchar(10)		default ''	not null,	-- 销售员
	peakrms		int								null,		-- 房数
	avrate		money								null,		-- 平均房价

	cutoff		datetime							null,
	follow		datetime							null,
	decision		datetime							null,
	rmlistdate	datetime							null,		-- room list date 
	currency		varchar(10)						null,		-- 货币
	tracecode	varchar(30)						null,
	triggers		varchar(30)						null,
	
	porterage	char(1)		default 'F'		not null,	-- 交通
	ptgrate		money 		default 0		not null,
	breakfast	char(1)		default 'F'		not null,	-- 早餐
	bfrate		money 		default 0		not null,
	bfdes			varchar(30)						null,


-- catering 
	c_status		char(10)	default ''		not null,	-- 宴会状态
	c_attendees	int			default 0		not null,	-- 人数
	c_guaranteed	char(3)	default 'F'		not null,	-- 保证 for c_attendees
	c_infoboard	varchar(100)					null,			-- 标牌
	c_follow		datetime							null,
	c_decision	datetime							null,
	c_function	varchar(40)						null,			-- 功能描述
	c_contract	varchar(20)						null,			-- 合约编号
	c_detailok	char(1)			default 'F'	not null,	-- 细节完成 ？
	c_distributed	char(1)		default 'F'	not null,	-- 信息发布了？
	c_saleid		varchar(10)		default ''	not null,	-- 销售员

	resby			char(10)		default ''	not null,	-- 预订员信息 
	restime		datetime						null,			
	defby			char(10)		default ''	not null,	-- 确认信息 
	deftime		datetime						null,			
	tfby			char(10)		default ''	not null,	-- to fo 信息 
	tftime		datetime						null,
	coby			char(10)		default ''	not null,	-- 结账员信息 
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	-- 退房员信息 
	deptime		datetime						null,			

	cby			char(10)						not null,	-- 最新修改人信息 
	changed		datetime						not null,	

-- 预留字段
	exp_m1		money							null,
	exp_m2		money							null,
	exp_m3		money							null,
	exp_m4		money							null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null,
	exp_dt3		datetime						null,
	exp_dt4		datetime						null,
	exp_s1		varchar(30)					null,
	exp_s2		varchar(30)					null,
	exp_s3		varchar(30)					null,
	exp_s4		varchar(30)					null,
	exp_s5		varchar(60)					null,
	exp_s6		varchar(100)				null,

	logmark     int    default 0 			not null
);
exec sp_primarykey sc_hmaster,accnt
create unique index  sc_hmaster on sc_hmaster(accnt)
create index  sta on sc_hmaster (sta, arr)
create index  arr on sc_hmaster (arr, sta)
create index  haccnt on sc_hmaster (haccnt, sta, arr)
create index  cusno on sc_hmaster (cusno, sta, arr)
create index  agent on sc_hmaster (agent, sta, arr)
create index  source on sc_hmaster (source, sta, arr)
create index  resby on sc_hmaster (resby)
create index  tfby on sc_hmaster (tfby)
create index  contact on sc_hmaster (contact,arr)
create index  saleid on sc_hmaster (saleid,arr)
create index  blockcode on sc_hmaster (blockcode)
;

