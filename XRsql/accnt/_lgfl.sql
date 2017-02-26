if  exists(select * from sysobjects where name = "lgfl" and type ="U")
	drop table lgfl
;
create table lgfl
(
	columnname			char(15)			not null,						/* 列名 */
	accnt					char(10)			not null,						/* 帐号 */
	old					varchar(255)		null,								/* 原值 */
	new					varchar(255)		null,								/* 新值 */
	empno					char(10)			not null,						/* 操作员 */
	date					datetime			default getdate()	not null	/* 输入时间 */
)
create index index1 on lgfl(accnt, columnname, date)
create index index2 on lgfl(empno, date)
;

if  exists(select * from sysobjects where name = "lgfl_des" and type ="U")
	drop table lgfl_des
;
create table lgfl_des
(
	columnname			char(15)			not null,						/* 列名 */
	descript				varchar(20)			not null,						/* 中文描述 */
	descript1			varchar(20)			not null,						/* 英文描述 */
	tag					char(1)			not null							/* 类别 */
)
exec sp_primarykey lgfl_des, columnname
create unique index index1 on lgfl_des(columnname)
;
