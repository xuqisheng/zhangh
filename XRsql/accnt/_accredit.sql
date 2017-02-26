
-- 预收信用卡明细 

-- 信用记录标记 
//insert basecode values ('accredit_tag', '0', '预收', '', 'T', 'F', 10, '');
//insert basecode values ('accredit_tag', '5', '作废', '', 'T', 'F', 20, '');
//insert basecode values ('accredit_tag', '9', '付款', '', 'T', 'F', 30, '');

-- 信用记录 
if exists(select * from sysobjects where type ="U" and name = "accredit")
	drop table accredit
;
create table accredit
(
	accnt			char(12)		not null,								-- 帐号 
	number		integer		default 1 not null,					-- 序号 
	pccode		char(5)		not null,								-- 信用卡类型 
	cardno		char(20)		not null,								-- 卡号 或者 AR帐户 
	expiry_date	datetime		not null,								-- 信用卡有效期 
	foliono		char(10)		default '' not null,					-- 水单号 
	creditno		char(10)		default '' not null,					-- 授权号 
	quantity		money			default 0 not null,					-- 金额-外币
	amount		money			default 0 not null,					-- 金额-预收 
	amtuse		money			default 0 not null,					-- 金额-使用 
	tag			char(1)		default '0' not null,				-- 状态:0.未用 5.取消 9.使用 = basecode(accredit_tag) 
	empno1		char(10)		not null,								-- 收件工号 
	bdate1		datetime		not null,								-- 收件营业日期 
	shift1		char(1)		not null,								-- 收件班别 
	log_date1	datetime		default getdate() not null,		-- 收件时间 
	empno2		char(10)		null,										-- 使用工号 
	bdate2		datetime		null,										-- 使用营业日期 
	shift2		char(1)		null,										-- 使用班别 
	log_date2	datetime		null,										-- 使用时间 
	partout		integer		default 1 not null,					-- 部分结账转销时用 
	billno		char(10)		default '' not null,					-- 使用该信用卡的帐单号 
	cby			char(10)		default '' not null,
	changed		datetime		default getdate() not null,		
	logmark		int			default 0	not null,
	hotelid     char(10) NULL,
   sendout     char(1) NULL 
)
exec sp_primarykey accredit, accnt, number
create unique index index1 on accredit(accnt, number)
;

-- 信用记录 
if exists(select * from sysobjects where type ="U" and name = "accredit_log")
	drop table accredit_log
;
create table accredit_log
(
	accnt			char(12)		not null,								-- 帐号 
	number		integer		default 1 not null,					-- 序号 
	pccode		char(5)		not null,								-- 信用卡类型 
	cardno		char(20)		not null,								-- 卡号 或者 AR帐户 
	expiry_date	datetime		not null,								-- 信用卡有效期 
	foliono		char(10)		default '' not null,					-- 水单号 
	creditno		char(10)		default '' not null,					-- 授权号 
	quantity		money			default 0 not null,					-- 金额-外币
	amount		money			default 0 not null,					-- 金额-预收 
	amtuse		money			default 0 not null,					-- 金额-使用 
	tag			char(1)		default '0' not null,				-- 状态:0.未用 5.取消 9.使用 = basecode(accredit_tag) 
	empno1		char(10)		not null,								-- 收件工号 
	bdate1		datetime		not null,								-- 收件营业日期 
	shift1		char(1)		not null,								-- 收件班别 
	log_date1	datetime		default getdate() not null,		-- 收件时间 
	empno2		char(10)		null,										-- 使用工号 
	bdate2		datetime		null,										-- 使用营业日期 
	shift2		char(1)		null,										-- 使用班别 
	log_date2	datetime		null,										-- 使用时间 
	partout		integer		default 1 not null,					-- 部分结账转销时用 
	billno		char(10)		default '' not null,					-- 使用该信用卡的帐单号 
	cby			char(10)		default '' not null,
	changed		datetime		default getdate() not null,		
	logmark		int			default 0	not null,
	hotelid     char(10) NULL,
   sendout     char(1) NULL 
)
exec sp_primarykey accredit_log, accnt, number, logmark
create unique index index1 on accredit_log(accnt, number, logmark)
;

