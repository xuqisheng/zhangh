exec sp_rename ar_master, ar_master_old;
exec sp_rename ar_master_last, ar_master_last_old;
exec sp_rename ar_master_log, ar_master_log_old;
exec sp_rename ar_master_till, ar_master_till_old;
exec sp_rename har_master, har_master_old;

if exists(select * from sysobjects where name = "ar_master" and type="U")
	drop table ar_master;
create table ar_master
(
	accnt			char(10)			not null,						/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)			default '' 	not null,		/* 宾客档案号  */
	bdate			datetime			not null,						/* 入住那天的营业日期=business date */
	sta			char(1)			not null,						/* 帐号状态(其说明见说明书) */
	osta			char(1)			default ''	not null,		/* 更新前的帐号状态 */
	ressta		char(1)			default ''	not null,		/* 结帐时保存的状态,用来撤消结帐并恢复到原状态 */
	sta_tm		char(1)			default '' 	not null,		/* 帐号状态(稽核用) */
	arr			datetime			not null,						/* 到店日期=arrival */
	dep			datetime			not null,						/* 离店日期=departure */
	resdep		datetime			null,								/* 结帐时保存的离开日期,用来撤消结帐 */
	oarr			datetime			null,
	odep			datetime			null,

	rmposted		char(1)			default 'F' 	not null,	/* 从入住日起是否过过房费, 与master.rmposted相同
																				以前的楼号改到extra的第二位 */
	class			char(1)			default '' 	not null,		/* 类别 */
	rmpoststa	char(1)			default '' 	not null,		/* 控制字段:过房费时用 */									---
	artag1		char(5)			default '' 	not null,		/* 类别 */
	artag2		char(5)			default '' 	not null,		/* 等级 */
	address1	   varchar(60)		default ''		not null,	/* 住址 */
	address2	   varchar(60)		default ''		not null,	/* 住址 */
	address3	   varchar(60)		default ''		not null,	/* 住址 */
	address4	   varchar(60)		default ''		not null,	/* 住址 */

	paycode		char(6)			default ''	not null,		/* 结算方式 */
	cycle			char(5)			default '' 	not null,		/* 结帐周期代码 */
	limit			money				default 0 	not null,		/* 限额(催帐用) */
	credcode		varchar(20)		default ''	not null,		/* 信用卡号码 */
	credman		varchar(20)		null,
	credunit		varchar(40)		null,
	applname		varchar(30)		null,								/* 订房人/委托人 */
	applicant	varchar(60)		default ''	not null,		/* 单位/委托单位 */
	phone			varchar(16) 	null,								/* 联系电话等 */
	fax			varchar(16) 	null,								/* fax */
	email			varchar(30)		null,								/* email */

	extra			char(30)			default ''	not null,		/* 附加信息: 1-永久账户 2-楼号 3-AR Status 4-保密 5-保密房价 
																				6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money				default 0		not null,
	credit 		money				default 0		not null,
	charge0		money				default 0		not null,
	credit0 		money				default 0		not null,
	accredit		money				default 0		not null,	/* 信用 */
	disputed		money				default 0		not null,	/* 争议金额 */
	invoice		money				default 0 not null,			/* 已开发票的金额 */

	lastnumb		integer			default 0		not null,	/* account的number的总数 */
	lastinumb	integer			default 0		not null,	/* account的inumber的总数 */

	srqs			varchar(30)		default ''	not null,		/* 特殊要求 */
	master		char(10)			default ''	not null, 		/* 主账 */
	pcrec			char(10)			default ''	not null, 		/* 联房 */
	pcrec_pkg	char(10)			default ''	not null, 		/* 联房 */
	ref			varchar(255)	default ''	null, 			/* comment */
	saleid		varchar(10)		default ''	not null,		/* 销售员 */

	resby			char(10)			default ''	not null,		/* 预订员信息 */
	restime		datetime			null,			
	depby			char(10)			default ''	not null,		/* 退房员信息 */
	deptime		datetime			null,			
	cby			char(10)			not null,						/* 最新修改人信息 */
	changed		datetime			not null,
