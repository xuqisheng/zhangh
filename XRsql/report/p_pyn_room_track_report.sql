IF OBJECT_ID('dbo.p_pyn_room_track_report') IS NOT NULL
    DROP PROCEDURE dbo.p_pyn_room_track_report
;
create proc p_pyn_room_track_report
   	  @bdate     datetime
 	as
   declare @date      datetime   ,
			  @date1     datetime   ,
           @count     int			,
           @count1    int        ,
           @result    money
   create table #track_report
         (date       datetime     			null,
			 cdate      char(20)     			null,
          day        char(3)      			null,
			 weekday    int          			null,
          week       char(2)       			null,
          arrival    money     default 0  null,
          overs      money     default 0  null,
          walkin     money     default 0  null,
          returngst  money     default 0  null,
          ttlocc     money     default 0  null,
          occper     money     default 0  null,
          gstcount   money     default 0  null,
          occmult    money     default 0  null,
          roomrev    money     default 0  null,
          availroom  money     default 0  null,
          avgrmrate  money     default 0  null,
          revepar    money     default 0  null,
          totalreve  money     default 0  null,
          spendpar   money     default 0  null,
          noshow     money     default 0  null,
          cancel     money     default 0  null )

--insert all date--
select @date = convert(datetime,(substring(convert(char(10),@bdate,111),1,8)+'01'))
exec p_pyn_month_maxday @bdate,@date1 out
if datediff(mm,@date,@date1)=0
begin
	while @date <= @date1
		begin
			insert #track_report select @date,'','',0,'0',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			select @date  = dateadd(dd,1,@date)
	end
