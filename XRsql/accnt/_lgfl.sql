if  exists(select * from sysobjects where name = "lgfl" and type ="U")
	drop table lgfl
;
create table lgfl
(
	columnname			char(15)			not null,						/* ���� */
	accnt					char(10)			not null,						/* �ʺ� */
	old					varchar(255)		null,								/* ԭֵ */
	new					varchar(255)		null,								/* ��ֵ */
	empno					char(10)			not null,						/* ����Ա */
	date					datetime			default getdate()	not null	/* ����ʱ�� */
)
create index index1 on lgfl(accnt, columnname, date)
create index index2 on lgfl(empno, date)
;

if  exists(select * from sysobjects where name = "lgfl_des" and type ="U")
	drop table lgfl_des
;
create table lgfl_des
(
	columnname			char(15)			not null,						/* ���� */
	descript				varchar(20)			not null,						/* �������� */
	descript1			varchar(20)			not null,						/* Ӣ������ */
	tag					char(1)			not null							/* ��� */
)
exec sp_primarykey lgfl_des, columnname
create unique index index1 on lgfl_des(columnname)
;
