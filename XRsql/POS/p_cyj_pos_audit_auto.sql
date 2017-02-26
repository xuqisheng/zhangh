if exists(select 1 from sysobjects where name ='p_cyj_pos_audit_auto' and type ='P')	
	drop  proc p_cyj_pos_audit_auto;
create proc p_cyj_pos_audit_auto
	@pc_id			char(4),
	@empno			char(10)
as
--------------------------------------------------------------------------------------
-- 独立餐饮系统，夜审批量处理 
--------------------------------------------------------------------------------------

declare	
	@ret			integer,
	@msg			char(100),
	@hasdone		char(1),
	@needinst	char(1)



select @ret = 0, @msg = ''
-- 稽核独占部分
select @hasdone = hasdone, @needinst = needinst from  auditprg where callform = 'p_cyj_audit_exclpart'
if @hasdone = 'F' and @needinst = 'T'
	begin
	exec p_cyj_audit_exclpart  @pc_id,@empno,@ret out,@msg out
	if @ret <> 0 
		goto GOOUT
	else
		update auditprg set hasdone = 'T'  where callform = 'p_cyj_audit_exclpart'
	end
	
-- 餐饮娱乐稽核独占部分
select @hasdone = hasdone, @needinst = needinst from  auditprg where callform = 'p_cyj_pos_dinexcl'
if @hasdone = 'F' and @needinst = 'T'
	begin
	exec p_cyj_pos_dinexcl @ret out, @msg out
	if @ret <> 0 
		goto GOOUT
	else
		update auditprg set hasdone = 'T'  where callform = 'p_cyj_pos_dinexcl'
	end
-- 餐饮吧台结转
select @hasdone = hasdone, @needinst = needinst from  auditprg where callform = 'p_cyj_bar_audit_exec'
if @hasdone = 'F' and @needinst = 'T'
	begin
	exec p_cyj_bar_audit_exec @ret out, @msg out
	if @ret <> 0 
		goto GOOUT
	else
		update auditprg set hasdone = 'T'  where callform = 'p_cyj_bar_audit_exec'
	end
-- 开放各站点
select @hasdone = hasdone, @needinst = needinst from  auditprg where callform = 'p_cyj_audit_opengate'
if @hasdone = 'F' and @needinst = 'T'
	begin
	exec p_cyj_audit_opengate  @ret out,@msg out
	if @ret <> 0 
		goto GOOUT
	else
		update auditprg set hasdone = 'T'  where callform = 'p_cyj_audit_opengate'
	end
-- 餐饮娱乐收入及财务记录表
select @hasdone = hasdone, @needinst = needinst from  auditprg where callform = 'p_cyj_pos_deptrep'
if @hasdone = 'F' and @needinst = 'T'
	begin
	exec p_cyj_pos_deptrep @ret, @msg
	if @ret <> 0 
		goto GOOUT
	else
		update auditprg set hasdone = 'T'  where callform = 'p_cyj_pos_deptrep'
	end
-- 综合收银营业情况统计表
select @hasdone = hasdone, @needinst = needinst from  auditprg where callform = 'p_cyj_pos_report'
if @hasdone = 'F' and @needinst = 'T'
	begin
	exec p_cyj_pos_report @ret, @msg
	if @ret <> 0 
		goto GOOUT
	else
		update auditprg set hasdone = 'T'  where callform = 'p_cyj_pos_report'
	end

select @hasdone = hasdone, @needinst = needinst from  auditprg where callform = 'p_cyj_audit_aftwork'
if @hasdone = 'F' and @needinst = 'T'
	begin
-- 夜间稽核结束部分
	exec p_cyj_audit_aftwork @ret out,@msg out
	if @ret <> 0 
		goto GOOUT
	end

GOOUT:
select @ret, @msg
;
