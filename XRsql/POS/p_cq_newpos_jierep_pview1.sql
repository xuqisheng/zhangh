drop  proc p_cq_newpos_jierep_pview1;
create proc p_cq_newpos_jierep_pview1
	@pdate		datetime,
	@pmode		char(1),
	@langid		int = 0
as

if charindex(@pmode, 'mM') > 0
	if @langid = 0
		select ltrim(rtrim(a.order_)), a.descript, a.month01, a.month02, a.month03, a.month04, a.month05, a.month06, a.month07, a.month99
			from	jierep a where a.date = @pdate order by a.class
	else
		select ltrim(rtrim(a.order_)), a.descript1, a.month01, a.month02, a.month03, a.month04, a.month05, a.month06, a.month07, a.month99
			from	jierep a where a.date = @pdate order by a.class
else
	if @langid = 0
		select ltrim(rtrim(a.order_)), a.descript, a.day01, a.day02, a.day03, a.day04, a.day05, a.day06, a.day07, a.day99
			from	jierep a where a.date = @pdate order by a.class
	else
		select ltrim(rtrim(a.order_)), a.descript1, a.day01, a.day02, a.day03, a.day04, a.day05, a.day06, a.day07, a.day99
			from	jierep a where a.date = @pdate order by a.class
return 0;
