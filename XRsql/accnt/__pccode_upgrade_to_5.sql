exec sp_rename account, account_old;
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
	package		char(3)		null									/* 分账标志 */
)
;
insert account select * from account_old
;
exec   sp_primarykey account, accnt, number
create unique index index1 on account(accnt, number)
create index index2 on account(billno, accnt, subaccnt, pccode)
create index index3 on account(tofrom, accntof, subaccntof)
create index index4 on account(bdate, empno, shift)
;
drop table account_old;
//--------------------
exec sp_rename gltemp, gltemp_old;
create table gltemp
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
	package		char(3)		null									/* 分账标志 */
)
;
insert gltemp select * from gltemp_old
;
exec   sp_primarykey gltemp, accnt, number
create unique index index1 on gltemp(accnt, number)
;
drop table gltemp_old;
//-------------------
exec sp_rename haccount, haccount_old;
create table haccount
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
	package		char(3)		null									/* 分账标志 */
)
;
insert haccount select * from haccount_old
;
exec   sp_primarykey haccount, accnt, number
create unique index index1 on haccount(accnt, number)
create index index2 on haccount(billno, accnt, subaccnt, pccode)
create index index3 on haccount(tofrom, accntof, subaccntof)
create index index4 on haccount(bdate, empno, shift)
;
drop table haccount_old
;
//-------------------
exec sp_rename outtemp, outtemp_old;
create table outtemp
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
	package		char(3)		null									/* 分账标志 */
)
;
insert outtemp select * from outtemp_old
;
exec   sp_primarykey outtemp, accnt, number
create unique index index1 on outtemp(accnt, number)
;
drop table outtemp_old;
//-------------------
exec sp_rename account_detail, account_detail_old;

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
;
insert account_detail select * from account_detail_old
;
exec sp_primarykey account_detail, modu_id, accnt, number, paycode, key0
create unique index index1 on account_detail(modu_id, accnt, number, paycode, key0)
;
drop table account_detail_old;
//--------------------------
exec sp_rename accredit, accredit_old
;
create table accredit
(
	accnt			char(10)		not null,								/* 帐号 */
	number		integer		default 1 not null,					/* 序号 */
	pccode		char(5)		not null,								/* 信用卡类型 */
	cardno		char(20)		not null,								/* 卡号 */
	expiry_date	datetime		not null,								/* 信用卡有效期 */
	foliono		char(10)		default '' not null,					/* 水单号 */
	creditno		char(10)		default '' not null,					/* 授权号 */
	amount		money			default 0 not null,					/* 金额 */
	tag			char(1)		default '0' not null,				/* 状态:0.未用;5.取消;9.使用*/
	empno1		char(10)		not null,								/* 收件工号 */
	bdate1		datetime		not null,								/* 收件营业日期 */
	shift1		char(1)		not null,								/* 收件班别 */
	log_date1	datetime		default getdate() not null,		/* 收件时间 */
	empno2		char(10)		null,										/* 使用工号 */
	bdate2		datetime		null,										/* 使用营业日期 */
	shift2		char(1)		null,										/* 使用班别 */
	log_date2	datetime		null,										/* 使用时间 */
	partout		integer		default 1 not null,					/* 部分结账转销时用 */
	billno		char(10)		default '' not null					/* 使用该信用卡的帐单号 */
)
;
insert accredit select * from accredit_old
;
exec sp_primarykey accredit, accnt, number
create unique index index1 on accredit(accnt, number)
;
drop table accredit_old;
//--------------------
/* 分摊用临时表 */
exec sp_rename apportion_jie, apportion_jie_old;

create table apportion_jie
(
	pc_id				char(4)	not null,							/* IP地址 */
	accnt				char(10)	not null,							/* 帐号(前台)
																				菜单号(综合收银)
																				流水号(商务中心) */
	number			integer	default 0 not null,				/* 行次 */
	pccode			char(5)	not null,							/* 费用码 */
	refer				char(15) null,									/* tag(前台)
																				code(综合收银) */
	charge			money		default 0 not null				/* 金额 */
)
;
insert apportion_jie select * from apportion_jie_old
;
exec sp_primarykey apportion_jie, pc_id, accnt, number
create unique index index1 on apportion_jie(pc_id, accnt, number)
;
drop table apportion_jie_old;
//-----------------------
exec sp_rename apportion_dai, apportion_dai_old;

create table apportion_dai
(
	pc_id				char(4)	not null,							/* IP地址 */
	paycode			char(5)	not null,							/* 付款方式 */
	credit			money		default 0 not null,				/* 金额 */
	key0				char(3)	null,									/* 优惠人员代码 */
	accnt				char(10)	not null								/* 帐号(前台)
																				菜单号(综合收银)
																				流水号(商务中心) */
)
;
insert apportion_dai select * from apportion_dai_old
;
exec sp_primarykey apportion_dai, pc_id, paycode, key0, accnt
create unique index index1 on apportion_dai(pc_id, paycode, key0, accnt)
;
drop table apportion_dai_old;
//-----------------------
exec sp_rename apportion_jiedai, apportion_jiedai_old;

create table apportion_jiedai
(
	pc_id				char(4)	not null,							/* IP地址 */
	accnt				char(10)	not null,							/* 帐号(前台)
																				菜单号(综合收银)
																				流水号(商务中心) */
	number			integer	default 0 not null,				/* 行次 */
	pccode			char(5)	not null,							/* 费用码 */
	refer				char(15) null,									/* tag(前台)
																				code(综合收银) */
	charge			money		default 0 not null,				/* 金额 */
	paycode			char(5)	not null,							/* 付款方式 */
	key0				char(3)	default '' null					/* 优惠人员代码 */
)
;
insert apportion_jiedai select * from apportion_jiedai_old
;
exec sp_primarykey apportion_jiedai, pc_id, accnt, number, paycode, key0
create unique index index1 on apportion_jiedai(pc_id, accnt, number, paycode, key0)
;
drop table apportion_jiedai_old;
//--------------------------
exec sp_rename bankcard, bankcard_old;

create table bankcard
(
	pccode			char(5)	not null,
	bankcode			char(3)	not null,
	commission		money		default 0 not null,		/* 给银行的回扣率(对信用卡有效) */
)
;
insert bankcard select * from bankcard_old
;
exec sp_primarykey bankcard, pccode, bankcode
create unique index index1 on bankcard(pccode, bankcode)
;
drop table bankcard_old;

//------------------------以下为BOS_TABLE
/*

 bos系统 或 第二收银系统 或 简易收银系统  表建构 
 modu = '09'
 客房中心，商务中心 的入账采用此模块
				2001/05/10			

bos_folio			费用单
bos_hfolio
bos_dish
bos_hdish

bos_account			款项
bos_haccount
bos_partout

bos_reason			优惠理由
bos_partfolio		前台补

bos_plu_class        ->>>>>>>>>  什么类别可以填写调价单，sysoption 定义
bos_plu				菜谱
bos_sort

bos_posdef			站点定义
bos_station

bos_mode_name		模式

bos_tblsta			地点
bos_tblav

bos_empno			工号

bos_itemdef			输入定义

bos_extno			商务中心分机
bos_tmpdish			单据输入临时表

bosjie; ybosjie
bosdai; ybosdai

*/


/*
	bos费用汇总表
*/
exec sp_rename bos_folio, bos_folio_old;

create table bos_folio
(
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,	/*本单建立或修改营业日,建立日由foliono识别*/
	bdate1      datetime   	null    ,	/*本单结帐或被冲消营业日*/
	foliono		char(10)	   not null,	/*序列号*/
	sfoliono		varchar(10)	default '' null,
	site			char(5)	   null,			/*地点*/
	sta			char(1)		not null,	/*状态,"M"手工输入未结,"P",电话转入未结, "H",电话转入未输,"O"已结,"C"冲帐,"X"销单,"T"直输总台后补*/
   setnumb     char(10)    null    ,   /*结帐序号*/ 
	modu			char(2)		not null,	/*模块号*/
	pccode		char(5)		not null,	/*费用码*/
	name	   	char(24)		null,			/*费用码描述*/
	posno       char(3)     not null,
	mode	      char(3)		null,			/* 系统码*/

	fee			money	default 0 		not null,   /*费用总额*/
	fee_base	   money	default 0 	   not null,	/*基本费*/
	fee_serve	money	default 0 	   not null,	/*服务费*/
	fee_tax  	money	default 0 	   not null,	/*附加费*/
	fee_disc 	money	default 0 	   not null,	/*折扣费*/

	serve_type 	char(1)	default '0' not null,	/*服务费方式   0:比例 1:金额*/
	serve_value money		default 0   not null,	/*服务费数值*/
	tax_type  	char(1)	default '0' not null,	/*附加费方式   0:比例 1:金额*/
	tax_value  	money		default 0   not null,	/*附加费数值*/
	disc_type   char(1)	default '0' not null,	/*优惠方式   0:比例 1:金额*/
	disc_value	 money	default 0 	not null,	/*优惠比例*/
	reason		char(3)					null,			/*优惠原因*/

	pfee		   money	default 0 	   not null,   /*原费用总额*/
	pfee_base	money	default 0 	   not null,	/*原基本费*/
	pfee_serve	money	default 0 	   not null,	/*原服务费*/
	pfee_tax 	money	default 0 	   not null,	/*原附加费*/

	refer		   varchar(40)	   null,			/*备注 -- 可以放电话号码 */
	empno1		char(10)			not null,	/*录入或修改工号*/
	shift1		char(1)			not null,	/*班号*/
	empno2		char(10)			null,			/*结帐或冲消工号*/
	shift2		char(1)			null,			/*班号*/
	checkout	   char(4)			null,			/*结帐锁定标志位*/
	site0	   	char(5) default '' not null			/**/
)
;
insert bos_folio select * from bos_folio_old
;
exec sp_primarykey bos_folio,foliono
create unique index index1 on bos_folio(foliono)
create unique index index2 on bos_folio(setnumb,foliono)
create index index3 on bos_folio(sta)
;
drop table bos_folio_old;
/*
	bos历史费用汇总表
*/
exec sp_rename bos_hfolio, bos_hfolio_old;

create table bos_hfolio
(
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,	/*本单建立或修改营业日,建立日由foliono识别*/
	bdate1      datetime   	null    ,	/*本单结帐或被冲消营业日*/
	foliono		char(10)	   not null,	/*序列号*/
	sfoliono		varchar(10)	default '' null,
	site			char(5)	   null,			/*地点*/
	sta			char(1)		not null,	/*状态,"M"手工输入未结,"P",电话转入未结, "H",电话转入未输,"O"已结,"C"冲帐, "T"直输总台后补*/
   setnumb     char(10)    null    ,   /*结帐序号*/ 
	modu			char(2)		not null,	/*模块号*/
	pccode		char(5)		not null,	/*费用码*/
	name	   	char(24)		null,			/*费用码描述*/
	posno       char(3)     not null,
	mode	      char(3)		null,			/* 系统码*/

	fee			money	default 0 		not null,   /*费用总额*/
	fee_base	   money	default 0 	   not null,	/*基本费*/
	fee_serve	money	default 0 	   not null,	/*服务费*/
	fee_tax  	money	default 0 	   not null,	/*附加费*/
	fee_disc 	money	default 0 	   not null,	/*折扣费*/

	serve_type 	char(1)	default '0' not null,	/*服务费方式   0:比例 1:金额*/
	serve_value money		default 0   not null,	/*服务费数值*/
	tax_type  	char(1)	default '0' not null,	/*附加费方式   0:比例 1:金额*/
	tax_value  	money		default 0   not null,	/*附加费数值*/
	disc_type   char(1)	default '0' not null,	/*优惠方式   0:比例 1:金额*/
	disc_value	 money	default 0 	not null,	/*优惠比例*/
	reason		char(3)					null,			/*优惠原因*/

	pfee		   money	default 0 	   not null,   /*原费用总额*/
	pfee_base	money	default 0 	   not null,	/*原基本费*/
	pfee_serve	money	default 0 	   not null,	/*原服务费*/
	pfee_tax 	money	default 0 	   not null,	/*原附加费*/

	refer		   varchar(40)	   null,			/*备注*/
	empno1		char(10)			not null,	/*录入或修改工号*/
	shift1		char(1)			not null,	/*班号*/
	empno2		char(10)			null,			/*结帐或冲消工号*/
	shift2		char(1)			null,			/*班号*/
	checkout	   char(4)			null,			/*结帐锁定标志位*/
	site0	   	char(5) default '' not null			/**/
)
;
insert bos_hfolio select * from bos_hfolio_old
;
exec sp_primarykey bos_hfolio,foliono
create unique index index1 on bos_hfolio(foliono)
create unique index index2 on bos_hfolio(setnumb,foliono)
create index index4 on bos_hfolio(bdate1);
create index index3 on bos_hfolio(sta)
;
drop table bos_hfolio_old;
/*
	bos费用明细表
*/
exec sp_rename bos_dish, bos_dish_old;