-- 
	chargeby			char(10)			default ''	not null,	/* 最近一次消费信息 */
	chargetime		datetime			null,
	creditby			char(10)			default ''	not null,	/* 最近一次付款信息 */
	credittime		datetime			null,
	invoiceby		char(10)			default ''	not null,	/* 最近一次结算开票信息 */
	invoicetime		datetime			null,
	statementby		char(10)			default ''	not null,	/* 最近一次对账单信息 */
	statementtime	datetime			null,
	reminderby		char(10)			default ''	not null,	/* 最近一次催账单信息 */
	remindertime	datetime			null,
	remindertext	varchar(30)		default ''	not null,
-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,

	logmark		integer			default 0 			not null
)
exec sp_primarykey ar_master,accnt
create unique index  ar_master on ar_master(accnt)
;
//insert ar_master
//	select accnt, haccnt, bdate, sta, osta, ressta, sta_tm, arr, dep, resdep, oarr, odep,
//	hall = 'A', class, tag0, artag1, artag2, address1='', address2='', address3='', address4='', paycode, cycle = '', limit,
//	credcode, credman, credunit, applname, applicant, phone, fax, email, extra,
//	charge, credit, charge0 = 0, credit0 = 0, accredit, disputed = 0, invoice = 0,
//	lastnumb, lastinumb, srqs, master, pcrec, pcrec_pkg, ref, saleid,
//	resby, restime, depby, deptime, cby, changed,
//	chargeby = '', chargetime = null, creditby = '', credittime = null, invoiceby = '', invoicetime = null, statementby = '', statementtime = null,
//	exp_m1, exp_m2, exp_dt1, exp_dt2, exp_s1, exp_s2, exp_s3, logmark
//	from master where class = 'A';

if exists(select * from sysobjects where name = "har_master" and type="U")
	drop table har_master;
create table har_master
(
	accnt			char(10)			not null,						/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)			default '' 	not null,		/* 宾客档案号  */
	bdate			datetime			not null,						/* 入住那天的营业日期=business date */
	sta			char(1)			not null,						/* 帐号状态(其说明见说明书) */
	osta			char(1)			default ''	not null,		/* 更新前的帐号状态 */
	ressta		char(1)			default ''	not null,		/* 结帐时保存的状态,用来撤消结帐并恢复到原状态 */
	sta_tm		char(1)			default '' 	not null,		/* 帐号状态(稽核用) */
	arr			datetime			not null,						/* 到店日期=arrival */
	dep			datetime			not null,						/* 离店日期=departure */
	resdep		datetime			null,								/* 结帐时保存的离开日期,用来撤消结帐 */
	oarr			datetime			null,
	odep			datetime			null,

	rmposted		char(1)			default 'F' 	not null,	/* 从入住日起是否过过房费, 与master.rmposted相同
																				以前的楼号改到extra的第二位 */
	class			char(1)			default '' 	not null,		/* 类别 */
	rmpoststa	char(1)			default '' 	not null,		/* 控制字段:过房费时用 */									---
	artag1		char(5)			default '' 	not null,		/* 类别 */
	artag2		char(5)			default '' 	not null,		/* 等级 */
	address1	   varchar(60)		default ''		not null,	/* 住址 */
	address2	   varchar(60)		default ''		not null,	/* 住址 */
	address3	   varchar(60)		default ''		not null,	/* 住址 */
	address4	   varchar(60)		default ''		not null,	/* 住址 */

	paycode		char(6)			default ''	not null,		/* 结算方式 */
	cycle			char(5)			default '' 	not null,		/* 结帐周期代码 */
	limit			money				default 0 	not null,		/* 限额(催帐用) */
	credcode		varchar(20)		default ''	not null,		/* 信用卡号码 */
	credman		varchar(20)		null,
	credunit		varchar(40)		null,
	applname		varchar(30)		null,								/* 订房人/委托人 */
	applicant	varchar(60)		default ''	not null,		/* 单位/委托单位 */
	phone			varchar(16) 	null,								/* 联系电话等 */
	fax			varchar(16) 	null,								/* fax */
	email			varchar(30)		null,								/* email */

	extra			char(30)			default ''	not null,		/* 附加信息: 1-永久账户 2-楼号 3-AR Status 4-保密 5-保密房价 
																				6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money				default 0		not null,
	credit 		money				default 0		not null,
	charge0		money				default 0		not null,
	credit0 		money				default 0		not null,
	accredit		money				default 0		not null,	/* 信用 */
	disputed		money				default 0		not null,	/* 争议金额 */
	invoice		money				default 0 not null,			/* 已开发票的金额 */

	lastnumb		integer			default 0		not null,	/* account的number的总数 */
	lastinumb	integer			default 0		not null,	/* account的inumber的总数 */

	srqs			varchar(30)		default ''	not null,		/* 特殊要求 */
	master		char(10)			default ''	not null, 		/* 主账 */
	pcrec			char(10)			default ''	not null, 		/* 联房 */
	pcrec_pkg	char(10)			default ''	not null, 		/* 联房 */
	ref			varchar(255)	default ''	null, 			/* comment */
	saleid		varchar(10)		default ''	not null,		/* 销售员 */

	resby			char(10)			default ''	not null,		/* 预订员信息 */
	restime		datetime			null,			
	depby			char(10)			default ''	not null,		/* 退房员信息 */
	deptime		datetime			null,			
	cby			char(10)			not null,						/* 最新修改人信息 */
	changed		datetime			not null,
