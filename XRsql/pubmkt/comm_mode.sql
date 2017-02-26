
// ------------------------------------------------------------------------------
//	comm_mode : 佣金方案
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "comm_mode")
   drop table comm_mode;
create table comm_mode
(
	mode			char(3)						not null,
	descript    char(30)						not null,
	descript1   varchar(30)	default ''	not null,
	grp			varchar(16)	default ''	not null,
	halt			char(1)		default 'F'	not null,
	flag			char(3)		default ''	not null,
	sequence		int		default 0		not null,
)
exec sp_primarykey comm_mode,mode
create unique index index1 on comm_mode(mode)
;



// ------------------------------------------------------------------------------
//	comm_def : 佣金方案 -- 描述
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "comm_def")
   drop table comm_def;
create table comm_def
(
	id				int		default 0		not null,
	mode			char(3)						not null,
	types    	varchar(100)	default ''	not null,
	rate1			money		default 0		not null,
	rate2			money		default 0		not null,
	night1		int		default 0		not null,
	night2		int		default 0		not null,
	tag			char(1)	default 'P'		not null,
	value			money		default 0		not null
)
exec sp_primarykey comm_def,id,mode
create unique index index1 on comm_def(id,mode)
;


