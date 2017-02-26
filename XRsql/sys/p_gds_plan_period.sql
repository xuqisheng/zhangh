create proc p_gds_plan_period
	@cat				varchar(30),
	@owner			varchar(30),
	@type				char(1),
	@action  		varchar(10),		-- check, current, next, previous, create
	@empno			char(10),
	@retmode  		char(1) = 'S',
	@period			varchar(30)		output,
	@msg				varchar(60)		output
as
---------------------------------------------------------------------------------------------------------
-- plan period : check & get & create
--
--		如果仅仅是 get, 是否可以不考虑 cat ?
---------------------------------------------------------------------------------------------------------
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
				@ptype		char(1),	-- period type
				@bdate		datetime,
				@date			datetime

select @ret=0, @msg='', @bdate=bdate1 from sysdata
if not exists(select 1 from plan_cat where cat=@cat)
  or not exists(select 1 from basecode where cat='plan_type' and code=@type)
begin
	select @ret=1, @msg='FOXHIS: Proc Input Code Error.输入区间错误'
	goto goutput
end

select @ptype = substring(@period,1,1)
if @ptype=''
begin 
	select @ptype=substring(plantype,1,1) from plan_cat where cat=@cat
end
if not exists(select 1 from basecode where cat='plan_period' and code=@ptype)
begin
	select @ret=1, @msg='FOXHIS: Proc Input Code Error.输入区间错误'
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
		select @ret=1, @msg='FOXHIS: Period Code Error.输入区间错误'
		goto goutput
	end