-- 
	chargeby			char(10)			default ''	not null,	/* 最近一次消费信息 */
	chargetime		datetime			null,
	creditby			char(10)			default ''	not null,	/* 最近一次付款信息 */
	credittime		datetime			null,
	invoiceby		char(10)			default ''	not null,	/* 最近一次结算开票信息 */
	invoicetime		datetime			null,
	statementby		char(10)			default ''	not null,	/* 最近一次对账单信息 */
	statementtime	datetime			null,
	reminderby		char(10)			default ''	not null,	/* 最近一次催账单信息 */
	remindertime	datetime			null,
	remindertext	varchar(30)		default ''	not null,
-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,

	logmark		integer			default 0 			not null
)
exec sp_primarykey har_master,accnt
create unique index  har_master on har_master(accnt)
;

if exists(select * from sysobjects where name = "ar_master_till" and type="U")
	drop table ar_master_till;
create table ar_master_till
(
	accnt			char(10)			not null,						/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)			default '' 	not null,		/* 宾客档案号  */
	bdate			datetime			not null,						/* 入住那天的营业日期=business date */
	sta			char(1)			not null,						/* 帐号状态(其说明见说明书) */
	osta			char(1)			default ''	not null,		/* 更新前的帐号状态 */
	ressta		char(1)			default ''	not null,		/* 结帐时保存的状态,用来撤消结帐并恢复到原状态 */
	sta_tm		char(1)			default '' 	not null,		/* 帐号状态(稽核用) */
	arr			datetime			not null,						/* 到店日期=arrival */
	dep			datetime			not null,						/* 离店日期=departure */
	resdep		datetime			null,								/* 结帐时保存的离开日期,用来撤消结帐 */
	oarr			datetime			null,
	odep			datetime			null,

	rmposted		char(1)			default 'F' 	not null,	/* 从入住日起是否过过房费, 与master.rmposted相同
																				以前的楼号改到extra的第二位 */
	class			char(1)			default '' 	not null,		/* 类别 */
	rmpoststa	char(1)			default '' 	not null,		/* 控制字段:过房费时用 */									---
	artag1		char(5)			default '' 	not null,		/* 类别 */
	artag2		char(5)			default '' 	not null,		/* 等级 */
	address1	   varchar(60)		default ''		not null,	/* 住址 */
	address2	   varchar(60)		default ''		not null,	/* 住址 */
	address3	   varchar(60)		default ''		not null,	/* 住址 */
	address4	   varchar(60)		default ''		not null,	/* 住址 */

	paycode		char(6)			default ''	not null,		/* 结算方式 */
	cycle			char(5)			default '' 	not null,		/* 结帐周期代码 */
	limit			money				default 0 	not null,		/* 限额(催帐用) */
	credcode		varchar(20)		default ''	not null,		/* 信用卡号码 */
	credman		varchar(20)		null,
	credunit		varchar(40)		null,
	applname		varchar(30)		null,								/* 订房人/委托人 */
	applicant	varchar(60)		default ''	not null,		/* 单位/委托单位 */
	phone			varchar(16) 	null,								/* 联系电话等 */
	fax			varchar(16) 	null,								/* fax */
	email			varchar(30)		null,								/* email */

	extra			char(30)			default ''	not null,		/* 附加信息: 1-永久账户 2-楼号 3-AR Status 4-保密 5-保密房价 
																				6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money				default 0		not null,
	credit 		money				default 0		not null,
	charge0		money				default 0		not null,
	credit0 		money				default 0		not null,
	accredit		money				default 0		not null,	/* 信用 */
	disputed		money				default 0		not null,	/* 争议金额 */
	invoice		money				default 0 not null,			/* 已开发票的金额 */

	lastnumb		integer			default 0		not null,	/* account的number的总数 */
	lastinumb	integer			default 0		not null,	/* account的inumber的总数 */

	srqs			varchar(30)		default ''	not null,		/* 特殊要求 */
	master		char(10)			default ''	not null, 		/* 主账 */
	pcrec			char(10)			default ''	not null, 		/* 联房 */
	pcrec_pkg	char(10)			default ''	not null, 		/* 联房 */
	ref			varchar(255)	default ''	null, 			/* comment */
	saleid		varchar(10)		default ''	not null,		/* 销售员 */

	resby			char(10)			default ''	not null,		/* 预订员信息 */
	restime		datetime			null,			
	depby			char(10)			default ''	not null,		/* 退房员信息 */
	deptime		datetime			null,			
	cby			char(10)			not null,						/* 最新修改人信息 */
	changed		datetime			not null,
