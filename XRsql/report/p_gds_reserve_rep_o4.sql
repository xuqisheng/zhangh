if exists(select 1 from sysobjects where name = "p_gds_reserve_rep_o4")
   drop proc p_gds_reserve_rep_o4
;
create  proc p_gds_reserve_rep_o4
	@date1		datetime,
	@len			int = 6,
	@market		char(3) = ''
as
declare	@bdate		datetime,
			@begin_		datetime,
			@end_			datetime,
			@pointer		datetime,
			@date2		datetime,
			@ttl			int

-----------------------------------------------------
--	报表专家分析报表： room sold grid - 4
-----------------------------------------------------
if rtrim(@market) is null 
	select @market = '%'
if @len is null or @len<=0 or @len >  20 
	select @len = 6
select @date2 = dateadd(month, @len, @date1)
select @bdate = bdate1 from sysdata
select @begin_ = convert(datetime, substring(convert(char(10),@date1,111),1,8)+'01')
select @end_ = dateadd(dd, -1, convert(datetime, substring(convert(char(10),dateadd(month,1,@date2),111),1,8)+'01'))
select @ttl = sum(quantity) from typim

--
create table #rep (
	date		datetime					not null,
	weekday	int		default 0	null,
	day		char(3)	default ''	null,
	ttl		money		default 0	null,
	ooo		money		default 0	null,
	tl_oo		money		default 0	null,
	hu			money		default 0	null,
	tl_hu		money		default 0	null,
	tl_oo_hu	money		default 0	null,
	sold		money		default 0	null,
	occ1		money		default 0	null,
	occ2		money		default 0	null,
	occ3		money		default 0	null,
	occ4		money		default 0	null,
	day_		char(2)					null,
	month_	char(6)					null,
	mondes	char(3)					null
)

--
select @pointer = @begin_
while @pointer <= @end_
begin
	insert #rep(date, ttl) values(@pointer, @ttl)
	select @pointer = dateadd(dd, 1, @pointer)
end 

-- Last data
update #rep set ttl = a.amount from yaudit_impdata a where a.class='ttl' and a.date=#rep.date and a.date<@bdate
update #rep set ooo = a.amount from yaudit_impdata a where a.class='mnt' and a.date=#rep.date and a.date<@bdate
update #rep set hu  = a.amount from yaudit_impdata a where a.class='htl' and a.date=#rep.date and a.date<@bdate
if @market = '%'
	update #rep set sold = a.amount from yaudit_impdata a where a.class='sold' and a.date=#rep.date and a.date<@bdate
else
	update #rep set sold = a.rquan from ymktsummaryrep a where a.date=#rep.date and a.date<@bdate and a.class='M' and a.code=@market

-- Future Data
select @pointer = @bdate
while @pointer <= @end_
begin
	-- 计算总客房占用 sold + hu
--	insert #rep (date, value)
--		select @pointer, isnull(sum(blockcnt),0) 
--			from rsvtype where begin_ <= @pointer and end_ > @pointer

	-- sold
	update #rep set sold = isnull((select sum(a.quantity) from rsvsaccnt a, master b
				where a.begin_ <= @pointer and a.end_ > @pointer and a.accnt=b.accnt and b.market like @market),0)
			where date = @pointer

	-- hu 
	update #rep set hu = isnull((select sum(a.quantity) from rsvsaccnt a, master b, mktcode c
				where a.begin_ <= @pointer and a.end_ > @pointer and a.accnt=b.accnt and b.market=c.code and c.flag='HSE'),0)
			where date = @pointer

	-- ooo  暂时不考虑
	-- ......

	select @pointer = dateadd(dd, 1, @pointer)
end

--
update #rep set day_ = convert(char(2), date, 3), 
					month_ = substring(convert(char(10), date, 111),3,2) + substring(convert(char(10), date, 111),6,2), 
					mondes = convert(char(3), date, 7), 
					weekday=datepart(weekday, date), 
					tl_oo = ttl - ooo, 
					tl_hu = ttl - hu, 
					tl_oo_hu = ttl - ooo - hu

update #rep set occ1 = round(100*(sold+hu)/(ttl), 2) where ttl <> 0 
update #rep set occ2 = round(100*sold/(ttl-ooo), 2) where ttl-ooo <> 0 
update #rep set occ3 = round(100*sold/(ttl-hu), 2) where ttl-hu <> 0 
update #rep set occ4 = round(100*sold/(ttl-ooo-hu), 2) where ttl-ooo-hu <> 0 

update #rep set day = 'SUN' where weekday = 1
update #rep set day = 'MON' where weekday = 2
update #rep set day = 'TUE' where weekday = 3
update #rep set day = 'WEN' where weekday = 4
update #rep set day = 'TUR' where weekday = 5
update #rep set day = 'FRI' where weekday = 6
update #rep set day = 'SAT' where weekday = 7

select * from #rep order by date
return 0
;
