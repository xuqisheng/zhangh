// Package定义表
if exists(select * from sysobjects where type ="U" and name = "package")
   drop table package;

create table package
(
	code					char(8)			not null,								/* 代码 */
	type					char(1)			not null,								/* 类别 */
	descript				char(30)			not null,								/* 描述 */
	descript1			char(30)			default '' not null,					/* 英文描述 */
	pccode				char(5)			not null,								/* 费用码 */
	quantity				money				default 1 not null,					/* 数量 */
	amount				money				default 0 not null,					/* 金额 */
	rule_calc			char(10)			default '0000000000' not null,	/* 计算方式选项
																								第一位:0.费用过在Package_Detail中;1.费用过在Account中
																								第二位:0.include;1.exclude
																								第三位:0.按金额;1.按比例
																								第四位:0.固定金额;1.按总人数;2.按成人;3.按儿童
																								第五位:0.日租加收;1.日租不收
																								第十位:可以成本价消费的个数(东方豪生) */
	rule_post			char(3)			not null,								/* 入账方式 */
	rule_parm			char(30)			default '' not null,					/* 入账周期 */
	starting_days		integer			default 1 not null,					/* 从入账后的第几天开始生效 */
	closing_days		integer			default 1 not null,					/* 总的生效天数 */
	starting_time		char(8)			default '00:00:00' not null,		/* 每天的有效挂账起始时间 */
	closing_time		char(8)			default '23:59:59' not null,		/* 每天的有效挂账截止时间 */
	pccodes				varchar(255)	default '' not null,					/* 可以关联的营业点费用码 */
	pos_pccode			char(5)			default '' not null,					/* 超出限额后，记入Account的营业点费用码 */
	credit				money				default 0 not null,					/* 允许转账的金额 */
	accnt					char(10)			default '' not null,					/* 调整账户的账号 */
	profit				char(5)			default '' not null,
	loss					char(5)			default '' not null,
	cby					char(10)			not null,								/* 工号 */
	changed				datetime			default getdate() not null,		/* 时间 */
	logmark				integer			default 0 not null
);
exec sp_primarykey package, code
create unique index index1 on package(code)
;
//insert package values ('SVR', '1', '服务费', '', '002', 1, 0.1, '00101', '*', '', 1, 1, '00:00:00', '23:59:59', '', '', 0, 'HRY', getdate(), 1);
//insert package values ('TAX', '5', '城建费', '', '005', 1, 0.05, '00101', '*', '', 1, 1, '00:00:00', '23:59:59', '', '', 0, 'HRY', getdate(), 1);
//insert package values ('BFA', '6', '映波厅', '', '100', 1, 68, '00000', '*', '', 1, 1, '00:00:00', '23:59:59', '100;110;120', '', 200, 'HRY', getdate(), 1);

// Package明细表(说明:即使使用Pakcage,在Account中都有一行金额为零的明细账)
// Master.Lastinumb转为Package.Number指针
if exists(select * from sysobjects where type ="U" and name = "package_detail")
   drop table package_detail;
create table package_detail
(
	accnt					char(10)			not null,								/* 账号 */
	number				integer			not null,								/* 关键字 */
	roomno				char(5)			default '' not null,					/* 房号 */
	code					char(8)			default '' not null,					/* 代码 */
	descript				char(30)			not null,								/* 描述 */
	descript1			char(30)			default '' not null,					/* 英文描述 */
	bdate					datetime			not null,								/*  */
	starting_date		datetime			default '2000/1/1' not null,		/* 有效起始日期 */
	closing_date		datetime			default '2038/12/31' not null,	/* 有效截止日期 */
	starting_time		char(8)			default '00:00:00' not null,		/* 每天的有效挂账起始时间 */
	closing_time		char(8)			default '23:59:59' not null,		/* 每天的有效挂账截止时间 */
	pccodes				varchar(255)	default '' not null,					/* 可以关联的营业点费用码 */
	pos_pccode			char(5)			default '' not null,					/* 超出限额后，记入Account的营业点费用码 */
	quantity				money				default 0 not null,					/* 数量 */
	charge				money				default 0 not null,					/* 已转账的金额 */
	credit				money				default 0 not null,					/* 允许转账的金额 */
	posted_accnt		char(10)			default '' not null,					/* 实际转账的账号 */
	posted_roomno		char(5)			default '' not null,					/* 实际转账的房号 */
	posted_number		integer			default 0 not null,					/* 对应关键字(实际使用的是那一行Package) */
	tag					char(1)			default '0' not null,				/* 标志：0.自动过入的Package(未用);
																										1.自动过入的Package(已用了一部分);
																										2.自动过入的Package(已用光);
																										5.自动过入的Package(已冲销);
																										9.实际使用Package的明细 */
	account_accnt		char(10)			default '' not null,					/* 账号(对应Account.Accnt) */
	account_number		integer			default 0 not null,					/* 账次(对应Account.Number) */
	account_date		datetime			default getdate() not null,		/* 账号(对应Account.log_date) */
	flag					char(1)			default 'F' 	not null				/* 夜审冲销标志 */
);
exec sp_primarykey package_detail, accnt, number
create unique index index1 on package_detail(accnt, number)
create index index2 on package_detail(accnt, account_accnt)
create index index3 on package_detail(accnt, tag, starting_date, closing_date, starting_time, closing_time)
;
if exists(select * from sysobjects where type ="U" and name = "hpackage_detail")
   drop table hpackage_detail;
