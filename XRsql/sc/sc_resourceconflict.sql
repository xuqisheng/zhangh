if exists(select 1 from sysobjects where name='sc_resourceconflict' and type='U')
drop table sc_resourceconflict
;
create table sc_resourceconflict
(
	 id       varchar(10) not null,
    evtresno char(10) not null,
	 rsclsid char(10) not null,
	 rsid    char(10) not null,
	 begin_  datetime not null,
	 end_    datetime not null,
    quantity integer not null,
    saleid  varchar(10) not null
)
;
 
