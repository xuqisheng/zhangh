-- ------------------------------------------------------------------------------------
--  存量表  -- Kempinski
-- ------------------------------------------------------------------------------------
if object_id('rmtype_inventory') is not null
	drop table rmtype_inventory
;
create table rmtype_inventory(
	id			int default 0	null,			-- 日期的次序
	date		datetime			null,			-- 日期
	datedes	char(10)			null,			-- 星期的描述
	sort		char(4)			null,			-- 排序（列方向）
	type		char(5)			null,			-- 房类
	des		varchar(30)		null,			-- 房类描述
	quan		money default 0	null,		-- 数量
	rep		int	default 0	null		-- 报表模式取舍标志
);

if object_id("p_gds_reserve_type_unsold_pan") is not null
	drop proc p_gds_reserve_type_unsold_pan;
create proc p_gds_reserve_type_unsold_pan
	@s_time			datetime,       	-- 开始时间
	@e_time			datetime,       	-- 开始时间
	@mode				char(1),       	-- 报表模式-> 针对 rep 的数值进行取舍
	@langid			int=0
as

declare 
     --	@e_time			datetime,
			@id				int,
			@sort				char(2),
			@ttl				int,
			@value			int,
			@occ				int

--select @e_time  =dateadd(dd, 14, @s_time)  -- 2 week

if datediff(dd,@s_time,@e_time) > 31
select @e_time  =dateadd(dd, 31, @s_time)    -- 30 days

truncate table rmtype_inventory

select @id = 1
while	@s_time <= @e_time
begin
  -- 客房总数
	select @value = sum(quantity) from typim where tag = 'K'
	if @langid=0
		insert rmtype_inventory	values(@id, @s_time, '','#000', '#00', '   总房数',	@value, 100)
	else
		insert rmtype_inventory	values(@id, @s_time, '','#000', '#00', '   Rooms Available',	@value, 100)
	  
	-- 总维修
	exec p_gds_reserve_rsv_index @s_time, '%', 'Out of Order', 'R', @value output
	if @langid=0
		insert rmtype_inventory	select @id, @s_time, '', '#444', '#Z4', '   总维修', @value, 100
	else
		insert rmtype_inventory	select @id, @s_time, '', '#444', '#Z4', '   Rooms Out of Order', @value, 100
	  
   -- 总锁房
	exec p_gds_reserve_rsv_index @s_time, '%', 'Out of Service', 'R', @value output
	if @langid=0
		insert rmtype_inventory	select @id, @s_time, '', '#445', '#Z4', '   总锁房', @value, 100
	else
		insert rmtype_inventory	select @id, @s_time, '', '#445', '#Z4', '   Rooms Outof Service', @value, 100

----------------------------------------------------------------------------------------------
	-- 某房类存量 = 某房类房间总数 - 某房类占用 - 维修/锁定
--	insert rmtype_inventory
--		select @id, @s_time, '',
--					right('0000'+rtrim(convert(char(10),a.sequence)),4), a.type, '',   	-- 注意房类的排序必须不要超过4位否则排序混乱。
--					a.quantity - (select isnull(sum(b.blockcnt),0)						 	-- blockcnt 预留纪录
--						from rsvtype b 
--								where b.begin_ <= @s_time 
--									and b.end_ > @s_time
--									and a.type = b.type
--					), 0
--			from typim a

	-- 某房类存量 = 某房类房间总数 - 某房类占用 - 维修/锁定 - 扣减 hu 
	insert rmtype_inventory
		select @id, @s_time, '',
					right('0000'+rtrim(convert(char(10),a.sequence)),4), a.type, '',   	-- 注意房类的排序必须不要超过4位否则排序混乱。
					a.quantity - (select isnull(sum(b.quantity),0)						 	-- blockcnt 预留纪录
						from rsvsaccnt b, master c, mktcode d
								where b.accnt=c.accnt and c.market=d.code and d.flag<>'HSE'
									and b.begin_ <= @s_time and b.begin_ <> b.end_
									and b.end_ > @s_time
									and a.type = b.type 
					) - (select isnull(sum(b.quantity),0)						 	-- blockcnt 预留纪录
						from rsvsaccnt b, sc_master c, mktcode d
								where b.accnt=c.accnt and c.market=d.code and d.flag<>'HSE'
									and b.begin_ <= @s_time and b.begin_ <> b.end_
									and b.end_ > @s_time
									and a.type = b.type 
					), 0
			from typim a where a.tag<>'P' order by a.gtype,a.sequence
			

	update rmtype_inventory
		set rmtype_inventory.quan = rmtype_inventory.quan - (select isnull(count(1),0)
						from rmsta b
							where  b.locked='L' 
									and b.futbegin <= @s_time 
									and (b.futend > @s_time or b.futend is null)
									and rmtype_inventory.type=b.type
					)
				where rmtype_inventory.date = @s_time
	update rmtype_inventory set sort = right('0000'+isnull(ltrim(convert(char(4),b.sequence)),''),4) from typim a,gtype b 
			where a.gtype=b.code and rtrim(rmtype_inventory.type) = rtrim(a.type)
