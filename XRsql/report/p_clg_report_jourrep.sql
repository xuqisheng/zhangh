IF OBJECT_ID('dbo.p_clg_report_jourrep') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_report_jourrep
;
create proc p_clg_report_jourrep
	@date	datetime,
	@mode	char(1),
    @lang   int

as
declare
@curday	int,
@days		int,
@ycurday	int,
@ydays	int
create table #goutput(
	class		char(8)		null,
	daya		money			null,
	dayp		money			null,
	dayc		money			null,
	montha		money			null,
	monthp		money			null,
	monthc	money			null,
	lmonth		money			null,
	lmonthc	money			null,
	year	money		null,
	yearp		money		null,
    yearc		money			null,
	lyear		money			null,
	lyearc		money			null,
	unit	char(6)	null)

if @mode='F'
    insert into #goutput select class,day+day_rebate,pmonth,0,month+month_rebate,pmonth,0,lmonth,0,year+year_rebate,pyear,0,lyear,0,unit from yjourrep  where date = @date and class<'600000'
else
    insert into #goutput select class,day+day_rebate,pmonth,0,month+month_rebate,pmonth,0,lmonth,0,year+year_rebate,pyear,0,lyear,0,unit from yjourrep  where date = @date and class>'600000'

select @days=isnull(datediff(day, firstday, lastday) + 1,30), @curday=isnull(datediff(day, firstday, @date) + 1,1) from firstdays where lastday >= @date and firstday <= @date
select @ydays=isnull(datediff(day, a.firstday, b.lastday) + 1,365), @ycurday=isnull(datediff(day, a.firstday, @date) + 1,1) from firstdays a,firstdays b where a.year=b.year and a.month=1 and b.month=12 and datepart(yy,@date)=a.year
update #goutput set dayp = dayp / @days,monthp = monthp * @curday / @days where unit<>'%'


update #goutput set dayc = daya - dayp,monthc = montha - monthp,lmonthc = montha - lmonth,yearc = year - yearp,lyearc = year - lyear

if @lang=0
    select b.descript,a.daya,a.dayp,a.dayc,a.montha,a.monthp,a.monthc,a.lmonth,a.lmonthc,a.year,a.yearp,a.yearc,a.lyear,a.lyearc from #goutput a,jourrep b where a.class=b.class order by a.class
else
    select b.descript1,a.daya,a.dayp,a.dayc,a.montha,a.monthp,a.monthc,a.lmonth,a.lmonthc,a.year,a.yearp,a.yearc,a.lyear,a.lyearc from #goutput a,jourrep b where a.class=b.class order by a.class
;
