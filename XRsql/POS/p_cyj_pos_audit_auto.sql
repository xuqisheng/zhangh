if exists(select 1 from sysobjects where name ='p_cyj_pos_audit_auto' and type ='P')	
	drop  proc p_cyj_pos_audit_auto;
create proc p_cyj_pos_audit_auto
	@pc_id			char(4),
	@empno			char(10)
as
--------------------------------------------------------------------------------------
-- ��������ϵͳ��ҹ���������� 
--------------------------------------------------------------------------------------

declare	
	@ret			integer,
	@msg			char(100),
	@hasdone		char(1),
	@needinst	char(1)



select @ret = 0, @msg = ''
-- ���˶�ռ����
select @hasdone = hasdone, @needinst = needinst from  auditprg where callform = 'p_cyj_audit_exclpart'
if @hasdone = 'F' and @needinst = 'T'
	begin
	exec p_cyj_audit_exclpart  @pc_id,@empno,@ret out,@msg out
	if @ret <> 0 
		goto GOOUT
	else
		update auditprg set hasdone = 'T'  where callform = 'p_cyj_audit_exclpart'
	end
	
-- �������ֻ��˶�ռ����
select @hasdone = hasdone, @needinst = needinst from  auditprg where callform = 'p_cyj_pos_dinexcl'
if @hasdone = 'F' and @needinst = 'T'
	begin
	exec p_cyj_pos_dinexcl @ret out, @msg out
	if @ret <> 0 
		goto GOOUT
	else
		update auditprg set hasdone = 'T'  where callform = 'p_cyj_pos_dinexcl'
	end
-- ������̨��ת
select @hasdone = hasdone, @needinst = needinst from  auditprg where callform = 'p_cyj_bar_audit_exec'
if @hasdone = 'F' and @needinst = 'T'
	begin
	exec p_cyj_bar_audit_exec @ret out, @msg out
	if @ret <> 0 
		goto GOOUT
	else
		update auditprg set hasdone = 'T'  where callform = 'p_cyj_bar_audit_exec'
	end
-- ���Ÿ�վ��
select @hasdone = hasdone, @needinst = needinst from  auditprg where callform = 'p_cyj_audit_opengate'
if @hasdone = 'F' and @needinst = 'T'
	begin
	exec p_cyj_audit_opengate  @ret out,@msg out
	if @ret <> 0 
		goto GOOUT
	else
		update auditprg set hasdone = 'T'  where callform = 'p_cyj_audit_opengate'
	end
-- �����������뼰�����¼��
select @hasdone = hasdone, @needinst = needinst from  auditprg where callform = 'p_cyj_pos_deptrep'
if @hasdone = 'F' and @needinst = 'T'
	begin
	exec p_cyj_pos_deptrep @ret, @msg
	if @ret <> 0 
		goto GOOUT
	else
		update auditprg set hasdone = 'T'  where callform = 'p_cyj_pos_deptrep'
	end
-- �ۺ�����Ӫҵ���ͳ�Ʊ�
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
-- ҹ����˽�������
	exec p_cyj_audit_aftwork @ret out,@msg out
	if @ret <> 0 
		goto GOOUT
	end

GOOUT:
select @ret, @msg
;
