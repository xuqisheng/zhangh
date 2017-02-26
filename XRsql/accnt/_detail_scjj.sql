if exists(select * from sysobjects where type ="U" and name = "detail_scjj")
	drop table detail_scjj
;
create table detail_scjj
(
	pc_id				char(4)	not null,							/*  */
	deptno			char(3)	default '' not null,				/* ������ */
	descript			char(24)	default '' not null,				/* ��Ŀ���� */
	charge			money		default 0 not null,				/* ��� */
	descript1		char(54)	default '' not null,				/* ���ʽ���� */
	billno			char(10)	default '' not null				/*  */
)
create index index1 on detail_scjj(pc_id)
;
