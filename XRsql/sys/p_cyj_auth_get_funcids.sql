/*--------------------------------------------------------------------*/
//		取得操作员权限代码串
//    增加对于部门授权范围的处理 zhj
/*--------------------------------------------------------------------*/
if exists(select * from sysobjects where name='p_cyj_auth_get_funcids' and type ='P')
   drop proc p_cyj_auth_get_funcids
;

create proc p_cyj_auth_get_funcids
   @empno    char(10)
as

declare		@deptno		char(3),
				@tag			char(1),
				@code			varchar(10),
				@funcsort	varchar(10),
				@funccode	varchar(30) 

create table #func
(
	code		char(4)	 not null,
	descript char(30) default '' not null
)

select @deptno = deptno from sys_empno where empno = @empno
if exists(select 1 from sys_function_dtl where tag = 'E' and code = @empno)
begin
	select @tag = 'E',@code = @empno
end
else
begin
	select @tag = 'D',@code = @deptno
end

insert #func select a.funccode, b.fun_des from sys_function_dtl a, sys_function b 
	where a.tag = @tag and a.code = @code and a.funccode <> '%' and a.funccode = b.code

declare c_cur1 cursor for select funcsort from sys_function_dtl where tag =@tag and code = @code and funccode = '%' 
open c_cur1
fetch c_cur1 into  @funcsort 
while @@sqlstatus = 0 
begin
	if exists(select 1 from sys_function_dtl where tag = 'Z' and code = substring(@deptno,1,1) and funcsort = @funcsort and funccode = '%')
	begin
		insert #func select b.code ,b.fun_des from sys_function_dtl a, sys_function b  
			where a.tag = @tag and a.code = @code 	and a.funcsort = @funcsort and a.funccode = '%' and a.funcsort = b.class 
	end
	else
	begin 
		insert #func select a.funccode, b.fun_des from sys_function_dtl a, sys_function b 
			where a.tag = 'Z' and a.code = substring(@deptno,1,1) and a.funcsort = @funcsort and a.funccode <> '%' and a.funccode = b.code
	end
	fetch c_cur1 into  @funcsort 
end
close c_cur1
deallocate cursor c_cur1

select distinct rtrim(descript) from #func order by code

return 0
;


