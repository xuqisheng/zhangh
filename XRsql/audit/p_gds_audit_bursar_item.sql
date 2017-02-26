IF OBJECT_ID('p_gds_audit_bursar_item') IS NOT NULL
    DROP PROCEDURE p_gds_audit_bursar_item
;
create proc p_gds_audit_bursar_item
	@date		datetime,
	@src		char(10),
	@classes	varchar(255),
	@value	money		output
as
------------------------------------------------------------
-- 凭证数值的单项取值
------------------------------------------------------------
--	@classes 的格式统一为 ＋class；＋class ：tail；
--			分号没有的时候，主动解析，取得缺省数值
------------------------------------------------------------
declare	@mode			char(1),
			@class		varchar(20),
			@tail			varchar(20),
			@amount		money,
			@pos			int

-- Init 
select @value = 0
if @date is null
	select @date = bdate from accthead
select @src = isnull(@src, '')
select @classes = isnull(ltrim(rtrim(@classes)), '')

-- 分解 classes 
select @pos = charindex(';', @classes)
while @pos > 0
begin
	select @class = substring(@classes, 1, @pos - 1)
	select @classes = isnull(ltrim(stuff(@classes, 1, @pos, '')), '')

	select @mode = substring(@class, 1, 1)
	select @class = isnull(ltrim(stuff(@class, 1, 1, '')), '')

	-- Get data 
	---------------------------------------------------------------
	if @src = 'jierep'
	---------------------------------------------------------------
	begin
		select @pos = charindex(':', @class)
		if @pos = 0 
			select @tail = 'day99' 
		else
		begin
			select @tail = isnull(substring(@class, @pos+1, char_length(@class)-@pos), '')
			select @class = substring(@class, 1, @pos-1)
		end
		
		if @tail = 'day01'
			select @amount = isnull((select day01 from yjierep where date=@date and class=@class), 0)
		else if @tail = 'day02'
			select @amount = isnull((select day02 from yjierep where date=@date and class=@class), 0)
		else if @tail = 'day03'
			select @amount = isnull((select day03 from yjierep where date=@date and class=@class), 0)
		else if @tail = 'day04'
			select @amount = isnull((select day04 from yjierep where date=@date and class=@class), 0)
		else if @tail = 'day05'
			select @amount = isnull((select day05 from yjierep where date=@date and class=@class), 0)
		else if @tail = 'day06'
			select @amount = isnull((select day06 from yjierep where date=@date and class=@class), 0)
		else if @tail = 'day07'
			select @amount = isnull((select day07 from yjierep where date=@date and class=@class), 0)
		else if @tail = 'day08'
			select @amount = isnull((select day08 from yjierep where date=@date and class=@class), 0)
		else if @tail = 'day09'
			select @amount = isnull((select day09 from yjierep where date=@date and class=@class), 0)
		else if @tail = 'day99'
			select @amount = isnull((select day99 from yjierep where date=@date and class=@class), 0)
		else
			select @amount = isnull((select day99 from yjierep where date=@date and class=@class), 0)

	end
	---------------------------------------------------------------
	else if @src = 'dairep'
	---------------------------------------------------------------
	begin
		select @pos = charindex(':', @class)
		if @pos = 0 
			select @tail = 'sumcre' 
		else
		begin
			select @tail = isnull(substring(@class, @pos+1, char_length(@class)-@pos), '')
			select @class = substring(@class, 1, @pos-1)
		end
		
		if @tail = 'credit01'
			select @amount = isnull((select credit01 from ydairep where date=@date and class=@class), 0)
		else if @tail = 'credit02'
			select @amount = isnull((select credit02 from ydairep where date=@date and class=@class), 0)
		else if @tail = 'credit03'
			select @amount = isnull((select credit03 from ydairep where date=@date and class=@class), 0)
		else if @tail = 'credit04'
			select @amount = isnull((select credit04 from ydairep where date=@date and class=@class), 0)
		else if @tail = 'credit05'
			select @amount = isnull((select credit05 from ydairep where date=@date and class=@class), 0)
		else if @tail = 'credit06'
			select @amount = isnull((select credit06 from ydairep where date=@date and class=@class), 0)
		else if @tail = 'credit07'
			select @amount = isnull((select credit07 from ydairep where date=@date and class=@class), 0)
		else if @tail = 'sumcre'
			select @amount = isnull((select sumcre from ydairep where date=@date and class=@class), 0)
		else if @tail = 'last_bl'
			select @amount = isnull((select last_bl from ydairep where date=@date and class=@class), 0)
		else if @tail = 'debit'
			select @amount = isnull((select debit from ydairep where date=@date and class=@class), 0)
		else if @tail = 'credit'
			select @amount = isnull((select credit from ydairep where date=@date and class=@class), 0)
		else if @tail = 'till_bl'
			select @amount = isnull((select till_bl from ydairep where date=@date and class=@class), 0)
		else 
			select @amount = isnull((select sumcre from ydairep where date=@date and class=@class), 0)

	end
	---------------------------------------------------------------
	else if @src = 'deptjie'
	---------------------------------------------------------------
	begin
		select @pos = charindex(':', @class)
		if @pos = 0 
			select @tail = '999' 
		else
		begin
			select @tail = isnull(substring(@class, @pos+1, char_length(@class)-@pos), '')
			select @class = substring(@class, 1, @pos-1)
		end
		select @amount = isnull((select feed from ydeptjie where date=@date and pccode=@class and code=@tail and shift='9' and empno='{{{'), 0)

	end
	---------------------------------------------------------------
	else if @src = 'deptdai'
	---------------------------------------------------------------
	begin
		select @pos = charindex(':', @class)
		if @pos = 0 
			select @tail = 'D99' 
		else
		begin
			select @tail = isnull(substring(@class, @pos+1, char_length(@class)-@pos), '')
			select @class = substring(@class, 1, @pos-1)
		end
		select @amount = isnull((select creditd from ydeptdai where date=@date and pccode=@class and paycode=@tail and shift='9' and empno='{{{'), 0)

	end
	---------------------------------------------------------------
	else if @src = 'cus_xf'
	---------------------------------------------------------------
	begin
		select @pos = charindex(':', @class)
		if @pos = 0 
			select @tail = 'dtl' 
		else
		begin
			select @tail = isnull(substring(@class, @pos+1, char_length(@class)-@pos), '')
			select @class = substring(@class, 1, @pos-1)
		end
		if @tail='lastbl'
			select @amount = isnull((select lastbl from ycus_xf where date=@date and accnt=@class), 0)
		else if @tail='dtl'
			select @amount = isnull((select dtl from ycus_xf where date=@date and accnt=@class), 0)
		else if @tail='ctl'
			select @amount = isnull((select ctl from ycus_xf where date=@date and accnt=@class), 0)
		else if @tail='tillbl'
			select @amount = isnull((select tillbl from ycus_xf where date=@date and accnt=@class), 0)
		else
			select @amount = isnull((select dtl from ycus_xf where date=@date and accnt=@class), 0)

	end
	---------------------------------------------------------------
	else if @src = 'pccode9'
	---------------------------------------------------------------
	begin
		select @amount = 0
	end
	---------------------------------------------------------------
	else if @src = 'impdata'  -- yaudit_impdata 
	---------------------------------------------------------------
		select @amount = isnull((select amount from yaudit_impdata where date=@date and class=@class), 0)


	-- 累加
	if @mode = '+'
		select @value = @value + @amount
	else
		select @value = @value - @amount

	select @pos = charindex(';', @classes)
end


return 0
;



---------------------------------------------------------------
-- 测试代码
---------------------------------------------------------------
//declare @value money
//exec p_gds_audit_bursar_item  '2005.1.10', 'jierep', '+010;+020010:day07;', @value out
//exec p_gds_audit_bursar_item  '2005.1.10', 'deptdai', '+222:C01;', @value out
//delete gdsmsg
//insert gdsmsg select convert(char(20), @value)
//;
//select * from gdsmsg;
//