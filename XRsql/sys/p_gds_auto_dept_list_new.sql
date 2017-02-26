/*--------------------------------------------------------------------------------------*/
//
//		报表专家查看权限．	 区分中英文
//
/*--------------------------------------------------------------------------------------*/
if exists(select 1 from sysobjects where name = 'p_gds_auto_dept_list_new' and type  = 'P')
	drop  proc p_gds_auto_dept_list_new;
create proc p_gds_auto_dept_list_new
	@empno			char(10),
	@entry			varchar(10),
	@langid			integer
as

declare
	@reptag 			char(1),
	@deptno			char(3),
	@modify 			char(1),
	@batch 			char(1)

select @reptag  = reptag, @deptno = deptno from sys_empno where empno = @empno
-- 是否有"修改报表"的权限
if exists (select 1 from sys_function_dtl where tag = 'D' and code = @deptno and '0013' like funcsort + funccode)
	select @modify = 'T'
else
	select @modify = 'F'
-- 是否有"设置批量报表"的权限
if exists (select 1 from sys_function_dtl where tag = 'D' and code = @deptno and '0015' like funcsort + funccode)
	select @batch = 'T'
else
	select @batch = 'F'

if @langid = 0														-- 中文
	begin
	if @reptag = 'T'												-- 同部门权限一样
		begin
		if @entry = 'Batch Rpts' and @batch = 'T'			-- 批量报表
			select '	' + code, descript from basecode where cat = 'adtrep' order by code
		else if @entry = 'Batch Rpts'
			select distinct b.empno, a.descript from basecode a, auto_empno b, auto_report c
				where a.cat = 'adtrep' and '	' + a.code = b.empno and b.id = c.id
				and exists (select 1 from sys_rep_link d
					where d.code = @deptno and d.tag = 'D' and d.class = 'r'
					and (c.dept like substring(d.funcsort, 1, 1) + '%' or (d.funccode = '%' and d.funcsort = '%')))
				order by b.empno asc
		else if @entry = '###'									-- 报表专家
			select auto_dept.code, auto_dept.descript from auto_dept
				where datalength(rtrim(auto_dept.code)) =  1
				and (@modify = 'T' or exists (select 1 from sys_rep_link a
					where a.code = @deptno and a.tag = 'D' and a.class = 'r'
					and (auto_dept.code like substring(a.funcsort, 1, 1) + '%' or (a.funccode = '%' and a.funcsort = '%'))))
				order by auto_dept.code asc
		else
			select auto_dept.code, auto_dept.descript from auto_dept
				where auto_dept.code like @entry + '%'
				and datalength(rtrim(auto_dept.code)) = datalength(@entry) + 1
				and (@modify = 'T' or exists (select 1 from sys_rep_link b
					where b.code = @deptno and b.tag = 'D' and b.class = 'r'
					and (auto_dept.code = b.funcsort or (auto_dept.code like rtrim(b.funcsort) + '%' and b.funccode = '%'))))
		order by  auto_dept.code asc
		end
	else																--	 同部门权限不一样
		begin
		if @entry = 'Batch Rpts' and @batch = 'T'			-- 批量报表
			select '	' + code, descript1 from basecode where cat = 'adtrep' order by code
		else if @entry = 'Batch Rpts'
			select distinct b.empno, a.descript from basecode a, auto_empno b, auto_report c
				where a.cat = 'adtrep' and '	' + a.code = b.empno and b.id = c.id
				and exists (select 1 from sys_rep_link d
					where d.code = @empno and d.tag = 'E' and d.class = 'r'
					and (c.dept like substring(d.funcsort, 1, 1) + '%' or (d.funccode = '%' and d.funcsort = '%')))
				order by b.empno asc
		else if @entry = '###'
			select auto_dept.code, auto_dept.descript from auto_dept
				where  datalength(rtrim(auto_dept.code)) =  1
				and (@modify = 'T' or exists (select 1 from sys_rep_link a
					where a.code = @empno and a.tag = 'E' and a.class = 'r'
					and (auto_dept.code like substring(a.funcsort, 1, 1) + '%' or (a.funccode = '%' and a.funcsort = '%'))))
				order by auto_dept.code asc
		else
			select auto_dept.code, auto_dept.descript from auto_dept
				where auto_dept.code like @entry + '%'
				and datalength(rtrim(auto_dept.code)) = datalength(@entry) + 1
				and (@modify = 'T' or exists (select 1 from sys_rep_link b
					where b.code = @empno and b.tag = 'E' and b.class = 'r'
					and (auto_dept.code = b.funcsort or (auto_dept.code like rtrim(b.funcsort) + '%' and b.funccode = '%'))))
		order by  auto_dept.code asc
		end
	end
