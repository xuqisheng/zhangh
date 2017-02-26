drop proc p_cq_sp_place_create_date;
create procedure p_cq_sp_place_create_date
			@bdate			datetime,
			@allow			char(1)
			
			
as
declare
		@date1		datetime,
		@dt_date		datetime,
		@sysdate		char(2),
		@li_res		integer,
		@date_t		char(2),
		@week			integer,
		@week1		integer,
		@li_count   integer,
		@li_count1  integer,
		@li_total1	integer,
		@li_total2	integer,
		@li_total3	integer,
		@check		char(2),
		@color		char(20),
		@status		char(1),
		@selected	char(1),
		@inumber		integer

create table #place_date
(
	date_t			char(2),
	dt_date			datetime,
	week				integer,
	menus				integer,
	color				char(20),
	status			char(1),
	selected			char(1)
)

create table #date
(
	date_1			char(2),
	date_2			char(2),
	date_3			char(2),
	date_4			char(2),
	date_5			char(2),
	date_6			char(2),
	date_7			char(2),
	color_1			char(20),
	color_2			char(20),
	color_3			char(20),
	color_4			char(20),
	color_5			char(20),
	color_6			char(20),
	color_7			char(20),
	status_1			char(1),
	status_2			char(1),
	status_3			char(1),
	status_4			char(1),
	status_5			char(1),
	status_6			char(1),
	status_7			char(1),
	dtdate_1			datetime,
	dtdate_2			datetime,
	dtdate_3			datetime,
	dtdate_4			datetime,
	dtdate_5			datetime,
	dtdate_6			datetime,
	dtdate_7			datetime,
	selected			char(1),
	bdate				datetime,
	inumber			integer	
)

select @inumber = 1

select @sysdate = rtrim(convert(char(2),datepart(day,@bdate)))
if @sysdate <> '1'
	select @bdate = dateadd(day,-datepart(day,@bdate) + 1,@bdate)


select @date1 = @bdate
select @li_res = datediff(month,@bdate,@date1)
while @li_res = 0
	begin
	select @color = '536870912',@li_total1 = 0,@li_total2 = 0,@li_total3 = 0,@li_count = 0
	select @date_t = convert(char(2),(select datepart(day,@date1) )),@week = (select datepart(weekday,@date1))
	select @li_total1 = isnull(count(1),0) from sp_plaav where datediff(day,@date1,stime) = 0 and charindex(rtrim(sta),'IR') > 0
	select @li_total2 = isnull(count(1),0) from sp_pla_use where datediff(day,@date1,stime) = 0 and charindex(rtrim(sta),'I') > 0
	select @li_total3 = isnull(count(1),0) from sp_plaooo where datediff(day,@date1,stime) = 0 and charindex(rtrim(sta),'O') > 0
	select @li_count = @li_total1 + @li_total2 + @li_total3
	select @color = isnull(color,'536870912') from sp_color_define where number = (select isnull(max(number),0) from sp_color_define where number <= @li_count)
	insert #place_date select @date_t,@date1,@week,@li_count,isnull(@color,'536870912'),'T',''
	select @date1 = dateadd(day,1,@date1)
	select @li_res = datediff(month,@bdate,@date1)
	end

select @week1 = week,@date1 = dt_date from #place_date where dt_date = (select max(dt_date) from #place_date)
while	@week1 < 7
	begin
	select @color = '536870912',@li_total1 = 0,@li_total2 = 0,@li_total3 = 0,@li_count = 0
	select @date1 = dateadd(day,1,@date1)
	select @date_t = convert(char(2),(select datepart(day,@date1) )),@week = (select datepart(weekday,@date1))
	select @li_total1 = isnull(count(1),0) from sp_plaav where datediff(day,@date1,stime) = 0 and charindex(rtrim(sta),'IR') > 0
	select @li_total2 = isnull(count(1),0) from sp_pla_use where datediff(day,@date1,stime) = 0 and charindex(rtrim(sta),'I') > 0
	select @li_total3 = isnull(count(1),0) from sp_plaooo where datediff(day,@date1,stime) = 0 and charindex(rtrim(sta),'O') > 0
	select @li_count = @li_total1 + @li_total2 + @li_total3
	select @color = isnull(color,'536870912') from sp_color_define where number = (select isnull(max(number),0) from sp_color_define where number <= @li_count)
	insert #place_date select @date_t,@date1,@week,@li_count,isnull(@color,'536870912'),'F',''
	select @week1 = @week1 + 1
	end


