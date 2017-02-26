
// ----------------------------------------------------------------
// rmsta_avl --- 客房可用性 
// ----------------------------------------------------------------
if exists(select * from sysobjects where name = "rmsta_avl")
	drop table rmsta_avl;
create table rmsta_avl
(
	roomno			char(5)							not null,
	type				char(5)							not null,
	date        	datetime	    					not null,
	sta				char(1)							not null,	-- O=stop X=cancel 
	cby				char(10)							not null,
	changed			datetime							not null
)
exec sp_primarykey rmsta_avl,roomno,date
create unique index index1 on rmsta_avl(roomno,date)
;

if exists(select * from sysobjects where name = "rmsta_avl_log")
	drop table rmsta_avl_log;
create table rmsta_avl_log
(
	roomno			char(5)							not null,
	type				char(5)							not null,
	date        	datetime	    					not null,
	sta				char(1)							not null,	-- O=stop X=cancel 
	cby				char(10)							not null,
	changed			datetime							not null,
	logmark			numeric(10,0) 					identity
)
exec sp_primarykey rmsta_avl_log,roomno,date,logmark
create unique index index1 on rmsta_avl_log(roomno,date,logmark)
;


//-----------------
//	trigger insert 
//-----------------
if exists (select * from sysobjects where name = 't_gds_rmsta_avl_insert' and type = 'TR')
   drop trigger t_gds_rmsta_avl_insert;
create trigger t_gds_rmsta_avl_insert
   on rmsta_avl
   for insert as
begin
	insert rmsta_avl_log(roomno,type,date,sta,cby,changed)
		select roomno,type,date,sta,cby,changed from inserted 
end
;


//-----------------
//	trigger update 
//-----------------
if exists (select * from sysobjects where name = 't_gds_rmsta_avl_update' and type = 'TR')
   drop trigger t_gds_rmsta_avl_update;
create trigger t_gds_rmsta_avl_update
   on rmsta_avl
   for update as
begin
	if update(date)
	begin
		rollback trigger with raiserror 20000 "不能采用更新日期的方法HRY_MARK"
		return 
	end
	if update(sta)
		insert rmsta_avl_log(roomno,type,date,sta,cby,changed)
			select roomno,type,date,sta,cby,changed from inserted 
end
;
