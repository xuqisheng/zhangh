if exists (select 1
            from  sysobjects
            where  id = object_id('hotelsync')
            and    type = 'U')
   drop table hotelsync
;
/* ============================================================ */
/*   Table: hotelsync                                           */
/* ============================================================ */
create table hotelsync
(
    syncid     varchar(20)            not null,
    descript   varchar(50)            null,
    descript1  varchar(50)            null,
    action     varchar(254)           null,  
	 sync			char(1)					  null,  
	 syncsta		char(1)					  null,  
    empno      char(10)					  null,	
	 lastdate	datetime					  null,  
    seq        integer                not null,  
    logmark    integer                not null 
)
exec sp_primarykey hotelsync,syncid
create unique index index1 on hotelsync(syncid)
;



if exists (select 1
            from  sysobjects
            where  id = object_id('hotelsync_log')
            and    type = 'U')
   drop table hotelsync_log
;

/* ============================================================ */
/*   Table: hotelsync_log                                       */
/* ============================================================ */
create table hotelsync_log
(
    syncid     varchar(20)            not null,
	 syncsta		char(1)					  null,  
    empno      char(10)					  null,	    
	 lastdate	datetime					  null,       
    logmark    integer                not null 
)
exec sp_primarykey hotelsync_log,syncid,logmark 
;

if exists (select * from sysobjects where name = 'tu_hotelsync' and type = 'TR')
   drop trigger tu_hotelsync;
create trigger tu_hotelsync
   on hotelsync
   for update as
begin
	if update(logmark)
		insert into hotelsync_log(syncsta,syncid,empno,lastdate,logmark)
			select syncsta,syncid,empno,lastdate,logmark
			from inserted where char_length(empno)>0
end
;

delete from hotelsync
;

insert into hotelsync(sync,syncid,descript,descript1,action,seq,logmark) 
	select '2','reserve','预订信息','Reserve Info',	'',20,0 
insert into hotelsync(sync,syncid,descript,descript1,action,seq,logmark) 
	select '2','income','宾客收入信息','Guest Income Info','',30,0
;



if exists (select 1
            from  sysobjects
            where  id = object_id('guest_income')
            and    type = 'U')
   drop table guest_income
;
