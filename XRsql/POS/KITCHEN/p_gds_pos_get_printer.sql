if exists (select 1 from sysobjects where name='p_gds_pos_get_printer' and type='P')
	drop procedure p_gds_pos_get_printer;

create proc p_gds_pos_get_printer
	@menu			char(10),
	@plucode		char(15),
	@kitchen 	char(3) 	output ,
	@printer		char(3)	output
as
------------------------------------------------------------------------------------------------
--
--  �õ�����Ĳ˶�Ӧ�ĳ�����ӡ��
--																										2003/10/28	cyj
------------------------------------------------------------------------------------------------
declare
	@deptcode	char(4),
	@deptno		char(2),
	@pccode		char(3),
	@flag			char(10),
	@ret			int,
	@msg			char(60)

select @ret = 0, @msg = 'ok', @printer='',@kitchen=''
select @pccode=pccode from pos_menu where menu=@menu
if @@rowcount = 0
begin
	select @ret=1, @msg='�˵�������'
	return @ret
end
/*
select @deptcode = max(dept) from pos_prnscope
	where @pccode like rtrim(dept) + '%' and @plucode like rtrim(plu_code) + '%'

if @deptcode is null 
	select @deptcode = max(dept) from pos_prnscope
		where dept = "����" and @plucode like rtrim(plu_code) + '%'

if @deptcode is not null
	begin
	select @kitchen=code from pos_prnscope
	 where dept = @deptcode 
			and plu_code = (select max(plu_code) from pos_prnscope 
									where dept=@deptcode and @plucode like rtrim(plu_code) + '%')
	if  @@rowcount = 0 or @kitchen is null
		select @ret = 1, @msg='ƥ�����', @kitchen = '', @printer=''
	else
		select @printer = printer from pos_kitchen where code = @kitchen
	end
else
	select @ret = 1,@msg='û�ж�Ӧ�Ĵ�ӡ������'
*/
return @ret;