-- 
	chargeby			char(10)			default ''	not null,	/* 最近一次消费信息 */
	chargetime		datetime			null,
	creditby			char(10)			default ''	not null,	/* 最近一次付款信息 */
	credittime		datetime			null,
	invoiceby		char(10)			default ''	not null,	/* 最近一次结算开票信息 */
	invoicetime		datetime			null,
	statementby		char(10)			default ''	not null,	/* 最近一次对账单信息 */
	statementtime	datetime			null,
	reminderby		char(10)			default ''	not null,	/* 最近一次催账单信息 */
	remindertime	datetime			null,
	remindertext	varchar(30)		default ''	not null,
-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,

	logmark		integer			default 0 			not null
)
exec sp_primarykey ar_master_till,accnt
create unique index  ar_master_till on ar_master_till(accnt)
;

if exists(select * from sysobjects where name = "ar_master_last" and type="U")
	drop table ar_master_last;
create table ar_master_last
(
	accnt			char(10)			not null,						/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)			default '' 	not null,		/* 宾客档案号  */
	bdate			datetime			not null,						/* 入住那天的营业日期=business date */
	sta			char(1)			not null,						/* 帐号状态(其说明见说明书) */
	osta			char(1)			default ''	not null,		/* 更新前的帐号状态 */
	ressta		char(1)			default ''	not null,		/* 结帐时保存的状态,用来撤消结帐并恢复到原状态 */
	sta_tm		char(1)			default '' 	not null,		/* 帐号状态(稽核用) */
	arr			datetime			not null,						/* 到店日期=arrival */
	dep			datetime			not null,						/* 离店日期=departure */
	resdep		datetime			null,								/* 结帐时保存的离开日期,用来撤消结帐 */
	oarr			datetime			null,
	odep			datetime			null,

	rmposted		char(1)			default 'F' 	not null,	/* 从入住日起是否过过房费, 与master.rmposted相同
																				以前的楼号改到extra的第二位 */
	class			char(1)			default '' 	not null,		/* 类别 */
	rmpoststa	char(1)			default '' 	not null,		/* 控制字段:过房费时用 */									---
	artag1		char(5)			default '' 	not null,		/* 类别 */
	artag2		char(5)			default '' 	not null,		/* 等级 */
	address1	   varchar(60)		default ''		not null,	/* 住址 */
	address2	   varchar(60)		default ''		not null,	/* 住址 */
	address3	   varchar(60)		default ''		not null,	/* 住址 */
	address4	   varchar(60)		default ''		not null,	/* 住址 */

	paycode		char(6)			default ''	not null,		/* 结算方式 */
	cycle			char(5)			default '' 	not null,		/* 结帐周期代码 */
	limit			money				default 0 	not null,		/* 限额(催帐用) */
	credcode		varchar(20)		default ''	not null,		/* 信用卡号码 */
	credman		varchar(20)		null,
	credunit		varchar(40)		null,
	applname		varchar(30)		null,								/* 订房人/委托人 */
	applicant	varchar(60)		default ''	not null,		/* 单位/委托单位 */
	phone			varchar(16) 	null,								/* 联系电话等 */
	fax			varchar(16) 	null,								/* fax */
	email			varchar(30)		null,								/* email */

	extra			char(30)			default ''	not null,		/* 附加信息: 1-永久账户 2-楼号 3-AR Status 4-保密 5-保密房价 
																				6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money				default 0		not null,
	credit 		money				default 0		not null,
	charge0		money				default 0		not null,
	credit0 		money				default 0		not null,
	accredit		money				default 0		not null,	/* 信用 */
	disputed		money				default 0		not null,	/* 争议金额 */
	invoice		money				default 0 not null,			/* 已开发票的金额 */

	lastnumb		integer			default 0		not null,	/* account的number的总数 */
	lastinumb	integer			default 0		not null,	/* account的inumber的总数 */

	srqs			varchar(30)		default ''	not null,		/* 特殊要求 */
	master		char(10)			default ''	not null, 		/* 主账 */
	pcrec			char(10)			default ''	not null, 		/* 联房 */
	pcrec_pkg	char(10)			default ''	not null, 		/* 联房 */
	ref			varchar(255)	default ''	null, 			/* comment */
	saleid		varchar(10)		default ''	not null,		/* 销售员 */

	resby			char(10)			default ''	not null,		/* 预订员信息 */
	restime		datetime			null,			
	depby			char(10)			default ''	not null,		/* 退房员信息 */
	deptime		datetime			null,			
	cby			char(10)			not null,						/* 最新修改人信息 */
	changed		datetime			not null,
