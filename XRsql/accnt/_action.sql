// action�����
if exists(select * from sysobjects where type ="U" and name = "action")
   drop table action;

create table action
(
	pc_id					char(4)			not null,								/* IP��ַ */
	action				varchar(250)	not null,
	descript				char(50)			not null,								/* ���� */
	cby					char(10)			not null,								/* ���� */
	changed				datetime			default getdate() not null,		/* ʱ�� */
);
exec sp_primarykey action, pc_id, action
create unique index index1 on action(pc_id, action)
;
INSERT INTO action VALUES ('0.69','account!3012028','[1105]Bill','HRY',getdate());
INSERT INTO action VALUES ('0.69','master!3012028','[1105]Reservation','HRY',getdate());
