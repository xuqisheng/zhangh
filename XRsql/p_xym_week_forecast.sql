create proc p_xym_week_forecast
	@stime			datetime,
	@etime         datetime
as
declare 	@swtime			datetime,
         @ewtime        datetime,
         @smtime        datetime,
         @emtime        datetime,
         @sytime        datetime,
         @eytime        datetime,
         @eymtime       datetime,
			@id				int,
			@sort				char(3),
         @y_time        datetime,
         @x_time        datetime,
         @m_time        datetime,
			@rmttl				int,
         @class         char(10),
  @charge        money,
         @days          int,
         @rooms         int,
			@rooms1			int		--add by ll 2010-6-1



select @swtime = dateadd(dd,-7,@stime)
select @ewtime = dateadd(dd,-7,@etime)
select @emtime = dateadd(mm,-1,@etime)
select @sytime = dateadd(yy,-1,@stime)
select @eytime= dateadd(yy,-1,@etime)
select @eymtime= dateadd(yy,-1,@etime)

select @days = datediff(dd,@stime,@etime) + 1

update week_forecast set  week = 0,
                         oweek = 0,
                         wdiff = 0,
                         pweek = 0,
                         pdiff = 0,
                         month = 0,
                        omonth = 0,
                         mdiff = 0,
                        pmonth = 0,
                        pmdiff = 0

declare c_jierep cursor for
		select distinct class,sum(day99)  from yjierep where date>=@stime and date<=@etime group by class	order by class
	open c_jierep
	fetch c_jierep into @class,@charge
	while @@sqlstatus = 0
		begin
        update week_forecast set week = @charge where class = @class and mode = '0'
		fetch c_jierep into @class,@charge
		end
deallocate cursor c_jierep

declare c_jierep cursor for
		select distinct class,sum(day99)  from yjierep where date>=@swtime and date<=@ewtime group by class order by class
	open c_jierep
	fetch c_jierep into @class,@charge
	while @@sqlstatus = 0
		begin
        update week_forecast set oweek = @charge where class = @class and mode = '0'
		fetch c_jierep into @class,@charge
		end
deallocate cursor c_jierep

declare c_jierep cursor for
		select distinct class,sum(day99)  from yjierep where date>=@sytime and date<=@eytime group by class order by class
	open c_jierep
	fetch c_jierep into @class,@charge
	while @@sqlstatus = 0
		begin
        update week_forecast set pweek = @charge where class = @class and mode = '0'
		fetch c_jierep into @class,@charge
		end
deallocate cursor c_jierep

declare c_jierep cursor for
		select distinct class,month99  from yjierep where date=@etime  order by class
	open c_jierep
	fetch c_jierep into @class,@charge
	while @@sqlstatus = 0
		begin
        update week_forecast set month = @charge where class = @class and mode = '0'
		fetch c_jierep into @class,@charge
		end
deallocate cursor c_jierep

declare c_jierep cursor for
		select distinct class,month99  from yjierep where date=@emtime  order by class
	open c_jierep
	fetch c_jierep into @class,@charge
	while @@sqlstatus = 0
		begin
        update week_forecast set omonth = @charge where class = @class and mode = '0'
		fetch c_jierep into @class,@charge
		end
deallocate cursor c_jierep

declare c_jierep cursor for
		select distinct class,month99  from yjierep where date=@eymtime  order by class
	open c_jierep
	fetch c_jierep into @class,@charge
	while @@sqlstatus = 0
		begin
        update week_forecast set pmonth = @charge where class = @class and mode = '0'
		fetch c_jierep into @class,@charge
		end
deallocate cursor c_jierep

update week_forecast set week = round((select a.week from week_forecast a where a.class = week_forecast.class and a.mode = '0')/@days,2),
              oweek = round((select a.oweek from week_forecast a where a.class = week_forecast.class and a.mode = '0')/@days,2),
                     pweek = round((select a.pweek from week_forecast a where a.class = week_forecast.class and a.mode = '0')/@days,2),
                     month = round((select a.month from week_forecast a where a.class = week_forecast.class and a.mode = '0')/@days,2),
                     omonth = round((select a.omonth from week_forecast a where a.class = week_forecast.class and a.mode = '0')/@days,2),
                     pmonth = round((select a.pmonth from week_forecast a where a.class = week_forecast.class and a.mode = '0')/@days,2)
                  where mode = '1'




