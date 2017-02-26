/* 各种优惠,折扣,款待明细 */
if exists (select * from sysobjects where name ='discount_detail' and type ='U')
	drop table discount_detail;

create table discount_detail
(
	date				datetime,										/* 营业日期 */
	modu_id			char(2)	not null,							/* 模块号 */
	accnt				char(10)	not null,							/* 帐号(前台)
																				菜单号(综合收银)
																				流水号(商务中心) */
	number			integer	default 0 not null,				/* 行次 */
	pccode			char(5)	not null,							/* 费用码 */
	charge			money		default 0 not null,				/* 金额 */
	paycode			char(5)	default '' not null,				/* 付款方式(折扣为'ZZZ') */
	key0				char(3)	default '' not null,				/* 优惠人员代码 */
	billno			char(10)	default '' not null,				/* 结帐单号(前台帐务) */
)
exec sp_primarykey discount_detail, modu_id, accnt, number, pccode, paycode, key0, billno
create unique index index1 on discount_detail(modu_id, accnt, number, pccode, paycode, key0, billno)
;

/* 各种优惠,折扣,款待明细 */
if exists (select * from sysobjects where name ='ydiscount_detail' and type ='U')
	drop table ydiscount_detail;

create table ydiscount_detail
(
	date				datetime,										/* 营业日期 */
	modu_id			char(2)	not null,							/* 模块号 */
	accnt				char(10)	not null,							/* 帐号(前台)
																				菜单号(综合收银)
																				流水号(商务中心) */
	number			integer	default 0 not null,				/* 行次 */
	pccode			char(5)	not null,							/* 费用码 */
	charge			money		default 0 not null,				/* 金额 */
	paycode			char(5)	default '' not null,				/* 付款方式(折扣为'ZZZ') */
	key0				char(3)	default '' not null,				/* 优惠人员代码 */
	billno			char(10)	default '' not null,				/* 结帐单号(前台帐务) */
)
exec sp_primarykey ydiscount_detail, date, modu_id, accnt, number, pccode, paycode, key0, billno
create unique index index1 on ydiscount_detail(date, modu_id, accnt, number, pccode, paycode, key0, billno)
;

/* 各种优惠,折扣,款待汇总表 */
if exists (select * from sysobjects where name ='discount' and type ='U')
	drop table discount;

create table discount
(
	date				datetime,										/* 营业日期 */
	key0				char(3)	not null,							/* 优惠人员代码 */
	paycode			char(5)	default '' not null,				/* 付款方式(折扣为'ZZZ') */
	pccode			char(5)	not null,							/* 费用码 */
	day				money		default 0 not null,				/* 本日 */
	month				money		default 0 not null,				/* 本月 */
	year				money		default 0 not null				/* 本年 */
)
exec sp_primarykey discount, key0, paycode, pccode
create unique index index1 on discount(key0, paycode, pccode)
;

/* 各种优惠,折扣,款待汇总表 */
if exists (select * from sysobjects where name ='ydiscount' and type ='U')
	drop table ydiscount;

create table ydiscount
(
	date				datetime,										/* 营业日期 */
	key0				char(3)	not null,							/* 优惠人员代码 */
	paycode			char(5)	default '' not null,				/* 付款方式(折扣为'ZZZ') */
	pccode			char(5)	not null,							/* 费用码 */
	day				money		default 0 not null,				/* 本日 */
	month				money		default 0 not null,				/* 本月 */
	year				money		default 0 not null				/* 本年 */
)
exec sp_primarykey ydiscount, date, key0, paycode, pccode
create unique index index1 on ydiscount(date, key0, paycode, pccode)
;

/* 打印用临时表*/

if exists (select * from sysobjects where name = 'pdiscount' and type = 'U')
	drop table pdiscount;
create table pdiscount
(
	pc_id		char(4), 
	key0		char(3), 
	descript	char(16)	default '' null,
	v1			money		default 0  not null, 
	v2			money		default 0  not null, 
	v3			money		default 0  not null, 
	v4			money		default 0  not null, 
	v5			money		default 0  not null, 
	v6			money		default 0  not null, 
	v7			money		default 0  not null, 
	v8			money		default 0  not null, 
	v9			money		default 0  not null, 
	v10		money		default 0  not null, 
	v11		money		default 0  not null, 
	v12		money		default 0  not null, 
	v13		money		default 0  not null, 
	v14		money		default 0  not null, 
	v15		money		default 0  not null, 
	v16		money		default 0  not null, 
	v17		money		default 0  not null, 
	v18		money		default 0  not null, 
	v19		money		default 0  not null, 
	v20		money		default 0  not null, 
	vtl		money		default 0  not null, 
)
exec sp_primarykey pdiscount, pc_id, key0
create unique index index1 on pdiscount(pc_id, key0)
;