// AR账核销库
if exists(select * from sysobjects where type ="U" and name = "ar_apply")
   drop table ar_apply;

create table ar_apply
(
	d_accnt		char(10)		not null,							/* 借方账号 */
	d_number		integer		not null,							/* 借方ar_detail中的账次 */
	d_inumber	integer		not null,							/* 借方ar_account中的账次 */
	c_accnt		char(10)		not null,							/* 贷方账号 */
	c_number		integer		not null,							/* 贷方ar_detail中的账次 */
	c_inumber	integer		not null,							/* 贷方ar_account中的账次 */
	amount		money			default 0 not null,				/* 核销金额 */
	billno		char(10)		not null,							/* 核销单号 */
	log_date		datetime		default getdate() not null,	/* 生成日期 */
	bdate			datetime		not null,							/* 营业日期 */
	shift			char(1)		not null,							/* 操作员班号 */
	empno			char(10)		not null,							/* 操作员工号 */
)
;
exec   sp_primarykey ar_apply, d_accnt, d_number, d_inumber, c_accnt, c_number, c_inumber, billno
create unique index index1 on ar_apply(d_accnt, d_number, d_inumber, c_accnt, c_number, c_inumber, billno)
create index index2 on ar_apply(billno, d_accnt, c_accnt)
;