create table bos_dish
(
	foliono		char(10)	   not null,	/*bos_folio号*/
	id          int         not null,   /*序列号*/       
	sta			char(1)		not null,		/*状态,'M'免;"C"冲帐*/
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,	/*本单建立或修改营业日,建立日由foliono识别*/
	bdate1      datetime   	null    ,	/*本单结帐或被冲消营业日*/
	pccode		char(5)		not null,	/*费用码*/
   code     	char(8)     not null,   /*菜谱明细码*/ 
	name	   	varchar(18)	null,			/*菜谱名称*/
	price       money       not null,   /*单价*/  
	number      money  default 0 not null,   /*数量*/
	unit        char(4)     null,   		/*单位*/  

	fee			money	default 0 		not null,   /*费用总额*/
	fee_base	   money	default 0 	   not null,	/*基本费*/
	fee_serve	money	default 0 	   not null,	/*服务费*/
	fee_tax  	money	default 0 	   not null,	/*附加费*/
	fee_disc 	money	default 0 	   not null,	/*折扣费*/

	serve_type 	char(1)	default '0' not null,	/*服务费方式   0:比例 1:金额*/
	serve_value money		default 0   not null,	/*服务费数值*/
	tax_type  	char(1)	default '0' not null,	/*附加费方式   0:比例 1:金额*/
	tax_value  	money		default 0   not null,	/*附加费数值*/
	disc_type   char(1)	default '0' not null,	/*优惠方式   0:比例 1:金额*/
	disc_value	 money	default 0 	not null,	/*优惠比例*/
	reason		char(3)					null,			/*优惠原因*/

	pfee		   money	default 0 	   not null,   /*原费用总额*/
	pfee_base	money	default 0 	   not null,	/*原基本费*/
	pfee_serve	money	default 0 	   not null,	/*原服务费*/
	pfee_tax 	money	default 0 	   not null,	/*原附加费*/

	refer		   varchar(80)	   null,		/*备注 -- 包含电话的说明 */
	empno1		char(10)		not null,	/*录入或修改工号*/
	shift1		char(1)		not null,	/*班号*/
	empno2		char(10)		null,		/*结帐或冲消工号*/
	shift2		char(1)		null,		/*班号*/
	amount0		money default 0  not null
)
;
insert bos_dish select * from bos_dish_old
;
exec sp_primarykey bos_dish,foliono,id
create unique index index1 on bos_dish(foliono,id)
create index index2 on bos_dish(sta)
;
drop table bos_dish_old;

/*
	bos历史费用明细表
*/
exec sp_rename bos_hdish, bos_hdish_old;

create table bos_hdish
(
	foliono		char(10)	   not null,	/*bos_folio号*/
	id          int         not null,   /*序列号*/       
	sta			char(1)		not null,		/*状态,'M'免;"C"冲帐*/
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,	/*本单建立或修改营业日,建立日由foliono识别*/
	bdate1      datetime   	null    ,	/*本单结帐或被冲消营业日*/
	pccode		char(5)		not null,	/*费用码*/
   code     	char(8)     not null,   /*菜谱明细码*/ 
	name	   	varchar(18)	null,			/*菜谱名称*/
	price       money       not null,   /*单价*/  
	number      money  default 0 not null,   /*数量*/
	unit        char(4)     null,   		/*单位*/  

	fee			money	default 0 		not null,   /*费用总额*/
	fee_base	   money	default 0 	   not null,	/*基本费*/
	fee_serve	money	default 0 	   not null,	/*服务费*/
	fee_tax  	money	default 0 	   not null,	/*附加费*/
	fee_disc 	money	default 0 	   not null,	/*折扣费*/

	serve_type 	char(1)	default '0' not null,	/*服务费方式   0:比例 1:金额*/
	serve_value money		default 0   not null,	/*服务费数值*/
	tax_type  	char(1)	default '0' not null,	/*附加费方式   0:比例 1:金额*/
	tax_value  	money		default 0   not null,	/*附加费数值*/
	disc_type   char(1)	default '0' not null,	/*优惠方式   0:比例 1:金额*/
	disc_value	 money	default 0 	not null,	/*优惠比例*/
	reason		char(3)					null,			/*优惠原因*/

	pfee		   money	default 0 	   not null,   /*原费用总额*/
	pfee_base	money	default 0 	   not null,	/*原基本费*/
	pfee_serve	money	default 0 	   not null,	/*原服务费*/
	pfee_tax 	money	default 0 	   not null,	/*原附加费*/

	refer		   varchar(80)	   null,		/*备注 -- 包含电话的说明 */
	empno1		char(10)		not null,	/*录入或修改工号*/
	shift1		char(1)		not null,	/*班号*/
	empno2		char(10)		null,		/*结帐或冲消工号*/
	shift2		char(1)		null,		/*班号*/
	amount0		money default 0  not null
)
;
insert bos_hdish select * from bos_hdish_old
;
exec sp_primarykey bos_hdish,foliono,id
create unique index index1 on bos_hdish(foliono,id)
create index index2 on bos_hdish(sta)
;
drop table bos_hdish_old;

/*
	商务中心结帐临时款项表
*/

exec sp_rename bos_partout, bos_partout_old;

create table bos_partout
(
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,				/*营业时间*/
	setnumb     char(10)    null    ,   			/*结帐序号*/
	code		   char(5)		not null,				/*内部码*/
	code1	 	   char(5)		not null,				/*外部码*/
	reason	   char(3)		default '' not null,	/*折扣款待理由*/
	name		   char(24)	   null,		   			/*款项码描述*/
	amount		money	default 0 not null,			/*金额*/
	empno		   char(10)		not null,				/*工号*/
	shift		   char(1)		not null,				/*班号*/
	room		   char(5)		null,						/*转帐房号*/
	accnt		   char(10)		null,						/*转帐帐号*/
	tranlog     char(10)    null,						/*协议码*/
	cusno       char(7)     null,						/*单位码*/
	cardno      char(7)     null,						/*卡号*/
	modu			char(2)		null,
	checkout	   char(4)		null						/*结帐锁定标志位*/
)
;
insert bos_partout select * from bos_partout_old
;
exec sp_primarykey bos_partout,checkout,code
create unique index index1 on bos_partout(checkout,code)
;
drop table bos_partout_old;


/*
	商务中心款项表
*/

exec sp_rename bos_account, bos_account_old;

create table bos_account
(
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,				/*营业时间*/
	setnumb     char(10)    null    ,   			/*结帐序号*/
	code		   char(5)		not null,				/*内部码*/
	code1	 	   char(5)		not null,				/*外部码*/
	reason	   char(3)		default '' not null,	/*折扣款待理由*/
	name		   char(24)	   null,		   			/*款项码描述*/
	amount		money	default 0 not null,			/*金额*/
	empno		   char(10)		not null,				/*工号*/
	shift		   char(1)		not null,				/*班号*/
	room		   char(5)		null,						/*转帐房号*/
	accnt		   char(10)		null,						/*转帐帐号*/
	tranlog     char(10)    null,						/*协议码*/
	cusno       char(7)     null,						/*单位码*/
	cardno      char(7)     null,						/*卡号*/
	modu			char(2)		null,
	checkout	   char(4)		null						/*结帐锁定标志位*/
)
;
insert bos_account select * from bos_account_old
;
exec sp_primarykey bos_account,setnumb,code
create unique index index1 on bos_account(setnumb,code)
;
drop table bos_account_old;

/*
	商务中心历史款项表
*/

exec sp_rename bos_haccount, bos_haccount_old;

create table bos_haccount
(
	log_date    datetime    default getdate()   not null,   /*入库日期*/
	bdate    	datetime   	not null,				/*营业时间*/
	setnumb     char(10)    null    ,   			/*结帐序号*/
	code		   char(5)		not null,				/*内部码*/
	code1	 	   char(5)		not null,				/*外部码*/
	reason	   char(3)		default '' not null,	/*折扣款待理由*/
	name		   char(24)	   null,		   			/*款项码描述*/
	amount		money	default 0 not null,			/*金额*/
	empno		   char(10)		not null,				/*工号*/
	shift		   char(1)		not null,				/*班号*/
	room		   char(5)		null,						/*转帐房号*/
	accnt		   char(10)		null,						/*转帐帐号*/
	tranlog     char(10)    null,						/*协议码*/
	cusno       char(7)     null,						/*单位码*/
	cardno      char(7)     null,						/*卡号*/
	modu			char(2)		null,
	checkout	   char(4)		null						/*结帐锁定标志位*/
)
;
insert bos_haccount select * from bos_haccount_old
;
exec sp_primarykey bos_haccount,setnumb,code
create unique index index1 on bos_haccount(setnumb,code)
;
drop table bos_haccount_old;

/////*
////	优惠理由
////*/
////if exists(select * from sysobjects where name = "bos_reason" and type ="U")
////	drop table bos_reason;
////create table bos_reason
////(
////	code		char(3)		not null,	/*代码*/
////	key0		char(3)		not null,	/*refer to reason0*/
////	descript	varchar(16)		not null,	/*描述*/
////	percent	money			not null,	/*比例*/
////	day		money			default 0 	not null,
////	month		money			default 0 	not null,
////	year		money			default 0 	not null,
////)
////exec sp_primarykey bos_reason,code
////create unique index index1 on bos_reason(code)
////;
////insert bos_reason values ('01','A01','徐斌优惠',0,0,0,0)
////insert bos_reason values ('02','A02','何仁尧优惠',0,0,0,0)
////;
//
//
///*
//	总台手工输入费用,bos后补明细对照表
//*/
//if exists(select * from sysobjects where name = "bos_partfolio" and type="U")
//	drop table bos_partfolio;
//
//create table bos_partfolio
//(
//	accnt        char(10) not null,     /*账号*/ 
//	number       int     not null,     /*帐次*/
//	foliono      char(10) not null     /*bos_folio*/
//);
//exec sp_primarykey bos_partfolio,accnt,number 
//create unique index index1 on bos_partfolio(accnt,number);
//create unique index index2 on bos_partfolio(foliono);
//
///*
//	bos菜单 类别
//*/
//if exists(select * from sysobjects where name = "bos_plu_class" and type ="U")
//	drop table bos_plu_class;
//create table bos_plu_class
//(
//   code     	char(3)     	not null,   /*代码*/
//	descript		varchar(18)		not null,	/*描述*/
//	descript1	varchar(30)		null			/*描述*/
//)
//exec sp_primarykey bos_plu_class,code
//create unique index index1 on bos_plu_class(code)
//;
//insert bos_plu_class select '0', '经销', ''
//insert bos_plu_class select '1', '代销', ''
//;
//

/*
	bos菜单
*/
exec sp_rename bos_plu, bos_plu_old;
create table bos_plu
(
	pccode   char(5)		not null,	/*营业点*/
   code     char(8)     not null,   /*代码*/
	name		varchar(18)		not null,	/*描述*/
	ename		varchar(30)		null,			/*描述*/
	helpcode	varchar(10)		null,			/*助记符*/
	standent	varchar(12)		null,			/*规格,废弃!!!*/
	unit		char(4)		null,			/*单位*/
	sort		char(4)		not null,	/*菜类*/
	hlpcode	varchar(8)		null,			/*菜类助记符*/
	price		money			not null,	/*价格*/
	menu		char(4)		not null,	/*早,中,晚,夜的共享*/
   dscmark  char(1)     null,       /*折扣特优码标志*/
	surmark  char(1)     null,       /*T:需收服务费,F:不收服务费*/
	taxmark  char(1)     null,       /*T:需收附加税,F:不收附加税*/
	discmark char(1)     null,       /*T:可打折,F:不打折*/
	provider	char(7)		default '' null,
	number	money	default 0 not null,  // 库存数量和金额
	amount	money default 0 not null,
	site		varchar(8) default '' null,  // 存放地点
	class		char(3)	 	not null			// 类别
)
;
insert bos_plu select * from bos_plu_old
;
exec sp_primarykey bos_plu,pccode,code
create unique index index1 on bos_plu(pccode,code)
// create unique index index2 on bos_plu(pccode,name)
create index index3 on bos_plu(pccode,helpcode)
;
drop table bos_plu_old;

/*
	bos菜类
*/

