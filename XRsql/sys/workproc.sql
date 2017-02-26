
//----------------------------------------------------------------------------------------
//	得到某系统工作表的缺省状态选择列表
//
//		下列构造列为客户端存盘的时候使用
//			def		-- 是否使用缺省
//			showold	-- 当前存放的数据
//			showdef	-- 系统缺省的数据
//----------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_worksta_list")
	drop proc p_gds_worksta_list;
create proc p_gds_worksta_list
	@window		varchar(30),
	@modu_id		char(2),
	@lang			int=0		// 语种
as

select *,showold=show,showdef=show,def='T' into #worksta from worksta_name where window=@window

if exists(select 1 from worksta where window=@window and modu_id=@modu_id)
begin
	update #worksta set show='F', showold='F', def='F'
	update #worksta set show='T' from worksta a 
		where #worksta.window=a.window and #worksta.sta=a.sta
end

if @lang<>0
	select sta, show, descript1,showold,showdef,def from #worksta order by sequence
else
	select sta, show, descript,showold,showdef,def from #worksta order by sequence

return 
;




//----------------------------------------------------------------------------------------
//	得到某系统工作表的缺省功能按钮列表
//
//		下列构造列为客户端存盘的时候使用
//			def		-- 是否使用缺省
//			showold	-- 当前存放的数据
//			showdef	-- 系统缺省的数据
//----------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_workbutton_list")
	drop proc p_gds_workbutton_list;
create proc p_gds_workbutton_list
	@window		varchar(30),
	@modu_id		char(2),
	@tab_no			int,				// 0 - base define for modu_id
	@lang			int=0		// 语种
as

select *,showold=show,showdef=show,def='T' into #workbutton from workbutton_name where window=@window
-- alter table #workbutton add showold  char(1) default 'T' not null  -- 当前存放的数据 can not use alter !
-- alter table #workbutton add showdef  char(1) default 'T' not null  -- 系统缺省的数据

if exists(select 1 from workbutton where window=@window and modu_id=@modu_id and tab_no=@tab_no)
begin
	update #workbutton set show='F', showold='F', def='F'
	update #workbutton set show='T', showold='T' from workbutton a 
		where #workbutton.window=a.window and #workbutton.event=a.event and a.tab_no=@tab_no
end
else
begin
if @tab_no<>0 and exists(select 1 from workbutton where window=@window and modu_id=@modu_id and tab_no=0)
	begin
		update #workbutton set show='F', showold='F', def='F'
		update #workbutton set show='T', showold='T' from workbutton a 
			where #workbutton.window=a.window and #workbutton.event=a.event and a.tab_no=0
	end
end

if @lang<>0
	select event, show, descript1, showold, showdef, def, lic from #workbutton order by sequence
else
	select event, show, descript, showold,showdef, def, lic from #workbutton order by sequence

return 
;


//----------------------------------------------------------------------------------------
//	系统工作表的复制
//----------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_workselect_copy")
	drop proc p_gds_workselect_copy;
create proc p_gds_workselect_copy
	@window		varchar(30),
	@modu_fm		char(2),
	@modu_to		char(2)
as

if exists(select 1 from workselect where modu_id=@modu_to and window=@window)
return

if not exists(select 1 from workselect where modu_id=@modu_fm and window=@window)
return

select * into #workselect from workselect where modu_id=@modu_fm and window=@window
update #workselect set modu_id = @modu_to
insert workselect select * from #workselect

select * into #worksta from worksta where modu_id=@modu_fm and window=@window
update #worksta set modu_id = @modu_to
insert worksta select * from #worksta

select * into #worksheet from worksheet where modu_id=@modu_fm and window=@window
update #worksheet set modu_id = @modu_to
insert worksheet select * from #worksheet

select * into #workbutton from workbutton where modu_id=@modu_fm and window=@window
update #workbutton set modu_id = @modu_to
insert workbutton select * from #workbutton

return 
;
