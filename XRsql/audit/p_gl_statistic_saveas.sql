IF OBJECT_ID('dbo.p_gl_statistic_saveas') IS NOT NULL
    DROP PROCEDURE dbo.p_gl_statistic_saveas
;
create proc p_gl_statistic_saveas
	@pc_id				char(4),
	@bdate				datetime,
	@table				char(30)
as
-- 将历史数据存入statistic_m & statistic_y
declare
	@cat					char(30),
	@class				char(1),
	@grp					char(10),
	@code					char(10),
	@grp_descript		varchar(50),
	@grp_descript1		varchar(50),
	@grp_sequence		integer,
	@code_descript		varchar(50),
	@code_descript1	varchar(50),
	@code_sequence		integer,
	@isfstday			char(1),
	@isyfstday			char(1),
-- mktsummaryrep
	@pquan				money,
	@rquan				money,
	@rincome				money,
	@tincome				money,
	@fincome				money,
	@rsvc					money,
	@rpak					money,
	@rarr					money,
	@rdep					money,
	@parr					money,
	@pdep					money,
	@noshow				money,
	@cxl					money,
-- jierep
	@day01				money,
	@day02				money,
	@day03				money,
	@day04				money,
	@day05				money,
	@day06				money,
	@day07				money,
	@day08				money,
	@day09				money,
	@day99				money,
	@last_bl				money,
	@debit				money,
	@credit				money,
	@till_bl				money,
-- jourrep
	@days					integer,
	@operator			char(1),
	@cat1					varchar(255),
	@cat2					varchar(255),
	@display				char(1),
	@day					money,
	@budget				money,
	@rebate				money,
-- master_income
	@lmaster				char(10),
	@master				char(10),
	@accnt				char(10),
	@item					char(10),
	@pccode				char(5),
	@amount1				money,
	@amount2				money,

	@haccnt				char(7),
	@cusno				char(7),
	@agent				char(7),
	@source				char(7),
	@saleid				char(10),
	@ssaleid				char(10),
	@groupno				char(10),

	@rooms_nights		money,
	@rooms_nights_set	money,
	@rooms_noshow		money,
	@rooms_noshow_set	money,
	@rooms_cancel		money,
	@rooms_cancel_set	money,
	@persons_adult		money,
	@revenus_room		money,
	@revenus_fb			money,
	@revenus_extras	money,

	@count				integer