exec sp_rename bos_sort, bos_sort_old;
create table bos_sort
(
	pccode		char(5)			not null,	/*营业点*/
	sort			char(8)			not null,	/*类别*/
	name			varchar(12)		not null,	/*描述*/
	ename			varchar(20)		null,			/*描述*/
	hlpcode		varchar(8)		null,			/*助记符*/
	surmark     char(1)     	null,       /*T:需收服务费,F:不收服务费*/
	taxmark     char(1)     	null,       /*T:需收附加税,F:不收附加税*/
	discmark    char(1)     	null,       /*T:可打折,F:不打折*/
)
;
insert bos_sort select * from bos_sort_old
;
exec sp_primarykey bos_sort,pccode,sort
create unique index index1 on bos_sort(pccode,sort)
create unique index index2 on bos_sort(pccode,name)
;
drop table bos_sort_old;

/*
	收银点表,定义每个收银点管辖的营业点
*/

exec sp_rename bos_posdef, bos_posdef_old;
create table bos_posdef
(
	posno			char(2)				not null,	/*收银点码*/
	modu			char(2)				not null,	/*模块号*/
	mode			char(1)				not null,	/*0-all, 1-folio, 2-dish*/
	descript		varchar(20)			not null,	/*收银点名*/
	descript1	varchar(20)			not null,	/*收银点名*/
   pccodes		varchar(120)		null,	 	   /*营业点集合*/		
	fax1			char(5)				null,			/*发送传真的费用码 国内*/
	fax2			char(5)				null,			/*发送传真的费用码 国际*/
	sites			varchar(100) default ''	not null			/*柜台号码*/
)
;
insert bos_posdef select * from bos_posdef_old
;
exec sp_primarykey bos_posdef,posno,modu
create unique index index1 on bos_posdef(posno,modu)
;
drop table bos_posdef_old
;

///*
//	工作站表
//*/
//if exists(select * from sysobjects where name = "bos_station" and type ="U")
//	drop table bos_station;
//create table bos_station
//(
//	netaddress	char(4)		not null,	/*网络地址*/
//	posno			char(2)		not null,	/*收银点*/
//   printer		char(1)		not null,	/*多次打单."T"/"F"*/
//	adjuhead		int			default 0	not null,	/*打印调整*/
//	adjurow		int			default 0	not null,	/*打印调整*/
//)
//exec sp_primarykey bos_station,netaddress,posno
//create unique index index1 on bos_station(netaddress,posno)
//;
//insert bos_station(netaddress,posno,printer)
//	values('1.01', '01', 'T')
//;
//
//
///*
//	模式代码及描述
//*/
//if exists(select * from sysobjects where name = "bos_mode_name" and type ="U")
//	drop table bos_mode_name;
//
//create table bos_mode_name
//(
//	code			char(3)			not null,	/*代码*/
//	descript		varchar(20)		not null,	/*中文名称*/
//	descript1	varchar(30)		null,			/*英文名称*/
//	remark		varchar(255)	null,			/*描述*/
//)
//exec sp_primarykey bos_mode_name,code
//create unique index index1 on bos_mode_name(code)
//;
//
//
///*
//	地点
//*/
//if exists(select * from sysobjects where name = "bos_tblsta" and type ="U")
//	drop table bos_tblsta;
////create table bos_tblsta
////(
////	tableno		char(4)		not null,							/*桌号*/
////	type			char(3)		null,									/*类别*/
////	pccode		char(5)		not null,							/*营业点*/
////	descript1	char(10)		null,									/*描述1*/
////	descript2	char(10)		null,									/*描述2*/
////	maxno			integer		default	0	not null,			/*席位数*/
////	sta			char(1)		default	'N'	not null,
////	mode			char(1)		default	'0'	not null,		/*最低消费模式*/
////	amount		money			default	0	not null,			/*最低消费金额*/
////	code			char(15)		default '' not null				/*零头去向*/
////)
////exec sp_primarykey bos_tblsta,tableno
////create unique index index1 on bos_tblsta(tableno)
////create index index2 on bos_tblsta(pccode, tableno)
////;
//
///*
//	席位状态表
//*/
//if exists(select * from sysobjects where name = "bos_tblav" and type ="U")
//	drop table bos_tblav;
////create table bos_tblav
////(
////	menu				char(10)		not null,								/*主单号*/
////	tableno			char(4)		not null,								/*桌号*/
////	id					integer		default 0 not null,
////	bdate				datetime		not null,								/*日期*/
////	shift				char(1)		not null,								/*班号*/
////	sta				char(1)		not null,								/*状态*/
////	begin_time		datetime		default	getdate()	not null,	/*计时开始时间*/
////	end_time			datetime		null										/*计时截止时间*/
////)
////exec sp_primarykey bos_tblav,menu,tableno,id
////create unique index index1 on bos_tblav(menu,tableno,id)
////;
//
///*
//	BOS 工号定义
//*/
//if exists(select * from sysobjects where name = "bos_empno" and type ="U")
//	drop table bos_empno;
//create table bos_empno
//(
//	empno		char(10)		not null,	/*工号*/
//	name		char(20)		not null,	/*姓名*/
//)
//exec sp_primarykey bos_empno,empno
//create unique index index1 on bos_empno(empno)
//;
//
///*
//	BOS 入账界面子项定义
//*/
//if exists(select * from sysobjects where name = "bos_itemdef" and type ="U")
//	drop table bos_itemdef;
//create table bos_itemdef
//(
//	posno		char(2)			not null,	/*收银点   ZZ = 客房中心快速入账定义《系统内定》*/
//	define	varchar(20)		null			/*不显示的定义*/
//)
//exec sp_primarykey bos_itemdef,posno
//create unique index index1 on bos_itemdef(posno)
//;
//
//
///*
//	商务中心分机设定
//*/
//if exists(select * from sysobjects where name = "bos_extno" and type ="U")
//	drop table bos_extno;
//create table bos_extno
//(
//	code		char(8)			not null,
//	posno		char(2)			not null
//)
//exec sp_primarykey bos_extno,code
//create unique index index1 on bos_extno(code)
//;
//
///*
//	bos 临时表
//*/
//if exists(select * from sysobjects where name = "bos_tmpdish" and type="U")
//	drop table bos_tmpdish;
//
//create table bos_tmpdish
//(
//	modu_id		char(2)		not null,
//	pc_id			char(4)		not null,
//	id          int         not null,      /*序列号*/
//	sta			char(1)		not null,		/*状态,'I'=正常 'M'=免 "C"=冲帐 */
//   code     	char(8)     not null,   /*菜谱明细码*/ 
//	name	   	varchar(18)	null,			/*菜谱名称*/
//	price       money       not null,   /*单价*/  
//	number      money  default 0 not null,   /*数量*/
//	unit        char(4)     null,   		/*单位*/  
//	pfee_base	money	default 0 	   not null,	/*原基本费*/
//	serve_type 	char(1)	default '0' not null,	/*服务费方式   0:比例 1:金额*/
//	serve_value money		default 0   not null,	/*服务费数值*/
//	tax_type  	char(1)	default '0' not null,	/*附加费方式   0:比例 1:金额*/
//	tax_value  	money		default 0   not null,	/*附加费数值*/
//	disc_type   char(1)	default '0' not null,	/*优惠方式   0:比例 1:金额*/
//	disc_value	 money	default 0 	not null		/*优惠比例*/
//)
//exec sp_primarykey bos_tmpdish,modu_id, pc_id, id
//create unique index index1 on bos_tmpdish(modu_id, pc_id, id)
//;
//
exec sp_rename bosjie, bosjie_old;
create table bosjie
(
   date          datetime default getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	code          char(5)  default '' not null,
	descript      char(24)  default '' not null,
	fee_bas       money    default 0  not null,
	fee_sur       money    default 0  not null,
	fee_tax       money    default 0  not null,
	fee_dsc	      money    default 0  not null,
	fee_ent	      money    default 0  not null,
	fee_ttl	      money    default 0  not null,
	fee_basm      money    default 0  not null,
	fee_surm      money    default 0  not null,
	fee_taxm      money    default 0  not null,
	fee_dscm      money    default 0  not null,
	fee_entm      money    default 0  not null,
	fee_ttlm      money    default 0  not null,
	daymark       char(1)  default '' not null
)
;
insert bosjie select * from bosjie_old
;
exec sp_primarykey bosjie,shift,empno,code
create unique index index1 on bosjie(shift,empno,code)
;
drop table bosjie_old
;
exec sp_rename ybosjie, ybosjie_old;
create table ybosjie
(
   date          datetime default getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	code          char(5)  default '' not null,
	descript      char(24)  default '' not null,
	fee_bas       money    default 0  not null,
	fee_sur       money    default 0  not null,
	fee_tax       money    default 0  not null,
	fee_dsc	     money    default 0  not null,
	fee_ent	     money    default 0  not null,
	fee_ttl	     money    default 0  not null,
	fee_basm      money    default 0  not null,
	fee_surm      money    default 0  not null,
	fee_taxm      money    default 0  not null,
	fee_dscm      money    default 0  not null,
	fee_entm      money    default 0  not null,
	fee_ttlm      money    default 0  not null,
	daymark       char(1)  default '' not null
)
;
insert ybosjie select * from ybosjie_old
;
exec sp_primarykey ybosjie,date,shift,empno,code;
create unique index index1 on ybosjie(date,shift,empno,code)
;
drop table ybosjie_old;

exec sp_rename bosdai, bosdai_old;
create table bosdai
(
   date          datetime default    getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	paycode       char(5)  default '' not null,
	paytail       char(1)  default '' not null,
	descript1     char(5)  default '' not null,
	descript      char(12) default '' not null,
	creditd       money    default 0  not null,
	creditm       money    default 0  not null,
	daymark       char(1)  default '' not null
)
;
insert bosdai select * from bosdai_old
;
exec sp_primarykey bosdai,shift,empno,paycode,paytail
create unique index index1 on bosdai(shift,empno,paycode,paytail)
;
drop table bosdai_old;

exec sp_rename ybosdai, ybosdai_old;
create table ybosdai
(
   date          datetime default    getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	paycode       char(5)  default '' not null,
	paytail       char(1)  default '' not null,
	descript1     char(5)  default '' not null,
	descript      char(12) default '' not null,
	creditd       money    default 0  not null,
	creditm       money    default 0  not null,
	daymark       char(1)  default '' not null
)
;
insert ybosdai select * from ybosdai_old
;
exec sp_primarykey ybosdai,date,shift,empno,paycode,paytail
create unique index index1 on ybosdai(date,shift,empno,paycode,paytail)
;
drop table ybosdai_old;
//------------------------以上为BOS_TABLE
// -----------------------以下为BOS_KCTABLE
//		BOS 库存管理表定义
//
//			bos_pccode
//
//			bos_provider_class
//			bos_provider_mkt
//			bos_provider			
//
//			payment
//
//			bos_site
//			bos_site_sort
//
//			bos_kcmenu
//			bos_kcdish
//			bos_store
//			bos_hstore
//
//			bos_detail
//			bos_hdetail
//			bos_tmpdetail 
// ------------------------------------------------------------------------------
//		经销  &  代销 ：本质区别-- 代销可以修改成本价 !
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------
//	bos_pccode	:  BOS 营业点定义
// ------------------------------------------------------------------------------------
exec sp_rename bos_pccode, bos_pccode_old;
create table bos_pccode
(
	pccode		char(5)					not null,
	descript		varchar(24)				not null,
	descript1	varchar(24)				not null,
	sortlen		int default 2 			not null,	// 菜谱类别码的长度
	site			int default 0  		not null,  	// 是否有地点的管理: 0-无; 1-客房; 2-其他
	jxc			int default 0  		not null,  	// 是否有进销存管理: 0-no, 1-yes
	smode			char(1)	default '%' not null,	// 服务费   -- 却省值
	svalue		money		default 0 	not null,
	tmode			char(1)	default '%' not null,	// 附加费
	tvalue		money		default 0 	not null,
	dmode			char(1)	default '%' not null,	// 折扣
	dvalue		money		default 0 	not null,
	site0			char(5)	 				not null,	// 却省的地点
	tag			char(1)	default ''	not null,	// S=shop
	chgcod		char(5)					not null		//  code in pccode
)
;
insert bos_pccode select * from bos_pccode_old
;
exec sp_primarykey bos_pccode, pccode
create unique index index1 on bos_pccode(pccode)
create unique index index2 on bos_pccode(chgcod)
;
drop table bos_pccode_old;


