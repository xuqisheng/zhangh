if exists (select * from sysobjects where name = 'rebaterep' and type ='U')
	drop table rebaterep;

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
exec sp_primarykey rebaterep, paycode, class
create unique index index1 on rebaterep(paycode, class)
;

if exists (select * from sysobjects where name = 'yrebaterep' and type ='U')
	drop table yrebaterep;

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
exec sp_primarykey yrebaterep, date, paycode, class
create unique index index1 on yrebaterep(date, paycode, class)
;
