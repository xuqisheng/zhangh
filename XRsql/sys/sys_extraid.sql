//// ------------------------------------------------------------------------------
////	sys_extraid
////				这里维护除了 sysdata 里不包含的系统 - id
//// ------------------------------------------------------------------------------
//if exists(select * from sysobjects where name = "sys_extraid")
//	drop table sys_extraid;
//create table sys_extraid
//(
//	cat				char(30)							not null,
//	descript			varchar(30)	default ''		not null,
//	id					int			default 0		not null		
//)
//exec sp_primarykey sys_extraid,cat
//create unique index index1 on sys_extraid(cat)
//;
//

if not exists(select 1 from sys_extraid where cat='SAT')
	insert sys_extraid select 'SAT', 'saccnt for room share', 0;

if not exists(select 1 from sys_extraid where cat='TUN')
	insert sys_extraid select 'TUN', 'ID for Turnaway', 1;

if not exists(select 1 from sys_extraid where cat='QRM')
	insert sys_extraid select 'QRM', 'Q-Room', 1;

if not exists(select 1 from sys_extraid where cat='DSR')
	insert sys_extraid select 'DSR', 'Discrepant Room 矛盾房', 1;

