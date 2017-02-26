
/*--------------------------------------------------------------------------------------------*/
//		����Ա����ɾ��Ա����ɾ������ʱ��Ȩ�޴���
//		����Ա��ʱĬ�ϴӲ��ſ���Ȩ��
/*--------------------------------------------------------------------------------------------*/

if exists(select 1 from sysobjects where name = 'p_cyj_maint_modi_func' and type ='P')
	drop proc p_cyj_maint_modi_func;

create proc p_cyj_maint_modi_func
	@empno			char(10),
	@deptno			char(3),
	@tag				char(1),						// A: ������D: ɾ��
	@group			char(1)						// T: ����, F:Ա��
as

if @tag = 'D' and @group <> 'T'
	begin
	delete sys_function_dtl where tag = 'E' and code = @empno
	delete sys_empno where empno = @empno
	end

if @tag = 'D' and @group = 'T'
	begin
	delete sys_function_dtl where tag = 'D' and code = @deptno
	delete basecode where cat = 'dept' and code = @deptno
	end
;


