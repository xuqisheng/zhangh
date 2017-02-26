if exists(select * from sysobjects where name = 'p_gl_public_calendar')
	drop proc p_gl_public_calendar;

create proc p_gl_public_calendar	
	@year						integer,
	@month					integer,
	@date						datetime,
	@operation				char(60)			/*	第一位:Day Type or Week
														第二位:阴历 or 到达/离开
														第三位:事件
														第四位:团体
														第五位:可用/占用/不显示
														第六位:百分比
														第七位:进度条	*/
as

declare
	@bdate					datetime,
	@fdate					datetime,
	@cdate					datetime,
	@class					char(1),
	@descript				char(2),
	@count					integer,
	@event					varchar(20),
	@events					varchar(255),
	@group					varchar(20),
	@groups					varchar(255),
	@week						integer,
	@quantity				integer,
	@m1						money, 
	@m2						money,
	@m3						money,
	@s3						integer,
	@s4						integer

create table #calendar
(
	date				datetime		not null,
	s0					char(255)	default ''	null,
	s1					char(255)	default ''	null,
	s2					char(255)	default ''	null,
	s3					char(255)	default ''	null,
	s4					char(255)	default ''	null,
	m1					money			default 0	null, 
	m2					money			default 0	null,
	m3					money			default 0	null,
	visible			integer		default 1	null
)
create table #group
(
	accnt				char(10)		not null,
	quantity			money			default 0	null, 
)
//
select @bdate = bdate1 from sysdata
select @fdate = convert(datetime, convert(char(4), @year) + '/' + convert(char(2), @month) + '/1')
select @week  = datepart(dw, @fdate), @s3 = 0, @s4 = 0
while @week > 1
	begin
	insert #calendar (date) select dateadd(dd, 1 - @week, @fdate)
	select @week  = @week - 1
	end
//
declare c_events cursor for
	select descript from events where sta = 'I' and begin_ <= @fdate and @fdate <= end_
declare c_groups cursor for
	select c.name, a.quantity from #group a, master b, guest c
		where a.accnt = b.accnt and b.haccnt = c.no order by a.quantity desc
//
while datepart(month, @fdate) = @month
	begin
	if substring(@operation, 5, 1) = '1' and @fdate >= @bdate
		begin
		exec p_gds_reserve_rsv_index @fdate, '%', 'Room to Rent', 'R', @m1 output
		exec p_gds_reserve_rsv_index @fdate, '%', 'Available Rooms', 'R', @m2 output
		if @m1 != 0
			select @m1 = @m2*100.00/@m1
		end
	else if substring(@operation, 5, 1) = '2' and @fdate >= @bdate
		begin
		exec p_gds_reserve_rsv_index @fdate, '%', 'Room to Rent', 'R', @m1 output
		exec p_gds_reserve_rsv_index @fdate, '%', 'Definite Reservations', 'R', @m2 output
		if @m1 != 0
			select @m1 = @m2*100.00/@m1
		end
	else
		select @m1 = 0, @m2 = 0
//
	if substring(@operation, 3, 1) = '1' and @fdate >= @bdate
		begin
		select @events = '', @count = 0
		open c_events
		fetch c_events into @event
		while @@sqlstatus = 0
			begin
			if charindex(@event, @events) = 0
				select @events = @events + @event + char(10) + char(13)
			fetch c_events into @event
			end
		close c_events
		end
//
	if substring(@operation, 4, 1) = '1' and @fdate >= @bdate
		begin
		truncate table #group
		insert #group (accnt, quantity) select isnull(rtrim(b.groupno), b.accnt), sum(a.quantity)
			from rsvsaccnt a, master b
			where a.begin_<>a.end_ and a.begin_<=@fdate and a.end_>@fdate
			and a.accnt=b.accnt and (b.groupno like '[G,M]%' or b.accnt like '[G,M]%')
			group by isnull(rtrim(b.groupno), b.accnt)
//
		select @groups = '', @count = 0
		open c_groups
		fetch c_groups into @group, @quantity
		while @@sqlstatus = 0
			begin
			if charindex(@group, @groups) = 0
				select @groups = @groups + rtrim(convert(char(5), @quantity)) + '/' + @group + char(10) + char(13)
				fetch c_groups into @group, @quantity
			end
		close c_groups
		end
//
	if substring(@operation, 2, 1) = '2' and @fdate >= @bdate
		begin
		exec p_gds_reserve_rsv_index @fdate, '%', 'Arrival Rooms', 'R', @s3 output
		exec p_gds_reserve_rsv_index @fdate, '%', 'Departure Rooms', 'R', @s4 output
		end
	insert #calendar (date, s1, m1, m2, m3, s3, s4, visible)
		select @fdate, ltrim(@events) + ltrim(@groups), @m1 / 100, @m2, @m1 / 100, ltrim(convert(char(5), @s3)), ltrim(convert(char(5), @s4)), 0
	select @fdate = dateadd(day, 1, @fdate)
	end
//
deallocate cursor c_events
deallocate cursor c_groups
//
select @week  = datepart(dw, @fdate)
while @week <> 1
	begin
	insert #calendar (date) select @fdate
	select @fdate = dateadd(day, 1, @fdate)
	select @week  = datepart(dw, @fdate)
	end
//
if substring(@operation, 1, 1) = '1'
	update #calendar set s2 = a.factor from rmrate_calendar a where #calendar.date = a.date
else
	update #calendar set s2 = '(' + ltrim(convert(char(2), datepart(week, date))) + ')' where datepart(dw, date) = 1
//
if substring(@operation, 2, 1) = '1'
	begin
	update #calendar set s0 = a.descript2, s3 = a.descript3, s4 = a.descript4 from lunar a where #calendar.date = a.date
	update #calendar set s3 = s0 + s3 where s3 in ('大', '小')
	end
//
select date, day = datepart(day, date), s1, s2, s3, s4, m1, m2, m3, visible from #calendar order by date
//
return 0
;

