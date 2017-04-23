if exists(select 1 from sysobjects where name = 'p_hry_update_jourrep_v5' and type = 'P')
	drop proc p_hry_update_jourrep_v5;
create proc p_hry_update_jourrep_v5
	@bdate_b 	datetime,
	@bdate_e		datetime
as 


-- 重算营业日报表
declare
	@bdate			datetime,
	@isfstday		char(1) , 
	@isyfstday		char(1),
	@toop				char(2),
	@toop1			char(2),
	@class			char(8), 
	@toclass			char(8), 
	@toclass1		char(8), 
	@toclass2		char(8),
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
	@pyear2			float,
	@day_rebate		money
	  

select @bdate = @bdate_b
while datediff(day,@bdate,@bdate_e ) >= 0
	begin

//		select @bdate
		update yjourrep set day=0 where rectype <> 'B' and date=@bdate
		declare j_cursor1 cursor for select toop, toclass1, day from yjourrep where date=@bdate and rectype = 'B' order by class
		open j_cursor1
		fetch	j_cursor1 into @toop, @toclass1, @day
		while @@sqlstatus = 0
			begin
			while rtrim(@toclass1) is not null
				begin
				if @toop = '-'
					update yjourrep set day = day - @day where date = @bdate and class = @toclass1
				else
					update yjourrep set day = day + @day where date = @bdate and class = @toclass1
				select @toclass1 = toclass1, @toop1 = toop from jourrep where class = @toclass1
				if @@rowcount = 0
					select @toclass1 = null
				if @toop <> @toop1
					select @toop = '-'
				else
					select @toop = '+'
				end
			fetch j_cursor1 into @toop, @toclass1, @day
			end
		close j_cursor1
		deallocate cursor j_cursor1



		exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
		if @isfstday = 'T'
			update yjourrep set month = day where date = @bdate// and class <> '080000'
		else
			update yjourrep set month = day + (select a.month from yjourrep a 
				where yjourrep.class = a.class and a.date = dateadd(day,-1,@bdate))
					where yjourrep.date = @bdate
		if @isyfstday = 'T'
			update yjourrep set year = day where date = @bdate// and class <> '080000'
		else
			update yjourrep set year = day + (select a.year from yjourrep a 
				where yjourrep.class = a.class and a.date = dateadd(day,-1,@bdate))
					where yjourrep.date = @bdate






		declare j_cursor cursor for select toop, class, toclass1, toclass2, day, month, year, pmonth, pyear
				  from yjourrep where date = @bdate and (toop ='/' or toop = '%') order by class
		open	 j_cursor
		fetch	j_cursor into @toop, @class, @toclass1, @toclass2, @day, @month, @year, @pmonth, @pyear
		while @@sqlstatus = 0
			begin 
			select @day1 = day, @month1 = month, @pmonth1 = pmonth, @year1 = year, @pyear1 = pyear from yjourrep where date = @bdate and class = @toclass1
			select @day2 = day, @month2 = month, @pmonth2 = pmonth, @year2 = year, @pyear2 = pyear from yjourrep where date = @bdate and class = @toclass2
			if @day1 is not null and @day2 is not null and @day2 <> 0 
				begin
				if @toop= '/' 
					update yjourrep set day = round(@day1 / @day2, 2) where date = @bdate and class = @class
				else
					update yjourrep set day = round(@day1 * 100 / @day2, 2) where date = @bdate and class = @class
				end
			if @month1 is not null and @month2 is not null and @month2 <> 0 
				begin
				if @toop = '/' 
					update yjourrep set month = round(@month1 / @month2, 2) where date = @bdate and class = @class
				else
					update yjourrep set month = round(@month1 * 100 / @month2, 2) where date = @bdate and class = @class
				end
			if @pmonth1 is not null and @pmonth2 is not null and @pmonth2 <> 0 
				begin
				if @toop = '/' 
					update yjourrep set pmonth = round(@pmonth1 / @pmonth2, 2) where date = @bdate and class = @class
				else
					update yjourrep set pmonth = round(@pmonth1 * 100 / @pmonth2, 2) where date = @bdate and class = @class
				end
			if @year1 is not null and @year2 is not null and @year2 <> 0 
				begin
				if @toop = '/' 
					update yjourrep set year = round(@year1 / @year2, 2) where date = @bdate and class = @class
				else
					update yjourrep set year = round(@year1 * 100 / @year2, 2) where date = @bdate and class = @class
				end
			if @pyear1 is not null and @pyear2 is not null and @pyear2 <> 0 
				begin
				if @toop = '/' 
					update yjourrep set pyear = round(@pyear1 / @pyear2,2) where date = @bdate and class = @class
				else
					update yjourrep set pyear = round(@pyear1 * 100 / @pyear2,2) where date = @bdate and class = @class
				end
			fetch	j_cursor into @toop, @class, @toclass1, @toclass2, @day, @month, @year, @pmonth, @pyear
			end
		close j_cursor
		deallocate cursor j_cursor
//
		select @bdate = dateadd(day,1,@bdate)
	end

return 0

;


