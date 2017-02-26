if exists (select * from sysobjects where name  = 'p_gl_audit_jourrep' and type = 'P')
	drop proc p_gl_audit_jourrep;
create proc p_gl_audit_jourrep
as
declare 
	@duringaudit	char(1), 
	@isfstday		char(1), 
	@isyfstday		char(1), 
	@bdate			datetime, 
	@bfdate			datetime, 
	@class			char(8), 
	@toop				char(2), 
	@toop1			char(2), 
	@toset			varchar(255), 
	@toclass			char(8), 
	@toclass1		char(8), 
	@toclass2		char(8), 
	@tosetpos		integer, 
	@day				money, 
	@day_rebate		money, 
	@day1				money, 
	@day2				money, 
	@month			money, 
	@month1			money, 
	@month2			money, 
	@year				money, 
	@year1			money, 
	@year2			money, 
	@pmonth			money, 
	@pmonth1			money, 
	@pmonth2			money, 
	@pyear			money, 
	@pyear1			money, 
	@pyear2			money

-- 与以前的jourrep相比增加了Rebate栏 

-- ---------Initialization--------------- 
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
if exists ( select * from jourrep where date = @bdate )
	update jourrep set month = month - day, month_rebate = month_rebate - day_rebate,
		year = year - day, year_rebate = year_rebate - day_rebate
update jourrep set day = 0, day_rebate = 0, date = @bfdate
-- first part:use impdata 
update jourrep set day = 0
update jourrep set day = amount from audit_impdata where jourrep.impindex = audit_impdata.class
-- second :use jierep data through jierep_jourrep 
declare c_cursor cursor for select class, day01 from jierep_jourrep where rtrim(day01) is not null order by class
open c_cursor 
fetch c_cursor into @class, @toset
while @@sqlstatus = 0
	begin
	while rtrim(@toset) is not null
		begin
		select @toop = substring(@toset, 1, 1)
		select @toset = substring(@toset, 2, 255)
		select @tosetpos = charindex('+', @toset)
		if @tosetpos = 0 
			select @tosetpos = charindex('-', @toset)
		if @tosetpos = 0 
			begin 
			select @toclass = @toset
			select @toset = null
			end 
		else
			begin
			select @toclass = substring(@toset, 1, @tosetpos - 1)
			select @toset = substring(@toset, @tosetpos, 255)
			end 
		if @toop = '+' 
			update jourrep set day = day + b.day01 from jierep b where jourrep.class = @toclass and b.class = @class
		else
			update jourrep set day = day - b.day01 from jierep b where jourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end 
close c_cursor
deallocate cursor c_cursor
-- day02 
declare c_cursor cursor for select class, day02 from jierep_jourrep where rtrim(day02) is not null order by class
open c_cursor 
fetch c_cursor into @class, @toset
while @@sqlstatus = 0
	begin
	while rtrim(@toset) is not null
		begin
		select @toop = substring(@toset, 1, 1)
		select @toset = substring(@toset, 2, 255)
		select @tosetpos = charindex('+', @toset)
		if @tosetpos = 0 
			select @tosetpos = charindex('-', @toset)
		if @tosetpos = 0 
			begin 
			select @toclass = @toset
			select @toset = null
			end 
		else
			begin
			select @toclass = substring(@toset, 1, @tosetpos - 1)
			select @toset = substring(@toset, @tosetpos, 255)
			end 
		if @toop = '+' 
			update jourrep set day = day + b.day02 from jierep b where jourrep.class = @toclass and b.class = @class
		else
			update jourrep set day = day - b.day02 from jierep b where jourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end 
close c_cursor
deallocate cursor c_cursor
-- day03 
declare c_cursor cursor for select class, day03 from jierep_jourrep where rtrim(day03) is not null order by class
open c_cursor 
fetch c_cursor into @class, @toset
while @@sqlstatus = 0
	begin
	while rtrim(@toset) is not null
		begin
		select @toop = substring(@toset, 1, 1)
		select @toset = substring(@toset, 2, 255)
		select @tosetpos = charindex('+', @toset)
		if @tosetpos = 0 
			select @tosetpos = charindex('-', @toset)
		if @tosetpos = 0 
			begin 
			select @toclass = @toset
			select @toset = null
			end 
		else
			begin
			select @toclass = substring(@toset, 1, @tosetpos - 1)
			select @toset = substring(@toset, @tosetpos, 255)
			end 
		if @toop = '+' 
			update jourrep set day = day + b.day03 from jierep b where jourrep.class = @toclass and b.class = @class
		else
			update jourrep set day = day - b.day03 from jierep b where jourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end 