end
else if @action in ('check', 'previous', 'next', 'create')
begin
	-- 区间有效性检测
	if @period=''
	begin
		select @ret=1, @msg='FOXHIS: Period Code Error1.输入区间错误'
		goto goutput
	end
	if @ptype<>substring(@period,1,1) 		-- 判断首位字母
	begin
		select @ret=1, @msg='FOXHIS: Period Code Error2.输入区间错误'
		goto goutput
	end
	select @year=substring(@period, 2, 4)	-- 判断年份
	if @year<'1900' or @year>'2050'
	begin
		select @ret=1, @msg='FOXHIS: Period Code Error3.输入区间错误'
		goto goutput
	end
	select @len=datalength(rtrim(@period)), @pos = 2
	while @pos < @len 							-- 判断是否有字母
	begin
		select @char = substring(@period, @pos, 1)
		if charindex(@char, '0123456789')=0
		begin
			select @ret=1, @msg='FOXHIS: Period Code Error4.输入区间错误'
			goto goutput
		end
		select @pos = @pos + 1
	end

	-- Y=年		Y2006
	if @ptype='Y'
	begin
		if @len<>5
		begin
			select @ret=1, @msg='FOXHIS: Period Code Error5.输入区间错误'
			goto goutput
		end
		if @action='previous'
			select @period = 'Y' + convert(char(4), convert(int,@year) - 1)
		else if @action='next'
			select @period = 'Y' + convert(char(4), convert(int,@year) + 1)
	end
	-- S=季度	S20061
	else if @ptype='S'
	begin
		select @char = substring(@period,6,1)
		if (@len<>6 or @char<'1' or @char>'4')
		begin
			select @ret=1, @msg='FOXHIS: Period Code Error6.输入区间错误'
			goto goutput
		end
		if @action='previous'
		begin
			if @char='1'
				select @period = 'S' + convert(char(4), convert(int,@year) - 1) + '4'
			else
				select @period = 'S' + @year + convert(char(1), convert(int,@char) - 1)
		end
		else if @action='next'
		begin
			if @char='4'
				select @period = 'S' + convert(char(4), convert(int,@year) + 1) + '1'
			else
				select @period = 'S' + @year + convert(char(1), convert(int,@char) + 1)
		end
	end
	-- M=月		M200608
	else if @ptype='M'
	begin
		select @month = substring(@period,6,2)
		if (@len<>7 or @month<'01' or @month>'12')
		begin
			select @ret=1, @msg='FOXHIS: Period CodeError7.输入区间错误'
			goto goutput
		end
		select @date = convert(datetime, substring(@period,2,6)+'01')
		if @action='previous'
		begin
			select @date = dateadd(month, -1, @date)
			select @period = 'M' + convert(char(6), @date, 112)
		end
		else if @action='next'
		begin
			select @date = dateadd(month, +1, @date)
			select @period = 'M' + convert(char(6), @date, 112)
		end
	end
	-- H=半月	H2006081, H2006082
	else if @ptype='H'
	begin
		select @month = substring(@period,6,2)
		select @char = substring(@period,8,1)
		if (@len<>8 or @month<'01' or @month>'12' or @char<'1' or @char>'2')
		begin
			select @ret=1, @msg='FOXHIS: Period Code Error8.输入区间错误'
			goto goutput
		end
		select @date = convert(datetime, substring(@period,2,6)+'01')
		if @action = 'previous'
		begin
			if @char = '1'
			begin
				select @date = dateadd(month, -1, @date)
				select @period = 'H' + convert(char(6), @date, 112)  + '2'
			end
			else
				select @period = 'H' + @year + @month + '1'
		end
		else if @action = 'next'
		begin
			if @char = '2'
			begin
				select @date = dateadd(month, +1, @date)
				select @period = 'H' + convert(char(6), @date, 112)  + '1'
			end
			else
				select @period = 'H' + @year + @month + '2'
		end
	end
	-- X=旬		X2006081, X2006082, X2006083
	else if @ptype='X'
	begin
		select @month = substring(@period,6,2)
		select @char = substring(@period,8,1)
		if (@len<>8 or @month<'01' or @month>'12' or @char<'1' or @char>'3')
		begin
			select @ret=1, @msg='FOXHIS: Period Code Error9.输入区间错误'
			goto goutput
		end
		select @date = convert(datetime, substring(@period,2,6)+'01')
		if @action = 'previous'
		begin
			if @char = '1'
			begin
				select @date = dateadd(month, -1, @date)
				select @period = 'X' + convert(char(6), @date,112)  + '3'
			end
			else if @char = '2'
				select @period = 'X' + @year + @month + '1'
			else
				select @period = 'X' + @year + @month + '2'
		end
		else if @action = 'next'
		begin
			if @char = '3'
			begin
				select @date = dateadd(month, +1, @date)
				select @period = 'X' + convert(char(6), @date,112)  + '1'
			end
			else if @char = '1'
				select @period = 'X' + @year + @month + '2'
			else
				select @period = 'X' + @year + @month + '3'
		end
	end
	-- W=星期	W200635
	else if @ptype='W'
	begin
		select @week = substring(@period,6,2)
		declare  @weekmax  char(2)
		select @weekmax = convert(char(2), datepart(week, convert(datetime,@year+'1231')))
		if  (@len<>7 or @week<'01' or @week>@weekmax)
		begin
			select @ret=1, @msg='FOXHIS: Period Code Error10.输入区间错误'
			goto goutput
		end
		if @action = 'previous'
		begin
			if @week='01'
			begin
				select @year=convert(char(4), convert(int,@year) - 1)
				select @weekmax = convert(char(2), datepart(week, convert(datetime,@year+'1231')))
				select @period='W'+@year+@weekmax
			end
			else
				select @period='W'+@year+right('00'+rtrim(convert(char(2),convert(int, @week) - 1)), 2)
		end
		else if @action = 'next'
		begin
			if @week=@weekmax
			begin
				select @year=convert(char(4), convert(int,@year) + 1)
				select @period='W'+@year+'01'
			end
			else
				select @period='W'+@year+right('00'+rtrim(convert(char(2),convert(int, @week) + 1)), 2)
		end
	end
	-- D=天		D20060828
	else if @ptype='D'
	begin
		select @month 	= substring(@period,6,2)
		select @day 	= substring(@period,8,2)
		if (@len<>9 or @month<'01' or @month>'12' or @day<'01' or @day>'31')
		begin
			select @ret=1, @msg='FOXHIS: Period Code Error11.输入区间错误'
			goto goutput
		end
		if @day > '28'  -- 日期的有效性 ,不仅仅是小于31
			if convert(char(8), dateadd(dd, convert(int,@day)-1, convert(datetime,@year+@month+'01')), 112) <> substring(@period,2,8)
			begin
				select @ret=1, @msg='FOXHIS: Period Code Error12.输入区间错误'
				goto goutput
			end
		select @date = convert(datetime, substring(@period,2,8))
		if @action = 'previous'
			select @period = 'D' + convert(char(8), dateadd(dd, -1, @date), 112)
		else if @action = 'next'
			select @period = 'D' + convert(char(8), dateadd(dd, +1, @date), 112)
	end

	-- 创建 相应区间的 plan_def
//	if @action = 'create'
//	begin
//		insert plan_def(cat,owner,type,clskey,class,period,empno,changed)
//			select a.cat,@owner,@type,a.clskey,a.class,@period,@empno,getdate()
//				from plan_code a
//				where cat=@cat
//					and a.cat+@owner+@type+a.clskey+a.class+@period not in (select b.cat+b.owner+b.type+b.clskey+b.class+b.period from plan_def bwhere b.cat=@cat and b.type=@type and b.period=@period)
//	end
end
else
begin
	select @ret=1, @msg='FOXHIS: Action Code Error.输入区间错误'
	goto goutput
end

--
goutput:
if @retmode = 'S'
	select @ret, @msg , @period
return @ret;
