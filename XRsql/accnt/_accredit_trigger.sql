-- ------------------------------------------------------------------------------------
--		accredit 更新触发器
-- ------------------------------------------------------------------------------------
create trigger t_gds_accredit_insert
   on accredit for insert
	as
begin
if exists(select 1 from inserted) 
	insert accredit_log select * from inserted 
end
;


-- ------------------------------------------------------------------------------------
--		accredit 更新触发器
-- ------------------------------------------------------------------------------------
create trigger t_gds_accredit_update
   on accredit for update
	as
begin
if update(logmark)
	insert accredit_log select * from inserted 
end
;
