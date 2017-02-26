/*--------------------------------------------------------------------------------------------*/
//		部门或员工报表权限树列表
//    增加对于部门授权范围的处理 zhj
//    整个过程重新梳理书写(加注释、修改处理模式等) zhj 2008/8/4
/*--------------------------------------------------------------------------------------------*/

if exists(select 1 from sysobjects where name = 'p_cyj_maint_sys_rep_tree' and type = 'P')
	drop proc p_cyj_maint_sys_rep_tree
;
	
create proc p_cyj_maint_sys_rep_tree
	@code			char(10),         -- // 部门号或工号
	@grp			char(1),				-- // 是否是部门  T 部门权限，F 员工权限, Z 部门授权
	@search		char(20),			-- // 查询内容
	@selected	char(1)				-- // 只显示拥有的权限 T, F			
as
declare
	@dept				varchar(10),
	@class			varchar(10),
	@toclass			varchar(10),
	@data				varchar(30),
	@label			varchar(40),
	@no				int,
	@chk				char(1),
	@deptno			char(3),
	@tag				char(1),			-- // 区分部门和员工
	@reptag			char(1),			-- // 员工和部门权限是否相同
	@funcsort		varchar(10),
	@funccode		varchar(30) 

-- /* 报表标记和部门*/
if @grp = 'F' 
	select @reptag = reptag, @deptno = deptno from sys_empno where empno = @code 
else
	select  @deptno = @code, @reptag = 'F'

-- /* 权限标记*/
if @grp = 'T' 
	select @tag = 'D'
else if @grp = 'F' and @reptag = 'T' 
	select @tag = 'D'
else if @grp = 'F' and @reptag = 'F' 
	select @tag = 'E'
else if @grp = 'Z' 
	select @tag = 'Z'

-- /* 员工和部门权限相同时候转为部门权限方式处理 */
if @grp = 'F' and @reptag = 'T'
begin
	select @grp = 'T',@tag='D', @code = @deptno 
end 

-- /* 临时表*/
create table #tree 
(
	class			char(10)				not null,
	toclass		char(10)				not null,
	node			char(1)				not null,
	data			varchar(30)			not null,
	label			varchar(40)			not null,
	handle		int					not null,
	chk			char(1)				not null,
	search		char(1)				not null,					-- // T 满足查询条件的记录
	z				int		default 0	null 
)
create unique index index1 on #tree(class)

-- /* 1.插入根记录root*/
insert #tree(class,toclass,node,data,label,handle,chk,search) select '#', '-', 'd', 'root', 'FOXHIS 系统报表', 0, 'F', 'F'

-- /* 2.插入报表专家auto*/
select @chk = 'F'
if exists(select 1 from sys_rep_link where tag = @tag and code = @code and class='r' and funccode='%' and funcsort='%')
	select @chk = 'T'
insert #tree(class,toclass,node,data,label,handle,chk,search) select '%', '#', 'd', 'auto', '报表专家', 0, @chk, 'F'

-- /* 3.插入所有分类记录*/
declare c_auto_dept cursor for select code, descript from auto_dept where halt = 'F' order by code
open c_auto_dept
fetch c_auto_dept into @class, @label
while @@sqlstatus = 0
begin
	if exists(select 1 from sys_rep_link where tag = @tag and code=@code and class='r' and funccode = '%' and funcsort = @class)
		select @chk = 'T'
	else
		select @chk = 'F'
	select @toclass = substring(@class,1,datalength(rtrim(@class))-1)
	if @toclass is null
		select @toclass = '%'

	select @data = 'AutoDept!'+ @class
	insert #tree(class,toclass,node,data,label,handle,chk,search) select @class, @toclass, 'd', @data, @label, 0, @chk, 'F'
	fetch c_auto_dept into @class, @label
end
close c_auto_dept
deallocate cursor c_auto_dept 


-- /* 4.插入所有明细记录*/
select @no = 0
declare c_auto cursor for
	select a.dept, a.id, a.descript from auto_report a, auto_dept b where a.dept=b.code and b.halt='F' order by a.dept
