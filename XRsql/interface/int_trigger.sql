
-- ------------------------------------------------------------------------------------
-- 		int_inttoact 更新触发器
-- ------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_gds_int_inttoact_update' and type = 'TR')
   drop trigger t_hry_gds_inttoact_update;
create trigger t_hry_gds_inttoact_update
   on inttoact
   for update as
begin
if update(logmark)
   begin
   insert inttoact_log select inserted.* from inserted 
   end
if update(occ)
   begin
	declare 	@occ 				char(1),
				@username		varchar(16)
	select @occ = occ, @username = int_user from inserted
	if @occ = 'T' 
		select @occ = '1'
	else
		select @occ = '0'
	exec p_gds_internet_pms_set  @username, @occ, 'PMS'
   end
end    
;


-- ------------------------------------------------------------------------------------
-- 		int_inttoact 插入触发器
-- ------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_gds_int_inttoact_update' and type = 'TR')
   drop trigger t_hry_gds_inttoact_insert;
create trigger t_hry_gds_inttoact_insert
   on inttoact
   for insert as
begin
	declare 	@occ 				char(1),
				@username		varchar(16)
	select @occ = occ, @username = int_user from inserted
	if @occ = 'T' 
		select @occ = '1'
	else
		select @occ = '0'
	exec p_gds_internet_pms_set  @username, @occ, 'PMS'
end    
;


-- ------------------------------------------------------------------------------------
-- 		int_inttoact 删除触发器
-- ------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_gds_int_inttoact_update' and type = 'TR')
   drop trigger t_hry_gds_inttoact_delete;
create trigger t_hry_gds_inttoact_delete
   on inttoact
   for delete as
begin
	declare 	@occ 				char(1),
				@username		varchar(16)
	select @occ = occ, @username = int_user from deleted
	if @occ = 'T' 
	begin
		select @occ = '0'
		exec p_gds_internet_pms_set  @username, @occ, 'PMS'
	end
end    
;
