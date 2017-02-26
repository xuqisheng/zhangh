IF OBJECT_ID('dbo.p_yjw_week') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_yjw_week
    IF OBJECT_ID('dbo.p_yjw_week') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_yjw_week >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_yjw_week >>>'
END
;
SETUSER 'dbo'
;
create procedure p_yjw_week
                 @shift_begin varchar(10),
                 @shift_end   varchar(10),
                 @due         char(1)
as
declare 
  @btime    datetime,
  @etime    datetime


create table #daytime
     (
      des   datetime,
      day1  varchar(10),
      day2  varchar(10),
      day3  varchar(10),
      day4  varchar(10),
      day5  varchar(10),
      day6  varchar(10),
      day7  varchar(10)
     )

select @btime='00:00:00'
select @etime='23:59:59'
if @shift_begin is not null and @shift_begin<>'0'
   select @btime=convert(datetime,@shift_begin)
if @shift_end is not null and @shift_end<>'0'
   select @etime=convert(datetime,@shift_end)

                             

  while @etime >= @btime
      begin
       insert #daytime values(@btime,'','','','','','','')
       if @due='0'
            select @btime= dateadd(minute,5,@btime)
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
IF OBJECT_ID('dbo.p_yjw_week') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_yjw_week >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_yjw_week >>>'
;