-- 
	chargeby			char(10)			default ''	not null,	/* 最近一次消费信息 */
	chargetime		datetime			null,
	creditby			char(10)			default ''	not null,	/* 最近一次付款信息 */
	credittime		datetime			null,
	invoiceby		char(10)			default ''	not null,	/* 最近一次结算开票信息 */
	invoicetime		datetime			null,
	statementby		char(10)			default ''	not null,	/* 最近一次对账单信息 */
	statementtime	datetime			null,
	reminderby		char(10)			default ''	not null,	/* 最近一次催账单信息 */
	remindertime	datetime			null,
	remindertext	varchar(30)		default ''	not null,
-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,

	logmark		integer			default 0 			not null
)
exec sp_primarykey ar_master_last,accnt
create unique index  ar_master_last on ar_master_last(accnt)
;

if exists(select * from sysobjects where name = "ar_master_log" and type="U")
	drop table ar_master_log;
create table ar_master_log
(
	accnt			char(10)			not null,						/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)			default '' 	not null,		/* 宾客档案号  */
	bdate			datetime			not null,						/* 入住那天的营业日期=business date */
	sta			char(1)			not null,						/* 帐号状态(其说明见说明书) */
	osta			char(1)			default ''	not null,		/* 更新前的帐号状态 */
	ressta		char(1)			default ''	not null,		/* 结帐时保存的状态,用来撤消结帐并恢复到原状态 */
	sta_tm		char(1)			default '' 	not null,		/* 帐号状态(稽核用) */
	arr			datetime			not null,						/* 到店日期=arrival */
	dep			datetime			not null,						/* 离店日期=departure */
	resdep		datetime			null,								/* 结帐时保存的离开日期,用来撤消结帐 */
	oarr			datetime			null,
	odep			datetime			null,

	rmposted		char(1)			default 'F' 	not null,	/* 从入住日起是否过过房费, 与master.rmposted相同
																				以前的楼号改到extra的第二位 */
	class			char(1)			default '' 	not null,		/* 类别 */
	rmpoststa	char(1)			default '' 	not null,		/* 控制字段:过房费时用 */									---
	artag1		char(5)			default '' 	not null,		/* 类别 */
	artag2		char(5)			default '' 	not null,		/* 等级 */
	address1	   varchar(60)		default ''		not null,	/* 住址 */
	address2	   varchar(60)		default ''		not null,	/* 住址 */
	address3	   varchar(60)		default ''		not null,	/* 住址 */
	address4	   varchar(60)		default ''		not null,	/* 住址 */

	paycode		char(6)			default ''	not null,		/* 结算方式 */
	cycle			char(5)			default '' 	not null,		/* 结帐周期代码 */
	limit			money				default 0 	not null,		/* 限额(催帐用) */
	credcode		varchar(20)		default ''	not null,		/* 信用卡号码 */
	credman		varchar(20)		null,
	credunit		varchar(40)		null,
	applname		varchar(30)		null,								/* 订房人/委托人 */
	applicant	varchar(60)		default ''	not null,		/* 单位/委托单位 */
	phone			varchar(16) 	null,								/* 联系电话等 */
	fax			varchar(16) 	null,								/* fax */
	email			varchar(30)		null,								/* email */

	extra			char(30)			default ''	not null,		/* 附加信息: 1-永久账户 2-楼号 3-AR Status 4-保密 5-保密房价 
																				6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money				default 0		not null,
	credit 		money				default 0		not null,
	charge0		money				default 0		not null,
	credit0 		money				default 0		not null,
	accredit		money				default 0		not null,	/* 信用 */
	disputed		money				default 0		not null,	/* 争议金额 */
	invoice		money				default 0 not null,			/* 已开发票的金额 */

	lastnumb		integer			default 0		not null,	/* account的number的总数 */
	lastinumb	integer			default 0		not null,	/* account的inumber的总数 */

	srqs			varchar(30)		default ''	not null,		/* 特殊要求 */
	master		char(10)			default ''	not null, 		/* 主账 */
	pcrec			char(10)			default ''	not null, 		/* 联房 */
	pcrec_pkg	char(10)			default ''	not null, 		/* 联房 */
	ref			varchar(255)	default ''	null, 			/* comment */
	saleid		varchar(10)		default ''	not null,		/* 销售员 */

	resby			char(10)			default ''	not null,		/* 预订员信息 */
	restime		datetime			null,			
	depby			char(10)			default ''	not null,		/* 退房员信息 */
	deptime		datetime			null,			
	cby			char(10)			not null,						/* 最新修改人信息 */
	changed		datetime			not null,
