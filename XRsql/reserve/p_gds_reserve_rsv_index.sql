if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_index")
	drop proc p_gds_reserve_rsv_index;
create proc p_gds_reserve_rsv_index
	@date			datetime,
	@types		varchar(255),
	@index		varchar(30),   -- 统计指标
	@retmode		char(1)='R',
	@result		money		output
as
-----------------------------------------------
--		系统客房资源数据统计指标 
--
--		该过程需要与 p_gds_reserve_rsv_index_list 保持一致 
-----------------------------------------------
--	参数说明
--			@types: 保证三位房类长度，百分号分割. eg.  %BJ %HHT%ZTD%
--				---> 保证索引的使用
--
--		这其中有许多指标有相互的关系，该proc可以嵌套运用。
--
-----------------------------------------------
declare		@mm1			money,
				@mm2			money,
				@mm3			money,
				@type			char(5),
				@bdate		datetime,
				@resno 		char(6),
				@duin			char(1)

select @result=0, @bdate = bdate1 from sysdata
select @resno = substring(convert(char(8),@date,112),3,6)
select @duin=value from sysoption where catalog='reserve' and item='day_use_in'

-- 拼字符串
if @types='%' 
begin
	select @types='_'
	select @type=isnull((select min(type) from typim where type>'' and tag='K'), '')
	while @type <> ''
	begin
		select @types = @types+substring(@type+space(5), 1, 5)+'_'
		select @type=isnull((select min(type) from typim where type>@type and tag='K'), '')
	end
end

-------------------------------------------
--	总房数
-------------------------------------------
if @index = 'Total Rooms' 
begin	 -- 目前，没有未来房的概念
	select @result = count(1) from rmsta where charindex(type,@types)>0 and tag='K' 
end

-------------------------------------------
--	维修房 
-------------------------------------------
else if @index = 'Out of Order'
begin
	select @result= count(1) from rmsta where locked='L' and futbegin<=@date and (futend > @date or futend is null)	
			and (sta='O' or futsta='O') and charindex(type,@types)>0 and tag='K' 
end

-------------------------------------------
-- 锁定房
-------------------------------------------
else if @index = 'Out of Service'		
begin
	select @result=count(1) from rmsta where locked='L' and futbegin<=@date and (futend > @date or futend is null)	
			and (sta='S' or futsta='S') and charindex(type,@types)>0 and tag='K' 
end

-------------------------------------------
-- 可卖房 = 总房数 - 维修房 (不能减去《维护房》 ???)
-------------------------------------------
else if @index = 'Room to Rent'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Total Rooms', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Out of Order', 'R', @mm2 output
	exec p_gds_reserve_rsv_index @date, @types, 'HSE', 'R', @mm3 output

	select @result = @mm1 - @mm2 - @mm3

--	select @result = isnull((select sum(blockcnt) from rsvtype 
--			where begin_ <= @date and end_ > @date and charindex(type,@types)>0),0)
end

-------------------------------------------
--	免费房
-------------------------------------------
else if @index = 'COM'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b, mktcode c 
		where a.accnt=b.accnt and b.market=c.code and c.flag='COM'
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0
		),0)
end

-------------------------------------------
--	自用房
-------------------------------------------
else if @index = 'HSE'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b, mktcode c 
		where a.accnt=b.accnt and b.market=c.code and c.flag='HSE'
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0
		),0)
end

-------------------------------------------
--	自用房人数
-------------------------------------------
else if @index = 'PN_HSE'
begin
	select @result = isnull((select sum(a.gstno*a.quantity) 
		from rsvsrc a, master b, mktcode c 
		 where a.accnt=b.accnt and b.market=c.code and c.flag='HSE' 
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno*a.quantity) 
		from rsvsrc a, sc_master b, mktcode c 
		 where b.foact='' and a.accnt=b.accnt and b.market=c.code and c.flag='HSE' 
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end


-----------------------------------------------------------------
-- 确认预订客房 ( Include Checked/In, Not include day-use)
-----------------------------------------------------------------
else if @index = 'Definite Reservations'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b
		where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@date and a.end_>@date
			and a.accnt=b.accnt and b.restype in (select code from restype where definite='T')),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsaccnt a, sc_master b
		where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@date and a.end_>@date
			and a.accnt=b.accnt and b.restype in (select code from restype where definite='T')),0)
