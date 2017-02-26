------------------------------
-- 稽核底表
------------------------------
if exists(select * from sysobjects where name = 'p_gl_audit_put_jiedai1' and type = 'P')
	drop proc p_gl_audit_put_jiedai1;
create proc p_gl_audit_put_jiedai1
	@pdate		datetime,
	@pmode		char(1),
	@langid		int = 0
as
------------------------------
-- 稽核底表 借方显示
------------------------------
declare		@show		char(1),	-- 稽核底表是否显示款待 ?
				@cnt		int,
				@entcls	char(8)

select @show = isnull((select value from sysoption where catalog='audit' and item='jiedai_show_ent'), 't')
if charindex(@show, 'TtYy') > 0 
	select @show='t', @entcls=''
else
begin
	select @cnt = count(1) from jierep where mode='E'
	if @cnt = 1
		select @show='f', @entcls=class from jierep where mode='E'
	else
		select @show='t', @entcls=''
end

select * into #entrep from	yjierep a where a.date = @pdate and a.class = @entcls and @show='f'
select * into #jierep from	yjierep a where a.date = @pdate
update #jierep set
	day01 = #jierep.day01 - a.day01, day02 = #jierep.day02 - a.day02, day03 = #jierep.day03 - a.day03, day04 = #jierep.day04 - a.day04,
	day05 = #jierep.day05 - a.day05, day06 = #jierep.day06 - a.day06, day07 = #jierep.day07 - a.day07, day99 = #jierep.day99 - a.day99,
	month01 = #jierep.month01 - a.month01, month02 = #jierep.month02 - a.month02, month03 = #jierep.month03 - a.month03, month04 = #jierep.month04 - a.month04,
	month05 = #jierep.month05 - a.month05, month06 = #jierep.month06 - a.month06, month07 = #jierep.month07 - a.month07, month99 = #jierep.month99 - a.month99
	from #entrep a
	where #jierep.class = '999' and a.class = @entcls and @show='f'

update #jierep set class = 'ZZZ' where class = @entcls and @show='f'  -- 显示在后面
-- delete #jierep where class = @entcls and @show='f'  -- 彻底不显示


if charindex(@pmode, 'mM') > 0
	if @langid = 0
		select ltrim(rtrim(order_)), descript, month01, month02, month03, month04, month05, month06, month07, month99
			from	#jierep where date = @pdate order by sequence, class
	else
		select ltrim(rtrim(order_)), descript1, month01, month02, month03, month04, month05, month06, month07, month99
			from	#jierep where date = @pdate order by sequence, class
else
	if @langid = 0
		select ltrim(rtrim(order_)), descript, day01, day02, day03, day04, day05, day06, day07, day99
			from	#jierep where date = @pdate order by sequence, class
	else
		select ltrim(rtrim(order_)), descript1, day01, day02, day03, day04, day05, day06, day07, day99
			from	#jierep where date = @pdate order by sequence, class
return 0;


if exists (select 1 from sysobjects where name = 'p_gl_audit_put_jiedai2' and type = 'P')
	drop proc p_gl_audit_put_jiedai2;
create proc p_gl_audit_put_jiedai2
	@pdate			datetime,
	@pmode			char(1),
	@langid			int = 0
as
------------------------------
-- 稽核底表 贷方显示
------------------------------
declare
	@class			char(8),
	@item_no			integer,
	@insertcnt		integer,
	@order_			char(2),
	@descript		char(16),
	@credit01		money,
	@credit02		money,
	@credit03		money,
	@credit04		money,
	@credit05		money,
	@credit06		money,
	@credit07		money,
	@sumcre			money

declare		@show		char(1),	-- 稽核底表是否显示款待 ?
				@entcls	char(8)

select @entcls = '08000'
select @show = isnull((select value from sysoption where catalog='audit' and item='jiedai_show_ent'), 't')
if charindex(@show, 'TtYy') > 0 
	select @show='t'
else
	select @show='f'

