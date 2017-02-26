drop  proc p_cq_newpos_jierep_pview2;
create proc p_cq_newpos_jierep_pview2
	@pdate			datetime,
	@pmode			char(1),
	@langid			int = 0
as
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

create table #dairep
(
	type				char(1)		default '' not null,
	class				char(8)		not null,
	order1			char(2)		default '' not null,
	descript			varchar(16)		default '' not null,
	descript1		varchar(16)		default '' not null,
	day1_01			money			default 0 not null,
	day1_02			money			default 0 not null,
	day1_03			money			default 0 not null,
	day1_04			money			default 0 not null,
	day1_05			money			default 0 not null,
	day1_06			money			default 0 not null,
	day1_07			money			default 0 not null,
	day1_99			money			default 0	not null,
)

if charindex(@pmode, 'mM') = 0
	begin
	insert #dairep select '1', class, order_, descript,descript1, credit01, credit02, credit03, credit04, credit05, credit06, credit07, sumcre
		from ydairep where date = @pdate and class like '01%' order by class
	insert #dairep select '2', class, order_, descript,descript1, last_bl, debit, credit, till_bl, 0, 0, 0, sumcre
		from ydairep where date = @pdate and class > '02' and substring(class, 3, 3) in ('000', '999') order by class
	end
else
	begin
	insert #dairep select '1', class, order_, descript,descript1, credit01m, credit02m, credit03m, credit04m, credit05m, credit06m, credit07m, sumcrem
		from ydairep where date = @pdate and class like '01%' order by class
	insert #dairep select '2', class, order_, descript,descript1, last_bl, debit, credit, till_bl, 0, 0, 0, sumcrem
		from ydairep where date = @pdate and class > '02' and substring(class, 3, 3) in ('000', '999') order by class
	end

if @langid=0
	select type, ltrim(rtrim(order1)), descript, day1_01, day1_02, day1_03, day1_04, day1_05, day1_06, day1_07, day1_99
		from #dairep order by class
else
	select type, ltrim(rtrim(order1)), descript1, day1_01, day1_02, day1_03, day1_04, day1_05, day1_06, day1_07, day1_99
		from #dairep order by class

return 0;
