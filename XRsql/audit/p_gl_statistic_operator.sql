if exists (select * from sysobjects where name ='p_gl_statistic_operator' and type ='P')
	drop proc p_gl_statistic_operator;
create proc p_gl_statistic_operator
	@pc_id				char(4), 
	@year					integer,
	@cat					char(30),
	@grp					char(10),
	@code					char(10),
	@para1				varchar(255),				-- revenus_room,revenus_service,-revenus_package (注意:只能有+,-或者没有)
	@para2 				varchar(255),				-- rooms_occupancy (注意:只能有+,-或者没有)
	@operator			char(1),						-- 只能有*,/,没有表示+
	@option				char(10) = 'cat'
as
declare
	@key					varchar(30),
	@cat1					char(30),
	@grp1					char(10),
	@code1				char(10),
	@operator1			money,
	@operator2			money,
	@amount01			money,
	@amount02			money,
	@amount03			money,
	@amount04			money,
	@amount05			money,
	@amount06			money,
	@amount07			money,
	@amount08			money,
	@amount09			money,
	@amount10			money,
	@amount11			money,
	@amount12			money,
	@amount13			money,
	@amount01_1			money,
	@amount02_1			money,
	@amount03_1			money,
	@amount04_1			money,
	@amount05_1			money,
	@amount06_1			money,
	@amount07_1			money,
	@amount08_1			money,
	@amount09_1			money,
	@amount10_1			money,
	@amount11_1			money,
	@amount12_1			money,
	@amount13_1			money,
	@amount01_2			money,
	@amount02_2			money,
	@amount03_2			money,
	@amount04_2			money,
	@amount05_2			money,
	@amount06_2			money,
	@amount07_2			money,
	@amount08_2			money,
	@amount09_2			money,
	@amount10_2			money,
	@amount11_2			money,
	@amount12_2			money,
	@amount13_2			money,
	@pos					integer

select @amount01 = 0, @amount02 = 0, @amount03 = 0, @amount04 = 0, @amount05 = 0, @amount06 = 0,
	@amount07 = 0, @amount08 = 0, @amount09 = 0, @amount10 = 0, @amount11 = 0, @amount12 = 0, @amount13 = 0,
	@amount01_1 = 0, @amount02_1 = 0, @amount03_1 = 0, @amount04_1 = 0, @amount05_1 = 0, @amount06_1 = 0,
	@amount07_1 = 0, @amount08_1 = 0, @amount09_1 = 0, @amount10_1 = 0, @amount11_1 = 0, @amount12_1 = 0, @amount13_1 = 0,
	@amount01_2 = 0, @amount02_2 = 0, @amount03_2 = 0, @amount04_2 = 0, @amount05_2 = 0, @amount06_2 = 0,
	@amount07_2 = 0, @amount08_2 = 0, @amount09_2 = 0, @amount10_2 = 0, @amount11_2 = 0, @amount12_2 = 0, @amount13_2 = 0
