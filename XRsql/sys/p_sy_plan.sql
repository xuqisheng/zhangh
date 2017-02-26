create proc p_sy_plan
	@cat				varchar(30),
	@owner			varchar(30),
	@type				char(1),
	@action  		varchar(10),		-- check, current, next, previous, create
	@empno			char(10),
	@retmode  		char(1) = 'S',
	@ptype			char(1),	-- period type
	@period			varchar(30)		output,
	@msg				varchar(60)		output
as
declare		@ret			int,
				@pos			int,
				@count		int,
				@len			int,
				@cdate		char(8),	-- current date
				@year			char(4),
				@month		char(2),
				@day			char(2),
				@week			char(2),
				@char			char(1),
				@bdate		datetime,
				@date			datetime

select @ret=0, @msg='', @bdate=bdate1 from sysdata
if not exists(select 1 from plan_cat where cat=@cat)
  or not exists(select 1 from basecode where cat='plan_type' and code=@type)
begin
	select @ret=1, @msg='FOXHIS: Proc Input Code Error'
	goto goutput
end
if not exists(select 1 from basecode where cat='plan_period' and code=@ptype)
begin
	select @ret=1, @msg='FOXHIS: Proc Input Code Error'
	goto goutput
end

--
select @period = isnull(@period, '')
	-- Y=年		Y2006
	-- S=季度	S20061
	-- M=月		M200608
	-- H=半月	H2006081, H2006082
	-- X=旬		X2006081, X2006082, X2006083
	-- W=星期	W200635
	-- D=天		D20060828

if @action = 'current' -- 取得当前区间代码
begin
	select @cdate = convert(char(8), @bdate, 112)  -- yyyymmdd
	select @week = right('00' + ltrim(rtrim(convert(char(2), datepart(week, @bdate)))), 2)
	select @year=substring(@cdate,1,4), @month=substring(@cdate,5,2), @day=substring(@cdate,7,2)
	if @ptype='Y'
	begin
		select @period = 'Y' + @year
	end
	else if @ptype='S'
	begin
		select @period = 'S' + @year + convert(char(1), datepart(quarter, @bdate))
	end
	else if @ptype='M'
	begin
		select @period = 'M' + @year + @month
	end
	else if @ptype='H'
	begin
		if @day <= '15'
			select @period = 'H' + @year + @month + '1'
		else
			select @period = 'H' + @year + @month + '2'
	end
	else if @ptype='X'
	begin
		if @day <= '10'
			select @period = 'X' + @year + @month + '1'
		else if @day <= '20'
			select @period = 'X' + @year + @month + '2'
		else
			select @period = 'X' + @year + @month + '3'
	end
	else if @ptype='W'
	begin
		select @period = 'W' + @year + @week
	end
	else if @ptype='D'
	begin
		select @period = 'D' + @year + @month + @day
	end
	else
	begin
		select @ret=1, @msg='FOXHIS: Period Code Error'
		goto goutput
	end

end


goutput:
if @retmode = 'S'
	select @ret, @msg , @period
return @ret;
