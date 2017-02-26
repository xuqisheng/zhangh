/*计算优惠价*/
if exists(select * from sysobjects where name = "p_gl_pos_create_discount")
	drop proc p_gl_pos_create_discount
;

create proc p_gl_pos_create_discount
	@deptno		char(2),
	@pccode		char(3),
	@code			char(3),
	@plucode		char(15),		/*菜号*/
	@amount0		money,			/*原金额*/
	@menu_rate	money,			/*优惠比例*/
	@result		money	output	/*优惠价*/
as
declare
	@mode			char(1),
	@rate			money,
	@deptcode	char(5)       /*deptno + pccode*/
select @deptcode = max(deptcode) from pos_mode_def
 where code = @code and type = '1' and @deptno + @pccode like rtrim(deptcode) + '%'
		 and @plucode like rtrim(plucode) + '%'
if @deptcode is not null
	select @mode = mode,@rate = rate from pos_mode_def
	 where code = @code and type = '1' and deptcode = @deptcode and
			 plucode = (select max(plucode) from pos_mode_def where code = @code and type = '1' and
			 deptcode = @deptcode and @plucode like rtrim(plucode) + '%')
if @mode = 'A'
	select @result = round(@amount0 * (1 - @rate) * (1 - @menu_rate),2)
else if @mode = 'B' and @rate + @menu_rate >= 1
	select @result = 0
else if @mode = 'B'
	select @result = round(@amount0 * (1 - @rate - @menu_rate),2)
else if @mode = 'C'
	select @result = round(@amount0 * (1 - @rate),2)
else if @mode = 'D'
	select @result = round(@amount0 * (1 - @menu_rate),2)
else if @mode = 'E'
	if @menu_rate > @rate
		select @result = round(@amount0 * (1 - @menu_rate),2)
	else
		select @result = round(@amount0 * (1 - @rate),2)
else if @mode = 'F'
	if @menu_rate < @rate
		select @result = round(@amount0 * (1 - @menu_rate),2)
	else
		select @result = round(@amount0 * (1 - @rate),2)
else if @mode = 'G'
	select @result = @amount0
else
	select @result = @amount0
return 0
;

/*计算服务费*/
if exists(select * from sysobjects where name = "p_gl_pos_create_serve")
	drop proc p_gl_pos_create_serve
;

create proc p_gl_pos_create_serve
	@deptno		char(2),
	@pccode		char(3),
	@code			char(3),
	@plucode		char(15),	/*菜号*/
	@amount0		money,		/*原金额*/
	@amount		money,		/*优惠后的金额*/
	@menu_rate	money,		/*MENU中的服务费率*/
	@result0		money	output,		/*原服务费*/
	@result		money	output		/*优惠后的服务费*/
as
declare
	@mode			char(1),
	@rate			money,
	@deptcode	char(5)       /*deptno + pccode*/
select @deptcode = max(deptcode) from pos_mode_def
 where code = @code and type = '2' and @deptno + @pccode like rtrim(deptcode) + '%'
		 and @plucode like rtrim(plucode) + '%'
if @deptcode is not null
	select @mode = mode,@rate = rate from pos_mode_def
	 where code = @code and type = '2' and deptcode = @deptcode and
			 plucode = (select max(plucode) from pos_mode_def where code = @code and type = '2' and
			 deptcode = @deptcode and @plucode like rtrim(plucode) + '%')
if @mode = 'A'
	select @result0 = round(@amount0 * @rate,2),@result = round(@amount0 * @rate,2)
else if @mode = 'B'
	select @result0 = round(@amount0 * @menu_rate,2),@result = round(@amount0 * @menu_rate,2)
else if @mode = 'C'
	if @menu_rate > @rate
		select @result0 = round(@amount0 * @menu_rate,2),@result = round(@amount0 * @menu_rate,2)
	else
		select @result0 = round(@amount0 * @rate,2),@result = round(@amount0 * @rate,2)
else if @mode = 'D'
	if @menu_rate < @rate
		select @result0 = round(@amount0 * @menu_rate,2),@result = round(@amount0 * @menu_rate,2)
	else
		select @result0 = round(@amount0 * @rate,2),@result = round(@amount0 * @rate,2)
