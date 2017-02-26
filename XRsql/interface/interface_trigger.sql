
/*
	pos_menu 的三个触发器
*/

if exists(select 1 from sysobjects where name = 't_interface_option_insert')
	drop trigger t_interface_option_insert
;

create trigger t_interface_option_insert
on interface_option for insert
as
declare
	@descript		char(50),
	@groupid			char(2),
	@id				char(2),
	@sta				char(1)

select @groupid = groupid,@id=interface_id,@descript = descript from inserted
if @descript = 'restart_c' 
begin
	update interface set start_c = getdate() where groupid = @groupid and id = @id and sta = 'T'
	update interface set start_c = null where groupid = @groupid and id = @id and sta = 'F'
end 
;



if exists(select 1 from sysobjects where name = 't_interface_option_update')
	drop trigger t_interface_option_update
;

create trigger t_interface_option_update
on interface_option for update
as
declare
	@descript		char(50),
	@groupid			char(2),
	@id				char(2),
	@sta				char(1)

select @groupid = groupid,@id=interface_id,@descript = descript from inserted
if @descript = 'restart_c' 
begin
	update interface set start_c = getdate() where groupid = @groupid and id = @id and sta = 'T'
	update interface set start_c = null where groupid = @groupid and id = @id and sta = 'F'
end 
;
