/*****************************************************************
*
*  FOXHIS �������ݿ⡢��ʷ���ݿ⡢��ѵ���ݿ�
*
*----------------------------------------------------------------
*  sysoption.catalog   .item
*----------------------------------------------------------------
*            hotel     database        -- ϵͳĿǰ����ĵ�ǰ��
*            hotel     database_backup -- ϵͳĿǰ�������ѵ��
*----------------------------------------------------------------
* FOXHIS.INI [database]
*----------------------------------------------------------------
* {ini} = {database} & {database} <> {database_backup}  -->����
*   login->��ǰ�����ѵ��(*)
*
* {ini} = {database_backup} | {ini} <> {database}  
*   login->��ѵ��
*
*
*****************************************************************/
/* ���ݿⶨ��  */
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
	cby				char(10)		default '!' 	not null,	/* �����޸�����Ϣ   */
	changed			datetime		default getdate()		not null 
)
exec sp_primarykey foxdatabase,dbid
create unique index index1 on foxdatabase(dbid)
;

/* ����������  */
if exists(select * from sysobjects where name = "foxdbserver")
	drop table foxdbserver;
create table foxdbserver
(
	srvdefine		char(64)							not null, /* ip,port*/
   descript   		varchar(60)    				not null,
   descript1  		varchar(60) default ''   	not null,
	cby				char(10)		default '!' 	not null,	/* �����޸�����Ϣ   */
	changed			datetime		default getdate()		not null 
)
exec sp_primarykey foxdbserver,srvdefine
create unique index index1 on foxdbserver(srvdefine)
;

/* dump��¼  */
if exists(select * from sysobjects where name = "foxdbdump")
	drop table foxdbdump;
create table foxdbdump
(
	dumpid			char(16)							not null,
	dumpdate			datetime		      			not null, /* ����ʱ�� */ 
	dumpsrv			char(64)							not null, /* ������ ip,port */
	dumpdb			char(64)							not null, /* ���ݿ�   */
	dumppath			char(254)						not null, /* �ļ�����·�� URL���� ,/backup/dump/xxx.dump */
	dumpnumb			int								not null, /* �ļ��ָ����� */
   remark   		varchar(254)    				    null  /* ���ݱ�ע */
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
-- ��������Ϣ����
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
	-- ������ʾ����

	select id,txt,seq from #info order by seq 

end
;

--------------------------------------------------------------------------------
-- ���ݿ���Ϣ����
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
	-- ������ʾ����

	select id,txt,seq from #info order by seq 

end
;

