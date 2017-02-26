
drop  proc p_gl_pos_create_min_charge;
create proc p_gl_pos_create_min_charge
	@menu			char(10),
	@min_charge	money		output,
	@retmode		char(1) = "S"	,
   @hamount    money
as
--
--	计算餐单最低消费
--
declare
	@mode			char(3),
	@option		char(1),
	@tables		money,
	@guest		money,
	@charge		money,
	@charge0		money,
	@amount		money


select @option = '0'
select @option = rtrim(ltrim(value))  from sysoption where catalog ='pos' and item = 'min_charge_option'

select @charge0 = isnull(sum(amount - dsc + srv + tax ), 0)  from pos_dish where menu = @menu  and  charindex(rtrim(code), 'YZ') = 0  and charindex(special, 'E') = 0  and charindex(sta,'03579')>0

if @option = '1'
	select @charge=isnull(sum(amount - dsc ), 0)  from pos_dish where menu = @menu  and  charindex(rtrim(code), 'YZ') = 0  and charindex(special, 'E') = 0  and charindex(sta,'03579')>0
else if @option = '2'
	select @charge=isnull(sum(amount - dsc + srv + tax), 0)  from pos_dish where menu = @menu  and  charindex(rtrim(code), 'XYZ') = 0  and charindex(special, 'E') = 0  and charindex(sta,'03579')>0
else if @option = '3'
	select @charge=isnull(sum(amount - dsc ), 0)   from pos_dish where menu = @menu  and  charindex(rtrim(code), 'YZ') = 0  and charindex(special, 'E') = 0  and charindex(sta,'03579')>0
else
	select @charge=isnull(sum(amount - dsc + srv + tax), 0)   from pos_dish where menu = @menu  and  charindex(rtrim(code), 'YZ') = 0  and charindex(special, 'E') = 0  and charindex(sta,'03579')>0

select @min_charge = 0
if exists (select 1 from pos_menu)
	select @tables = a.tables, @guest = a.guest,   @mode = b.mode, @amount = b.amount
		from pos_menu a, pos_tblsta b where a.menu = @menu and a.tableno = b.tableno
else
	select @tables = a.tables, @guest = a.guest, @charge = a.amount, @mode = b.mode, @amount = b.amount
		from pos_hmenu a, pos_tblsta b where a.menu = @menu and a.tableno = b.tableno

if @mode = '1' and @amount * @tables > @charge
	select @min_charge = @amount * @tables
else if @mode = '2' and @amount * @guest > @charge
	select @min_charge = @amount * @guest

if @hamount <> 0 and @hamount < @min_charge 
	begin
	if @hamount > @charge0
		select @min_charge = @hamount
	else
		select @min_charge = 0
	end
if @retmode = 'S'
	select @min_charge
return 0
;