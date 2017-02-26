drop procedure p_cq_interface_operate;
create proc p_cq_interface_operate
	@appid	char(1),
	@groupid	char(2),
	@id		char(2),
	@code		char(20),
	@class	char(20)

as
declare
	@ret    integer
	
create table #operate
(	
	groupid     char(2),
	id				char(2),
	code			char(20),
	descript		char(20),
	descript1	char(40),
	wtype			char(20),
	window		char(40),
	parm			char(60),
	event			char(20),
	son			char(1),
	content		text
)

if @class = 'interface'
	begin
	if @code = '' 
		select groupid = a.groupid,id = a.id,code = a.code,descript = a.descript,descript1 = a.descript1, wtype = a.wtype,window = a.window,parm = a.parm,event = a.event,son = a.son,content = a.content
		 from interface_operate a where a.groupid = @groupid and a.id = @id and a.display = 'T' and charindex(@appid,appid) > 0 order by a.sequence
	else
		--菜单子项
		select groupid = a.groupid,id = a.id,code = a.item,descript = a.descript,descript1 = a.descript1, wtype = a.wtype,window = a.window,parm = a.parm,event = a.event,son = 'F',content = a.content
		from interface_son a where a.groupid = @groupid and a.id = @id and a.code = @code order by a.sequence
	end
else
--其他情况自由添加
	select groupid,id,code,descript,descript1, wtype,window,parm,event,son,content from interface_operate 
			where groupid = @groupid and id = @id order by sequence
;
