-- ------------------------------------------------------------------------------------
--  Forecast 
-- ------------------------------------------------------------------------------------
//if object_id('forecast') is not null
//	drop table forecast
//;
//create table forecast(
//	pc_id		char(4)			null,
//	id			int default 0	null,			-- 项目标志 - 进行加减计算关系
//	date		datetime			null,			-- 日期
//	datedes	char(10)			null,			-- 星期的描述
//	sort		char(4)			null,			-- 排序（列方向）
//	type		char(5)			null,			-- 房类 - 为了保证次序，需要放在房类上方的数据 like #%, 下方的数据 like ZZ%
//													-- for the actual room type, it is typiml.sequence 
//	des		varchar(30)		null,			-- 房类描述
//	quan		money default 0	null		-- 数量
//);

if object_id("p_gds_reserve_mkt_forecast") is not null
	drop proc p_gds_reserve_mkt_forecast;
create proc p_gds_reserve_mkt_forecast
	@s_time			datetime,       	-- 开始时间
	@e_time			datetime,       	-- 开始时间
	@langid			int=0,
	@types			char(255) = '%',		--大房类
	@pc_id			char(4)
as

declare 
			@id				int,
			@sort				char(2),
			@ttl				int,
			@value			int,
			@occ				int

if datediff(dd,@s_time,@e_time) > 31
	select @e_time  =dateadd(dd, 31, @s_time)    -- 30 days
else if datediff(dd,@s_time,@e_time) <= 0
	select @e_time  =dateadd(dd, 15, @s_time)    -- 15 days

delete from forecast where  pc_id = @pc_id
create table #mkt (code char(3) null, quan int null, sequence int null)

if exists(select 1 from sysoption where catalog = 'hotel' and item = 'allotment' and charindex(rtrim(value),'TYty') > 0 )
	exec p_zk_room_plan_check 'pcid',@s_time,@e_time,'%','D'

select @id = 1
while	@s_time <= @e_time
begin
  -- 客房总数
	select @value = sum(quantity) from typim where (charindex(type,@types) > 0 or @types = '%') and tag = 'K'
	if @langid=0
		insert forecast	values(@pc_id,@id, @s_time, '','#000', '#00', '   总房数',	@value)
	else
		insert forecast	values(@pc_id,@id, @s_time, '','#000', '#00', '   Rooms Available',	@value)
	  
	-- 总维修
	exec p_gds_reserve_rsv_index @s_time, @types, 'Out of Order', 'R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', '#444', '#Z4', '   总维修', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', '#444', '#Z4', '   Rooms Out of Order', @value
	  
   -- 总锁房
	exec p_gds_reserve_rsv_index @s_time, @types, 'Out of Service', 'R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', '#445', '#Z4', '   总锁房', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', '#445', '#Z4', '   Rooms Outof Service', @value

---------------------------------------------------------------------------------------------------------
	-- 占用  方法 - 1
---------------------------------------------------------------------------------------------------------
--	insert forecast
--		select @pc_id,@id, @s_time, '', right('0000'+rtrim(convert(char(10),a.sequence)),4), a.code, '',0
--			from mktcode a
--	update forecast set quan=quan + isnull((select sum(a.quantity) from rsvsrc a, master b 
--															where a.accnt=b.accnt and a.roomno='' and b.market=forecast.type
--																and a.begin_<=@s_time and a.end_>@s_time),0)
--		where date=@s_time
--	update forecast set quan=quan + isnull((select count(distinct a.roomno) from rsvsrc a, master b  -- 此语句不成功！ why ? - gds
--															where a.accnt=b.accnt and a.roomno<>'' and b.market=forecast.type
--																and a.begin_<=@s_time and a.end_>@s_time),0)
--		where date=@s_time
---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
	-- 占用  方法 - 2