open c_auto
fetch c_auto into @toclass, @data, @label
while @@sqlstatus = 0
begin
	if exists(select 1 from sys_rep_link where tag = @tag and code=@code and class='r' and funccode = @data and funcsort = @toclass)
		select @chk = 'T'
	else
		select @chk = 'F'
	select @no = @no + 1
	select @class = rtrim(@toclass) + '-' + convert(char(5), @no)
	insert #tree(class,toclass,node,data,label,handle,chk,search) select @class, @toclass, 'r', @data, @label, 0, @chk, 'F'
	fetch c_auto into @toclass, @data, @label
end
close c_auto
deallocate cursor c_auto

-- /* 4.对于非授权方式删除无权限的记录*/
if @grp <> 'Z'  
begin
	declare c_cur1 cursor for select funcsort, funccode from sys_rep_link where tag ='Z' and code = substring(@deptno,1,1) order by code
	open c_cur1
	fetch c_cur1 into  @funcsort, @funccode
	while @@sqlstatus = 0 
		begin
		update #tree set z = 1 where data = 'AutoDept!'+ @funcsort and @funccode = '%'
		update #tree set z = 1 where data = @funccode  
		update #tree set z = 1 where toclass = @funcsort and @funccode = '%'
		fetch c_cur1 into  @funcsort, @funccode
		end
	close c_cur1
	deallocate cursor c_cur1
	
	update #tree set z = 1 where toclass ='-' or toclass = '#'
   -- 在部门授权为全部报表情况下，明细一级报表无法显示问题修正 zhj 2008-12-1
	
	create table #cls 
	(
		class			char(10)				not null
	)
	insert into #cls(class) 
		select funcsort 
		from sys_rep_link 
		where tag ='Z' and code = substring(@deptno,1,1) and class='r' and funccode='%' 
		
	insert into #cls(class) 
		select code 
		from auto_dept 
		where exists(select 1 from sys_rep_link where tag ='Z' and code = substring(@deptno,1,1) and class='r' and funcsort='%' and funccode='%')
	
	insert into #cls(class) 
		select code from auto_dept a,#cls b where substring(a.code,1,datalength(b.class)) = b.class 
		
	update #tree set z = 1 where toclass in(select class from #cls)
	
	delete from #tree where z = 0
end


-- /* 5.更新权限标记*/
update #tree set chk='T' from sys_rep_link a
	where a.tag = @tag and #tree.node='r' and a.code=@code and #tree.data=a.funccode 
update #tree set chk='T' from sys_rep_link a
	where a.tag = @tag and #tree.node='d' and a.code=@code and #tree.data='AutoDept!'+ a.funcsort and a.funccode = '%'

-- /* 6.处理查询条件*/
if @search > '' 
begin
	update #tree set search = 'T' where label like '%' + rtrim(@search) + '%'
	declare c_searched cursor for 
		select class, toclass from #tree where search = 'T'  order by class
	open c_searched
	fetch c_searched into @class, @toclass
	while @@sqlstatus = 0 
		begin
		while @toclass <> '-'
			begin
			if not exists(select 1 from #tree where class = @toclass)
				continue
			update #tree set search = 'S' where class = @toclass
			select @toclass = toclass from #tree where class = @toclass
			end
		fetch c_searched into @class, @toclass
		end
	close c_searched
	deallocate cursor c_searched
	delete #tree where search <> 'S' and search <> 'T'
end

-- /* 7.只列有权限的列表，包括它们的上层*/
if @selected = 'T' 
begin
	declare c_selected cursor for 
		select class, toclass from #tree where chk = 'T' order by class
	open c_selected
	fetch c_selected into @class, @toclass
	while @@sqlstatus = 0 
		begin
		while @toclass <> '-'
			begin
			if not exists(select 1 from #tree where class = @toclass)
				continue
			update #tree set chk = 'C' where class = @toclass
			select @toclass = toclass from #tree where class = @toclass
			end
		fetch c_selected into @class, @toclass
		end
	close c_selected
	deallocate cursor c_selected
	delete #tree where chk <> 'T' and chk <> 'C' and class <> '#' and class <> '%' and class <> '-'
	update #tree set chk = 'F' where chk = 'C'
end

-- /* 8.返回*/
select class, toclass, node, data, label, handle, chk from #tree order by class

return 0
;

