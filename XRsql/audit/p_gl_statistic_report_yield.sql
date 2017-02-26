IF OBJECT_ID('dbo.p_gl_statistic_report_yield') IS NOT NULL
    DROP PROCEDURE dbo.p_gl_statistic_report_yield
;
create proc p_gl_statistic_report_yield
	@pc_id				char(4),
	@firstday			datetime,					-- 日期
	@lastday				datetime,					-- 预留出区间报表
	@item					char(30) = 'code',		-- 针对客户code, year_code, year_code_class1, year_code_class2, year_code_class3, year_code_class4
															-- 针对销售员saleid, year_saleid, year_saleid_class
															-- 原来针对销售员的参数 grp, year_grp 取消
	@para1				varchar(255),				-- market_revenus_room-d,source_rooms_occupancy-w,channel_persons_adult-m,ratecode_revenus_f&b-y
															-- 例如 : firstday = 2005/05/15, ladtday = 2005/05/15
															-- m本月到15号的合计数,m1上月到15号的合计数......m12上年同月到15号的合计数
															-- M1上月全月的合计数......M12上年同月合计数
															-- y本年到05/15号的合计数,y1上年到05/15好的合计数,Y1上年全年的合计数
															-- 如果firstday <> lastday, 区间报表参数必须是T
															-- Am,AY1等含有字母A的表示按会计月份计算
	@para2 				varchar(255) = '',
	@langid				integer = 0,
	@para3				varchar(255) = ''			-- 过滤条件 no=3150023；class=F；
															-- <return> 只准备好statistic_p,不select返回
as
delete gdsmsg
-- insert gdsmsg select @item

if charindex('@', @para3)>0 -- 报表专家语法中避免分号，这里还原
	exec p_gds_string_multi_replace @para3, '@', ';', @para3 output

declare
	@para					varchar(255),
	@pos1					integer,
	@pos2					integer,
	@count				integer,
	@column				varchar(10),
	@cat					char(30),
	@grp					char(10),
	@code					char(10),
	@mcode				varchar(10),	-- 指定档案或者销售员
	@class				varchar(30),
	@option				char(10),
	@operator			char(1),
	@cat1					varchar(255),
	@cat2					varchar(255),
	@display				char(1),
	@cat_descript		varchar(50),
	@cat_descript1		varchar(50),
	@cat_sequence		integer,
	@grp_descript		varchar(50),
	@grp_descript1		varchar(50),
	@grp_sequence		integer,
	@code_descript		varchar(50),
	@code_descript1	varchar(50),
	@code_sequence		integer,
	@cfirstday			datetime,
	@clastday			datetime,
	@year					integer,
	@item1				char(30),
	@index				char(31)

delete statistic_p where pc_id = @pc_id

-- 临时表
create table #statistic
(
	year				integer				Not Null,
	cat				char(30)				Not Null,
	cat_descript	varchar(50)			Default '' Null,
	cat_descript1	varchar(50)			Default '' Null,
	cat_sequence	integer				Default 0 Null,
	operator			char(1)				Default '' Null,
	cat1				varchar(255)		Default '' Null,
	cat2				varchar(255)		Default '' Null,
	display			char(1)				Default 'T' Null			-- 是否需要呈现
)

if not rtrim(@para1) is null
	select @para = @para1, @para1 = ''
else
	select @para = @para2, @para2 = ''
select @count = 1

