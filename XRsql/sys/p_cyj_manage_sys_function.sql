
/*--------------------------------------------------------------------------------------------*/
//		�������޸�ϵͳȨ��
//		
/*--------------------------------------------------------------------------------------------*/

if exists(select 1 from sysobjects where name = 'p_cyj_manage_sys_function' and type ='P')
	drop proc p_cyj_manage_sys_function;

create proc p_cyj_manage_sys_function
	@class			char(2),						// Ȩ�����
	@code				char(4),						// Ȩ�޴���
	@descript		char(30),					// ����
	@descript1		char(30)						// Ӣ������
as

if exists(select 1 from sys_function where class = @class and code = @code)
	delete sys_function where class = @class and code = @code
insert into sys_function(code,class,descript,descript1,fun_des) select @code, @class, @descript,rtrim(@descript) + '_e', @descript1
;