//// ------------------------------------------------------------------------------
////  供应商 CLASS
//// ------------------------------------------------------------------------------
//if exists(select * from sysobjects where type ="U" and name = "bos_provider_class")
//	drop table bos_provider_class;
//create table bos_provider_class
//(
//	code			char(1)	default '1' not null,					// 代码 
//	descript		char(20)					not null,					// 描述 
//	descript1	char(20)	default ''	not null
//)
//exec sp_primarykey bos_provider_class, code
//create unique index index1 on bos_provider_class(code)
//;
//insert bos_provider_class select 'N', '普通供应商',''
//insert bos_provider_class select 'V', 'VIP供应商',''
//;
//
//// ------------------------------------------------------------------------------
//// bos_provider_mkt	供应商市场码
//// ------------------------------------------------------------------------------
//if exists(select * from sysobjects where name = "bos_provider_mkt")
//   drop table bos_provider_mkt;
//create table bos_provider_mkt
//(
//	code			char(5)			not null,		// 代码 
//	descript    varchar(30)		not null, 		// 描述 
//	descript1   varchar(30)		not null, 		// 描述 
//	remark    	varchar(30)		not null 		// 描述 
//)
//exec sp_primarykey bos_provider_mkt,code
//create unique index index1 on bos_provider_mkt(code);
//insert bos_provider_mkt select 'A', '市内', 'CITY',''
//insert bos_provider_mkt select 'B', '其他', 'OTHER',''
//;
//
//
//// ------------------------------------------------------------------------------------
//// bos_provider ----- 供应商代码
//// ------------------------------------------------------------------------------------
//if exists(select * from sysobjects where name = "bos_provider")
//	drop table bos_provider;
//create table bos_provider
//(
//	accnt			char(7)		not null,			//帐号:主键
//	sta			char(1)		not null,			//状态 I, O, 
//	nation      char(3) 		not null,       	//国籍
//	name			varchar(50)	not null,			//名称
//	address  	varchar(60)	null,					//地址
//	phone			varchar(30)	null,					//电话
//	fax  			varchar(20)	null,					//传真
//	zip  			char(10)		null,					//邮编
//	c_name		varchar(40)	null,					//联系人
//	intinfo		varchar(50)	null,					//互联网信息
//	class			char(1)		null,					//级别:
//	locksta     char(1)     null,       		//信用状态
//	limit			money			default 0 	not null,	//限额(催帐用)
//	arr			datetime		null,					//生效日期
//	dep			datetime		null,					//有效日期,到明日为止
//   mkt     		char(5)     null,       		//市场码
//	pccodes		varchar(20)	default '' not null,  //费用码范围
//	resby			char(10)		not null,					//建立人工号
//	reserved		datetime	default getdate() not null, //建立时间,用系统时间,不可修改
//	cby			char(10)		null,							//修改人工号
//	changed		datetime		null,							//修改时间
//	ref			varchar(90)	null,							//备注
//	exp_m			money				null,
//	exp_dt		datetime			null,
//	exp_s			varchar(10)		null,
//	logmark     int default 0 not null
//);
//exec sp_primarykey bos_provider,accnt
//create unique index index1 on bos_provider(accnt)
//create index index2 on bos_provider(name)
//;
//
//
// ------------------------------------------------------------------------------------
// payment ----- 结算纪录
// ------------------------------------------------------------------------------------
exec sp_rename payment, payment_old;
create table payment
(
	accnt			char(7)		not null,					//帐号:主键
	number		int			not null,			
	sta			char(1)		not null,					//状态 I, C
	bdate			datetime		not null,					//营业日期
	date			datetime		not null,					//交易日期
	paycode		char(5)		not null,					//付款方式
	amount		money		default 0	not null,	
	payref		varchar(20)	default '' null,			//付款备注
	resman		varchar(50)	default '' null,
	sndman		varchar(50)	default '' null,
	ref			varchar(90)	null,							//备注
	resby			char(10)		not null,					//建立人工号
	reserved		datetime	default getdate() not null, //建立时间,用系统时间,不可修改
	cby			char(10)		null,							//修改人工号
	changed		datetime		null,							//修改时间
	logmark     int default 0 not null
)
;
insert payment select * from payment_old
;
exec sp_primarykey payment,accnt,number
create unique index index1 on payment(accnt,number)
;
drop table payment_old;

//------------------------------------------------------------------------------
// 地点码 -- 仓库，柜台，其他部门 等
//------------------------------------------------------------------------------
exec sp_rename bos_site, bos_site_old;
create table  bos_site (
	pccode	char(5)			not null,
	tag		char(2)			not null, 	// 类别:仓(仓库) - 柜(柜台) - 部(内部部门)
	site		char(5)			not null,  	// --- 注意： 内部部门本来与 pccode 无关，但是
	name		varchar(24)		not null		//  	有可能分开编辑可能更好，
													//		此时最好统一部门在不同的pccode 中，site 一致
)
;
insert bos_site select * from bos_site_old
;
exec sp_primarykey bos_site,site
create unique index site on bos_site(site);
;
drop table bos_site_old;

////------------------------------------------------------------------------------
//// 地点的售货定义：定义该地点能够出售什么物品 
////------------------------------------------------------------------------------
//if exists (select 1 from sysobjects where name = 'bos_site_sort')
//	drop table bos_site_sort;
//create table  bos_site_sort (
//	site		char(5)			not null,
//	sort		varchar(20)	default '%' not null
//);
//exec sp_primarykey bos_site_sort,site,sort
//create unique index site on bos_site_sort(site,sort)
//;
//insert bos_site_sort select site,'%' from bos_site;
//
//------------------------------------------------------------------------------
//		
//		物品流动单据主库  ------- 当前
//		主单类型: 入<出>库, 损耗, 冲销, 盘存, 调拨
//
//		这里的单据号码由电脑单号和手工单号组成
//			单据只能“建立”和“冲销当日”，所以不需要LOG字段
//			冲销单据时,改变状态,填满冲销字段即可;
//
//------------------------------------------------------------------------------

// 主表
exec sp_rename bos_kcmenu, bos_kcmenu_old
;
create table  bos_kcmenu (
	folio		char(10)			not null,				// 电脑单号(日期+流水号)
	pccode 	char(5)			not null,
	sfolio	varchar(20),								// 手工号码
	site0		char(5)			not null,				// 原始地点
	site1		char(5)	default '' not null,  		// 地点
	act_date	datetime			not null,				// 业务发生日期
	bdate		datetime			not null,				// 营业日期
	flag		char(2)			not null,				// 主单类型: 入<出>库, 损耗, 冲销, 盘存, 调拨
	sta		char(1)			not null,				// 状态== I, X, O, D
	tag1		char(2)			null,						// 损耗原因
	tag2		char(2)			null,						// 保留字段
	tag3		char(10)			null,						// 保留字段
	tag4		char(10)			null,						// 保留字段
	amount	money	default 0 not null,				// 总金额
	refer		varchar(50)		null,						// 备注
	sby		char(10)			null,						// 审核
	sdate		datetime			null,
	cby		char(10)			not null,				// 创建
	cdate		datetime	default getdate()	not null,
	dby		char(10)			null,						// 冲销	
	ddate		datetime			null,
	dreason	varchar(20)		null,						// 冲销原因
	pc_id		char(4)			null,						// 独占标志
	logmark	int default 0	not null
)
;
insert bos_kcmenu select * from bos_kcmenu_old
;
exec sp_primarykey bos_kcmenu, folio
create unique index fno on bos_kcmenu(folio)
create index sfno on bos_kcmenu(sfolio)
create index cby on bos_kcmenu(cby, folio)
create index bdate on bos_kcmenu(bdate, folio)
create index actdate on bos_kcmenu(act_date, folio)
;
drop table bos_kcmenu_old;
//
////------------------------------------------------------------------------------
//// 明细单据  -- 要求同单据，代码唯一
////				其他情况开新单
////------------------------------------------------------------------------------
//if exists (select 1 from sysobjects where name = 'bos_kcdish')
//	drop table bos_kcdish
//;
//create table  bos_kcdish (
//	folio		char(10)			not null,				// 电脑单号(日期+流水号)
//	code		char(8)			not null,				// 代码
//	name		varchar(18)		null,						
//	number	money	default 0 not null,				// 数量
//	price		money	default 0 not null,				// 进价
//	amount	money	default 0 not null,				// 成本金额
//	price1	money	default 0 not null,				// 销售单价
//	amount1	money	default 0 not null,				// 销售金额
//	profit	money	default 0 not null,				// 进销差价
//	ref		varchar(20)		null						// 备注
//)
//exec sp_primarykey bos_kcdish, folio, code
//create unique index code on bos_kcdish(folio,code)
//;
//// ----------> 老版本的结构修改 sql 如下
////exec sp_rename 'bos_kcdish.number0', price1;
////exec sp_rename 'bos_kcdish.price0', amount1;
////exec sp_rename 'bos_kcdish.amount0', profit;
//
//
//------------------------------------------------------------------------------
//	各点存货纪录报告  ---  实时信息
//------------------------------------------------------------------------------
exec sp_rename bos_store, bos_store_old
;
create table  bos_store (
	id			char(6)		not null,
	pccode	char(5)		not null,
	site		char(5)		not null,			// 存货点
	code		char(8)		not null,			// 代码
	number0	money	default 0	not null,	// 上期结余
	amount0	money	default 0 	not null,	// 
	sale0		money	default 0 	not null,	// 
	profit0	money	default 0 	not null,	// 
	number1	money	default 0	not null,	// 入库
	amount1	money	default 0 	not null,	// 
	sale1		money	default 0 	not null,	// 
	profit1	money	default 0 	not null,	// 
	number2	money	default 0	not null,	// 损耗
	amount2	money	default 0 	not null,	// 
	sale2		money	default 0 	not null,	// 
	profit2	money	default 0 	not null,	// 
	number3	money	default 0	not null,	// 盘存
	amount3	money	default 0 	not null,	// 
	sale3		money	default 0 	not null,	// 
	profit3	money	default 0 	not null,	// 
	number4	money	default 0	not null,	// 调拨
	amount4	money	default 0 	not null,	// 
	sale4		money	default 0 	not null,	// 
	profit4	money	default 0 	not null,	// 
	number5	money	default 0	not null,	// 销售
	amount5	money	default 0 	not null,	// 
	sale5		money	default 0 	not null,	// 
	disc		money	default 0 	not null,	// 
	profit5	money	default 0 	not null,	// 
	number6	money	default 0	not null,	// 领料
	amount6	money	default 0 	not null,	// 
	sale6		money	default 0 	not null,	// 
	profit6	money	default 0 	not null,	// 
	number7	money	default 0	not null,	// 调成本价
	amount7	money	default 0 	not null,	// 
	sale7		money	default 0 	not null,	// 
	profit7	money	default 0 	not null,	// 
	number8	money	default 0	not null,	// 调销售价
	amount8	money	default 0 	not null,	// 
	sale8		money	default 0 	not null,	// 
	profit8	money	default 0 	not null,	// 
	number9	money	default 0	not null,	// 余额
	amount9	money	default 0 	not null,	// 
	sale9		money	default 0 	not null,	// 
	profit9	money	default 0 	not null,	// 
	price0	money	default 0 	not null,	// 进价
	price1	money	default 0 	not null		// 售价
)
;
insert bos_store select * from bos_store_old
;
exec sp_primarykey bos_store, pccode,site,code
create unique index siteno on bos_store(pccode,site,code)
;
drop table bos_store_old;

//------------------------------------------------------------------------------
//	各点存货纪录报告  ---  历史信息
//------------------------------------------------------------------------------
exec sp_rename bos_hstore, bos_hstore_old
;
create table  bos_hstore (
	id			char(6)		not null,
	pccode	char(5)		not null,
	site		char(5)		not null,			// 存货点
	code		char(8)		not null,			// 代码
	number0	money	default 0	not null,	// 上期结余
	amount0	money	default 0 	not null,	// 
	sale0		money	default 0 	not null,	// 
	profit0	money	default 0 	not null,	// 
	number1	money	default 0	not null,	// 入库
	amount1	money	default 0 	not null,	// 
	sale1		money	default 0 	not null,	// 
	profit1	money	default 0 	not null,	// 
	number2	money	default 0	not null,	// 损耗
	amount2	money	default 0 	not null,	// 
	sale2		money	default 0 	not null,	// 
	profit2	money	default 0 	not null,	// 
	number3	money	default 0	not null,	// 盘存
	amount3	money	default 0 	not null,	// 
	sale3		money	default 0 	not null,	// 
	profit3	money	default 0 	not null,	// 
	number4	money	default 0	not null,	// 调拨
	amount4	money	default 0 	not null,	// 
	sale4		money	default 0 	not null,	// 
	profit4	money	default 0 	not null,	// 
	number5	money	default 0	not null,	// 销售
	amount5	money	default 0 	not null,	// 
	sale5		money	default 0 	not null,	// 
	disc		money	default 0 	not null,	// 
	profit5	money	default 0 	not null,	// 
	number6	money	default 0	not null,	// 领料
	amount6	money	default 0 	not null,	// 
	sale6		money	default 0 	not null,	// 
	profit6	money	default 0 	not null,	// 
	number7	money	default 0	not null,	// 调成本价
	amount7	money	default 0 	not null,	// 
	sale7		money	default 0 	not null,	// 
	profit7	money	default 0 	not null,	// 
	number8	money	default 0	not null,	// 调销售价
	amount8	money	default 0 	not null,	// 
	sale8		money	default 0 	not null,	// 
	profit8	money	default 0 	not null,	// 
	number9	money	default 0	not null,	// 余额
	amount9	money	default 0 	not null,	// 
	sale9		money	default 0 	not null,	// 
	profit9	money	default 0 	not null,	// 
	price0	money	default 0 	not null,	// 进价
	price1	money	default 0 	not null		// 售价
)
;
insert bos_hstore select * from bos_hstore_old
;
exec sp_primarykey bos_hstore,id,pccode,site,code
create unique index siteno on bos_hstore(id,pccode,site,code)
;
drop table bos_hstore_old;

