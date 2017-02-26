// 催账周期定义
if exists(select * from sysobjects where type ="U" and name = "ar_cycle")
   drop table ar_cycle;

create table ar_cycle
(
	code			char(4)		not null,							/* 代码 */
	days			integer		not null,							/* 账期 */
	descript		char(30)		default '' not null,				/* 中文描述 */
	descript1	char(30)		default '' not null,				/* 英文描述 */
	bill_mode	char(3)		not null								/* 催账信代码 */
)
;
exec   sp_primarykey ar_cycle, code, days
create unique index index1 on ar_cycle(code, days)
;

insert ar_cycle values ('OTH', 30, '1st Reminder Letter', '1st Reminder Letter', '40');
insert ar_cycle values ('OTH', 60, '2st Reminder Letter', '2st Reminder Letter', '40');
insert ar_cycle values ('OTH', 90, '3st Reminder Letter', '3st Reminder Letter', '40');
insert ar_cycle values ('OTH', 120, 'Last Reminder Letter', 'Last Reminder Letter', '40');
insert ar_cycle values ('COM', 30, '1st Reminder Letter', '1st Reminder Letter', '40');
insert ar_cycle values ('COM', 60, '2st Reminder Letter', '2st Reminder Letter', '40');
insert ar_cycle values ('COM', 90, '3st Reminder Letter', '3st Reminder Letter', '40');
insert ar_cycle values ('COM', 120, 'Last Reminder Letter', 'Last Reminder Letter', '40');
insert ar_cycle values ('TA', 30, '1st Reminder Letter', '1st Reminder Letter', '40');
insert ar_cycle values ('TA', 60, '2st Reminder Letter', '2st Reminder Letter', '40');
insert ar_cycle values ('TA', 90, '3st Reminder Letter', '3st Reminder Letter', '40');
insert ar_cycle values ('TA', 120, 'Last Reminder Letter', 'Last Reminder Letter', '40');
