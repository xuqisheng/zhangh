if exists (select * from sysobjects where name ='p_gds_audit_statistic_saveas_y' and type ='P')
	drop proc p_gds_audit_statistic_saveas_y;
create proc p_gds_audit_statistic_saveas_y
as
------------------------------------------------------------------------------------------------
-- 重建 statistic 报表的月累计
------------------------------------------------------------------------------------------------
declare 
	@duringaudit		char(1),
	@pc_id				char(4),
	@bdate				datetime, 
	@isfstday			char(1), 
	@isyfstday			char(1)

-- ---------Initialization--------------- 
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead

--
select @pc_id = 'pcid' 

-- 重建报表的月累计
exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday  = 'T'
	begin
	select @bdate = dateadd(dd, -1, @bdate)
	exec p_gl_statistic_saveas_y @pc_id, @bdate, '%', '%', '%'
	end

return 0
;
