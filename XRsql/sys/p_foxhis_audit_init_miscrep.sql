
IF OBJECT_ID('p_foxhis_audit_init_miscrep') IS NOT NULL
    DROP PROCEDURE p_foxhis_audit_init_miscrep
;
create proc p_foxhis_audit_init_miscrep
as
-------------------------------------------------
-- 	一些杂项夜审报表的初始化
-------------------------------------------------

truncate table gststa
truncate table ygststa
truncate table gststa1
truncate table ygststa1

truncate table mktsummaryrep
truncate table ymktsummaryrep

truncate table rmsalerep_new
truncate table yrmsalerep_new

truncate table account_detail
truncate table discount_detail
truncate table discount
truncate table ydiscount

//truncate table act_bal
//truncate table act_bal_serve
//truncate table yact_bal

truncate table bjourrep
truncate table ybjourrep

truncate table cashrep
truncate table ycashrep

truncate table discount_scjj
truncate table ydiscount_scjj


truncate table torrepo
truncate table ytorrepo

truncate table cus_xf
truncate table ycus_xf

return 0
;