//------------------------------------------------------------------------------
//		物品流动明细账 --- 当前
//------------------------------------------------------------------------------
exec sp_rename bos_detail, bos_detail_old;
create table  bos_detail (
	pccode 	char(5)			not null,
	site		char(5)			not null,				// 地点
	code		char(8)			not null,				// 代码
	id			char(6)			not null,				// 帐务周期
	ii			int				not null,				// 帐务序号
	flag		char(2)			not null,				// 单据类型 -- 入/领/损/调/盘/售/内/外   -- + 续
	descript	varchar(20)		null,						// 描述: 售-表明客房/续-起初余额
	folio		char(10)			not null,				// 电脑单号(日期+流水号)
	sfolio	varchar(20)		null,						// 手工号码
	fid		int	default 0	not null,			// 帐务序号
	rsite		char(5)	default '' not null,  		// 相关地点
	bdate		datetime			not null,				// 营业日期
	act_date	datetime			not null,				// 业务发生日期
	log_date	datetime			not null,				// 电脑入账日期
	empno		char(10)			null,						// 

	number	money	default 0 not null,				// 数量		-------- 当前业务
	amount0	money	default 0 not null,				// 进价
	amount	money	default 0 not null,				// 售价
	disc		money	default 0 not null,				// 折扣
	profit	money	default 0 not null,				// 进销差价

	gnumber	money	default 0 not null,				// 数量		---------  余额
	gamount0	money	default 0 not null,				// 进价
	gamount	money	default 0 not null,				// 售价
	gprofit	money	default 0 not null,				// 进销差价

	price0	money	default 0 not null,				// 进价
	price1	money	default 0 not null,				// 售价
)
;
insert bos_detail select * from bos_detail_old
;
exec sp_primarykey bos_detail,pccode,site,code,ii
create unique index index1 on bos_detail(pccode,site,code,ii)
create index sfno on bos_detail(sfolio)
create index fno on bos_detail(folio)
create index bdate on bos_detail(bdate)
create index actdate on bos_detail(act_date)
create index code on bos_detail(code,folio)
create index empno on bos_detail(empno,folio)
;
drop table bos_detail_old;

//------------------------------------------------------------------------------
//		物品流动明细账 --- 历史
//------------------------------------------------------------------------------
exec sp_rename bos_hdetail, bos_hdetail_old;
create table  bos_hdetail (
	pccode 	char(5)			not null,
	site		char(5)			not null,				// 地点
	code		char(8)			not null,				// 代码
	id			char(6)			not null,				// 帐务周期
	ii			int				not null,				// 帐务序号
	flag		char(2)			not null,				// 单据类型 -- 入/领/损/调/盘/售/内/外   -- + 续
	descript	varchar(20)		null,						// 描述: 售-表明客房/续-起初余额
	folio		char(10)			not null,				// 电脑单号(日期+流水号)
	sfolio	varchar(20)		null,						// 手工号码
	fid		int	default 0	not null,			// 帐务序号
	rsite		char(5)	default '' not null,  		// 相关地点
	bdate		datetime			not null,				// 营业日期
	act_date	datetime			not null,				// 业务发生日期
	log_date	datetime			not null,				// 电脑入账日期
	empno		char(10)			null,						// 

	number	money	default 0 not null,				// 数量		-------- 当前业务
	amount0	money	default 0 not null,				// 进价
	amount	money	default 0 not null,				// 售价
	disc		money	default 0 not null,				// 折扣
	profit	money	default 0 not null,				// 进销差价

	gnumber	money	default 0 not null,				// 数量		---------  余额
	gamount0	money	default 0 not null,				// 进价
	gamount	money	default 0 not null,				// 售价
	gprofit	money	default 0 not null,				// 进销差价

	price0	money	default 0 not null,				// 进价
	price1	money	default 0 not null,				// 售价
)
;
insert bos_hdetail select * from bos_hdetail_old
;
exec sp_primarykey bos_hdetail,id,pccode,site,code,ii
create unique index index1 on bos_hdetail(id,pccode,site,code,ii)
create index sfno on bos_hdetail(sfolio)
create index fno on bos_hdetail(folio)
create index bdate on bos_hdetail(bdate)
create index actdate on bos_hdetail(act_date)
create index code on bos_hdetail(code,folio)
create index empno on bos_hdetail(empno,folio)
;
drop table bos_hdetail_old;

//// ------------------------------------------------------------------------------
//// 临时表 === 明细账来源 --- 物流单据 和 销售单据 
//// ------------------------------------------------------------------------------
//if exists (select 1 from sysobjects where name = 'bos_tmpdetail' and type='U')
//	drop table bos_tmpdetail;
//create table bos_tmpdetail 
//(
//	modu_id	char(2)			not null,
//	pc_id		char(4)			not null,
//	folio		char(10)			not null,				// 电脑单号(日期+流水号)
//	sfolio	varchar(20),								// 手工号码
//	site		char(5)	default '' not null,  		// 地点
//	rsite		char(5)	default '' not null,  		// 相关地点
//	act_date	datetime			not null,				// 业务发生日期
//	bdate		datetime			not null,				// 营业日期
//	flag		char(2)			not null,				// 主单类型: 入<出>库, 损耗, 冲销, 盘存, 调拨
//	cby		char(10)			not null,				// 创建
//	cdate		datetime	default getdate()	not null,
//	fid		int				not null,				// 物流单据=0  销售单据=id
//	code		char(8)			not null,				// 代码
//	number	money	default 0 not null,				// 数量
//	amount	money	default 0 not null,				// 成本金额
//	amount1	money	default 0 not null,				// 销售金额
//	disc		money	default 0 not null,				// 折扣
//	profit	money	default 0 not null,				// 进销差价
//	ref		varchar(20)		null						// 备注
//)
//exec sp_primarykey bos_tmpdetail,modu_id,pc_id,folio,site,code,fid
//create unique index index1 on bos_tmpdetail(modu_id,pc_id,folio,site,code,fid)
//;
// -----------------------以上为BOS_KCTABLE
// -----------------------以下为BOS_HS_INPUT
exec sp_rename bos_trans, bos_trans_old;
create table  bos_trans
(
	modu_id			char(2)				not null,
	pc_id				char(4)				not null,
	pccode			char(5)				not null,
	mode			 	char(3)				null,
   pfee_base	 	money	default 0 	not null,
   serve_type	 	char	default '0'	not null,
   serve_value	 	money	default 0 	not null,
   tax_type	 		char	default '0'	not null,
   tax_value	 	money	default 0 	not null,
   disc_type	 	char	default '0'	not null,
   disc_value	 	money	default 0 	not null,
	reason			char(3)				null
)
;
insert bos_trans select * from bos_trans_old
;
exec sp_primarykey bos_trans, modu_id, pc_id, pccode
create unique index index1 on bos_trans(modu_id, pc_id, pccode)
;
drop table bos_trans_old;
// -----------------------以上为BOS_HS_INPUT
// -----------------------以下为BOS_SHIFT
--		shiftbosjie
--		shiftbosdai
--
--		bos_jie
--		bos_dai
--		bos_jiedai
--
--		p_gds_bos_shiftrep
--		p_gds_bos_shiftrep_exp
--
-- ------------------------------------------------------------------------------

--   
--	BOS 交班表 
--


exec sp_rename shiftbosjie, shiftbosjie_old;
create table shiftbosjie
(
	modu_id       char(2)	not null,
	pc_id         char(4)	not null,
	order_        int      default 0	,
	date          datetime default getdate(),
	code          char(5)  default '' not null,
	descript      char(24)  default '' not null,
	fee_bas       money    default 0  not null,
	fee_sur       money    default 0  not null,
	fee_tax       money    default 0  not null,
	fee_dsc	     money    default 0  not null,
	fee_ent	     money    default 0  not null,
	fee_ttl	     money    default 0  not null
)
;
insert shiftbosjie select * from shiftbosjie_old
;
exec sp_primarykey shiftbosjie,modu_id,pc_id,code
create unique index index1 on shiftbosjie(modu_id,pc_id,code)
;
drop table shiftbosjie_old;

exec sp_rename shiftbosdai, shiftbosdai_old;
create table shiftbosdai
(
	modu_id       char(2)	not null,
	pc_id         char(4)	not null,
	order_        int      default 0,
	date          datetime default    getdate(),
	paycode       char(5)  default '' not null,
	paytail       char(1)  default '' not null,
	descript1     char(5)  default '' not null,
	descript      char(24) default '' not null,
	creditd       money    default 0  not null
)
;
insert shiftbosdai select * from shiftbosdai_old
;
exec sp_primarykey shiftbosdai,modu_id,pc_id,paycode,paytail
create unique index index1 on shiftbosdai(modu_id,pc_id,paycode,paytail)
;
drop table shiftbosdai_old;

--  
--	交班表统计临时表
--
exec sp_rename bos_jie, bos_jie_old;
create table bos_jie
(
	modu_id  char(2) not null,
   pc_id    char(4) not null,
	jiecode  char(5) not null,            --  借项  
	amount   money   default 0 not null,  --  基本费
	smount   money   default 0 not null,  --  服务费
	tmount   money   default 0 not null,  --  附加费
	pmount   money   default 0 not null,  --  百分比折扣
	dmount   money   default 0 not null,  --  贷扣
	emount   money   default 0 not null   --  款待
)
;
insert bos_jie select * from bos_jie_old
;
exec sp_primarykey bos_jie,modu_id,pc_id,jiecode
create unique index index1 on bos_jie (modu_id,pc_id,jiecode)
;
drop table bos_jie_old;

exec sp_rename bos_dai, bos_dai_old;
create table bos_dai
(
	modu_id       char(2) not null,
   pc_id       char(4) not null,
   daicode     char(5) not null,      --  贷项 
   daitail     char(1) default '',    --  贷项补钉 
   distribute  char(4) default '',    --  需分摊项,只对借项中净数额进行 
   amount      money   default 0  not null
)	 
;
insert bos_dai select * from bos_dai_old
;
exec sp_primarykey bos_dai,modu_id,pc_id,daicode,daitail
create unique index index1 on bos_dai (modu_id,pc_id,daicode,daitail)
;
drop table bos_dai_old;

exec sp_rename bos_jiedai, bos_jiedai_old;
create table bos_jiedai
(
   modu_id       char(2) not null,
   pc_id       char(4) not null,
   jiecode  char(5) default '',  --  借项 
   daicode  char(5) default '',  --  贷项 
   amount   money   default 0  not null,
   smount   money   default 0  not null,
   tmount   money   default 0  not null
)
;
insert bos_jiedai select * from bos_jiedai_old
;
exec sp_primarykey bos_jiedai,modu_id,pc_id,daicode,jiecode
create unique index index1 on bos_jiedai (modu_id,pc_id,daicode,jiecode)
;
drop table bos_jiedai_old
// -----------------------以上为BOS_SHIFT
/* 现金收入表 */

exec sp_rename cashrep, cashrep_old;
create table cashrep
(
	date		datetime		null,
	class		char(2)		default '' null, /* '01' 前厅,'02' AR帐,'03',商务中心,'04',综合收银 */
	descript char(10)		default '' null,
	shift		char(1)		default '' null,
	sname		char(6)		default '' null,
	empno		char(10)		default '' null,
	ename		char(12)		default '' null,
	cclass	char(1)		default '' null,
	ccode		char(5)		default '' null,
	credit	money			default 0 not null
)
;
insert cashrep select * from cashrep_old
;
exec sp_primarykey cashrep,class,shift,empno,cclass,ccode 
create unique index index1 on cashrep(class,shift,empno,cclass,ccode)
;
drop table cashrep_old;

