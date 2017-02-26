// fixed_charge定义表
if exists(select * from sysobjects where type ="U" and name = "fixed_charge")
   drop table fixed_charge;

create table fixed_charge
(
	accnt					char(10)			not null,								/* 账号 */
	number				integer			not null,								/*  */
	pccode				char(5)			not null,								/* 费用码 */
	argcode				char(3)			default '' null,						/* 改编码(打印在账单的代码) */
	amount				money				default 0 not null,					/* 金额 */
	quantity				money				default 0 not null,					/* 数量 */
	starting_time		datetime			default '2000-1-1' not null,					/* 有效期起始 */
	closing_time		datetime			default '2000-1-1 23:59:59' not null,		/* 有效期截止 */
	cby					char(10)			not null,								/* 工号 */
	changed				datetime			default getdate() not null,		/* 时间 */
	logmark				integer			default 0 not null
);
exec sp_primarykey fixed_charge, accnt, number
create unique index index1 on fixed_charge(accnt, number)
;
// fixed_charge_log定义表
if exists(select * from sysobjects where type ="U" and name = "fixed_charge_log")
   drop table fixed_charge_log;

create table fixed_charge_log
(
	accnt					char(10)			not null,								/* 账号 */
	number				integer			not null,								/*  */
	pccode				char(5)			not null,								/* 费用码 */
	argcode				char(3)			default '' null,						/* 改编码(打印在账单的代码) */
	amount				money				default 0 not null,					/* 金额 */
	quantity				money				default 0 not null,					/* 数量 */
	starting_time		datetime			default '2000-1-1' not null,					/* 有效期起始 */
	closing_time		datetime			default '2000-1-1 23:59:59' not null,		/* 有效期截止 */
	cby					char(10)			not null,								/* 工号 */
	changed				datetime			default getdate() not null,		/* 时间 */
	logmark				integer			default 0 not null
);
exec sp_primarykey fixed_charge_log, accnt, number, logmark
create unique index index1 on fixed_charge_log(accnt, number, logmark)
;
//insert fixed_charge values ('SVR', '1', '服务费', '', '002', 0.1, '0010', '*', '', '0', '0', '2000-1-1', '2000-1-1 23:59:59', '', '', 0, 'HRY', getdate(), 1);
//insert fixed_charge values ('TAX', '5', '城建费', '', '005', 0.05, '0010', '*', '', '0', '0', '2000-1-1', '2000-1-1 23:59:59', '', '', 0, 'HRY', getdate(), 1);
//insert fixed_charge values ('BFA', '6', '映波厅', '', '100', 68, '0000', '*', '', '0', '0', '2000-1-1', '2000-1-1 23:59:59', '100;110;120', '', 200, 'HRY', getdate(), 1);
//
//// fixed_charge明细表(说明:即使使用Pakcage,在Account中都有一行金额为零的明细账)
//// Master.Lastinumb转为fixed_charge.Number指针
//if exists(select * from sysobjects where type ="U" and name = "fixed_charge_detail")
//   drop table fixed_charge_detail;
//
//create table fixed_charge_detail
//(
//	accnt					char(10)			not null,								/* 账号 */
//	number				integer			not null,								/* 关键字 */
//	roomno				char(5)			default '' not null,					/* 房号 */
//	code					char(4)			default '' not null,					/* 代码 */
//	descript				char(30)			not null,								/* 描述 */
//	descript1			char(30)			default '' not null,					/* 英文描述 */
//	starting_time		datetime			default '2000-1-1' not null,					/* 有效期起始 */
//	closing_time		datetime			default '2038-1-1 23:59:59' not null,		/* 在定义行是有效期截止;在转账行是发生时间 */
//	pccodes				varchar(255)	default '' not null,					/* 可以关联的营业点费用码 */
//	pos_pccode			char(3)			default '' not null,					/* 超出限额后，记入Account的营业点费用码 */
//	charge				money				default 0 not null,					/* 已转账的金额 */
//	credit				money				default 0 not null,					/* 允许转账的金额 */
//	posted_accnt		char(10)			default '' not null,					/* 实际转账的账号 */
//	posted_roomno		char(5)			default '' not null,					/* 实际转账的房号 */
//	posted_number		integer			default 0 not null,					/* 对应关键字(实际使用的是那一行fixed_charge) */
//	tag					char(1)			default '0' not null,				/* 标志：0.自动过入的fixed_charge(未用);
//																										1.自动过入的fixed_charge(已用了一部分);
//																										2.自动过入的fixed_charge(已用光);
//																										5.自动过入的fixed_charge(已冲销);
//																										9.实际使用fixed_charge的明细 */
//	account_accnt		char(10)			default '' not null,					/* 账号(对应Account.Accnt) */
//	account_number		integer			default 0 not null					/* 账次(对应Account.Number) */
//);
//exec sp_primarykey fixed_charge_detail, accnt, number
//create unique index index1 on fixed_charge_detail(accnt, number)
//create index index2 on fixed_charge_detail(accnt, account_number)
//create index index3 on fixed_charge_detail(accnt, tag, starting_time, closing_time)
//;
//
//insert fixed_charge_detail values ('3012028', 1, '1219', 'BFA', '早餐', '', '2001/1/1', '2003/12/31', '100;110;120', '', 0, 200, '', '', 0, '0', '3012028', 1);
//
//insert basecode values ('fixed_charge_rule_post', '*', '每天入账', 'Post Every Night', 'T', 'F', 10, '');
//insert basecode values ('fixed_charge_rule_post', 'B', '仅在到达的当天晚上入账', 'Post on Arrival Night', 'T', 'F', 20, '');
//insert basecode values ('fixed_charge_rule_post', 'E', '仅在最后一个晚上入账', 'Post on Last Night', 'T', 'F', 30, '');
//insert basecode values ('fixed_charge_rule_post', 'W', '在一周中的某几天入账', 'Post on Certain Nights of the Week', 'T', 'F', 40, '');
//insert basecode values ('fixed_charge_rule_post', '-B', '除了到达的那天外每天入账', 'PostEvery Night Except Arrival Night', 'T', 'F', 50, '');
//insert basecode values ('fixed_charge_rule_post', '-E', '除了最后一天外每天入账', 'PostEvery Night Except Last Night', 'T', 'F', 60, '');
//insert basecode values ('fixed_charge_rule_post', 'M', '除了头尾两天外每天入账', 'Do NOT Post on Arrival and Last Night', 'T', 'F', 70, '');
////
//insert basecode values ('fixed_charge_rule_4', '0', '固定费用', 'Flat Rate', 'T', 'F', 10, '');
//insert basecode values ('fixed_charge_rule_4', '1', '按人数收取', 'Per Person', 'T', 'F', 20, '');
//insert basecode values ('fixed_charge_rule_4', '2', '按成人数收取', 'Per Adult', 'T', 'F', 30, '');
//insert basecode values ('fixed_charge_rule_4', '3', '按儿童数收取', 'Per Child', 'T', 'F', 40, '');
////
//insert basecode values ('fixed_charge_type', '1', '早餐', 'Breakfast', 'T', 'F', 10, '');
//insert basecode values ('fixed_charge_type', '2', '中餐', 'Lunch', 'T', 'F', 20, '');
//insert basecode values ('fixed_charge_type', '3', '晚餐', 'Dinner', 'T', 'F', 30, '');
//insert basecode values ('fixed_charge_type', '4', '混合餐', 'Miscellaneous', 'T', 'F', 40, '');
//insert basecode values ('fixed_charge_type', '5', '服务费', 'Service Charge', 'T', 'F', 50, '');
//insert basecode values ('fixed_charge_type', '6', '城建费', 'Tax', 'T', 'F', 60, '');
//