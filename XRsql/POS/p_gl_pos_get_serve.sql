if exists(select 1 from sysobjects where name ='p_gl_pos_get_serve' and type ='P')
	drop proc p_gl_pos_get_serve;
create proc p_gl_pos_get_serve
	@deptno		char(5),
	@pccode		char(5),
	@code			char(3),
	@plucode		char(15),
	@amount0		money,			  -- ԭ��
	@amount1		money,           -- ģʽ�Żݶ�
	@amount2		money,           -- �͵��Żݶ�
	@menu_rate	money,
	@result0		money	output,    -- �Ż�ǰ�����
	@result1		money	output,    -- ģʽ�Żݷ���Ѷ�
	@result2		money	output     -- �͵��Żݷ���Ѷ�
as
-----------------------------------------------------------------------
--
--		pos_detail �е���
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
if @mode = 'A'   -- ��ģʽ�������Ϊ׼
	select @result0 = @amount0 * @rate
else if @mode = 'B'  -- �Բ˵��������Ϊ׼
	select @result0 = @amount0 * @menu_rate
else if @mode = 'C' -- �Խϴ�ķ������Ϊ׼
	if @menu_rate > @rate
		select @result0 = @amount0 * @menu_rate
	else
		select @result0 = @amount0 * @rate
else if @mode = 'D'  -- �Խ�С�ķ������Ϊ׼
	if @menu_rate < @rate
		select @result0 = @amount0 * @menu_rate
	else
		select @result0 = @amount0 * @rate
else if @mode = 'E'  -- ��ģʽ�������Ϊ׼(�Żݷ����)
	begin
	select @result0 = @amount0 * @rate
	select @result1 = round(@amount1 * @rate,2)
	select @result2 = @result0 - round(@amount * @rate,2) - @result1
	end
else if @mode = 'F'  -- �Բ˵��������Ϊ׼(�Żݷ����)
	begin
	select @result0 = @amount0 * @menu_rate
	select @result1 = round(@amount1 * @menu_rate,2)
	select @result2 = @result0 - round(@amount * @menu_rate,2) - @result1
	end
else if @mode = 'G'  -- �Խϴ�ķ������Ϊ׼(�Żݷ����)
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
else if @mode = 'H'  -- �Խ�С�ķ������Ϊ׼(�Żݷ����)
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
else if @mode = 'I' -- �Żݷ����, ���շ���ѣ������ȫ���Ż�
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

