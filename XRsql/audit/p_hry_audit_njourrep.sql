if exists (select * from sysobjects where name  = 'p_hry_audit_njourrep' and type = 'P')
	drop proc p_hry_audit_njourrep;
create proc p_hry_audit_njourrep
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
	@day				float,
	@day1				float,
	@day2				float,
	@month			float,
	@month1			float,
	@month2			float,
	@year				float,
	@year1			float,
	@year2			float,
	@pmonth			float,
	@pmonth1			float,
	@pmonth2			float,
	@pyear			float,
	@pyear1			float,
	@pyear2			float


select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
if exists ( select * from njourrep where date = @bdate )
	update njourrep set month = month - day, year = year - day
update njourrep set day = 0, date = @bfdate

update njourrep set day = 0
update njourrep set day = amount from audit_impdata where njourrep.impindex = audit_impdata.class

declare c_cursor cursor for select class, day01 from jierep_njourrep where rtrim(day01) is not null order by class
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
			update njourrep set day = day + b.day01 from jierep b where njourrep.class = @toclass and b.class = @class
		else
			update njourrep set day = day - b.day01 from jierep b where njourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end
close c_cursor
deallocate cursor c_cursor

declare c_cursor cursor for select class, day02 from jierep_njourrep where rtrim(day02) is not null order by class
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
			update njourrep set day = day + b.day02 from jierep b where njourrep.class = @toclass and b.class = @class
		else
			update njourrep set day = day - b.day02 from jierep b where njourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end
close c_cursor
deallocate cursor c_cursor

declare c_cursor cursor for select class, day03 from jierep_njourrep where rtrim(day03) is not null order by class
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
			update njourrep set day = day + b.day03 from jierep b where njourrep.class = @toclass and b.class = @class
		else
			update njourrep set day = day - b.day03 from jierep b where njourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end
close c_cursor
deallocate cursor c_cursor

declare c_cursor cursor for select class, day04 from jierep_njourrep where rtrim(day04) is not null order by class
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
			update njourrep set day = day + b.day04 from jierep b where njourrep.class = @toclass and b.class = @class
		else
			update njourrep set day = day - b.day04 from jierep b where njourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end
close c_cursor
deallocate cursor c_cursor

declare c_cursor cursor for select class, day05 from jierep_njourrep where rtrim(day05) is not null order by class
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
			update njourrep set day = day + b.day05 from jierep b where njourrep.class = @toclass and b.class = @class
		else
			update njourrep set day = day - b.day05 from jierep b where njourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end
close c_cursor
deallocate cursor c_cursor

declare c_cursor cursor for select class, day06 from jierep_njourrep where rtrim(day06) is not null order by class
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
			update njourrep set day = day + b.day06 from jierep b where njourrep.class = @toclass and b.class = @class
		else
			update njourrep set day = day - b.day06 from jierep b where njourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end
close c_cursor
deallocate cursor c_cursor

declare c_cursor cursor for select class, day07 from jierep_njourrep where rtrim(day07) is not null order by class
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
			update njourrep set day = day + b.day07 from jierep b where njourrep.class = @toclass and b.class = @class
		else
			update njourrep set day = day - b.day07 from jierep b where njourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end
close c_cursor
deallocate cursor c_cursor

declare c_cursor cursor for select class, day08 from jierep_njourrep where rtrim(day08) is not null order by class
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
			update njourrep set day = day + b.day08 from jierep b where njourrep.class = @toclass and b.class = @class
		else
			update njourrep set day = day - b.day08 from jierep b where njourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end
close c_cursor
deallocate cursor c_cursor

declare c_cursor cursor for select class, day09 from jierep_njourrep where rtrim(day09) is not null order by class
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
			update njourrep set day = day + b.day09 from jierep b where njourrep.class = @toclass and b.class = @class
		else
			update njourrep set day = day - b.day09 from jierep b where njourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end
close c_cursor
deallocate cursor c_cursor

