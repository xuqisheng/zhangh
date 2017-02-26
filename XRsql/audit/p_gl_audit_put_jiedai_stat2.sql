if exists (select 1 from sysobjects where name = 'p_gl_audit_put_jiedai_stat2' and type = 'P')
	drop proc p_gl_audit_put_jiedai_stat2;
create proc p_gl_audit_put_jiedai_stat2
	@pdate			datetime,
	@pmode			char(1),
	@langid			integer = 0
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
	@sumcre			money,
	@pc_id			char(4),
	@para1			varchar(255),
	@option			varchar(10),
	@last_balance	varchar(10),
	@show				char(1),												-- 稽核底表是否显示款待 ?
	@entcls			char(8)

create table #putrep
(
	type				char(1)			null,
	class				char(8)			null,
	order1			char(2)			null,
	descript			varchar(16)		null,
	descript1		varchar(16)		null,
	day1_01			money				null,
	day1_02			money				null,
	day1_03			money				null,
	day1_04			money				null,
	day1_05			money				null,
	day1_06			money				null,
	day1_07			money				null,
	day1_99			money				null,
)
--
select @entcls = '08000'
select @show = isnull((select value from sysoption where catalog = 'audit' and item = 'jiedai_show_ent'), 't')
if charindex(@show, 'TtYy') > 0 
	select @show = 't'
else
	select @show = 'f'
--
if @pmode like '[Mm]'
	select @option = 'Am', @last_balance = 'ADFM'
else
	select @option = 'D', @last_balance = 'ADFM'
select @pc_id = '9999', @para1 = 'dairep_credit01-' + @option + ',' + 'dairep_credit02-' + @option + ',' + 'dairep_credit03-' + @option + ',' + 
	'dairep_credit04-' + @option + ',' + 'dairep_credit05-' + @option + ',' + 'dairep_credit06-' + @option + ',' + 'dairep_credit07-' + @option + ',' + 
	'dairep_sumcre-' + @option
exec p_gl_statistic_report @pc_id, @pdate, @pdate, 'code', @para1, '', @langid, 'withzero,withreturn'
-- 从贷方总计中扣除款待
if @show='f'
	begin
	select * into #statistic_p from statistic_p where pc_id = @pc_id and code = @entcls
	update statistic_p set
		amount01 = statistic_p.amount01 - a.amount01, amount02 = statistic_p.amount02 - a.amount02, amount03 = statistic_p.amount03 - a.amount03,
		amount04 = statistic_p.amount04 - a.amount04, amount05 = statistic_p.amount05 - a.amount05, amount06 = statistic_p.amount06 - a.amount06,
		amount07 = statistic_p.amount07 - a.amount07, amount08 = statistic_p.amount08 - a.amount08
		from #statistic_p a
		where statistic_p.pc_id = @pc_id and statistic_p.code = '09000' and a.pc_id = @pc_id and a.code = @entcls
	-- 显示在后面
	-- update statistic_p set code = 'ZZ' + substring(class, 3, 3) where pc_id = @pc_id and code = @entcls
	-- 彻底不显示
	delete statistic_p where pc_id = @pc_id and code like substring(@entcls, 1, 2) + '%'
	end
insert #putrep select '1', a.code, b.order_, a.code_descript, a.code_descript1,
	a.amount01, a.amount02, a.amount03, a.amount04, a.amount05, a.amount06, a.amount07, a.amount08
	from statistic_p a, dairep b where a.pc_id = @pc_id and a.code like '01%' and a.code *= b.class order by a.code
insert #putrep select '2', a.code, b.order_, a.code_descript, a.code_descript1,
	a.amount01, a.amount02, a.amount03, a.amount04, a.amount05, a.amount06, a.amount07, a.amount08
	from statistic_p a, dairep b where a.pc_id = @pc_id and (a.code like '0[45679]%' or a.code = '08000') and a.code *= b.class order by a.code
--
//select @pc_id = '9999', @para1 = 'jiedai_last_charge-' + @option + ',' + 'jiedai_last_credit-' + @option + ',' + 'jiedai_charge-' + @option + ',' + 
//	'jiedai_credit-' + @option + ',' + 'jiedai_apply-' + @option + ',' + 'jiedai_till_charge-' + @option + ',' + 'jiedai_till_credit-' + @option
select @pc_id = '9999', @para1 = 'jiedai_last_charge-' + @last_balance + ',jiedai_last_credit-' + @last_balance + ',jiedai_charge-' + @option + ',' + 
	'jiedai_credit-' + @option + ',' + 'jiedai_apply-' + @option + ',' + 'jiedai_till_charge-D,jiedai_till_credit-D'
exec p_gl_statistic_report @pc_id, @pdate, @pdate, 'code', @para1, '', @langid, 'withzero,withreturn'
insert #putrep select '2', a.code, b.order_, a.code_descript, a.code_descript1,
	a.amount01 - a.amount02, a.amount03, a.amount04, a.amount06 - a.amount07, 0, 0, 0, a.amount03 - a.amount04
	from statistic_p a, dairep b where a.pc_id = @pc_id and (a.code = '02000' or a.code like '03%') and a.code *= b.class order by a.code
--
if @langid = 0
	select type, ltrim(rtrim(order1)), descript, day1_01, day1_02, day1_03, day1_04, day1_05, day1_06, day1_07, day1_99
		from #putrep order by class
else
	select type, ltrim(rtrim(order1)), descript1, day1_01, day1_02, day1_03, day1_04, day1_05, day1_06, day1_07, day1_99
		from #putrep order by class

return 0;
