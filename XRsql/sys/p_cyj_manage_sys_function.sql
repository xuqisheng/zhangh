
/*--------------------------------------------------------------------------------------------*/
//		新增或修改系统权限
//		
/*--------------------------------------------------------------------------------------------*/

if exists(select 1 from sysobjects where name = 'p_cyj_manage_sys_function' and type ='P')
	drop proc p_cyj_manage_sys_function;

create proc p_cyj_manage_sys_function
	@class			char(2),						// 权限类别
	@code				char(4),						// 权限代码
	@descript		char(30),					// 描述
	@descript1		char(30)						// 英文描述
as

if exists(select 1 from sys_function where class = @class and code = @code)
	delete sys_function where class = @class and code = @code
insert into sys_function(code,class,descript,descript1,fun_des) select @code, @class, @descript,rtrim(@descript) + '_e', @descript1
;