end

-------------------------------------------
--	非确认预订 ( Not include day-use)
-------------------------------------------
else if @index = 'Tentative Reservation'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b
		where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@date and a.end_>@date
			and a.accnt=b.accnt and b.restype not in (select code from restype where definite='T')),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsaccnt a, sc_master b
		where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@date and a.end_>@date
			and a.accnt=b.accnt and b.restype not in (select code from restype where definite='T')),0)
end

-------------------------------------------
-- 可用房 = 可卖房 - 确认预订客房
-------------------------------------------
else if @index = 'Available Rooms'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Room to Rent', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Definite Reservations', 'R', @mm2 output
	select @result = @mm1 - @mm2
end

-------------------------------------------
--	最小可用房 = 可用房 - 非确认预订
-------------------------------------------
else if @index = 'Minimum Availability'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Available Rooms', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Tentative Reservation', 'R', @mm2 output
	select @result = @mm1 - @mm2
end

-------------------------------------------
--	超预留数目 1 : 整个酒店范畴的界定
-------------------------------------------
else if @index = 'House Overbooking'
begin
	-- 首先提取房类的超预留 
	exec p_gds_reserve_rsv_index @date, @types, 'Room Type Overbooking', 'R', @mm1 output
	
	if exists(select 1 from sysoption where catalog = "reserve" and item = "cntlblock" and charindex(substring(value,1,1), 'TtYy')>0) 
	begin  -- 存在总量控制 
		select @result = overbook from rsvlimit where date=@date and gtype='' and type='' 
		if @@rowcount=0 
			select @result = convert(int,value) from sysoption where catalog = "reserve" and item = "cntlquan"
		if @mm1 < @result 
			select @result = @mm1 
	end 
	else 
		select @result = @mm1 

	if @result is null or @result < 0
		select @result = 0
end

-------------------------------------------
--	超预留数目 2 : 房类范畴的界定
-------------------------------------------
else if @index = 'Room Type Overbooking'
begin
	select @result = 0, @type = isnull((select min(type) from typim where charindex(type,@types)>0 and tag<>'P'), '') 
	while @type <> ''
	begin 
		if exists(select 1 from rsvlimit where date=@date and type=@type)
			select @result = @result + overbook from rsvlimit where date=@date and type=@type
		else 
			select @result = @result + overquan from typim where type=@type
		select @type = isnull((select min(type) from typim where type>@type and charindex(type,@types)>0 and tag<>'P'), '') 
	end 
end

-------------------------------------------
--	可订房 = 可用房 + 超预留数目
-------------------------------------------
else if @index = 'Rooms to Sell'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Available Rooms', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'House Overbooking', 'R', @mm2 output
	select @result = @mm1 + @mm2
end

-------------------------------------------
--	本日抵离 dayuse 
-------------------------------------------
else if @index = 'Day Use'
begin
	select @result = isnull((select sum(quantity) from rsvsrc 
		where charindex(type,@types)>0 and begin_=end_ and begin_=@date and roomno=''),0)
	select @result = @result + (select count(distinct roomno) from rsvsrc 
		where charindex(type,@types)>0 and begin_=end_ and begin_=@date and roomno<>'')
end
else if @index = 'Day Use Persons'
begin
	select @result = isnull((select sum(gstno*quantity) from rsvsrc 
		where charindex(type,@types)>0 and begin_=end_ and begin_=@date),0)
end

-------------------------------------------
--	总预订房 = 确认预订客房 + 非确认预订
-------------------------------------------
else if @index = 'Total Reserved'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Definite Reservations', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Tentative Reservation', 'R', @mm2 output
	select @result = @mm1 + @mm2
end

-------------------------------------------
--	diff = 总预订房 - 可卖房
--	超预订数 = if(diff>0, diff, 0)
-------------------------------------------
else if @index = 'Over Reserved'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Total Reserved', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Room to Rent', 'R', @mm2 output
	if @mm1 > @mm2 
		select @result = @mm1 - @mm2
	else
		select @result = 0
end

