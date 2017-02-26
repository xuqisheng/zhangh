if exists(select * from sysobjects where type ="U" and name = "ar_account")
   drop table ar_account;

create table ar_account
(
	accnt			char(10)		not null,							/* 账号 */
	subaccnt		integer		default 0 not null,				/* 子账号(用整数好像更方便一点？) */
	number		integer		not null,							/* 物理序列号,每个账号分别从1开始 */
	inumber		integer		not null,							/* 关联序列号(冲账,转账时有用) */
	modu_id		char(2)		not null,							/* 模块号 */
	log_date		datetime		default getdate() not null,	/* 生成日期 */
	bdate			datetime		not null,							/* 营业日期 */
	date			datetime		default getdate() not null,	/* 传票日期 */
	pccode		char(5)		not null,							/* 营业点码 */
	argcode		char(3)		default '' null,					/* 改编码(打印在账单的代码) */
	quantity		money			default 0 not null,				/* 数量 */
	charge		money			default 0 not null,				/* 借方数,记录客人消费 */
	charge1		money			default 0 not null,				/* 借方数(基本费) */
	charge2		money			default 0 not null,				/* 借方数(优惠费) */
	charge3		money			default 0 not null,				/* 借方数(服务费) */
	charge4		money			default 0 not null,				/* 借方数(税、附加费) */
	charge5		money			default 0 not null,				/* 借方数(其它) */
	package_d	money			default 0 not null,				/* 实际使用Package的金额,对应Package_Detail.charge */
	package_c	money			default 0 not null,				/* Package允许消费的金额,对应Package.credit,Package_Detail.credit */
	package_a	money			default 0 not null,				/* Package的实际金额,对应Package.amount */
	credit		money			default 0 not null,				/* 贷方数,记录客人定金及结算款 */
	balance		money			default 0 not null,				/* 新加字段 */
//
	shift			char(1)		not null,							/* 操作员班号 */
	empno			char(10)		not null,							/* 操作员工号 */
	crradjt		char(2)		default '' not null,				/* 账务标志(详见说明书) */
	waiter		char(3)		default '' not null,				/* 信用卡刷卡行代码 */
	tag			char(3)		null,									/* 市场码 */
	reason		char(3)		null,									/* 优惠理由 */
	tofrom		char(2)		default '' not null,				/* 转账方向,"TO"或"FM" */
	accntof		char(10)		default '' not null,				/* 转账来源或目标 */
	subaccntof	integer		default 0 not null,				/* 转账子账号(用整数好像更方便一点？) */
	ref			char(24)		default '' null,					/* 费用（账务）描述 */
	ref1			char(10)		default '' null,					/* 单号 */
	ref2			char(50)		default '' null,					/* 摘要 */
	roomno		char(5)		default '' not null,				/* 房号 */
	groupno		char(10)		default '' not null,				/* 团号 */
	mode			char(10)		null,									/* 房费明细信息 */
	billno		char(10)		default '' not null,				/* 结账单号 */
// 以下字段好像均不需要了？
	empno0		char(10)		null,									/* 分账（工号） */
	date0			datetime		null,									/* 分账（时间） */
	shift0		char(1)		null,									/* 分账（班号） */
	mode1			char(10)		null,									/* 稽核用 */
	pnumber		integer		default 0 null,					/* 同一个包的号码与第一条的inumber相同 */
	package		char(3)		null,									/* 分账标志 */
// 以下字段是专门为AR账增加的
	ar_accnt		char(10)		default '' not null,				/* AR账号 */
	ar_subaccnt	integer		default 0 not null,				/* 子账号(用整数好像更方便一点？) */
	ar_number	integer		default 0 not null,				/* 物理序列号,每个账号分别从1开始 */
	ar_inumber	integer		default 0 not null,				/* 关联ar_detail的序列号 */
	ar_tag		char(1)		default 'P' not null,			/* 账务类别:A.调整;P.前台转入;p.前台转入的费用明细;T.后台转帐;t.后台转帐的费用明细;Z.压缩账目;t.压缩账目的费用明细 */
	ar_subtotal	char(1)		default 'F' not null,			/* 当前行是否有明细费用:F.没有;T.有 */
	ar_pnumber	integer		default 0 null,					/* 当前行是哪一行的费用明细，只有ar_tag为为小写字母时才有值，否则为零 */
	charge9		money			default 0 not null,				/* 借方数,记录已经结算的客人消费 */
	credit9		money			default 0 not null				/* 贷方数,记录已经结算的客人定金及结算款 */
)
;
exec   sp_primarykey ar_account, ar_accnt, ar_number
create unique index index1 on ar_account(ar_accnt, ar_number)
create index index2 on ar_account(ar_accnt, ar_inumber, ar_tag, ar_subtotal)
create index index3 on ar_account(ar_accnt, ar_number, ar_tag, accnt, number)
create index index4 on ar_account(bdate, shift, empno, ar_tag)
;