-- 市场码、来源、渠道、房价码、预定类型
if @table = 'mktsummaryrep'
	begin
	declare c_mktsummaryrep cursor for
		select class, grp, code, pquan, rquan, rincome, tincome, rsvc, rpak, rarr,  rdep,fincome, parr, pdep, noshow, cxl from ymktsummaryrep where date=@bdate
	open  c_mktsummaryrep
	fetch c_mktsummaryrep into @class, @grp, @code, @pquan, @rquan, @rincome, @tincome, @rsvc, @rpak, @rarr, @rdep, @fincome, @parr, @pdep, @noshow, @cxl
	while @@sqlstatus = 0
		begin
		if @class in ('M', 'S', 'C', 'R','L')
			begin
			if @class = 'M'
				begin
				select @cat = 'market_persons_adult'
				select @grp_descript = descript, @grp_descript1 = descript1, @grp_sequence = sequence from basecode where cat = 'market_cat' and code = @grp
				select @code_descript = descript, @code_descript1 = descript1, @code_sequence = sequence from mktcode where code = @code
				end
			else if @class = 'S'
				begin
				select @cat = 'source_persons_adult'
				select @grp_descript = descript, @grp_descript1 = descript1, @grp_sequence = sequence from basecode where cat = 'src_cat' and code = @grp
				select @code_descript = descript, @code_descript1 = descript1, @code_sequence = sequence from srccode where code = @code
				end
			else if @class = 'C'
				begin
				select @cat = 'channel_persons_adult'
				select @grp_descript = '', @grp_descript1 = '', @grp_sequence = 0
				select @code_descript = descript, @code_descript1 = descript1, @code_sequence = sequence from basecode where cat = 'channel' and code = @code
				end
			else if @class = 'R'
				begin
				select @cat = 'ratecode_persons_adult'
				select @grp_descript = descript, @grp_descript1 = descript1, @grp_sequence = sequence from basecode where cat = 'rmratecat' and code = @grp
				select @code_descript = descript, @code_descript1 = descript1, @code_sequence = sequence from rmratecode where code = @code
				end
			else if @class = 'L'
				begin
				select @cat = 'restype_persons_adult'
				select @grp_descript = '', @grp_descript1 = '', @grp_sequence = 0 from restype where code = @grp
				select @code_descript = descript, @code_descript1 = descript1, @code_sequence = sequence from restype where code = @code
				end
			if @pquan<>0 exec p_gl_statistic_saveas_m @bdate, @cat, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @pquan
			--
			select @cat = substring(@cat, 1, charindex('_', @cat)) + 'rooms_nights'
			if @rquan<>0 exec p_gl_statistic_saveas_m @bdate, @cat, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @rquan
			--
			select @cat = substring(@cat, 1, charindex('_', @cat)) + 'revenus_room'
           	if @rincome<>0 exec p_gl_statistic_saveas_m @bdate, @cat, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @rincome
			--
			select @cat = substring(@cat, 1, charindex('_', @cat)) + 'revenus_total'
			if @tincome<>0 exec p_gl_statistic_saveas_m @bdate, @cat, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @tincome
			--
			select @cat = substring(@cat, 1, charindex('_', @cat)) + 'revenus_service'
			if @rsvc<>0 exec p_gl_statistic_saveas_m @bdate, @cat, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @rsvc
			--
			select @cat = substring(@cat, 1, charindex('_', @cat)) + 'revenus_package'
			if @rpak<>0 exec p_gl_statistic_saveas_m @bdate, @cat, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @rpak
			--
			select @cat = substring(@cat, 1, charindex('_', @cat)) + 'rooms_arrival'
			if @rarr<>0 exec p_gl_statistic_saveas_m @bdate, @cat, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @rarr
			--
			select @cat = substring(@cat, 1, charindex('_', @cat)) + 'rooms_departure'
			if @rdep<>0 exec p_gl_statistic_saveas_m @bdate, @cat, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @rdep
			--
			select @cat = substring(@cat, 1, charindex('_', @cat)) + 'revenus_f&b'
			if @fincome<>0 exec p_gl_statistic_saveas_m @bdate, @cat, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @fincome
			--
			select @cat = substring(@cat, 1, charindex('_', @cat)) + 'persons_arrival'
			if @parr<>0 exec p_gl_statistic_saveas_m @bdate, @cat, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @parr
			--
			select @cat = substring(@cat, 1, charindex('_', @cat)) + 'persons_departure'
			if @pdep<>0 exec p_gl_statistic_saveas_m @bdate, @cat, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @pdep
			--
			select @cat = substring(@cat, 1, charindex('_', @cat)) + 'rooms_noshow'
			if @noshow<>0 exec p_gl_statistic_saveas_m @bdate, @cat, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @noshow
			--
			select @cat = substring(@cat, 1, charindex('_', @cat)) + 'rooms_cancel'
			if @cxl<>0 exec p_gl_statistic_saveas_m @bdate, @cat, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @cxl
			end
		fetch c_mktsummaryrep into @class, @grp, @code, @pquan, @rquan, @rincome, @tincome, @rsvc, @rpak, @rarr, @rdep, @fincome, @parr, @pdep, @noshow, @cxl
		end
	close c_mktsummaryrep
	deallocate cursor c_mktsummaryrep
	-- 更新累计数
	exec p_gl_statistic_saveas_y @pc_id, @bdate, 'market_%', '%', '%'
	exec p_gl_statistic_saveas_y @pc_id, @bdate, 'source_%', '%', '%'
	exec p_gl_statistic_saveas_y @pc_id, @bdate, 'channel_%', '%', '%'
	exec p_gl_statistic_saveas_y @pc_id, @bdate, 'ratecode_%', '%', '%'
	exec p_gl_statistic_saveas_y @pc_id, @bdate, 'restype_%', '%', '%'
	end