end
--insert all data--
select @count1 = (select count(1)  from #track_report)
update #track_report set weekday = datepart(weekday,date)
update #track_report set arrival   = isnull((select b.amount  from yaudit_impdata b where b.class='act_arr'  and  #track_report.date=b.date),0)
update #track_report set overs     = isnull((select b.amount  from yaudit_impdata b where b.class='stay_ove' and  #track_report.date=b.date),0)
update #track_report set walkin    = isnull((select b.amount  from yaudit_impdata b where b.class='walkin'   and  #track_report.date=b.date),0)
update #track_report set returngst = isnull((select b.amount  from yaudit_impdata b where b.class='rtngst'   and  #track_report.date=b.date),0)
update #track_report set ttlocc    = isnull((select sum(b.amount)  from yaudit_impdata b where b.class in ('act_arr','stay_ove')  and  #track_report.date=b.date),0)
update #track_report set occper    = isnull((select b.amount  from yaudit_impdata b where b.class='sold%'    and  #track_report.date=b.date),0)
update #track_report set gstcount  = isnull((select b.amount  from yaudit_impdata b where b.class='gst'      and  #track_report.date=b.date),0)
update #track_report set occmult   = gstcount /  ttlocc where ttlocc<>0
update #track_report set roomrev   = isnull((select b.amount  from yaudit_impdata b where b.class='income'   and  #track_report.date=b.date),0)
update #track_report set availroom = isnull((select b.amount  from yaudit_impdata b where b.class='avl'      and  #track_report.date=b.date),0)
update #track_report set avgrmrate = roomrev / ttlocc    where ttlocc   <>0
select @result =  isnull((select b.amount  from yaudit_impdata b where b.class='avl' and date=@bdate),0)
if @result <> 0
update #track_report set revepar   = roomrev /  @result
update #track_report set totalreve = isnull((select b.amount  from yaudit_impdata b where b.class='total' and  #track_report.date=b.date),0)
update #track_report set spendpar  = totalreve / availroom where availroom <>0
update #track_report set noshow    = isnull((select b.amount  from yaudit_impdata b where b.class='noshow'   and  #track_report.date=b.date),0)
update #track_report set cancel    = isnull((select b.amount  from yaudit_impdata b where b.class='cancel'   and  #track_report.date=b.date),0)

--update--
update #track_report set weekday = datepart(weekday,date)
update #track_report set day     ='Sat' where weekday = 7
update #track_report set day     ='Fri' where weekday = 6
update #track_report set day     ='Thu' where weekday = 5
update #track_report set day     ='Wed' where weekday = 4
update #track_report set day     ='Tue' where weekday = 3
update #track_report set day     ='Mon' where weekday = 2
update #track_report set day     ='Sun' where weekday = 1
update #track_report set weekday = 1  where day = 'Sat'
update #track_report set weekday = 2  where day = 'Sun'
update #track_report set weekday = 3  where day = 'Mon'
update #track_report set weekday = 4  where day = 'Tue'
update #track_report set weekday = 5  where day = 'Wed'
update #track_report set weekday = 6  where day = 'Thu'
update #track_report set weekday = 7  where day = 'Fri'
update #track_report set cdate   = convert(char(10),date,6)
update #track_report set week    = '1' where convert(money,substring(convert(char(10),date,111),9,2))/7 > 0 and convert(money,SUBSTRING(convert(char(10),date,111),9,2))/7 <= 1
update #track_report set week    = '2' where convert(money,substring(convert(char(10),date,111),9,2))/7 > 1 and convert(money,SUBSTRING(convert(char(10),date,111),9,2))/7 <= 2
update #track_report set week    = '3' where convert(money,substring(convert(char(10),date,111),9,2))/7 > 2 and convert(money,SUBSTRING(convert(char(10),date,111),9,2))/7 <= 3
update #track_report set week    = '4' where convert(money,substring(convert(char(10),date,111),9,2))/7 > 3 and convert(money,SUBSTRING(convert(char(10),date,111),9,2))/7 <= 4
update #track_report set week    = '5' where convert(money,substring(convert(char(10),date,111),9,2))/7 > 4

--insert average--
insert #track_report select '2000.01.01','Average','Sta',1,'A',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
insert #track_report select '2000.01.01','Average','Sun',2,'A',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
insert #track_report select '2000.01.01','Average','Mon',3,'A',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
insert #track_report select '2000.01.01','Average','Tue',4,'A',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
insert #track_report select '2000.01.01','Average','Wed',5,'A',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
insert #track_report select '2000.01.01','Average','Thu',6,'A',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
insert #track_report select '2000.01.01','Average','Fri',7,'A',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

--update  average--
select @count = isnull((select count(1) from  #track_report where day='Sat' and cdate<>'Average'),0)
update #track_report set arrival   = (select sum(arrival)    from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set overs     = (select sum(overs)      from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set walkin    = (select sum(walkin)     from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set returngst = (select sum(returngst)  from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set ttlocc    = (select sum(ttlocc)     from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set occper    = (select sum(occper)     from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set gstcount  = (select sum(gstcount)   from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set occmult   = (select sum(occmult)    from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set roomrev   = (select sum(roomrev)    from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set availroom = (select sum(availroom)  from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set avgrmrate = (select sum(avgrmrate)  from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set revepar   = (select sum(revepar)    from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set totalreve = (select sum(totalreve)  from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set spendpar  = (select sum(spendpar)   from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set noshow    = (select sum(noshow)     from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
update #track_report set cancel    = (select sum(cancel)     from #track_report where day='Sat' and cdate<>'Average')/@count where cdate = 'Average' and day='Sat' and @count <> 0
select @count = isnull((select count(1) from  #track_report where day='Sun' and cdate<>'Average'),0)
update #track_report set arrival   = (select sum(arrival)    from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set overs     = (select sum(overs)      from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set walkin    = (select sum(walkin)     from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set returngst = (select sum(returngst)  from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set ttlocc    = (select sum(ttlocc)     from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set occper    = (select sum(occper)     from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set gstcount  = (select sum(gstcount)   from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set occmult   = (select sum(occmult)    from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set roomrev   = (select sum(roomrev)    from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set availroom = (select sum(availroom)  from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set avgrmrate = (select sum(avgrmrate)  from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set revepar   = (select sum(revepar)    from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set totalreve = (select sum(totalreve)  from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set spendpar  = (select sum(spendpar)   from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set noshow    = (select sum(noshow)     from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
update #track_report set cancel    = (select sum(cancel)     from #track_report where day='Sun' and cdate<>'Average')/@count where cdate = 'Average' and day='Sun' and @count <> 0
select @count = isnull((select count(1) from  #track_report where day='Mon' and cdate<>'Average'),0)
update #track_report set arrival   = (select sum(arrival)    from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set overs     = (select sum(overs)      from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set walkin    = (select sum(walkin)     from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set returngst = (select sum(returngst)  from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set ttlocc    = (select sum(ttlocc)     from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set occper    = (select sum(occper)     from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set gstcount  = (select sum(gstcount)   from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set occmult   = (select sum(occmult)    from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set roomrev   = (select sum(roomrev)    from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set availroom = (select sum(availroom)  from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set avgrmrate = (select sum(avgrmrate)  from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set revepar   = (select sum(revepar)    from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set totalreve = (select sum(totalreve)  from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set spendpar  = (select sum(spendpar)   from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set noshow    = (select sum(noshow)     from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
update #track_report set cancel    = (select sum(cancel)     from #track_report where day='Mon' and cdate<>'Average')/@count where cdate = 'Average' and day='Mon' and @count <> 0
select @count = isnull((select count(1) from  #track_report where day='Tue' and cdate<>'Average'),0)
update #track_report set arrival   = (select sum(arrival)    from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set overs     = (select sum(overs)      from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set walkin    = (select sum(walkin)     from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set returngst = (select sum(returngst)  from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set ttlocc    = (select sum(ttlocc)     from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set occper    = (select sum(occper)     from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set gstcount  = (select sum(gstcount)   from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set occmult   = (select sum(occmult)    from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set roomrev   = (select sum(roomrev)    from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set availroom = (select sum(availroom)  from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set avgrmrate = (select sum(avgrmrate)  from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set revepar   = (select sum(revepar)    from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set totalreve = (select sum(totalreve)  from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set spendpar  = (select sum(spendpar)   from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set noshow    = (select sum(noshow)     from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
update #track_report set cancel    = (select sum(cancel)     from #track_report where day='Tue' and cdate<>'Average')/@count where cdate = 'Average' and day='Tue' and @count <> 0
select @count = isnull((select count(1) from  #track_report where day='Wed' and cdate<>'Average'),0)
update #track_report set arrival   = (select sum(arrival)    from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set overs     = (select sum(overs)      from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set walkin    = (select sum(walkin)     from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set returngst = (select sum(returngst)  from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set ttlocc    = (select sum(ttlocc)     from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set occper    = (select sum(occper)     from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set gstcount  = (select sum(gstcount)   from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set occmult   = (select sum(occmult)    from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set roomrev   = (select sum(roomrev)    from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set availroom = (select sum(availroom)  from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set avgrmrate = (select sum(avgrmrate)  from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set revepar   = (select sum(revepar)    from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set totalreve = (select sum(totalreve)  from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set spendpar  = (select sum(spendpar)   from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set noshow    = (select sum(noshow)     from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
update #track_report set cancel    = (select sum(cancel)     from #track_report where day='Wed' and cdate<>'Average')/@count where cdate = 'Average' and day='Wed' and @count <> 0
select @count = isnull((select count(1) from  #track_report where day='Thu' and cdate<>'Average'),0)
update #track_report set arrival   = (select sum(arrival)    from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set overs     = (select sum(overs)      from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set walkin    = (select sum(walkin)     from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set returngst = (select sum(returngst)  from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set ttlocc    = (select sum(ttlocc)     from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set occper    = (select sum(occper)     from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set gstcount  = (select sum(gstcount)   from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set occmult   = (select sum(occmult)    from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set roomrev   = (select sum(roomrev)    from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set availroom = (select sum(availroom)  from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set avgrmrate = (select sum(avgrmrate)  from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set revepar   = (select sum(revepar)    from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set totalreve = (select sum(totalreve)  from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set spendpar  = (select sum(spendpar)   from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set noshow    = (select sum(noshow)     from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
update #track_report set cancel    = (select sum(cancel)     from #track_report where day='Thu' and cdate<>'Average')/@count where cdate = 'Average' and day='Thu' and @count <> 0
select @count = isnull((select count(1) from  #track_report where day='Fri' and cdate<>'Average'),0)
update #track_report set arrival   = (select sum(arrival)    from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set overs     = (select sum(overs)      from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set walkin    = (select sum(walkin)     from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set returngst = (select sum(returngst)  from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set ttlocc    = (select sum(ttlocc)     from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set occper    = (select sum(occper)     from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set gstcount  = (select sum(gstcount)   from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set occmult   = (select sum(occmult)    from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set roomrev   = (select sum(roomrev)    from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set availroom = (select sum(availroom)  from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set avgrmrate = (select sum(avgrmrate)  from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set revepar   = (select sum(revepar)    from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set totalreve = (select sum(totalreve)  from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set spendpar  = (select sum(spendpar)   from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set noshow    = (select sum(noshow)     from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0
update #track_report set cancel    = (select sum(cancel)     from #track_report where day='Fri' and cdate<>'Average')/@count where cdate = 'Average' and day='Fri' and @count <> 0

--Î²²¿--
insert #track_report select '2020.01.01','Monthly Tatol',null,9,null,sum(arrival),sum(overs),sum(walkin),sum(returngst),sum(ttlocc),sum(occper),sum(gstcount),
			sum(occmult),sum(roomrev),sum(availroom),sum(avgrmrate),sum(revepar),sum(totalreve),sum(spendpar),sum(noshow),sum(cancel)
			from #track_report where cdate <> 'Average'
insert #track_report select '2020.01.01','Daily Average',null,10,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
update #track_report set arrival   = (select sum(arrival)    from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set overs     = (select sum(overs)      from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set walkin    = (select sum(walkin)     from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set returngst = (select sum(returngst)  from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set ttlocc    = (select sum(ttlocc)     from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set occper    = (select sum(occper)     from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set gstcount  = (select sum(gstcount)   from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set occmult   = (select sum(occmult)    from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set roomrev   = (select sum(roomrev)    from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set availroom = (select sum(availroom)  from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set avgrmrate = (select sum(avgrmrate)  from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set revepar   = (select sum(revepar)    from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set totalreve = (select sum(totalreve)  from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set spendpar  = (select sum(spendpar)   from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set noshow    = (select sum(noshow)     from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'
update #track_report set cancel    = (select sum(cancel)     from #track_report where  cdate='Monthly Tatol')/@count1 where cdate = 'Daily Average'

update #track_report set day= ''    where week<>'3'
update #track_report set day= '===' where week='A'
--result--
select day,week,cdate,arrival,overs,walkin,returngst,ttlocc,occper,gstcount,
		 occmult,roomrev,availroom,avgrmrate,revepar,totalreve,spendpar,noshow,cancel
 from #track_report order by weekday,week,date
return
;
