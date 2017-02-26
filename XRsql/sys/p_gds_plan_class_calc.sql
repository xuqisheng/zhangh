
if exists (select * from sysobjects where name  = 'p_gds_plan_class_calc' and type = 'P')
	drop proc p_gds_plan_class_calc;
create proc p_gds_plan_class_calc
	@cat				varchar(30),
	@owner			varchar(30),
	@type				char(1),
	@period			varchar(30)
as
------------------------------------------------------------------------------------------
--	plan_def 输入以后，调用该过程，有多个作用：
--		1、表内关联计算：自动计算出所有的计算项目，比如（+, -, /, %）；
--		2、plan相关表处理：比如输入月数据后，自动产生年数据；
--		3、更新其他相关表。比如 plan_def 更新后，需要自动处理 jourrep 表的 pmonth, pyear 
------------------------------------------------------------------------------------------
declare 
	@clskey			varchar(30),
	@class			varchar(30),
	@toop				char(2), 
	@toop1			char(2), 
	@toclass1		varchar(60), 
	@toclass2		varchar(60), 

	@amount1			money, @amount11			money, @amount12			money, 
	@amount2			money, @amount21			money, @amount22			money, 
	@amount3			money, @amount31			money, @amount32			money, 
	@amount4			money, @amount41			money, @amount42			money, 
	@amount5			money, @amount51			money, @amount52			money, 
	@amount6			money, @amount61			money, @amount62			money, 
	@amount7			money, @amount71			money, @amount72			money, 
	@amount8			money, @amount81			money, @amount82			money

----------------------------
--		1、表内关联计算
----------------------------
-- Init data 
update plan_def set amount1=0, amount2=0, amount3=0, amount4=0, amount5=0, amount6=0, amount7=0, amount8=0
	from plan_code b 
		where plan_def.cat=@cat and plan_def.owner=@owner and plan_def.type=@type and plan_def.period=@period
			and plan_def.cat=b.cat and plan_def.clskey=b.clskey and plan_def.class=b.class and b.rectype <> 'B' 

-- 累计项处理 
declare j_cursor cursor for select b.toop, b.toclass1, a.amount1, a.amount2, a.amount3, a.amount4, a.amount5, a.amount6, a.amount7, a.amount8 
	from plan_def a, plan_code b 
		where a.cat=@cat and a.owner=@owner and a.type=@type and a.period=@period and b.rectype = 'B' 
			and a.cat=b.cat and a.clskey=b.clskey and a.class=b.class 
		order by a.clskey, a.class
open j_cursor
fetch	j_cursor into @toop, @toclass1, @amount1, @amount2, @amount3, @amount4, @amount5, @amount6, @amount7, @amount8 
while @@sqlstatus = 0
	begin 
	while rtrim(@toclass1) is not null
		begin
		if @toop = '-' 
			update plan_def set 	amount1=amount1-@amount1, amount2=amount2-@amount2, amount3=amount3-@amount3, amount4=amount4-@amount4, 
										amount5=amount5-@amount5, amount6=amount6-@amount6, amount7=amount7-@amount7, amount8=amount8-@amount8 
				where cat=@cat and owner=@owner and type=@type and period=@period and clskey+class = @toclass1
		else
			update plan_def set 	amount1=amount1+@amount1, amount2=amount2+@amount2, amount3=amount3+@amount3, amount4=amount4+@amount4, 
										amount5=amount5+@amount5, amount6=amount6+@amount6, amount7=amount7+@amount7, amount8=amount8+@amount8 
				where cat=@cat and owner=@owner and type=@type and period=@period and clskey+class = @toclass1
		select @toclass1 = toclass1, @toop1 = toop from plan_code where cat=@cat and clskey+class = @toclass1
		if @@rowcount = 0
			select @toclass1 = null
		if @toop <> @toop1
			select @toop = '-'
		else
			select @toop = '+'
		end
	fetch	j_cursor into @toop, @toclass1, @amount1, @amount2, @amount3, @amount4, @amount5, @amount6, @amount7, @amount8 
	end
close j_cursor
deallocate cursor j_cursor