-- 
	chargeby			char(10)			default ''	not null,	/* 最近一次消费信息 */
	chargetime		datetime			null,
	creditby			char(10)			default ''	not null,	/* 最近一次付款信息 */
	credittime		datetime			null,
	invoiceby		char(10)			default ''	not null,	/* 最近一次结算开票信息 */
	invoicetime		datetime			null,
	statementby		char(10)			default ''	not null,	/* 最近一次对账单信息 */
	statementtime	datetime			null,
	reminderby		char(10)			default ''	not null,	/* 最近一次催账单信息 */
	remindertime	datetime			null,
	remindertext	varchar(30)		default ''	not null,
-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,

	logmark		integer			default 0 			not null
)
exec sp_primarykey ar_master_log,accnt,logmark
create unique index  ar_master_log on ar_master_log(accnt,logmark)
;

if exists(select * from sysobjects where name = "ar_master_del" and type="U")
	drop table ar_master_del;
create table ar_master_del
(
	accnt			char(10)			not null,						/* 帐号:主键(其生成见说明书)  */
	haccnt		char(7)			default '' 	not null,		/* 宾客档案号  */
	bdate			datetime			not null,						/* 入住那天的营业日期=business date */
	sta			char(1)			not null,						/* 帐号状态(其说明见说明书) */
	osta			char(1)			default ''	not null,		/* 更新前的帐号状态 */
	ressta		char(1)			default ''	not null,		/* 结帐时保存的状态,用来撤消结帐并恢复到原状态 */
	sta_tm		char(1)			default '' 	not null,		/* 帐号状态(稽核用) */
	arr			datetime			not null,						/* 到店日期=arrival */
	dep			datetime			not null,						/* 离店日期=departure */
	resdep		datetime			null,								/* 结帐时保存的离开日期,用来撤消结帐 */
	oarr			datetime			null,
	odep			datetime			null,

	rmposted		char(1)			default 'F' 	not null,	/* 从入住日起是否过过房费, 与master.rmposted相同
																				以前的楼号改到extra的第二位 */
	class			char(1)			default '' 	not null,		/* 类别 */
	rmpoststa	char(1)			default '' 	not null,		/* 控制字段:过房费时用 */									---
	artag1		char(5)			default '' 	not null,		/* 类别 */
	artag2		char(5)			default '' 	not null,		/* 等级 */
	address1	   varchar(60)		default ''		not null,	/* 住址 */
	address2	   varchar(60)		default ''		not null,	/* 住址 */
	address3	   varchar(60)		default ''		not null,	/* 住址 */
	address4	   varchar(60)		default ''		not null,	/* 住址 */

	paycode		char(6)			default ''	not null,		/* 结算方式 */
	cycle			char(5)			default '' 	not null,		/* 结帐周期代码 */
	limit			money				default 0 	not null,		/* 限额(催帐用) */
	credcode		varchar(20)		default ''	not null,		/* 信用卡号码 */
	credman		varchar(20)		null,
	credunit		varchar(40)		null,
	applname		varchar(30)		null,								/* 订房人/委托人 */
	applicant	varchar(60)		default ''	not null,		/* 单位/委托单位 */
	phone			varchar(16) 	null,								/* 联系电话等 */
	fax			varchar(16) 	null,								/* fax */
	email			varchar(30)		null,								/* email */

	extra			char(30)			default ''	not null,		/* 附加信息: 1-永久账户 2-楼号 3-AR Status 4-保密 5-保密房价 
																				6-电话 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money				default 0		not null,
	credit 		money				default 0		not null,
	charge0		money				default 0		not null,
	credit0 		money				default 0		not null,
	accredit		money				default 0		not null,	/* 信用 */
	disputed		money				default 0		not null,	/* 争议金额 */
	invoice		money				default 0 not null,			/* 已开发票的金额 */

	lastnumb		integer			default 0		not null,	/* account的number的总数 */
	lastinumb	integer			default 0		not null,	/* account的inumber的总数 */

	srqs			varchar(30)		default ''	not null,		/* 特殊要求 */
	master		char(10)			default ''	not null, 		/* 主账 */
	pcrec			char(10)			default ''	not null, 		/* 联房 */
	pcrec_pkg	char(10)			default ''	not null, 		/* 联房 */
	ref			varchar(255)	default ''	null, 			/* comment */
	saleid		varchar(10)		default ''	not null,		/* 销售员 */

	resby			char(10)			default ''	not null,		/* 预订员信息 */
	restime		datetime			null,			
	depby			char(10)			default ''	not null,		/* 退房员信息 */
	deptime		datetime			null,			
	cby			char(10)			not null,						/* 最新修改人信息 */
	changed		datetime			not null,
-- 
	chargeby			char(10)			default ''	not null,	/* 最近一次消费信息 */
	chargetime		datetime			null,
	creditby			char(10)			default ''	not null,	/* 最近一次付款信息 */
	credittime		datetime			null,
	invoiceby		char(10)			default ''	not null,	/* 最近一次结算开票信息 */
	invoicetime		datetime			null,
	statementby		char(10)			default ''	not null,	/* 最近一次对账单信息 */
	statementtime	datetime			null,
	reminderby		char(10)			default ''	not null,	/* 最近一次催账单信息 */
	remindertime	datetime			null,
	remindertext	varchar(30)		default ''	not null,
-- 预留字段
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,

	logmark		integer			default 0 			not null
)
exec sp_primarykey ar_master_del,accnt
create unique index  ar_master_del on ar_master_del(accnt)
;