-- 夜间稽核工作底表
else if @table = 'jiedai'
	begin
	-- jierep
	select @grp = '', @grp_descript = '', @grp_descript1 = '', @grp_sequence = 0
	declare c_jierep cursor for
		select class, descript, descript1, day01, day02, day03, day04, day05, day06, day07, day08, day09, day99 from yjierep where date=@bdate
	open  c_jierep
	fetch c_jierep into @code, @code_descript, @code_descript1, @day01, @day02, @day03, @day04, @day05, @day06, @day07, @day08, @day09, @day99
	while @@sqlstatus = 0
		begin
		exec p_gl_statistic_saveas_m @bdate, 'jierep_day99', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day99, 0.0, 'T'
		exec p_gl_statistic_saveas_m @bdate, 'jierep_day01', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day01
		exec p_gl_statistic_saveas_m @bdate, 'jierep_day02', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day02
		exec p_gl_statistic_saveas_m @bdate, 'jierep_day03', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day03
		exec p_gl_statistic_saveas_m @bdate, 'jierep_day04', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day04
		exec p_gl_statistic_saveas_m @bdate, 'jierep_day05', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day05
		exec p_gl_statistic_saveas_m @bdate, 'jierep_day06', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day06
		exec p_gl_statistic_saveas_m @bdate, 'jierep_day07', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day07
		exec p_gl_statistic_saveas_m @bdate, 'jierep_day08', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day08
		exec p_gl_statistic_saveas_m @bdate, 'jierep_day09', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day09
		--
		fetch c_jierep into @code, @code_descript, @code_descript1, @day01, @day02, @day03, @day04, @day05, @day06, @day07, @day08, @day09, @day99
		end
	close c_jierep
	deallocate cursor c_jierep
	-- 更新累计数
	exec p_gl_statistic_saveas_y @pc_id, @bdate, 'jierep_%', '%', '%'
	-- dairep
	declare c_dairep cursor for
		select class, descript, descript1, credit01, credit02, credit03, credit04, credit05, credit06, credit07, sumcre, last_bl, debit, credit, till_bl from ydairep where date=@bdate
	open  c_dairep
	fetch c_dairep into @code, @code_descript, @code_descript1, @day01, @day02, @day03, @day04, @day05, @day06, @day07, @day99, @last_bl, @debit, @credit, @till_bl
	while @@sqlstatus = 0
		begin
		exec p_gl_statistic_saveas_m @bdate, 'dairep_sumcre', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day99, 0.0, 'T'
		exec p_gl_statistic_saveas_m @bdate, 'dairep_credit01', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day01
		exec p_gl_statistic_saveas_m @bdate, 'dairep_credit02', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day02
		exec p_gl_statistic_saveas_m @bdate, 'dairep_credit03', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day03
		exec p_gl_statistic_saveas_m @bdate, 'dairep_credit04', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day04
		exec p_gl_statistic_saveas_m @bdate, 'dairep_credit05', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day05
		exec p_gl_statistic_saveas_m @bdate, 'dairep_credit06', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day06
		exec p_gl_statistic_saveas_m @bdate, 'dairep_credit07', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day07
		--
		exec p_gl_statistic_saveas_m @bdate, 'dairep_last_bl', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @last_bl, 0.0, 'T'
		exec p_gl_statistic_saveas_m @bdate, 'dairep_debit', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @debit
		exec p_gl_statistic_saveas_m @bdate, 'dairep_credit', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @credit
		exec p_gl_statistic_saveas_m @bdate, 'dairep_till_bl', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @till_bl
		--
		fetch c_dairep into @code, @code_descript, @code_descript1, @day01, @day02, @day03, @day04, @day05, @day06, @day07, @day99, @last_bl, @debit, @credit, @till_bl
		end
	close c_dairep
	deallocate cursor c_dairep
	-- 更新累计数
	exec p_gl_statistic_saveas_y @pc_id, @bdate, 'dairep_%', '%', '%'
	-- jiedai
	declare c_jiedai cursor for
		select class, descript, descript1, last_charge, last_credit, charge, credit, apply, till_charge, till_credit from yjiedai where date=@bdate
	open  c_jiedai
	fetch c_jiedai into @code, @code_descript, @code_descript1, @day01, @day02, @day03, @day04, @day05, @day06, @day07
	while @@sqlstatus = 0
		begin
		exec p_gl_statistic_saveas_m @bdate, 'jiedai_last_charge', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day01, 0.0, 'T'
		exec p_gl_statistic_saveas_m @bdate, 'jiedai_last_credit', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day02
		exec p_gl_statistic_saveas_m @bdate, 'jiedai_charge', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day03
		exec p_gl_statistic_saveas_m @bdate, 'jiedai_credit', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day04
		exec p_gl_statistic_saveas_m @bdate, 'jiedai_apply', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day05
		exec p_gl_statistic_saveas_m @bdate, 'jiedai_till_charge', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day06
		exec p_gl_statistic_saveas_m @bdate, 'jiedai_till_credit', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day07
		--
		fetch c_jiedai into @code, @code_descript, @code_descript1, @day01, @day02, @day03, @day04, @day05, @day06, @day07
		end
	close c_jiedai
	deallocate cursor c_jiedai
	-- 更新累计数
	exec p_gl_statistic_saveas_y @pc_id, @bdate, 'jiedai_%', '%', '%'
	end
