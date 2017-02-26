-------------------------------------------------------------------------------
--		客房预测报表
-------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "mforecast" and type='U')
   drop table mforecast
;
CREATE TABLE mforecast 
(
    date      datetime NOT NULL,
    day       char(3)  DEFAULT '' 	 NOT NULL,
	 rm_for_sale  int		  DEFAULT 0	 NOT NULL,     -- Rooms Available for Sale
    lastnight int      DEFAULT 0	 NOT NULL,
    dep       int      DEFAULT 0	 NOT NULL,
    arr_m     int      DEFAULT 0	 NOT NULL,
    arr_g     int      DEFAULT 0	 NOT NULL,
    arr_f     int      DEFAULT 0	 NOT NULL,
	 hse     int      DEFAULT 0	 NOT NULL,
    stay_over  int      DEFAULT 0	 NOT NULL,
    exten     int      DEFAULT 0	 NOT NULL,			-- 人工预测数据
    wkin      int      DEFAULT 0	 NOT NULL,			-- 人工预测数据
    earlyco   int      DEFAULT 0	 NOT NULL,			-- 人工预测数据
    drsv_t    int      DEFAULT 0	 NOT NULL,			-- 人工预测数据
    drsv_g    int      DEFAULT 0	 NOT NULL,			-- 人工预测数据
    sold      int      DEFAULT 0	 NOT NULL,
    msold      int      DEFAULT 0	 NOT NULL,
    occ       money    DEFAULT 0	 NOT NULL,			-- Actual Occ
    mocc       money    DEFAULT 0	 NOT NULL		-- Forecast Occ
)
;
EXEC sp_primarykey 'mforecast', date;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON mforecast(date)
;


if exists(select 1 from sysobjects where name = "p_gds_reserve_forecast")
   drop proc p_gds_reserve_forecast
;
create  proc p_gds_reserve_forecast
	@s_time		datetime,
	@e_time		datetime 
as

declare 	@time				datetime,  	-- 某日
			@class			char(1),
			@ttl				int,
			@s_time0			datetime		-- 保留

declare 	@lastsold	int,
			@dep			int,
			@arr_m		int,
			@arr_g		int,
			@arr_f		int,
			@rm_for_sale int,
			@stayover	int,
			@bdate		datetime,
			@hse			int

select @s_time0 = @s_time
select @ttl = sum(quantity) from typim
select @bdate = bdate1 from sysdata


-- Work Begin ...			
while @s_time < @e_time
begin
	-- 小于当前营业日期
	if @s_time < @bdate  
	begin
		select @s_time = dateadd(dd, 1, @s_time)
		continue 
	end

	-- 插入记录
	select @time = dateadd(dd, -1, @s_time)  -- 上日
	if not exists(select 1 from mforecast where date=@s_time)
		insert mforecast(date,day) select @s_time,substring(datename(weekday, @s_time),1,3)

	-- Rooms Available for Sale
	exec p_gds_reserve_rsv_index @s_time, '%', 'Room to Rent', 'R', @rm_for_sale output
	update mforecast set rm_for_sale = @rm_for_sale where date=@s_time

	-- 上日过夜客房计算
	if @s_time = @bdate
		select @lastsold = isnull((select count(distinct a.roomno) from rsvsrc_till a, master_till b 
				where a.accnt=b.accnt and b.class='F' and b.sta='I'), 0)
	else
		select @lastsold = isnull((select sum(a.quantity) from rsvdtl a 
				where a.end_ > @time and a.begin_ <= @time), 0)
	update mforecast set lastnight = @lastsold where date=@s_time

	-- 本日将到情况. 	rsvsrc 注意同住共享的问题(没有包含 dayuse )
	-- 散客
	exec p_gds_reserve_rsv_index @s_time, '%', 'Arrival Rooms/FIT', 'R', @arr_f output
	-- 团体
	exec p_gds_reserve_rsv_index @s_time, '%', 'Arrival Rooms/GRP', 'R', @arr_g output
	-- 会议
	exec p_gds_reserve_rsv_index @s_time, '%', 'Arrival Rooms/MET', 'R', @arr_m output
	update mforecast set arr_m=@arr_m, arr_g=@arr_g, arr_f=@arr_f where date=@s_time
	-- HSE
	exec p_gds_reserve_rsv_index @s_time, '%', 'HSE', 'R', @hse output
	update mforecast set hse=@hse where date=@s_time
	update mforecast set hse=0 where date=@s_time

	-- Stay Over
	exec p_gds_reserve_rsv_index @s_time, '%', 'Stay Over', 'R', @stayover output
	update mforecast set stay_over = @stayover where date=@s_time

	-- 上一日的离店房数
	update mforecast set dep= (select lastnight+arr_m+arr_g+arr_f from mforecast where date=@time) - @lastsold
		where date=@time

	select @s_time = dateadd(dd, 1, @s_time)
end

-- End
update mforecast set sold=lastnight-dep+arr_m+arr_g+arr_f-hse
	where date>=@s_time0 and date>=@bdate and date<=@e_time
update mforecast set msold=sold+exten+wkin-earlyco+drsv_t+drsv_g 
	where date>=@s_time0 and date>=@bdate and date<=@e_time

update mforecast set occ = round(sold*1.00/rm_for_sale, 4) 
	where date>=@s_time0 and date>=@bdate and date<=@e_time
update mforecast set mocc = round(msold*1.00/rm_for_sale, 4) 
	where date>=@s_time0 and date>=@bdate and date<=@e_time

-- Output
select date,day,rm_for_sale,lastnight,dep,arr_m,arr_g,arr_f,stay_over,exten,wkin,earlyco,drsv_t,
  drsv_g,sold,msold,occ,mocc from mforecast

return 0
;
