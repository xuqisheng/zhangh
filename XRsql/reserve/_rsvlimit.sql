
-------------------------------------------------------------------------------
-- ��ʱ������ overbooking 
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "rsvlimit" and type='U')
	drop table rsvlimit;
create table rsvlimit
(
	date    		datetime  				not null,			-- ����
	gtype			char(5) default ''	not null,			-- ����
	type			char(5) default ''	not null,			-- ���� 
	overbook		int		default 0	not null,
	cby			char(10)						null,
	changed		datetime						null,
	logmark		int		default 0		null
)
exec sp_primarykey rsvlimit,date,gtype,type;
create unique index index1 on rsvlimit(date,gtype,type);

-- ��־�� 
if exists(select * from sysobjects where name = "rsvlimit_log" and type='U')
	drop table rsvlimit_log;
create table rsvlimit_log
(
	date    		datetime  				not null,			-- ����
	gtype			char(5) default ''	not null,			-- ����
	type			char(5) default ''	not null,			-- ���� 
	overbook		int		default 0	not null,
	cby			char(10)						null,
	changed		datetime						null,
	logmark		int		default 0		null
)
exec sp_primarykey rsvlimit_log,date,gtype,type,logmark;
create unique index index1 on rsvlimit_log(date,gtype,type,logmark);

-- update ������  ��־��¼
IF OBJECT_ID('t_gds_rsvlimit_update') IS NOT NULL
    DROP TRIGGER t_gds_rsvlimit_update
;
create trigger t_gds_rsvlimit_update
   on rsvlimit
   for update
as
if update(logmark)  -- ��¼��־
   insert rsvlimit_log select * from inserted
return
;

