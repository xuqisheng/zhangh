IF OBJECT_ID('dbo.p_sc_recur_handle') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_recur_handle
    IF OBJECT_ID('dbo.p_sc_recur_handle') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_recur_handle >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_recur_handle >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_recur_handle
                 @recurid varchar(10),
                 @actidmaster varchar(10),
                 @activityto  varchar(50)   
as
declare
  @actid  char(10),           --活动id
  @mode   varchar(1),         --模式   按年3、月2、周1、天0
  @submode varchar(1),        --子模式
  @year   money,              --每？年
  @month  money,              --每？月
  @week   money,              --每？周
  @day    money,              --每？天
  @weekend varchar(10),       --周末      目前还没有用到
  @note   varchar(255),       --描述一周中那些天活动需要重复
  @calendar varchar(1),       --日历模式  目前还没有用到
  @count  money,              --重复次数
  @num    money,              --循环次数计数器
  @begintime datetime,        --每次活动开始时间
  @endtime   datetime,        --每次活动结束时间
  @begin  datetime,           --循环开始时间
  @end    datetime,           --循环结束时间
  @date   datetime,           --指定截止日期计数器
  @recurmode varchar(1),      --重复模式 '0'--按次数结束，'1'--按截止日期结束
  @weekday  money,            --一周中的某一天
  @ret      money,            --debug用返回值
  @monthnew money,            --用做判断
  @yearnew  money,
  @weeknew  money,
  @daynew   money,
  @datenew  datetime,
  @daydiff  money,
  @posyear  money,
  @posmonth money,
  @datentnew datetime,
  @datentmonth money,
  @datent   datetime,
  @datentyear money,
  @posyearnt  money,
  @posmonthnt money,
  @datediff   money


delete sc_activitydetail where recactid=@recurid and activityid<>@actidmaster and activityto=@activityto


select @mode=recmode,@submode=recsubmode,@year=recyear,@month=recmonth,@week=recweek,@day=recdates,
       @begin=begindate,@end=enddate,@count=reccounts,@note=note,@recurmode=repmode 
from sc_recuractivity where recuractid=@recurid
select @begintime=begintime,@endtime=endtime from sc_activitydetail where recactid=@recurid
select @num=1
select @date=@begin
select @datediff=datediff(minute,@begintime,@endtime)
---天
if @mode='0'
   begin
     ---重复模式(按次数结束)
     if @recurmode='0'
        begin
          ---子模式(每天)
          if @submode='1'
             while @num<@count
                 begin
                   select @begintime=dateadd(day,1,@begintime)
                   select @endtime=dateadd(day,1,@endtime)
                   exec @ret=p_sc_getactno1  @actid output
                   exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
                   select @num=@num+1
                end

          ---子模式(每个工作日)
          if @submode='0'
               while @num<@count
                 begin
                   select @begintime=dateadd(day,1,@begintime)
						 select @endtime=dateadd(day,1,@endtime)
                   select @weekday=datepart(weekday,@begintime)
                   if @weekday=1 or @weekday=7
   	                   continue
                   else
                      begin
								 exec @ret=p_sc_getactno1  @actid output
                         exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
								 select @num=@num+1
                      end
                 end
        end
    ---按指定日期结束
     if @recurmode='1'
        begin
          if @submode='1'
             	while @date<=@end
                 begin
                   select @begintime=dateadd(day,1,@begintime)
                   select @endtime=dateadd(day,1,@endtime)
                   exec @ret=p_sc_getactno1  @actid output 
                    exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
                   select @date=dateadd(day,1,@date)
                 end  
          if @submode='0'
					while @date<=@end
                 begin
                   select @begintime=dateadd(day,1,@begintime)
                   select @weekday=datepart(weekday,@begintime)
                   if @weekday=1 or @weekday=7
                      begin
	                      select @date=dateadd(day,1,@date)
   	                   continue
                      end
                   else
                      begin
								 select @endtime=dateadd(day,1,@endtime)
								 exec @ret=p_sc_getactno1  @actid output 
                          exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
								 select @date=dateadd(day,1,@date)
                      end
                 end
             end
   end
