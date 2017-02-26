/*****************************************************************
*
*  FOXHIS 备份数据库、历史数据库、培训数据库
*
*----------------------------------------------------------------
*  sysoption.catalog   .item
*----------------------------------------------------------------
*            hotel     database        -- 系统目前定义的当前库
*            hotel     database_backup -- 系统目前定义的培训库
*----------------------------------------------------------------
* FOXHIS.INI [database]
*----------------------------------------------------------------
* {ini} = {database} & {database} <> {database_backup}  -->正常
*   login->当前库或培训库(*)
*
* {ini} = {database_backup} | {ini} <> {database}  
*   login->培训库
*
*
*****************************************************************/
/* 数据库定义  */
if exists(select * from sysobjects where name = "foxdatabase")
	drop table foxdatabase;
create table foxdatabase
(
	dbid				char(16)							not null,
	dbsrv				char(32)							not null, /* ip,port */
	dbname			char(64)							not null, 
   descript   		varchar(60)    				not null,
   descript1  		varchar(60) default ''   	not null,
	dbtype			char(1)		default 'H'		not null,	/*	H:History T:Train */
	cby				char(10)		default '!' 	not null,	/* 最新修改人信息   */
	changed			datetime		default getdate()		not null 
)
exec sp_primarykey foxdatabase,dbid
create unique index index1 on foxdatabase(dbid)
;

/* 服务器定义  */
if exists(select * from sysobjects where name = "foxdbserver")
	drop table foxdbserver;
create table foxdbserver
(
	srvdefine		char(64)							not null, /* ip,port*/
   descript   		varchar(60)    				not null,
   descript1  		varchar(60) default ''   	not null,
	cby				char(10)		default '!' 	not null,	/* 最新修改人信息   */
	changed			datetime		default getdate()		not null 
)
exec sp_primarykey foxdbserver,srvdefine
create unique index index1 on foxdbserver(srvdefine)
;

/* dump记录  */
if exists(select * from sysobjects where name = "foxdbdump")
	drop table foxdbdump;
create table foxdbdump
(
	dumpid			char(16)							not null,
	dumpdate			datetime		      			not null, /* 备份时间 */ 
	dumpsrv			char(64)							not null, /* 服务器 ip,port */
	dumpdb			char(64)							not null, /* 数据库   */
	dumppath			char(254)						not null, /* 文件完整路径 URL定义 ,/backup/dump/xxx.dump */
	dumpnumb			int								not null, /* 文件分割数量 */
   remark   		varchar(254)    				    null  /* 备份备注 */
)
exec sp_primarykey foxdbdump,dumpid
create unique index index1 on foxdbdump(dumpid)
;

--------------------------------------------------------------------------------
--  dumpid
--------------------------------------------------------------------------------
if exists(select 1 from sys_extraid where cat='DMP')
	update sys_extraid set id = 0 where cat='DMP'
else
	insert into sys_extraid(cat,descript,id) select 'DMP','Dump Id',0
;
--------------------------------------------------------------------------------
-- 服务器信息过程
--------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_foxhis_serverinfo' and type = 'P')
   drop procedure p_foxhis_serverinfo
; 
create procedure p_foxhis_serverinfo
as	
begin 
	create table #info
	(
		id					varchar(32)						not null, 
		txt				varchar(254)					not null, 
		seq				int				default 0	not null 
	)
	-- 增加显示内容

	select id,txt,seq from #info order by seq 

end
;

--------------------------------------------------------------------------------
-- 数据库信息过程
--------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_foxhis_databaseinfo' and type = 'P')
   drop procedure p_foxhis_databaseinfo
; 
create procedure p_foxhis_databaseinfo 
	@dbname	varchar(64) 
as	
begin 
	create table #info
	(
		id					varchar(32)						not null, 
		txt				varchar(254)					not null, 
		seq				int				default 0	not null 
	)
	-- 增加显示内容

	select id,txt,seq from #info order by seq 

end
;

