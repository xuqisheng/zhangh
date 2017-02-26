IF OBJECT_ID('dbo.p_yjw_month') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_yjw_month
    IF OBJECT_ID('dbo.p_yjw_month') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_yjw_month >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_yjw_month >>>'
END
;
SETUSER 'dbo'
;
create procedure p_yjw_month
                 @shift_begin varchar(10),
                 @shift_end   varchar(10),
                 @due         char(1)
as
declare 
  @btime    datetime,
  @etime    datetime,
  @segment  integer,
  @ctime    datetime,
  @temptime varchar(20)

create table #daytime
     (
      des   datetime,
      day1  varchar(5),
      day2  varchar(5),
      day3  varchar(5),
      day4  varchar(5),
      day5  varchar(5),
      day6  varchar(5),
      day7  varchar(5),
      day8  varchar(5),
      day9  varchar(5),
      day10 varchar(5),
      day11 varchar(5),
      day12 varchar(5),
      day13 varchar(5),
      day14 varchar(5),
      day15 varchar(5),
      day16 varchar(5),
      day17 varchar(5),
      day18 varchar(5),
      day19 varchar(5),
      day20 varchar(5),
      day21 varchar(5),
      day22 varchar(5),
      day23 varchar(5),
      day24 varchar(5),
      day25 varchar(5),
      day26 varchar(5),
      day27 varchar(5),
      day28 varchar(5),
      day29 varchar(5),
      day30 varchar(5),
      day31 varchar(5),
      property varchar(30),
      status varchar(30)
     )
select @btime='00:00:00'
select @etime='23:59:59'
if @shift_begin is not null and @shift_begin<>'0'
   select @btime=convert(datetime,@shift_begin)
if @shift_end is not null and @shift_end<>'0'
   select @etime=convert(datetime,@shift_end)
                           

  while @etime >= @btime
      begin
			 insert #daytime values(@btime,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','000000000000000000000000000000','000000000000000000000000000000')
          if @due='0'
               select @btime=dateadd(minute,5,@btime)
          else       
          if @due='1'
					select @btime = dateadd(minute,15,@btime)
			 else
				if @due='2'
				  select @btime = dateadd(minute,30,@btime)  
			 else
				if @due='3'
				  select @btime = dateadd(minute,60,@btime)
          else
            begin
              select * from #daytime
              return 0
            end
       end
      select * from #daytime
   return 0
;
SETUSER
;
IF OBJECT_ID('dbo.p_yjw_month') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_yjw_month >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_yjw_month >>>'
;
