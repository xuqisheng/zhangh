if exists(select 1 from sysobjects where name = "p_gds_reserve_rep_o1")
   drop proc p_gds_reserve_rep_o1
;
create  proc p_gds_reserve_rep_o1
	@date		datetime
as
declare	@bdate		datetime,
			@begin_		datetime,
			@end_			datetime,
			@pointer		datetime

-----------------------------------------------------
--	报表专家分析报表： room sold grid - 1
-----------------------------------------------------
-- 
select @bdate = bdate1 from sysdata
select @begin_ = convert(datetime, substring(convert(char(10),@date,111),1,8)+'01')
select @end_ = dateadd(dd, -1, convert(datetime, substring(convert(char(10),dateadd(month,12,@date),111),1,8)+'01'))

--
create table #rep (
	date		datetime					not null,
	value		money		default 0	null,
	day_		char(2)					null,
	month_	char(6)					null,
	mondes	char(3)					null
)

--
select @pointer = @begin_
while @pointer <= @end_
begin
	insert #rep(date) values(@pointer)
	select @pointer = dateadd(dd, 1, @pointer)
end 

-- Last data
update #rep set value = a.amount from yaudit_impdata a where a.class='sold' and a.date=#rep.date and a.date<@bdate
update #rep set value = value + a.amount from yaudit_impdata a where a.class='htl' and a.date=#rep.date and a.date<@bdate

-- Future Data
while @bdate <= @end_
begin
	insert #rep (date, value)
		select @bdate, isnull(sum(blockcnt),0) 
			from rsvtype where begin_ <= @bdate and end_ > @bdate

	select @bdate = dateadd(dd, 1, @bdate)
end

--
update #rep set day_ = convert(char(2), date, 3), 
					month_ = substring(convert(char(10), date, 111),6,2) + substring(convert(char(10), date, 111),3,2), 
					mondes = convert(char(3), date, 7)

select * from #rep order by date
return 0
;
