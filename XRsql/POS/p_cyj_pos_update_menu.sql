/*---------------------------------------------------------------------------------------------*/
//
// ������������ 
//
/*---------------------------------------------------------------------------------------------*/

if exists(select * from sysobjects where name = "p_cyj_pos_update_menu")
	drop proc p_cyj_pos_update_menu
;

create proc p_cyj_pos_update_menu
	@pc_id		char(4),
	@menu			char(10),
	@returnmode	char(1)   = 'S'
as
declare
	@ret			integer,
	@msg			char(60),
	@bdate		datetime,		/*Ӫҵ����*/
	@p_mode		char(1)	,		/*�ۿ������ѵļ���˳��*/
	@deptno		char(2)	,		/*���Ŵ���*/
	@pccode		char(3)	,		/*Ӫҵ����*/
	@code			char(15)	,		/*�˺�*/
	@name1		char(20)	,		/*���Ĳ���*/
	@name2		char(20)	,		/*Ӣ�Ĳ���*/
	@unit			char(2)	,		/*��λ*/
	@guest 		integer	,
	@mode			char(3),			/*	ģʽ����*/
	@tea_charge	money	,
	@amount0		money	,			/*�˵��۸�*/
	@amount		money	,
	@number		money	,			/*�˵�����*/	            

	@dsc_rate	money,		/*�����Żݱ���*/
	@serve_rate		money,		/*�����������*/
	@tax_rate		money,		/*�������ӷ���*/

	@total_serve_charge0	money,		/*������ۼ�*/
	@total_tax_charge0	money,		/*���ӷ��ۼ�*/
	@total_serve_charge	money,		/*������ۼ�,���ܴ���*/
	@total_tax_charge		money,		/*���ӷ��ۼ�,���ܴ���*/
	@charge					money,		/*�Ѳ���ۼ�*/

	@serve_charge0	money,		/*�����*/
	@tax_charge0	money,		/*���ӷ�*/
	@serve_charge	money,		/*�����,���ܴ���*/
	@tax_charge		money,		/*���ӷ�,���ܴ���*/

	@special    char(1),
	@sta        char(1), 
	@dishsta		char(1), 
	@dsc			money,
	@inumber		int

select @bdate  = bdate1 from sysdata
select @p_mode = value  from sysoption where catalog = "pos_dish" and item = "p_mode"

begin tran
save  tran p_gl_pos_update_menu_s1
update pos_menu set pc_id = @pc_id where menu = @menu
select @deptno = deptno,@pccode = pccode,@sta = sta,
		 @serve_rate = serve_rate,@tax_rate = tax_rate,@dsc_rate = dsc_rate,
		 @mode = mode,@guest = guest,@tea_charge = tea_rate
  from pos_menu where menu = @menu
if @@rowcount = 0
	select @ret = 1,@msg = "���������ڻ�������"
else if @sta ='3'
	select @ret = 1,@msg = "�����ѱ���������Ա����"
else
	begin
	select @total_tax_charge0 =0,@total_tax_charge = 0,@total_serve_charge0 = 0,@total_serve_charge = 0
	-- ��λ���������������޸�
	select @guest = number from pos_dish  where menu = @menu and code = 'X'
	select @amount0 = round(@tea_charge * @guest,2),@amount = 0

	/*�����λ�ѵ��Żݼ�*/
	if @guest > 0 and @tea_charge > 0
		exec p_gl_pos_create_discount	@deptno,@pccode,@mode,'X',@amount0,@dsc_rate,@result = @amount output
	update pos_dish set number = @guest,amount = @amount0,dsc = @amount0 - @amount where menu = @menu and code = 'X'
	/*�����λ�ѵĸ��ӷ�*/
	exec p_gl_pos_create_tax @deptno,@pccode,@mode,'Y',@amount0,@amount,@tax_rate,@result0 = @total_tax_charge0 output,@result = @total_tax_charge output
	update pos_dish set tax = @total_tax_charge,tax0 = @total_tax_charge0,tax_dsc = @total_tax_charge0 - @total_tax_charge where menu = @menu and code = 'X'
	/*�����λ�ѵķ����*/
	exec p_gl_pos_create_serve @deptno,@pccode,@mode,'Z',@amount0,@amount,@serve_rate,@result0 = @total_serve_charge0 output,@result = @total_serve_charge output
	update pos_dish set srv = @total_serve_charge,srv0 = @total_serve_charge0,srv_dsc = @total_serve_charge0 - @total_serve_charge where menu = @menu and code = 'X'

