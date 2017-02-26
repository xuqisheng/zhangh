-------------------------------------------------------------------------------------------
-- foxhelp
-------------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'fox_dispatchclass' and type ='U')
	drop table fox_dispatchclass
;
create table fox_dispatchclass (
	dispatch			varchar(32)						not null, 
	classname		varchar(128)					not null, 
	descript    	varchar(30)		default ''	not null,
	descript1   	varchar(30)		default ''	not null,
	byappid			varchar(64)		default ''	not null 
)
;
exec sp_primarykey fox_dispatchclass,dispatch,classname
create unique index index1 on fox_dispatchclass(dispatch,classname)
;

-------------------------------------------------------------------------------------------
-- data
-------------------------------------------------------------------------------------------
insert into fox_dispatchclass(dispatch,classname,descript,descript1,byappid) select  'shortcut','n_shortcut_accnt', '', '', '123' ;

insert into fox_dispatchclass(dispatch,classname,descript,descript1,byappid) select  'msgprocess','n_msgprocess_front', '', '', '1' ;