-------------------------------------------
--	出租率 = 确认预订客房 / 可卖房
-------------------------------------------
else if @index = 'Occupancy %'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Definite Reservations', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Room to Rent', 'R', @mm2 output
	if @mm2 <> 0 
		select @result = round(@mm1*100/@mm2, 2)
	else
		select @result = 0
end

-------------------------------------------
--	最大出租率 = (确认预订客房 + 非确认预订) / 可卖房
-------------------------------------------
else if @index = 'Maximum Occ. %'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Definite Reservations', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Tentative Reservation', 'R', @mm2 output
	exec p_gds_reserve_rsv_index @date, @types, 'Room to Rent', 'R', @mm3 output
	if @mm3 <> 0
		select @result = round((@mm1+@mm2)*100/@mm3, 2)
	else
		select @result = 0
end

-------------------------------------------
--	过夜客人  -hu
-------------------------------------------
else if @index = 'People In-House-HU'  			-- 所有
begin
	select @result = isnull((select sum(a.gstno*a.quantity) 
		from rsvsrc a, master b, mktcode c 
		 where a.accnt=b.accnt and b.market=c.code and c.flag<>'HSE' 
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno*a.quantity) 
		from rsvsrc a, sc_master b, mktcode c 
		 where b.foact='' and a.accnt=b.accnt and b.market=c.code and c.flag<>'HSE' 
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end

-------------------------------------------
--	过夜客人  +散客/团体/会议
-------------------------------------------
else if @index = 'People In-House'  			-- 所有
begin
	select @result = isnull((select sum(gstno*quantity) from rsvsrc where begin_<=@date and end_>@date and charindex(type,@types)>0),0)
end
else if @index = 'People In-House/FIT'			-- 散客
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno='' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end
else if @index = 'People In-House/GRP'			-- 团体
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno like 'G%'
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='G' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno*a.quantity) from rsvsrc a, sc_master b 
		where b.foact='' and a.accnt=b.accnt and b.class='G' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end
else if @index = 'People In-House/MET'			-- 会议
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno like 'M%'
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='M' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno*a.quantity) from rsvsrc a, sc_master b 
		where b.foact='' and a.accnt=b.accnt and b.class='M' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end

-------------------------------------------
--	当前 Q-room (当前)
-------------------------------------------
else if @index = 'Q-room'
begin
	select @result = count(distinct a.roomno) from qroom a, master b 
		where a.accnt=b.accnt and a.status='I' and b.sta in ('R', 'I') and charindex(b.type,@types)>0
end

-------------------------------------------
--	当前 Walk-Ins
-------------------------------------------
else if @index = 'Walk-Ins'
begin
	select @result = isnull((select count(distinct roomno) from master where sta='I' and class='F' and datediff(dd,bdate,@bdate)=0 and substring(extra,9,1)='1' and charindex(type,@types)>0),0)
end
else if @index = 'Walk-Ins Persons'
begin
	select @result = isnull((select sum(gstno) from master where sta='I' and class='F' and datediff(dd,bdate,@bdate)=0 and substring(extra,9,1)='1' and charindex(type,@types)>0),0)
end

-------------------------------------------
--	Stay Over 客房
-------------------------------------------
else if @index = 'Stay Over'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and a.roomno=''
				and a.begin_<@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select count(distinct a.roomno) from rsvsrc a, master b 
		where a.accnt=b.accnt and a.roomno<>''
				and a.begin_<@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, sc_master b 
		where b.foact='' and a.accnt=b.accnt and a.roomno=''
				and a.begin_<@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select count(distinct a.roomno) from rsvsrc a, sc_master b 
		where b.foact='' and a.accnt=b.accnt and a.roomno<>''
				and a.begin_<@date and a.end_>@date and charindex(a.type,@types)>0),0)
end

-------------------------------------------
--	过夜客房  - hu
-------------------------------------------
else if @index = 'Occupied Tonight-HU'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b, mktcode c 
		where a.accnt=b.accnt and b.market=c.code and c.flag<>'HSE'
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0
		),0)
end

-------------------------------------------
--	过夜客房  +散客/团体/会议
-------------------------------------------
else if @index = 'Occupied Tonight'
begin
	select @result = isnull((select sum(quantity) from rsvsaccnt where begin_<=@date and end_>@date and charindex(type,@types)>0),0)