---周
if @mode='1'
   begin
     ---重复次数
	  if @recurmode='0'
        while @num<@count
          begin
            select @begintime=dateadd(day,1,@begintime)
     			select @endtime=dateadd(day,1,@endtime)
            select @weekday=datepart(weekday,@begintime)
            if charindex(substring(convert(varchar,@weekday),1,1),@note)>0
               begin
					  exec @ret=p_sc_getactno1  @actid output 
                  exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
                 select @num=@num+1
               end 
          end
     ---指定结束日期
     if @recurmode='1'
         while @date<=@end
			  begin
				 select @begintime=dateadd(day,1,@begintime)
             select @endtime=dateadd(day,1,@endtime)
				 select @weekday=datepart(weekday,@begintime)
				 if charindex(substring(convert(varchar,@weekday),1,1),@note)>0
               begin
                 exec @ret=p_sc_getactno1  @actid output 
                  exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
                 select @date=dateadd(day,1,@date)
               end 
              else
               select @date=dateadd(day,1,@date)
			  end
   end
---月
if @mode='2'
   begin
    ---重复次数
    if @recurmode='0'
        begin
			  ---间隔几个月的第几天
			  if @submode='1'
				  while @num<@count
					 begin
						select @begintime=dateadd(month,@month,@begintime)
						select @endtime=dateadd(month,@month,@endtime)
						exec @ret=p_sc_getactno1  @actid output
                   exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
						select @num=@num+1
					 end 
			  ---间隔几个月的第几周的星期几 
			  if @submode='0'
				  while @num<@count
					 begin
						select @begintime=dateadd(month,@month,@begintime)
						select @datent   =dateadd(month,1,@begintime)
						select @yearnew=datepart(year,@begintime)
						select @monthnew=datepart(month,@begintime)
						select @datentmonth=datepart(month,@datent)
						select @datentyear=datepart(year,@datent)
						select @posyear=charindex('.',convert(varchar,@yearnew)) -1
                  select @posyearnt=charindex('.',convert(varchar,@datentyear)) -1
						select @posmonth=charindex('.',convert(varchar,@monthnew)) -1
                  select @posmonthnt=charindex('.',convert(varchar,@datentmonth)) -1
						select @datenew=convert(datetime,substring(convert(varchar,@yearnew),1,@posyear)+'-'+substring(convert(varchar,@monthnew),1,@posmonth)+'-1 '+convert(varchar,@begintime,108))
						select @datentnew=convert(datetime,substring(convert(varchar,@datentyear),1,@posyearnt)+'-'+substring(convert(varchar,@datentmonth),1,@posmonthnt)+'-1 '+convert(varchar,@begintime,108))
						if @week<>5
							begin
							  select @weekday=datepart(weekday,@datenew)
								if @weekday>@day
									begin
										select @daydiff=7- @weekday+@day
										select @datenew=dateadd(week,@week - 2,@datenew)
									end
								else
									begin
										select @daydiff=@day - @weekday
										select @datenew=dateadd(week,@week - 1,@datenew)
									end
								select @begintime=dateadd(day, @daydiff,@datenew)
							end
						else
						  begin
							  select @weekday=datepart(weekday,@datentnew)
							  if @weekday>@day
									 select @daydiff=  @weekday  - @day
							  else
									 select @daydiff=@weekday + 7 - @day 
							  select @begintime=dateadd(day, - @daydiff,@datentnew)
						  end
						
