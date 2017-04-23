drop proc p_hui_guest;
create proc p_hui_guest
	@date		datetime
as

	create table #rep(
		rmrent_d			money    DEFAULT 0 NULL,
		rmrent_m			money    DEFAULT 0 NULL,
		rmcount_d		money    DEFAULT 0 NULL,
		rmcount_m		money    DEFAULT 0 NULL,
		rmcharge_d		money    DEFAULT 0 NULL,
		rmcharge_m		money    DEFAULT 0 NULL,
		rmrate_d			money    DEFAULT 0 NULL,
		rmrate_m			money    DEFAULT 0 NULL,
		rmcount_ea1		integer	,
		rmcount_ea2		integer	,
		rmcount_ea3		integer	,
		rmcount_ed1		integer	,
		rmcount_ed2		integer	,
		rmcount_ed3		integer	,
		rmcount_1		integer	,
		rmcount_2		integer	,
		rmcount_3		integer
	)

	declare
		@rmrent_d		money    ,
		@rmrent_m		money    ,
		@rmcount_d		money    ,
		@rmcount_m		money    ,
		@rmcharge_d		money    ,
		@rmcharge_m		money    ,
		@rmrate_d		money    ,
		@rmrate_m		money		,
		@rmcount_ea1	integer	,
		@rmcount_ea2	integer	,
		@rmcount_ea3	integer	,
		@rmcount_ed1	integer	,
		@rmcount_ed2	integer	,
		@rmcount_ed3	integer	,
		@rmcount_1		integer	,
		@rmcount_2		integer	,
		@rmcount_3		integer	
		    
	
	
	select @rmrent_d 	  = day,	@rmrent_m   = month 	from yjourrep where date=dateadd(dd,-1,@date) and class = '010080'
	select @rmcount_d   = day,	@rmcount_m  = month 	from yjourrep where date=dateadd(dd,-1,@date) and class = '010030'
	select @rmcharge_d  = day,	@rmcharge_m = month 	from yjourrep where date=dateadd(dd,-1,@date) and class = '010130'
	select @rmrate_d    = day,	@rmrate_m   = month 	from yjourrep where date=dateadd(dd,-1,@date) and class = '010180'

	select @rmcount_ea1 = count( distinct roomno)	from master  where sta ='R' and datediff(dd, @date, arr)<=0 and class = 'F' and roomno<>''
	select @rmcount_ea2 = count( distinct roomno)	from master  where sta ='R' and datediff(dd, @date, arr)>0  and datediff(dd, @date, arr)<=1	and class = 'F'
	select @rmcount_ea3 = count( distinct roomno)	from master  where sta ='R' and datediff(dd, @date, arr)>1  and datediff(dd, @date, arr)<=2	and class = 'F'

	select @rmcount_ed1 = count( distinct roomno)	from master  where sta ='I' and datediff(dd, @date, dep)<=0 and class = 'F'
	select @rmcount_ed2 = count( distinct roomno)	from master  where sta ='I' and datediff(dd, @date, dep)>0  and datediff(dd, @date, dep)<=1 and class = 'F'
	select @rmcount_ed2 = count( distinct roomno) + @rmcount_ed2 from master  where sta ='R' and datediff(dd, @date, dep)>0  and datediff(dd, @date, dep)<=1 and class = 'F'
	select @rmcount_ed3 = count( distinct roomno)	from master  where sta ='I' and datediff(dd, @date, dep)>1  and datediff(dd, @date, dep)<=2 and class = 'F'
	select @rmcount_ed3 = count( distinct roomno) + @rmcount_ed3 from master  where sta ='R' and datediff(dd, @date, dep)>1  and datediff(dd, @date, dep)<=2 and class = 'F'

	select @rmcount_1	  = count( distinct roomno)	from master  where sta = 'I' and class = 'F'
	select @rmcount_2	  = count( distinct roomno)	from master  where sta = 'I' and datediff(dd,@date,dep)<=0 and class = 'F'
	select @rmcount_2   = count( distinct roomno) + @rmcount_2 	 from master  where sta = 'R' and datediff(dd, @date, arr)>0  and datediff(dd, @date, arr)<=1 and class = 'F'
	select @rmcount_3	  = count( distinct roomno)	from master  where sta = 'I' and datediff(dd,@date,dep)>1 and datediff(dd, @date,dep)<=2 and class = 'F'
	select @rmcount_3   = count( distinct roomno) + @rmcount_3 	 from master  where sta = 'R' and datediff(dd, @date, arr)>1  and datediff(dd, @date, arr)<=2 and class = 'F'


	insert into #rep(rmrent_d,rmrent_m,rmcount_d,rmcount_m,rmcharge_d,rmcharge_m,rmrate_d,rmrate_m,rmcount_ea1,rmcount_ea2,rmcount_ea3,rmcount_ed1,rmcount_ed2,rmcount_ed3,rmcount_1,rmcount_2,rmcount_3)
		select @rmrent_d,@rmrent_m,@rmcount_d,@rmcount_m,@rmcharge_d,@rmcharge_m,@rmrate_d,@rmrate_m,@rmcount_ea1,@rmcount_ea2,@rmcount_ea3,@rmcount_ed1,@rmcount_ed2,@rmcount_ed3,@rmcount_1,@rmcount_2,@rmcount_3

	select * from #rep

return;
