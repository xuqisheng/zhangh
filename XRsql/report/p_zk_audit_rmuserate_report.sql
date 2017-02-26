
if exists (select * from sysobjects where name ='p_zk_audit_rmuserate_report' and type ='P')
	drop proc p_zk_audit_rmuserate_report;
create proc p_zk_audit_rmuserate_report

as
---------------------------------------------
-- 客房出租率报表
---------------------------------------------
declare 
	@bdate			datetime, 
	@bfdate			datetime, 
	@duringaudit	char(1),
	@wbegin			datetime,
	@wend				datetime,
	@mbegin			datetime,
	@mend				datetime,
	@ybegin			datetime,
	@yend				datetime

-- 
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)

select @wbegin = dateadd(dd, -convert(int,datepart(weekday,@bdate)) +2,@bdate)
select @wend	= dateadd(dd,  convert(int,datepart(weekday,@bdate))   ,@bdate)
select @mbegin = convert(datetime,substring(convert(char,@bdate,111),1,8)+'01')
select @mend	= dateadd(dd,-1,dateadd(mm,1,convert(datetime,substring(convert(char,@bdate,111),1,8)+'01')))
select @ybegin = convert(datetime,substring(convert(char,@bdate,111),1,5)+'01/01')
select @yend	= dateadd(dd,-1,dateadd(yy,1, convert(datetime,substring(convert(char,@bdate,111),1,5)+'01/01')))


create table #room	 (	roomno  		char(10) not null,
								weektotal	money		not null,
							  	week			money 	not null,
								weekper		money		not null,
								monthtotal	money		not null,
								month			money		not null,
								monthper		money		not null,
								yeartotal 	money 	not null,
								year			money		not null,
								yearper		money		not null )

insert #room select roomno,0,0,0,0,0,0,0,0,0 from rmsta order by roomno

update #room set weektotal = (select isnull(sum(quantity),0) from rmuserate where rmuserate.roomno=#room.roomno and sta='I' and date>=@wbegin and date<=@wend)
update #room set week = weektotal/(7-(select isnull(sum(quantity),0) from rmuserate where rmuserate.roomno=#room.roomno and sta='O' and date>=@wbegin and date<=@wend))
update #room set weekper = (select isnull(sum(rmrate),0) from rmuserate where rmuserate.roomno=#room.roomno and sta='I' and date>=@wbegin and date<=@wend)/weektotal where weektotal<>0 
update #room set monthtotal = (select isnull(sum(quantity),0) from rmuserate where rmuserate.roomno=#room.roomno and sta='I' and date>=@mbegin and date<=@mend)
update #room set month = monthtotal/((datediff(dd,@mbegin,@mend)+1) -(select isnull(sum(quantity),0) from rmuserate where rmuserate.roomno=#room.roomno and sta='O' and date>=@mbegin and date<=@mend))
update #room set monthper = (select isnull(sum(rmrate),0) from rmuserate where rmuserate.roomno=#room.roomno and sta='I' and date>=@mbegin and date<=@mend)/monthtotal where monthtotal<>0 
update #room set yeartotal = (select isnull(sum(quantity),0) from rmuserate where rmuserate.roomno=#room.roomno and sta='I' and date>=@ybegin and date<=@yend)
update #room set year = yeartotal/((datediff(dd,@ybegin,@yend)+1) -(select isnull(sum(quantity),0) from rmuserate where rmuserate.roomno=#room.roomno and sta='O' and date>=@ybegin and date<=@yend))
update #room set yearper = (select isnull(sum(rmrate),0) from rmuserate where rmuserate.roomno=#room.roomno and sta='I' and date>=@ybegin and date<=@yend)/yeartotal where yeartotal<>0 

update #room set week=week*100,month=month*100,year=year*100


select * from #room order by roomno
return 0
;




