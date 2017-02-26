IF OBJECT_ID('p_foxhis_audit_maininit') IS NOT NULL
    DROP PROCEDURE p_foxhis_audit_maininit
;
create proc p_foxhis_audit_maininit
as
----------------------------------------
-- 相关报表初始化
----------------------------------------
exec p_foxhis_audit_init_jiedairep
exec p_foxhis_audit_init_deptrep
exec p_foxhis_audit_init_miscrep

exec p_gds_audit_init_bosrep

return 0
;