--aa						select @endtime=convert(datetime,convert(varchar,@begintime,111)+' '+convert(varchar,@endtime,108))  
                     select @endtime=dateadd(minute,@datediff,@begintime)             
						exec @ret=p_sc_getactno1  @actid output
                   exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
						select @num=@num+1
					 end 
        end
    ---指定截止日期
    if @recurmode='1'
       begin
          ---间隔几个月的第几天
        if @submode='1'
           while @date<@end
             begin
               select @begintime=dateadd(month,@month,@begintime)
               select @endtime=dateadd(month,@month,@endtime)
               exec @ret=p_sc_getactno1  @actid output
                exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
               select @date=@begintime
             end 
        ---间隔几个月的第几周的星期几 
        if @submode='0'
           while @date<@end
             begin
               select @begintime=dateadd(month,@month,@begintime)
					select @datent   =dateadd(month,1,@begintime)
					select @yearnew=datepart(year,@begintime)
					select @monthnew=datepart(month,@begintime)
					select @datentmonth=datepart(month,@datent)
					select @datentyear=datepart(year,@datent)
					select @posyear=charindex('.',convert(varchar,@yearnew)) -1
					select @posyearnt=charindex('.',convert(varchar,@datentyear)) -1
					select @posmonth=charindex('.',convert(varchar,@monthnew)) -1
					select @posmonthnt=charindex('.',convert(varchar,@datentmonth)) -1
					select @datenew=convert(datetime,substring(convert(varchar,@yearnew),1,@posyear)+'-'+substring(convert(varchar,@monthnew),1,@posmonth)+'-1 '+convert(varchar,@begintime,108))
					select @datentnew=convert(datetime,substring(convert(varchar,@datentyear),1,@posyearnt)+'-'+substring(convert(varchar,@datentmonth),1,@posmonthnt)+'-1 '+convert(varchar,@begintime,108))
               if @week<>5
                  begin
                     select @weekday=datepart(weekday,@datenew)
							if @weekday>@day
								begin
									select @daydiff=7- @weekday+@day
									select @datenew=dateadd(week,@week - 2,@datenew)
								end
							else
								begin
									select @daydiff=@day - @weekday
									select @datenew=dateadd(week,@week - 1,@datenew)
								end
                     select @begintime=dateadd(day, @daydiff,@datenew)
                  end
               else
                 begin
                    select @weekday=datepart(weekday,@datentnew)
                    if @weekday>@day
                         select @daydiff=  @weekday  - @day
                    else
								 select @daydiff=@weekday + 7 - @day 
                    select @begintime=dateadd(day, - @daydiff,@datentnew)
                 end
               
--               select @endtime=convert(datetime,convert(varchar,@begintime,111)+' '+convert(varchar,@endtime,108))   
					select @endtime=dateadd(minute,@datediff,@begintime)                         
               exec @ret=p_sc_getactno1  @actid output
                exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
               select @date=@begintime
             end 
   end
 end 
---年
if @mode='3'
  begin
    ---重复次数
    if @recurmode='0'
        begin
			  if @submode='1'
              begin
					  while @num<@count
						  begin
							 select @begintime=dateadd(year,1,@begintime)
							 select @endtime=dateadd(year,1,@endtime)
							 exec @ret=p_sc_getactno1  @actid output
							 exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
							 select @num=@num+1
						  end 
               end
			  if @submode='0'
              begin
					  while @num<@count
					  	 begin

                     select @begintime=dateadd(year,1,@begintime)
							select @datent   =dateadd(month,1,@begintime)
							select @yearnew=datepart(year,@begintime)
							select @monthnew=datepart(month,@begintime)
							select @datentmonth=datepart(month,@datent)
							select @datentyear=datepart(year,@datent)
							select @posyear=charindex('.',convert(varchar,@yearnew)) -1
							select @posyearnt=charindex('.',convert(varchar,@datentyear)) -1
							select @posmonth=charindex('.',convert(varchar,@monthnew)) -1
							select @posmonthnt=charindex('.',convert(varchar,@datentmonth)) -1
							select @datenew=convert(datetime,substring(convert(varchar,@yearnew),1,@posyear)+'-'+substring(convert(varchar,@monthnew),1,@posmonth)+'-1 '+convert(varchar,@begintime,108))
							select @datentnew=convert(datetime,substring(convert(varchar,@datentyear),1,@posyearnt)+'-'+substring(convert(varchar,@datentmonth),1,@posmonthnt)+'-1 '+convert(varchar,@begintime,108))
							if @week<>5
								begin
								  select @weekday=datepart(weekday,@datenew)
									if @weekday>@day
										begin
											select @daydiff=7- @weekday+@day
											select @datenew=dateadd(week,@week - 2,@datenew)
										end
									else
										begin
											select @daydiff=@day - @weekday
											select @datenew=dateadd(week,@week - 1,@datenew)
										end
									select @begintime=dateadd(day, @daydiff,@datenew)
								end
							else
							  begin
								  select @weekday=datepart(weekday,@datentnew)
								  if @weekday>@day
										 select @daydiff=  @weekday  - @day
								  else
										 select @daydiff=@weekday + 7 - @day 
								  select @begintime=dateadd(day, - @daydiff,@datentnew)
							  end
							