exec sp_rename ycashrep, ycashrep_old;
create table ycashrep
(
	date		datetime		null,
	class		char(2)		default '' null, /* '01' 前厅,'02' AR帐,'03',商务中心,'04',综合收银 */
	descript char(10)		default '' null,
	shift		char(1)		default '' null,
	sname		char(6)		default '' null,
	empno		char(10)		default '' null,
	ename		char(12)		default '' null,
	cclass	char(1)		default '' null,
	ccode		char(5)		default '' null,
	credit	money			default 0 not null
)
;
insert ycashrep select * from ycashrep_old
;
exec sp_primarykey ycashrep,date,class,shift,empno,cclass,ccode 
create unique index index1 on ycashrep(date,class,shift,empno,cclass,ccode)
;
drop table ycashrep_old;

/* 客房营业(服务费)日报表 for HZDS */
exec sp_rename dayrepo, dayrepo_old;
create table dayrepo
(
	bdate			datetime	not null, 
	class			char(1)	not null, 
	pccode		char(5)	default '' not null, 
	servcode		char(1)	default '' not null, 
	descript		char(16)	default '' not null, 
	last			money		default 0 not null,			/* 上日止客欠 */
	ddeb			money		default 0 not null,			/* 本日发生应收 */
	ddis			money		default 0 not null,			/* 本日发生优惠 */
	dcre			money		default 0 not null,			/* 本日收回 */
	dlos			money		default 0 not null,			/* 本日发生逃帐 */
	till			money		default 0 not null			/* 本日止客欠 */
)
;
insert dayrepo select * from dayrepo_old
;
exec sp_primarykey dayrepo, bdate, class, pccode, servcode
create unique index index1 on dayrepo(bdate, class, pccode, servcode)
;
drop table dayrepo_old
;

exec sp_rename ydayrepo, ydayrepo_old;
create table ydayrepo
(
	bdate			datetime	not null, 
	class			char(1)	not null, 
	pccode		char(5)	default '' not null, 
	servcode		char(1)	default '' not null, 
	descript		char(16)	default '' not null, 
	last			money		default 0 not null,			/* 上日止客欠 */
	ddeb			money		default 0 not null,			/* 本日发生应收 */
	ddis			money		default 0 not null,			/* 本日发生优惠 */
	dcre			money		default 0 not null,			/* 本日收回 */
	dlos			money		default 0 not null,			/* 本日发生逃帐 */
	till			money		default 0 not null			/* 本日止客欠 */
)
;
insert ydayrepo select * from ydayrepo_old
;
exec sp_primarykey ydayrepo, bdate, class, pccode, servcode
create unique index index1 on ydayrepo(bdate, class, pccode, servcode)
;
drop table ydayrepo_old
;

/* 餐饮娱乐日报 */

exec sp_rename deptjie, deptjie_old;
create table deptjie
(
   date           datetime default getdate() not null,
	pccode         char(5)  default '' not null,
	shift          char(1)  default '' not null,
	empno          char(10)  default '' not null,
	code           char(5)  default '' not null,
	descript       char(24) default '' not null,
	daymark        char(1)  default '' not null,
	feed           money    default 0  not null,
	feem           money    default 0  not null
)
;
insert deptjie select * from deptjie_old
;
exec sp_primarykey deptjie,pccode,shift,empno,code
create unique index index1 on deptjie(pccode,shift,empno,code)
;
drop table deptjie_old;

exec sp_rename ydeptjie, ydeptjie_old;
create table ydeptjie
(
   date           datetime default getdate() not null,
	pccode         char(5)  default '' not null,
	shift          char(1)  default '' not null,
	empno          char(10)  default '' not null,
	code           char(5)  default '' not null,
	descript       char(24) default '' not null,
	daymark        char(1)  default '' not null,
	feed           money    default 0  not null,
	feem           money    default 0  not null
)
;
insert ydeptjie select * from ydeptjie_old
;
exec sp_primarykey ydeptjie,date,pccode,shift,empno,code
create unique index index1 on ydeptjie(date,pccode,shift,empno,code)
;
drop table ydeptjie_old;

exec sp_rename deptdai, deptdai_old;
create table deptdai
(
   date           datetime default getdate() not null,
	pccode         char(5)  default '' not null,
	shift          char(1)  default '' not null,
	empno          char(10)  default '' not null,
	descript1      char(5)  default '' not null,
	paycode        char(5)  default '' not null,
	paytail        char(1)  default '' not null,
	descript       char(24) default '' not null,
	daymark        char(1)  default '' not null,
	creditd        money    default 0  not null,
	creditm        money    default 0  not null
)
;
insert deptdai select * from deptdai_old
;
exec sp_primarykey deptdai,pccode,shift,empno,paycode,paytail
create unique index index1 on deptdai(pccode,shift,empno,paycode,paytail)
;
drop table deptdai_old;

exec sp_rename ydeptdai, ydeptdai_old;
create table ydeptdai
(
	date           datetime default getdate() not null,
	pccode         char(5)  default '' not null,
	shift          char(1)  default '' not null,
	empno          char(10)  default '' not null,
	descript1      char(5)  default '' not null,
	paycode        char(5)  default '' not null,
	paytail        char(1)  default '' not null,
	descript       char(24) default '' not null,
	daymark        char(1)  default '' not null,
	creditd        money    default 0  not null,
	creditm        money    default 0  not null
)
;
insert ydeptdai select * from ydeptdai_old
;
exec sp_primarykey ydeptdai,date,pccode,shift,empno,paycode,paytail
create unique index index1 on ydeptdai(date,pccode,shift,empno,paycode,paytail)
;
drop table ydeptdai_old;

/* 各种优惠,折扣,款待明细 */
exec sp_rename discount_detail, discount_detail_old;

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
;
insert discount_detail select * from discount_detail_old
;
exec sp_primarykey discount_detail, modu_id, accnt, number, pccode, paycode, key0, billno
create unique index index1 on discount_detail(modu_id, accnt, number, pccode, paycode, key0, billno)
;
drop table discount_detail_old;

/* 各种优惠,折扣,款待汇总表 */
exec sp_rename discount, discount_old;
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
;
insert discount select * from discount_old
;
exec sp_primarykey discount, key0, paycode, pccode
create unique index index1 on discount(key0, paycode, pccode)
;
drop table discount_old;

/* 各种优惠,折扣,款待汇总表 */
exec sp_rename ydiscount, ydiscount_old;
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
;
insert ydiscount select * from ydiscount
;
exec sp_primarykey ydiscount, date, key0, paycode, pccode
create unique index index1 on ydiscount(date, key0, paycode, pccode)
;
drop table ydiscount_old;

// fixed_charge定义表
exec sp_rename fixed_charge, fixed_charge_old;

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
)
;
insert fixed_charge select * from fixed_charge_old
;
exec sp_primarykey fixed_charge, accnt, number
create unique index index1 on fixed_charge(accnt, number)
;
drop table fixed_charge_old;

// 客人信用卡定义表
exec sp_rename guest_card, guest_card_old;
create table guest_card
(
	no						char(7)			not null,								/* 客人号 */
	pccode				char(5)			not null,								/* 信用卡型 */
	cardno				char(20)			not null,								/* 信用卡号 */
	cardlevel			char(3)			null,										/* 级别 */
	expiry_date			datetime			null,										/* 信用有效期 */
	cby					char(10)			not null,								/* 工号 */
	changed				datetime			default getdate() not null,		/* 时间 */
)
;
insert guest_card select * from guest_card_old
;
exec sp_primarykey guest_card, no, pccode, cardno
create unique index index1 on guest_card(no, pccode, cardno)
;
drop table guest_card_old;


/* 发票库 */
/* 发票领退明细表 */

exec sp_rename in_detail, in_detail_old;
create table in_detail
(
	printtype   char(10)  default 'bill' not null, /* abill:2:前台账单 check:发票 
																	  pbill:餐饮账单*/ 
	inno        char(12) not null,             /*发票号*/
	bnumb       int      default 0 not null,   /*发票申领的批号*/
	sta         char(1)  default '0' not null, /*0:没用;1:已用;2:报废*/
	accnt       char(10)  null,                /*该发票对应的账号*/
	billno      char(10) null,                 /*该发票对应的账单号*/
	pccode      char(5)  null,
	modu        char(2)  null,
	bdate       datetime  null,					 /*单据使用的帐务日期*/		
	empno       char(10)   null,
	shift       char(1)   null,
	credit      money     null,              /*金额*/ 
	modi        char(1) default 'F' not null,   /*消费内容是否有改动*/ 
	cdate			datetime null,
	cempno		char(10) null,
	logdate		datetime		null					 /*单据使用的物理日期*/
)
;
insert in_detail select * from in_detail_old
;
create unique  index index1 on in_detail(printtype,inno) ;
create index index2 on in_detail(inno);
create index index3 on in_detail(empno,shift);
create index index4 on in_detail(accnt);
drop table in_detail_old;

/* 发票打印记录表 */
exec sp_rename in_print, in_print_old;
create table in_print
(
	printtype   char(10)  default 'abill' not null, /* abill:前台账单 acheck:发票  pbill:餐饮账单*/ 
	inno        char(12)  not null,             /*发票号*/
	accnt       char(10)  null,                /*该发票对应的账号*/
	billno      char(10)  null,                 /*该发票对应的账单号*/
	pccode      char(5)   null,
	modu        char(2)   null,
	bdate       datetime  null,					 /*单据使用的帐务日期*/		
	empno       char(10)  null,
	shift       char(1)   null,
	credit      money     null,             	 /*金额*/ 
	modi        char(1) 	 default 'F' not null,   /*消费内容是否有改动*/ 
	logdate		datetime	 null					 /*单据使用的物理日期*/
)
;
insert in_print select * from in_print_old
;
create unique  index index1 on in_print(printtype,inno);
create index index2 on in_print(inno);
create index index3 on in_print(empno,shift);
create index index4 on in_print(accnt);
drop table in_print_old;

//// 前台账单明细内容
//if exists(select 1  from sysobjects where type ='U' and name ='in_bill_detail') 
//	drop table in_bill_detail ;
//create table in_bill_detail
//(
//	billno      char(10)  not null,                         /*主键*/
//	printtype   char(10)  default 'abill' not null,         /* 账单类别 ; */
//	inno        char(12)  default  '' not null,                 /*账单号*/
//	code        char(5)   default  '' not null,                
//	charge      money     default 0,        
//	credit      money    default  0,       
//	item        varchar(100)  null ,
//	log_date    datetime  
//)
//;
//create unique  index index1 on in_bill_detail(printtype,inno,code,item,log_date) ;
//
//// 前台帐单头
//if exists(select 1  from sysobjects where type ='U' and name ='in_bill_head') 
//	drop table in_bill_head ;
//create table in_bill_head
//(
//	billno      char(10)  not null,                         /*主键*/
//	printtype   char(10)  default 'abill' not null,         /* 账单类别 ; */
//	inno        char(12)  default  '' not null,                 /*账单号*/
//	name        varchar(40)   default  '' not null,                
//	fir         varchar(60)   default '',        
//	room        char(5)   default  '',           
//	rooms       int,
//	guests      int,
//	arr         datetime,
//	dep         datetime,
//	qtrate      money default 0,
//	setrate     money default 0,
//	remark      varchar(200),
//	log_date    datetime
//)
//;
//create unique  index index1 on in_bill_head(printtype,inno,log_date) ;
//
//
//// 前台帐单头修改内容
//if exists(select 1  from sysobjects where type ='U' and name ='in_billmodi_head') 
//	drop table in_billmodi_head ;
//create table in_billmodi_head
//(
//	billno      char(10)  not null,                         /*主键*/
//	printtype   char(10)  default 'abill' not null,         /* 账单类别 ; */
//	inno        char(12)  default  '' not null,                 /*账单号*/
//	name        varchar(40)   default  '' not null,                
//	fir         varchar(60)   default '',        
//	room        char(5)   default  '',           
//	rooms       int,
//	guests      int,
//	arr         datetime,
//	dep         datetime,
//	qtrate      money default 0,
//	setrate     money default 0,
//	remark      varchar(200),
//	log_date    datetime
//)
//;
//create unique  index index1 on in_billmodi_head(printtype,inno,log_date) ;
//
//
//// 前台账单明细修改内容
//
//if exists(select 1  from sysobjects where type ='U' and name ='in_billmodi_detail') 
//	drop table in_billmodi_detail ;
//create table in_billmodi_detail
//(
//	billno      char(10)  not null,                         /*主键*/
//	printtype   char(10)  default 'abill' not null,         /* 账单类别 ; */
//	inno        char(12)  default  '' not null,                 /*账单号*/
//	code        char(5)   default  '' not null,                
//	charge      money     default 0,        
//	credit      money    default  0,       
//	item        varchar(100)  null ,
//	log_date    datetime,
//	modi        char(1)  default 'T'  
//)
//;
//create unique  index index1 on in_billmodi_detail(printtype,inno,code,item,log_date) ;

