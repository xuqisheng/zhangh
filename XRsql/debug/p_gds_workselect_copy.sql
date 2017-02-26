//delete workselect where window='w_pos_master_list'; 
//delete worksheet where window='w_pos_master_list'; 
//delete worksta where window='w_pos_master_list'; 
//delete worksta_name where window='w_pos_master_list'; 
//delete workbutton where window='w_pos_master_list'; 
//delete workbutton_name where window='w_pos_master_list'; 
//

IF OBJECT_ID('p_gds_workselect_copy') IS NOT NULL
    DROP PROCEDURE p_gds_workselect_copy
;
create proc p_gds_workselect_copy
	@modu_id0		char(2),
	@window0			varchar(30),
	@modu_id1		char(2),
	@window1			varchar(30)
as

-- workselect
select * into #workselect from workselect where modu_id=@modu_id0 and window=@window0
if @@rowcount = 0
begin
	select 1, 'No workselect can be copied.'
	return
end
update #workselect set modu_id=@modu_id1, window=@window1
insert workselect select * from #workselect

-- worksheet
select * into #worksheet from worksheet where modu_id=@modu_id0 and window=@window0
if @@rowcount > 0
begin
	update #worksheet set modu_id=@modu_id1, window=@window1
	insert worksheet select * from #worksheet
end

-- worksta_name
select * into #worksta_name from worksta_name where window=@window0
if @@rowcount > 0
begin
	update #worksta_name set window=@window1
	insert worksta_name select * from #worksta_name
end

-- worksta
select * into #worksta from worksta where modu_id=@modu_id0 and window=@window0
if @@rowcount > 0
begin
	update #worksta set modu_id=@modu_id1, window=@window1
	insert worksta select * from #worksta
end

-- workbutton_name
select * into #workbutton_name from workbutton_name where window=@window0
if @@rowcount > 0
begin
	update #workbutton_name set window=@window1
	insert workbutton_name select * from #workbutton_name
end

-- workbutton
select * into #workbutton from workbutton where modu_id=@modu_id0 and window=@window0
if @@rowcount > 0
begin
	update #workbutton set modu_id=@modu_id1, window=@window1
	insert workbutton select * from #workbutton
end

return 0
;
