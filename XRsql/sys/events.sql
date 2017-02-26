
//================================================================================
// 	酒店事务
//================================================================================

if exists(select * from sysobjects where name = "events")
	drop table events;
create table events
(
	id					int								not null,
	sta				char(1)		default 'I'		not null,		// I, X, O
   descript   		varchar(60)    				not null,
   remark  			text 			 default ''   	not null,
	begin_			datetime							not null,
	end_				datetime							not null,
	crtby				char(10)							not null,		// 创建
	crttime			datetime							not null,
	cby				char(10)							not null,		// 修改
	changed			datetime							not null
)
exec sp_primarykey events, id
create unique index index1 on events(id)
;