/* 每日应收款日报 */
exec sp_rename nbrepo, nbrepo_old;
create table nbrepo(
	deptno		char(3)		not null,					/* 类别 */
	deptname		char(24)		null,							/* 大类的中文名称 */
	pccode		char(5)		not null,					/*  */
	descript		char(24)    null,							/* 中文名称 */
	f_in			money			default 0 	not null,	/* 前台 */
	b_in  		money			default 0 	not null,	/* 后台 */	/*录入,定金*/
	f_out			money			default 0 	not null,	/* 前台 */
	b_out			money			default 0 	not null,	/* 后台 */	/*退款,部结*/
	f_tran      money			default 0 	not null,	/* 前台 */
	b_tran      money			default 0 	not null,	/* 后台 */	/*转入,清算*/
)
;
insert nbrepo select * from nbrepo_old
;
exec sp_primarykey nbrepo,pccode
create unique index index1 on nbrepo(pccode)
;
drop table nbrepo_old;


// Package定义表
exec sp_rename package, package_old;
create table package
(
	code					char(4)			not null,								/* 代码 */
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
																								第五位:0.日租不收;1.日租加收 */
	rule_post			char(3)			not null,								/* 入账方式 */
	rule_parm			char(30)			default '' not null,					/* 入账周期 */
	starting_days		integer			default 1 not null,					/* 从入账后的第几天开始生效 */
	closing_days		integer			default 1 not null,					/* 总的生效天数 */
	starting_time		char(8)			default '00:00:00' not null,		/* 每天的有效挂账起始时间 */
	closing_time		char(8)			default '23:59:59' not null,		/* 每天的有效挂账截止时间 */
	pccodes				varchar(255)	default '' not null,					/* 可以关联的营业点费用码 */
	pos_pccode			char(3)			default '' not null,					/* 超出限额后，记入Account的营业点费用码 */
	credit				money				default 0 not null,					/* 允许转账的金额 */
	cby					char(10)			not null,								/* 工号 */
	changed				datetime			default getdate() not null,		/* 时间 */
	logmark				integer			default 0 not null
)
;
insert package select * from package_old
;
exec sp_primarykey package, code
create unique index index1 on package(code)
;
drop table package_old;

// Package明细表(说明:即使使用Pakcage,在Account中都有一行金额为零的明细账)
// Master.Lastinumb转为Package.Number指针
exec sp_rename package_detail, package_detail_old;
create table package_detail
(
	accnt					char(10)			not null,								/* 账号 */
	number				integer			not null,								/* 关键字 */
	roomno				char(5)			default '' not null,					/* 房号 */
	code					char(4)			default '' not null,					/* 代码 */
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
	account_date		datetime			default getdate() not null			/* 账号(对应Account.log_date) */
)
;
insert package_detail select * from package_detail_old
;
exec sp_primarykey package_detail, accnt, number
create unique index index1 on package_detail(accnt, number)
create index index2 on package_detail(accnt, account_accnt)
create index index3 on package_detail(accnt, tag, starting_date, closing_date, starting_time, closing_time)
;
drop table package_detail_old;

exec sp_rename pccode, pccode_old;
create table pccode
(
	pccode		char(5)		not null,					/* 营业点 */
	descript		char(24)		default '',					/* 中文描述 */
	descript1	char(50)		default '',					/* 其他语种描述 */
	descript2	char(50)		default '',					/* 其他语种描述 */
	descript3	char(50)		default '',					/* 其他语种描述 */
	modu			char(2)		default '',					/* 模块号 */
	jierep		char(8)		default '',					/* 底表行索引 */
	tail			char(2)		default '',					/* 底表列索引 */
	//
	commission	money			default 0 not null,		/* 给银行的回扣率(对信用卡有效) */
	limit			money			default 0 not null,		/* 信用限额 */
	reason		char(1)		default 'F' not null,	/* 是否需要输入优惠理由 */
	// deptno?为各种分类代码、排列次序以及原付款方式表中的各项
	deptno		char(5)		default '',					/* 所属营业部门 */
	deptno1		char(5)		default '' null,			/* 允许记账、自动转账、分账户分类 */
	deptno2		char(5)		default '' null,			/* 预留 */
	deptno3		char(5)		default '' null,			/* 预留 */
	deptno4		char(5)		default '' null,			/* 帐务查询分类 */
	deptno5		char(5)		default '' null,			/* 发票分类 */
	deptno6		char(5)		default '' null,			/* 余额表列号 */	 
	deptno7		char(5)		default '' null,			/* 业绩统计 */
	deptno8		char(5)		default '' null,			/* 费用:Rebate标志; 付款:Distribute标志*/ 
	argcode		char(3)		default '' null,			/* 缺省的账单分类 */
//	paycode		char(3)		not null,					/* 内部码,小于54为有效的付款方式 */
//	codecls		char(1)		not null,					/* 付款方式类别,refer to credcls */
//	tag1			char(3)		default '' null,			/*  */
//	tag2			char(3)		default '' null,			/*  */
//	tag3			char(3)		default '' null,			/*  */
//	tag4			integer 		default 0 null,			/*  */
//	distribute  char(4)     null,							/* 需分摊款项... */
	//
	pos_item		char(3)		default '' null
)
;
insert pccode select * from pccode_old
;
exec sp_primarykey pccode, pccode
create unique clustered index index1 on pccode(pccode)
;
drop table pccode_old;

/* 打印格式表定义*/
exec sp_rename pdeptrep, pdeptrep_old;
create table pdeptrep
(
	pc_id		char(4)		not null, 
	jiedai	char(1)		not null, 
	itemcnt  integer		default 0 not null, 
	code		char(10)		not null, 
	coden		char(1)		default '' null, 
	descript char(60)		default '', 
	v1			money			default 0 null, 
	v2			money			default 0 null, 
	v3			money			default 0 null, 
	v4			money			default 0 null, 
	v5			money			default 0 null, 
	v6			money			default 0 null, 
	v7			money			default 0 null, 
	v8			money			default 0 null, 
	v9			money			default 0 null, 
	v10		money			default 0 null, 
	v11		money			default 0 null, 
	v12		money			default 0 null, 
	v13		money			default 0 null, 
	v14		money			default 0 null, 
	v15		money			default 0 null, 
	v16		money			default 0 null, 
	v17		money			default 0 null, 
	v18		money			default 0 null, 
	v19		money			default 0 null, 
	v20		money			default 0 null, 
	v21		money			default 0 null, 
	v22		money			default 0 null, 
	v23		money			default 0 null, 
	v24		money			default 0 null, 
	v25		money			default 0 null, 
	v26		money			default 0 null, 
	v27		money			default 0 null, 
	v28		money			default 0 null, 
	v29		money			default 0 null, 
	v30		money			default 0 null, 
	v31		money			default 0 null, 
	v32		money			default 0 null, 
	v33		money			default 0 null, 
	v34		money			default 0 null, 
	v35		money			default 0 null, 
	v36		money			default 0 null, 
	v37		money			default 0 null, 
	v38		money			default 0 null, 
	v39		money			default 0 null, 
	v40		money			default 0 null, 
	vtl		money			default 0 null 
)
;
insert pdeptrep select * from pdeptrep_old
;
exec sp_primarykey pdeptrep, pc_id, jiedai, code, coden
create unique index index1 on pdeptrep(pc_id, jiedai, code, coden)
create index index2 on pdeptrep(pc_id, jiedai, itemcnt)
;
drop table pdeptrep_old;

/* 打印格式表定义*/
exec sp_rename pdeptrep1, pdeptrep1_old;
create table pdeptrep1
(
	pc_id			char(4)		not null, 
	pccode		char(5)		not null, 
	descript2	char(24)		not null, 
	shift			char(1)		default '' null, 
	descript		char(4)		default '', 
	v1				money			default 0 null, 
	v2				money			default 0 null, 
	v3				money			default 0 null, 
	v4				money			default 0 null, 
	v5				money			default 0 null, 
	v6				money			default 0 null, 
	v7				money			default 0 null, 
	v8				money			default 0 null, 
	v9				money			default 0 null, 
	v10			money			default 0 null, 
	v11			money			default 0 null, 
	v12			money			default 0 null, 
	v13			money			default 0 null, 
	v14			money			default 0 null, 
	v15			money			default 0 null, 
	v16			money			default 0 null, 
	v17			money			default 0 null, 
	v18			money			default 0 null, 
	v19			money			default 0 null, 
	v20			money			default 0 null, 
	v21			money			default 0 null, 
	v22			money			default 0 null, 
	v23			money			default 0 null, 
	v24			money			default 0 null, 
	v25			money			default 0 null, 
	v26			money			default 0 null, 
	v27			money			default 0 null, 
	v28			money			default 0 null, 
	v29			money			default 0 null, 
	v30			money			default 0 null, 
	v31			money			default 0 null, 
	v32			money			default 0 null, 
	v33			money			default 0 null, 
	v34			money			default 0 null, 
	v35			money			default 0 null, 
	v36			money			default 0 null, 
	v37			money			default 0 null, 
	v38			money			default 0 null, 
	v39			money			default 0 null, 
	v40			money			default 0 null, 
	vtl			money			default 0 null 
)
;
insert pdeptrep1 select * from pdeptrep1_old
;
exec sp_primarykey pdeptrep1, pc_id, pccode, shift
create unique index index1 on pdeptrep1(pc_id, pccode, shift)
;
drop table pdeptrep1_old;

/* 打印格式表定义*/
exec sp_rename pdeptrep2, pdeptrep2_old;
create table pdeptrep2
(
	pc_id			char(4)		not null, 
	pccode		char(5)		not null, 
	descript2	char(24)		not null, 
	shift			char(1)		default '' null, 
	descript		char(4)		default '', 
	d1				money			default 0 null, 			// 食品
	d2				money			default 0 null, 			// 饮料
	d3				money			default 0 null,			// 香烟
	d4				money			default 0 null,			// 服务费
	d5				money			default 0 null,			// 其他
	d6				money			default 0 null,			// 前台入账
	d7				money			default 0 null,			// 人数		 
	d8				money			default 0 null,
	d9				money			default 0 null,			// 桌数
	//
	m1				money			default 0 null, 			// 食品
	m2				money			default 0 null, 			// 饮料
	m3				money			default 0 null,			// 香烟
	m4				money			default 0 null,			// 服务费
	m5				money			default 0 null,			// 其他
	m6				money			default 0 null,			// 前台入账
	m7				money			default 0 null,			// 人数 
	m8				money			default 0 null,
	m9				money			default 0 null				// 桌数
)
;
insert pdeptrep2 select * from pdeptrep2_old
;
exec sp_primarykey pdeptrep2, pc_id, pccode, shift
create unique index index1 on pdeptrep2(pc_id, pccode, shift)
;
drop table pdeptrep2_old;

exec sp_rename rebaterep, rebaterep_old;
create table rebaterep
(
	date				datetime,
	paycode			char(5)	default '',
	class				char(8)	default '',
	day01				money		default 0,
	day02				money		default 0,
	day03				money		default 0,
	day04				money		default 0,
	day05				money		default 0,
	day06				money		default 0,
	day07				money		default 0,
	day08				money		default 0,
	day09				money		default 0,
	day99				money		default 0,
	month01			money		default 0,
	month02			money		default 0,
	month03			money		default 0,
	month04			money		default 0,
	month05			money		default 0,
	month06			money		default 0,
	month07			money		default 0,
	month08			money		default 0,
	month09			money		default 0,
	month99			money		default 0,
)
;
insert rebaterep select * from rebaterep_old
;
exec sp_primarykey rebaterep, paycode, class
create unique index index1 on rebaterep(paycode, class)
;
drop table rebaterep_old;

exec sp_rename yrebaterep, yrebaterep_old;
create table yrebaterep
(
	date				datetime,
	paycode			char(5)	default '',
	class				char(8)	default '',
	day01				money		default 0,
	day02				money		default 0,
	day03				money		default 0,
	day04				money		default 0,
	day05				money		default 0,
	day06				money		default 0,
	day07				money		default 0,
	day08				money		default 0,
	day09				money		default 0,
	day99				money		default 0,
	month01			money		default 0,
	month02			money		default 0,
	month03			money		default 0,
	month04			money		default 0,
	month05			money		default 0,
	month06			money		default 0,
	month07			money		default 0,
	month08			money		default 0,
	month09			money		default 0,
	month99			money		default 0,
)
;
insert yrebaterep select * from yrebaterep_old
;
exec sp_primarykey yrebaterep, date, paycode, class
create unique index index1 on yrebaterep(date, paycode, class)
;
drop table yrebaterep_old;


