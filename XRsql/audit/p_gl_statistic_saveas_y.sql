if exists (select * from sysobjects where name ='p_gl_statistic_saveas_y' and type ='P')
	drop proc p_gl_statistic_saveas_y;
create proc p_gl_statistic_saveas_y
	@pc_id				char(4),
	@bdate				datetime,
	@cat					char(30),
	@grp					char(10),
	@code					char(10)
as
declare
	@firstday			datetime, 
	@lastday				datetime, 
	@operator			char(1),
	@cat1					varchar(255),
	@cat2					varchar(255),
	@year					integer,
	@month				integer,
	@cdate				datetime

-- 将历史数据存入statistic_y
create table #statistic
(
	year				integer		Not Null,
	cat				char(30)		Not Null,
	grp				char(10)		Default '' Not Null,
	code				char(10)		Default '' Not Null,
	day99				money			Default 0 Not Null,
	tag				char(1)		Default 'F' Not Null				-- 代码是否于statistic_y的标志
)
select @year = datepart(yy, @bdate), @month = datepart(mm, @bdate)
update statistic_m set day99 = day01 + day02 + day03 + day04 + day05 + day06 + day07 + day08 + day09 + day10 + 
	day11 + day12 + day13 + day14 + day15 + day16 + day17 + day18 + day19 + day20 + 
	day21 + day22 + day23 + day24 + day25 + day26 + day27 + day28 + day29 + day30 + day31
	where cat like @cat and grp like @grp and code like @code
-- 加代码到statistic_y
insert #statistic (year, cat, grp, code, day99, tag)
	select @year, cat, grp, code, day99, 'F' from statistic_m a
	where a.year = @year and a.month = @month and a.cat like @cat and a.grp like @grp and a.code like @code
update #statistic set tag = 'T' from statistic_y a
	where a.year = @year and a.cat = #statistic.cat and a.grp = #statistic.grp and a.code = #statistic.code
insert statistic_y (year, cat, grp, code)
	select year, cat, grp, code from #statistic where tag = 'F'
-- 需要计算的指标(jourrep中的平均房价、出租率等)
delete statistic_p where pc_id = @pc_id
insert statistic_p (pc_id, year, cat, grp, code, amount01) select @pc_id, year, cat, grp, code, day99 from #statistic
declare c_compute cursor for select a.year, a.cat, a.grp, a.code, b.operator, b.cat1, b.cat2
	from #statistic a, statistic_i b where rtrim(a.cat) + '_' + a.code = b.cat
open c_compute
fetch c_compute into @year, @cat, @grp, @code, @operator, @cat1, @cat2
while @@sqlstatus = 0
	begin
	if not (rtrim(@operator) is null and rtrim(@cat1) is null and rtrim(@cat1) is null)
		exec p_gl_statistic_operator @pc_id, @year, @cat, @grp, @code, @cat1, @cat2, @operator, 'code'
	fetch c_compute into @year, @cat, @grp, @code, @operator, @cat1, @cat2
	end
close c_compute
deallocate cursor c_compute
-- 更新statistic_y中物理月的合计数
if @month = 1
	update statistic_y set month01 = a.amount01 from statistic_p a
		where a.pc_id = @pc_id and statistic_y.year = a.year and statistic_y.cat = a.cat and statistic_y.grp = a.grp and statistic_y.code = a.code
else if @month = 2
	update statistic_y set month02 = a.amount01 from statistic_p a
		where a.pc_id = @pc_id and statistic_y.year = a.year and statistic_y.cat = a.cat and statistic_y.grp = a.grp and statistic_y.code = a.code
else if @month = 3
	update statistic_y set month03 = a.amount01 from statistic_p a
		where a.pc_id = @pc_id and statistic_y.year = a.year and statistic_y.cat = a.cat and statistic_y.grp = a.grp and statistic_y.code = a.code
else if @month = 4
	update statistic_y set month04 = a.amount01 from statistic_p a
		where a.pc_id = @pc_id and statistic_y.year = a.year and statistic_y.cat = a.cat and statistic_y.grp = a.grp and statistic_y.code = a.code
else if @month = 5
	update statistic_y set month05 = a.amount01 from statistic_p a
		where a.pc_id = @pc_id and statistic_y.year = a.year and statistic_y.cat = a.cat and statistic_y.grp = a.grp and statistic_y.code = a.code
else if @month = 6
	update statistic_y set month06 = a.amount01 from statistic_p a
		where a.pc_id = @pc_id and statistic_y.year = a.year and statistic_y.cat = a.cat and statistic_y.grp = a.grp and statistic_y.code = a.code
else if @month = 7
	update statistic_y set month07 = a.amount01 from statistic_p a
		where a.pc_id = @pc_id and statistic_y.year = a.year and statistic_y.cat = a.cat and statistic_y.grp = a.grp and statistic_y.code = a.code
else if @month = 8
	update statistic_y set month08 = a.amount01 from statistic_p a
		where a.pc_id = @pc_id and statistic_y.year = a.year and statistic_y.cat = a.cat and statistic_y.grp = a.grp and statistic_y.code = a.code
else if @month = 9
	update statistic_y set month09 = a.amount01 from statistic_p a
		where a.pc_id = @pc_id and statistic_y.year = a.year and statistic_y.cat = a.cat and statistic_y.grp = a.grp and statistic_y.code = a.code
else if @month = 10
	update statistic_y set month10 = a.amount01 from statistic_p a
		where a.pc_id = @pc_id and statistic_y.year = a.year and statistic_y.cat = a.cat and statistic_y.grp = a.grp and statistic_y.code = a.code
else if @month = 11
	update statistic_y set month11 = a.amount01 from statistic_p a
		where a.pc_id = @pc_id and statistic_y.year = a.year and statistic_y.cat = a.cat and statistic_y.grp = a.grp and statistic_y.code = a.code
else if @month = 12
	update statistic_y set month12 = a.amount01 from statistic_p a
		where a.pc_id = @pc_id and statistic_y.year = a.year and statistic_y.cat = a.cat and statistic_y.grp = a.grp and statistic_y.code = a.code
return 0
;