
if exists(select * from sysobjects where name='p_gds_auth_check' and type ='P')
   drop proc p_gds_auth_check;
create proc p_gds_auth_check
   @empno			char(10),
   @authcode		varchar(30),
	@retmode			char(1)='S',
	@msg				varchar(60) output 
as
--------------------------------------------------------------------
--		员工权限验证
--		返回 0 表示验证通过, 否则失败 
--
--		本过程有一个约定 : sys_function.code = 数字 
--------------------------------------------------------------------
declare		@deptno		char(3),
				@code			char(4),
				@count		int,
				@ret			int

select @ret = 0, @msg = ''
select @empno = isnull(@empno, ''), @authcode = isnull(@authcode, '')
select @deptno = deptno from sys_empno where empno = @empno
if @@rowcount = 0 
	select @count = 0, @msg='%1不存在^用户'
else
begin
	select @code = ''
	if charindex(substring(@authcode,1,1), '0123456789') = 0		-- 权限代码 
	begin
		select @count = count(1) from sys_function where fun_des = @authcode 
		if @count = 1
			select @code = code from sys_function where fun_des  = @authcode 
		else
			select @msg='%1不存在^授权代码'
	end
	else																			-- 权限数字
	begin
		select @count = count(1) from sys_function where code = @authcode
		if @count = 1 
			select @code = @authcode
		else
			select @msg='%1不存在^授权代码'
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
		select @msg = '权限不足，请联系系统管理员'
end

if @retmode = 'S'
	select @ret, @msg 

return @ret 
;


