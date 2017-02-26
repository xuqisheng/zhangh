--E67的过程
drop proc p_clg_report_four_forecast;
create proc p_clg_report_four_forecast
	@s_time	datetime,
	@e_time	datetime
as
declare
	@rmnum	integer,
	@type		char(5),
	@market	char(3),
	@cdate	char(10),
	@quantity	money
create table #goutput(
	type		char(5),
	market	char(3),
	cdate		char(10),
	value		integer)
if datediff(dd,@s_time,@e_time) > 31
	select @e_time  =dateadd(dd,31, @s_time)    -- 30 days
else if datediff(dd,@s_time,@e_time) < 0
	select @e_time  =dateadd(dd, 15, @s_time)    -- 15 days
--rsvsrc中的日期09-01 00:00:00~09-02 00:00:00 统计到09-01的占用。
declare c_type cursor for select distinct type from rsvsrc where datediff(dd,begin_,@s_time)>=0
		and datediff(dd,end_,@s_time)<0
declare c_market cursor for select distinct market from rsvsrc where datediff(dd,begin_,@s_time)>=0
			and datediff(dd,end_,@s_time)<0 and type=@type

while @s_time <= @e_time
begin
	select @cdate=convert(char(5),@s_time,1)
	select @cdate=substring('MON TUE WED THU FRI SAT SUN ',datepart(dw,@s_time)*4-3,4)+@cdate
	open c_type	
	fetch c_type into @type
	while @@sqlstatus=0
	begin
		open c_market
		fetch c_market into @market
		while @@sqlstatus=0
		begin
			--房数
			insert into #goutput select @type,@market,@cdate,sum(a.quantity) from rsvsaccnt a where a.type=@type and exists(select 1 from rsvsrc b
				where datediff(dd,b.begin_,@s_time)>=0 and datediff(dd,b.end_,@s_time)<0 and a.accnt=b.accnt and b.type=@type and b.market=@market)
			--平均房价
			--exec p_gds_reserve_rsv_index @s_time,@type,'Average Room Rate','R',@quantity output
			--insert into #goutput select @type,'ADR',@cdate,@quantity
			--可买房
			--exec p_gds_reserve_rsv_index @s_time,@type,'Rooms to Sell','R',@quantity output
			--insert into #goutput select @type,'AVL',@cdate,@quantity
			fetch c_market into @market
		end
		close c_market

		fetch c_type into @type
	end
	close c_type

	select @s_time = dateadd(day, 1, @s_time)
end

select * from #goutput
;