/* 各种付款方式明细分摊 */
if exists (select * from sysobjects where name ='account_detail' and type ='U')
	drop table account_detail;

create table account_detail
(
	date				datetime,										/* 营业日期 */
	modu_id			char(2)	not null,							/* 模块号 */
	accnt				char(10)	not null,							/* 帐号(前台)
																				菜单号(综合收银)
																				流水号(商务中心) */
	number			integer	default 0 not null,				/* 行次 */
	pccode			char(5)	not null,							/* 费用码 */
	refer				char(15) null,									/* tag(前台)
																				code(综合收银) */
	charge			money		default 0 not null,				/* 金额 */
	paycode			char(5)	default '' not null,				/* 付款方式(折扣为'') */
	key0				char(3)	default '' not null,				/* 优惠人员代码 */
	billno			char(10)	default '' not null,				/* 结帐单号(前台帐务) */
	jierep			char(8)	null,									/* 底表行 */
	tail				char(2)	null									/* 底表列 */
)
exec sp_primarykey account_detail, modu_id, accnt, number, paycode, key0
create unique index index1 on account_detail(modu_id, accnt, number, paycode, key0)
;