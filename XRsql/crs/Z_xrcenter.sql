if exists (select 1
            from  sysobjects
            where  id = object_id('hotelinfo')
            and    type = 'U')
   drop table hotelinfo
;

/* ============================================================ */
/*   Table: hotelinfo                                           */
/* ============================================================ */
create table hotelinfo
(
    hotelid    varchar(20)            not null,
    descript   varchar(50)            not null,
    descript1  varchar(50)            not null,
    city       varchar(50)            null    ,
    addr       varchar(254)           null    ,
    addr1      varchar(254)           null    ,
    tel        varchar(50)            null    ,
    fax        varchar(50)            null    ,
    rsvtel     varchar(50)            null    ,
    email      varchar(64)            null    ,
    remark     text                   null    ,
    photo      varchar(254)           null    ,
    dns        varchar(64) default ''    not null, 
	 sta			char(1)		default '0'	  not null   -- 0-Õý³£  1-½ûÓÃ 
)
exec sp_primarykey hotelinfo,hotelid
create unique index index1 on hotelinfo(hotelid)
;
