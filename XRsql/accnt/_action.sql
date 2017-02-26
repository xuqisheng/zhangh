// action定义表
if exists(select * from sysobjects where type ="U" and name = "action")
   drop table action;

create table action
(
	pc_id					char(4)			not null,								/* IP地址 */
	action				varchar(250)	not null,
	descript				char(50)			not null,								/* 描述 */
	cby					char(10)			not null,								/* 工号 */
	changed				datetime			default getdate() not null,		/* 时间 */
);
exec sp_primarykey action, pc_id, action
create unique index index1 on action(pc_id, action)
;
INSERT INTO action VALUES ('0.69','account!3012028','[1105]Bill','HRY',getdate());
INSERT INTO action VALUES ('0.69','master!3012028','[1105]Reservation','HRY',getdate());