//	if @guest > 0 and @tea_charge > 0
//		/*�����λ�ѵ��Żݼ�*/
//		exec p_gl_pos_create_discount	@deptno,@pccode,@mode,'X',@amount0,@dsc_rate,@result = @amount output
//	update pos_dish set number = @guest,amount = @amount0,dsc = @amount0 - @amount where menu = @menu and code = 'X'
//	/*�����λ�ѵĸ��ӷ�*/
//	exec p_gl_pos_create_tax @deptno,@pccode,@mode,'Y',@amount0,@amount,@tax_rate,@result0 = @total_tax_charge0 output,@result = @total_tax_charge output
//	update pos_dish set tax = @total_tax_charge where menu = @menu and code = 'X'
//	/*�����λ�ѵķ����*/
//	exec p_gl_pos_create_serve @deptno,@pccode,@mode,'Z',@amount0,@amount,@serve_rate,@result0 = @total_serve_charge0 output,@result = @total_serve_charge output
//	update pos_dish set srv = @total_serve_charge where menu = @menu and code = 'X'
	declare c_dish cursor for
	 select inumber,sta, plucode+sort+code,number,amount,special,dsc from pos_dish  
	  where menu = @menu and code like '[0-9]%' and charindex(sta,'03579') > 0 
	open c_dish
	fetch c_dish into @inumber,@dishsta,@code,@number,@amount,@special,@dsc
	while @@sqlstatus = 0
	   begin
		select @serve_charge0 = 0,@serve_charge = 0,@tax_charge0 = 0,@tax_charge = 0,@charge = 0
		if charindex(@special,'XT') = 0                                     
		begin
			if @dsc > @amount and @amount > 0 -- Ԥ���ۿ۴���ԭ��
				select @dsc = @amount
			select @amount0 = @amount
			if charindex(@dishsta,'09') > 0 
				exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@code,@amount0,@dsc_rate,@result = @amount output
			else if charindex(@dishsta,'35') > 0 
				select @amount = 0
			else if charindex(@dishsta,'7') > 0 
				select @amount = @amount0 - @dsc

--			if charindex(@dishsta,'35') = 0 and @special <> 'U'       
--          '3' ���Ͳ���ģʽ������Ѳ���          
			if @dishsta <>'3' and @special <> 'U'               
				begin
				exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@code,@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output
				exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@code,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
				end
			else if @dishsta <>'3' and @special = 'U'    -- �����ѣ�����˰����Ҫ����˰           
				exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@code,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
		end
	   if charindex(@dishsta,'012357') > 0  and charindex(@special,'XT') = 0                                                
			update pos_dish set srv = @serve_charge,srv0 = @serve_charge0,srv_dsc = @serve_charge0-@serve_charge,
			 dsc = amount - @amount, tax = @tax_charge,tax0 = @tax_charge0,tax_dsc = @tax_charge0-@tax_charge
			 where menu = @menu and inumber = @inumber
//			update pos_dish set dsc = amount - @amount, srv = @serve_charge, tax = @tax_charge
//			 where menu = @menu and inumber = @inumber
		else if charindex(@dishsta,'35') > 0  and charindex(@special,'XT') = 0                                                
			update pos_dish set dsc=amount, srv = @serve_charge, tax = @tax_charge
			 where menu = @menu and inumber = @inumber

		if @special = 'E'        -- ���˿���ۿۡ�����ѡ�˰Ϊ0
			begin
				select @serve_charge = 0, @serve_charge0 = 0,@tax_charge = 0, @tax_charge0 = 0
				update pos_dish set dsc=0, srv=0, srv0=0, srv_dsc=0, tax=0, tax0=0, tax_dsc=0 
					where menu = @menu and inumber = @inumber
			end

		update  pos_dish set dsc=amount  where menu = @menu and inumber = @inumber and dsc>amount and amount>0

		select @total_serve_charge0 = @total_serve_charge0 + @serve_charge0,
					 @total_serve_charge = @total_serve_charge  + @serve_charge,
					 @total_tax_charge0 = @total_tax_charge0 + @tax_charge0,
					 @total_tax_charge = @total_tax_charge + @tax_charge
					 
		fetch c_dish into @inumber,@dishsta,@code,@number,@amount,@special,@dsc
		end

	                              
	update pos_dish set amount =  @total_serve_charge, dsc = @total_serve_charge0 - @total_serve_charge
	 where menu = @menu and code = "Z"
	update pos_dish set amount =  @total_tax_charge, dsc = @total_tax_charge0 - @total_tax_charge
	 where menu = @menu and code = "Y"

	/*����MENU���ü�¼*/
	/* ͳ��ʱ�����Ǳ�׼��ϸ������, sta='M' */
	update pos_menu set amount = isnull((select sum(amount) - sum(dsc) + sum(srv) + sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0), 0)
		where menu = @menu
	update pos_menu set amount0 = isnull((select sum(amount) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),0)
		where menu = @menu
	update pos_menu set dsc = isnull((select sum(dsc) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),0)
		where menu = @menu
	update pos_menu set srv = isnull((select sum(srv) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),0)
		where menu = @menu
	update pos_menu set tax = isnull((select sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),0)
		where menu = @menu

	update pos_tblav set amount = isnull((select sum(amount) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 ), 0)
		from pos_tblav a where a.menu = @menu and sta = '7'
	update pos_tblav set amount = amount + isnull((select sum(srv) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0), 0)
		from pos_tblav a where a.menu = @menu and sta = '7'
	update pos_tblav set amount = amount + isnull((select sum(tax) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0), 0)
		from pos_tblav a where a.menu = @menu and sta = '7'
	update pos_tblav set amount = amount - isnull((select sum(dsc) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0), 0)
		from pos_tblav a where a.menu = @menu and sta = '7'

	select @ret = 0,@msg = "�ɹ�"
	end
close c_dish
deallocate cursor c_dish

exec p_fhb_pos_tcmxft @menu

-- ����pos_order�ķ���Ѻ��ۿ�
exec p_cyj_pos_order_amount	@menu,@pc_id

commit tran 

if @returnmode = 'R'
	select @ret,@msg
return @ret;
