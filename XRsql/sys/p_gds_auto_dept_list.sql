/*--------------------------------------------------------------------------------------*/
//
//		报表专家查看权限．	 区分中英文
//
/*--------------------------------------------------------------------------------------*/
if exists(select 1 from sysobjects where name = 'p_gds_auto_dept_list' and type  = 'P')
	drop  proc p_gds_auto_dept_list;
create proc p_gds_auto_dept_list
	@empno			char(10),
	@entry			varchar(15),
	@langid			integer
as

declare
	@reptag 			char(1),
	@deptno			char(3),
	@depts			char(10),
	@modify 			char(1),
	@modifyexp 			char(1),
	@batch 			char(1)

select @reptag  = reptag, @deptno = deptno from sys_empno where empno = @empno

if @reptag = 'T'												-- 同部门权限一样
begin
	-- 是否有"修改报表"的权限
	if exists (select 1 from sys_function_dtl where tag = 'D' and code = @deptno and '00' like funcsort and '0013' like funccode)
		select @modify = 'T'
	else
		select @modify = 'F'
	-- 是否有"设置批量报表"的权限
	if exists (select 1 from sys_function_dtl where tag = 'D' and code = @deptno and '00' like funcsort and '0015' like funccode)
		select @batch = 'T'
	else
		select @batch = 'F'
	-- 是否有"定义快捷报表"的权限
	if exists (select 1 from sys_function_dtl where tag = 'D' and code = @deptno and '00' like funcsort and '0018' like funccode)
		select @modifyexp = 'T'
	else
		select @modifyexp = 'F'
end
	else																--	 同部门权限不一样
begin
	-- 是否有"修改报表"的权限
	if exists (select 1 from sys_function_dtl where tag = 'E' and code = @empno and '00' like funcsort and '0013' like funccode)
		select @modify = 'T'
	else
		select @modify = 'F'
	-- 是否有"设置批量报表"的权限
	if exists (select 1 from sys_function_dtl where tag = 'E' and code = @empno and '00' like funcsort and '0015' like funccode)
		select @batch = 'T'
	else
		select @batch = 'F'
	-- 是否有"定义快捷报表"的权限
	if exists (select 1 from sys_function_dtl where tag = 'E' and code = @empno and '00' like funcsort and '0018' like funccode)
		select @modifyexp = 'T'
	else
		select @modifyexp = 'F'
end

-- 只有超级用户与西软人员才能看到其他报表
if @deptno in ('0', 'X')
	select @depts = '%'
else
	select @depts = '[^Z]%'