close c_cursor
deallocate cursor c_cursor
-- day04 
declare c_cursor cursor for select class, day04 from jierep_jourrep where rtrim(day04) is not null order by class
open c_cursor 
fetch c_cursor into @class, @toset
while @@sqlstatus = 0
	begin
	while rtrim(@toset) is not null
		begin
		select @toop = substring(@toset, 1, 1)
		select @toset = substring(@toset, 2, 255)
		select @tosetpos = charindex('+', @toset)
		if @tosetpos = 0 
			select @tosetpos = charindex('-', @toset)
		if @tosetpos = 0 
			begin 
			select @toclass = @toset
			select @toset = null
			end 
		else
			begin
			select @toclass = substring(@toset, 1, @tosetpos - 1)
			select @toset = substring(@toset, @tosetpos, 255)
			end 
		if @toop = '+' 
			update jourrep set day = day + b.day04 from jierep b where jourrep.class = @toclass and b.class = @class
		else
			update jourrep set day = day - b.day04 from jierep b where jourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end 
close c_cursor
deallocate cursor c_cursor
-- day05 
declare c_cursor cursor for select class, day05 from jierep_jourrep where rtrim(day05) is not null order by class
open c_cursor 
fetch c_cursor into @class, @toset
while @@sqlstatus = 0
	begin
	while rtrim(@toset) is not null
		begin
		select @toop = substring(@toset, 1, 1)
		select @toset = substring(@toset, 2, 255)
		select @tosetpos = charindex('+', @toset)
		if @tosetpos = 0 
			select @tosetpos = charindex('-', @toset)
		if @tosetpos = 0 
			begin 
			select @toclass = @toset
			select @toset = null
			end 
		else
			begin
			select @toclass = substring(@toset, 1, @tosetpos - 1)
			select @toset = substring(@toset, @tosetpos, 255)
			end 
		if @toop = '+' 
			update jourrep set day = day + b.day05 from jierep b where jourrep.class = @toclass and b.class = @class
		else
			update jourrep set day = day - b.day05 from jierep b where jourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end 
close c_cursor
deallocate cursor c_cursor
-- day06 
declare c_cursor cursor for select class, day06 from jierep_jourrep where rtrim(day06) is not null order by class
open c_cursor 
fetch c_cursor into @class, @toset
while @@sqlstatus = 0
	begin
	while rtrim(@toset) is not null
		begin
		select @toop = substring(@toset, 1, 1)
		select @toset = substring(@toset, 2, 255)
		select @tosetpos = charindex('+', @toset)
		if @tosetpos = 0 
			select @tosetpos = charindex('-', @toset)
		if @tosetpos = 0 
			begin 
			select @toclass = @toset
			select @toset = null
			end 
		else
			begin
			select @toclass = substring(@toset, 1, @tosetpos - 1)
			select @toset = substring(@toset, @tosetpos, 255)
			end 
		if @toop = '+' 
			update jourrep set day = day + b.day06 from jierep b where jourrep.class = @toclass and b.class = @class
		else
			update jourrep set day = day - b.day06 from jierep b where jourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end 
