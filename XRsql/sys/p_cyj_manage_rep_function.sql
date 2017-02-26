
/*--------------------------------------------------------------------------------------------*/
//		部门或员工报表权限设置
//    增加对于部门授权范围的处理 zhj
/*--------------------------------------------------------------------------------------------*/

if exists(select 1 from sysobjects where name = 'p_cyj_manage_rep_function' and type = 'P')
	drop proc p_cyj_manage_rep_function;
create proc p_cyj_manage_rep_function
	@group			char(1),						//	T : 部门， F : 员工, Z:授权
	@code				char(10),					//	部门号或工号
   @class  		 	char(1),						// 报表大类别 a - 夜审报表，r - 定制报表
	@funcsort		char(10),					// 报表类别
	@funccode  		char(30),					//	报表代码
	@mode				char(1)						//	A : 加功能，D : 减功能
as

declare
   @thisgrp 		char(2),
   @class1 			varchar(20),
	@funcsort1		varchar(10),
	@ilen				tinyint,
	@tag				char(1)

if @group = 'T'
	select @tag = 'D'
else if @group = 'F'
	select @tag = 'E'
else if @group = 'Z'
	select @tag = 'Z'

if charindex(@mode, 'AD')=0
	or charindex(@class, 'ar')=0
	or rtrim(@funcsort) is null
	return 0

if @mode = 'A'
	begin
	if @class = 'a'
		begin
		if @funccode = '%'
			begin
			delete sys_rep_link where code = @code and class='a' and tag = @tag
			insert sys_rep_link select @tag, @code, 'a', '%', '%'
			end
		else
			if not exists(select 1 from sys_rep_link where tag = @tag and code = @code  and class='a' and (funccode='%' or funccode=@funccode))
				insert sys_rep_link select @tag, @code, 'a', '%', @funccode
		end
	else
		begin
		if @funccode = '%'
			begin
			delete sys_rep_link where tag = @tag and code = @code and class='r' and funcsort like rtrim(@funcsort)+'%'
			if exists(select 1 from sys_rep_link where  tag = @tag and code = @code and funccode = '%' and @funcsort like rtrim(funcsort)+'%' and class='r')
				return
			insert sys_rep_link select @tag, @code, 'r', @funcsort, '%'
			end
		else
			if not exists(select 1 from sys_rep_link where tag = @tag and code=@code and class='r' and (funccode=@funccode or (funccode='%' and @funcsort like rtrim(funcsort)+'%')))
				insert sys_rep_link select @tag, @code, 'r', @funcsort, @funccode
		end
	end
else
	begin
	if @class = 'a'
		begin
		if @funccode = '%'
			delete sys_rep_link where tag = @tag and code=@code and class='a' and funccode = '%'
		else
			if exists(select 1 from sys_rep_link where tag = @tag and code=@code and class='a' and funccode=@funccode)
				delete sys_rep_link where tag = @tag and code = @code and class='a' and funccode=@funccode
			else if exists(select 1 from sys_rep_link where tag = @tag and code = @code and class='a' and funccode='%')
				begin
					delete sys_rep_link where tag = @tag and code = @code and class='a'
					insert sys_rep_link select @tag, @code, 'a', '%', 'Adtrep!'+rtrim(convert(char(5),order_)) from adtrep
					delete sys_rep_link where tag = @tag and code = @code and class='a' and funccode=@funccode
				end
		end
	else
		begin
		if @funccode = '%'
			begin
			delete sys_rep_link where tag = @tag and code=@code and class='r' and funcsort=@funcsort and funccode='%'

			if exists(select 1 from sys_rep_link where tag = @tag and code=@code and class='r' and funccode='%' and @funcsort like rtrim(funcsort)+'%')
				begin
				select @ilen = datalength(rtrim(@funcsort))
				if @ilen = 1
					begin
					delete sys_rep_link where tag = @tag and code=@code and class='r' and funcsort='%' and funccode='%'
					insert sys_rep_link select @tag, @code,  'r', code, '%' from auto_dept where datalength(rtrim(code))=@ilen and code<>@funcsort
					end
				else
					begin
					select @funcsort1 = substring(@funcsort, 1, @ilen - 1)
					insert sys_rep_link select @tag, @code, 'r', code, '%'  from auto_dept where code like @funcsort1+'%' and datalength(rtrim(code))=@ilen and code<>@funcsort
					insert sys_rep_link select @tag, @code, 'r', dept, id from auto_report where dept = @funcsort1
					if exists(select 1 from sys_rep_link where tag = @tag and code = @code and class='r' and funcsort=@funcsort1 and funccode='%')
						delete sys_rep_link where code=@code and class='r' and funcsort=@funcsort1 and funccode='%'
					else
						exec p_cyj_manage_rep_function @group, 'r', @funcsort1, '%', @code, 'D'
					end
				end
			end
		else
			begin
			delete sys_rep_link where tag = @tag and code=@code and class='r' and funccode=@funccode and funcsort=@funcsort

			if exists(select 1 from sys_rep_link where tag = @tag and code=@code and class='r' and funccode='%' and @funcsort like rtrim(funcsort)+'%')
				begin
				select @ilen = datalength(rtrim(@funcsort))
				insert sys_rep_link select @tag, @code, 'r', code, '%' from auto_dept where code like @funcsort+'%' and datalength(rtrim(code))=@ilen+1
				insert sys_rep_link select @tag, @code, 'r', dept, id from auto_report where dept=@funcsort and id<>@funccode
				if exists(select 1 from sys_rep_link where tag = @tag and code = @code and  class='r' and funcsort=@funcsort and funccode='%')
					delete sys_rep_link where tag = @tag and code=@code and class='r' and funcsort=@funcsort and funccode='%'
				else
					exec p_cyj_manage_rep_function @group, 'r', @funcsort, '%', @code, 'D'
				end
			end
		end
	end

return 0
;
