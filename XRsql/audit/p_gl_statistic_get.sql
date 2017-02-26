if exists (select * from sysobjects where name ='p_gl_statistic_get' and type ='P')
	drop proc p_gl_statistic_get;
create proc p_gl_statistic_get
	@pc_id				char(4),
	@firstday			datetime,
	@lastday				datetime,
	@cat					char(30),
	@grp					char(10),
	@code					char(10),
	@option				char(10) = 'AM',	-- 参数与上一级是一样的	
													-- 第一位:P.物理月,A.会计月.第二位起含有D就算本日,M就算月累计,含有Y就算年累计,含有C就要准备descript
	@group				char(10) = 'grp,code'
as
--insert gdsmsg select @cat + '=cat ' + @grp + '=grp ' + @code+'=code '+@option+'=option '+@group +'=group'
declare
	@offset				integer,
	@cfirstday			datetime,
	@clastday			datetime,
	@year					integer,				-- 年
	@month				integer,				-- 月
	@index				char(31)

-- 存放结果的临时表
create table #statistic_t(
	cat					char(30)		Null,
	grp					char(10)		Default '' Null,
	code					char(10)		Default '' Null,
	amount				money			Default 0 Null
)
delete statistic_t where pc_id = @pc_id
--
if substring(@option, 2, 1) like '[0-9]'
	select @offset = convert(integer, substring(@option, 2, 9))
else if substring(@option, 3, 1) like '[0-9]'
	select @offset = convert(integer, substring(@option, 3, 8))
else if substring(@option, 4, 1) like '[0-9]'
	select @offset = convert(integer, substring(@option, 4, 7))
else
	select @offset = convert(integer, substring(@option, 5, 6))
--
if @option like 'Am%'
	begin
	select @option = 'T', @firstday = dateadd(mm, - @offset, @firstday), @lastday = dateadd(mm, - @offset, @lastday)
	select @cfirstday = firstday, @clastday = @lastday from firstdays where @lastday >= firstday and @lastday <= lastday
	select @firstday = isnull(@cfirstday, '2000/1/1'), @lastday = isnull(@clastday, '2000/1/1')
	end
else if @option like 'm%'
	select @option = 'm', @firstday = dateadd(mm, - @offset, @firstday), @lastday = dateadd(mm, - @offset, @lastday)
else if @option like 'AM%'
	begin
	select @option = 'T'
	select @year = year, @month = month from firstdays where @lastday >= firstday and @lastday <= lastday
	select @year = @year - @offset / 12, @month = @month - @offset % 12
	if @month <= 0
		select @year = @year - 1, @month = @month + 12
	select @cfirstday = firstday, @clastday = lastday from firstdays where year = @year and month = @month
	select @firstday = isnull(@cfirstday, '2000/1/1'), @lastday = isnull(@clastday, '2000/1/1')
	end
else if @option like 'M%'
	select @option = 'm', @firstday = dateadd(dd, 1 - datepart(dd, dateadd(mm, - @offset, @firstday)), dateadd(mm, - @offset, @firstday)),
		@lastday = dateadd(dd, - datepart(dd, dateadd(mm, 1 - @offset, @lastday)), dateadd(mm, 1 - @offset, @lastday))
else if @option like 'Ay%'
	begin
	select @option = 'T'
	select @year = year - @offset from firstdays where @lastday >= firstday and @lastday <= lastday
	select @firstday = isnull((select firstday from firstdays where year = @year and month = 1), '2000/1/1')
	select @clastday = lastday from firstdays where year = @year and month = 12
	select @lastday = dateadd(yy, - @offset, @lastday)
	if @lastday > @clastday
		select @lastday = @clastday
	end
else if @option like 'y%'
	select @option = 'y', @firstday = dateadd(yy, - @offset, @firstday), @lastday = dateadd(yy, - @offset, @lastday)
else if @option like 'AY%'
	begin
	select @option = 'T'
	select @year = year - @offset from firstdays where @lastday >= firstday and @lastday <= lastday
	select @firstday = isnull((select firstday from firstdays where year = @year and month = 1), '2000/1/1')
	select @lastday = isnull((select lastday from firstdays where year = @year and month = 12), '2000/1/1')
	end
else if @option like 'Y%'
	select @option = 'y', @firstday = convert(datetime, convert(char(4), datepart(yy, @firstday) - 1) + '01/01'),
		@lastday = convert(datetime, convert(char(4), datepart(yy, @lastday) - 1) + '12/31')
else if @option like '[Dd][Yy]%'								-- 上年同日
	select @option = 'd', @firstday = dateadd(yy, - 1, @firstday), @lastday = dateadd(yy, - 1, @lastday)
else if @option like '[Dd][Mm]%'								-- 上月同日
	select @option = 'd', @firstday = dateadd(mm, - 1, @firstday), @lastday = dateadd(mm, - 1, @lastday)
