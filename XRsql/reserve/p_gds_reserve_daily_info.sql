if  exists(select * from sysobjects where name = "p_gds_reserve_daily_info" and type = "P")
	drop proc p_gds_reserve_daily_info;
create proc p_gds_reserve_daily_info
	@s_time			datetime,       	-- 开始时间
	@e_time			datetime,     		-- 结束时间
	@types			varchar(255) = '%'
as
-- ------------------------------------------------------------------------------------
--  前台客房信息查询  -- 客房可用与占用的 下半部分
-- ------------------------------------------------------------------------------------
declare	
	@arrivals		int,
	@departures		int,
	@adults			int,
	@child			int,
	@overrsv			int,
	@oo				int,
	@os				int,
	@overbook		int,
	@datetype		char(1),
	@waitlist_rm	int,
	@waitlist_ps	int,
	@turnaway		int,
	@ttl_avl			money,
	@max_avl			money,
	@min_avl			money,
	@ttl_occ			money,
	@max_occ			money,
	@min_occ			money,
	@event			varchar(60)

create table #info
(
	date			datetime					not null,
	arrivals		int		default 0	not null,		-- 到达客房
	departures	int		default 0	not null,		-- 离开房数
	adults		int		default 0	not null,		-- 到达人数
	child			int		default 0	not null,		-- 到达儿童  => 离开人数
	overrsv		int		default 0	not null,		-- 超预订数  = ？
	oo				int		default 0	not null,		-- 维修
	overbook		int		default 0	not null,		-- 超预订数  = ？
	datetype		char(1)	default ''		null,			
	waitlist_rm		int		default 0	not null,
	waitlist_ps		int		default 0	not null,
	turnaway		int		default 0	not null,
	ttl_avl		money		default 0	not null,
	max_avl		money		default 0	not null,
	min_avl		money		default 0	not null,
	ttl_occ		money		default 0	not null,		-- 出租率
	max_occ		money		default 0	not null,
	min_occ		money		default 0	not null,
	event			varchar(60)	default '' 	null,
	os				int		default 0	not null			-- 锁定
)

while	@s_time <= @e_time
begin
	-- 到达房数
	exec p_gds_reserve_rsv_index @s_time, @types, 'Arrival Rooms', 'R', @arrivals output
	-- 离开房数
	exec p_gds_reserve_rsv_index @s_time, @types, 'Departure Rooms', 'R', @departures output

	-- 到达人数
	exec p_gds_reserve_rsv_index @s_time, @types, 'Arrival Persons', 'R', @adults output
	-- 离开人数
	exec p_gds_reserve_rsv_index @s_time, @types, 'Departure Persons', 'R', @child output

	-- 超预订  Over Reserved
	exec p_gds_reserve_rsv_index @s_time, @types, 'Over Reserved', 'R', @overrsv output

	-- 维修数
	exec p_gds_reserve_rsv_index @s_time, @types, 'Out of Order', 'R', @oo output
	exec p_gds_reserve_rsv_index @s_time, @types, 'Out of Service', 'R', @os output

	-- 允许超预订数
	exec p_gds_reserve_rsv_index @s_time, @types, 'House Overbooking', 'R', @overbook output
	
	-- 日期类型（房价相关）
	select @datetype = factor from rmrate_calendar where date=@s_time
	if @@rowcount = 0
		select @datetype = ''

	-- Waitlist (只计算到日)
	select @waitlist_rm = isnull((select sum(a.rmnum) from master a, typim b 
		where b.tag='K' and a.type=b.type and (@types='%' or charindex(a.type,@types)>0) and datediff(dd,a.arr,@s_time)=0 and a.sta='W'), 0)
	select @waitlist_ps = isnull((select sum(a.gstno) from master a, typim b 
		where b.tag='K' and a.type=b.type and (@types='%' or charindex(a.type,@types)>0) and datediff(dd,a.arr,@s_time)=0 and a.sta='W'), 0)

	-- Turnaway (只计算到日)
--	select @turnaway	= isnull((select sum(a.rmnum) from turnaway a, typim b 
--		where b.tag='K' and a.type=b.type and (@types='%' or charindex(a.type,@types)>0) and datediff(dd,a.arr,@s_time)=0 and a.sta='T'), 0)

	-- turnaway.type 可以多选的，因此这里没有房类判断了，总是显示所有数字 
	select @turnaway	= isnull((select sum(a.rmnum) from turnaway a
		where datediff(dd,a.arr,@s_time)=0 and a.sta='T'), 0)

	-- 可用房数
	exec p_gds_reserve_rsv_index @s_time, @types, 'Available Rooms', 'R', @ttl_avl output
	exec p_gds_reserve_rsv_index @s_time, @types, 'Available Rooms', 'R', @max_avl output
	exec p_gds_reserve_rsv_index @s_time, @types, 'Minimum Availability', 'R', @min_avl output

	-- 占用房数
--	exec p_gds_reserve_rsv_index @s_time, @types, 'Total Reserved', 'R', @ttl_occ output
--	exec p_gds_reserve_rsv_index @s_time, @types, 'Total Reserved', 'R', @max_occ output
--	exec p_gds_reserve_rsv_index @s_time, @types, 'Definite Reservations', 'R', @min_occ output

	-- 出租率
	exec p_gds_reserve_rsv_index @s_time, @types, 'Maximum Occ. %', 'R', @ttl_occ output
	select @max_occ = @ttl_occ
	exec p_gds_reserve_rsv_index @s_time, @types, 'Occupancy %', 'R', @min_occ output

	-- 酒店活动/事件 (有多个事件的时候，只取id最小的一个。考虑时间跨度)
	declare 	@id		int
	select @id = min(id) from events where sta='I' and datediff(dd,begin_,@s_time)>=0 and datediff(dd,end_,@s_time)<=0
	if @id is not null
		select @event	= descript from events where id=@id
	else
		select @event	= 'Null'
	
	-- insert 
	insert #info 
		values(@s_time,@arrivals,@departures,@adults,@child,@overrsv,@oo,@overbook,@datetype,@waitlist_rm,@waitlist_ps,
			@turnaway,@ttl_avl,@max_avl,@min_avl,@ttl_occ,@max_occ,@min_occ,@event,@os)

	-- next date
	select @s_time = dateadd(day, 1, @s_time)
end

select * from #info order by date

return 0
;