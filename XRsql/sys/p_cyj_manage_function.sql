
/*--------------------------------------------------------------------------------------------*/
//		�Բ��Ż�Ա���Ӽ�Ȩ��
//    ���Ӷ��ڲ�����Ȩ��Χ�Ĵ��� zhj
/*--------------------------------------------------------------------------------------------*/

if exists(select 1 from sysobjects where name = 'p_cyj_manage_function' and type ='P')
	drop proc p_cyj_manage_function;
create proc p_cyj_manage_function
	@group			char(1),						//	T : ���ţ� F : Ա��, Z:��Ȩ
	@code				char(10),					//	���źŻ򹤺�
	@funcsort		char(2),						// D : �������R : ������
	@funccode  		char(4),						//	���ܴ���������
	@mode				char(1)						//	A : �ӹ��ܣ�D : ������
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
-- // ɾ�����๦�ܼ�¼��������ѡ���ˣ���ϸ��¼����ɾ��
delete sys_function_dtl from sys_function_dtl a, sys_function_dtl b where a.tag = b.tag and a.code = b.code and a.funcsort = b.funcsort and b.funccode = '%' and a.funccode <>'%'
;