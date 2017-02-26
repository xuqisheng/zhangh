if exists (select 1 from sysobjects where name = 'p_gl_audit_put_jiedai_nar2' and type = 'P')
	drop proc p_gl_audit_put_jiedai_nar2;
create proc p_gl_audit_put_jiedai_nar2
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
--delete #dairep where substring(class, 1, 2) in ('03')
delete #dairep where class like '08%' and substring(class, 3, 3) <> '000'
insert #dairep select date, order_, itemno, mode, class, descript, descript1, sequence, 0, 0, 0, 0, 0, 0, 0, charge - credit,
	last_charge - last_credit, charge, credit, till_charge - till_credit, 0, 0, 0, 0, 0, 0, 0, chargem - creditm,
	last_chargem - last_creditm, chargem, creditm, till_chargem - till_creditm
	from yjiedai where date = @pdate --and class like '03%'
--
create table #putrep
(
	type				char(1)			null,
	class				char(8)			null,
	order1			char(2)			null,
	descript			varchar(50)		null,
	descript1		varchar(50)		null,
	sequence			integer			null,
	day1_01			money				null,
	day1_02			money				null,
	day1_03			money				null,
	day1_04			money				null,
	day1_05			money				null,
	day1_06			money				null,
	day1_07			money				null,
	day1_99			money				null
)

if charindex(@pmode, 'mM') = 0
	begin
	insert #putrep select '1', class, order_, descript, descript1, sequence, credit01, credit02, credit03, credit04, credit05, credit06, credit07, sumcre
		from #dairep where class like '01%' order by sequence, class
	insert #putrep select '2', class, order_, descript, descript1, sequence, last_bl, debit, credit, till_bl, 0, 0, 0, sumcre
		from #dairep where class > '02' order by sequence, class
	end
else
	begin
	insert #putrep select '1', class, order_, descript, descript1, sequence, credit01m, credit02m, credit03m, credit04m, credit05m, credit06m, credit07m, sumcrem
		from #dairep where class like '01%' order by sequence, class
	insert #putrep select '2', class, order_, descript, descript1, sequence, last_blm, debitm, creditm, till_bl, 0, 0, 0, sumcrem
		from #dairep where class > '02'  order by sequence, class
	end


if @langid=0
	select type, ltrim(rtrim(order1)), descript, day1_01, day1_02, day1_03, day1_04, day1_05, day1_06, day1_07, day1_99
		from #putrep order by sequence, class
else
	select type, ltrim(rtrim(order1)), descript1, day1_01, day1_02, day1_03, day1_04, day1_05, day1_06, day1_07, day1_99
		from #putrep order by sequence, class

return 0
;