else if @mode = 'E'
	select @result0 = round(@amount0 * @rate,2),@result = round(@amount * @rate,2)
else if @mode = 'F'
	select @result0 = round(@amount0 * @menu_rate,2),@result = round(@amount * @menu_rate,2)
else if @mode = 'G'
	if @menu_rate > @rate
		select @result0 = round(@amount0 * @menu_rate,2),@result = round(@amount * @menu_rate,2)
	else
		select @result0 = round(@amount0 * @rate,2),@result = round(@amount * @rate,2)
else if @mode = 'H'
	if @menu_rate < @rate
		select @result0 = round(@amount0 * @menu_rate,2),@result = round(@amount * @menu_rate,2)
	else
		select @result0 = round(@amount0 * @rate,2),@result = round(@amount * @rate,2)
else if @mode = 'I'
	select @result0 = round(@amount0 * @menu_rate,2),@result = 0
else
	select @result0 = 0,@result = 0
return 0
;

/*计算附加费*/
if exists(select * from sysobjects where name = "p_gl_pos_create_tax")
	drop proc p_gl_pos_create_tax
;

create proc p_gl_pos_create_tax
	@deptno		char(2),
	@pccode		char(3),
	@code			char(3),
	@plucode		char(15),	/*菜号*/
	@amount0		money,		/*原金额*/
	@amount		money,		/*优惠后的金额*/
	@menu_rate	money,		/*MENU中的附加费率*/
	@result0		money	output,		/*原附加费*/
	@result		money	output		/*优惠后的附加费*/
as
declare
	@mode			char(1),
	@rate			money,
	@deptcode	char(5)       /*deptno + pccode*/
select @deptcode = max(deptcode) from pos_mode_def
 where code = @code and type = '3' and @deptno + @pccode like rtrim(deptcode) + '%'
		 and @plucode like rtrim(plucode) + '%'
if @deptcode is not null
	select @mode = mode,@rate = rate from pos_mode_def
	 where code = @code and type = '3' and deptcode = @deptcode and
			 plucode = (select max(plucode) from pos_mode_def where code = @code and type = '3' and
			 deptcode = @deptcode and @plucode like rtrim(plucode) + '%')
if @mode = 'A'
	select @result0 = round(@amount0 * @rate,2),@result = round(@amount0 * @rate,2)
else if @mode = 'B'
	select @result0 = round(@amount0 * @menu_rate,2),@result = round(@amount0 * @menu_rate,2)
else if @mode = 'C'
	if @menu_rate > @rate
		select @result0 = round(@amount0 * @menu_rate,2),@result = round(@amount0 * @menu_rate,2)
	else
		select @result0 = round(@amount0 * @rate,2),@result = round(@amount0 * @rate,2)
else if @mode = 'D'
	if @menu_rate < @rate
		select @result0 = round(@amount0 * @menu_rate,2),@result = round(@amount0 * @menu_rate,2)
	else
		select @result0 = round(@amount0 * @rate,2),@result = round(@amount0 * @rate,2)
else if @mode = 'E'
	select @result0 = round(@amount0 * @rate,2),@result = round(@amount * @rate,2)
else if @mode = 'F'
	select @result0 = round(@amount0 * @menu_rate,2),@result = round(@amount * @menu_rate,2)
else if @mode = 'G'
	if @menu_rate > @rate
		select @result0 = round(@amount0 * @menu_rate,2),@result = round(@amount * @menu_rate,2)
	else
		select @result0 = round(@amount0 * @rate,2),@result = round(@amount * @rate,2)
else if @mode = 'H'
	if @menu_rate < @rate
		select @result0 = round(@amount0 * @menu_rate,2),@result = round(@amount * @menu_rate,2)
	else
		select @result0 = round(@amount0 * @rate,2),@result = round(@amount * @rate,2)
else if @mode = 'I'
	select @result0 = round(@amount0 * @menu_rate,2),@result = 0
else
	select @result0 = 0,@result = 0
;

