if exists(select * from sysobjects where type ="U" and name = "account")
   drop table account;

create table account
(
	accnt			char(10)		not null,							/* 账号 */
	subaccnt		integer		default 0 not null,				/* 子账号(用整数好像更方便一点？) */
	number		integer		not null,							/* 物理序列号,每个账号分别从1开始 */
	inumber		integer		not null,							/* 关联序列号(冲账,转账时有用) */
	modu_id		char(2)		not null,							/* 模块号 */
	log_date		datetime		default getdate() not null,	/* 生成日期 */
	bdate			datetime		not null,							/* 营业日期 */
	date			datetime		default getdate() not null,	/* 传票日期 */
	pccode		char(3)		not null,							/* 营业点码 */
	argcode		char(2)		default '' null,					/* 改编码(打印在账单的代码) */
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
	empno0		char(10)		null,									/* 稽核用 */
	date0			datetime		null,									/* 稽核用 */
	shift0		char(1)		null,									/* 稽核用 */
	mode1			char(10)		null,									/* 稽核用 */
	pnumber		integer		default 0 null,					/* 同一个包的号码与第一条的inumber相同 */
	package		char(3)		null									/* 包的代码 */
)
;
insert account select accnt, 1, number, inumber, modu_id, log_date, bdate, date, pccode + servcode, pccode, 1, charge, 
	0, 0, 0, 0, 0,	0, 0, 0, credit, balance, shift, empno, crradjt, waiter, tag, tag1, tofrom, accntof, 0, 
	substring(ref + '        ', 1, 8) + ref1, '', ref2, isnull(roomno, ''), isnull(groupno, ''), mode, billno, empno0, date0, shift0, mode1, pnumber, package
	from v5..account
;
exec   sp_primarykey account, accnt, number
create unique index index1 on account(accnt, number)
create index index2 on account(billno, accnt, subaccnt, pccode)
create index index3 on account(tofrom, accntof, subaccntof)
create index index4 on account(bdate, shift, empno)
update account set billno = 'B' + substring(billno, 2, 9) where billno like '[OP]%';
update account set quantity=0 where pccode<'03';
update account set quantity=1 where pccode='02A' and mode like '[B,J,N]%';
update account set quantity=0.5 where pccode='02A' and mode like '[b,j,P]%';
//
update account set pccode = a.pos_item,argcode = substring(a.pos_item,1,2) from a_chgcod a where account.pccode = a.old_pccode;
update account set crradjt = '' where crradjt = 'NR';
update account set argcode = '98' where argcode in ('05', '06');
update account set argcode = '99' where argcode in ('03');
update account set pccode = a.pccode from pccode a where account.tag = a.deptno2;
// JJH
update account set pccode = '921' where pccode='920';
update account set pccode = '916' where pccode in ('917', '919');
update account set pccode = '918' where pccode='917';
update account set charge1 = charge where reason = '';
update account set charge2 = - charge where reason <> '';
