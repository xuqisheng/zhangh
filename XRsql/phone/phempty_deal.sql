
// ------------------------------------------------------------------------------------
//		漏单电话处理
// ------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = 'phempty_deal' and type = 'U')
	drop table phempty_deal
;
create table phempty_deal
(
	date				datetime			not null,
	inumber			int				not null,
	refer0			varchar(20)		null,
	refer1			varchar(20)		not null,
	empno				char(10)			not null
)
exec sp_primarykey  phempty_deal, date
create unique index index1 on phempty_deal(date)
;

