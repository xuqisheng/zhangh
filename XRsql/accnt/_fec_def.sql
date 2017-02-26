// 外币兑换相关表

//exec sp_rename fec_def, a_fec_def;

// 外币兑换牌价
if exists(select * from sysobjects where name = "fec_def")
   drop table fec_def;
create table fec_def
(
	code				char(3)					not null,				//代码
	descript			char(30)					not null,				//中文描述
	descript1		char(30)					null,						//英文描述
	disc				money		default 0 	not null,				//扣贴息
	base				money		default 100 not null,				//基数
	price_in			money		default 0 	not null,				//买入价
	price_out		money		default 0 	not null,				//卖出价
	price_cash		money		default 0 	not null, 				//现钞价
	cby				char(10)	default ''	not null,
	changed			datetime					null,
	logmark			int		default 0	not null
)
exec   sp_primarykey fec_def, code
create unique index index1 on fec_def(code)
;

if exists(select * from sysobjects where name = "fec_def_log")
   drop table fec_def_log;
create table fec_def_log
(
	code				char(3)					not null,				//代码
	descript			char(30)					not null,				//中文描述
	descript1		char(30)					null,						//英文描述
	disc				money		default 0 	not null,				//扣贴息
	base				money		default 100 not null,				//基数
	price_in			money		default 0 	not null,				//买入价
	price_out		money		default 0 	not null,				//卖出价
	price_cash		money		default 0 	not null, 				//现钞价
	cby				char(10)	default ''	not null,
	changed			datetime					null,
	logmark			int		default 0	not null
)
exec   sp_primarykey fec_def_log, code, logmark
create unique index index1 on fec_def_log(code, logmark)
;

//insert fec_def select * , '', getdate(), 0 from a_fec_def;

// 外币兑换流水账
if exists(select * from sysobjects where name = "fec_folio")
   drop table fec_folio;
create table fec_folio
(
	foliono			char(10)					not null,				// 电脑流水号
	sta				char(1)					not null,				// I, X
	sno				varchar(12)				null,						// 手工单号
	tag				char(1)	default '1'	not null,  				// 1=外部, 0=内部
	bdate				datetime					not null,
	gstid				char(7)					null,
	roomno			char(5) default '' 	null,
	name				varchar(50)				not null,
	nation			char(3)					not null,
	idcls				char(3)					not null,
	ident				char(20)					not null,
	code				char(3)					not null,				// 代码
	class				char(5) default 'CASH' not null, 			// CASH, CHECK
	amount0			money		default 0 	not null,				// 金额
	disc				money		default 0 	not null,				// 扣贴息
	amount			money		default 0 	not null,				// 净额
	price				money		default 0 	not null,				// 买入价
	amount_out		money		default 0 	not null,				// 兑出币
	ref				varchar(100)			null,
	resby				char(10)					not null,
	reserved			datetime					not null,
	cby				char(10)					not null,
	changed			datetime					not null,
	logmark			int		default 0	not null
)
exec   sp_primarykey fec_folio, foliono
create unique index index1 on fec_folio(foliono)
;
if exists(select * from sysobjects where name = "fec_folio_log")
   drop table fec_folio_log;
create table fec_folio_log
(
	foliono			char(10)					not null,				// 电脑流水号
	sta				char(1)					not null,				// I, X
	sno				varchar(12)				null,						// 手工单号
	tag				char(1)	default '1'	not null,  				// 1=外部, 0=内部
	bdate				datetime					not null,
	gstid				char(7)					null,
	roomno			char(5) default '' 	null,
	name				varchar(50)				not null,
	nation			char(3)					not null,
	idcls				char(3)					not null,
	ident				char(20)					not null,
	code				char(3)					not null,				// 代码
	class				char(5) default 'CASH' not null, 			// CASH, CHECK
	amount0			money		default 0 	not null,				// 金额
	disc				money		default 0 	not null,				// 扣贴息
	amount			money		default 0 	not null,				// 净额
	price				money		default 0 	not null,				// 买入价
	amount_out		money		default 0 	not null,				// 兑出币
	ref				varchar(100)			null,
	resby				char(10)					not null,
	reserved			datetime					not null,
	cby				char(10)					not null,
	changed			datetime					not null,
	logmark			int		default 0	not null
)
exec   sp_primarykey fec_folio_log, foliono, logmark
create unique index index1 on fec_folio_log(foliono, logmark)
;

// 外币兑换流水账 - 历史纪录
if exists(select * from sysobjects where name = "fec_hfolio")
   drop table fec_hfolio;
create table fec_hfolio
(
	foliono			char(10)					not null,				// 电脑流水号
	sta				char(1)					not null,				// I, X
	sno				varchar(12)				null,						// 手工单号
	tag				char(1)	default '1'	not null,  				// 1=外部, 0=内部
	bdate				datetime					not null,
	gstid				char(7) default ''	null,
	roomno			char(5) default '' 	null,
	name				varchar(50)				not null,
	nation			char(3)					not null,
	idcls				char(3)					not null,
	ident				char(20)					not null,
	code				char(3)					not null,				// 代码
	class				char(5) default 'CASH' not null, 			// CASH, CHECK
	amount0			money		default 0 	not null,				// 金额
	disc				money		default 0 	not null,				// 扣贴息
	amount			money		default 0 	not null,				// 净额
	price				money		default 0 	not null,				// 买入价
	amount_out		money		default 0 	not null,				// 兑出币
	ref				varchar(100)			null,
	resby				char(10)					not null,
	reserved			datetime					not null,
	cby				char(10)					not null,
	changed			datetime					not null,
	logmark			int		default 0	not null
)
exec   sp_primarykey fec_hfolio, foliono
create unique index index1 on fec_hfolio(foliono)
create index index2 on fec_hfolio(bdate)
create index index3 on fec_hfolio(name)
create index index4 on fec_hfolio(roomno)
;