if @item like '%year%'								-- yearview
	begin

	create table #statistic_c(
		year				integer				Not Null,
		grp				char(10)				Default '' Not Null,
		grp_descript	varchar(50)			Default '' Null,
		grp_descript1	varchar(50)			Default '' Null,
		grp_sequence	integer				Default 0 Null,
		code				char(10)				Default '' Not Null,
		code_descript	varchar(50)			Default '' Null,
		code_descript1	varchar(50)			Default '' Null,
		code_sequence	integer				Default 0 Null,
	)
	--
	while not rtrim(@para) is null
		begin
		-- 分解para
		select @pos1 = charindex(',', @para)
		if @pos1 = 0
			select @cat = @para, @para = ''
		else
			select @cat = substring(@para, 1, @pos1 - 1), @para = substring(@para, @pos1 + 1, 255)
		select @cfirstday = @firstday, @clastday = @lastday
		while @cfirstday <= @clastday
			begin
			insert #statistic select datepart(year, @cfirstday), cat, descript, descript1, @count,operator, cat1, cat2, 'T'
				from statistic_i where cat = @cat
			select @cfirstday = dateadd(yy, 1, @cfirstday)
			end
		select @count = @count + 1
		if rtrim(@para) is null
			select @para = @para2, @para2 = ''
		end

	insert #statistic select distinct b.year, a.cat, a.descript, a.descript1, -1, a.operator, a.cat1, a.cat2, 'F'
		from statistic_i a, #statistic b where  a.cat not in (select cat from #statistic)
		and (charindex(',' + rtrim(a.cat) + ',', ',' + b.cat1 + ',') > 0 or charindex(',' + rtrim(a.cat) + ',', ',' + b.cat2 + ',') > 0)
	-- 已经有的指标
	select @year = datepart(year, @firstday)
	select @item1 = substring(@item, charindex('_', @item) + 1, 30)

	if charindex('code', @item1) > 0  -- 客户部分
		begin
		-- 指定档案号
		if charindex(';no=', @para3) > 0
			begin
			exec p_gds_get_flag_string @para3, ';no=', ';', @code output
			select @code=rtrim(@code)+'%'
			insert #statistic_c (year, grp, code) select distinct a.year, '%', a.code
				from statistic_y a, #statistic b where a.year = b.year and a.cat = b.cat and a.code like @code
			if @@rowcount = 0
				insert #statistic_c (year, grp, code) select distinct a.year, '%', @code from #statistic a
			end
		else
			begin
			insert #statistic_c (year, grp, code) select distinct a.year, '%', a.code
				from statistic_y a, #statistic b where a.year = b.year and a.cat = b.cat and a.code != '' and a.code not like 'S%'

		--------------------------------------------------------------------------------------------------------------
		---- 过滤处理
			if charindex(';class=', @para3) > 0
				begin
				exec p_gds_get_flag_string @para3, ';class=', ';', @class output
				delete #statistic_c from guest a where #statistic_c.code = a.no and a.class != @class
				end
		-- for guest class - 1234
			if charindex(';class1=', @para3) > 0
				begin
				exec p_gds_get_flag_string @para3, ';class1=', ';', @class output
				delete #statistic_c from guest a where #statistic_c.code = a.no and charindex(rtrim(a.class1),@class)=0
				end
			if charindex(';class2=', @para3) > 0
				begin
				exec p_gds_get_flag_string @para3, ';class2=', ';', @class output
				delete #statistic_c from guest a where #statistic_c.code = a.no and charindex(rtrim(a.class2),@class)=0
				end
			if charindex(';class3=', @para3) > 0
				begin
				exec p_gds_get_flag_string @para3, ';class=3', ';', @class output
				delete #statistic_c from guest a where #statistic_c.code = a.no and charindex(rtrim(a.class3),@class)=0
				end
			if charindex(';class4=', @para3) > 0
				begin
				exec p_gds_get_flag_string @para3, ';class4=', ';', @class output
				delete #statistic_c from guest a where #statistic_c.code = a.no and charindex(rtrim(a.class4),@class)=0
				end
			if charindex(';sid=', @para3) > 0  -- 指定销售员
				begin
				exec p_gds_get_flag_string @para3, ';sid=', ';', @code output
				delete from #statistic_c where code not in (select no from guest where class in ('C','A','S') and saleid = @code)
				end
		---- 过滤处理
		--------------------------------------------------------------------------------------------------------------

			end
		update #statistic_c set code_descript = a.name, code_descript1 = a.name2, code_sequence = 0
			from guest a where #statistic_c.code = a.no
		if @@rowcount > 200  -- ???
			insert statistic_p (pc_id, year, cat, cat_descript, cat_descript1, cat_sequence, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence, display,
				amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10, amount11, amount12, amount13)
				select @pc_id, a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, '%', '', '', 0, b.code, '', '', 0, 'F',
				sum(b.month01), sum(b.month02), sum(b.month03), sum(b.month04), sum(b.month05), sum(b.month06), sum(b.month07), sum(b.month08), sum(b.month09), sum(b.month10), sum(b.month11), sum(b.month12), sum(b.month99)
				from #statistic a, statistic_y b
				where b.year = a.year and b.cat = a.cat group by a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, b.code
		else
			insert statistic_p (pc_id, year, cat, cat_descript, cat_descript1, cat_sequence, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence, display,
				amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10, amount11, amount12, amount13)
				select @pc_id, a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, '%', '', '', 0, b.code, '', '', 0, 'F',
				sum(b.month01), sum(b.month02), sum(b.month03), sum(b.month04), sum(b.month05), sum(b.month06), sum(b.month07), sum(b.month08), sum(b.month09), sum(b.month10), sum(b.month11), sum(b.month12), sum(b.month99)
				from #statistic a, statistic_y b, #statistic_c c
				where b.year = a.year and b.cat = a.cat and b.year = c.year and b.code = c.code
				group by a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, b.code

end

	else		-- 销售员部分
		begin
		if charindex(';sid=', @para3) > 0  -- 指定销售员
			begin
			exec p_gds_get_flag_string @para3, ';sid=', ';', @code output
			select @code='S'+@code
			insert #statistic_c (year, grp, code) select distinct a.year, '%', a.code from statistic_y a, #statistic b
				where a.year = b.year and a.cat = b.cat and a.code = @code
			end
		else
			begin
			insert #statistic_c (year, grp, code) select distinct a.year, '%', a.code from statistic_y a, #statistic b
				where a.year = b.year and a.cat = b.cat and a.code like 'S%'
			--------------------------------------------------------------------------------------------------------------
			---- 过滤处理
			if charindex(';salegrp=', @para3) > 0
				begin
				exec p_gds_get_flag_string @para3, ';salegrp=', ';', @class output
				delete #statistic_c from saleid a where #statistic_c.code = 'S'+a.code and a.grp != @class
				end
			---- 过滤处理
			--------------------------------------------------------------------------------------------------------------
			end

--		update #statistic_c set grp_descript = a.descript, grp_descript1 = a.descript1, grp_sequence = 0
--			from saleid a where #statistic_c.grp = a.code
		update #statistic_c set code_descript = a.name, code_descript1 = a.name2, code_sequence = a.sequence
			from saleid a where #statistic_c.code = 'S'+a.code
		insert statistic_p (pc_id, year, cat, cat_descript, cat_descript1, cat_sequence, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence, display,
			amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10, amount11, amount12, amount13)
			select @pc_id, a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, '%', '', '', 0, b.code, '', '', 0, 'F',
			sum(b.month01), sum(b.month02), sum(b.month03), sum(b.month04), sum(b.month05), sum(b.month06), sum(b.month07), sum(b.month08), sum(b.month09), sum(b.month10), sum(b.month11), sum(b.month12), sum(b.month99)
			from #statistic a, statistic_y b, #statistic_c c
			where b.year = a.year and b.cat = a.cat and b.year=c.year and b.code=c.code
			group by a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, b.code
		end

	delete statistic_p where pc_id = @pc_id and (grp = '' or code = '')