----------------------------------------------------------------------------------------------

	-- HU
	exec p_gds_reserve_rsv_index @s_time, '%', 'HSE', 'R', @value output
	if @langid=0
		insert rmtype_inventory	select @id, @s_time, '', '#500', '', '   自用房', @value, 0
	else
		insert rmtype_inventory	select @id, @s_time, '', '#500', '', '   House Use', @value, 0

	-- 当日到
	exec p_gds_reserve_rsv_index @s_time, '%', 'Arrival Rooms', 'R', @value output
	if @langid=0
		insert rmtype_inventory	select @id, @s_time, '', 'ZZ20', 'ZZ2', '   当日到', @value, 0
	else
		insert rmtype_inventory	select @id, @s_time, '', 'ZZ20', 'ZZ2', '   Arrival', @value, 0
	
	-- 本日退
	exec p_gds_reserve_rsv_index @s_time, '%', 'Departure Rooms', 'R', @value output
	if @langid=0
		insert rmtype_inventory	select @id, @s_time, '', 'ZZ30', 'ZZ3','   本日退', @value, 0
	else
		insert rmtype_inventory	select @id, @s_time, '', 'ZZ30', 'ZZ3', '   Departure', @value, 0

-- 在店客人 Guest in house
	exec p_gds_reserve_rsv_index @s_time, '%', 'People In-House-HU', 'R', @value output
	if @langid=0
		insert rmtype_inventory	select @id, @s_time, '', '#892', '#ZZ6','   在店客人', @value, 110
	else
		insert rmtype_inventory	select @id, @s_time, '', '#892', '#ZZ6', '   Guest In House', @value,100

--	-- Day Use
--	exec p_gds_reserve_rsv_index @s_time, '%', 'Day Use', 'R', @value output
--	if @langid=0
--		insert rmtype_inventory	select @id, @s_time, '', 'ZZ60', 'ZZ6', '   Day Use', @value, 0
--	else
--		insert rmtype_inventory	select @id, @s_time, '', 'ZZ60', 'ZZ6', '   Day Use', @value, 0

--	-- Room Revenue
--	exec p_gds_reserve_rsv_index @s_time, '%', 'Room Revenue','R', @value output
--	if @langid=0
--		insert rmtype_inventory	select @id, @s_time, '', 'ZZ90', 'ZZ6', '   客房收入', @value, 0
--	else
--		insert rmtype_inventory	select @id, @s_time, '', 'ZZ90', 'ZZ6', '   Gross Rooms Revenue', @value, 0
--	-- Average Room Rate
--	exec p_gds_reserve_rsv_index @s_time, '%', 'Average Room Rate', 'R', @value output
--	if @langid=0
--		insert rmtype_inventory	select @id, @s_time, '', 'ZZ96', 'ZZ6', '   平均房价', @value, 100
--	else
--		insert rmtype_inventory	select @id, @s_time,'', 'ZZ96', 'ZZ6', '   Average Rate', @value, 100


	-- Occupied Tonight
	exec p_gds_reserve_rsv_index @s_time, '%', 'Occupied Tonight-HU','R', @occ output

	-- Room Revenue Net
	exec p_gds_reserve_rsv_index @s_time, '%', 'Room Revenue Net','R', @value output
	if @langid=0
		insert rmtype_inventory	select @id, @s_time, '', 'ZZ91', 'ZZ6', '   净客房收入', @value, 0
	else
		insert rmtype_inventory	select @id, @s_time, '', 'ZZ91', 'ZZ6', '   Net Net Revenue', @value, 0
	if @occ <> 0 
		select @value = round(@value/@occ, 2)
	else
		select @value = 0
	-- Average Room Rate-1
	if @langid=0
		insert rmtype_inventory	select @id, @s_time, '', 'ZZ96', 'ZZ6', '   平均房价', @value, 0
	else
		insert rmtype_inventory	select @id, @s_time,'', 'ZZ96', 'ZZ6', '   Net Net AVR', @value, 0

	-- Room Revenue Include SVC
	exec p_gds_reserve_rsv_index @s_time, '%', 'Room Revenue Include SVC','R', @value output
	if @langid=0
		insert rmtype_inventory	select @id, @s_time, '', 'ZZ92', 'ZZ6', '   净客房收入+SVC', @value, 0
	else
		insert rmtype_inventory	select @id, @s_time, '', 'ZZ92', 'ZZ6', '   Net Rooms Revenue', @value, 0
	if @occ <> 0 
		select @value = round(@value/@occ, 2)
	else
		select @value = 0
	-- Average Room Rate-2
	if @langid=0
		insert rmtype_inventory	select @id, @s_time, '', 'ZZ97', 'ZZ6', '   平均房价+SVC', @value, 0
	else
		insert rmtype_inventory	select @id, @s_time,'', 'ZZ97', 'ZZ6', '   Net Average Rate', @value, 0

	-- Room Revenue Include Package
	exec p_gds_reserve_rsv_index @s_time, '%', 'Room Revenue Include Packages','R', @value output
	if @langid=0
		insert rmtype_inventory	select @id, @s_time, '', 'ZZ93', 'ZZ6', '   净客房收入+SVC+PAK', @value, 0
	else
		insert rmtype_inventory	select @id, @s_time, '', 'ZZ93', 'ZZ6', '   Gross Rooms Revenue', @value, 0
	if @occ <> 0 
		select @value = round(@value/@occ, 2)
	else
		select @value = 0
	-- Average Room Rate-3
	if @langid=0
		insert rmtype_inventory	select @id, @s_time, '', 'ZZ98', 'ZZ6', '   平均房价+SVC+PAK', @value, 0
	else
		insert rmtype_inventory	select @id, @s_time,'', 'ZZ98', 'ZZ6', '   Gross Average Rate', @value, 0

	-- Next Date
	select @s_time = dateadd(day, 1, @s_time)
	select @id = @id + 1
