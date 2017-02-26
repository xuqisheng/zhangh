IF OBJECT_ID('p_foxhis_audit_init_deptrep') IS NOT NULL
    DROP PROCEDURE p_foxhis_audit_init_deptrep
;
create proc p_foxhis_audit_init_deptrep
as
-------------------------------------------------------------------
--	pos 系列夜审报表的初始化
-------------------------------------------------------------------

truncate table pos_report
truncate table pos_yreport

truncate table deptjie
truncate table ydeptjie

truncate table deptdai
truncate table ydeptdai

return 0
;