declare c_cursor cursor for select class, day99 from jierep_njourrep where rtrim(day99) is not null order by class
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
			update njourrep set day = day + b.day99 from jierep b where njourrep.class = @toclass and b.class = @class
		else
			update njourrep set day = day - b.day99 from jierep b where njourrep.class = @toclass and b.class = @class
		end
	fetch c_cursor into @class, @toset
	end
close c_cursor
deallocate cursor c_cursor

declare j_cursor cursor for select toop, toclass1, day
		  from njourrep where rectype = 'B' order by class
open	 j_cursor
fetch	j_cursor into @toop, @toclass1, @day
while @@sqlstatus = 0
	begin
	while rtrim(@toclass1) is not null
		begin
		if @toop = '-'
			update njourrep set day = day - @day where class = @toclass1
		else
			update njourrep set day = day + @day where class = @toclass1
		select @toclass1 = toclass1, @toop1 = toop from njourrep where class = @toclass1
		if @@rowcount = 0
			select @toclass1 = null
		if @toop <> @toop1
			select @toop = '-'
		else
			select @toop = '+'
		end
	fetch j_cursor into @toop, @toclass1, @day
	end
close j_cursor
deallocate cursor j_cursor

exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday  = 'T'
	update njourrep set month = day, date	 = @bdate
else
	update njourrep  set month = month+day, date = @bdate
if @isyfstday  = 'T'
	update njourrep set year = day, date	 = @bdate
else
	update njourrep  set year = year+day, date = @bdate

declare j_cursor cursor for select toop, class, toclass1, toclass2, day, month, year, pmonth, pyear
	from njourrep where toop = '/' or toop = '%' order by class
open j_cursor
fetch	j_cursor into @toop, @class, @toclass1, @toclass2, @day, @month, @year, @pmonth, @pyear
while @@sqlstatus = 0
	begin
	select @day1 = day, @month1 = month, @pmonth1 = pmonth, @year1 = year, @pyear1 = pyear from njourrep where class = @toclass1
	select @day2 = day, @month2 = month, @pmonth2 = pmonth, @year2 = year, @pyear2 = pyear from njourrep where class = @toclass2
	if @day1 is not null and @day2 is not null and @day2 <> 0
		begin
		if @toop = '/'
			update njourrep set day = round(@day1 / @day2, 2) where class = @class
		else
			update njourrep set day = round(@day1 * 100 / @day2, 2) where class = @class
		end
	if @month1 is not null and @month2 is not null and @month2 <> 0
		begin
		if @toop = '/'
			update njourrep set month = round(@month1 / @month2, 2) where class = @class
		else
			update njourrep set month = round(@month1 * 100 / @month2, 2) where class = @class
		end
	if @pmonth1 is not null and @pmonth2 is not null and @pmonth2 <> 0
		begin
		if @toop = '/'
			update njourrep set pmonth = round(@pmonth1 / @pmonth2, 2) where class = @class
		else
			update njourrep set pmonth = round(@pmonth1 * 100 / @pmonth2, 2) where class = @class
		end
	if @year1 is not null and @year2 is not null and @year2 <> 0
		begin
		if @toop = '/'
			update njourrep set year = round(@year1 / @year2, 2) where class = @class
		else
			update njourrep set year = round(@year1 * 100 / @year2, 2) where class = @class
		end
	if @pyear1 is not null and @pyear2 is not null and @pyear2 <> 0
		begin
		if @toop = '/'
			update njourrep set pyear = @pyear1 / @pyear2 where class = @class
		else
			update njourrep set pyear = @pyear1 * 100 / @pyear2 where class = @class
		end
	fetch	j_cursor into @toop, @class, @toclass1, @toclass2, @day, @month, @year, @pmonth, @pyear
	end
close j_cursor
deallocate cursor j_cursor
update njourrep set day = round(day, 2), month = round(month, 2), year = round(year, 2), pmonth = round(pmonth, 2), pyear = round(pyear, 2)
update njourrep set lmonth = b.month, lyear = b.year from ynjourrep b
	where dateadd(year, -1, @bdate) =  b.date and njourrep.class = b.class
delete ynjourrep where date = @bdate
insert ynjourrep select * from njourrep
return 0
;