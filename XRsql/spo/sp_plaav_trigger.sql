if exists(select 1 from sysobjects where name = 't_sp_plaav_insert')
	drop trigger t_sp_plaav_insert
;

create trigger t_sp_plaav_insert
on sp_plaav for insert
as
declare 
	@menu			char(20),
	@inumber		integer,
	@placecode  char(5)

select @menu =menu ,@inumber = inumber,@placecode = placecode from inserted
if update(sta)
	begin
	if (select value from sysoption where catalog = 'spo' and item = 'remind_insert') = 'T'
		insert sp_remind select a.menu ,a.inumber,a.placecode,a.stime,a.etime,b.name,a.empno,0 from inserted a,sp_place b where a.placecode = b.placecode and charindex('R',a.menu) = 0
	end
;


if exists(select 1 from sysobjects where name = 't_sp_plaav_update')
	drop trigger t_sp_plaav_update
;

create trigger t_sp_plaav_update
on sp_plaav for update
as
declare 
	@menu			char(20),
	@inumber		integer,
	@placecode  char(5)

select @menu =menu ,@inumber = inumber,@placecode = placecode from deleted
if exists(select 1 from inserted where sta = 'D') and exists(select 1 from deleted where sta = 'I')
	delete sp_remind where menu = @menu and inumber = @inumber and placecode = @placecode
else
	begin
	if exists(select 1 from sp_remind a,deleted b where a.menu = b.menu and a.inumber = b.inumber  and a.placecode = b.placecode)
		begin
		delete sp_remind where menu = @menu and inumber = @inumber and placecode = @placecode
		insert sp_remind select a.menu,a.inumber,a.placecode ,a.stime,a.etime,b.name,a.empno,0 from inserted a ,sp_place b where a.placecode = b.placecode and charindex('R',a.menu) = 0
		end
	end
	

;

if exists(select 1 from sysobjects where name = 't_sp_plaav_delete')
	drop trigger t_sp_plaav_delete
;

create trigger t_sp_plaav_delete
on sp_plaav for delete
as
declare 
	@menu			char(20),
	@inumber		integer,
	@placecode  char(5)

select @menu =menu ,@inumber = inumber,@placecode = placecode from deleted
delete sp_remind where menu = @menu and inumber = @inumber and placecode = @placecode

;


