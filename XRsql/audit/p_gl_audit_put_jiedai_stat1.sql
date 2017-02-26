------------------------------
-- 稽核底表
------------------------------
if exists(select * from sysobjects where name = 'p_gl_audit_put_jiedai_stat1' and type = 'P')
	drop proc p_gl_audit_put_jiedai_stat1;
create proc p_gl_audit_put_jiedai_stat1
	@pdate			datetime,
	@pmode			char(1),
	@langid			integer = 0
as
------------------------------
-- 稽核底表 借方显示
------------------------------
declare
	@show				char(1),	-- 稽核底表是否显示款待 ?
	@cnt				integer,
	@entcls			char(8),
	@pc_id			char(4),
	@para1			varchar(255),
	@option			varchar(10)

select @show = isnull((select value from sysoption where catalog = 'audit' and item = 'jiedai_show_ent'), 't')
if charindex(@show, 'TtYy') > 0 
	select @show = 't', @entcls = ''
else
	begin
	select @cnt = count(1) from jierep where mode = 'E'
	if @cnt = 1
		select @show = 'f', @entcls = class from jierep where mode = 'E'
	else
		select @show = 't', @entcls = ''
	end
--
if @pmode like '[Mm]'
	select @option = 'Am'
else
	select @option = 'D'
select @pc_id = '9999', @para1 = 'jierep_day01-' + @option + ',' + 'jierep_day02-' + @option + ',' + 'jierep_day03-' + @option + ',' + 
	'jierep_day04-' + @option + ',' + 'jierep_day05-' + @option + ',' + 'jierep_day06-' + @option + ',' + 'jierep_day07-' + @option + ',' + 
	'jierep_day99-' + @option
exec p_gl_statistic_report @pc_id, @pdate, @pdate, 'code', @para1, '', @langid, 'withzero,withreturn'
if @show='f'
	begin
	select * into #statistic_p from statistic_p where pc_id = @pc_id and code = @entcls
	update statistic_p set
		amount01 = statistic_p.amount01 - a.amount01, amount02 = statistic_p.amount02 - a.amount02, amount03 = statistic_p.amount03 - a.amount03,
		amount04 = statistic_p.amount04 - a.amount04, amount05 = statistic_p.amount05 - a.amount05, amount06 = statistic_p.amount06 - a.amount06,
		amount07 = statistic_p.amount07 - a.amount07, amount08 = statistic_p.amount08 - a.amount08
		from #statistic_p a
		where statistic_p.pc_id = @pc_id and statistic_p.code = '999' and a.pc_id = @pc_id and a.code = @entcls
	-- 显示在后面
	update statistic_p set code = 'ZZZ' where pc_id = @pc_id and code = @entcls
	-- 彻底不显示
	-- delete statistic_p where pc_id = @pc_id and code = @entcls
	end
--
if @langid = 0
	select ltrim(rtrim(b.order_)), a.code_descript, a.amount01, a.amount02, a.amount03, a.amount04, a.amount05, a.amount06, a.amount07, a.amount08
		from statistic_p a, jierep b where a.pc_id = @pc_id and a.code *= b.class order by a.code
else
	select ltrim(rtrim(b.order_)), a.code_descript1, a.amount01, a.amount02, a.amount03, a.amount04, a.amount05, a.amount06, a.amount07, a.amount08
		from statistic_p a, jierep b where a.pc_id = @pc_id and a.code *= b.class order by a.code
return 0;