else																	-- 英文
	begin
	if @reptag = 'T'												-- 同部门权限一样
		begin
		if @entry = 'Batch Rpts' and @batch = 'T'			-- 批量报表
			select '	' + code, descript1 from basecode where cat = 'adtrep' order by code
		else if @entry = 'Batch Rpts'
		  select distinct b.empno, a.descript1 from basecode a, auto_empno b, auto_report c
				where a.cat = 'adtrep' and '	' + a.code = b.empno and b.id = c.id
				and exists (select 1 from sys_rep_link d
					where d.code = @deptno and d.tag = 'D' and d.class = 'r'
					and (c.dept like substring(d.funcsort, 1, 1) + '%' or (d.funccode = '%' and d.funcsort = '%')))
				order by b.empno asc
		else if @entry = '###'
		  select auto_dept.code, auto_dept.descript1 from auto_dept
				where datalength(rtrim(auto_dept.code)) =  1
				and (@modify = 'T' or exists (select 1 from sys_rep_link a
					where a.code = @deptno and a.tag = 'D' and a.class = 'r'
					and (auto_dept.code like substring(a.funcsort, 1, 1) + '%' or (a.funccode = '%' and a.funcsort = '%'))))
				order by auto_dept.code asc
		else
		  select auto_dept.code, auto_dept.descript1 from auto_dept
				where auto_dept.code like @entry + '%'
				and datalength(rtrim(auto_dept.code)) = datalength(@entry) + 1
				and (@modify = 'T' or exists (select 1 from sys_rep_link b
					where b.code = @deptno and b.tag = 'D' and b.class = 'r'
					and (auto_dept.code = b.funcsort or (auto_dept.code like rtrim(b.funcsort) + '%' and b.funccode = '%'))))
		order by  auto_dept.code asc
		end
	else																--	 同部门权限不一样
		begin
		if @entry = 'Batch Rpts' and @batch = 'T'			-- 批量报表
			select '	' + code, descript1 from basecode where cat = 'adtrep' order by code
		else if @entry = 'Batch Rpts'
		  select distinct b.empno, a.descript1 from basecode a, auto_empno b, auto_report c
				where a.cat = 'adtrep' and '	' + a.code = b.empno and b.id = c.id
				and exists (select 1 from sys_rep_link d
					where d.code = @empno and d.tag = 'E' and d.class = 'r'
					and (c.dept like substring(d.funcsort, 1, 1) + '%' or (d.funccode = '%' and d.funcsort = '%')))
				order by b.empno asc
		else if @modify = 'T'									-- 有权修改报表则显示所有类别
			select code, descript1 from auto_dept order by code asc
		else if @entry = '###'
		  select auto_dept.code, auto_dept.descript1 from auto_dept
				where  datalength(rtrim(auto_dept.code)) =  1
				and (@modify = 'T' or exists (select 1 from sys_rep_link a
					where a.code = @empno and a.tag = 'E' and a.class = 'r'
					and (auto_dept.code like substring(a.funcsort, 1, 1) + '%' or (a.funccode = '%' and a.funcsort = '%'))))
				order by auto_dept.code asc
		else
		  select auto_dept.code, auto_dept.descript1 from auto_dept
				where auto_dept.code like @entry + '%'
				and datalength(rtrim(auto_dept.code)) = datalength(@entry) + 1
				and (@modify = 'T' or exists (select 1 from sys_rep_link b
					where b.code = @empno and b.tag = 'E' and b.class = 'r'
					and (auto_dept.code = b.funcsort or (auto_dept.code like rtrim(b.funcsort) + '%' and b.funccode = '%'))))
		order by  auto_dept.code asc
		end
	end

return 0
;