end
else if @index = 'Occupied Tonight/FIT'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno='' and a.roomno=''
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select count(distinct a.roomno) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno='' and a.roomno<>''
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end
else if @index = 'Occupied Tonight/GRP'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno like 'G%' and a.roomno=''
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select count(distinct a.roomno) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno like 'G%' and a.roomno<>''
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='G' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, sc_master b 
		where b.foact='' and a.accnt=b.accnt and b.class='G' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end
else if @index = 'Occupied Tonight/MET'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno like 'M%' and a.roomno=''
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select count(distinct a.roomno) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno like 'M%' and a.roomno<>''
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='M' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, sc_master b 
		where b.foact='' and a.accnt=b.accnt and b.class='M' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end

---------------------------------------------------------
--	预计客房收入 -- 包括day-use. 但是包价、白日加收等未知
---------------------------------------------------------
else if @index = 'Room Revenue'
begin  -- 这里不用区分是否已经分房，因为即使已经分房，多人同住的时候，房价也是需要计算的
	select @result = isnull((select sum(rate*quantity) from rsvsrc where begin_<=@date and end_>@date and charindex(type,@types)>0),0)
end

---------------------------------------------------------
--	预计客房收入 -- 净价
---------------------------------------------------------
else if @index = 'Room Revenue Net'
begin  -- 这里不用区分是否已经分房，因为即使已经分房，多人同住的时候，房价也是需要计算的
	exec @result = p_gl_audit_rmpost_index @date, @types, @index
end

---------------------------------------------------------
--	预计客房收入 -- 包括day-use. 服务费
---------------------------------------------------------
else if @index = 'Room Revenue Include SVC'
begin  -- 这里不用区分是否已经分房，因为即使已经分房，多人同住的时候，房价也是需要计算的
	exec @result = p_gl_audit_rmpost_index @date, @types, @index
end

---------------------------------------------------------
--	预计客房收入 -- 包括day-use. 服务费. Packages
---------------------------------------------------------
else if @index = 'Room Revenue Include Packages'
begin  -- 这里不用区分是否已经分房，因为即使已经分房，多人同住的时候，房价也是需要计算的
	exec @result = p_gl_audit_rmpost_index @date, @types, @index
end

-------------------------------------------
--	平均房价
-------------------------------------------
else if @index = 'Average Room Rate'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Room Revenue', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Occupied Tonight', 'R', @mm2 output
	if @mm2 <> 0 
		select @result = round(@mm1/@mm2, 2)
	else
		select @result = 0
end

---------------------------------------------------------------
--	Same Day Reservations 当日预订当日到达客房
---------------------------------------------------------------
else if @index = 'Same Day Reservations' 		-- 已经退房的不算
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''
			and b.resno like @resno+'%' ),0)
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b
			where a.accnt=b.accnt and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>''
				and b.resno like @resno+'%' )
end
else if @index = 'Same Day Reservations Persons'  -- 已经退房的不算
begin
	-- 人数计算没有必要区分是否分房 
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.resno like @resno+'%' and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 ),0)

--	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
--		where a.accnt=b.accnt and b.resno like @resno+'%' and a.begin_=@date and a.begin_<>a.end_ and charindex(a.type,@types)>0 and a.roomno=''),0)
--	select @result = @result + isnull((select sum(a.gstno) from rsvsrc a, master b 
--		where a.accnt=b.accnt and b.resno like @resno+'%' and b.sta in ('R','I') and a.begin_=@date and a.begin_<>a.end_ and charindex(a.type,@types)>0 and a.roomno<>''),0)
end


-------------------------------------------------------------------------
--	当日到达客房	+散客/团体/会议  (未到)
-------------------------------------------------------------------------
else if @index = 'Arrival Rooms'   -- 未分房(sum(quantity)) + 分房(count(distinct roomno))
begin
	select @result = isnull((select sum(quantity) from rsvsrc where begin_=@date and (begin_<>end_ or @duin='T') and charindex(type,@types)>0 and roomno=''),0)
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b
			where a.accnt=b.accnt and b.sta='R' and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end