-- ---------------------------------------------------------------------------------------------------------------
if @langid = 0														-- 中文
-- ---------------------------------------------------------------------------------------------------------------
begin
	if @reptag = 'T'												-- 同部门权限一样
	begin
		if @entry = 'Batch Rpts' and @batch = 'T'			-- 批量报表
			select '	' + code, descript from auto_batch
		else if @entry = 'Batch Rpts'
			select distinct b.empno, a.descript from auto_batch a, auto_empno b, auto_report c
				where '	' + a.code = b.empno and b.id = c.id and a.code like @depts
				and exists (select 1 from sys_rep_link d
				where d.code = @deptno and d.tag = 'D' and d.class = 'r'
				and (c.dept like substring(d.funcsort, 1, 1) + '%' or (d.funccode = '%' and d.funcsort = '%')))
				order by b.empno asc
		else if @entry = '###'									-- 报表专家
			select auto_dept.code, auto_dept.descript from auto_dept
				where datalength(rtrim(auto_dept.code)) =  1 and auto_dept.code like @depts
				and (@modify = 'T' or exists (select 1 from sys_rep_link a
				where a.code = @deptno and a.tag = 'D' and a.class = 'r'
				and (auto_dept.code like substring(a.funcsort, 1, 1) + '%' or (a.funccode = '%' and a.funcsort = '%'))))
				and auto_dept.halt='F'
				order by auto_dept.sequence, auto_dept.code asc
		else if @entry = '#_REPORT'
			select code,descript from auto_dept_exp where halt='F' and (empno=@empno or rtrim(empno)=null)  order by sequence
		else if @entry like 'EXP_%'
			-- select id,descript from auto_report_exp where halt='F' and groupid=@entry  and (@modifyexp = 'T' or exists (select 1 from auto_dept_exp a where empno =@empno and a.code = auto_report_exp.groupid)) order by seq
			select id,descript from auto_report_exp where halt='F' and groupid=@entry  order by seq
		else if @entry like 'EMP_%'
			select id,descript from auto_report_exp where halt='F' -- and rtrim(groupid)=rtrim(@entry)  and (@modifyexp = 'T' or exists (select 1 from auto_dept_exp a where empno =@empno and a.code = auto_report_exp.groupid)) order by seq
		else
			select auto_dept.code, auto_dept.descript from auto_dept
				where auto_dept.code like @entry + '%' and auto_dept.code like @depts and datalength(rtrim(auto_dept.code)) = datalength(@entry) + 1
				and (@modify = 'T' or exists (select 1 from sys_rep_link b
				where b.code = @deptno and b.tag = 'D' and b.class = 'r'
				and (auto_dept.code = b.funcsort or (auto_dept.code like rtrim(b.funcsort) + '%' and b.funccode = '%'))))
				and auto_dept.halt='F'
				order by  auto_dept.sequence, auto_dept.code asc
	end
	else																--	 同部门权限不一样
	begin
		if @entry = 'Batch Rpts' and @batch = 'T'			-- 批量报表
			select '	' + code, descript from auto_batch
		else if @entry = 'Batch Rpts'
			select distinct b.empno, a.descript from auto_batch a, auto_empno b, auto_report c
				where '	' + a.code = b.empno and b.id = c.id and a.code like @depts
				and exists (select 1 from sys_rep_link d
				where d.code = @empno and d.tag = 'E' and d.class = 'r'
				and (c.dept like substring(d.funcsort, 1, 1) + '%' or (d.funccode = '%' and d.funcsort = '%')))
				order by b.empno asc
		else if @modify = 'T' and @entry = '###'									-- 有权修改报表则显示所有类别
			select code, descript from auto_dept where auto_dept.halt='F' order by code asc
		else if @entry = '###'
			select auto_dept.code, auto_dept.descript from auto_dept
				where  datalength(rtrim(auto_dept.code)) =  1 and auto_dept.code like @depts
				and (@modify = 'T' or exists (select 1 from sys_rep_link a
				where a.code = @empno and a.tag = 'E' and a.class = 'r'
				and (auto_dept.code like substring(a.funcsort, 1, 1) + '%' or (a.funccode = '%' and a.funcsort = '%'))))
				and auto_dept.halt='F'
				order by auto_dept.sequence, auto_dept.code asc
		else if @entry = '#_REPORT'
			select code,descript from auto_dept_exp where halt='F' and (empno=@empno or rtrim(empno)=null) order by sequence
		else if @entry like 'EXP_%'
			-- select id,descript from auto_report_exp where halt='F' and groupid=@entry and (@modifyexp = 'T' or exists (select 1 from auto_dept_exp a where empno =@empno and a.code = auto_report_exp.groupid)) order by seq
			select id,descript from auto_report_exp where halt='F' and groupid=@entry  order by seq
		else if @entry like 'EMP_%'
			select id,descript from auto_report_exp where halt='F' and rtrim(groupid)=rtrim(@entry)  and (@modifyexp = 'T' or exists (select 1 from auto_dept_exp a where empno =@empno and a.code = auto_report_exp.groupid)) order by seq
		else
			select auto_dept.code, auto_dept.descript from auto_dept
				where auto_dept.code like @entry + '%' and auto_dept.code like @depts and datalength(rtrim(auto_dept.code)) = datalength(@entry) + 1
				and (@modify = 'T' or exists (select 1 from sys_rep_link b
				where b.code = @empno and b.tag = 'E' and b.class = 'r'
				and (auto_dept.code = b.funcsort or (auto_dept.code like rtrim(b.funcsort) + '%' and b.funccode = '%'))))
				and auto_dept.halt='F'
				order by  auto_dept.sequence, auto_dept.code asc
	end
