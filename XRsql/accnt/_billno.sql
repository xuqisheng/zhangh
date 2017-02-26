/* 账单流水记录 */
if  exists(select * from sysobjects where name = "billno" and type ="U")
	drop table billno
;
create table billno
(
	billno				char(10)			not null,
	accnt					char(10)			not null,
	bdate					datetime			not null,
	empno1				char(10)			not null,
	shift1				char(1)			not null,
	date1					datetime			default getdate()	not null,
	empno2				char(10)			null,
	shift2				char(1)			null,
	date2					datetime			null,
)
exec sp_primarykey billno, billno, accnt
create unique index index1 on billno(billno, accnt)
;