insert ar_master
	select accnt, haccnt, bdate, sta, osta, ressta, sta_tm, arr, dep, resdep, oarr, odep,
	rmposted = 'F', class, rmpoststa = '0', artag1, artag2, address1, address2, address3, address4, paycode, cycle, limit,
	credcode, credman, credunit, applname, applicant, phone, fax, email, extra,
	charge, credit, charge0, credit0, accredit, disputed, invoice,
	lastnumb, lastinumb, srqs, master, pcrec, pcrec_pkg, ref, saleid,
	resby, restime, depby, deptime, cby, changed,
	chargeby, chargetime, creditby, credittime, invoiceby, invoicetime, statementby, statementtime, '', null, '',
	exp_m1, exp_m2, exp_dt1, exp_dt2, exp_s1, exp_s2, exp_s3, logmark
	from ar_master_old;
insert har_master
	select accnt, haccnt, bdate, sta, osta, ressta, sta_tm, arr, dep, resdep, oarr, odep,
	rmposted = 'F', class, rmpoststa = '0', artag1, artag2, address1, address2, address3, address4, paycode, cycle, limit,
	credcode, credman, credunit, applname, applicant, phone, fax, email, extra,
	charge, credit, charge0, credit0, accredit, disputed, invoice,
	lastnumb, lastinumb, srqs, master, pcrec, pcrec_pkg, ref, saleid,
	resby, restime, depby, deptime, cby, changed,
	chargeby, chargetime, creditby, credittime, invoiceby, invoicetime, statementby, statementtime, '', null, '',
	exp_m1, exp_m2, exp_dt1, exp_dt2, exp_s1, exp_s2, exp_s3, logmark
	from har_master_old;
