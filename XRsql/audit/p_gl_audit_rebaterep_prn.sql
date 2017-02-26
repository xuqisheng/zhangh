if exists (select * from sysobjects where name ='p_gl_audit_rebaterep_prn' and type ='P')
	drop proc p_gl_audit_rebaterep_prn;
create proc p_gl_audit_rebaterep_prn
	@pdate			datetime, 
	@paycodes		char(20),
   @langid        integer 

as
declare
	@day01			money, 
	@day02			money, 
	@day03			money, 
	@day04			money, 
	@day05			money, 
	@day06			money, 
	@day07			money, 
	@day08			money, 
	@day09			money, 
	@day99			money, 
	@month01			money, 
	@month02			money, 
	@month03			money, 
	@month04			money, 
	@month05			money, 
	@month06			money, 
	@month07			money, 
	@month08			money, 
	@month09			money, 
	@month99			money, 
	@toop				char(1), 
	@toclass			char(8)
	
select * into #rebate1 from yrebaterep where date = @pdate
delete #rebate1 where charindex(paycode, @paycodes) = 0
select class, day01 = sum(day01), day02 = sum(day02), day03 = sum(day03), day04 = sum(day04), day05 = sum(day05),
	day06 = sum(day06), day07 = sum(day07), day08 = sum(day08), day09 = sum(day09), day99 = sum(day99),
	month01 = sum(month01), month02 = sum(month02), month03 = sum(month03), month04 = sum(month04), month05 = sum(month05),
	month06 = sum(month06), month07 = sum(month07), month08 = sum(month08), month09 = sum(month09), month99 = sum(month99)
	into #rebate2 from #rebate1 group by class
//
select * into #jierep from yjierep where date = @pdate
update #jierep set
	month01 = 0, day01 = 0, month02 = 0, day02 = 0, month03 = 0, day03 = 0, month04 = 0, day04 = 0, 
	month05 = 0, day05 = 0, month06 = 0, day06 = 0, month07 = 0, day07 = 0, month08 = 0, day08 = 0, 
	month09 = 0, day09 = 0, month99 = 0, day99 = 0
update #jierep set
	day01 = a.day01, day02 = a.day02, day03 = a.day03, day04 = a.day04, day05 = a.day05,
	day06 = a.day06, day07 = a.day07, day08 = a.day08, day09 = a.day09, day99 = a.day99,
	month01 = a.month01, month02 = a.month02, month03 = a.month03, month04 = a.month04, month05 = a.month05,
	month06 = a.month06, month07 = a.month07, month08 = a.month08, month09 = a.month09, month99 = a.month99
	from #rebate2 a where #jierep.class = a.class
//
declare c_jierep cursor for select toop, toclass, day01, day02, day03, day04, day05, day06, day07, day08, day09, 
	month01, month02, month03, month04, month05, month06, month07, month08, month09 from #jierep where rectype = 'B'
open c_jierep
fetch c_jierep into @toop, @toclass, @day01, @day02, @day03, @day04, @day05, @day06, @day07, @day08, @day09, 
	@month01, @month02, @month03, @month04, @month05, @month06, @month07, @month08, @month09
while @@sqlstatus = 0
	begin 
	while @toclass <> space(8)
		begin
		if @toop = '+' 
			update #jierep set 
				day01 = day01 + @day01, day02 = day02 + @day02, day03 = day03 + @day03, 
				day04 = day04 + @day04, day05 = day05 + @day05, day06 = day06 + @day06, 
				day07 = day07 + @day07, day08 = day08 + @day08, day09 = day09 + @day09, 
				month01 = month01 + @month01, month02 = month02 + @month02, month03 = month03 + @month03, 
				month04 = month04 + @month04, month05 = month05 + @month05, month06 = month06 + @month06, 
				month07 = month07 + @month07, month08 = month08 + @month08, month09 = month09 + @month09
				where class = @toclass
		else
			update #jierep set 
				day01 = day01 - @day01, day02 = day02 - @day02, day03 = day03 - @day03, 
				day04 = day04 - @day04, day05 = day05 - @day05, day06 = day06 - @day06, 
				day07 = day07 - @day07, day08 = day08 - @day08, day09 = day09 - @day09, 
				month01 = month01 - @month01, month02 = month02 - @month02, month03 = month03 - @month03, 
				month04 = month04 - @month04, month05 = month05 - @month05, month06 = month06 - @month06, 
				month07 = month07 - @month07, month08 = month08 - @month08, month09 = month09 - @month09
				where class = @toclass
		select @toclass = toclass, @toop = toop from #jierep where class = @toclass
		if @@rowcount = 0
			select @toclass = space(8)
		end
	fetch c_jierep into @toop, @toclass, @day01, @day02, @day03, @day04, @day05, @day06, @day07, @day08, @day09, 
		@month01, @month02, @month03, @month04, @month05, @month06, @month07, @month08, @month09
	end
close c_jierep
deallocate cursor c_jierep
update #jierep set mode = '1'

insert #jierep (mode, class, descript, descript1, day01, day02, day03, day04, day05, day06, day07, day08, day09, day99, 
		month01, month02, month03, month04, month05, month06, month07, month08, month09, month99,
		sequence)
	select '0', b.pccode, b.descript, b.descript1, sum(a.day01), sum(a.day02), sum(a.day03), sum(a.day04), sum(a.day05),
		sum(a.day06), sum(a.day07), sum(a.day08), sum(a.day09), sum(a.day99),
		sum(a.month01), sum(a.month02), sum(a.month03), sum(a.month04), sum(a.month05),
		sum(a.month06), sum(a.month07), sum(a.month08), sum(a.month09), sum(a.month99),
		0  
	from #rebate1 a, pccode b where a.paycode = b.pccode group by b.pccode, b.descript


update #jierep set day99 = day01 + day02 + day03 + day04 + day05 + day06 + day07,
	month99 = month01 + month02 + month03 + month04 + month05 + month06 + month07
if @langid = 0
	select mode, order_, descript, day01, day02, day03, day04, day05, day06, day07, day08, day09, day99, 
		month01, month02, month03, month04, month05, month06, month07, month08, month09, month99
		from #jierep order by mode, class
else
	select mode, order_, descript1, day01, day02, day03, day04, day05, day06, day07, day08, day09, day99, 
		month01, month02, month03, month04, month05, month06, month07, month08, month09, month99
		from #jierep order by mode, class
 
;
