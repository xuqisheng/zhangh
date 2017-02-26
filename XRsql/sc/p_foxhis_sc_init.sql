
if exists (select 1 from sysobjects where name = 'p_foxhis_sc_init' and type='P')
	drop proc p_foxhis_sc_init
;
create proc  p_foxhis_sc_init 
as
-- ------------------------------------------------------------------------------
--   SC 初始化
-- ------------------------------------------------------------------------------

-- -------------------------------
--  客房业务
-- -------------------------------
truncate table sc_master
truncate table sc_master_till
truncate table sc_master_last
truncate table sc_master_log
truncate table sc_master_del
truncate table sc_hmaster

truncate table sc_master_hung
truncate table sc_master_hhung

truncate table sc_remark 


-- -------------------------------
--  宴会业务
-- -------------------------------
truncate table sc_eventreservation
truncate table sc_spacereservation
truncate table sc_resourcreservation
truncate table sc_billinfo
truncate table sc_eventreservation_log
truncate table sc_grpblk_trace
truncate table sc_resourceconflict
truncate table sc_pos_reserve 
truncate table sc_spacemaintain 

-- -------------------------------
--  活动业务
-- -------------------------------
truncate table sc_activitydetail
truncate table sc_recuractivity

-- -------------------------------
--  报表
-- -------------------------------
truncate table sc_grpblk_trace
--  ......


return 0
;