create table hpackage_detail
(
	accnt					char(10)			not null,								/* 账号 */
	number				integer			not null,								/* 关键字 */
	roomno				char(5)			default '' not null,					/* 房号 */
	code					char(8)			default '' not null,					/* 代码 */
	descript				char(30)			not null,								/* 描述 */
	descript1			char(30)			default '' not null,					/* 英文描述 */
	bdate					datetime			not null,								/*  */
	starting_date		datetime			default '2000/1/1' not null,		/* 有效起始日期 */
	closing_date		datetime			default '2038/12/31' not null,	/* 有效截止日期 */
	starting_time		char(8)			default '00:00:00' not null,		/* 每天的有效挂账起始时间 */
	closing_time		char(8)			default '23:59:59' not null,		/* 每天的有效挂账截止时间 */
	pccodes				varchar(255)	default '' not null,					/* 可以关联的营业点费用码 */
	pos_pccode			char(5)			default '' not null,					/* 超出限额后，记入Account的营业点费用码 */
	quantity				money				default 0 not null,					/* 数量 */
	charge				money				default 0 not null,					/* 已转账的金额 */
	credit				money				default 0 not null,					/* 允许转账的金额 */
	posted_accnt		char(10)			default '' not null,					/* 实际转账的账号 */
	posted_roomno		char(5)			default '' not null,					/* 实际转账的房号 */
	posted_number		integer			default 0 not null,					/* 对应关键字(实际使用的是那一行Package) */
	tag					char(1)			default '0' not null,				/* 标志：0.自动过入的Package(未用);
																										1.自动过入的Package(已用了一部分);
																										2.自动过入的Package(已用光);
																										5.自动过入的Package(已冲销);
																										9.实际使用Package的明细 */
	account_accnt		char(10)			default '' not null,					/* 账号(对应Account.Accnt) */
	account_number		integer			default 0 not null,					/* 账次(对应Account.Number) */
	account_date		datetime			default getdate() not null,		/* 账号(对应Account.log_date) */
	flag					char(1)			default 'F' 	not null				/* 夜审冲销标志 */
);
exec sp_primarykey hpackage_detail, accnt, number
create unique index index1 on hpackage_detail(accnt, number)
create index index2 on hpackage_detail(accnt, account_accnt)
create index index3 on hpackage_detail(accnt, tag, starting_date, closing_date, starting_time, closing_time)
;

//insert package_detail values ('3012018', 1, '1210', 'BFA', '早餐', '', '2001/1/1', '2003/12/31', '00:00:00', '23:59:59', '100;110;120', '', 0, 100, '', '', 0, '0', '3012018', 1, getdate());
//insert package_detail values ('3012028', 1, '1219', 'BFA', '早餐', '', '2001/1/1', '2003/12/31', '00:00:00', '23:59:59', '100;110;120', '', 0, 100, '', '', 0, '0', '3012028', 1, getdate());

insert basecode values ('package_rule_post', '*', '每天入账', 'Post Every Night', 'T', 'F', 10, '');
insert basecode values ('package_rule_post', 'B', '仅在到达的当天晚上入账', 'Post on Arrival Night', 'T', 'F', 20, '');
insert basecode values ('package_rule_post', 'E', '仅在最后一个晚上入账', 'Post on Last Night', 'T', 'F', 30, '');
insert basecode values ('package_rule_post', 'W', '在一周中的某几天入账', 'Post on Certain Nights of the Week', 'T', 'F', 40, '');
insert basecode values ('package_rule_post', '-B', '除了到达的那天外每天入账', 'PostEvery Night Except Arrival Night', 'T', 'F', 50, '');
insert basecode values ('package_rule_post', '-E', '除了最后一天外每天入账', 'PostEvery Night Except Last Night', 'T', 'F', 60, '');
insert basecode values ('package_rule_post', 'M', '除了头尾两天外每天入账', 'Do NOT Post on Arrival and Last Night', 'T', 'F', 70, '');
//
insert basecode values ('package_rule_4', '0', '固定费用', 'Flat Rate', 'T', 'F', 10, '');
insert basecode values ('package_rule_4', '1', '按人数收取', 'Per Person', 'T', 'F', 20, '');
insert basecode values ('package_rule_4', '2', '按成人数收取', 'Per Adult', 'T', 'F', 30, '');
insert basecode values ('package_rule_4', '3', '按儿童数收取', 'Per Child', 'T', 'F', 40, '');
//
insert basecode values ('package_type', '1', '早餐', 'Breakfast', 'T', 'F', 10, '');
insert basecode values ('package_type', '2', '中餐', 'Lunch', 'T', 'F', 20, '');
insert basecode values ('package_type', '3', '晚餐', 'Dinner', 'T', 'F', 30, '');
insert basecode values ('package_type', '4', '混合餐', 'Miscellaneous', 'T', 'F', 40, '');
insert basecode values ('package_type', '5', '服务费', 'Service Charge', 'T', 'F', 50, '');
insert basecode values ('package_type', '6', '城建费', 'Tax', 'T', 'F', 60, '');
//
INSERT INTO sysdefault VALUES (	'd_gl_code_package_edit',	'rule_post',	'*');
INSERT INTO sysdefault VALUES (	'd_gl_code_package_edit',	'rule_4',	'0');
INSERT INTO sysdefault VALUES (	'd_gl_code_package_edit',	'type',	'1');
INSERT INTO sysdefault VALUES (	'd_gl_code_package_edit',	'quantity',	'1');
INSERT INTO sysdefault VALUES (	'd_gl_code_package_edit',	'amount',	'0');
