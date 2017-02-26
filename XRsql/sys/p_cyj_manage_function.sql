
/*--------------------------------------------------------------------------------------------*/
//		对部门或员工加减权限
//    增加对于部门授权范围的处理 zhj
/*--------------------------------------------------------------------------------------------*/

if exists(select 1 from sysobjects where name = 'p_cyj_manage_function' and type ='P')
	drop proc p_cyj_manage_function;
create proc p_cyj_manage_function
	@group			char(1),						//	T : 部门， F : 员工, Z:授权
	@code				char(10),					//	部门号或工号
	@funcsort		char(2),						// D : 功能类别，R : 功能项
	@funccode  		char(4),						//	功能代码或功能类别
	@mode				char(1)						//	A : 加功能，D : 减功能
as

if @mode = 'A' 
	begin
	if @group = 'T' 
		begin
		delete sys_function_dtl where tag = 'D' and funcsort = @funcsort and code = rtrim(@code) and funccode = @funccode
		insert sys_function_dtl(tag,code,funcsort,funccode) select 'D', rtrim(@code), @funcsort, @funccode
		end
	else if @group = 'F' 
		begin
		delete sys_function_dtl where  tag ='E' and funcsort = @funcsort and code = rtrim(@code) and funccode = @funccode
		insert sys_function_dtl(tag,code,funcsort,funccode) select 'E', rtrim(@code), @funcsort, @funccode
		end
	else if @group = 'Z' 
		begin
		delete sys_function_dtl where  tag ='Z' and funcsort = @funcsort and code = rtrim(@code) and funccode = @funccode
		insert sys_function_dtl(tag,code,funcsort,funccode) select 'Z', rtrim(@code), @funcsort, @funccode
		end
	end	
else
	begin
	if @group = 'T' 
		delete sys_function_dtl where tag ='D' and funcsort = @funcsort and code = rtrim(@code) and funccode = @funccode
	else if @group = 'F' 
		delete sys_function_dtl where tag ='E' and funcsort = @funcsort and code = rtrim(@code) and funccode = @funccode
	else if @group = 'Z' 
		delete sys_function_dtl where tag ='Z' and funcsort = @funcsort and code = rtrim(@code) and funccode = @funccode
	end	
-- // 删除多余功能记录，功能类选中了，明细记录必须删除
delete sys_function_dtl from sys_function_dtl a, sys_function_dtl b where a.tag = b.tag and a.code = b.code and a.funcsort = b.funcsort and b.funccode = '%' and a.funccode <>'%'
;