/* 账单流水记录（账务查询用） */
if  exists(select * from sysobjects where name = "billno_temp" and type ="U")
	drop table billno_temp
;
create table billno_temp
(
	pc_id					char(4)			not null,
	mdi_id				integer			not null,
	billno				char(10)			not null,
	charge				money				default 0 not null,
	credit				money				default 0 not null,
	accntof				char(10)			default '' not null,
	empno					char(10)			default '' not null,
	log_date				datetime			default getdate() not null
)
;
exec sp_primarykey billno_temp, pc_id, mdi_id, billno
create unique index index1 on billno_temp(pc_id, mdi_id, billno)
;


