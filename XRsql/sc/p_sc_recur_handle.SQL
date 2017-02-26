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
  @actid  char(10),           --�id
  @mode   varchar(1),         --ģʽ   ����3����2����1����0
  @submode varchar(1),        --��ģʽ
  @year   money,              --ÿ����
  @month  money,              --ÿ����
  @week   money,              --ÿ����
  @day    money,              --ÿ����
  @weekend varchar(10),       --��ĩ      Ŀǰ��û���õ�
  @note   varchar(255),       --����һ������Щ����Ҫ�ظ�
  @calendar varchar(1),       --����ģʽ  Ŀǰ��û���õ�
  @count  money,              --�ظ�����
  @num    money,              --ѭ������������
  @begintime datetime,        --ÿ�λ��ʼʱ��
  @endtime   datetime,        --ÿ�λ����ʱ��
  @begin  datetime,           --ѭ����ʼʱ��
  @end    datetime,           --ѭ������ʱ��
  @date   datetime,           --ָ����ֹ���ڼ�����
  @recurmode varchar(1),      --�ظ�ģʽ '0'--������������'1'--����ֹ���ڽ���
  @weekday  money,            --һ���е�ĳһ��
  @ret      money,            --debug�÷���ֵ
  @monthnew money,            --�����ж�
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
---��
if @mode='0'
   begin
     ---�ظ�ģʽ(����������)
     if @recurmode='0'
        begin
          ---��ģʽ(ÿ��)
          if @submode='1'
             while @num<@count
                 begin
                   select @begintime=dateadd(day,1,@begintime)
                   select @endtime=dateadd(day,1,@endtime)
                   exec @ret=p_sc_getactno1  @actid output
                   exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
                   select @num=@num+1
                end

          ---��ģʽ(ÿ��������)
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
    ---��ָ�����ڽ���
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
---��
if @mode='1'
   begin
     ---�ظ�����
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
     ---ָ����������
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
---��
if @mode='2'
   begin
    ---�ظ�����
    if @recurmode='0'
        begin
			  ---��������µĵڼ���
			  if @submode='1'
				  while @num<@count
					 begin
						select @begintime=dateadd(month,@month,@begintime)
						select @endtime=dateadd(month,@month,@endtime)
						exec @ret=p_sc_getactno1  @actid output
                   exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
						select @num=@num+1
					 end 
			  ---��������µĵڼ��ܵ����ڼ� 
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
    ---ָ����ֹ����
    if @recurmode='1'
       begin
          ---��������µĵڼ���
        if @submode='1'
           while @date<@end
             begin
               select @begintime=dateadd(month,@month,@begintime)
               select @endtime=dateadd(month,@month,@endtime)
               exec @ret=p_sc_getactno1  @actid output
                exec @ret=p_sc_recur_insert @recurid,@actid,@begintime,@endtime,@actidmaster,@activityto
               select @date=@begintime
             end 
        ---��������µĵڼ��ܵ����ڼ� 
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
---��
if @mode='3'
  begin
    ---�ظ�����
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
    ---��ֹ����
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