insert ar_master_last
	select accnt, haccnt, bdate, sta, osta, ressta, sta_tm, arr, dep, resdep, oarr, odep,
	rmposted = 'F', class, rmpoststa = '0', artag1, artag2, address1, address2, address3, address4, paycode, cycle, limit,
	credcode, credman, credunit, applname, applicant, phone, fax, email, extra,
	charge, credit, charge0, credit0, accredit, disputed, invoice,
	lastnumb, lastinumb, srqs, master, pcrec, pcrec_pkg, ref, saleid,
	resby, restime, depby, deptime, cby, changed,
	chargeby, chargetime, creditby, credittime, invoiceby, invoicetime, statementby, statementtime, '', null, '',
	exp_m1, exp_m2, exp_dt1, exp_dt2, exp_s1, exp_s2, exp_s3, logmark
	from ar_master_last_old;
insert ar_master_log
	select accnt, haccnt, bdate, sta, osta, ressta, sta_tm, arr, dep, resdep, oarr, odep,
	rmposted = 'F', class, rmpoststa = '0', artag1, artag2, address1, address2, address3, address4, paycode, cycle, limit,
	credcode, credman, credunit, applname, applicant, phone, fax, email, extra,
	charge, credit, charge0, credit0, accredit, disputed, invoice,
	lastnumb, lastinumb, srqs, master, pcrec, pcrec_pkg, ref, saleid,
	resby, restime, depby, deptime, cby, changed,
	chargeby, chargetime, creditby, credittime, invoiceby, invoicetime, statementby, statementtime, '', null, '',
	exp_m1, exp_m2, exp_dt1, exp_dt2, exp_s1, exp_s2, exp_s3, logmark
	from ar_master_log_old;
insert ar_master_till
	select accnt, haccnt, bdate, sta, osta, ressta, sta_tm, arr, dep, resdep, oarr, odep,
	rmposted = 'F', class, rmpoststa = '0', artag1, artag2, address1, address2, address3, address4, paycode, cycle, limit,
	credcode, credman, credunit, applname, applicant, phone, fax, email, extra,
	charge, credit, charge0, credit0, accredit, disputed, invoice,
	lastnumb, lastinumb, srqs, master, pcrec, pcrec_pkg, ref, saleid,
	resby, restime, depby, deptime, cby, changed,
	chargeby, chargetime, creditby, credittime, invoiceby, invoicetime, statementby, statementtime, '', null, '',
	exp_m1, exp_m2, exp_dt1, exp_dt2, exp_s1, exp_s2, exp_s3, logmark
	from ar_master_till_old;

drop table ar_master_old;
drop table ar_master_last_old;
drop table ar_master_log_old;
drop table ar_master_till_old;
drop table har_master_old;
