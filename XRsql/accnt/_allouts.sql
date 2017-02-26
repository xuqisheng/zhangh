

if exists (select * from sysobjects where name='allouts' and type='U')
	drop table allouts;

create table allouts
(
	accnt				char(10)		not null,
	sta				char(1)		not null,
	stabacktoi		char(1)		not null,
	empno				char(10)		not null,
	date				datetime		default getdate() not null,
	billno			char(10)		not null,
)
exec sp_primarykey allouts,accnt
create unique index index1 on allouts(accnt)
;
