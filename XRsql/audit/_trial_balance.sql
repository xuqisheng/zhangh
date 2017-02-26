-- 底表宾客账、应收账款以及以后的积分等等

if exists(select * from sysobjects where name = "trial_balance")
	drop table trial_balance;
create table trial_balance(
	date				datetime		not null,
	type				char(2)		default '' not null,
	code				char(5)		default '' not null,
	descript			char(24)		default '' not null,
	descript1		char(50)		default '' not null,
	day				money			default 0 not null,
	month				money			default 0 not null,
	year				money			default 0 not null
)
exec sp_primarykey trial_balance, type, code
create unique index index1 on trial_balance(type, code)
;

if exists(select * from sysobjects where name = "ytrial_balance")
	drop table ytrial_balance;
create table ytrial_balance(
	date				datetime		not null,
	type				char(2)		default '' not null,
	code				char(5)		default '' not null,
	descript			char(24)		default '' not null,
	descript1		char(50)		default '' not null,
	day				money			default 0 not null,
	month				money			default 0 not null,
	year				money			default 0 not null
)
exec sp_primarykey ytrial_balance, date, type, code
create unique index index1 on ytrial_balance(date, type, code)
;

insert trial_balance select bdate, '10', ' *', '上日余额', 'Balance From Yesterday', 0, 0, 0 from accthead;
insert trial_balance select bdate, '20', ' #', '收入', 'REVENUE', 0, 0, 0 from accthead;
insert trial_balance select bdate, '20', '{{{{{', '合计', 'Total', 0, 0, 0 from accthead;
insert trial_balance select bdate, '30', ' #', '支出', 'PAID-OUT', 0, 0, 0 from accthead;
insert trial_balance select bdate, '30', '{{{{{', '合计', 'Total', 0, 0, 0 from accthead;
insert trial_balance select bdate, '40', '', '收款', 'PAYMENTS', 0, 0, 0 from accthead;
insert trial_balance select bdate, '40', '{{{{{', '合计', 'Total', 0, 0, 0 from accthead;
insert trial_balance select bdate, '50', '00', '总计', 'GRAND TOTAL', 0, 0, 0 from accthead;
insert trial_balance select bdate, '50', '10', '客账余额', 'Total Projected', 0, 0, 0 from accthead;
insert trial_balance select bdate, '50', '20', '实际余额', 'Balance is', 0, 0, 0 from accthead;
insert trial_balance select bdate, '50', '{{{{{', '差额', 'Control Sum', 0, 0, 0 from accthead;
insert trial_balance select bdate, '60', ' #', '应收', 'CITY LEDGER', 0, 0, 0 from accthead;
insert trial_balance select bdate, '60', '1*', '上日余额', 'Balance Yesterday', 0, 0, 0 from accthead;
insert trial_balance select bdate, '60', '20', '转入', 'Transfer to City Ledger', 0, 0, 0 from accthead;
insert trial_balance select bdate, '60', '30', '入账', 'City Ledger Revenue', 0, 0, 0 from accthead;
insert trial_balance select bdate, '60', '40', '付款', 'City Ledger Payments', 0, 0, 0 from accthead;
insert trial_balance select bdate, '60', '50', '应收余额', 'Balance Projected', 0, 0, 0 from accthead;
insert trial_balance select bdate, '60', '60', '实际余额', 'Balance Actual', 0, 0, 0 from accthead;
insert trial_balance select bdate, '60', '{{{{{', '差额', 'Control Sum', 0, 0, 0 from accthead;
insert trial_balance select bdate, '70', ' #', 'DEPOSIT LEDGER', 'DEPOSIT LEDGER', 0, 0, 0 from accthead;
insert trial_balance select bdate, '70', '1*', 'Balance Yesterday', 'Balance Yesterday', 0, 0, 0 from accthead;
insert trial_balance select bdate, '70', '20', 'Deposits Paid', 'Deposits Paid', 0, 0, 0 from accthead;
insert trial_balance select bdate, '70', '30', 'Deposits Refunded', 'Deposits Refunded', 0, 0, 0 from accthead;
insert trial_balance select bdate, '70', '40', 'Deposits Retained', 'Deposits Retained', 0, 0, 0 from accthead;
insert trial_balance select bdate, '70', '50', 'Deposits Transfer at Check-in', 'Deposits Transfer at Check-in', 0, 0, 0 from accthead;
insert trial_balance select bdate, '70', '60', 'Balance Projected', 'Balance Projected', 0, 0, 0 from accthead;
insert trial_balance select bdate, '70', '70', 'Balance Actual', 'Balance Actual', 0, 0, 0 from accthead;
insert trial_balance select bdate, '70', '80', 'Balance on Wait List', 'Balance on Wait List', 0, 0, 0 from accthead;
insert trial_balance select bdate, '70', '{{{{{', 'Control Sum', 'Control Sum', 0, 0, 0 from accthead;