--							select @endtime=convert(datetime,convert(varchar,@begintime,111)+' '+convert(varchar,@endtime,108))               
							select @endtime=dateadd(minute,@datediff,@begintime)             
							exec @ret=p_sc_getactno1  @actid output
                     exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
							select @num=@num+1
					  	 end   
              end
        end
    ---截止日期
    if @recurmode='1'
        if @submode='1'
             while @date<@end
				  begin
				    select @begintime=dateadd(year,1,@begintime)
                select @endtime=dateadd(year,1,@endtime)
                exec @ret=p_sc_getactno1  @actid output
                 exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
					 select @date=@begintime
              end
        if @submode='0'
           begin
             select @begintime=dateadd(year,1,@begintime)
				 select @datent   =dateadd(month,1,@begintime)
				 select @yearnew=datepart(year,@begintime)
				 select @monthnew=datepart(month,@begintime)
				 select @datentmonth=datepart(month,@datent)
				 select @datentyear=datepart(year,@datent)
				 select @posyear=charindex('.',convert(varchar,@yearnew)) -1
				 select @posyearnt=charindex('.',convert(varchar,@datentyear)) -1
				 select @posmonth=charindex('.',convert(varchar,@monthnew)) -1
				 select @posmonthnt=charindex('.',convert(varchar,@datentmonth)) -1
				 select @datenew=convert(datetime,substring(convert(varchar,@yearnew),1,@posyear)+'-'+substring(convert(varchar,@monthnew),1,@posmonth)+'-1 '+convert(varchar,@begintime,108))
				 select @datentnew=convert(datetime,substring(convert(varchar,@datentyear),1,@posyearnt)+'-'+substring(convert(varchar,@datentmonth),1,@posmonthnt)+'-1 '+convert(varchar,@begintime,108))
				 if @week<>5
					begin
						select @weekday=datepart(weekday,@datenew)
						if @weekday>@day
							begin
								select @daydiff=7- @weekday+@day
								select @datenew=dateadd(week,@week - 2,@datenew)
							end
						else
							begin
								select @daydiff=@day - @weekday
								select @datenew=dateadd(week,@week - 1,@datenew)
							end
						select @begintime=dateadd(day, @daydiff,@datenew)
					end
				 else
				  begin
					  select @weekday=datepart(weekday,@datentnew)
					  if @weekday>@day
							 select @daydiff=  @weekday  - @day
					  else
							 select @daydiff=@weekday + 7 - @day 
					  select @begintime=dateadd(day, - @daydiff,@datentnew)
				  end
				
--				 select @endtime=convert(datetime,convert(varchar,@begintime,111)+' '+convert(varchar,@endtime,108))  
				 select @endtime=dateadd(minute,@datediff,@begintime)                          
				 exec @ret=p_sc_getactno1  @actid output
             exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
				 select @date=@begintime
             
           end
  end
select @actid
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_recur_handle') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_recur_handle >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_recur_handle >>>'
;
