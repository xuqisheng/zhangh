if exists(select 1 from sysobjects where name ='p_cyj_pos_create_min_charge' and type = 'P')
	drop proc p_cyj_pos_create_min_charge;
create proc p_cyj_pos_create_min_charge
	@menu			char(10),
	@min_charge	money	output,			            -- ������ѽ��
   @hamount    money,									-- �������������
	@retmode		char(1) = "S"	
as
----------------------------------------------------------------------------------------------
--
--		�����������
--
----------------------------------------------------------------------------------------------
declare
	@mode			char(3),
	@tables		money,
	@guest		money,
	@charge		money,
	@amount		money

select @min_charge = 0
if exists (select 1 from pos_menu where menu = @menu)
	select @tables = a.tables, @guest = a.guest, @charge = a.amount, @mode = b.mode, @amount = b.amount
		from pos_menu a, pos_tblsta b where a.menu = @menu and a.tableno = b.tableno
else
	select @tables = a.tables, @guest = a.guest, @charge = a.amount, @mode = b.mode, @amount = b.amount
		from pos_hmenu a, pos_tblsta b where a.menu = @menu and a.tableno = b.tableno

if @mode = '1' and @amount * @tables > @charge        -- ����
	select @min_charge = @amount * @tables
else if @mode = '2' and @amount * @guest > @charge    -- ����
	select @min_charge = @amount * @guest

if  @hamount  <>0
	if @hamount <> @min_charge 
		select @min_charge = @hamount
   
if @retmode = 'S'
	select @min_charge
return 0;