else if @option like '[Dd]F[Yy]%'							-- 本年第一天
	begin
	select @firstday = convert(datetime, convert(char(5), @firstday, 111) + '01/01')
	select @firstday = dateadd(dd, - @offset, @firstday)
	select @option = 'd', @lastday = @firstday
	end
else if @option like '[Dd]F[Mm]%'							-- 本月第一天
	begin
	select @firstday = convert(datetime, convert(char(8), @firstday, 111) + '01'), @lastday = convert(datetime, convert(char(8), @lastday, 111) + '01')
	select @firstday = dateadd(dd, - @offset, @firstday)
	select @option = 'd', @lastday = @firstday
	end
else if @option like 'A[Dd]F[Yy]%'							-- 本会计年第一天
	begin
	select @year = year from firstdays where @firstday >= firstday and @firstday <= lastday
	select @firstday = isnull((select firstday from firstdays where year = @year and month = 1), '2000/1/1')
	select @firstday = dateadd(dd, - @offset, @firstday)
	select @option = 'd', @lastday = @firstday
	end
else if @option like 'A[Dd]F[Mm]%'							-- 本会计月第一天
	begin
	select @firstday = isnull((select firstday from firstdays where @firstday >= firstday and @firstday <= lastday), '2000/1/1')
	select @firstday = dateadd(dd, - @offset, @firstday)
	select @option = 'd', @lastday = @firstday
	end
else if @option like '[Dd]%'									-- 本日
	select @option = 'd', @firstday = dateadd(dd, - @offset, @firstday), @lastday = dateadd(dd, - @offset, @lastday)
else
	select @option = 'T', @firstday = dateadd(mm, - @offset, @firstday), @lastday = dateadd(mm, - @offset, @lastday)

if charindex('d', @option) > 0 or charindex('m', @option) > 0 or charindex('y', @option) > 0
	begin
	select @year = datepart(yy, @firstday), @month = datepart(mm, @firstday), @index = '0000000000000000000000000000000'
	if charindex('d', @option) > 0														-- 本日
		select @index = stuff(@index, datepart(dd, @firstday), 1, '1')
	else																							-- 本月
		select @index = stuff(@index, 1, datepart(day, @lastday), replicate('1', datepart(day, @lastday)))
	insert #statistic_t (cat, grp, code, amount)
		select cat, grp, code, 
		day01 * convert(money, substring(@index, 1, 1)) + day02 * convert(money, substring(@index, 2, 1)) + day03 * convert(money, substring(@index, 3, 1)) +
		day04 * convert(money, substring(@index, 4, 1)) + day05 * convert(money, substring(@index, 5, 1)) + day06 * convert(money, substring(@index, 6, 1)) +
		day07 * convert(money, substring(@index, 7, 1)) + day08 * convert(money, substring(@index, 8, 1)) + day09 * convert(money, substring(@index, 9, 1)) +
		day10 * convert(money, substring(@index, 10, 1)) + day11 * convert(money, substring(@index, 11, 1)) + day12 * convert(money, substring(@index, 12, 1)) +
		day13 * convert(money, substring(@index, 13, 1)) + day14 * convert(money, substring(@index, 14, 1)) + day15 * convert(money, substring(@index, 15, 1)) +
		day16 * convert(money, substring(@index, 16, 1)) + day17 * convert(money, substring(@index, 17, 1)) + day18 * convert(money, substring(@index, 18, 1)) +
		day19 * convert(money, substring(@index, 19, 1)) + day20 * convert(money, substring(@index, 20, 1)) + day21 * convert(money, substring(@index, 21, 1)) +
		day22 * convert(money, substring(@index, 22, 1)) + day23 * convert(money, substring(@index, 23, 1)) + day24 * convert(money, substring(@index, 24, 1)) +
		day25 * convert(money, substring(@index, 25, 1)) + day26 * convert(money, substring(@index, 26, 1)) + day27 * convert(money, substring(@index, 27, 1)) +
		day28 * convert(money, substring(@index, 28, 1)) + day29 * convert(money, substring(@index, 29, 1)) + day30 * convert(money, substring(@index, 30, 1)) +
		day31 * convert(money, substring(@index, 31, 1))
		from statistic_m where year = @year and month = @month and cat like @cat and grp like @grp and code like @code
	end
