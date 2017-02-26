if exists(select 1 from sysobjects where name ='p_gl_pos_get_serve' and type ='P')
	drop proc p_gl_pos_get_serve;
create proc p_gl_pos_get_serve
	@deptno		char(5),
	@pccode		char(5),
	@code			char(3),
	@plucode		char(15),
	@amount0		money,			  -- 原价
	@amount1		money,           -- 模式优惠额
	@amount2		money,           -- 餐单优惠额
	@menu_rate	money,
	@result0		money	output,    -- 优惠前服务费
	@result1		money	output,    -- 模式优惠服务费额
	@result2		money	output     -- 餐单优惠服务费额
as
-----------------------------------------------------------------------
--
--		pos_detail 中调用
--
-----------------------------------------------------------------------
declare
	@mode			char(1),
	@rate			money,
	@amount		money,
	@deptcode	char(4)
select @result1 = 0,@result2 = 0,@amount = @amount0 - @amount1 - @amount2
select @deptcode = max(deptcode) from pos_mode_def
 where code = @code and type= '2' and @deptno + @pccode like rtrim(deptcode) + '%'
		 and @plucode like rtrim(plucode) + '%'
if @deptcode is not null
	select @mode = mode,@rate = rate from pos_mode_def
	 where code = @code and type = '2' and deptcode = @deptcode and
			 plucode = (select max(plucode) from pos_mode_def where code = @code and type = '2'
			 and deptcode = @deptcode and @plucode like rtrim(plucode) + '%')
if @mode = 'A'   -- 以模式服务费率为准
	select @result0 = @amount0 * @rate
else if @mode = 'B'  -- 以菜单服务费率为准
	select @result0 = @amount0 * @menu_rate
else if @mode = 'C' -- 以较大的服务费率为准
	if @menu_rate > @rate
		select @result0 = @amount0 * @menu_rate
	else
		select @result0 = @amount0 * @rate
else if @mode = 'D'  -- 以较小的服务费率为准
	if @menu_rate < @rate
		select @result0 = @amount0 * @menu_rate
	else
		select @result0 = @amount0 * @rate
else if @mode = 'E'  -- 以模式服务费率为准(优惠服务费)
	begin
	select @result0 = @amount0 * @rate
	select @result1 = round(@amount1 * @rate,2)
	select @result2 = @result0 - round(@amount * @rate,2) - @result1
	end
else if @mode = 'F'  -- 以菜单服务费率为准(优惠服务费)
	begin
	select @result0 = @amount0 * @menu_rate
	select @result1 = round(@amount1 * @menu_rate,2)
	select @result2 = @result0 - round(@amount * @menu_rate,2) - @result1
	end
else if @mode = 'G'  -- 以较大的服务费率为准(优惠服务费)
	if @menu_rate > @rate
		begin
		select @result0 = @amount0 * @menu_rate
		select @result1 = round(@amount1 * @menu_rate,2)
		select @result2 = @result0 - round(@amount * @menu_rate,2) - @result1
		end
	else
		begin
		select @result0 = @amount0 * @rate
		select @result1 = round(@amount1 * @rate,2)
		select @result2 = @result0 -round(@amount * @rate,2) - @result1
		end
else if @mode = 'H'  -- 以较小的服务费率为准(优惠服务费)
	if @menu_rate < @rate
		begin
		select @result0 = @amount0 * @menu_rate
		select @result1 = round(@amount1 * @menu_rate,2)
		select @result2 = @result0 - round(@amount * @menu_rate,2) - @result1
		end
	else
		begin
		select @result0 = @amount0 * @rate
		select @result1 = round(@amount1 * @rate,2)
		select @result2 = @result0 - round(@amount * @rate,2) - @result1
		end
else if @mode = 'I' -- 优惠服务费, 不收服务费，服务费全部优惠
	begin
	select @result0 = @amount0 * @menu_rate
--	select @result1 = round(@amount1 * @menu_rate,2)
	select @result1 = round(@amount0 * @menu_rate,2)
--	select @result2 = @result0 - round(@amount * @menu_rate,2) - @result1
	select @result2 = @result0 - round(@amount * @menu_rate,2) 
	end
else
	select @result0 = 0, @result1 = 0, @result2 = 0
return 0
;