else if @index = 'Arrival Rooms/FIT'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno=''
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''),0)
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno=''
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end
else if @index = 'Arrival Rooms/GRP'
begin
	-- 团体主单纯预留
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='G'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	-- 成员主单-未分房
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno like 'G%'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''),0)
	-- 成员主单-分房
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno like 'G%'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end
else if @index = 'Arrival Rooms/MET'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='M'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno like 'M%'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''),0)
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno like 'M%'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end

-------------------------------------------------------------------------
--	当日到达客人	+散客/团体/会议 (未到)
-------------------------------------------------------------------------
else if @index = 'Arrival Persons'
begin
	select @result = isnull((select sum(gstno*quantity) from rsvsrc where begin_=@date and (begin_<>end_ or @duin='T') and charindex(type,@types)>0 and roomno=''),0)
	select @result = @result + isnull((select sum(a.gstno) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.sta='R' and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>''),0)
end 
else if @index = 'Arrival Persons/FIT'
begin
	select @result = isnull((select sum(a.gstno) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno=''
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
end
else if @index = 'Arrival Persons/GRP'  -- 纯预留（房数*人数） + 成员
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='G'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno like 'G%'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
end
else if @index = 'Arrival Persons/MET'
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='M'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno like 'M%'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
end

-------------------------------------------------------------------------
--	实际到达客房/客人  -- 主要检验营业日期
-------------------------------------------------------------------------
else if @index = 'Arrival Rooms Actual'
begin
	select @result = isnull((select count(distinct roomno) from master where sta='I' and class='F' and bdate=@bdate and charindex(type,@types)>0),0)
end
else if @index = 'Arrival Persons Actual'
begin
	select @result = isnull((select sum(gstno) from master where sta='I' and class='F' and bdate=@bdate and charindex(type,@types)>0),0)
end

-------------------------------------------
--	当日离店客房	+散客/团体/会议
-------------------------------------------
else if @index = 'Departure Rooms'   -- 未分房(sum(quantity)) + 分房(count(distinct roomno))
begin
	select @result = isnull((select sum(quantity) from rsvsrc where end_=@date and (begin_<>end_ or @duin='T') and charindex(type,@types)>0 and roomno=''),0)
	select @result = @result + (select count(distinct roomno) from rsvsrc 
			where end_=@date and (begin_<>end_ or @duin='T') and charindex(type,@types)>0 and roomno<>'')
end
else if @index = 'Departure Rooms/FIT'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno=''
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''),0)
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno=''
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end
else if @index = 'Departure Rooms/GRP'
begin
	-- 团体主单纯预留
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='G'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	-- 成员主单-未分房
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno like 'G%'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''),0)
	-- 成员主单-分房
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno like 'G%'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end
else if @index = 'Departure Rooms/MET'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='M'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno like 'M%'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''),0)
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno like 'M%'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end

-------------------------------------------
--	当日离店客人	+散客/团体/会议
-------------------------------------------
else if @index = 'Departure Persons'
begin
	select @result = isnull((select sum(gstno) from rsvsrc where end_=@date and (begin_<>end_ or @duin='T') and charindex(type,@types)>0),0)
end
else if @index = 'Departure Persons/FIT'
begin
	select @result = isnull((select sum(a.gstno) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno=''
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
end
else if @index = 'Departure Persons/GRP'  -- 纯预留（房数*人数） + 成员
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='G'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno like 'G%'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
end
else if @index = 'Departure Persons/MET'
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='M'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno like 'M%'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
end

-------------------------------------------
--	当日实际离店客房 / 客人
-------------------------------------------
else if @index = 'Departure Rooms Actual'
begin
	select @result = count(distinct roomno) from master where sta='O' and class='F' and ressta='I'  and charindex(type,@types)>0
end
else if @index = 'Departure Persons Actual'
begin
	select @result = isnull((select sum(gstno) from master where sta='O' and class='F' and ressta='I' and charindex(type,@types)>0),0)
end

-------------------------------------------
--	Extended Stays / 延房 -- 在住客人、本日延房；需要参考 master_till
-------------------------------------------
else if @index = 'Extended Stays Rooms'
begin
--	select @result = isnull((select count(distinct a.roomno) from master a where a.sta='I' and a.class='F' and datediff(dd,@bdate,a.dep)>0  and charindex(a.type,@types)>0
--		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)=0)),0)
	-- 以下是拆开写，避免嵌套太深，数据库报错误的 
	select @result = count(distinct a.roomno) from master a where a.sta='I' and a.class='F' and datediff(dd,@bdate,a.dep)>0  and charindex(a.type,@types)>0
		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)=0)
	if @result is null 
		select @result = 0 