select @week1 = week,@date1 = dt_date from #place_date where dt_date = (select min(dt_date) from #place_date)
select @li_count1 = count(1) from #place_date
while	@week1 > 1 or @li_count1 < 42
	begin
	select @color = '536870912',@li_total1 = 0,@li_total2 = 0,@li_total3 = 0,@li_count = 0
	select @date1 = dateadd(day,-1,@date1)
	select @date_t = convert(char(2),(select datepart(day,@date1) )),@week = (select datepart(weekday,@date1))
	select @li_total1 = isnull(count(1),0) from sp_plaav where datediff(day,@date1,stime) = 0 and charindex(rtrim(sta),'IR') > 0
	select @li_total2 = isnull(count(1),0) from sp_pla_use where datediff(day,@date1,stime) = 0 and charindex(rtrim(sta),'I') > 0
	select @li_total3 = isnull(count(1),0) from sp_plaooo where datediff(day,@date1,stime) = 0 and charindex(rtrim(sta),'O') > 0
	select @li_count = @li_total1 + @li_total2 + @li_total3
	select @color = isnull(color,'536870912') from sp_color_define where number = (select isnull(max(number),0) from sp_color_define where number <= @li_count)
	insert #place_date select @date_t,@date1,@week,@li_count,isnull(@color,'536870912'),'F',''
	select @li_count1 = count(1) from #place_date
	select @week1 = @week1 - 1
	end
--更新具体的某一天的选中状态
update #place_date set selected = convert(char(1),week) where rtrim(date_t) = rtrim(@sysdate)

declare c_date cursor for 
	select date_t,color,status,week,selected,dt_date from #place_date order by dt_date,date_t
open c_date
fetch c_date into @date_t,@color,@status,@week,@selected,@dt_date
while @@sqlstatus = 0 
	begin
	if @week = 1 
		begin
		select @check = @date_t
		insert #date select @date_t,'','','','','','',@color,'','','','','','',@status,'','','','','','',@dt_date,getdate(),getdate(),getdate(),getdate(),getdate(),getdate(),'',@bdate,@inumber
		end
	if @week = 2
		update #date set date_2 = @date_t,color_2 = @color,status_2 = @status,dtdate_2 = @dt_date where date_1 = @check
	if @week = 3
		update #date set date_3 = @date_t,color_3 = @color,status_3 = @status,dtdate_3 = @dt_date where date_1 = @check
	if @week = 4
		update #date set date_4 = @date_t,color_4 = @color,status_4 = @status,dtdate_4 = @dt_date where date_1 = @check
	if @week = 5
		update #date set date_5 = @date_t,color_5 = @color,status_5 = @status,dtdate_5 = @dt_date where date_1 = @check
	if @week = 6
		update #date set date_6 = @date_t,color_6 = @color,status_6 = @status,dtdate_6 = @dt_date where date_1 = @check
	if @week = 7
		update #date set date_7 = @date_t,color_7 = @color,status_7 = @status,dtdate_7 = @dt_date where date_1 = @check
	if rtrim(@date_t) = rtrim(@sysdate) and datediff(mm,@dt_date,@bdate) = 0
		update #date set selected = @selected where date_1 = @check 
	select @inumber = @inumber + 1
	fetch c_date into @date_t,@color,@status,@week,@selected,@dt_date
	end

close c_date
deallocate cursor c_date
if @allow <> 'T' 
	update #date set color_1 = '536870912',color_2 = '536870912',color_3 = '536870912',color_4 = '536870912',color_5 = '536870912',color_6 = '536870912',color_7 = '536870912'
select * from #date order by dtdate_1,date_1
;
