
//   drop trigger t_gds_checkroom_insert;
//   drop trigger t_gds_checkroom_update;
//   drop trigger t_gds_checkroom_delete;



// ------------------------------------------------------------------------------------
// checkroom trigger 
// ------------------------------------------------------------------------------------

//-----------------
//	insert 
//-----------------
if exists (select * from sysobjects where name = 't_gds_checkroom_insert' and type = 'TR')
   drop trigger t_gds_checkroom_insert;
create trigger t_gds_checkroom_insert
   on checkroom
   for insert as
begin
// Added by gds for update infomation !
if not exists(select 1 from table_update where tbname = 'checkroom')
	insert table_update select 'checkroom', getdate()
else
	update table_update set update_date = getdate() where tbname = 'checkroom'

end
;


//-----------------
//	delete
//-----------------
if exists (select * from sysobjects where name = 't_gds_checkroom_delete' and type = 'TR')
   drop trigger t_gds_checkroom_delete;
create trigger t_gds_checkroom_delete
   on  checkroom
   for delete as
begin
// Added by gds for update infomation !
if not exists(select 1 from table_update where tbname = 'checkroom')
	insert table_update select 'checkroom', getdate()
else
	update table_update set update_date = getdate() where tbname = 'checkroom'
end
;


//-----------------
//	update
//-----------------
// 允许修改在住房间的房类, 但是必须重建预留房 !
// update typim set typim.quantity = (select sum(1) from checkroom where checkroom.type=typim.type);
if exists (select * from sysobjects where name = 't_gds_checkroom_update' and type = 'TR')
   drop trigger t_gds_checkroom_update;
create trigger t_gds_checkroom_update
   on checkroom
   for update as
begin
// Added by gds for update infomation !
if not exists(select 1 from table_update where tbname = 'checkroom')
	insert table_update select 'checkroom', getdate()
else
	update table_update set update_date = getdate() where tbname = 'checkroom'

end
;

