/* 转AR账明细 */

if exists(select * from sysobjects where type ="U" and name = "transfer_log")
	drop table transfer_log
;
create table transfer_log
(
	accnt			char(10)		not null,								/* 源帐号 */
	number		integer		default 0 not null,					/* 源序号 */
	charge		money			default 0 not null,					/* 源消费金额 */
	credit		money			default 0 not null,					/* 源付款金额 */
	empno			char(10)		not null,								/* 转账工号 */
	date			datetime		default getdate() not null,		/* 转账时间 */
	//
	araccnt		char(10)		not null,								/* AR帐号 */
	arnumber		integer		default 1 not null,					/* AR序号 */
	archarge		money			default 0 not null,					/* 收回消费金额 */
	arcredit		money			default 0 not null,					/* 收回付款金额 */
	arempno		char(10)		null,										/* 收回工号 */
	ardate		datetime		null,										/* 收回时间 */
	//
	billno		char(10)		default '' not null					/* 收回时的帐单号 */
)
exec sp_primarykey transfer_log, accnt, number, araccnt, arnumber
create unique index index1 on transfer_log(accnt, number, araccnt, arnumber)
create index index2 on transfer_log(araccnt, arnumber)
;