-- 从贷方总计中扣除款待
select * into #entrep from ydairep where date = @pdate and class = @entcls and @show='f'
select * into #dairep from ydairep where date = @pdate
update #dairep set
	credit01 = #dairep.credit01 - a.credit01, credit02 = #dairep.credit02 - a.credit02, credit03 = #dairep.credit03 - a.credit03, credit04 = #dairep.credit04 - a.credit04,
	credit05 = #dairep.credit05 - a.credit05, credit06 = #dairep.credit06 - a.credit06, credit07 = #dairep.credit07 - a.credit07, sumcre = #dairep.sumcre - a.sumcre,
	credit01m = #dairep.credit01m - a.credit01m, credit02m = #dairep.credit02m - a.credit02m, credit03m = #dairep.credit03m - a.credit03m, credit04m = #dairep.credit04m - a.credit04m,
	credit05m = #dairep.credit05m - a.credit05m, credit06m = #dairep.credit06m - a.credit06m, credit07m = #dairep.credit07m - a.credit07m, sumcrem = #dairep.sumcrem - a.sumcrem
	from #entrep a
	where #dairep.class = '09000' and a.class = @entcls and @show='f'

-- update #dairep set class = 'ZZ' + substring(class, 3, 3) where class like '08%' and @show='f'  -- 显示在后面
delete #dairep where class like substring(@entcls,1,2)+'%' and @show='f'  -- -- 彻底不显示

--
delete #dairep where substring(class, 1, 2) in ('03')
delete #dairep where class like '08%' and substring(class, 3, 3) <> '000'
insert #dairep select date, order_, itemno, mode, class, descript, descript1, sequence, 0, 0, 0, 0, 0, 0, 0, charge - credit,
	last_charge - last_credit, charge, credit, till_charge - till_credit, 0, 0, 0, 0, 0, 0, 0, chargem - creditm,
	last_chargem - last_creditm, chargem, creditm, till_chargem - till_creditm
	from yjiedai where date = @pdate and class like '03%'

--
create table #putrep
(
	type				char(1)		null,
	class				char(8)		null,
	order1			char(2)		null,
	descript			varchar(50)	null,
	descript1		varchar(50)	null,
	sequence			integer		null,
	day1_01			money			null,
	day1_02			money			null,
	day1_03			money			null,
	day1_04			money			null,
	day1_05			money			null,
	day1_06			money			null,
	day1_07			money			null,
	day1_99			money			null
)

if charindex(@pmode, 'mM') = 0
	begin
	insert #putrep select '1', class, order_, descript, descript1, sequence, credit01, credit02, credit03, credit04, credit05, credit06, credit07, sumcre
		from #dairep where class like '01%' order by sequence, class
	insert #putrep select '2', class, order_, descript, descript1, sequence, last_bl, debit, credit, till_bl, 0, 0, 0, sumcre
		from #dairep 
		where class > '02' order by sequence, class
--		where class > '02' and substring(class, 3, 3) in ('000', '999') order by sequence, class
	end
else
	begin
	insert #putrep select '1', class, order_, descript, descript1, sequence, credit01m, credit02m, credit03m, credit04m, credit05m, credit06m, credit07m, sumcrem
		from #dairep where class like '01%' order by sequence, class
	insert #putrep select '2', class, order_, descript, descript1, sequence, last_blm, debitm, creditm, till_bl, 0, 0, 0, sumcrem
		from #dairep 
		where class > '02' order by sequence, class
--		where class > '02' and substring(class, 3, 3) in ('000', '999') order by sequence, class
	end

if @langid=0
	select type, ltrim(rtrim(order1)), descript, day1_01, day1_02, day1_03, day1_04, day1_05, day1_06, day1_07, day1_99
		from #putrep order by sequence, class
else
	select type, ltrim(rtrim(order1)), descript1, day1_01, day1_02, day1_03, day1_04, day1_05, day1_06, day1_07, day1_99
		from #putrep order by sequence, class

return 0;
