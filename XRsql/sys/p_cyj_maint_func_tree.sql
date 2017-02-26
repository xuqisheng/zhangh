
if exists(select 1 from sysobjects where name ='p_cyj_maint_func_tree' and type = 'P')
	drop proc p_cyj_maint_func_tree;
create proc p_cyj_maint_func_tree
	@code			char(10),			-- 部门号或工号
	@grp			char(1),				-- T 部门权限，F 员工权限, Z 部门授权
	@search		char(30),			-- 内容限定
	@selected	char(1),				-- 只显示拥有的权限 T, F
	@langid		int
as
----------------------------------------------------------------------------------------------
--		部门或员工权限树列表
--    增加对于部门授权范围的处理 zhj
----------------------------------------------------------------------------------------------
declare
	@dept					varchar(10),
	@funcsort			varchar(10),
	@funccode			varchar(30),
	@functag				char(1)

create table #tree (
	class			char(10)				not null,
	toclass		char(10)				not null,
	node			char(1)				not null,
	data			varchar(30)			not null,

	label			varchar(40)			not null,
	handle		int					not null,
	chk			char(1)				not null,
	sequence		int		default 0	null, 
	z				int		default 0	null 
)
create unique index index1 on #tree(class)

if @search = null 
	select @search = ''


if @langid = 0 
	begin
	insert #tree(class,toclass,node,data,label,handle,chk) select code, class, 'r', code, descript, 0, 'F'  from sys_function where upper(descript) like '%' + upper(rtrim(@search)) + '%'
	insert #tree(class,toclass,node,data,label,handle,chk) select code, '#', 'd', code, descript, 0, 'F' from basecode where cat = 'function_class' --and upper(descript) like '%' + upper(rtrim(@search)) + '%'
	end
else
	begin
	insert #tree(class,toclass,node,data,label,handle,chk) select code, class, 'r', code, descript1, 0, 'F'  from sys_function where upper(descript) like '%' + upper(rtrim(@search)) + '%'
	insert #tree(class,toclass,node,data,label,handle,chk) select code, '#', 'd', code, descript1, 0, 'F' from basecode where cat = 'function_class' --and upper(descript) like '%' + upper(rtrim(@search)) + '%'
	end


if @grp <> 'Z'
begin
	if @grp= 'F'   
		select  @dept = deptno from sys_empno where empno = @code 
	else
		select  @dept = @code 

	declare c_cur1 cursor for select funcsort, funccode from sys_function_dtl where tag ='Z' and code = substring(@dept,1,1) order by code
	open c_cur1
	fetch c_cur1 into  @funcsort, @funccode
	while @@sqlstatus = 0 
		begin
		update #tree set z = 1 where class = @funccode 
		update #tree set z = 1 where class = @funcsort 
		if @funccode = '%'
			update #tree set z = 1 where toclass = @funcsort 
		fetch c_cur1 into  @funcsort, @funccode
		end
	close c_cur1
	deallocate cursor c_cur1
	
	delete from #tree where z = 0
end


-- -- 带进查询条件，要过滤调不符合条件的功能类别
if @search > '' 
	begin
	delete #tree where node = 'd' and upper(data) not like  '%' + upper(rtrim(@search)) + '%'  and class not in(select rtrim(toclass) from #tree b where b.node = 'r' )
	delete #tree where  toclass in (select code from basecode where cat = 'function_class' and upper(descript) like '%' + upper(rtrim(@search)) + '%')
	if @langid = 0 
		insert #tree(class,toclass,node,data,label,handle,chk) select code, class, 'r', code, descript, 0, 'F'  from sys_function  
			where class in (select code from basecode where cat = 'function_class' and upper(descript) like '%' + upper(rtrim(@search)) + '%')
	else
		insert #tree(class,toclass,node,data,label,handle,chk) select code, class, 'r', code, descript1, 0, 'F'  from sys_function  
			where class in (select code from basecode where cat = 'function_class' and upper(descript) like '%' + upper(rtrim(@search)) + '%')
	end


insert #tree(class,toclass,node,data,label,handle,chk) select '#', '-', 'd', '','权限列表', 0, 'F'

if @grp = 'F'              -- 个人权限
	select @functag = functag from sys_empno where empno = @code 
if @grp = 'F' and  @functag = 'F'       -- 员工权限，并且该员工的权限和部门不一致
begin
	declare c_cur cursor for select funcsort, funccode from sys_function_dtl where tag = 'E' and code = @code order by code
	open c_cur
	fetch c_cur into  @funcsort, @funccode
	while @@sqlstatus = 0 
		begin
		update #tree set chk = 'T' where class = @funccode 
		if @funccode = '%'
			update #tree set chk = 'T' where class = @funcsort and node = 'd'
		fetch c_cur into  @funcsort, @funccode
		end
	close c_cur
	deallocate cursor c_cur
end
else if ((@functag = 'T'  and @grp= 'F') or @grp= 'T')  -- 个人权限同部门一样，取部门号
begin
	if @functag = 'T'  and @grp= 'F'  -- 个人权限同部门一样，取部门号
		select  @code = deptno from sys_empno where empno = @code 
	declare c_cur1 cursor for select funcsort, funccode from sys_function_dtl where tag ='D' and code = @code order by code
	open c_cur1
	fetch c_cur1 into  @funcsort, @funccode
	while @@sqlstatus = 0 
		begin
		update #tree set chk = 'T' where class = @funccode 
		if @funccode = '%'
			update #tree set chk = 'T' where class = @funcsort and node = 'd'
		fetch c_cur1 into  @funcsort, @funccode
		end
	close c_cur1
	deallocate cursor c_cur1
end
else if @grp= 'Z'  -- 部门授权
begin
	declare c_cur1 cursor for select funcsort, funccode from sys_function_dtl where tag ='Z' and code = @code order by code
	open c_cur1
	fetch c_cur1 into  @funcsort, @funccode
	while @@sqlstatus = 0 
		begin
		update #tree set chk = 'T' where class = @funccode 
		if @funccode = '%'
			update #tree set chk = 'T' where class = @funcsort and node = 'd'
		fetch c_cur1 into  @funcsort, @funccode
		end
	close c_cur1
	deallocate cursor c_cur1
end

--
update #tree set sequence = a.sequence from basecode a where substring(#tree.class,1,2)=a.code and a.cat='function_class'
update #tree set sequence = 0 where class='#' 


-- -- 只列有权限的列表，包括它们的上层
if @selected = 'T'		
begin
	create table #tree1 (
		class			char(10)				not null,
		toclass		char(10)				not null,
		node			char(1)				not null,
		data			varchar(30)			not null,
	
		label			varchar(40)			not null,
		handle		int					not null,
		chk			char(1)				not null,
		sequence		int		default 0	null 
	)

	insert #tree1 
	select a.class,a.toclass,a.node,a.data,a.label,a.handle,a.chk,a.sequence from #tree a where a.chk = 'T' or a.class = '#' 
	union 
	select a.class,a.toclass,a.node,a.data,a.label,a.handle,a.chk,a.sequence from #tree a, #tree b where b.chk = 'T' and b.toclass = a.class and a.toclass = '#'

	select class,toclass,node,data,label,handle,chk from #tree1 order by sequence, class, toclass
end 
else
	select class,toclass,node,data,label,handle,chk from #tree order by sequence, class, toclass

;