--	-- 合计
--	insert #statistic_c (grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence)
--		select '{{{', '合计', 'Total', 10000, '{{{', '合计', 'Total', 10000
--	insert statistic_p (pc_id, year, cat, cat_descript, cat_descript1, cat_sequence, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence, display,
--		amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10, amount11, amount12, amount13)
--		select @pc_id, @year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, '{{{', '合计', 'Total', 10000, '{{{', '合计', 'Total', 10000, 'F',
--		sum(a.amount01), sum(a.amount02), sum(a.amount03), sum(a.amount04), sum(a.amount05), sum(a.amount06), sum(a.amount07), sum(a.amount08), sum(a.amount09), sum(a.amount10), sum(a.amount11), sum(a.amount12), sum(a.amount13)
--		from statistic_p a where a.pc_id = @pc_id
--		group by a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence
	-- 1.去掉起始日期以前的整月
	select @index = replicate('0', datepart(month, @firstday) - 1) + replicate('1', 13 - datepart(month, @firstday)), @year = datepart(year, @firstday)
	if @index ! = '111111111111'
		update statistic_p set amount01 = amount01 * convert(money, substring(@index, 1, 1)), amount02 = amount02 * convert(money, substring(@index, 2, 1)),
			amount03 = amount03 * convert(money, substring(@index, 3, 1)), amount04 = amount04 * convert(money, substring(@index, 4, 1)),
			amount05 = amount05 * convert(money, substring(@index, 5, 1)), amount06 = amount06 * convert(money, substring(@index, 6, 1)),
			amount07 = amount07 * convert(money, substring(@index, 7, 1)), amount08 = amount08 * convert(money, substring(@index, 8, 1)),
			amount09 = amount09 * convert(money, substring(@index, 9, 1)), amount10 = amount10 * convert(money, substring(@index, 10, 1)),
			amount11 = amount11 * convert(money, substring(@index, 11, 1)), amount12 = amount12 * convert(money, substring(@index, 12, 1))
			where pc_id = @pc_id and year = @year
	-- 2.去掉截止日期以后的整月
	select @index = replicate('1', datepart(month, @lastday)) + replicate('0', 12 - datepart(month, @lastday)), @year = datepart(year, @lastday)
	if @index ! = '111111111111'
		update statistic_p set amount01 = amount01 * convert(money, substring(@index, 1, 1)), amount02 = amount02 * convert(money, substring(@index, 2, 1)),
			amount03 = amount03 * convert(money, substring(@index, 3, 1)), amount04 = amount04 * convert(money, substring(@index, 4, 1)),
			amount05 = amount05 * convert(money, substring(@index, 5, 1)), amount06 = amount06 * convert(money, substring(@index, 6, 1)),
			amount07 = amount07 * convert(money, substring(@index, 7, 1)), amount08 = amount08 * convert(money, substring(@index, 8, 1)),
			amount09 = amount09 * convert(money, substring(@index, 9, 1)), amount10 = amount10 * convert(money, substring(@index, 10, 1)),
			amount11 = amount11 * convert(money, substring(@index, 11, 1)), amount12 = amount12 * convert(money, substring(@index, 12, 1))
			where pc_id = @pc_id and year = @year
	-- 3.去掉中间的数据
	declare c_cat cursor for select cat from #statistic
	open c_cat
	fetch c_cat into @cat
	while @@sqlstatus = 0
		begin
		-- 起止日期在同一个月, 但不是从头到尾
		if datediff(mm, @firstday, @lastday) = 0 and (datepart(day, @firstday) != 1 or datepart(month, @lastday) = datepart(month, dateadd(dd, 1, @lastday)))
			begin
			select @cfirstday = @firstday, @clastday = @lastday
			exec p_gl_statistic_get @pc_id, @cfirstday, @clastday, @cat, '%', '%', 'T', @item1
			select @index = '000000000000', @year = datepart(year, @cfirstday)
			select @index = stuff(@index, datepart(month, @cfirstday), 1, '1')
			update statistic_p set amount01 = amount01 - (amount01 - a.amount) * convert(money, substring(@index, 1, 1)), amount02 = amount02 - (amount02 - a.amount) * convert(money, substring(@index, 2, 1)),
				amount03 = amount03 - (amount03 - a.amount) * convert(money, substring(@index, 3, 1)), amount04 = amount04 - (amount04 - a.amount) * convert(money, substring(@index, 4, 1)),
				amount05 = amount05 - (amount05 - a.amount) * convert(money, substring(@index, 5, 1)), amount06 = amount06 - (amount06 - a.amount) * convert(money, substring(@index, 6, 1)),
				amount07 = amount07 - (amount07 - a.amount) * convert(money, substring(@index, 7, 1)), amount08 = amount08 - (amount08 - a.amount) * convert(money, substring(@index, 8, 1)),
				amount09 = amount09 - (amount09 - a.amount) * convert(money, substring(@index, 9, 1)), amount10 = amount10 - (amount10 - a.amount) * convert(money, substring(@index, 10, 1)),
				amount11 = amount11 - (amount11 - a.amount) * convert(money, substring(@index, 11, 1)), amount12 = amount12 - (amount12 - a.amount) * convert(money, substring(@index, 12, 1))
				from statistic_t a where statistic_p.pc_id = @pc_id and a.pc_id = statistic_p.pc_id
				and statistic_p.year = @year and statistic_p.cat = a.cat and statistic_p.grp like a.grp and statistic_p.code like a.code
			end
		else
			begin
			-- 起始日期不是一号
			if datediff(mm, @firstday, @lastday) != 0 and datepart(day, @firstday) != 1
				begin
				select @cfirstday = @firstday, @clastday = dateadd(dd, - datepart(dd, dateadd(mm, 1, @firstday)), dateadd(mm, 1, @firstday))
				exec p_gl_statistic_get @pc_id, @cfirstday, @clastday, @cat, '%', '%', 'T', @item1
				select @index = '000000000000', @year = datepart(year, @cfirstday)
				select @index = stuff(@index, datepart(month, @cfirstday), 1, '1')
				update statistic_p set amount01 = amount01 - (amount01 - a.amount) * convert(money, substring(@index, 1, 1)), amount02 = amount02 - (amount02 - a.amount) * convert(money, substring(@index, 2, 1)),
					amount03 = amount03 - (amount03 - a.amount) * convert(money, substring(@index, 3, 1)), amount04 = amount04 - (amount04 - a.amount) * convert(money, substring(@index, 4, 1)),
					amount05 = amount05 - (amount05 - a.amount) * convert(money, substring(@index, 5, 1)), amount06 = amount06 - (amount06 - a.amount) * convert(money, substring(@index, 6, 1)),
					amount07 = amount07 - (amount07 - a.amount) * convert(money, substring(@index, 7, 1)), amount08 = amount08 - (amount08 - a.amount) * convert(money, substring(@index, 8, 1)),
					amount09 = amount09 - (amount09 - a.amount) * convert(money, substring(@index, 9, 1)), amount10 = amount10 - (amount10 - a.amount) * convert(money, substring(@index, 10, 1)),
					amount11 = amount11 - (amount11 - a.amount) * convert(money, substring(@index, 11, 1)), amount12 = amount12 - (amount12 - a.amount) * convert(money, substring(@index, 12, 1))
					from statistic_t a where statistic_p.pc_id = @pc_id and a.pc_id = statistic_p.pc_id
					and statistic_p.year = @year and statistic_p.cat = a.cat and statistic_p.grp like a.grp and statistic_p.code like a.code
				end
			-- 截止日期不是月末
			if datediff(mm, @firstday, @lastday) != 0 and datepart(month, @lastday) = datepart(month, dateadd(dd, 1, @lastday))
				begin
				select @cfirstday = dateadd(dd, 1 - datepart(dd, @lastday), @lastday), @clastday = @lastday
				exec p_gl_statistic_get @pc_id, @cfirstday, @clastday, @cat, '%', '%', 'T', @item1
				select @index = '000000000000', @year = datepart(year, @cfirstday)
				select @index = stuff(@index, datepart(month, @cfirstday), 1, '1')
				update statistic_p set amount01 = amount01 - (amount01 - a.amount) * convert(money, substring(@index, 1, 1)), amount02 = amount02 - (amount02 - a.amount) * convert(money, substring(@index, 2, 1)),
					amount03 = amount03 - (amount03 - a.amount) * convert(money, substring(@index, 3, 1)), amount04 = amount04 - (amount04 - a.amount) * convert(money, substring(@index, 4, 1)),
					amount05 = amount05 - (amount05 - a.amount) * convert(money, substring(@index, 5, 1)), amount06 = amount06 - (amount06 - a.amount) * convert(money, substring(@index, 6, 1)),
					amount07 = amount07 - (amount07 - a.amount) * convert(money, substring(@index, 7, 1)), amount08 = amount08 - (amount08 - a.amount) * convert(money, substring(@index, 8, 1)),
					amount09 = amount09 - (amount09 - a.amount) * convert(money, substring(@index, 9, 1)), amount10 = amount10 - (amount10 - a.amount) * convert(money, substring(@index, 10, 1)),
					amount11 = amount11 - (amount11 - a.amount) * convert(money, substring(@index, 11, 1)), amount12 = amount12 - (amount12 - a.amount) * convert(money, substring(@index, 12, 1))
					from statistic_t a where statistic_p.pc_id = @pc_id and a.pc_id = statistic_p.pc_id
					and statistic_p.year = @year and statistic_p.cat = a.cat and statistic_p.grp like a.grp and statistic_p.code like a.code
				end
			end
		fetch c_cat into @cat
		end
	close c_cat
	-- Group By Class?
	if charindex('code_class', @item1) > 0
		begin
		if charindex('code_class1', @item1) > 0
			begin
			insert #statistic_c (year, grp, code) select distinct a.year, 'class', b.class1
				from #statistic_c a, guest b where a.code = b.no
			insert statistic_p (pc_id, year, cat, cat_descript, cat_descript1, cat_sequence, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence, display,
				amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10, amount11, amount12, amount13)
				select @pc_id, a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, 'class', '', '', 0, b.class1, '', '', 0, a.display,
				sum(a.amount01), sum(a.amount02), sum(a.amount03), sum(a.amount04), sum(a.amount05), sum(a.amount06), sum(a.amount07), sum(a.amount08), sum(a.amount09), sum(a.amount10), sum(a.amount11), sum(a.amount12), sum(a.amount13)
				from statistic_p a, guest b
				where a.pc_id = @pc_id and a.code = b.no
				group by a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, b.class1, a.display
			end
		else if charindex('code_class2', @item1) > 0
			begin
			insert #statistic_c (year, grp, code) select distinct a.year, 'class', b.class2
				from #statistic_c a, guest b where a.code = b.no
			insert statistic_p (pc_id, year, cat, cat_descript, cat_descript1, cat_sequence, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence, display,
				amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10, amount11, amount12, amount13)
				select @pc_id, a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, 'class', '', '', 0, b.class2, '', '', 0, a.display,
				sum(a.amount01), sum(a.amount02), sum(a.amount03), sum(a.amount04), sum(a.amount05), sum(a.amount06), sum(a.amount07), sum(a.amount08), sum(a.amount09), sum(a.amount10), sum(a.amount11), sum(a.amount12), sum(a.amount13)
				from statistic_p a, guest b
				where a.pc_id = @pc_id and a.code = b.no
				group by a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, b.class2, a.display
			end
		else if charindex('code_class3', @item1) > 0
			begin
			insert #statistic_c (year, grp, code) select distinct a.year, 'class', b.class3
				from #statistic_c a, guest b where a.code = b.no
			insert statistic_p (pc_id, year, cat, cat_descript, cat_descript1, cat_sequence, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence, display,
				amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10, amount11, amount12, amount13)
				select @pc_id, a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, 'class', '', '', 0, b.class3, '', '', 0, a.display,
				sum(a.amount01), sum(a.amount02), sum(a.amount03), sum(a.amount04), sum(a.amount05), sum(a.amount06), sum(a.amount07), sum(a.amount08), sum(a.amount09), sum(a.amount10), sum(a.amount11), sum(a.amount12), sum(a.amount13)
				from statistic_p a, guest b
				where a.pc_id = @pc_id and a.code = b.no
				group by a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, b.class3, a.display
			end
		else if charindex('code_class4', @item1) > 0
			begin
			insert #statistic_c (year, grp, code) select distinct a.year, 'class', b.class4
				from #statistic_c a, guest b where a.code = b.no
			insert statistic_p (pc_id, year, cat, cat_descript, cat_descript1, cat_sequence, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence, display,
				amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10, amount11, amount12, amount13)
				select @pc_id, a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, 'class', '', '', 0, b.class4, '', '', 0, a.display,
				sum(a.amount01), sum(a.amount02), sum(a.amount03), sum(a.amount04), sum(a.amount05), sum(a.amount06), sum(a.amount07), sum(a.amount08), sum(a.amount09), sum(a.amount10), sum(a.amount11), sum(a.amount12), sum(a.amount13)
				from statistic_p a, guest b
				where a.pc_id = @pc_id and a.code = b.no
				group by a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, b.class4, a.display
			end
		-- 1.准备#statistic_c
		delete #statistic_c where grp = '%'
		update #statistic_c set grp = '%', code_descript = a.descript, code_descript1 = a.descript1
			from basecode a where #statistic_c.code = a.code and a.cat = 'cuscls' + substring(@item1, 11, 1)
		-- 2.准备statistic_p
		delete statistic_p where pc_id = @pc_id and grp = '%'
		update statistic_p set grp = '%', code_descript = a.descript, code_descript1 = a.descript1
			from basecode a where statistic_p.pc_id = @pc_id and statistic_p.code = a.code and a.cat = 'cuscls' + substring(@item1, 11, 1)
		end
	-- 需要计算的指标
	update statistic_p set amount13 = amount01 + amount02 + amount03 + amount04 + amount05 + amount06 +
		amount07 + amount08 + amount09 + amount10 + amount11 + amount12 where pc_id = @pc_id
	declare c_compute cursor for select b.year, b.cat, a.grp, a.code, b.operator, b.cat1, b.cat2, b.cat_descript, b.cat_descript1, b.cat_sequence, b.display,
		a.grp_descript, a.grp_descript1, a.grp_sequence, a.code_descript, a.code_descript1, a.code_sequence
		from #statistic_c a, #statistic b where a.year = b.year and b.display = 'T'
	open c_compute
	fetch c_compute into @year, @cat, @grp, @code, @operator, @cat1, @cat2, @cat_descript, @cat_descript1, @cat_sequence, @display, @grp_descript, @grp_descript1, @grp_sequence, @code_descript, @code_descript1, @code_sequence
	while @@sqlstatus = 0
		begin
		update statistic_p set cat_descript = @cat_descript, cat_descript1 = @cat_descript1, cat_sequence = @cat_sequence, display = @display,
			grp_descript = @grp_descript, grp_descript1 = @grp_descript1, grp_sequence = @grp_sequence, code_descript = @code_descript, code_descript1 = @code_descript1, code_sequence = @code_sequence
			where pc_id = @pc_id and year = @year and cat = @cat and grp = @grp and code = @code
		if @@rowcount = 0
			insert statistic_p (pc_id, year, cat, cat_descript, cat_descript1, cat_sequence, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence)
				select @pc_id, @year, @cat, @cat_descript, @cat_descript1, @cat_sequence, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence
		if not rtrim(@cat1) is null or not rtrim(@cat2) is null
			exec p_gl_statistic_operator @pc_id, @year, @cat, @grp, @code, @cat1, @cat2, @operator
		fetch c_compute into @year, @cat, @grp, @code, @operator, @cat1, @cat2, @cat_descript, @cat_descript1, @cat_sequence, @display, @grp_descript, @grp_descript1, @grp_sequence, @code_descript, @code_descript1, @code_sequence
		end
	close c_compute
	deallocate cursor c_compute
	end