-- 本年
if charindex('y', @option) > 0
	begin
	select @year = datepart(yy, @lastday), @month = datepart(mm, @lastday), @index = '000000000000'
	select @index = stuff(@index, 1, @month - 1, replicate('1', @month - 1))
	insert #statistic_t (cat, grp, code, amount)
		select cat, grp, code, 
		month01 * convert(money, substring(@index, 1, 1)) + month02 * convert(money, substring(@index, 2, 1)) + month03 * convert(money, substring(@index, 3, 1)) +
		month04 * convert(money, substring(@index, 4, 1)) + month05 * convert(money, substring(@index, 5, 1)) + month06 * convert(money, substring(@index, 6, 1)) +
		month07 * convert(money, substring(@index, 7, 1)) + month08 * convert(money, substring(@index, 8, 1)) + month09 * convert(money, substring(@index, 9, 1)) +
		month10 * convert(money, substring(@index, 10, 1)) + month11 * convert(money, substring(@index, 11, 1)) + month12 * convert(money, substring(@index, 12, 1))
		from statistic_y a where a.year = @year and a.cat like @cat and grp like @grp and code like @code
	end
-- 区间
if charindex('T', @option) > 0
	begin
	while @firstday <= @lastday
		begin
		select @year = datepart(yy, @firstday), @month = datepart(mm, @firstday), @index = '0000000000000000000000000000000'
		-- 同一个月
		if datediff(mm, @firstday, @lastday) = 0
			begin
			select @index = stuff(@index, datepart(day, @firstday), 1 + datepart(day, @lastday) - datepart(day, @firstday), replicate('1', 1 + datepart(day, @lastday) - datepart(day, @firstday)))
			select @firstday = dateadd(dd, 1, @lastday)
			end
		else
			begin
			select @index = stuff(@index, datepart(day, @firstday), 31, replicate('1', 31))
			select @firstday = dateadd(dd, 1 - datepart(dd, dateadd(mm, 1, @firstday)), dateadd(mm, 1, @firstday))
			end
		insert #statistic_t (cat, grp, code, amount)
			select cat, grp, code, 
			day01 * convert(money, substring(@index, 1, 1)) + day02 * convert(money, substring(@index, 2, 1)) + day03 * convert(money, substring(@index, 3, 1)) +
			day04 * convert(money, substring(@index, 4, 1)) + day05 * convert(money, substring(@index, 5, 1)) + day06 * convert(money, substring(@index, 6, 1)) +
			day07 * convert(money, substring(@index, 7, 1)) + day08 * convert(money, substring(@index, 8, 1)) + day09 * convert(money, substring(@index, 9, 1)) +
			day10 * convert(money, substring(@index, 10, 1)) + day11 * convert(money, substring(@index, 11, 1)) + day12 * convert(money, substring(@index, 12, 1)) +
			day13 * convert(money, substring(@index, 13, 1)) + day14 * convert(money, substring(@index, 14, 1)) + day15 * convert(money, substring(@index, 15, 1)) +
			day16 * convert(money, substring(@index, 16, 1)) + day17 * convert(money, substring(@index, 17, 1)) + day18 * convert(money, substring(@index, 18, 1)) +
			day19 * convert(money, substring(@index, 19, 1)) + day20 * convert(money, substring(@index, 20, 1)) + day21 * convert(money, substring(@index, 21, 1)) +
			day22 * convert(money, substring(@index, 22, 1)) + day23 * convert(money, substring(@index, 23, 1)) + day24 * convert(money, substring(@index, 24, 1)) +
			day25 * convert(money, substring(@index, 25, 1)) + day26 * convert(money, substring(@index, 26, 1)) + day27 * convert(money, substring(@index, 27, 1)) +
			day28 * convert(money, substring(@index, 28, 1)) + day29 * convert(money, substring(@index, 29, 1)) + day30 * convert(money, substring(@index, 30, 1)) +
			day31 * convert(money, substring(@index, 31, 1))
			from statistic_m where year = @year and month = @month and cat like @cat and grp like @grp and code like @code
		end
	end
-- 生成statistic_t
if @group  = 'grp'
	insert statistic_t (pc_id, cat, grp, code, amount) select @pc_id, cat, grp, '%', sum(amount) from #statistic_t group by cat, grp having sum(amount)<>0
else if @group  = 'code' or @group='saleid'
	insert statistic_t (pc_id, cat, grp, code, amount) select @pc_id, cat, '%', code, sum(amount) from #statistic_t group by cat, code having sum(amount)<>0
else -- 'grp,code'
	insert statistic_t (pc_id, cat, grp, code, amount) select @pc_id, cat, grp, code, sum(amount) from #statistic_t group by cat, grp, code having sum(amount)<>0
--select * from statistic_t where pc_id = @pc_id
--if charindex('C', @option) > 0
--	update statistic_t set grp_descript = a.grp_descript, grp_descript1 = a.grp_descript1, code_descript = a.code_descript, code_descript1 = a.code_descript1
--		from statistic_c a where statistic_t.pc_id = @pc_id and statistic_t.cat = a.cat and statistic_t.grp = a.grp and statistic_t.code = a.code
--		and a.bdate = (select max(b.bdate) from statistic_c b where b.cat = a.cat and b.grp = a.grp and b.code = a.code)
return 0
;