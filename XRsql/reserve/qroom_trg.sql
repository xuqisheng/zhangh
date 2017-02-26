
create trigger t_gds_qroom_insert
   on qroom
   for insert as
begin

if not exists(select 1 from table_update where tbname = 'qroom')
	insert table_update select 'qroom', getdate()
else
	update table_update set update_date = getdate() where tbname = 'qroom'

end
;

create trigger t_gds_qroom_update
   on qroom
   for update as
begin

if not exists(select 1 from table_update where tbname = 'qroom')
	insert table_update select 'qroom', getdate()
else
	update table_update set update_date = getdate() where tbname = 'qroom'

end
;

create trigger t_gds_qroom_delete
   on  qroom
   for delete as
begin

if not exists(select 1 from table_update where tbname = 'qroom')
	insert table_update select 'qroom', getdate()
else
	update table_update set update_date = getdate() where tbname = 'qroom'
end
;