close c_cursor
deallocate cursor c_cursor
-- day07 Rebate 特殊处理
--declare c_cursor cursor for select class, day07 from jierep_jourrep where rtrim(day07) is not null order by class
--open c_cursor 
--fetch c_cursor into @class, @toset
--while @@sqlstatus = 0
--	begin
--	while rtrim(@toset) is not null
--		begin
--		select @toop = substring(@toset, 1, 1)
--		select @toset = substring(@toset, 2, 255)
--		select @tosetpos = charindex('+', @toset)
--		if @tosetpos = 0 
--			select @tosetpos = charindex('-', @toset)
--		if @tosetpos = 0 
--			begin 
--			select @toclass = @toset
--			select @toset = null
--			end 
--		else
--			begin
--			select @toclass = substring(@toset, 1, @tosetpos - 1)
--			select @toset = substring(@toset, @tosetpos, 255)
--			end 
--		if @toop = '+' 
--			update jourrep set day = day + b.day07 from jierep b where jourrep.class = @toclass and b.class = @class
--		else
--			update jourrep set day = day - b.day07 from jierep b where jourrep.class = @toclass and b.class = @class
--		end
--	fetch c_cursor into @class, @toset
--	end 
--close c_cursor
--deallocate cursor c_cursor
declare c_cursor cursor for select class, day99 from jierep_jourrep where rtrim(day99) is not null order by class
open c_cursor 
fetch c_cursor into @class, @toset
while @@sqlstatus = 0
	begin
	while rtrim(@toset) is not null
		begin
		select @toop = substring(@toset, 1, 1)
		select @toset = substring(@toset, 2, 255)
		select @tosetpos = charindex('+', @toset)
		if @tosetpos = 0 
			select @tosetpos = charindex('-', @toset)
		if @tosetpos = 0 
			begin 
			select @toclass = @toset
			select @toset = null
			end 
		else
			begin
			select @toclass = substring(@toset, 1, @tosetpos - 1)
			select @toset = substring(@toset, @tosetpos, 255)
			end 
		if @toop = '+' 
			update jourrep set day = day - b.day07, day_rebate = day_rebate + b.day07 from jierep b where jourrep.class = @toclass and b.class = @class
		else
			update jourrep set day = day + b.day07, day_rebate = day_rebate - b.day07 from jierep b where jourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end 
close c_cursor
deallocate cursor c_cursor
-- day08 
declare c_cursor cursor for select class, day08 from jierep_jourrep where rtrim(day08) is not null order by class
open c_cursor 
fetch c_cursor into @class, @toset
while @@sqlstatus = 0
	begin
	while rtrim(@toset) is not null
		begin
		select @toop = substring(@toset, 1, 1)
		select @toset = substring(@toset, 2, 255)
		select @tosetpos = charindex('+', @toset)
		if @tosetpos = 0 
			select @tosetpos = charindex('-', @toset)
		if @tosetpos = 0 
			begin 
			select @toclass = @toset
			select @toset = null
			end 
		else
			begin
			select @toclass = substring(@toset, 1, @tosetpos - 1)
			select @toset = substring(@toset, @tosetpos, 255)
			end 
		if @toop = '+' 
			update jourrep set day = day + b.day08 from jierep b where jourrep.class = @toclass and b.class = @class
		else
			update jourrep set day = day - b.day08 from jierep b where jourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end 
close c_cursor
deallocate cursor c_cursor
-- day09 
declare c_cursor cursor for select class, day09 from jierep_jourrep where rtrim(day09) is not null order by class
open c_cursor 
fetch c_cursor into @class, @toset
while @@sqlstatus = 0
	begin
	while rtrim(@toset) is not null
		begin
		select @toop = substring(@toset, 1, 1)
		select @toset = substring(@toset, 2, 255)
		select @tosetpos = charindex('+', @toset)
		if @tosetpos = 0 
			select @tosetpos = charindex('-', @toset)
		if @tosetpos = 0 
			begin 
			select @toclass = @toset
			select @toset = null
			end 
		else
			begin
			select @toclass = substring(@toset, 1, @tosetpos - 1)
			select @toset = substring(@toset, @tosetpos, 255)
			end 
		if @toop = '+' 
			update jourrep set day = day + b.day09 from jierep b where jourrep.class = @toclass and b.class = @class
		else
			update jourrep set day = day - b.day09 from jierep b where jourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end 
close c_cursor
deallocate cursor c_cursor
-- day99
declare c_cursor cursor for select class, day99 from jierep_jourrep where rtrim(day99) is not null order by class
open c_cursor 
fetch c_cursor into @class, @toset
while @@sqlstatus = 0
	begin
	while rtrim(@toset) is not null
		begin
		select @toop = substring(@toset, 1, 1)
		select @toset = substring(@toset, 2, 255)
		select @tosetpos = charindex('+', @toset)
		if @tosetpos = 0 
			select @tosetpos = charindex('-', @toset)
		if @tosetpos = 0 
			begin 
			select @toclass = @toset
			select @toset = null
			end 
		else
			begin
			select @toclass = substring(@toset, 1, @tosetpos - 1)
			select @toset = substring(@toset, @tosetpos, 255)
			end 
		if @toop = '+' 
			update jourrep set day = day + b.day99 from jierep b where jourrep.class = @toclass and b.class = @class
		else
			update jourrep set day = day - b.day99 from jierep b where jourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end 
