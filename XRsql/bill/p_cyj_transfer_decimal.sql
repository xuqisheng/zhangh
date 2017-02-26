/*------------------------------------------------------------------------------------*/
//
//		½ð¶î×ª»»³ÉÖÐÎÄ´óÐ´		cyj 2003/09/08
//
/*------------------------------------------------------------------------------------*/

if exists(select 1 from sysobjects where name = 'p_cyj_transfer_decimal_func')
	drop proc p_cyj_transfer_decimal_func;
create proc p_cyj_transfer_decimal_func
	@posi		int,
	@sparm	char(1),
	@rt		char(4) output
as
declare
	@numbs	char(20),
	@units	char(10),
	@units2	char(10)

select @units='·Ö½ÇÔ²'
select @units2='Ê°°ÛÇªÍò'
select @numbs = 'ÁãÒ¼·¡ÈþËÁÎéÂ½Æâ°Æ¾ÁÊ°'
if @sparm='.' 
	select @rt= substring(@units,5,2)
else if @sparm = '0' 
	select @rt= substring(@numbs,1,2)
else if @sparm = '#' 
   if @posi <> 8 
	   select @rt= ''
	else
	   select @rt= substring(@units2,7,2)
else
	if @posi=9 
		select @rt= substring(@numbs,(ascii(@sparm) - ascii('0'))*2+1,2) + substring(@units2,1,2)
   else if @posi=10 
		select @rt= substring(@numbs,(ascii(@sparm)-ascii('0'))*2+1,2) + substring(@units2,3,2)
	else
		begin
		select @rt= substring(@numbs,(ascii(@sparm)-ascii('0'))*2+1,2)
      if @posi<=2 
         select @rt = @rt + substring(@units,(@posi - 1)*2+1,2)
      else if @posi>= 5
         select @rt = @rt + substring(@units2,(@posi - 5)*2+1,2)
		end

;

if exists(select 1 from sysobjects where name = 'p_cyj_transfer_decimal')
	drop proc p_cyj_transfer_decimal;
create proc p_cyj_transfer_decimal
	@number		decimal(10,2),
	@fappe		varchar(40) output
as
declare
	@amount1		varchar(24),
	@amount2		varchar(24),
	@tmpch		char(1),
	@alhas		char(1),
	@lenc			int,
	@jiji			int,
	@lence		int,
	@ijij			int,
	@retvl		varchar(40),
	@retv			varchar(40),
	@retvl1		varchar(4),
	@tmp1			char(1)

select @amount1=convert(char(12), @number)
select @lenc=datalength(rtrim(@amount1)), @amount2 = '', @alhas = 'F'

select @jiji = 1
while @jiji <= @lenc
	begin
   select @tmpch = substring(@amount1,@jiji,1)
   if charindex(@tmpch, '123456789')>0
		begin
      select @amount2 = @amount2 + @tmpch
	   select @alhas = 'F'
		end
   else if @tmpch = '.' 
		begin
	   select @lence = datalength(rtrim(@amount2))
	   while charindex(substring(@amount2,@lence,1), '0#')>0
			begin
	      select @amount2 = stuff(@amount2,@lence,1,'#')
	      select @lence=@lence - 1
	   	end
	   select @lence=datalength(rtrim(@amount2))
	   if @lence>4 
	      while charindex(substring(@amount2,@lence - 4,1), '0#') > 0 
				begin
      		select @amount2=stuff(@amount2,@lence - 4,1,'#')
      		select @lence=@lence - 1
	      	end
	   select @amount2=@amount2 + '.'
	   select @alhas='F'
		end
   else if @tmpch = '0' 
	   if @alhas = 'T' 
	      select @amount2=@amount2+'#'
	   else
			begin
	      select @alhas='T'
	      select @amount2=@amount2+'0'
	   	end
	select @jiji = @jiji + 1
   end

select @lence=datalength(rtrim(@amount2))
while charindex(substring(@amount2,@lence,1), '0#') > 0 
	begin
   select @amount2=stuff(@amount2,@lence,1,'#')
   select @lence=@lence - 1
	end

select @ijij=1, @retvl='', @retvl1='', @retv =''
select @amount2 = ltrim(@amount2)

select @lence=datalength(rtrim(@amount2))
while @ijij <= @lence
	begin
	select @tmp1 = substring(@amount2,@lence - @ijij + 1,1)
	exec p_cyj_transfer_decimal_func @ijij, @tmp1, @retvl1 output
	select @retvl =  rtrim(@retvl1) + @retvl
	select @ijij = @ijij + 1
	end

select @retvl = rtrim(ltrim(@retvl))
if @number < 0 
	select @fappe = '¸º'
if convert(int, @number) = 0 
	select @fappe = rtrim(@fappe) + 'Áã'

select @fappe = @fappe + @retvl
if right(@fappe,2) = 'Ô²'
	select @fappe = @fappe + 'Õû'

;