-- 营业日报
else if @table = 'jourrep'
	begin
	select @grp = '', @grp_descript = '', @grp_descript1 = '', @grp_sequence = 0, @days = datepart(dd, dateadd(dd, - datepart(dd, dateadd(mm, 1, @bdate)), dateadd(mm, 1, @bdate)))
	declare c_jourrep cursor for
		select class, descript, descript1, toop, toclass1, toclass2, show, day, pmonth / datepart(dd, dateadd(dd, - datepart(dd, dateadd(mm, 1, date)), dateadd(mm, 1, date))), day_rebate from yjourrep where date=@bdate
	open  c_jourrep
	fetch c_jourrep into @code, @code_descript, @code_descript1, @operator, @cat1, @cat2, @display, @day, @budget, @rebate
	while @@sqlstatus = 0
		begin
		if @operator in ('/', '%', '*') or @display != 'T'
			begin
			if not exists (select 1 from statistic_i where cat = 'jourrep_day_' + @code)
				insert statistic_i (cat, descript, descript1, operator, cat1, cat2, display) select 'jourrep_day_' + @code, @code_descript, @code_descript1, @operator, @cat1, @cat2, @display
			if not exists (select 1 from statistic_i where cat = 'jourrep_budget_' + @code)
				insert statistic_i (cat, descript, descript1, operator, cat1, cat2, display) select 'jourrep_budget_' + @code, @code_descript, @code_descript1, @operator, @cat1, @cat2, @display
			if not exists (select 1 from statistic_i where cat = 'jourrep_rebate_' + @code)
				insert statistic_i (cat, descript, descript1, operator, cat1, cat2, display) select 'jourrep_rebate_' + @code, @code_descript, @code_descript1, @operator, @cat1, @cat2, @display
			end
		exec p_gl_statistic_saveas_m @bdate, 'jourrep_day', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @day, 0.0, 'T'
		exec p_gl_statistic_saveas_m @bdate, 'jourrep_budget', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @budget
		exec p_gl_statistic_saveas_m @bdate, 'jourrep_rebate', @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence, @rebate
		--
		fetch c_jourrep into @code, @code_descript, @code_descript1, @operator, @cat1, @cat2, @display, @day, @budget, @rebate
		end
	close c_jourrep
	deallocate cursor c_jourrep
	-- 更新累计数
	exec p_gl_statistic_saveas_y @pc_id, @bdate, 'jourrep_%', '%', '%'
	end