/* 每天房租预审表 */
exec sp_rename rmpostbucket, rmpostbucket_old;
create table rmpostbucket
(
	accnt			char(10)			not null, 
	roomno		char(5)			null, 
	src			char(3)			null, 
	class			char(1)			null, 
	groupno		char(10)			null, 
	headname		varchar(100)	null, 
	type			char(3)			null,								/*房间类型*/
	market		char(3)			null,								/*价别码*/
	name			varchar(50)		null, 
	fir			varchar(60)		null, 
	ratecode		char(10)			null, 
	packages		char(20)			null, 
	paycode		char(5)			null, 
	rmrate		money				not null, 
	qtrate		money				not null, 
	setrate		money				not null, 
	charge1		money				not null, 
	charge2		money				not null, 
	charge3		money				not null, 
	charge4		money				not null, 
	charge5		money				not null, 
	package_c	money				not null, 
	rtreason		char(3)			null, 
	gstno			integer			null, 
	arr			datetime			not null, 
	dep			datetime			null, 
	today_arr	char(1)			default 'F'	not null, 
	w_or_h		integer			not null, 
	posted		char(1)			default 'F'	not null,		/*表示入帐否*/
	rmpostdate	datetime			not null, 
	// 入帐信息
	logmark		integer			not null,						/* 过房费当时的日志指针 */
	empno			char(10)			not null, 						/* 入帐员 */
	shift			char(1)			not null,  						/* 入帐班别 */
	date			datetime			default getdate() not null	/* 入帐时间 */
)
;
insert rmpostbucket select * from rmpostbucket
;
create index index1 on rmpostbucket(rmpostdate, accnt);
create index index2 on rmpostbucket(rmpostdate, groupno);
create index index3 on rmpostbucket(rmpostdate, posted)
;
drop table rmpostbucket_old;

//	每天房租预审表附表1(Package专用)
exec sp_rename rmpostpackage, rmpostpackage_old;
create table rmpostpackage
(
	pc_id					char(4)			not null, 
	mdi_id				integer			not null, 
	accnt					char(10)			not null,							/* 账号 */
	number				integer			not null,							/* 关键字 */
	roomno				char(5)			default '' not null,				/* 房号 */
	code					char(4)			default '' not null,				/* 代码 */
	pccode				char(5)			not null, 
	argcode				char(3)			default '' not null, 
	amount				money				not null,
	quantity				money				default 1 not null,
	rule_calc			char(10)			not null,
	starting_date		datetime			default '2000/1/1' not null,		/* 有效起始日期 */
	closing_date		datetime			default '2038/12/31' not null,	/* 有效截止日期 */
	starting_time		char(8)			default '00:00:00' not null,		/* 每天的有效挂账起始时间 */
	closing_time		char(8)			default '23:59:59' not null,		/* 每天的有效挂账截止时间 */
	descript				char(30)			not null,							/* 描述 */
	descript1			char(30)			default '' not null,				/* 英文描述 */
	pccodes				varchar(255)	default '' not null,				/* 可以关联的营业点费用码 */
	pos_pccode			char(5)			default '' not null,				/* 超出限额后，记入Account的营业点费用码 */
	credit				money				default 0 not null,				/* 允许转账的金额 */
)
;
insert rmpostpackage select * from rmpostpackage_old
;
exec sp_primarykey rmpostpackage, pc_id, mdi_id, accnt, number
create unique index index1 on rmpostpackage(pc_id, mdi_id, accnt, number)
;
drop table rmpostpackage_old;

/* rmratecode---房价代码表 */
exec sp_rename rmratecode, rmratecode_old;
create table rmratecode
(
	code          char(10)	    					not null,  	// 代码
	cat          	char(3)	    					not null,
   descript      varchar(60)      				not null,  	// 描述  
   descript1     varchar(60)     default ''	not null,  	// 描述  
   private       char(1) 			default 'T'	not null,  	// 私有 or 公用
   mode       	  char(1) 			default ''	not null,  	// 模式--以后用来控制主单房价的取舍
   folio       	varchar(30) 	default ''	not null, 	// 帐单
	src				char(3)			default ''	not null,	// 宾客来源
	market			char(3)			default ''	not null,	// 市场代码
	packages			char(20)			default ''	not null,	//	包价
	begin_			datetime							null,
	end_				datetime							null,
	calendar			char(1)		default 'F'	not null,	// 房价日历
	yieldable		char(1)		default 'F'	not null,	// 限制策略
	yieldcat			char(3)		default ''	not null,
	bucket			char(3)		default ''	not null,
	staymin			int			default 0	not null,
	staymax			int			default 0	not null,
	pccode			char(5)		default ''	not null,
	sequence			int			default 0	not null
)
;
insert rmratecode select * from rmratecode_old
;
exec sp_primarykey rmratecode,code;
create unique index index1 on rmratecode(code);
create unique index index2 on rmratecode(descript);
;
drop table rmratecode_old;

/* 四川锦江费综合报表 */
exec sp_rename sjourrep, sjourrep_old;
create table sjourrep
(
	date			datetime			not null,
	tag			char(1)			default '' not null, 
	deptno		char(5)			not null,
	pccode		char(5)			default '' not null,
	descript		char(24)			not null,
	balance_l	money				default 0 not null,			/* 上日未收数 */
	day0			money				default 0 not null,			/* 本日发生数 */
	month0		money				default 0 not null,			/* 本月发生数 */
	day1			money				default 0 not null,			/* 本日减免打折 */
	month1		money				default 0 not null,			/* 本月减免打折 */
	day2			money				default 0 not null,			/* 本日二次折扣 */
	month2		money				default 0 not null,			/* 本月二次折扣 */
	day3			money				default 0 not null,
	month3		money				default 0 not null,
	day8			money				default 0 not null,			/* 本日实收记账款 */
	month8		money				default 0 not null,			/* 本月实收记账款 */
	day9			money				default 0 not null,			/* 本日实收款 */
	month9		money				default 0 not null,			/* 本月实收款 */
	balance_t	money				default 0 not null			/* 本日未收数 */
)
;
insert sjourrep select * from sjourrep_old
;
exec sp_primarykey sjourrep, tag, deptno, pccode
create unique index index1 on sjourrep(tag, deptno, pccode)
;
drop table sjourrep_old;

exec sp_rename ysjourrep, ysjourrep_old;
create table ysjourrep
(
	date			datetime			not null,
	tag			char(1)			default '' not null, 
	deptno		char(5)			not null,
	pccode		char(5)			default '' not null,
	descript		char(24)			not null,
	balance_l	money				default 0 not null,			/* 上日未收数 */
	day0			money				default 0 not null,			/* 本日发生数 */
	month0		money				default 0 not null,			/* 本月发生数 */
	day1			money				default 0 not null,			/* 本日减免打折 */
	month1		money				default 0 not null,			/* 本月减免打折 */
	day2			money				default 0 not null,			/* 本日二次折扣 */
	month2		money				default 0 not null,			/* 本月二次折扣 */
	day3			money				default 0 not null,
	month3		money				default 0 not null,
	day8			money				default 0 not null,			/* 本日实收记账款 */
	month8		money				default 0 not null,			/* 本月实收记账款 */
	day9			money				default 0 not null,			/* 本日实收款 */
	month9		money				default 0 not null,			/* 本月实收款 */
	balance_t	money				default 0 not null			/* 本日未收数 */
)
;
insert ysjourrep select * from ysjourrep_old
;
exec sp_primarykey ysjourrep, date, tag, deptno, pccode
create unique index index1 on ysjourrep(date, tag, deptno, pccode)
;
drop table ysjourrep_old;

// 分账户定义表
exec sp_rename subaccnt, subaccnt_old;
create table subaccnt
(
	roomno				char(5)			default '' not null,				/* 房号 */
	haccnt				char(7)			default '' not null,				/* 客人号 */
	accnt					char(10)			not null,							/* 账号 */
	subaccnt				integer			default 0 not null,				/* 子账号*/
	to_roomno			char(5)			default '' not null,				/* 转账房号 */
	to_accnt				char(10)			default '' not null,				/* 转账账号 */
	name					char(50)			not null,							/* 名称 */
	pccodes				varchar(255)	not null,							/* 费用码 */
	starting_time		datetime			default '2000/1/1' not null,	/* 有效期起始 */
	closing_time		datetime			default '2038/1/1' not null,	/* 有效期截止 */
	cby					char(10)			not null,							/* 工号 */
	changed				datetime			default getdate() not null,	/* 时间 */
	type					char(1)			default '1' not null,			/* 子(AB)账户的类别: 
																							0.允许记账
																							2.团体为成员付费(只有团体主单才有，成员以此为模版)
																							5.分账户(自动转账并入分账户) */
	tag					char(1)			default '0' not null,			/* 0.系统自动增加(不能修改)
																							1.系统自动增加(能修改、不能删除)
																							2.人工产生(能修改) */
	paycode				char(5)			default '' not null,				/* 付款方式 */
	ref					varchar(50)		default '' not null,				/* 备注 */
	logmark				integer			default 0 not null
)
;
insert subaccnt select * from subaccnt_old
;
exec sp_primarykey subaccnt, accnt, subaccnt, type, starting_time, closing_time
create unique index index1 on subaccnt(accnt, subaccnt, type, starting_time, closing_time)
create index index2 on subaccnt(to_accnt, type)
create index index3 on subaccnt(accnt, haccnt)
;
drop table subaccnt_old;

exec sp_rename hsubaccnt, hsubaccnt_old;
create table hsubaccnt
(
	roomno				char(5)			default '' not null,				/* 房号 */
	haccnt				char(7)			default '' not null,				/* 客人号 */
	accnt					char(10)			not null,							/* 账号 */
	subaccnt				integer			default 0 not null,				/* 子账号*/
	to_roomno			char(5)			default '' not null,				/* 转账房号 */
	to_accnt				char(10)			default '' not null,				/* 转账账号 */
	name					char(50)			not null,							/* 名称 */
	pccodes				varchar(255)	not null,							/* 费用码 */
	starting_time		datetime			default '2000/1/1' not null,	/* 有效期起始 */
	closing_time		datetime			default '2038/1/1' not null,	/* 有效期截止 */
	cby					char(10)			not null,							/* 工号 */
	changed				datetime			default getdate() not null,	/* 时间 */
	type					char(1)			default '1' not null,			/* 子(AB)账户的类别: 
																							0.允许记账
																							2.团体为成员付费(只有团体主单才有，成员以此为模版)
																							5.分账户(自动转账并入分账户) */
	tag					char(1)			default '0' not null,			/* 0.系统自动增加(不能修改)
																							1.系统自动增加(能修改、不能删除)
																							2.人工产生(能修改) */
	paycode				char(5)			default '' not null,				/* 付款方式 */
	ref					varchar(50)		default '' not null,				/* 备注 */
	logmark				integer			default 0 not null
)
;
insert hsubaccnt select * from hsubaccnt_old
;
exec sp_primarykey hsubaccnt, accnt, subaccnt, type, starting_time, closing_time
create unique index index1 on hsubaccnt(accnt, subaccnt, type, starting_time, closing_time)
create index index2 on hsubaccnt(to_accnt, type)
create index index3 on hsubaccnt(accnt, haccnt)
;
drop table hsubaccnt_old;

// 可能没用
///* 自动转账(允许记账)项目表 */
//exec sp_rename transfer, transfer_old;
//create table transfer
//(
//	type			char(1)	default '1' not null,					/* 类型:1.自动转账,
//																						  2.允许记账,
//																						  3.AB账,
//																						  4.显示账目,
//																						  5.显示电话费 */
//	accnt			char(10)	not null,
//	to_accnt		char(10)	default '' not null,
//	pccode		char(10)	not null,									/* deptno + pccode + '%'*/
//	percent		money		default 1 not null,						/* 备用 */
//	amount		money		default 0 not null,						/* 备用 */
//	empno			char(10)	not null,									/* 工号 */
//	date			datetime	default getdate() not null,			/* 时间 */
//)
//;
//insert transfer select * from transfer_old
//;
//exec sp_primarykey transfer, type, accnt, pccode, to_accnt
//create unique index index1 on transfer(type, accnt, pccode, to_accnt)
//;
//drop table transfer_old;
///* 团体成员批量修改   --  允许记账控制临时表 */
//exec sp_rename transfer_mem, transfer_mem_old;
//create table transfer_mem
//(
//	modu_id		char(2)	not null,
//	pc_id			char(4)	not null,
//	pccode		char(10)	not null,									/* deptno2 + pccode + '%'*/
//	percent		money		default 1 not null,						/* 备用 */
//	amount		money		default 0 not null,						/* 备用 */
//	empno			char(10)	not null,									/* 工号 */
//	date			datetime	default getdate() not null,			/* 时间 */
//)
//;
//insert transfer_mem select * from transfer_mem_old
//;
//exec sp_primarykey transfer_mem, modu_id, pc_id, pccode
//create unique index index1 on transfer_mem(modu_id, pc_id, pccode)
//;
//drop table transfer_mem_old;