close c_cursor
deallocate cursor c_cursor
-- third: accumulate basic item 
declare j_cursor cursor for select toop, toclass1, day, day_rebate from jourrep where rectype = 'B' order by class
open j_cursor
fetch	j_cursor into @toop, @toclass1, @day, @day_rebate
while @@sqlstatus = 0
	begin 
	while rtrim(@toclass1) is not null
		begin
		if @toop = '-' 
			update jourrep set day = day - @day, day_rebate = day_rebate - @day_rebate where class = @toclass1
		else
			update jourrep set day = day + @day, day_rebate = day_rebate + @day_rebate where class = @toclass1
		select @toclass1 = toclass1, @toop1 = toop from jourrep where class = @toclass1
		if @@rowcount = 0
			select @toclass1 = null
		if @toop <> @toop1
			select @toop = '-'
		else
			select @toop = '+'
		end
	fetch j_cursor into @toop, @toclass1, @day, @day_rebate
	end
close j_cursor
deallocate cursor j_cursor
-- forth 
exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday  = 'T'
	update jourrep set month = day, month_rebate = day_rebate, date	 = @bdate
else
	update jourrep  set month = month+day, month_rebate = month_rebate+day_rebate, date = @bdate
if @isyfstday  = 'T'
	update jourrep set year = day, year_rebate = day_rebate, date	 = @bdate
else
	update jourrep  set year = year+day, year_rebate = year_rebate+day_rebate, date = @bdate
-- fifth :deal with div and percentage 
declare j_cursor cursor for select toop, class, toclass1, toclass2, day, month, year, pmonth, pyear
		  from jourrep where toop = '/' or toop = '%' order by class
open	 j_cursor
fetch	j_cursor into @toop, @class, @toclass1, @toclass2, @day, @month, @year, @pmonth, @pyear
while @@sqlstatus = 0
	begin 
	select @day1 = day, @month1 = month, @pmonth1 = pmonth, @year1 = year, @pyear1 = pyear from jourrep where class = @toclass1
	select @day2 = day, @month2 = month, @pmonth2 = pmonth, @year2 = year, @pyear2 = pyear from jourrep where class = @toclass2
	if @day1 is not null and @day2 is not null and @day2 <> 0 
		begin
		if @toop = '/' 
			update jourrep set day = round(@day1 / @day2, 2) where class = @class
		else
			update jourrep set day = round(@day1 * 100 / @day2, 2) where class = @class
		end
	if @month1 is not null and @month2 is not null and @month2 <> 0 
		begin
		if @toop = '/' 
			update jourrep set month = round(@month1 / @month2, 2) where class = @class
		else
			update jourrep set month = round(@month1 * 100 / @month2, 2) where class = @class
		end
	if @pmonth1 is not null and @pmonth2 is not null and @pmonth2 <> 0 
		begin
		if @toop = '/' 
			update jourrep set pmonth = round(@pmonth1 / @pmonth2, 2) where class = @class
		else
			update jourrep set pmonth = round(@pmonth1 * 100 / @pmonth2, 2) where class = @class
		end
	if @year1 is not null and @year2 is not null and @year2 <> 0 
		begin
		if @toop = '/' 
			update jourrep set year = round(@year1 / @year2, 2) where class = @class
		else
			update jourrep set year = round(@year1 * 100 / @year2, 2) where class = @class
		end
	if @pyear1 is not null and @pyear2 is not null and @pyear2 <> 0 
		begin
		if @toop = '/' 
			update jourrep set pyear = @pyear1 / @pyear2 where class = @class
		else
			update jourrep set pyear = @pyear1 * 100 / @pyear2 where class = @class
		end
	fetch	j_cursor into @toop, @class, @toclass1, @toclass2, @day, @month, @year, @pmonth, @pyear
	end
close j_cursor
deallocate cursor j_cursor
update jourrep set day = round(day, 2), month = round(month, 2), year = round(year, 2), pmonth = round(pmonth, 2), pyear = round(pyear, 2),
	day_rebate = round(day_rebate, 2), month_rebate = round(month_rebate, 2), year_rebate = round(year_rebate, 2)
update jourrep set lmonth = b.month, lyear = b.year from yjourrep b
	where dateadd(year, -1, @bdate) =  b.date and jourrep.class = b.class
delete yjourrep where date = @bdate
insert yjourrep select * from jourrep

--
exec p_gl_statistic_saveas 'pcid', @bdate, 'jourrep'

return 0
;