if exists(select * from sysobjects where type ="U" and name = "har_account")
   drop table har_account;

create table har_account
(
	accnt			char(10)		not null,							/* 账号 */
	subaccnt		integer		default 0 not null,				/* 子账号(用整数好像更方便一点？) */
	number		integer		not null,							/* 物理序列号,每个账号分别从1开始 */
	inumber		integer		not null,							/* 关联序列号(冲账,转账时有用) */
	modu_id		char(2)		not null,							/* 模块号 */
	log_date		datetime		default getdate() not null,	/* 生成日期 */
	bdate			datetime		not null,							/* 营业日期 */
	date			datetime		default getdate() not null,	/* 传票日期 */
	pccode		char(5)		not null,							/* 营业点码 */
	argcode		char(3)		default '' null,					/* 改编码(打印在账单的代码) */
	quantity		money			default 0 not null,				/* 数量 */
	charge		money			default 0 not null,				/* 借方数,记录客人消费 */
	charge1		money			default 0 not null,				/* 借方数(基本费) */
	charge2		money			default 0 not null,				/* 借方数(优惠费) */
	charge3		money			default 0 not null,				/* 借方数(服务费) */
	charge4		money			default 0 not null,				/* 借方数(税、附加费) */
	charge5		money			default 0 not null,				/* 借方数(其它) */
	package_d	money			default 0 not null,				/* 实际使用Package的金额,对应Package_Detail.charge */
	package_c	money			default 0 not null,				/* Package允许消费的金额,对应Package.credit,Package_Detail.credit */
	package_a	money			default 0 not null,				/* Package的实际金额,对应Package.amount */
	credit		money			default 0 not null,				/* 贷方数,记录客人定金及结算款 */
	balance		money			default 0 not null,				/* 新加字段 */
//
	shift			char(1)		not null,							/* 操作员班号 */
	empno			char(10)		not null,							/* 操作员工号 */
	crradjt		char(2)		default '' not null,				/* 账务标志(详见说明书) */
	waiter		char(3)		default '' not null,				/* 信用卡刷卡行代码 */
	tag			char(3)		null,									/* 市场码 */
	reason		char(3)		null,									/* 优惠理由 */
	tofrom		char(2)		default '' not null,				/* 转账方向,"TO"或"FM" */
	accntof		char(10)		default '' not null,				/* 转账来源或目标 */
	subaccntof	integer		default 0 not null,				/* 转账子账号(用整数好像更方便一点？) */
	ref			char(24)		default '' null,					/* 费用（账务）描述 */
	ref1			char(10)		default '' null,					/* 单号 */
	ref2			char(50)		default '' null,					/* 摘要 */
	roomno		char(5)		default '' not null,				/* 房号 */
	groupno		char(10)		default '' not null,				/* 团号 */
	mode			char(10)		null,									/* 房费明细信息 */
	billno		char(10)		default '' not null,				/* 结账单号 */
// 以下字段好像均不需要了？
	empno0		char(10)		null,									/* 分账（工号） */
	date0			datetime		null,									/* 分账（时间） */
	shift0		char(1)		null,									/* 分账（班号） */
	mode1			char(10)		null,									/* 稽核用 */
	pnumber		integer		default 0 null,					/* 同一个包的号码与第一条的inumber相同 */
	package		char(3)		null,									/* 分账标志 */
// 以下字段是专门为AR账增加的
	ar_accnt		char(10)		default '' not null,				/* AR账号 */
	ar_subaccnt	integer		default 0 not null,				/* 子账号(用整数好像更方便一点？) */
	ar_number	integer		default 0 not null,				/* 物理序列号,每个账号分别从1开始 */
	ar_inumber	integer		default 0 not null,				/* 关联ar_detail的序列号 */
	ar_tag		char(1)		default 'P' not null,			/* 账务类别:A.调整;P.前台转入;p.前台转入的费用明细;T.后台转帐;t.后台转帐的费用明细;Z.压缩账目;t.压缩账目的费用明细 */
	ar_subtotal	char(1)		default 'F' not null,			/* 当前行是否有明细费用:F.没有;T.有 */
	ar_pnumber	integer		default 0 null,					/* 当前行是哪一行的费用明细，只有ar_tag为为小写字母时才有值，否则为零 */
	charge9		money			default 0 not null,				/* 借方数,记录已经结算的客人消费 */
	credit9		money			default 0 not null				/* 贷方数,记录已经结算的客人定金及结算款 */
)
;
exec   sp_primarykey har_account, ar_accnt, ar_number
create unique index index1 on har_account(ar_accnt, ar_number)
create index index2 on har_account(ar_accnt, ar_inumber, ar_tag, ar_subtotal)
create index index3 on har_account(ar_accnt, ar_number, ar_tag, accnt, number)
create index index4 on har_account(bdate, shift, empno, ar_tag)
;