---------------------------------------------------------------------------------------------------------
	truncate table #mkt
	insert #mkt select b.market, count(distinct a.roomno), 0 from rsvsrc_detail a, master b 
			where b.sta in ('I','R') and a.accnt=b.accnt and a.roomno<>'' and datediff(dd,a.arr,@s_time)>=0 and datediff(dd,a.dep,@s_time)<0 and a.date_=@s_time and (charindex(b.type,@types)>0 or @types = '%')
				group by b.market
	insert #mkt select code, 0, 0 from mktcode where code not in (select code from #mkt)
	delete #mkt from mktcode a where #mkt.code=a.code and a.flag='HSE'
	update #mkt set quan=quan + isnull((select count(distinct a.saccnt) from rsvsrc_detail a, master b 
															where b.sta in ('I','R') and a.accnt=b.accnt and a.roomno='' and b.market=#mkt.code and a.arr<>a.dep and a.quantity=1
																and datediff(dd,a.arr,@s_time)>=0 and datediff(dd,a.dep,@s_time)<0 and a.date_=@s_time and (charindex(b.type,@types)>0 or @types = '%')),0)														 
									  + isnull((select sum(a.quantity) from rsvsrc_detail a, master b 
															where b.sta in ('I','R') and a.accnt=b.accnt and a.roomno='' and b.market=#mkt.code and a.arr<>a.dep and a.quantity>1
																and datediff(dd,a.arr,@s_time)>=0 and datediff(dd,a.dep,@s_time)<0 and a.date_=@s_time and (charindex(b.type,@types)>0 or @types = '%')),0)
									  + isnull((select sum(a.quantity) from rsvsrc a, sc_master b 
															where a.accnt=b.accnt and a.roomno='' and b.market=#mkt.code and a.begin_<>a.end_
																and a.begin_<=@s_time and a.end_>@s_time and (charindex(b.type,@types)>0 or @types = '%')),0)
	update #mkt set sequence = b.sequence from mktcode a,basecode b where rtrim(#mkt.code) = rtrim(a.code) 
						and rtrim(a.grp) = rtrim(b.code) and b.cat = 'market_cat' 
	--update #mkt set sequence = a.sequence from mktcode a where #mkt.code=a.code
	select @occ = isnull((select sum(quan) from #mkt), 0)  -- 总占用
	insert forecast select @pc_id,@id, @s_time, '', right('0000'+rtrim(convert(char(10),a.sequence)),4), a.code, '',quan
			from #mkt a 

---------------------------------------------------------------------------------------------------------
	

	-- HU
	exec p_gds_reserve_rsv_index @s_time, @types, 'HSE', 'R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', '#500', '', '   自用房', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', '#500', '', '   House Use', @value
	
	-- 当日到
	exec p_gds_reserve_rsv_index @s_time, @types, 'Arrival Rooms', 'R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ20', 'ZZ2', '   当日到', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ20', 'ZZ2', '   Arrival', @value
	
	-- 本日退
	exec p_gds_reserve_rsv_index @s_time, @types, 'Departure Rooms', 'R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ30', 'ZZ3','   本日退', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ30', 'ZZ3', '   Departure', @value


	-- 在店客人 Guest in house
	exec p_gds_reserve_rsv_index @s_time, @types, 'People In-House-HU', 'R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', '#892', '#ZZ6','   在店客人', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', '#892', '#ZZ6', '   Guest In House', @value

//	-- Room Revenue
//	exec p_gds_reserve_rsv_index @s_time, '%', 'Room Revenue','R', @value output
//	if @langid=0
//		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ90', 'ZZ6', '   客房收入', @value
//	else
//		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ90', 'ZZ6', '   Gross Rooms Revenue', @value

	-- Room Revenue Net
	exec p_gds_reserve_rsv_index @s_time, @types, 'Room Revenue Net','R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ91', 'ZZ6', '   净客房收入', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ91', 'ZZ6', '   Net Net Revenue', @value
	if @occ <> 0 
		select @value = round(@value/@occ, 2)
	else
		select @value = 0
	-- Average Room Rate-1
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ96', 'ZZ6', '   平均房价', @value
	else
		insert forecast	select @pc_id,@id, @s_time,'', 'ZZ96', 'ZZ6', '   Net Net AVR', @value

	-- Room Revenue Include SVC
	exec p_gds_reserve_rsv_index @s_time, @types, 'Room Revenue Include SVC','R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ92', 'ZZ6', '   净客房收入+SVC', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ92', 'ZZ6', '   Net Rooms Revenue', @value
	if @occ <> 0 
		select @value = round(@value/@occ, 2)
	else
		select @value = 0
	-- Average Room Rate-2
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ97', 'ZZ6', '   平均房价+SVC', @value
	else
		insert forecast	select @pc_id,@id, @s_time,'', 'ZZ97', 'ZZ6', '   Net Average Rate', @value

	-- Room Revenue Include Package
	exec p_gds_reserve_rsv_index @s_time, @types, 'Room Revenue Include Packages','R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ93', 'ZZ6', '   净客房收入+SVC+PAK', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ93', 'ZZ6', '   Gross Rooms Revenue', @value
	if @occ <> 0 
		select @value = round(@value/@occ, 2)
	else
		select @value = 0
	-- Average Room Rate-3
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ98', 'ZZ6', '   平均房价+SVC+PAK', @value
	else
		insert forecast	select @pc_id,@id, @s_time,'', 'ZZ98', 'ZZ6', '   Gross Average Rate', @value
	
	-- 配额房
//	if exists (select 1 from sysoption where catalog = 'hotel' and item = 'lic_buy.1' and charindex(',allot,',','+rtrim(value)+',') > 0)
//			or exists (select 1 from sysoption where catalog = 'hotel' and item = 'lic_buy.2' and charindex(',allot,',','+rtrim(value)+',') > 0)
	if exists(select 1 from sysoption where catalog = 'hotel' and item = 'allotment' and charindex(rtrim(value),'TYty') > 0 )
		begin
		if @langid=0 
			insert forecast	select @pc_id,@id, @s_time, '', 'ZZ99', 'ZZ8', '   剩余配额房(散客)', sum(leftn) from rsv_plan_check where date = @s_time and leftn >= 0 and class = 'F' and pc_id = 'pcid'
		else
			insert forecast	select @pc_id,@id, @s_time,'', 'ZZ99', 'ZZ8', '   Avl. Allotment(FIT)', sum(leftn) from rsv_plan_check where date = @s_time and leftn >= 0 and class = 'F' and pc_id = 'pcid'

		if @langid=0
			insert forecast	select @pc_id,@id, @s_time, '', 'ZZZ9', 'ZZ9', '   剩余配额房(团队)', sum(leftn) from rsv_plan_check where date = @s_time and leftn >= 0 and class = 'G' and pc_id = 'pcid'
		else
			insert forecast	select @pc_id,@id, @s_time,'', 'ZZZ9', 'ZZ9', '   Avl. Allotment(GRP)', sum(leftn) from rsv_plan_check where date = @s_time and leftn >= 0 and class = 'G' and pc_id = 'pcid'
		end

	-- Next Date
	select @s_time = dateadd(day, 1, @s_time)
	select @id = @id + 1
end

insert forecast select distinct @pc_id,id,date,datedes,sort,'','小计'
		,sum(quan) from forecast  where sort not like '#%' and sort not like 'Z%' and type <> '' and pc_id = @pc_id group by date,sort
update forecast set des = '小计 '+rtrim((select max(grp) from mktcode a,forecast b where rtrim(b.type) = rtrim(a.code) and pc_id = @pc_id and b.sort = forecast.sort ))+'--------------------------'
 where sort not like '#%' and sort not like 'Z%' and type = '' and pc_id = @pc_id

-- 总占房 
if @langid=0
	insert forecast
		select @pc_id,id, date, '', '#890', 'ZZ5', '   总占房', sum(quan)
			from forecast where sort not like 'ZZ%' and sort not like '#%' and type <> '' and pc_id = @pc_id group by id, date
else
	insert forecast
		select @pc_id,id, date, '', '#890', 'ZZ5', '   Rooms Occupied', sum(quan)
			from forecast where sort not like 'ZZ%' and sort not like '#%' and type <> '' and pc_id = @pc_id group by id, date

-- 总存量 -- 剩余存量 = 所有房类的可用数相加
select @ttl = sum(quantity) from typim where (charindex(type,@types) > 0 or @types = '%') and tag = 'K'
if @langid=0
	insert forecast
		select @pc_id,id, date, '', '#895', 'ZZ1', '   总存量', @ttl - isnull(sum(quan),0)
			from forecast where sort in ('#890','#444','#445','#500') and pc_id = @pc_id group by id, date
else
	insert forecast
		select @pc_id,id, date, '', '#895', 'ZZ1', '   Available', @ttl - isnull(sum(quan),0)
			from forecast where sort in ('#890','#444','#445','#500') and pc_id = @pc_id group by id, date

-- 可用房 = ttl - oo - os - hu
if @langid=0
	insert forecast
		select @pc_id,id, date, '', '#888', '#88', '   可用房', @ttl-sum(quan)
			from forecast where sort in ('#444','#500') and pc_id = @pc_id group by id, date
else
	insert forecast
		select @pc_id,id, date, '', '#888', '#88', '   Rooms Available for Sale', @ttl-sum(quan)
			from forecast where sort in ('#444','#500') and pc_id = @pc_id group by id, date

-- 占房率1
if @langid=0
	insert forecast
		select @pc_id,a.id, a.date, '', 'ZZ80', 'ZZZ', '   占房率1(%)', 
				round(a.quan*100.0/(select b.quan from forecast b where a.date=b.date and b.sort='#000' and pc_id = @pc_id),2)
			from forecast a where a.sort='#890' and pc_id = @pc_id
else
	insert forecast
		select @pc_id,a.id, a.date, '','ZZ80', 'ZZZ', '   Occupancy1(%)', 
				round(a.quan*100.0/(select b.quan from forecast b where a.date=b.date and b.sort='#000' and pc_id = @pc_id),2)
			from forecast a where a.sort='#890' and pc_id = @pc_id

-- 占房率3
if @langid=0
	insert forecast
		select @pc_id,a.id, a.date, '', 'ZZ81', 'ZZZ', '   占房率3(%)', 
				round(a.quan*100.0/(select b.quan from forecast b where a.date=b.date and b.sort='#888' and pc_id = @pc_id),2)
			from forecast a where a.sort='#890' and pc_id = @pc_id
else
	insert forecast
		select @pc_id,a.id, a.date, '','ZZ81', 'ZZZ', '   Occupancy3(%)', 
				round(a.quan*100.0/(select b.quan from forecast b where a.date=b.date and b.sort='#888' and pc_id = @pc_id),2)
			from forecast a where a.sort='#890' and pc_id = @pc_id


if @langid=0
	update forecast set des = a.code+':'+rtrim(a.descript)
		from mktcode a where forecast.type=a.code and pc_id = @pc_id
else
	update forecast set des = a.code+':'+rtrim(a.descript1)
		from mktcode a where forecast.type=a.code and pc_id = @pc_id

update forecast set datedes=convert(char(2),date,3) + '(S)'
	where datepart(weekday,date) = 1 and pc_id = @pc_id
update forecast set datedes=convert(char(2),date,3) + '(M)'
	where datepart(weekday,date) = 2 and pc_id = @pc_id
update forecast set datedes=convert(char(2),date,3) + '(T)'
	where datepart(weekday,date) = 3 and pc_id = @pc_id
update forecast set datedes=convert(char(2),date,3) + '(W)'
	where datepart(weekday,date) = 4 and pc_id = @pc_id
update forecast set datedes=convert(char(2),date,3) + '(T)'
	where datepart(weekday,date) = 5 and pc_id = @pc_id
update forecast set datedes=convert(char(2),date,3) + '(F)'
	where datepart(weekday,date) =6 and pc_id = @pc_id
update forecast set datedes=convert(char(2),date,3) + '(S)'
	where datepart(weekday,date) = 7 and pc_id = @pc_id

-- 横向合计的内容
insert forecast   -- Insert a row
	select @pc_id,99,'2020.01.01','TOTAL',sort,type,des,0 from forecast where id = 1 and pc_id = @pc_id
update forecast set quan = isnull((select sum(b.quan) from forecast b      -- summary
					where b.sort=forecast.sort and b.type=forecast.type and pc_id = @pc_id),0) 
	where date='2020.01.01'  and pc_id = @pc_id
-- Occupancy3
select @value = b.quan from forecast b where b.sort='#888' and b.date='2020.01.01' and pc_id = @pc_id  
if @value<> 0   
	update forecast set quan = round((select b.quan from forecast b where b.sort='#890' and b.date='2020.01.01' and pc_id = @pc_id)*100/@value,2)
		where datedes='TOTAL' and sort='ZZ81' and pc_id = @pc_id
-- Occupancy1
select @value = b.quan from forecast b where b.sort='#000' and b.date='2020.01.01'  and pc_id = @pc_id 
if @value<> 0   
	update forecast set quan = round((select b.quan from forecast b where b.sort='#890' and b.date='2020.01.01' and pc_id = @pc_id)*100/@value,2)
		where datedes='TOTAL' and sort='ZZ80' and pc_id = @pc_id
-- AVR
select @value = b.quan from forecast b where b.sort='#890' and b.date='2020.01.01' and pc_id = @pc_id
if @value<> 0
begin
	update forecast set quan = ROUND((select b.quan from forecast b where b.sort='ZZ91' and b.date='2020.01.01' and pc_id = @pc_id)/@value,0)
		where datedes='TOTAL' and sort='ZZ96' and pc_id = @pc_id
	update forecast set quan = ROUND((select b.quan from forecast b where b.sort='ZZ92' and b.date='2020.01.01' and pc_id = @pc_id)/@value,0)
		where datedes='TOTAL' and sort='ZZ97' and pc_id = @pc_id
	update forecast set quan = ROUND((select b.quan from forecast b where b.sort='ZZ93' and b.date='2020.01.01' and pc_id = @pc_id)/@value,0)
		where datedes='TOTAL' and sort='ZZ98' and pc_id = @pc_id
end

return 0;