end

insert rmtype_inventory select distinct id,date,datedes,sort,'','小计'
		,sum(quan),0 from rmtype_inventory  where sort not like '#%' and sort not like 'Z%' and type <> '' group by date,sort
update rmtype_inventory set des = '小计 '+rtrim((select max(gtype) from typim a,rmtype_inventory b 
	where rtrim(b.type) = rtrim(a.type) and b.sort = rmtype_inventory.sort ))+'--------------------------'
		where sort not like '#%' and sort not like 'Z%' and type = ''


-- 总存量 -- 剩余存量 = 所有房类的可用数相加
if @langid=0
	insert rmtype_inventory
		select id, date, '', '#895', 'ZZ1', '   总存量', isnull(sum(quan),0), 100
			from rmtype_inventory where sort not like 'ZZ%' and sort not like '#%' and type<>'' group by id, date
else
	insert rmtype_inventory
		select id, date, '', '#895', 'ZZ1', '   Available', isnull(sum(quan),0), 100
			from rmtype_inventory where sort not like 'ZZ%' and sort not like '#%' and type<>'' group by id, date
 
-- 总占房 扣除,'#445'
select @ttl = sum(quantity) from typim where tag = 'K'
if @langid=0
	insert rmtype_inventory
		select id, date, '', '#890', 'ZZ5', '   总占房', @ttl-sum(quan),100
			from rmtype_inventory where sort in ('#895','#444') group by id, date
else
	insert rmtype_inventory
		select id, date, '', '#890', 'ZZ5', '   Rooms Occupied', @ttl-sum(quan), 100
			from rmtype_inventory where sort in ('#895','#444') group by id, date



-- 可用房 = ttl - oo - hu,
if @langid=0
	insert rmtype_inventory
		select id, date, '', '#888', '#88', '   可用房', @ttl-sum(quan), 100
			from rmtype_inventory where sort in ('#444','#500') group by id, date
else
	insert rmtype_inventory
		select id, date, '', '#888', '#88', '   Rooms Available for Sale', @ttl-sum(quan), 100
			from rmtype_inventory where sort in ('#444','#500') group by id, date

-- 占房率 C1
if @langid=0
	insert rmtype_inventory
		select a.id, a.date, '', 'ZZ80', 'ZZZ', '   占房率1(%)', 
				round(a.quan*100.0/(select b.quan from rmtype_inventory b where a.date=b.date and b.sort='#000'),2), 100
			from rmtype_inventory a where a.sort='#890'
else
	insert rmtype_inventory
		select a.id, a.date, '','ZZ80', 'ZZZ', '   Occupancy1(%)', 
				round(a.quan*100.0/(select b.quan from rmtype_inventory b where a.date=b.date and b.sort='#000'),2), 100
			from rmtype_inventory a where a.sort='#890'


