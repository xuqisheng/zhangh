delete basecode where cat='control_panel';

insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '010', '总房数', 'Total Rooms', 'F', 'F', 10, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '020', '维修房', 'Out of Order', 'F', 'F', 20, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '030', '可用房', 'Room to Rent', 'F', 'F', 30, '65280','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '040', '确认预订', 'Definite Reservations', 'F', 'F', 40, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '050', '空房数', 'Available Rooms', 'F', 'F', 50, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '060', '锁定房', 'Out of Service', 'F', 'F', 60, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '070', '临时预订', 'Tentative Reservation', 'F', 'F', 70, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '080', '最小空房数', 'Minimum Availability', 'F', 'F', 80, '456678','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '090', 'House Overbooking', 'House Overbooking', 'F', 'F', 90, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '240', 'Room Type Overbooking', 'Room Type Overbooking', 'F', 'F', 95, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '100', '可售房', 'Rooms to Sell', 'F', 'F', 100, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '110', '已售房', 'Total Reserved', 'F', 'F', 110, '456678','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '120', '出租率％', 'Occupancy %', 'F', 'F', 120, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '130', '最大出租率％', 'Maximum Occ. %', 'F', 'F', 130, '16711935','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '140', 'Waitlist', 'Waitlist', 'F', 'F', 140, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '150', 'Blocks', 'Blocks', 'F', 'F', 150, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '160', 'Turnaway', 'Turnaway', 'F', 'F', 160, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '170', '事件', 'Event', 'F', 'F', 170, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '180', 'Day Type', 'Day Type', 'F', 'F', 180, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '190', '在店人数', 'People In-House', 'F', 'F', 190, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '200', '本日抵达房数', 'Arrival Rooms', 'F', 'F', 200, '456678','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '210', '本日抵达人数', 'Arrival Persons', 'F', 'F', 210, '','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '220', '本日离开房数', 'Departure Rooms', 'F', 'F', 220, '456678','F');
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) values ('control_panel', '230', '本日离开人数', 'Departure Persons', 'F', 'F', 230, '','F');

if exists(select * from sysobjects where name = "p_gl_public_control_panel")
	drop proc p_gl_public_control_panel;

create proc p_gl_public_control_panel
	@date				datetime,
	@types			varchar(255) = '%'
as

declare
	@bdate			datetime,
	@cdate			datetime,
	@quantity		integer, 
	@qty010			integer, 
	@qty020			integer, 
	@qty060			integer, 
	@count			integer, 
	@ntmp				int,
	@descript1		char(30),
	@code				char(3)


create table #control_panel
(
	date				datetime, 
	code				char(3)			not null,
	quantity1		money				default 0 null,
	quantity2		money				default 0 null,
	quantity			money				default 0 null
)
create table #print
(
	code				char(3)			not null,
	descript			char(50)			not null,
	descript1		char(50)			not null,
	day0				varchar(20)		null,
	day1				varchar(20)		null,
	day2				varchar(20)		null,
	day3				varchar(20)		null,
	day4				varchar(20)		null,
	day5				varchar(20)		null,
	day6				varchar(20)		null,
	format			char(50)			default '' not null,
	alignment		integer			default 1 null,					-- 对齐方式
	sequence			integer			null,
	color				integer			default 0	not null
)

select @bdate = bdate1, @count = 0 from sysdata 
declare c_basecode cursor for select code, descript1 from basecode where cat = 'control_panel' order by sequence
while @count < 7
begin
	select @cdate = dateadd(dd, @count, @date)
	open c_basecode
	fetch c_basecode into @code, @descript1
	while @@sqlstatus = 0
	begin
		exec p_gds_reserve_rsv_index @cdate, @types, @descript1, 'R', @quantity output
		insert #control_panel (date, code, quantity) select @cdate, @code, @quantity
		fetch c_basecode into @code, @descript1
	end
	close c_basecode
	select @count = @count + 1
end
deallocate cursor c_basecode

-- 转换成显示格式
insert #print (code, descript, descript1, sequence, color) 
	select code, descript, descript1, sequence, convert(int, grp) from basecode where cat = 'control_panel'

select @count = 0
while @count < 7
begin
	select @cdate = dateadd(dd, @count, @date)
	if @count = 0
	begin
		update #print set day0 = convert(varchar(20), round(a.quantity,0)) from #control_panel a
			where a.date = @cdate and #print.code = a.code
		update #print set day0 = isnull((select a.factor from rmrate_calendar a where a.date=@cdate), '') where #print.code = '180'
	end
	else if @count = 1
	begin
		update #print set day1 = convert(varchar(20), round(a.quantity,0)) from #control_panel a
			where a.date = @cdate and #print.code = a.code
		update #print set day1 = isnull((select a.factor from rmrate_calendar a where a.date=@cdate), '') where #print.code = '180'
	end
	else if @count = 2
	begin
		update #print set day2 = convert(varchar(20), round(a.quantity,0)) from #control_panel a
			where a.date = @cdate and #print.code = a.code
		update #print set day2 = isnull((select a.factor from rmrate_calendar a where a.date=@cdate), '') where #print.code = '180'
	end
	else if @count = 3
	begin
		update #print set day3 = convert(varchar(20), round(a.quantity,0)) from #control_panel a
			where a.date = @cdate and #print.code = a.code
		update #print set day3 = isnull((select a.factor from rmrate_calendar a where a.date=@cdate), '') where #print.code = '180'
	end
	else if @count = 4
	begin
		update #print set day4 = convert(varchar(20), round(a.quantity,0)) from #control_panel a
			where a.date = @cdate and #print.code = a.code
		update #print set day4 = isnull((select a.factor from rmrate_calendar a where a.date=@cdate), '') where #print.code = '180'
	end
	else if @count = 5
	begin
		update #print set day5 = convert(varchar(20), round(a.quantity,0)) from #control_panel a
			where a.date = @cdate and #print.code = a.code
		update #print set day5 = isnull((select a.factor from rmrate_calendar a where a.date=@cdate), '') where #print.code = '180'
	end
	else if @count = 6
	begin
		update #print set day6 = convert(varchar(20), round(a.quantity,0)) from #control_panel a
			where a.date = @cdate and #print.code = a.code
		update #print set day6 = isnull((select a.factor from rmrate_calendar a where a.date=@cdate), '') where #print.code = '180'
	end
	select @count = @count + 1
end

-- format 
update #print set day0=substring(day0,1,charindex('.',day0)-1) where charindex('.',day0)>0 
update #print set day1=substring(day1,1,charindex('.',day1)-1) where charindex('.',day1)>0 
update #print set day2=substring(day2,1,charindex('.',day2)-1) where charindex('.',day2)>0 
update #print set day3=substring(day3,1,charindex('.',day3)-1) where charindex('.',day3)>0 
update #print set day4=substring(day4,1,charindex('.',day4)-1) where charindex('.',day4)>0 
update #print set day5=substring(day5,1,charindex('.',day5)-1) where charindex('.',day5)>0 
update #print set day6=substring(day6,1,charindex('.',day6)-1) where charindex('.',day6)>0 


-- update #print set format = '0.00%' where code in ('120', '130')
update #print set color=16777215 where color is null or color<=0 

select code, descript, descript1, day0, day1, day2, day3, day4, day5, day6, format, alignment,color from #print order by sequence
;