select @cat1 = @cat, @grp1 = @grp, @code1 = @code
-- Para 1
while not rtrim(@para1) is null
	begin
	-- 分解para
	select @pos = charindex(',', @para1)
	if @pos = 0
		select @key = @para1, @para1 = ''
	else
		select @key = substring(@para1, 1, @pos - 1), @para1 = substring(@para1, @pos + 1, 255)
	if substring(@key, 1, 1) = '-'
		select @key = substring(@key, 2, 30), @operator1 = -1.0
	else if substring(@key, 1, 1) = '+'
		select @key = substring(@key, 2, 30), @operator1 = 1.0
	else
		select @operator1 = 1.0
	--
	if @option = 'code'
		select @code1 = @key
	else if @option = 'grp'
		select @grp1 = @key
	else
		select @cat1 = @key
	-- 分解cat
	if @grp = '{{{'
		select @amount01_1 = @amount01_1 + @operator1 * isnull(sum(amount01), 0), @amount02_1 = @amount02_1 + @operator1 * isnull(sum(amount02), 0), 
			@amount03_1 = @amount03_1 + @operator1 * isnull(sum(amount03), 0), @amount04_1 = @amount04_1 + @operator1 * isnull(sum(amount04), 0), 
			@amount05_1 = @amount05_1 + @operator1 * isnull(sum(amount05), 0), @amount06_1 = @amount06_1 + @operator1 * isnull(sum(amount06), 0), 
			@amount07_1 = @amount07_1 + @operator1 * isnull(sum(amount07), 0), @amount08_1 = @amount08_1 + @operator1 * isnull(sum(amount08), 0), 
			@amount09_1 = @amount09_1 + @operator1 * isnull(sum(amount09), 0), @amount10_1 = @amount10_1 + @operator1 * isnull(sum(amount10), 0), 
			@amount11_1 = @amount11_1 + @operator1 * isnull(sum(amount11), 0), @amount12_1 = @amount12_1 + @operator1 * isnull(sum(amount12), 0), 
			@amount13_1 = @amount13_1 + @operator1 * isnull(sum(amount13), 0)
			from statistic_p where pc_id = @pc_id and year = @year and cat like @cat1
	else if @code = '{{{'
		select @amount01_1 = @amount01_1 + @operator1 * isnull(sum(amount01), 0), @amount02_1 = @amount02_1 + @operator1 * isnull(sum(amount02), 0), 
			@amount03_1 = @amount03_1 + @operator1 * isnull(sum(amount03), 0), @amount04_1 = @amount04_1 + @operator1 * isnull(sum(amount04), 0), 
			@amount05_1 = @amount05_1 + @operator1 * isnull(sum(amount05), 0), @amount06_1 = @amount06_1 + @operator1 * isnull(sum(amount06), 0), 
			@amount07_1 = @amount07_1 + @operator1 * isnull(sum(amount07), 0), @amount08_1 = @amount08_1 + @operator1 * isnull(sum(amount08), 0), 
			@amount09_1 = @amount09_1 + @operator1 * isnull(sum(amount09), 0), @amount10_1 = @amount10_1 + @operator1 * isnull(sum(amount10), 0), 
			@amount11_1 = @amount11_1 + @operator1 * isnull(sum(amount11), 0), @amount12_1 = @amount12_1 + @operator1 * isnull(sum(amount12), 0), 
			@amount13_1 = @amount13_1 + @operator1 * isnull(sum(amount13), 0)
			from statistic_p where pc_id = @pc_id and year = @year and cat like @cat1 and grp like @grp1
	else
		select @amount01_1 = @amount01_1 + @operator1 * amount01, @amount02_1 = @amount02_1 + @operator1 * amount02, 
			@amount03_1 = @amount03_1 + @operator1 * amount03, @amount04_1 = @amount04_1 + @operator1 * amount04, 
			@amount05_1 = @amount05_1 + @operator1 * amount05, @amount06_1 = @amount06_1 + @operator1 * amount06, 
			@amount07_1 = @amount07_1 + @operator1 * amount07, @amount08_1 = @amount08_1 + @operator1 * amount08, 
			@amount09_1 = @amount09_1 + @operator1 * amount09, @amount10_1 = @amount10_1 + @operator1 * amount10, 
			@amount11_1 = @amount11_1 + @operator1 * amount11, @amount12_1 = @amount12_1 + @operator1 * amount12, 
			@amount13_1 = @amount13_1 + @operator1 * amount13
			from statistic_p where pc_id = @pc_id and year = @year and cat like @cat1 and grp like @grp1 and code like @code1
	end
