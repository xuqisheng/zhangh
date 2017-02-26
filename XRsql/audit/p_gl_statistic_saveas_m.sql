if exists (select * from sysobjects where name ='p_gl_statistic_saveas_m' and type ='P')
	drop proc p_gl_statistic_saveas_m;
create proc p_gl_statistic_saveas_m
	@bdate					datetime, 
	@cat						char(30),
	@grp						char(10),
	@grp_descript			varchar(50),
	@grp_descript1			varchar(50),
	@grp_sequence			integer,
	@code						char(10),
	@code_descript			varchar(50),
	@code_descript1		varchar(50),
	@code_sequence			integer,
	@value					money,
	@option					money = 0.0,
	@zero						char(1) = 'F'					-- 金额为零的是否保存
as
declare
	@old_bdate				datetime, 
	@old_grp_descript		varchar(50),
	@old_grp_descript1	varchar(50),
	@old_grp_sequence		integer,
	@old_code_descript	varchar(50),
	@old_code_descript1	varchar(50),
	@old_code_sequence	integer,
	@year						integer,
	@month					integer,
	@day						integer

-- 将历史数据存入statistic_m
select @year = datepart(yy, @bdate), @month = datepart(mm, @bdate), @day = datepart(dd, @bdate)
if not exists(select 1 from statistic_m where year = @year and month = @month and cat = @cat and grp = @grp and code = @code)
	begin
	if @zero = 'F' and @value = 0
		return 0
	else
		begin
		insert statistic_m (year, month, cat, grp, code)
			select @year, @month, @cat, @grp, @code
		if not @cat like 'yield%'
			insert statistic_c (cat, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence, bdate)
				select @cat, @grp, isnull(@grp_descript, ''), isnull(@grp_descript1, ''), isnull(@grp_sequence, 0),
				@code, isnull(@code_descript, ''), isnull(@code_descript1, ''), isnull(@code_sequence, 0), @bdate
		end
	end
else if not @cat like 'yield%'
	begin
	select @old_bdate = bdate, @old_grp_descript = a.grp_descript, @old_grp_descript1 = a.grp_descript1, @old_grp_sequence = a.grp_sequence,
		@old_code_descript = a.code_descript, @old_code_descript1 = a.code_descript1, @old_code_sequence = a.code_sequence
		from statistic_c a where a.cat = @cat and a.grp = @grp and a.code = @code
		and a.bdate = (select max(b.bdate) from statistic_c b where b.cat = a.cat and b.grp = a.grp and b.code = a.code)
	if isnull(@grp_descript, '') != isnull(@old_grp_descript, '') or isnull(@grp_descript1, '') != isnull(@old_grp_descript1, '') or
		isnull(@code_descript, '') != isnull(@old_code_descript, '') or isnull(@code_descript1, '') != isnull(@old_code_descript1, '') or
		isnull(@grp_sequence, 0) != isnull(@old_grp_sequence, 0) or isnull(@code_sequence, 0) != isnull(@old_code_sequence, 0)
		begin
		if @bdate = @old_bdate
			update statistic_c set grp_descript = isnull(@grp_descript, ''), grp_descript1 = isnull(@grp_descript1, ''),grp_sequence = isnull(@grp_sequence, 0),
				code_descript = isnull(@code_descript, ''), code_descript1 = isnull(@code_descript1, ''), code_sequence = isnull(@code_sequence, 0)
				where bdate = @bdate and cat = @cat and grp = @grp and code = @code
		else
			insert statistic_c (cat, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence, bdate)
				select @cat, @grp, isnull(@grp_descript, ''), isnull(@grp_descript1, ''), isnull(@grp_sequence, 0),
				@code, isnull(@code_descript, ''), isnull(@code_descript1, ''), isnull(@code_sequence, 0), @bdate
		end
	end
if @day = 1
	update statistic_m set day01 = day01 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 2
	update statistic_m set day02 = day02 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 3
	update statistic_m set day03 = day03 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 4
	update statistic_m set day04 = day04 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 5
	update statistic_m set day05 = day05 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 6
	update statistic_m set day06 = day06 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 7
	update statistic_m set day07 = day07 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 8
	update statistic_m set day08 = day08 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 9
	update statistic_m set day09 = day09 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 10
	update statistic_m set day10 = day10 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 11
	update statistic_m set day11 = day11 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 12
	update statistic_m set day12 = day12 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 13
	update statistic_m set day13 = day13 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 14
	update statistic_m set day14 = day14 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 15
	update statistic_m set day15 = day15 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 16
	update statistic_m set day16 = day16 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 17
	update statistic_m set day17 = day17 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 18
	update statistic_m set day18 = day18 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 19
	update statistic_m set day19 = day19 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 20
	update statistic_m set day20 = day20 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 21
	update statistic_m set day21 = day21 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 22
	update statistic_m set day22 = day22 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 23
	update statistic_m set day23 = day23 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 24
	update statistic_m set day24 = day24 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 25
	update statistic_m set day25 = day25 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 26
	update statistic_m set day26 = day26 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 27
	update statistic_m set day27 = day27 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 28
	update statistic_m set day28 = day28 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 29
	update statistic_m set day29 = day29 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 30
	update statistic_m set day30 = day30 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
else if @day = 31
	update statistic_m set day31 = day31 * @option + @value
		where year = @year and month = @month and cat = @cat and grp = @grp and code = @code
return 0
;