-- 占房率 C3
if @langid=0
	insert rmtype_inventory
		select a.id, a.date, '', 'ZZ81', 'ZZZ', '   占房率3(%)', 
				round(a.quan*100.0/(select b.quan from rmtype_inventory b where a.date=b.date and b.sort='#888'),2), 100
			from rmtype_inventory a where a.sort='#890'
else
	insert rmtype_inventory
		select a.id, a.date, '','ZZ81', 'ZZZ', '   Occupancy3(%)', 
				round(a.quan*100.0/(select b.quan from rmtype_inventory b where a.date=b.date and b.sort='#888'),2), 100
			from rmtype_inventory a where a.sort='#890'


-- 四位的年份, 以及星期   yy/mm/dd-wk
-- select type, convert(char(8),date,11)+'-'+convert(char(1),datepart(weekday, date)-1), quan  from rmtype_inventory order by date, type

if @langid=0
	update rmtype_inventory set des = rtrim(a.type)+' ['+rtrim(a.descript)+'] ('+rtrim(convert(char(3),a.quantity))+')'
		from typim a where rtrim(rmtype_inventory.type) = rtrim(a.type)
else
	update rmtype_inventory set des = rtrim(a.type)+' ['+rtrim(a.descript1)+'] ('+rtrim(convert(char(3),a.quantity))+')'
		from typim a where rtrim(rmtype_inventory.type) = rtrim(a.type)

-- update rmtype_inventory set datedes=convert(char(5),date,1)		-- mm/dd
-- update rmtype_inventory set datedes=convert(char(2),date,3) + '('+convert(char(1),datepart(weekday,date)-1)+')'  -- dd(wk)


update rmtype_inventory set datedes=convert(char(2),date,3) + '(S)'
	where datepart(weekday,date) = 1
update rmtype_inventory set datedes=convert(char(2),date,3) + '(M)'
	where datepart(weekday,date) = 2
update rmtype_inventory set datedes=convert(char(2),date,3) + '(T)'
	where datepart(weekday,date) = 3
update rmtype_inventory set datedes=convert(char(2),date,3) + '(W)'
	where datepart(weekday,date) = 4
update rmtype_inventory set datedes=convert(char(2),date,3) + '(T)'
	where datepart(weekday,date) = 5
update rmtype_inventory set datedes=convert(char(2),date,3) + '(F)'
	where datepart(weekday,date) =6
update rmtype_inventory set datedes=convert(char(2),date,3) + '(S)'
	where datepart(weekday,date) = 7

-- 横向合计的内容
insert rmtype_inventory   -- Insert a row
	select 99,'2020.01.01','总计',sort,type,des,0,rep from rmtype_inventory where id = 1
update rmtype_inventory set quan = isnull((select sum(b.quan) from rmtype_inventory b      -- summary
					where b.sort=rmtype_inventory.sort and b.type=rmtype_inventory.type),0) 
	where date='2020.01.01' 
-- Occupancy1
select @value = b.quan from rmtype_inventory b where b.sort='#000' and b.date='2020.01.01'  
if @value<> 0   
	update rmtype_inventory set quan = round((select b.quan from rmtype_inventory b where b.sort='#890' and b.date='2020.01.01')*100/@value,2)
		where datedes='总计' and sort='ZZ80'
-- Occupancy3
select @value = b.quan from rmtype_inventory b where b.sort='#888' and b.date='2020.01.01'  
if @value<> 0   
	update rmtype_inventory set quan = round((select b.quan from rmtype_inventory b where b.sort='#890' and b.date='2020.01.01')*100/@value,2)
		where datedes='总计' and sort='ZZ81'
-- AVR
select @value = b.quan from rmtype_inventory b where b.sort='#890' and b.date='2020.01.01'
if @value<> 0
begin
	update rmtype_inventory set quan = ROUND((select b.quan from rmtype_inventory b where b.sort='ZZ91' and b.date='2020.01.01')/@value,0)
		where datedes='总计' and sort='ZZ96'
	update rmtype_inventory set quan = ROUND((select b.quan from rmtype_inventory b where b.sort='ZZ92' and b.date='2020.01.01')/@value,0)
		where datedes='总计' and sort='ZZ97'
	update rmtype_inventory set quan = ROUND((select b.quan from rmtype_inventory b where b.sort='ZZ93' and b.date='2020.01.01')/@value,0)
		where datedes='总计' and sort='ZZ98'
end

if @mode = 'S'
	delete rmtype_inventory where rep=0
return 0;
