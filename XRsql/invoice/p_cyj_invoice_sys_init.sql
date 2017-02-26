if exists(select 1 from sysobjects where name ='p_cyj_invoice_sys_init' and type ='P')
	drop proc p_cyj_invoice_sys_init;

create proc p_cyj_invoice_sys_init
	@parm char(1)
as

truncate table invoice
truncate table invoice_log
truncate table in_detail
truncate table in_recode
truncate table in_allprint
;