end
else if @index = 'Extended Stays Persons'
begin
--	select @result = isnull((select sum(a.gstno) from master a where a.sta='I' and a.class='F' and datediff(dd,@bdate,a.dep)>0  and charindex(a.type,@types)>0
--		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)=0)),0)
	-- 以下是拆开写，避免嵌套太深，数据库报错误的 
	select @result = sum(a.gstno) from master a where a.sta='I' and a.class='F' and datediff(dd,@bdate,a.dep)>0  and charindex(a.type,@types)>0
		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)=0)
	if @result is null 
		select @result = 0 
end

-------------------------------------------
--	Early Departures / 提前走
-------------------------------------------
else if @index = 'Early Departures Rooms'
begin
	-- 提前走 ed  -- 本日结账、本来离日<>今天；需要参考 master_till
--	select @result = isnull((select count(distinct a.roomno) from master a where a.sta='O' and a.class='F'  and charindex(a.type,@types)>0
--		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)<0)),0)
	-- 以下是拆开写，避免嵌套太深，数据库报错误的 
	select @result = count(distinct a.roomno) from master a where a.sta='O' and a.class='F'  and charindex(a.type,@types)>0
		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)<0)
	if @result is null 
		select @result = 0 
end
else if @index = 'Early Departures Persons'
begin
--	select @result = isnull((select sum(a.gstno) from master a where a.sta='O' and a.class='F'  and charindex(a.type,@types)>0
--		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)<0)),0)
	-- 以下是拆开写，避免嵌套太深，数据库报错误的 
	select @result = sum(a.gstno) from master a where a.sta='O' and a.class='F'  and charindex(a.type,@types)>0
		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)<0)
	if @result is null 
		select @result = 0 
end

-------------------------------------------
-- 事件的个数
-------------------------------------------
else if @index in ('Event', 'Events')  
begin
	select @result = count(1) from events where sta='I' and @date>=begin_ and @date<=end_
end

-------------------------------------------
--	Turnaway
-------------------------------------------
else if @index = 'Turnaway'
begin
--	select @result = isnull((select sum(rmnum) from turnaway where sta='I' and @date>=arr and datediff(dd,arr,@date)<=days), 0)

	-- Turnaway (只计算到日) -- 与 p_gds_reserve_daily_info 保持一致 2007.4.24 simon 
--	select @result	= isnull((select sum(a.rmnum) from turnaway a, typim b 
--		where b.tag='K' and a.type=b.type and datediff(dd,a.arr,@date)=0 and a.sta='T'), 0)

	-- turnaway.type 可以多选的，因此这里没有房类判断了，总是显示所有数字
	select @result	= isnull((select sum(a.rmnum) from turnaway a  
		where datediff(dd,a.arr,@date)=0 and a.sta='T'), 0)

end

-------------------------------------------
--	Waitlist
-------------------------------------------
else if @index = 'Waitlist'
begin
	select @result = isnull((select sum(rmnum) from master where sta='W' and datediff(dd,arr,@date)>=0 and datediff(dd,dep,@date)<=0), 0)
end

-------------------------------------------
--	其他未知 统计指标
-------------------------------------------
else 
	select @result = 0
-------------------------------------------
--	在住免费房
-------------------------------------------
if @index = 'COM_IN'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b, mktcode c 
		where a.accnt=b.accnt and b.market=c.code and c.flag='COM'
			and b.sta = 'I'
		),0)
end
-------------------------------------------
--	Blocks
-------------------------------------------
if @index = 'Blocks'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, sc_master b
		where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@date and a.end_>@date
			and a.accnt=b.accnt ),0)
end
-------------------------------------------
--	输出结果
-------------------------------------------
if @result is null
	select @result = 0
if @retmode = 'S'
	select @result
return 0
;