update week_forecast set week = (select sum(day) from yjourrep  where date>=@stime and date<=@etime and class = '010030' ) where class= '0190'
select @rooms = (select sum(day) from yjourrep where date>=@stime and date<=@etime and class = '010020')
update week_forecast set week = round((select week from week_forecast where class= '010' and mode='0')/(select week from week_forecast where class = '0190' and mode = '0'),2) where class= '0191'
update week_forecast set week = round((select week from week_forecast where class = '0190' and mode = '0')/@rooms,2)where class= '0192'
select @rooms1 = (select sum(day) from yjourrep where date>=@stime and date<=@etime and class = '010012')
update week_forecast set week = round((select week from week_forecast where class = '0190' and mode = '0')/@rooms1,2)where class= '0193'


update week_forecast set oweek = (select sum(day) from yjourrep  where date>=@swtime and date<=@ewtime and class = '010030' ) where class= '0190'
select @rooms = (select sum(day) from yjourrep where date>=@swtime and date<=@ewtime and class = '010020')
update week_forecast set oweek = round((select oweek from week_forecast where class= '010' and mode='0')/(select oweek from week_forecast where class = '0190' and mode = '0'),2) where class= '0191'
update week_forecast set oweek = round((select oweek from week_forecast where class = '0190' and mode = '0')/@rooms,2) where class= '0192'
select @rooms1 = (select sum(day) from yjourrep where date>=@swtime and date<=@ewtime and class = '010012')
update week_forecast set oweek = round((select oweek from week_forecast where class = '0190' and mode = '0')/@rooms1,2) where class= '0193'


update week_forecast set pweek = (select sum(day) from yjourrep  where date>=@sytime and date<=@eytime and class = '010030' ) where class= '0190'
select @rooms = (select sum(day) from yjourrep where date>=@sytime and date<=@eytime and class = '010020')
update week_forecast set pweek = round((select pweek from week_forecast where class= '010' and mode='0')/(select pweek from week_forecast where class = '0190' and mode = '0'),2) where class= '0191'
update week_forecast set pweek = round((select pweek from week_forecast where class = '0190' and mode = '0')/@rooms,2) where class= '0192'
select @rooms1 = (select sum(day) from yjourrep where date>=@sytime and date<=@eytime and class = '010012')
update week_forecast set pweek = round((select pweek from week_forecast where class = '0190' and mode = '0')/@rooms1,2) where class= '0193'



update week_forecast set month = (select month from yjourrep  where date=@etime and class = '010030' ) where class= '0190'
select @rooms = (select month from yjourrep where date=@etime and class = '010020')
update week_forecast set month = round((select month from week_forecast where class= '010' and mode='0')/(select month from week_forecast where class = '0190' and mode = '0'),2) where class= '0191'
update week_forecast set month = round((select month from week_forecast where class = '0190' and mode = '0')/@rooms,2) where class= '0192'
select @rooms1 = (select month from yjourrep where date=@etime and class = '010012')
update week_forecast set month = round((select month from week_forecast where class = '0190' and mode = '0')/@rooms1,2) where class= '0193'


update week_forecast set omonth = (select month from yjourrep  where date=@emtime and class = '010030' ) where class= '0190'
select @rooms = (select month from yjourrep where date=@emtime and class = '010020')
update week_forecast set omonth = round((select omonth from week_forecast where class= '010' and mode='0')/(select omonth from week_forecast where class = '0190' and mode = '0'),2) where class= '0191'
update week_forecast set omonth = round((select omonth from week_forecast where class = '0190' and mode = '0')/@rooms,2) where class= '0192'
select @rooms1 = (select month from yjourrep where date=@emtime and class = '010012')
update week_forecast set omonth = round((select omonth from week_forecast where class = '0190' and mode = '0')/@rooms1,2) where class= '0193'


update week_forecast set pmonth = (select month from yjourrep  where date=@eymtime and class = '010030' ) where class= '0190'
select @rooms = (select month from yjourrep where date=@eymtime and class = '010020')
update week_forecast set pmonth = round((select pmonth from week_forecast where class= '010' and mode='0')/(select pmonth from week_forecast where class = '0190' and mode = '0'),2) where class= '0191'
update week_forecast set pmonth = round((select pmonth from week_forecast where class = '0190' and mode = '0')/@rooms,2) where class= '0192'
select @rooms1 = (select month from yjourrep where date=@eymtime and class = '010012')
update week_forecast set pmonth = round((select pmonth from week_forecast where class = '0190' and mode = '0')/@rooms1,2) where class= '0193'


update week_forecast set wdiff = week - oweek,pdiff = week - pweek,mdiff = month- omonth,pmdiff = month - pmonth


return 0