else if @table = 'master_income'
	begin
	select @count = 0
	select @rooms_nights = 0, @rooms_noshow = 0, @rooms_cancel = 0, @persons_adult = 0, @revenus_room = 0, @revenus_fb = 0, @revenus_extras = 0
    --master_income没有日期，重算历史的时候有错，暂不处理
    --exec p_clg_statistic_retotal @table
	declare c_master_income cursor for
		select master, accnt, item, pccode, amount1, amount2 from master_income order by master
	open  c_master_income
	fetch c_master_income into @master, @accnt, @item, @pccode, @amount1, @amount2
	select @lmaster = @master
	while @@sqlstatus = 0
		begin
		select @count = @count + 1
		if @master <> @lmaster
			begin
			select @cusno = cusno, @agent = agent, @source = source, @saleid = saleid, @bdate = isnull(deptime, dep) from hmaster where accnt = @lmaster
			if @cusno <> ''
				begin
				if @rooms_nights<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_nights', @saleid, '', '', 0, @cusno, '', '', 0, @rooms_nights, 1.0
				if @rooms_noshow<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_noshow', @saleid, '', '', 0, @cusno, '', '', 0, @rooms_noshow, 1.0
				if @rooms_cancel<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_cancel', @saleid, '', '', 0, @cusno, '', '', 0, @rooms_cancel, 1.0
				if @persons_adult<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_persons_adult', @saleid, '', '', 0, @cusno, '', '', 0, @persons_adult, 1.0
				if @revenus_room<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_room', @saleid, '', '', 0, @cusno, '', '', 0, @revenus_room, 1.0
				if @revenus_fb<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_f&b', @saleid, '', '', 0, @cusno, '', '', 0, @revenus_fb, 1.0
				if @revenus_extras<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_extras', @saleid, '', '', 0, @cusno, '', '', 0, @revenus_extras, 1.0
				end
			else if @agent <> ''
				begin
				if @rooms_nights<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_nights', @saleid, '', '', 0, @agent, '', '', 0, @rooms_nights, 1.0
				if @rooms_noshow<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_noshow', @saleid, '', '', 0, @agent, '', '', 0, @rooms_noshow, 1.0
				if @rooms_cancel<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_cancel', @saleid, '', '', 0, @agent, '', '', 0, @rooms_cancel, 1.0
				if @persons_adult<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_persons_adult', @saleid, '', '', 0, @agent, '', '', 0, @persons_adult, 1.0
				if @revenus_room<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_room', @saleid, '', '', 0, @agent, '', '', 0, @revenus_room, 1.0
				if @revenus_fb<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_f&b', @saleid, '', '', 0, @agent, '', '', 0, @revenus_fb, 1.0
				if @revenus_extras<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_extras', @saleid, '', '', 0, @agent, '', '', 0, @revenus_extras, 1.0
				end
			else if @source <> ''
				begin
				if @rooms_nights<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_nights', @saleid, '', '', 0, @source, '', '', 0, @rooms_nights, 1.0
				if @rooms_noshow<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_noshow', @saleid, '', '', 0, @source, '', '', 0, @rooms_noshow, 1.0
				if @rooms_cancel<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_cancel', @saleid, '', '', 0, @source, '', '', 0, @rooms_cancel, 1.0
				if @persons_adult<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_persons_adult', @saleid, '', '', 0, @source, '', '', 0, @persons_adult, 1.0
				if @revenus_room<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_room', @saleid, '', '', 0, @source, '', '', 0, @revenus_room, 1.0
				if @revenus_fb<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_f&b', @saleid, '', '', 0, @source, '', '', 0, @revenus_fb, 1.0
				if @revenus_extras<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_extras', @saleid, '', '', 0, @source, '', '', 0, @revenus_extras, 1.0
				end
			else if @saleid <> ''
				begin
				if @rooms_nights<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_nights', @saleid, '', '', 0, '', '', '', 0, @rooms_nights, 1.0
				if @rooms_noshow<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_noshow', @saleid, '', '', 0, '', '', '', 0, @rooms_noshow, 1.0
				if @rooms_cancel<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_cancel', @saleid, '', '', 0, '', '', '', 0, @rooms_cancel, 1.0
				if @persons_adult<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_persons_adult', @saleid, '', '', 0, '', '', '', 0, @persons_adult, 1.0
				if @revenus_room<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_room', @saleid, '', '', 0, '', '', '', 0, @revenus_room, 1.0
				if @revenus_fb<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_f&b', @saleid, '', '', 0, '', '', '', 0, @revenus_fb, 1.0
				if @revenus_extras<>0 exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_extras', @saleid, '', '', 0, '', '', '', 0, @revenus_extras, 1.0
				end
			select @lmaster = @master, @rooms_nights = 0, @rooms_noshow = 0, @rooms_cancel = 0, @persons_adult = 0, @revenus_room = 0, @revenus_fb = 0, @revenus_extras = 0
		end
		if @item = 'I_TIMES' and @master = @accnt
			select @rooms_nights = @rooms_nights + @amount2
		else if @item = 'N_TIMES' and @master = @accnt
			select @rooms_noshow = @rooms_noshow + @amount2
		else if @item = 'X_TIMES' and @master = @accnt
			select @rooms_cancel = @rooms_cancel + @amount2
		else if @item = 'I_GUESTS'
			select @persons_adult = @persons_adult + @amount2
		else if @item = '' and @pccode like '1%'
			select @revenus_room = @revenus_room + @amount1
		else if @item = '' and @pccode like '2%'
			select @revenus_fb = @revenus_fb + @amount1
		else
			select @revenus_extras = @revenus_extras + @amount1
		if @count / 1000 * 1000 = @count
			select @count
		fetch c_master_income into @master, @accnt, @item, @pccode, @amount1, @amount2
		end
	close c_master_income
	deallocate cursor c_master_income
	-- 最后一个
	select @cusno = cusno, @agent = agent, @source = source, @saleid = saleid, @bdate = isnull(deptime, dep) from hmaster where accnt = @lmaster
	if @cusno <> ''
		begin
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_nights', @saleid, '', '', 0, @cusno, '', '', 0, @rooms_nights, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_noshow', @saleid, '', '', 0, @cusno, '', '', 0, @rooms_noshow, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_cancel', @saleid, '', '', 0, @cusno, '', '', 0, @rooms_cancel, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_persons_adult', @saleid, '', '', 0, @cusno, '', '', 0, @persons_adult, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_room', @saleid, '', '', 0, @cusno, '', '', 0, @revenus_room, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_f&b', @saleid, '', '', 0, @cusno, '', '', 0, @revenus_fb, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_extras', @saleid, '', '', 0, @cusno, '', '', 0, @revenus_extras, 1.0
		end
	else if @agent <> ''
		begin
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_nights', @saleid, '', '', 0, @agent, '', '', 0, @rooms_nights, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_noshow', @saleid, '', '', 0, @agent, '', '', 0, @rooms_noshow, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_cancel', @saleid, '', '', 0, @agent, '', '', 0, @rooms_cancel, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_persons_adult', @saleid, '', '', 0, @agent, '', '', 0, @persons_adult, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_room', @saleid, '', '', 0, @agent, '', '', 0, @revenus_room, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_f&b', @saleid, '', '', 0, @agent, '', '', 0, @revenus_fb, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_extras', @saleid, '', '', 0, @agent, '', '', 0, @revenus_extras, 1.0
		end
	else if @source <> ''
		begin
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_nights', @saleid, '', '', 0, @source, '', '', 0, @rooms_nights, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_noshow', @saleid, '', '', 0, @source, '', '', 0, @rooms_noshow, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_cancel', @saleid, '', '', 0, @source, '', '', 0, @rooms_cancel, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_persons_adult', @saleid, '', '', 0, @source, '', '', 0, @persons_adult, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_room', @saleid, '', '', 0, @source, '', '', 0, @revenus_room, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_f&b', @saleid, '', '', 0, @source, '', '', 0, @revenus_fb, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_extras', @saleid, '', '', 0, @source, '', '', 0, @revenus_extras, 1.0
		end
	else if @saleid <> ''
		begin
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_nights', @saleid, '', '', 0, '', '', '', 0, @rooms_nights, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_noshow', @saleid, '', '', 0, '', '', '', 0, @rooms_noshow, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_rooms_cancel', @saleid, '', '', 0, '', '', '', 0, @rooms_cancel, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_persons_adult', @saleid, '', '', 0, '', '', '', 0, @persons_adult, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_room', @saleid, '', '', 0, '', '', '', 0, @revenus_room, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_f&b', @saleid, '', '', 0, '', '', '', 0, @revenus_fb, 1.0
		exec p_gl_statistic_saveas_m @bdate, 'yieldar_revenus_extras', @saleid, '', '', 0, '', '', '', 0, @revenus_extras, 1.0
		end
	-- 更新累计数
	exec p_gl_statistic_saveas_y @pc_id, @bdate, 'yieldar_%', '%', '%'
	end
