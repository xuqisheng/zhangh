if exists (select 1 from sysobjects where name='p_foxhis_worklist')
   drop proc p_foxhis_worklist;
create proc p_foxhis_worklist
	@window		varchar(30)
as
-- ---------------------------------------------------------------------------------------
-- 系统工作表 查询  - simon 2006.10   
-- 
--  把针对所有 modu_id 的都显示出来 
-- ---------------------------------------------------------------------------------------

if exists(select 1 from workselect where window=@window) 
	select 'workselect', * from workselect where window=@window
else
	select '没有任何 workselect'

if exists(select 1 from workselect where window=@window) 
	select 'worksheet', * from worksheet where window=@window order by sequence

if exists(select 1 from workbutton_name where window=@window) 
	select 'workbutton_name', * from workbutton_name where window=@window order by sequence

if exists(select 1 from workbutton where window=@window) 
	select 'workbutton', * from workbutton where window=@window

if exists(select 1 from worksta_name where window=@window) 
	select 'worksta_name', * from worksta_name where window=@window order by sequence 

if exists(select 1 from worksta where window=@window) 
	select 'worksta', * from worksta where window=@window

return 0
;

exec p_foxhis_worklist  'w_gds_sc_master_list_fo';
