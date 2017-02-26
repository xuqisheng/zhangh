
//   drop trigger t_gds_rmsta_insert;
//   drop trigger t_gds_rmsta_update;
//   drop trigger t_gds_rmsta_delete;


// ------------------------------------------------------------------------------------
// rmsta trigger 
// ------------------------------------------------------------------------------------

//-----------------
//	insert 
//-----------------
if exists (select * from sysobjects where name = 't_gds_rmsta_insert' and type = 'TR')
   drop trigger t_gds_rmsta_insert;
create trigger t_gds_rmsta_insert
   on rmsta
   for insert as
begin
if not exists (select 1 from inserted a, basecode b where b.cat='hall' and a.hall=b.code)
   rollback trigger with raiserror 20000 "无效的楼号!HRY_MARK"

if not exists (select 1 from inserted a, flrcode b where a.flr=b.code)
   rollback trigger with raiserror 20000 "无效的客房楼层!HRY_MARK"

if not exists (select 1 from inserted a, basecode b where b.cat='hsregion' and a.rmreg=b.code)
   rollback trigger with raiserror 20000 "无效的客房区域!HRY_MARK"

-- Added by gds for update infomation !
if not exists(select 1 from table_update where tbname = 'rmsta')
	insert table_update select 'rmsta', getdate()
else
	update table_update set update_date = getdate() where tbname = 'rmsta'

--
update typim set quantity = quantity + (select count(roomno) from inserted where inserted.type = typim.type)

end
;


//-----------------
//	delete
//-----------------
if exists (select * from sysobjects where name = 't_gds_rmsta_delete' and type = 'TR')
   drop trigger t_gds_rmsta_delete;
create trigger t_gds_rmsta_delete
   on  rmsta
   for delete as
begin
if exists (select 1 from master,deleted where master.roomno = deleted.roomno)
   rollback trigger with raiserror 20000 "已有客人使用本房间,你不能删除HRY_MARK"
else if exists (select 1 from rsvroom,deleted where rsvroom.roomno = deleted.roomno)
   rollback trigger with raiserror 20000 "已有预订使用本房间,你不能删除HRY_MARK"
else
   begin
   update typim set quantity = quantity - (select count(*) from deleted where deleted.type = typim.type)
   delete rmsta_log from deleted where rmsta_log.roomno = deleted.roomno 
   end 
end
;


//-----------------
//	update
//-----------------
if exists (select * from sysobjects where name = 't_gds_rmsta_update' and type = 'TR')
   drop trigger t_gds_rmsta_update;
create trigger t_gds_rmsta_update
   on rmsta
   for update as
begin
if update(type)
   begin
   if exists (select 1 from master,inserted,deleted where inserted.type <> deleted.type and inserted.roomno = deleted.roomno and master.roomno = deleted.roomno)
      begin
		update master set master.type=inserted.type from inserted where inserted.roomno=master.roomno
		update master_till set master_till.type=inserted.type from inserted where inserted.roomno=master_till.roomno
      end 
   update typim set quantity = quantity + (select count(1) from inserted where inserted.type = typim.type)
   update typim set quantity = quantity - (select count(1) from deleted  where deleted.type = typim.type)
   end 

if update(logmark)
   begin
   insert rmsta_log select * from deleted
   update rmbmp_login set writetime = getdate()
   end

if update(hall) and not exists (select 1 from inserted a, basecode b where b.cat='hall' and a.hall=b.code)
      rollback trigger with raiserror 20000 "无效的楼号!HRY_MARK"

if update(flr) and not exists (select 1 from inserted a, flrcode b where a.flr=b.code)
      rollback trigger with raiserror 20000 "无效的客房楼层!HRY_MARK"

if update(rmreg) and not exists (select 1 from inserted a, basecode b where b.cat='hsregion' and a.rmreg=b.code)
      rollback trigger with raiserror 20000 "无效的客房区域!HRY_MARK"

-- 自动取消矛盾房
if update(ocsta)
begin
	declare	@ocsta char(1), @roomno char(5), @empno char(10)
	select @ocsta=ocsta, @roomno=roomno, @empno=changed from inserted 
	if exists(select 1 from discrepant_room where roomno=@roomno and sta='I' and fo_sta<>@ocsta)
	begin
		update discrepant_room set sta='X', fo_sta=@ocsta, cby=@empno, changed=getdate(),remark=remark+'=>'+'Auto Cancel'
			where roomno=@roomno and sta='I' and fo_sta<>@ocsta
	end
	
end

-- Added by gds for update infomation !
if not exists(select 1 from table_update where tbname = 'rmsta')
	insert table_update select 'rmsta', getdate()
else
	update table_update set update_date = getdate() where tbname = 'rmsta'

end
;