-- 处理 /, %
declare j_cursor cursor for 
	select b.toop, a.clskey, a.class, b.toclass1, b.toclass2, 
			a.amount1, a.amount2, a.amount3, a.amount4, a.amount5, a.amount6, a.amount7, a.amount8
		 from plan_def a, plan_code b 
			where a.cat=@cat and a.owner=@owner and a.type=@type and a.period=@period 
				and a.cat=b.cat and a.clskey=b.clskey and a.class=b.class 
				and (b.toop = '/' or b.toop = '%')
			order by a.clskey, a.class
open	 j_cursor
fetch	j_cursor into @toop, @clskey, @class, @toclass1, @toclass2, 
			@amount1, @amount2, @amount3, @amount4, @amount5, @amount6, @amount7, @amount8
while @@sqlstatus = 0
	begin 
	select @amount11=amount1, @amount21=amount2, @amount31=amount3, @amount41=amount4, @amount51=amount5, @amount61=amount6, @amount71=amount7, @amount81=amount8 
		from plan_def where cat=@cat and owner=@owner and type=@type and period=@period and clskey+class = @toclass1
	select @amount12=amount1, @amount22=amount2, @amount32=amount3, @amount42=amount4, @amount52=amount5, @amount62=amount6, @amount72=amount7, @amount82=amount8 
		from plan_def where cat=@cat and owner=@owner and type=@type and period=@period and clskey+class = @toclass2

	-- amount1
	if @amount11 is not null and @amount12 is not null and @amount12 <> 0 
		begin
		if @toop = '/' 
			update plan_def set amount1 = round(@amount11 / @amount12, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		else
			update plan_def set amount1 = round(@amount11 * 100 / @amount12, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		end

	-- amount2
	if @amount21 is not null and @amount22 is not null and @amount22 <> 0 
		begin
		if @toop = '/' 
			update plan_def set amount2 = round(@amount21 / @amount22, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		else
			update plan_def set amount2 = round(@amount21 * 100 / @amount22, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		end

	-- amount3
	if @amount31 is not null and @amount32 is not null and @amount32 <> 0 
		begin
		if @toop = '/' 
			update plan_def set amount3 = round(@amount31 / @amount32, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		else
			update plan_def set amount3 = round(@amount31 * 100 / @amount32, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		end

	-- amount4
	if @amount41 is not null and @amount42 is not null and @amount42 <> 0 
		begin
		if @toop = '/' 
			update plan_def set amount4 = round(@amount41 / @amount42, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		else
			update plan_def set amount4 = round(@amount41 * 100 / @amount42, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		end

	-- amount5
	if @amount51 is not null and @amount52 is not null and @amount52 <> 0 
		begin
		if @toop = '/' 
			update plan_def set amount5 = round(@amount51 / @amount52, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		else
			update plan_def set amount5 = round(@amount51 * 100 / @amount52, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		end

	-- amount6
	if @amount61 is not null and @amount62 is not null and @amount62 <> 0 
		begin
		if @toop = '/' 
			update plan_def set amount6 = round(@amount61 / @amount62, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		else
			update plan_def set amount6 = round(@amount61 * 100 / @amount62, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		end

	-- amount7
	if @amount71 is not null and @amount72 is not null and @amount72 <> 0 
		begin
		if @toop = '/' 
			update plan_def set amount7 = round(@amount71 / @amount72, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		else
			update plan_def set amount7 = round(@amount71 * 100 / @amount72, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		end

	-- amount8
	if @amount81 is not null and @amount82 is not null and @amount82 <> 0 
		begin
		if @toop = '/' 
			update plan_def set amount8 = round(@amount81 / @amount82, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		else
			update plan_def set amount8 = round(@amount81 * 100 / @amount82, 2) where cat=@cat and owner=@owner and type=@type and period=@period and clskey=@clskey and class = @class
		end

	fetch	j_cursor into @toop, @clskey, @class, @toclass1, @toclass2, 
				@amount1, @amount2, @amount3, @amount4, @amount5, @amount6, @amount7, @amount8
	end
close j_cursor
deallocate cursor j_cursor

----------------------------
--		2、plan相关表处理
----------------------------
-- 脚本如下 ...... 



----------------------------
--		3、更新其他相关表
----------------------------
-- 脚本如下 ...... 




return 0
;