else		-- not like year_%  记录列表输出方式
	begin
    select * into #statistic_tmp from statistic_t where 1=2
    declare c_cat cursor for select cat from #statistic
	if charindex('code', @item) > 0  -- 客户部分
		begin
		if charindex(';no=', @para3) > 0  -- 指定销售员
			exec p_gds_get_flag_string @para3, ';no=', ';', @mcode output
		else
			select @mcode='[0-9]%'

		while not rtrim(@para) is null
			begin
			-- 分解para
			select @pos1 = charindex(',', @para)
			if @pos1 = 0
				select @cat = @para, @para = ''
			else
				select @cat = substring(@para, 1, @pos1 - 1), @para = substring(@para, @pos1 + 1, 255)
			-- 分解cat
			select @pos1 = charindex('-', @cat)
			if @pos1 = 0
				select @column = 'd'
			else
				select @cat = substring(@cat, 1, @pos1 - 1), @column = substring(@cat, @pos1 + 1, 255)
			--
            delete from #statistic
            delete from #statistic_tmp
            insert #statistic select datepart(year, @firstday), cat, descript, descript1, 1,operator, cat1, cat2, 'T'
				from statistic_i where cat = @cat

        	insert #statistic select distinct b.year, a.cat, a.descript, a.descript1, -1, a.operator, a.cat1, a.cat2, 'F'
        		from statistic_i a, #statistic b where  a.cat not in (select cat from #statistic)
        		and (charindex(',' + rtrim(a.cat) + ',', ',' + b.cat1 + ',') > 0 or charindex(',' + rtrim(a.cat) + ',', ',' + b.cat2 + ',') > 0)

            open c_cat
            fetch c_cat into @cat
            while @@sqlstatus=0
            begin
					exec p_gl_statistic_get @pc_id, @firstday, @lastday, @cat, '%', @mcode, @column, @item
					-----------------------------------------------------------------------------------------
					--过滤处理提前到这里
					if charindex(';class=', @para3) > 0
						begin
						exec p_gds_get_flag_string @para3, ';class=', ';', @class output
						delete statistic_t from guest a where statistic_t.pc_id = @pc_id and statistic_t.code = a.no and a.class != @class
						end
					-- for guest class - 1234
					if charindex(';class1=', @para3) > 0
						begin
						exec p_gds_get_flag_string @para3, ';class1=', ';', @class output
						delete statistic_t from guest a where statistic_t.pc_id = @pc_id and statistic_t.code = a.no and charindex(rtrim(a.class1),@class)=0
						end
					if charindex(';class2=', @para3) > 0
						begin
						exec p_gds_get_flag_string @para3, ';class2=', ';', @class output
						delete statistic_t from guest a where statistic_t.pc_id = @pc_id and statistic_t.code = a.no and charindex(rtrim(a.class2),@class)=0
						end
					if charindex(';class3=', @para3) > 0
						begin
						exec p_gds_get_flag_string @para3, ';class3=', ';', @class output
						delete statistic_t from guest a where statistic_t.pc_id = @pc_id and statistic_t.code = a.no and charindex(rtrim(a.class3),@class)=0
						end
					if charindex(';class4=', @para3) > 0
						begin
						exec p_gds_get_flag_string @para3, ';class4=', ';', @class output
						delete statistic_t from guest a where statistic_t.pc_id = @pc_id and statistic_t.code = a.no and charindex(rtrim(a.class4),@class)=0
						end
					if charindex(';sid=', @para3) > 0  -- 指定销售员
						begin
						exec p_gds_get_flag_string @para3, ';sid=', ';', @code output
						delete from statistic_t where code not in (select no from guest where class in ('C','A','S') and saleid = @code)
						end
					--过滤处理
					---------------------------------------------------------------------------------------
                insert into #statistic_tmp select * from statistic_t where pc_id=@pc_id
                fetch c_cat into @cat
            end
            close c_cat
            delete from statistic_t where pc_id=@pc_id
            insert into statistic_t select * from #statistic_tmp

            if exists(select 1 from #statistic where display='F')
            begin
                select @cat=cat,@operator=operator,@cat1=cat1,@cat2=cat2 from #statistic where display='T'
                exec p_gl_statistic_operator1 @pc_id, @year, @cat, @grp, @code, @cat1, @cat2, @operator
            end

			--
			update statistic_t set tag = 'T' from statistic_p a
				where statistic_t.pc_id = @pc_id and a.pc_id = statistic_t.pc_id and a.grp = statistic_t.grp and a.code = statistic_t.code
			insert statistic_p (pc_id, cat, grp, code)
				select pc_id, cat, grp, code from statistic_t where pc_id = @pc_id and tag = 'F'
			select @index = '0000000000000000000000000000000'
			select @index = stuff(@index, @count, 1, '1')
			update statistic_p set amount01 = amount01 + a.amount * convert(money, substring(@index, 1, 1)), amount02 = amount02 + a.amount * convert(money, substring(@index, 2, 1)),
				amount03 = amount03 + a.amount * convert(money, substring(@index, 3, 1)), amount04 = amount04 + a.amount * convert(money, substring(@index, 4, 1)),
				amount05 = amount05 + a.amount * convert(money, substring(@index, 5, 1)), amount06 = amount06 + a.amount * convert(money, substring(@index, 6, 1)),
				amount07 = amount07 + a.amount * convert(money, substring(@index, 7, 1)), amount08 = amount08 + a.amount * convert(money, substring(@index, 8, 1)),
				amount09 = amount09 + a.amount * convert(money, substring(@index, 9, 1)), amount10 = amount10 + a.amount * convert(money, substring(@index, 10, 1)),
				amount11 = amount11 + a.amount * convert(money, substring(@index, 11, 1)), amount12 = amount12 + a.amount * convert(money, substring(@index, 12, 1)),
				amount13 = amount13 + a.amount * convert(money, substring(@index, 13, 1)), amount14 = amount14 + a.amount * convert(money, substring(@index, 14, 1)),
				amount15 = amount15 + a.amount * convert(money, substring(@index, 15, 1)), amount16 = amount16 + a.amount * convert(money, substring(@index, 16, 1)),
				amount17 = amount17 + a.amount * convert(money, substring(@index, 17, 1)), amount18 = amount18 + a.amount * convert(money, substring(@index, 18, 1)),
				amount19 = amount19 + a.amount * convert(money, substring(@index, 19, 1)), amount20 = amount20 + a.amount * convert(money, substring(@index, 20, 1))
				from statistic_t a where statistic_p.pc_id = @pc_id and a.pc_id = statistic_p.pc_id and statistic_p.grp = a.grp and statistic_p.code = a.code
			select @count = @count + 1
			if rtrim(@para) is null
				select @para = @para2, @para2 = ''
			end

		-- 删除金额为零的行
		delete statistic_p where pc_id = @pc_id and amount01 = 0 and amount02 = 0 and amount03 = 0 and amount04 = 0 and amount05 = 0
			and amount06 = 0 and amount07 = 0 and amount08 = 0 and amount09 = 0 and amount10 = 0 and amount11 = 0 and amount12 = 0
			and amount13 = 0 and amount14 = 0 and amount15 = 0 and amount16 = 0 and amount17 = 0 and amount18 = 0 and amount19 = 0 and amount20 = 0

		-- 描述
		update statistic_p set code_descript = a.name, code_descript1 = a.name2
			from guest a where statistic_p.pc_id = @pc_id and statistic_p.code = a.no
		end
	else		-- 销售员部分 @item = saleid
		begin
		if charindex(';sid=', @para3) > 0  -- 指定销售员
			begin
			exec p_gds_get_flag_string @para3, ';sid=', ';', @mcode output
			select @mcode='S'+rtrim(@mcode)+'%'
			end
		else
			select @mcode='S%'

		while not rtrim(@para) is null
			begin
			-- 分解para
			select @pos1 = charindex(',', @para)
			if @pos1 = 0
				select @cat = @para, @para = ''
			else
				select @cat = substring(@para, 1, @pos1 - 1), @para = substring(@para, @pos1 + 1, 255)
			-- 分解cat
			select @pos1 = charindex('-', @cat)
			if @pos1 = 0
				select @column = 'd'
			else
				select @cat = substring(@cat, 1, @pos1 - 1), @column = substring(@cat, @pos1 + 1, 255)
			--
            delete from #statistic
            delete from #statistic_tmp
            insert #statistic select datepart(year, @firstday), cat, descript, descript1, 1,operator, cat1, cat2, 'T'
				from statistic_i where cat = @cat

        	insert #statistic select distinct b.year, a.cat, a.descript, a.descript1, -1, a.operator, a.cat1, a.cat2, 'F'
        		from statistic_i a, #statistic b where  a.cat not in (select cat from #statistic)
        		and (charindex(',' + rtrim(a.cat) + ',', ',' + b.cat1 + ',') > 0 or charindex(',' + rtrim(a.cat) + ',', ',' + b.cat2 + ',') > 0)

            open c_cat
            fetch c_cat into @cat
            while @@sqlstatus=0
            begin
			    exec p_gl_statistic_get @pc_id, @firstday, @lastday, @cat, '%', @mcode, @column, @item
                insert into #statistic_tmp select * from statistic_t where pc_id=@pc_id
                fetch c_cat into @cat
            end
            close c_cat
            delete from statistic_t where pc_id=@pc_id
            insert into statistic_t select * from #statistic_tmp

            if exists(select 1 from #statistic where display='F')
            begin
                select @cat=cat,@operator=operator,@cat1=cat1,@cat2=cat2 from #statistic where display='T'
                exec p_gl_statistic_operator1 @pc_id, @year, @cat, @grp, @code, @cat1, @cat2, @operator
            end

			--
			update statistic_t set tag = 'T' from statistic_p a
				where statistic_t.pc_id = @pc_id and a.pc_id = statistic_t.pc_id and a.grp = statistic_t.grp and a.code = statistic_t.code
			insert statistic_p (pc_id, cat, grp, code)
				select pc_id, cat, grp, code from statistic_t where pc_id = @pc_id and tag = 'F'
			select @index = '0000000000000000000000000000000'
			select @index = stuff(@index, @count, 1, '1')
			update statistic_p set amount01 = amount01 + a.amount * convert(money, substring(@index, 1, 1)), amount02 = amount02 + a.amount * convert(money, substring(@index, 2, 1)),
				amount03 = amount03 + a.amount * convert(money, substring(@index, 3, 1)), amount04 = amount04 + a.amount * convert(money, substring(@index, 4, 1)),
				amount05 = amount05 + a.amount * convert(money, substring(@index, 5, 1)), amount06 = amount06 + a.amount * convert(money, substring(@index, 6, 1)),
				amount07 = amount07 + a.amount * convert(money, substring(@index, 7, 1)), amount08 = amount08 + a.amount * convert(money, substring(@index, 8, 1)),
				amount09 = amount09 + a.amount * convert(money, substring(@index, 9, 1)), amount10 = amount10 + a.amount * convert(money, substring(@index, 10, 1)),
				amount11 = amount11 + a.amount * convert(money, substring(@index, 11, 1)), amount12 = amount12 + a.amount * convert(money, substring(@index, 12, 1)),
				amount13 = amount13 + a.amount * convert(money, substring(@index, 13, 1)), amount14 = amount14 + a.amount * convert(money, substring(@index, 14, 1)),
				amount15 = amount15 + a.amount * convert(money, substring(@index, 15, 1)), amount16 = amount16 + a.amount * convert(money, substring(@index, 16, 1)),
				amount17 = amount17 + a.amount * convert(money, substring(@index, 17, 1)), amount18 = amount18 + a.amount * convert(money, substring(@index, 18, 1)),
				amount19 = amount19 + a.amount * convert(money, substring(@index, 19, 1)), amount20 = amount20 + a.amount * convert(money, substring(@index, 20, 1))
				from statistic_t a where statistic_p.pc_id = @pc_id and a.pc_id = statistic_p.pc_id and statistic_p.grp = a.grp and statistic_p.code = a.code
			select @count = @count + 1
			if rtrim(@para) is null
				select @para = @para2, @para2 = ''
			end

		-- 删除金额为零的行
		delete statistic_p where pc_id = @pc_id and amount01 = 0 and amount02 = 0 and amount03 = 0 and amount04 = 0 and amount05 = 0
			and amount06 = 0 and amount07 = 0 and amount08 = 0 and amount09 = 0 and amount10 = 0 and amount11 = 0 and amount12 = 0
			and amount13 = 0 and amount14 = 0 and amount15 = 0 and amount16 = 0 and amount17 = 0 and amount18 = 0 and amount19 = 0 and amount20 = 0
		--------------------------------------------------------------------------------------------------------------
		---- 过滤处理
		if charindex(';salegrp=', @para3) > 0
			begin
			exec p_gds_get_flag_string @para3, ';salegrp=', ';', @class output
			delete statistic_p from saleid a where statistic_p.pc_id = @pc_id and statistic_p.code = 'S'+a.code and a.grp != @class
			end
		---- 过滤处理
		--------------------------------------------------------------------------------------------------------------
		-- 描述
		update statistic_p set code_descript = a.name, code_descript1 = a.name2, code_sequence = a.sequence
			from saleid a where statistic_p.pc_id = @pc_id and statistic_p.code = 'S'+a.code
		end
	end
deallocate cursor c_cat
-- 输出
if charindex('<return>', @para3) > 0  -- 不直接输出，只是存放在表 statistic_p
	select @langid = @langid
else if @item = 'code' and @langid = 0
	select code, code_descript, sum(amount01), sum(amount02), sum(amount03), sum(amount04), sum(amount05), sum(amount06),
		sum(amount07), sum(amount08), sum(amount09), sum(amount10), sum(amount11), sum(amount12), sum(amount13), sum(amount14),
		sum(amount15), sum(amount16), sum(amount17), sum(amount18), sum(amount19), sum(amount20)
		from statistic_p where pc_id = @pc_id and code != ''
		group by code, code_descript
else if @item = 'code'
	select code, code_descript1, sum(amount01), sum(amount02), sum(amount03), sum(amount04), sum(amount05), sum(amount06),
		sum(amount07), sum(amount08), sum(amount09), sum(amount10), sum(amount11), sum(amount12), sum(amount13), sum(amount14),
		sum(amount15), sum(amount16), sum(amount17), sum(amount18), sum(amount19), sum(amount20)
		from statistic_p where pc_id = @pc_id and code != ''
		group by code, code_descript1
else if @item = 'saleid' and @langid = 0
	select code, code_descript, sum(amount01), sum(amount02), sum(amount03), sum(amount04), sum(amount05), sum(amount06),
		sum(amount07), sum(amount08), sum(amount09), sum(amount10), sum(amount11), sum(amount12), sum(amount13), sum(amount14),
		sum(amount15), sum(amount16), sum(amount17), sum(amount18), sum(amount19), sum(amount20)
		from statistic_p where pc_id = @pc_id and code != ''
		group by code, code_descript
else if @item = 'saleid'
	select code, code_descript1, sum(amount01), sum(amount02), sum(amount03), sum(amount04), sum(amount05), sum(amount06),
		sum(amount07), sum(amount08), sum(amount09), sum(amount10), sum(amount11), sum(amount12), sum(amount13), sum(amount14),
		sum(amount15), sum(amount16), sum(amount17), sum(amount18), sum(amount19), sum(amount20)
		from statistic_p where pc_id = @pc_id and code != ''
		order by code, code_descript1
else if @item like 'year_code%' and @langid = 0
	select code, code_descript, year, cat_descript, amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10,
		amount11, amount12, amount13, amount14, amount15, amount16, amount17, amount18, amount19, amount20
		from statistic_p where pc_id = @pc_id and display = 'T' order by code, year desc, cat_sequence
else if @item like 'year_code%'
	select code, code_descript1, year, cat_descript1, amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10,
		amount11, amount12, amount13, amount14, amount15, amount16, amount17, amount18, amount19, amount20
		from statistic_p where pc_id = @pc_id and display = 'T' order by code, year desc, cat_sequence
else if @item like 'year_saleid%' and @langid = 0
	select code, code_descript, year, cat_descript, amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10,
		amount11, amount12, amount13, amount14, amount15, amount16, amount17, amount18, amount19, amount20
		from statistic_p where pc_id = @pc_id and display = 'T' order by code, year desc, cat_sequence
else if @item like 'year_saleid%'
	select code, code_descript1, year, cat_descript1, amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10,
		amount11, amount12, amount13, amount14, amount15, amount16, amount17, amount18, amount19, amount20
		from statistic_p where pc_id = @pc_id and display = 'T' order by code, year desc, cat_sequence

return 0
;
