IF OBJECT_ID('dbo.p_gds_reserve_rmsta_list_one') IS NOT NULL
    DROP PROCEDURE dbo.p_gds_reserve_rmsta_list_one
;
create  proc p_gds_reserve_rmsta_list_one
	@roomno	 char(5),
	@bdate	 datetime,
	@alldays	 int = 0
as

declare	@cdate		datetime,
			@quantity	int,
			@locked     char(1),
			@futsta     char(1),
			@futbegin   datetime,
			@futend     datetime,
			@numstr		varchar(250),
			@weekend		varchar(1)

select @numstr = NULL,@cdate = @bdate
select @bdate = isnull(@bdate,getdate())
select @alldays = 20 where @alldays > 20 or @alldays is null or @alldays=0    -- Max data length = 20
select @locked=locked, @futsta=futsta, @futbegin=futbegin, @futend=futend from rmsta where roomno=@roomno
if @@rowcount = 0 
	goto gout

while	datediff(day, @bdate, @cdate) < @alldays
begin
	if datepart(weekday,@cdate) = 7 
		select @weekend=', '
	else
		select @weekend=' '

	select @quantity = isnull((select sum(quantity) from rsvdtl
		 where roomno = @roomno and begin_ <= @cdate and end_ > @cdate), 0)
	if	@quantity = 0  -- 没有预留
	begin
		if @locked <> 'L'
			select @numstr = @numstr + "-" + @weekend
		else if (@futend is null or @futend > @cdate ) and @cdate >= @futbegin  -- 维修
			select @numstr = @numstr + @futsta + @weekend
		else
			select @numstr = @numstr + "-" + @weekend
	end
	else
		if	@quantity > 99 or @quantity < 0
			select @numstr = @numstr + "*" + @weekend   -- 占用过多
		else
		begin
			if	@quantity > 9
				select @numstr = @numstr + convert(char(2), @quantity) + @weekend
			else
				select @numstr = @numstr + convert(char(1), @quantity) + @weekend
		end
	select @cdate = dateadd(day, 1, @cdate)
end

-- Output
gout:
select numstr = @numstr

return 0
;
