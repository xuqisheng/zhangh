if exists (select 1
            from  sysobjects
            where  id = object_id('master_hotel')
            and    type = 'U')
   drop table master_hotel
;

/* ============================================================ */
/*   Table: master_hotel                                        */
/* ============================================================ */
create table master_hotel
(
	accnt      	char(10)					   not null,	
	hotelid    	varchar(20)            	not null,
	accnt0     	char(10)					   not null, 
	sync			char(1)					   not null,   
	empno       char(10)					       null,	    // 操作人
	lastdate		datetime					       null       // 最后操作时间 
)
exec sp_primarykey master_hotel,accnt
create unique index index1 on master_hotel(accnt)
;

if exists (select 1
            from  sysobjects
            where  id = object_id('vmaster')
            and    type = 'V')
   drop view vmaster
;

/* ============================================================ */
/*   View: vmaster                                              */
/* ============================================================ */
create view vmaster 
as
    select b.hotelid,b.accnt0,a.*  
      from master a,master_hotel b 
     where a.accnt = b.accnt 
;



if exists (select 1
            from  sysobjects
            where  id = object_id('vhmaster')
            and    type = 'V')
   drop view vhmaster
;

/* ============================================================ */
/*   View: vhmaster                                             */
/* ============================================================ */
create view vhmaster 
as
    select b.hotelid,b.accnt0,a.*  
      from hmaster a,master_hotel b 
     where a.accnt = b.accnt 
;

