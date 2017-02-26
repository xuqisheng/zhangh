if exists (select 1 from sysobjects where name='p_foxhis_worklist')
   drop proc p_foxhis_worklist;
create proc p_foxhis_worklist
	@window		varchar(30)
as
-- ---------------------------------------------------------------------------------------
-- ϵͳ������ ��ѯ  - simon 2006.10   
-- 
--  ��������� modu_id �Ķ���ʾ���� 
-- ---------------------------------------------------------------------------------------

if exists(select 1 from workselect where window=@window) 
	select 'workselect', * from workselect where window=@window
else
	select 'û���κ� workselect'

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
