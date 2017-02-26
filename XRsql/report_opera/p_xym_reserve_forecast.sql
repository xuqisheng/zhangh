//p_gds_reserve_daily_info
drop proc p_xym_reserve_forecast;
create proc p_xym_reserve_forecast
	@s_time			datetime,
   @type          char(5)
as
-- ------------------------------------------------------------------------------------
--  前台客房信息查询  -- 客房可用与占用的 下半部分
-- ------------------------------------------------------------------------------------
declare
   @e_time        datetime,
   @year          integer,
   @month         integer,
   @day           integer,
	@min_avl			money,
	@ttl_occ			money,
	@max_occ			money,
	@min_occ			money,
	@event			varchar(60)

create table #info
(
day    integer,
jan    money,
feb    money,
mar    money,
apr    money,
may    money,
jun    money,
jul    money,
aug    money,
sep    money,
oct    money,
nov    money,
dec    money
)

select @year = datepart(year,@s_time) + 1 
select @e_time = dateadd(day,-1,convert(datetime,convert(char(4),@year)+'01'+'01'))
if rtrim(@type) is null or rtrim(@type) = '' 
   select @type = '%'
while	@s_time <= @e_time
begin
   select @day = datepart(day,@s_time)
   select @month = datepart(month,@s_time)

	-- 占用房数
	exec p_gds_reserve_rsv_index @s_time, @type, 'Total Reserved', 'R', @ttl_occ output
	exec p_gds_reserve_rsv_index @s_time, @type, 'Total Reserved', 'R', @max_occ output
	exec p_gds_reserve_rsv_index @s_time, @type, 'Definite Reservations', 'R', @min_occ output
   if not exists(select 1 from #info where day=@day)
      insert #info select @day,0,0,0,0,0,0,0,0,0,0,0,0
        if @month = 1
           update #info set jan = jan + @ttl_occ where day = @day
        if @month = 2
           update #info set feb = feb + @ttl_occ where day = @day
        if @month = 3
           update #info set mar = mar + @ttl_occ where day = @day
        if @month = 4
           update #info set apr = apr + @ttl_occ where day = @day
        if @month = 5
           update #info set may = may + @ttl_occ where day = @day
        if @month = 6
           update #info set jun = jun + @ttl_occ where day = @day
        if @month = 7
           update #info set jul = jul + @ttl_occ where day = @day
        if @month = 8
           update #info set aug = aug + @ttl_occ where day = @day
        if @month = 9
           update #info set sep = sep + @ttl_occ where day = @day
        if @month = 10
           update #info set oct = oct + @ttl_occ where day = @day
        if @month = 11
           update #info set nov = nov + @ttl_occ where day = @day
        if @month = 12
           update #info set dec = dec + @ttl_occ where day = @day
	-- next date
	select @s_time = dateadd(day, 1, @s_time)
end

select * from #info order by day


return 0;

exec p_xym_reserve_forecast '2006/09/02','';