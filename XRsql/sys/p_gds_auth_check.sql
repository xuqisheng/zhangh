
if exists(select * from sysobjects where name='p_gds_auth_check' and type ='P')
   drop proc p_gds_auth_check;
create proc p_gds_auth_check
   @empno			char(10),
   @authcode		varchar(30),
	@retmode			char(1)='S',
	@msg				varchar(60) output 
as
--------------------------------------------------------------------
--		Ա��Ȩ����֤
--		���� 0 ��ʾ��֤ͨ��, ����ʧ�� 
--
--		��������һ��Լ�� : sys_function.code = ���� 
--------------------------------------------------------------------
declare		@deptno		char(3),
				@code			char(4),
				@count		int,
				@ret			int

select @ret = 0, @msg = ''
select @empno = isnull(@empno, ''), @authcode = isnull(@authcode, '')
select @deptno = deptno from sys_empno where empno = @empno
if @@rowcount = 0 
	select @count = 0, @msg='%1������^�û�'
else
begin
	select @code = ''
	if charindex(substring(@authcode,1,1), '0123456789') = 0		-- Ȩ�޴��� 
	begin
		select @count = count(1) from sys_function where fun_des = @authcode 
		if @count = 1
			select @code = code from sys_function where fun_des  = @authcode 
		else
			select @msg='%1������^��Ȩ����'
	end
	else																			-- Ȩ������
	begin
		select @count = count(1) from sys_function where code = @authcode
		if @count = 1 
			select @code = @authcode
		else
			select @msg='%1������^��Ȩ����'
	end

	if @code <> '' 
	begin
		if exists(select 1 from sys_function_dtl where tag = 'E' and code = @empno)
		begin
			select @count = count(1) from sys_function_dtl a where a.tag = 'E' and a.code = @empno and a.funccode <> '%' and a.funccode = @code
			if @count = 0 
				select @count = count(1) from sys_function_dtl a, sys_function b  where a.tag = 'E' and a.code = @empno 	and a.funccode = '%' and a.funcsort = b.class and b.code=@code 
		end
		else
		begin
			select @count = count(1) from sys_function_dtl a where a.tag = 'D' and a.code = @deptno and a.funccode <> '%' and a.funccode = @code
			if @count = 0 
				select @count = count(1) from sys_function_dtl a, sys_function b  where a.tag = 'D' and a.code = @deptno and a.funccode = '%' and a.funcsort = b.class and b.code=@code 
		end
	end 
end

-- 
if @count > 0 
	select @ret = 0
else
begin
	select @ret = 1
	if @msg = ''
		select @msg = 'Ȩ�޲��㣬����ϵϵͳ����Ա'
end

if @retmode = 'S'
	select @ret, @msg 

return @ret 
;


