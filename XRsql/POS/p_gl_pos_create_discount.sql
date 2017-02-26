/*�����Żݼ�*/
if exists(select * from sysobjects where name = "p_gl_pos_create_discount")
	drop proc p_gl_pos_create_discount
;

create proc p_gl_pos_create_discount
	@deptno		char(2),
	@pccode		char(3),
	@code			char(3),
	@plucode		char(15),		/*�˺�*/
	@amount0		money,			/*ԭ���*/
	@menu_rate	money,			/*�Żݱ���*/
	@result		money	output	/*�Żݼ�*/
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

/*��������*/
if exists(select * from sysobjects where name = "p_gl_pos_create_serve")
	drop proc p_gl_pos_create_serve
;

create proc p_gl_pos_create_serve
	@deptno		char(2),
	@pccode		char(3),
	@code			char(3),
	@plucode		char(15),	/*�˺�*/
	@amount0		money,		/*ԭ���*/
	@amount		money,		/*�Żݺ�Ľ��*/
	@menu_rate	money,		/*MENU�еķ������*/
	@result0		money	output,		/*ԭ�����*/
	@result		money	output		/*�Żݺ�ķ����*/
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

/*���㸽�ӷ�*/
if exists(select * from sysobjects where name = "p_gl_pos_create_tax")
	drop proc p_gl_pos_create_tax
;

create proc p_gl_pos_create_tax
	@deptno		char(2),
	@pccode		char(3),
	@code			char(3),
	@plucode		char(15),	/*�˺�*/
	@amount0		money,		/*ԭ���*/
	@amount		money,		/*�Żݺ�Ľ��*/
	@menu_rate	money,		/*MENU�еĸ��ӷ���*/
	@result0		money	output,		/*ԭ���ӷ�*/
	@result		money	output		/*�Żݺ�ĸ��ӷ�*/
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

