IF OBJECT_ID('dbo.p_gl_statistic_report') IS NOT NULL
    DROP PROCEDURE dbo.p_gl_statistic_report
;
create proc p_gl_statistic_report
	@pc_id				char(4),
	@firstday			datetime,					-- 日期
	@lastday				datetime,					-- 预留出区间报表
	@item					char(30) = 'code',		-- grp, year_code, year_grp
	@para1				varchar(255),				-- market_revenus_room-d,source_rooms_occupancy-w,channel_persons_adult-m,ratecode_revenus_f&b-y
															-- 例如 : firstday = 2005/05/15, ladtday = 2005/05/15
															-- m本月到15号的合计数,m1上月到15号的合计数......m12上年同月到15号的合计数
															-- M1上月全月的合计数......M12上年同月合计数
															-- y本年到05/15号的合计数,y1上年到05/15好的合计数,Y1上年全年的合计数
															-- 如果firstday <> lastday, 区间报表参数必须是T
															-- Am,AY1等含有字母A的表示按会计月份计算
															-- DFy,dFM1等表示本年、月的第几天, DFy本年第一天01/01, dFM1本月第二天
															-- ADFy,AdFM1等含有字母A的表示按会计月份计算本月的第几天, AD本月第一天, Ad1本月第二天
	@para2 				varchar(255) = '',
	@langid				integer = 0,
	@para3				char(30) = ''				-- withzero, withreturn
as
declare
	@para					varchar(255),
	@pos					integer,
	@count				integer,
	@amount				money,
	@column				varchar(10),
	@mcode				varchar(10),
	@cat					char(30),
	@grp					char(10),
	@code					char(10),
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
	@month				integer,
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
if @item like '%graph_date%'								-- graph
	begin
	while not rtrim(@para) is null
		begin
		-- 分解para
		select @pos = charindex(',', @para), @grp = '%'
		if @pos = 0
			select @cat = @para, @para = ''
		else
			select @cat = substring(@para, 1, @pos - 1), @para = substring(@para, @pos + 1, 255)
		select @cat = substring(@cat, 1, charindex('-', @cat) - 1), @code = substring(@cat, charindex('-', @cat) +1, 255)
		select @cfirstday = @firstday, @clastday = @lastday
		while @cfirstday <= @clastday
			begin
			if @count = 1
				insert statistic_p (pc_id, date) select @pc_id, @cfirstday
			select @index = '0000000000000000000000000000000'
			select @index = stuff(@index, datepart(dd, @cfirstday), 1, '1'), @year = datepart(yy, @cfirstday), @month = datepart(mm, @cfirstday)
			select @amount = isnull((select day01 * convert(money, substring(@index, 1, 1)) + day02 * convert(money, substring(@index, 2, 1)) + day03 * convert(money, substring(@index, 3, 1)) +
				day04 * convert(money, substring(@index, 4, 1)) + day05 * convert(money, substring(@index, 5, 1)) + day06 * convert(money, substring(@index, 6, 1)) +
				day07 * convert(money, substring(@index, 7, 1)) + day08 * convert(money, substring(@index, 8, 1)) + day09 * convert(money, substring(@index, 9, 1)) +
				day10 * convert(money, substring(@index, 10, 1)) + day11 * convert(money, substring(@index, 11, 1)) + day12 * convert(money, substring(@index, 12, 1)) +
				day13 * convert(money, substring(@index, 13, 1)) + day14 * convert(money, substring(@index, 14, 1)) + day15 * convert(money, substring(@index, 15, 1)) +
				day16 * convert(money, substring(@index, 16, 1)) + day17 * convert(money, substring(@index, 17, 1)) + day18 * convert(money, substring(@index, 18, 1)) +
				day19 * convert(money, substring(@index, 19, 1)) + day20 * convert(money, substring(@index, 20, 1)) + day21 * convert(money, substring(@index, 21, 1)) +
				day22 * convert(money, substring(@index, 22, 1)) + day23 * convert(money, substring(@index, 24, 1)) + day24 * convert(money, substring(@index, 24, 1)) +
				day25 * convert(money, substring(@index, 25, 1)) + day26 * convert(money, substring(@index, 26, 1)) + day27 * convert(money, substring(@index, 27, 1)) +
				day28 * convert(money, substring(@index, 28, 1)) + day29 * convert(money, substring(@index, 29, 1)) + day30 * convert(money, substring(@index, 30, 1)) +
				day31 * convert(money, substring(@index, 31, 1))
				from statistic_m where year = @year and month = @month and cat like @cat and grp like @grp and code like @code), 0)
			select @index = '0000000000000000000000000000000'
			select @index = stuff(@index, @count, 1, '1')
			update statistic_p set amount01 = amount01 + @amount * convert(money, substring(@index, 1, 1)), amount02 = amount02 + @amount * convert(money, substring(@index, 2, 1)),
				amount03 = amount03 + @amount * convert(money, substring(@index, 3, 1)), amount04 = amount04 + @amount * convert(money, substring(@index, 4, 1)),
				amount05 = amount05 + @amount * convert(money, substring(@index, 5, 1)), amount06 = amount06 + @amount * convert(money, substring(@index, 6, 1)),
				amount07 = amount07 + @amount * convert(money, substring(@index, 7, 1)), amount08 = amount08 + @amount * convert(money, substring(@index, 8, 1)),
				amount09 = amount09 + @amount * convert(money, substring(@index, 9, 1)), amount10 = amount10 + @amount * convert(money, substring(@index, 10, 1)),
				amount11 = amount11 + @amount * convert(money, substring(@index, 11, 1)), amount12 = amount12 + @amount * convert(money, substring(@index, 12, 1)),
				amount13 = amount13 + @amount * convert(money, substring(@index, 13, 1)), amount14 = amount14 + @amount * convert(money, substring(@index, 14, 1)),
				amount15 = amount15 + @amount * convert(money, substring(@index, 15, 1)), amount16 = amount16 + @amount * convert(money, substring(@index, 16, 1)),
				amount17 = amount17 + @amount * convert(money, substring(@index, 17, 1)), amount18 = amount18 + @amount * convert(money, substring(@index, 18, 1)),
				amount19 = amount19 + @amount * convert(money, substring(@index, 19, 1)), amount20 = amount20 + @amount * convert(money, substring(@index, 20, 1))
				where pc_id = @pc_id and date = @cfirstday
			select @cfirstday = dateadd(dd, 1, @cfirstday)
			end
		select @count = @count + 1
		if rtrim(@para) is null
			select @para = @para2, @para2 = ''
		end
		update statistic_p set cat_descript = substring(convert(char(10), date, 3), 1, 2) + '(' + convert(char(1), datepart(weekday, date)) + ')'
			where pc_id = @pc_id
	end