else if @table = 'cus_xf'
	begin
	select @count = 0
	select @rooms_nights = 0, @rooms_noshow = 0, @rooms_cancel = 0, @persons_adult = 0, @revenus_room = 0, @revenus_fb = 0, @revenus_extras = 0
    exec p_clg_statistic_retotal @bdate,@table
	-- xia add 20080611
	-- 餐饮 - 现付的,转AR的应算上,转房间的剔除掉
   create table #tmp (menu	char(10))  -- 存放转房间 menu
	insert #tmp select distinct a.menu  from pos_hmenu a, pos_hpay b, pccode c
		where a.bdate = @bdate and a.menu=b.menu and a.sta='3' and b.sta='3'
			and b.crradjt='NR' and b.paycode=c.pccode
and c.deptno='I'
	declare c_cus_xf cursor for
		select master, accnt, gstno, haccnt, groupno, cusno, agent, source, saleid, date, i_days, x_times, n_times, xf_rm, xf_fb, xf_mt + xf_en + xf_sp + xf_dot
		from ycus_xf
			where  date=@bdate and master <> '' and (haccnt<>'' or cusno<>'' or agent<>'' or source<>'' or saleid<>'')
					and not (actcls='F' and accnt like '[AC]%')
						order by master
---
	--declare c_cus_xf cursor for
		--select master, accnt, gstno, haccnt, groupno, cusno, agent, source, saleid, date, i_days, x_times, n_times, xf_rm, xf_fb, xf_mt + xf_en + xf_sp + xf_dot
		--from ycus_xf
		--	where  date=@bdate and master <> '' and (haccnt<>'' or cusno<>'' or agent<>'' or source<>'' or saleid<>'')
			--		and not (actcls='F' and accnt like '[AC]%')
			--	and not (actcls='P' and master in (select menu from #tmp) )

		--	order by master


	open  c_cus_xf
	select @lmaster='', @haccnt='', @cusno='', @agent='', @source='', @saleid=''
	fetch c_cus_xf into @master, @accnt, @persons_adult, @haccnt, @groupno, @cusno, @agent, @source, @saleid, @bdate, @rooms_nights, @rooms_cancel, @rooms_noshow, @revenus_room, @revenus_fb, @revenus_extras
	while @@sqlstatus = 0
		begin
		if @master<>@lmaster
			begin
			delete accnt_set where pc_id=@pc_id and mdi_id=666
			select @lmaster=@master
			end
		select @count = @count + 1
		if @saleid<>''
			select @ssaleid='S'+@saleid
		else
			select @ssaleid=''
		if @haccnt <> ''
			begin
            if substring(@accnt,1,1) not in ('G','M')
                begin
						if @rooms_nights > 0
							begin
							exec p_gds_guest_nts_check @pc_id, @master, @haccnt, 'I', @rooms_nights, @rooms_nights_set output
							if @rooms_nights_set>0
								exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_nights', '', '', '', 0, @haccnt, '', '', 0, @rooms_nights_set, 1.0
							end
						if @rooms_noshow > 0
							begin
							exec p_gds_guest_nts_check @pc_id, @master, @haccnt, 'N', @rooms_noshow, @rooms_noshow_set output
							if @rooms_noshow_set>0
								exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_noshow', '', '', '', 0, @haccnt, '', '', 0, @rooms_noshow_set, 1.0
							end
						if @rooms_cancel > 0
							begin
							exec p_gds_guest_nts_check @pc_id, @master, @haccnt, 'N', @rooms_cancel, @rooms_cancel_set output
							if @rooms_cancel_set>0
								exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_cancel', '', '', '', 0, @haccnt, '', '', 0, @rooms_cancel_set, 1.0
							end
							if @persons_adult<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_persons_adult', '', '', '', 0, @haccnt, '', '', 0, @persons_adult, 1.0
                end
			if @revenus_room<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_room', '', '', '', 0, @haccnt, '', '', 0, @revenus_room, 1.0
			if @revenus_fb<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_f&b', '', '', '', 0, @haccnt, '', '', 0, @revenus_fb, 1.0
			if @revenus_extras<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_extras', '', '', '', 0, @haccnt, '', '', 0, @revenus_extras, 1.0
			end
		if @groupno <> ''
            begin
			select @haccnt = haccnt from cus_xf where accnt=@groupno
    		if @haccnt <> ''
    			begin
    			if @rooms_nights > 0
    				begin
    				exec p_gds_guest_nts_check @pc_id, @groupno, @haccnt, 'I', @rooms_nights, @rooms_nights_set output
    				if @rooms_nights_set>0
    					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_nights', '', '', '', 0, @haccnt, '', '', 0, @rooms_nights_set, 1.0
    				end
    			if @rooms_noshow > 0
    				begin
    				exec p_gds_guest_nts_check @pc_id, @groupno, @haccnt, 'N', @rooms_noshow, @rooms_noshow_set output
    				if @rooms_noshow_set>0
    					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_noshow', '', '', '', 0, @haccnt, '', '', 0, @rooms_noshow_set, 1.0
    				end
    			if @rooms_cancel > 0
    				begin
    				exec p_gds_guest_nts_check @pc_id, @groupno, @haccnt, 'N', @rooms_cancel, @rooms_cancel_set output
    				if @rooms_cancel_set>0
    					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_cancel', '', '', '', 0, @haccnt, '', '', 0, @rooms_cancel_set, 1.0
    				end
    			if @persons_adult<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_persons_adult', '', '', '', 0, @haccnt, '', '', 0, @persons_adult, 1.0
    			if @revenus_room<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_room', '', '', '', 0, @haccnt, '', '', 0, @revenus_room, 1.0
    			if @revenus_fb<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_f&b', '', '', '', 0, @haccnt, '', '', 0, @revenus_fb, 1.0
    			if @revenus_extras<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_extras', '', '', '', 0, @haccnt, '', '', 0, @revenus_extras, 1.0
    		end
      end
		if @cusno <> ''
			begin
			if @rooms_nights > 0
				begin
				exec p_gds_guest_nts_check @pc_id, @master, @cusno, 'I', @rooms_nights, @rooms_nights_set output
				if @rooms_nights_set>0
					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_nights', '', '', '', 0, @cusno, '', '', 0, @rooms_nights_set, 1.0
				end
			if @rooms_noshow > 0
				begin
				exec p_gds_guest_nts_check @pc_id, @master, @cusno, 'N', @rooms_noshow, @rooms_noshow_set output
				if @rooms_noshow_set>0
					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_noshow', '', '', '', 0, @cusno, '', '', 0, @rooms_noshow_set, 1.0
				end
			if @rooms_cancel > 0
				begin
				exec p_gds_guest_nts_check @pc_id, @master, @cusno, 'N', @rooms_cancel, @rooms_cancel_set output
				if @rooms_cancel_set>0
					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_cancel', '', '', '', 0, @cusno, '', '', 0, @rooms_cancel_set, 1.0
				end
			if @persons_adult<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_persons_adult', '', '', '', 0, @cusno, '', '', 0, @persons_adult, 1.0
			if @revenus_room<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_room', '', '', '', 0, @cusno, '', '', 0, @revenus_room, 1.0
			if @revenus_fb<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_f&b', '', '', '', 0, @cusno, '', '', 0, @revenus_fb, 1.0
			if @revenus_extras<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_extras', '', '', '', 0, @cusno, '', '', 0, @revenus_extras, 1.0
			end
		if @agent <> ''
			begin
			if @rooms_nights > 0
				begin
				exec p_gds_guest_nts_check @pc_id, @master, @agent, 'I', @rooms_nights, @rooms_nights_set output
				if @rooms_nights_set>0
					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_nights', '', '', '', 0, @agent, '', '', 0, @rooms_nights_set, 1.0
				end
			if @rooms_noshow > 0
				begin
				exec p_gds_guest_nts_check @pc_id, @master, @agent, 'N', @rooms_noshow, @rooms_noshow_set output
				if @rooms_noshow_set>0
					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_noshow', '', '', '', 0, @agent, '', '', 0, @rooms_noshow_set, 1.0
				end
			if @rooms_cancel > 0
				begin
				exec p_gds_guest_nts_check @pc_id, @master, @agent, 'N', @rooms_cancel, @rooms_cancel_set output
				if @rooms_cancel_set>0
					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_cancel', '', '', '', 0, @agent, '', '', 0, @rooms_cancel_set, 1.0
				end
			if @persons_adult<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_persons_adult', '', '', '', 0, @agent, '', '', 0, @persons_adult, 1.0
			if @revenus_room<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_room', '', '', '', 0, @agent, '', '', 0, @revenus_room, 1.0
			if @revenus_fb<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_f&b', '', '', '', 0, @agent, '', '', 0, @revenus_fb, 1.0
			if @revenus_extras<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_extras', '', '', '', 0, @agent, '', '', 0, @revenus_extras, 1.0
			end
		if @source <> ''
			begin
			if @rooms_nights > 0
				begin
				exec p_gds_guest_nts_check @pc_id, @master, @source, 'I', @rooms_nights, @rooms_nights_set output
				if @rooms_nights_set>0
					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_nights', '', '', '', 0, @source, '', '', 0, @rooms_nights_set, 1.0
				end
			if @rooms_noshow > 0
				begin
				exec p_gds_guest_nts_check @pc_id, @master, @source, 'N', @rooms_noshow, @rooms_noshow_set output
				if @rooms_noshow_set>0
					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_noshow', '', '', '', 0, @source, '', '', 0, @rooms_noshow_set, 1.0
				end
			if @rooms_cancel > 0
				begin
				exec p_gds_guest_nts_check @pc_id, @master, @source, 'N', @rooms_cancel, @rooms_cancel_set output
				if @rooms_cancel_set>0
					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_cancel', '', '', '', 0, @source, '', '', 0, @rooms_cancel_set, 1.0
				end
			if @persons_adult<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_persons_adult', '', '', '', 0, @source, '', '', 0, @persons_adult, 1.0
			if @revenus_room<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_room', '', '', '', 0, @source, '', '', 0, @revenus_room, 1.0
			if @revenus_fb<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_f&b', '', '', '', 0, @source, '', '', 0, @revenus_fb, 1.0
			if @revenus_extras<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_extras', '', '', '', 0, @source, '', '', 0, @revenus_extras, 1.0
			end
		if @saleid <> ''
			begin
			if @rooms_nights > 0
				begin
				exec p_gds_guest_nts_check @pc_id, @master, @saleid, 'I', @rooms_nights, @rooms_nights_set output
				if @rooms_nights_set>0
					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_nights', '', '', '', 0, @ssaleid, '', '', 0, @rooms_nights_set, 1.0
				end
			if @rooms_noshow > 0
				begin
				exec p_gds_guest_nts_check @pc_id, @master, @saleid, 'N', @rooms_noshow, @rooms_noshow_set output
				if @rooms_noshow_set>0
					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_noshow', '', '', '', 0, @ssaleid, '', '', 0, @rooms_noshow_set, 1.0
				end
			if @rooms_cancel > 0
				begin
				exec p_gds_guest_nts_check @pc_id, @master, @saleid, 'N', @rooms_cancel, @rooms_cancel_set output
				if @rooms_cancel_set>0
					exec p_gl_statistic_saveas_m @bdate, 'yielddb_rooms_cancel', '', '', '', 0, @ssaleid, '', '', 0, @rooms_cancel_set, 1.0
				end
			if @persons_adult<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_persons_adult', '', '', '', 0, @ssaleid, '', '', 0, @persons_adult, 1.0
			if @revenus_room<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_room', '', '', '', 0, @ssaleid, '', '', 0, @revenus_room, 1.0
			if @revenus_fb<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_f&b', '', '', '', 0, @ssaleid, '', '', 0, @revenus_fb, 1.0
			if @revenus_extras<>0 exec p_gl_statistic_saveas_m @bdate, 'yielddb_revenus_extras', '', '', '', 0, @ssaleid, '', '', 0, @revenus_extras, 1.0
			end

		fetch c_cus_xf into @master, @accnt, @persons_adult, @haccnt, @groupno, @cusno, @agent, @source, @saleid, @bdate, @rooms_nights, @rooms_cancel, @rooms_noshow, @revenus_room, @revenus_fb, @revenus_extras
		end
	close c_cus_xf
	deallocate cursor c_cus_xf

	-- 更新累计数
	exec p_gl_statistic_saveas_y @pc_id, @bdate, 'yielddb_%', '%', '%'
	end

--
delete accnt_set where pc_id=@pc_id and mdi_id=666

------------------------------------------------------------------------------------------------
-- 以下步骤转移到 独立的过程，因为当前过程在夜审中可能多次调用，会导致月累计反复计算，耽误时间
-- p_gds_audit_statistic_saveas_y
------------------------------------------------------------------------------------------------
---- 重建报表的月累计
--exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
--if @isfstday  = 'T'
--	begin
--	select @bdate = dateadd(dd, -1, @bdate)
--	exec p_gl_statistic_saveas_y @pc_id, @bdate, '%', '%', '%'
--	end

return 0
;