-- Para 2
while not rtrim(@para2) is null
	begin
	-- 分解para
	select @pos = charindex(',', @para2)
	if @pos = 0
		select @key = @para2, @para2 = ''
	else
		select @key = substring(@para2, 1, @pos - 1), @para2 = substring(@para2, @pos + 1, 255)
	if substring(@key, 1, 1) = '-'
		select @key = substring(@key, 2, 30), @operator1 = -1
	else if substring(@key, 1, 1) = '+'
		select @key = substring(@key, 2, 30), @operator1 = 1
	else
		select @operator2 = 1.0
	--
	if @option = 'code'
		select @code1 = @key
	else if @option = 'grp'
		select @grp1 = @key
	else
		select @cat1 = @key
	-- 分解cat
	if @grp = '{{{'
		select @amount01_2 = @amount01_2 + @operator2 * isnull(sum(amount01), 0), @amount02_2 = @amount02_2 + @operator2 * isnull(sum(amount02), 0), 
			@amount03_2 = @amount03_2 + @operator2 * isnull(sum(amount03), 0), @amount04_2 = @amount04_2 + @operator2 * isnull(sum(amount04), 0), 
			@amount05_2 = @amount05_2 + @operator2 * isnull(sum(amount05), 0), @amount06_2 = @amount06_2 + @operator2 * isnull(sum(amount06), 0), 
			@amount07_2 = @amount07_2 + @operator2 * isnull(sum(amount07), 0), @amount08_2 = @amount08_2 + @operator2 * isnull(sum(amount08), 0), 
			@amount09_2 = @amount09_2 + @operator2 * isnull(sum(amount09), 0), @amount10_2 = @amount10_2 + @operator2 * isnull(sum(amount10), 0), 
			@amount11_2 = @amount11_2 + @operator2 * isnull(sum(amount11), 0), @amount12_2 = @amount12_2 + @operator2 * isnull(sum(amount12), 0), 
			@amount13_2 = @amount13_2 + @operator2 * isnull(sum(amount13), 0)
			from statistic_p where pc_id = @pc_id and year = @year and cat like @cat1
	else if @code = '{{{'
		select @amount01_2 = @amount01_2 + @operator2 * isnull(sum(amount01), 0), @amount02_2 = @amount02_2 + @operator2 * isnull(sum(amount02), 0), 
			@amount03_2 = @amount03_2 + @operator2 * isnull(sum(amount03), 0), @amount04_2 = @amount04_2 + @operator2 * isnull(sum(amount04), 0), 
			@amount05_2 = @amount05_2 + @operator2 * isnull(sum(amount05), 0), @amount06_2 = @amount06_2 + @operator2 * isnull(sum(amount06), 0), 
			@amount07_2 = @amount07_2 + @operator2 * isnull(sum(amount07), 0), @amount08_2 = @amount08_2 + @operator2 * isnull(sum(amount08), 0), 
			@amount09_2 = @amount09_2 + @operator2 * isnull(sum(amount09), 0), @amount10_2 = @amount10_2 + @operator2 * isnull(sum(amount10), 0), 
			@amount11_2 = @amount11_2 + @operator2 * isnull(sum(amount11), 0), @amount12_2 = @amount12_2 + @operator2 * isnull(sum(amount12), 0), 
			@amount13_2 = @amount13_2 + @operator2 * isnull(sum(amount13), 0)
			from statistic_p where pc_id = @pc_id and year = @year and cat = @cat1 and grp like @grp1
	else
		select @amount01_2 = @amount01_2 + @operator2 * amount01, @amount02_2 = @amount02_2 + @operator2 * amount02, 
			@amount03_2 = @amount03_2 + @operator2 * amount03, @amount04_2 = @amount04_2 + @operator2 * amount04, 
			@amount05_2 = @amount05_2 + @operator2 * amount05, @amount06_2 = @amount06_2 + @operator2 * amount06, 
			@amount07_2 = @amount07_2 + @operator2 * amount07, @amount08_2 = @amount08_2 + @operator2 * amount08, 
			@amount09_2 = @amount09_2 + @operator2 * amount09, @amount10_2 = @amount10_2 + @operator2 * amount10, 
			@amount11_2 = @amount11_2 + @operator2 * amount11, @amount12_2 = @amount12_2 + @operator2 * amount12, 
			@amount13_2 = @amount13_2 + @operator2 * amount13
			from statistic_p where pc_id = @pc_id and year = @year and cat like @cat1 and grp like @grp1 and code like @code1
	end