end
-- ---------------------------------------------------------------------------------------------------------------
else																	-- 英文
-- ---------------------------------------------------------------------------------------------------------------
begin
	if @reptag = 'T'												-- 同部门权限一样
	begin
		if @entry = 'Batch Rpts' and @batch = 'T'			-- 批量报表
			select '	' + code, descript1 from auto_batch
		else if @entry = 'Batch Rpts'
			select distinct b.empno, a.descript1 from auto_batch a, auto_empno b, auto_report c
				where '	' + a.code = b.empno and b.id = c.id and a.code like @depts
				and exists (select 1 from sys_rep_link d
				where d.code = @deptno and d.tag = 'D' and d.class = 'r'
				and (c.dept like substring(d.funcsort, 1, 1) + '%' or (d.funccode = '%' and d.funcsort = '%')))
				order by b.empno asc
		else if @entry = '###'
			select auto_dept.code, auto_dept.descript1 from auto_dept
				where datalength(rtrim(auto_dept.code)) =  1 and auto_dept.code like @depts
				and (@modify = 'T' or exists (select 1 from sys_rep_link a
				where a.code = @deptno and a.tag = 'D' and a.class = 'r'
				and (auto_dept.code like substring(a.funcsort, 1, 1) + '%' or (a.funccode = '%' and a.funcsort = '%'))))
				and auto_dept.halt='F'
				order by auto_dept.sequence, auto_dept.code asc
		else if @entry = '#_REPORT'
			select code,descript1 from auto_dept_exp where halt='F' and (empno=@empno or rtrim(empno)=null)  order by sequence
		else if @entry like 'EXP_%'
			-- select id,descript from auto_report_exp where halt='F' and groupid=@entry  and (@modifyexp = 'T' or exists (select 1 from auto_dept_exp a where empno =@empno and a.code = auto_report_exp.groupid)) order by seq
			select id,descript1 from auto_report_exp where halt='F' and groupid=@entry  order by seq
		else if @entry like 'EMP_%'
			select id,descript1 from auto_report_exp where halt='F' -- and rtrim(groupid)=rtrim(@entry)  and (@modifyexp = 'T' or exists (select 1 from auto_dept_exp a where empno =@empno and a.code = auto_report_exp.groupid)) order by seq
		else
			select auto_dept.code, auto_dept.descript1 from auto_dept
				where auto_dept.code like @entry + '%' and auto_dept.code like @depts and datalength(rtrim(auto_dept.code)) = datalength(@entry) + 1
				and (@modify = 'T' or exists (select 1 from sys_rep_link b
				where b.code = @deptno and b.tag = 'D' and b.class = 'r'
				and (auto_dept.code = b.funcsort or (auto_dept.code like rtrim(b.funcsort) + '%' and b.funccode = '%'))))
				and auto_dept.halt='F'
				order by  auto_dept.sequence, auto_dept.code asc
	end
	else																--	 同部门权限不一样
	begin
		if @entry = 'Batch Rpts' and @batch = 'T'			-- 批量报表
			select '	' + code, descript1 from auto_batch
		else if @entry = 'Batch Rpts'
			select distinct b.empno, a.descript1 from auto_batch a, auto_empno b, auto_report c
				where '	' + a.code = b.empno and b.id = c.id and a.code like @depts
				and exists (select 1 from sys_rep_link d
				where d.code = @empno and d.tag = 'E' and d.class = 'r'
				and (c.dept like substring(d.funcsort, 1, 1) + '%' or (d.funccode = '%' and d.funcsort = '%')))
				order by b.empno asc
		else if @modify = 'T' and @entry = '###'									-- 有权修改报表则显示所有类别
			select code, descript1 from auto_dept where auto_dept.halt='F' order by code asc
		else if @entry = '###'
			select auto_dept.code, auto_dept.descript1 from auto_dept
				where  datalength(rtrim(auto_dept.code)) =  1 and auto_dept.code like @depts
				and (@modify = 'T' or exists (select 1 from sys_rep_link a
				where a.code = @empno and a.tag = 'E' and a.class = 'r'
				and (auto_dept.code like substring(a.funcsort, 1, 1) + '%' or (a.funccode = '%' and a.funcsort = '%'))))
				and auto_dept.halt='F'
				order by auto_dept.sequence, auto_dept.code asc
		else if @entry = '#_REPORT'
			select code,descript1 from auto_dept_exp where halt='F' and (empno=@empno or rtrim(empno)=null) order by sequence
		else if @entry like 'EXP_%'
			-- select id,descript1 from auto_report_exp where halt='F' and groupid=@entry and (@modifyexp = 'T' or exists (select 1 from auto_dept_exp a where empno =@empno and a.code = auto_report_exp.groupid)) order by seq
			select id,descript1 from auto_report_exp where halt='F' and groupid=@entry  order by seq
		else if @entry like 'EMP_%'
			select id,descript1 from auto_report_exp where halt='F' and rtrim(groupid)=rtrim(@entry)  and (@modifyexp = 'T' or exists (select 1 from auto_dept_exp a where empno =@empno and a.code = auto_report_exp.groupid)) order by seq
		else
			select auto_dept.code, auto_dept.descript1 from auto_dept
				where auto_dept.code like @entry + '%' and auto_dept.code like @depts and datalength(rtrim(auto_dept.code)) = datalength(@entry) + 1
				and (@modify = 'T' or exists (select 1 from sys_rep_link b
				where b.code = @empno and b.tag = 'E' and b.class = 'r'
				and (auto_dept.code = b.funcsort or (auto_dept.code like rtrim(b.funcsort) + '%' and b.funccode = '%'))))
				and auto_dept.halt='F'
				order by  auto_dept.sequence, auto_dept.code asc
	end
end



return 0
;
