/* 未转到AR账的信用卡 */

if exists(select * from sysobjects where type ="U" and name = "ar_creditcard")
   drop table ar_creditcard;

create table ar_creditcard
(
	accnt			char(10)		not null,							/* 账号 */
	subaccnt		integer		default 0 not null,				/* 子账号 */
	number		integer		not null,							/* 物理序列号,每个账号分别从1开始 */
	inumber		integer		not null,							/* Account.Number & 关联序列号(冲账,转账时有用) */
	modu_id		char(2)		not null,							/* 模块号 */
	log_date		datetime		default getdate() not null,	/* 生成日期 */
	bdate			datetime		not null,							/* 营业日期 */
	date			datetime		default getdate() not null,	/* 传票日期 */
	pccode		char(5)		not null,							/* 营业点码 */
	argcode		char(3)		default '' null,					/* 改编码(打印在账单的代码) */
	quantity		money			default 0 not null,				/* 数量 */
	charge		money			default 0 not null,				/* 借方数,记录客人消费,前台转入的记在这里 */
	credit		money			default 0 not null,				/* 贷方数,记录客人定金及结算款,前台转入的记在这里 */
	balance		money			default 0 not null,				/* 新加字段 */
	charge0		money			default 0 not null,				/* 借方数,记录调整的客人消费 */
	credit0		money			default 0 not null,				/* 贷方数,记录调整的客人定金及结算款,AR录入的记在这里 */
	charge1		money			default 0 not null,				/* 借方数,记录未经信用确认的客人消费,AR录入的记在这里 */
	credit1		money			default 0 not null,				/* 贷方数,记录未经信用确认的的客人定金及结算款 */
	charge9		money			default 0 not null,				/* 借方数,记录已经核销的客人消费 */
	credit9		money			default 0 not null,				/* 贷方数,记录已经核销的客人定金及结算款 */
	balance9		money			default 0 not null,				/* 新加字段 */
	disputed		money			default 0 not null,				/* 争议金额 */
	invoice_id	char(10)		default '' null,					/* 已开发票号 */
	invoice		money			default 0 not null,				/* 已开发票的金额 */
	guestname	varchar(50)	default '' not null,				/* 客人姓名 */
	guestname2	varchar(50)	default '' not null,				/* 客人姓名 */
//
	shift			char(1)		not null,							/* 操作员班号 */
	empno			char(10)		not null,							/* 操作员工号 */
	crradjt		char(2)		default '' not null,				/* 账务标志(详见说明书) */
	reason		char(3)		null,									/* 优惠理由 */
	tofrom		char(2)		default '' not null,				/* 转账方向,"TO"或"FM" */
	accntof		char(10)		default '' not null,				/* 转账来源或目标 */
	subaccntof	integer		default 0 not null,				/* 转账子账号(用整数好像更方便一点？) */
	ref			char(24)		default '' null,					/* 费用（账务）描述 */
	ref1			char(10)		default '' null,					/* 单号 */
	ref2			char(50)		default '' null,					/* 摘要 */
	roomno		char(5)		default '' not null,				/* 房号 */
	billno		char(10)		default '' not null,				/* 结账单号 */
	tag			char(1)		default 'P' null,					/* 账务类别:A.调整;P.前台转入;T.后台转帐;Z.压缩账目 */
	audit			char(1)		default '1' not null,			/* 审核标志:0.未审应收账;2.未审信用卡账;:1.已审账; */
// 以下字段好像均不需要了？
	empno0		char(10)		null,									/* 审核确认（工号） */
	date0			datetime		null,									/* 审核确认（时间） */
	shift0		char(1)		null,									/* 审核确认（班号） */
	mode1			char(10)		default '' null,					/* 稽核用 */
	pnumber		integer		default 0 null,					/* 压缩后账目的number号 */
	package		char(3)		null,									/* 分账标志 */
	waiter		char(3)		default '' not null,				/* 信用卡刷卡行代码 */
	selected		integer		default 0 not null				/*  */
)
;
exec   sp_primarykey ar_creditcard, accnt, number
create unique index index1 on ar_creditcard(accnt, number)
;