else if @item like '%year%'								-- yearview
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
		select @pos = charindex(',', @para)
		if @pos = 0
			select @cat = @para, @para = ''
		else
			select @cat = substring(@para, 1, @pos - 1), @para = substring(@para, @pos + 1, 255)
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
	insert #statistic select b.year, a.cat, a.descript, a.descript1, -1, a.operator, a.cat1, a.cat2, 'F'
		from statistic_i a, #statistic b where  a.cat not in (select cat from #statistic)
		and (charindex(',' + rtrim(a.cat) + ',', ',' + b.cat1 + ',') > 0 or charindex(',' + rtrim(a.cat) + ',', ',' + b.cat1 + ',') > 0)
	-- 已经有的指标
	select @year = datepart(year, @firstday)
	select @item1 = substring(@item, charindex('_', @item) + 1, 30)
	insert #statistic_c (year, grp, code) select distinct a.year, a.grp, a.code
		from statistic_y a, #statistic b where a.year = b.year and a.cat = b.cat
	update #statistic_c set grp_descript = a.grp_descript, grp_descript1 = a.grp_descript1, grp_sequence = a.grp_sequence,
		code_descript = a.code_descript, code_descript1 = a.code_descript1, code_sequence = a.code_sequence
		from statistic_c a where a.cat in (select cat from #statistic) and #statistic_c.grp = a.grp and #statistic_c.code = a.code
	insert statistic_p (pc_id, year, cat, cat_descript, cat_descript1, cat_sequence, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence, display,
		amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10, amount11, amount12, amount13)
		select @pc_id, a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, b.grp, '', '', 0, b.code, '', '', 0, 'F',
		sum(b.month01), sum(b.month02), sum(b.month03), sum(b.month04), sum(b.month05), sum(b.month06), sum(b.month07), sum(b.month08), sum(b.month09), sum(b.month10), sum(b.month11), sum(b.month12), sum(b.month99)
		from #statistic a, statistic_y b
		where b.year = a.year and b.cat = a.cat group by a.year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, b.grp, b.code
	-- 合计
	insert #statistic_c (year, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence)
		select @year, '{{{', '合计', 'Total', 10000, '{{{', '合计', 'Total', 10000
	insert statistic_p (pc_id, year, cat, cat_descript, cat_descript1, cat_sequence, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence, display,
		amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10, amount11, amount12, amount13)
		select @pc_id, @year, a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence, '{{{', '合计', 'Total', 10000, '{{{', '合计', 'Total', 10000, 'F',
		sum(a.amount01), sum(a.amount02), sum(a.amount03), sum(a.amount04), sum(a.amount05), sum(a.amount06), sum(a.amount07), sum(a.amount08), sum(a.amount09), sum(a.amount10), sum(a.amount11), sum(a.amount12), sum(a.amount13)
		from statistic_p a where a.pc_id = @pc_id
		group by a.cat, a.cat_descript, a.cat_descript1, a.cat_sequence
	-- 需要计算的指标
	update statistic_p set amount13 = amount01 + amount02 + amount03 + amount04 + amount05 + amount06 +
		amount07 + amount08 + amount09 + amount10 + amount11 + amount12 where pc_id = @pc_id
	declare c_compute1 cursor for select b.year, b.cat, a.grp, a.code, b.operator, b.cat1, b.cat2, b.cat_descript, b.cat_descript1, b.cat_sequence, b.display,
		a.grp_descript, a.grp_descript1, a.grp_sequence, a.code_descript, a.code_descript1, a.code_sequence
		from #statistic_c a, #statistic b where a.year = b.year and b.display = 'T'
	open c_compute1
	fetch c_compute1 into @year, @cat, @grp, @code, @operator, @cat1, @cat2, @cat_descript, @cat_descript1, @cat_sequence, @display, @grp_descript, @grp_descript1, @grp_sequence, @code_descript, @code_descript1, @code_sequence
	while @@sqlstatus = 0
		begin
		update statistic_p set cat_descript = @cat_descript, cat_descript1 = @cat_descript1, cat_sequence = @cat_sequence, display = @display,
			grp_descript = @grp_descript, grp_descript1 = @grp_descript1, grp_sequence = @grp_sequence, code_descript = @code_descript, code_descript1 = @code_descript1, code_sequence = @code_sequence
			where pc_id = @pc_id and year = @year and cat = @cat and grp = @grp and code = @code
		if @@rowcount = 0
			insert statistic_p (pc_id, year, cat, cat_descript, cat_descript1, cat_sequence, grp, grp_descript, grp_descript1, grp_sequence, code, code_descript, code_descript1, code_sequence)
				select @pc_id, @year, @cat, @cat_descript, @cat_descript1, @cat_sequence, @grp, @grp_descript, @grp_descript1, @grp_sequence, @code, @code_descript, @code_descript1, @code_sequence
		if not (rtrim(@operator) is null and rtrim(@cat1) is null and rtrim(@cat1) is null)
			exec p_gl_statistic_operator @pc_id, @year, @cat, @grp, @code, @cat1, @cat2, @operator
		fetch c_compute1 into @year, @cat, @grp, @code, @operator, @cat1, @cat2, @cat_descript, @cat_descript1, @cat_sequence, @display, @grp_descript, @grp_descript1, @grp_sequence, @code_descript, @code_descript1, @code_sequence
		end
	close c_compute1
	deallocate cursor c_compute1
	end
else
	begin
    select * into #statistic_tmp from statistic_t where 1=2
    declare c_cat cursor for select cat from #statistic
	while not rtrim(@para) is null
		begin
		-- 分解para
		select @pos = charindex(',', @para)
		if @pos = 0
			select @cat = @para, @para = ''
		else
			select @cat = substring(@para, 1, @pos - 1), @para = substring(@para, @pos + 1, 255)
		-- 分解cat
		select @pos = charindex('-', @cat)
		if @pos = 0
			select @column = 'd'
		else
			select @cat = substring(@cat, 1, @pos - 1), @column = substring(@cat, @pos + 1, 255)
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
			    exec p_gl_statistic_get @pc_id, @firstday, @lastday, @cat, '%', '%', @column, 'grp,code'
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
	-- 按需要删除金额为零的行
	if charindex('withzero', @para3) = 0
		delete statistic_p where pc_id = @pc_id and amount01 = 0 and amount02 = 0 and amount03 = 0 and amount04 = 0 and amount05 = 0
			and amount06 = 0 and amount07 = 0 and amount08 = 0 and amount09 = 0 and amount10 = 0 and amount11 = 0 and amount12 = 0
			and amount13 = 0 and amount14 = 0 and amount15 = 0 and amount16 = 0 and amount17 = 0 and amount18 = 0 and amount19 = 0 and amount20 = 0
	-- 描述
	update statistic_p set grp_descript = a.grp_descript, grp_descript1 = a.grp_descript1, grp_sequence = a.grp_sequence,
		code_descript = a.code_descript, code_descript1 = a.code_descript1, code_sequence = a.code_sequence
		from statistic_c a where statistic_p.pc_id = @pc_id and statistic_p.cat = a.cat and statistic_p.grp = a.grp and statistic_p.code = a.code
		and a.bdate = (select max(b.bdate) from statistic_c b where b.cat = a.cat and b.grp = a.grp and b.code = a.code and b.bdate <= @lastday)
	-- 需要计算的指标
	if exists (select 1 from statistic_i a, statistic_p b where b.pc_id = @pc_id and rtrim(b.cat) + '_' + b.code = a.cat)
		begin
		select b.year, b.cat, b.grp, b.code, a.operator, a.cat1, a.cat2, a.display into #statistic_p
			from statistic_i a, statistic_p b where b.pc_id = @pc_id and rtrim(b.cat) + '_' + b.code = a.cat
		declare c_compute2 cursor for select year, cat, grp, code, operator, cat1, cat2, display from #statistic_p
		open c_compute2
		fetch c_compute2 into @year, @cat, @grp, @code, @operator, @cat1, @cat2, @display
		while @@sqlstatus = 0
			begin
			update statistic_p set display = @display where pc_id = @pc_id and year = @year and cat = @cat and grp = @grp and code = @code
			if not rtrim(@cat1) is null and not rtrim(@cat1) is null
				exec p_gl_statistic_operator @pc_id, @year, @cat, @grp, @code, @cat1, @cat2, @operator, 'code'
			fetch c_compute2 into @year, @cat, @grp, @code, @operator, @cat1, @cat2, @display
			end
		close c_compute2
		deallocate cursor c_compute2
		end
	end
if charindex('withreturn', @para3) > 0
	select @para3 = @para3
else if @item = 'code' and @langid = 0
	select grp_descript, code, code_descript, amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10,
		amount11, amount12, amount13, amount14, amount15, amount16, amount17, amount18, amount19, amount20
		from statistic_p where pc_id = @pc_id and display = 'T' order by grp_sequence, grp, code_sequence, code
else if @item = 'code'
	select grp_descript1, code, code_descript1, amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10,
		amount11, amount12, amount13, amount14, amount15, amount16, amount17, amount18, amount19, amount20
		from statistic_p where pc_id = @pc_id and display = 'T' order by grp_sequence, grp, code_sequence, code
else if @item = 'grp' and @langid = 0
	select grp_sequence, grp, grp_descript, sum(amount01), sum(amount02), sum(amount03), sum(amount04), sum(amount05), sum(amount06),
		sum(amount07), sum(amount08), sum(amount09), sum(amount10), sum(amount11), sum(amount12), sum(amount13), sum(amount14),
		sum(amount15), sum(amount16), sum(amount17), sum(amount18), sum(amount19), sum(amount20)
		from statistic_p where pc_id = @pc_id and display = 'T' group by grp_sequence, grp, grp_descript
else if @item = 'grp'
	select grp_sequence, grp, grp_descript1, sum(amount01), sum(amount02), sum(amount03), sum(amount04), sum(amount05), sum(amount06),
		sum(amount07), sum(amount08), sum(amount09), sum(amount10), sum(amount11), sum(amount12), sum(amount13), sum(amount14),
		sum(amount15), sum(amount16), sum(amount17), sum(amount18), sum(amount19), sum(amount20)
		from statistic_p where pc_id = @pc_id and display = 'T' order by grp_sequence, grp, grp_descript1
else if @item = 'year_code' and @langid = 0
	select grp_descript, code, code_descript, cat_descript, amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10,
		amount11, amount12, amount13, amount14, amount15, amount16, amount17, amount18, amount19, amount20
		from statistic_p where pc_id = @pc_id and display = 'T' order by grp_sequence, grp, code_sequence, code, cat_sequence
else if @item = 'year_code'
	select grp_descript1, code, code_descript1, cat_descript1, amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10,
		amount11, amount12, amount13, amount14, amount15, amount16, amount17, amount18, amount19, amount20
		from statistic_p where pc_id = @pc_id and display = 'T' order by grp_sequence, grp, code_sequence, code, cat_sequence
else if @item = 'year_grp' and @langid = 0
	select grp_sequence, grp, grp_descript, cat_descript, sum(amount01), sum(amount02), sum(amount03), sum(amount04), sum(amount05), sum(amount06),
		sum(amount07), sum(amount08), sum(amount09), sum(amount10), sum(amount11), sum(amount12), sum(amount13), sum(amount14),
		sum(amount15), sum(amount16), sum(amount17), sum(amount18), sum(amount19), sum(amount20)
		from statistic_p where pc_id = @pc_id and display = 'T' group by grp_sequence, grp, grp_descript, cat_descript
else if @item = 'year_grp'
	select grp_sequence, grp, grp_descript1, cat_descript1, sum(amount01), sum(amount02), sum(amount03), sum(amount04), sum(amount05), sum(amount06),
		sum(amount07), sum(amount08), sum(amount09), sum(amount10), sum(amount11), sum(amount12), sum(amount13), sum(amount14),
		sum(amount15), sum(amount16), sum(amount17), sum(amount18), sum(amount19), sum(amount20)
		from statistic_p where pc_id = @pc_id and display = 'T' order by grp_sequence, grp, grp_descript1, cat_descript
else if @item = 'code_all' and @langid = 0
	select c.descript as des1, b.code, b.descript as des2, amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10,
		amount11, amount12, amount13, amount14, amount15, amount16, amount17, amount18, amount19, amount20
		from statistic_p a,mktcode b,basecode c where a.pc_id = @pc_id and a.display = 'T' and b.code*=a.code and c.cat='market_cat' and c.code=b.grp order by c.sequence, c.code, b.sequence, b.code
else if @item = 'code_all'
	select c.descript1 as des1, b.code, b.descript1 as des2, amount01, amount02, amount03, amount04, amount05, amount06, amount07, amount08, amount09, amount10,
		amount11, amount12, amount13, amount14, amount15, amount16, amount17, amount18, amount19, amount20
		from statistic_p a,mktcode b,basecode c where a.pc_id = @pc_id and a.display = 'T' and b.code*=a.code and c.cat='market_cat' and c.code=b.grp order by c.sequence, c.code, b.sequence, b.code
else if @item = 'grp_all' and @langid = 0
	select c.sequence, c.code, c.descript as des2, sum(amount01) as amt01, sum(amount02) as amt02, sum(amount03) as amt03, sum(amount04) as amt04, sum(amount05) as amt05, sum(amount06) as amt06,
		sum(amount07) as amt07, sum(amount08) as amt08, sum(amount09) as amt09, sum(amount10) as amt10, sum(amount11) as amt11, sum(amount12) as amt12, sum(amount13) as amt13, sum(amount14) as amt14,
		sum(amount15) as amt15, sum(amount16) as amt16, sum(amount17) as amt17, sum(amount18) as amt18, sum(amount19) as amt19, sum(amount20) as amt20
		from statistic_p a,basecode c where pc_id = @pc_id and a.display = 'T' and c.cat='market_cat' and c.code*=a.grp group by c.sequence, c.code, c.descript
else if @item = 'grp_all'
	select c.sequence, c.code, c.descript1 as des2, sum(amount01) as amt01, sum(amount02) as amt02, sum(amount03) as amt03, sum(amount04) as amt04, sum(amount05) as amt05, sum(amount06) as amt06,
		sum(amount07) as amt07, sum(amount08) as amt08, sum(amount09) as amt09, sum(amount10) as amt10, sum(amount11) as amt11, sum(amount12) as amt12, sum(amount13) as amt13, sum(amount14) as amt14,
		sum(amount15) as amt15, sum(amount16) as amt16, sum(amount17) as amt17, sum(amount18) as amt18, sum(amount19) as amt19, sum(amount20) as amt20
		from statistic_p a,basecode c where pc_id = @pc_id and a.display = 'T' and c.cat='market_cat' and c.code*=a.grp group by c.sequence, c.code, c.descript1


return 0
;