-- 计算
select @amount01 = 0, @amount02 = 0, @amount03 = 0, @amount04 = 0, @amount05 = 0, @amount06 = 0, 
	@amount07 = 0, @amount08 = 0, @amount09 = 0, @amount10 = 0, @amount11 = 0, @amount12 = 0, @amount13 = 0
if @operator in ('/', '%')
	begin
	if @amount01_2 != 0
		select @amount01 = @amount01_1 / @amount01_2
	if @amount02_2 != 0
		select @amount02 = @amount02_1 / @amount02_2
	if @amount03_2 != 0
		select @amount03 = @amount03_1 / @amount03_2
	if @amount04_2 != 0
		select @amount04 = @amount04_1 / @amount04_2
	if @amount05_2 != 0
		select @amount05 = @amount05_1 / @amount05_2
	if @amount06_2 != 0
		select @amount06 = @amount06_1 / @amount06_2
	if @amount07_2 != 0
		select @amount07 = @amount07_1 / @amount07_2
	if @amount08_2 != 0
		select @amount08 = @amount08_1 / @amount08_2
	if @amount09_2 != 0
		select @amount09 = @amount09_1 / @amount09_2
	if @amount10_2 != 0
		select @amount10 = @amount10_1 / @amount10_2
	if @amount11_2 != 0
		select @amount11 = @amount11_1 / @amount11_2
	if @amount12_2 != 0
		select @amount12 = @amount12_1 / @amount12_2
	if @amount13_2 != 0
		select @amount13 = @amount13_1 / @amount13_2
	if @operator = '%'
		select @amount01 = @amount01 * 100.00, @amount02 = @amount02 * 100.00, @amount03 = @amount03 * 100.00, @amount04 = @amount04 * 100.00,
			@amount05 = @amount05 * 100.00, @amount06 = @amount06 * 100.00, @amount07 = @amount07 * 100.00, @amount08 = @amount08 * 100.00,
			@amount09 = @amount09 * 100.00, @amount10 = @amount10 * 100.00, @amount11 = @amount11 * 100.00, @amount12 = @amount12 * 100.00, @amount13= @amount13 * 100.00
	end
else if @operator = '*'
	select @amount01 = @amount01_1 * @amount01_2, @amount02 = @amount02_1 * @amount02_2, @amount03 = @amount03_1 * @amount03_2, 
		@amount04 = @amount04_1 * @amount04_2, @amount05 = @amount05_1 * @amount05_2, @amount06 = @amount06_1 * @amount06_2, 
		@amount07 = @amount07_1 * @amount07_2, @amount08 = @amount08_1 * @amount08_2, @amount09 = @amount09_1 * @amount09_2, 
		@amount10 = @amount10_1 * @amount10_2, @amount11 = @amount11_1 * @amount11_2, @amount12 = @amount12_1 * @amount12_2, 
		@amount13 = @amount13_1 * @amount13_2
else
	select @amount01 = @amount01_1 + @amount01_2, @amount02 = @amount02_1 + @amount02_2, @amount03 = @amount03_1 + @amount03_2, 
		@amount04 = @amount04_1 + @amount04_2, @amount05 = @amount05_1 + @amount05_2, @amount06 = @amount06_1 + @amount06_2, 
		@amount07 = @amount07_1 + @amount07_2, @amount08 = @amount08_1 + @amount08_2, @amount09 = @amount09_1 + @amount09_2, 
		@amount10 = @amount10_1 + @amount10_2, @amount11 = @amount11_1 + @amount11_2, @amount12 = @amount12_1 + @amount12_2, 
		@amount13 = @amount13_1 + @amount13_2
update statistic_p set amount01 = @amount01, amount02 = @amount02, amount03 = @amount03, amount04 = @amount04, amount05 = @amount05, 
	amount06 = @amount06, amount07 = @amount07, amount08 = @amount08, amount09 = @amount09, amount10 = @amount10, 
	amount11 = @amount11, amount12 = @amount12, amount13 = @amount13
	where pc_id = @pc_id and year = @year and cat = @cat and grp = @grp and code = @code
;
