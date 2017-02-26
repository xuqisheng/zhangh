/*---------------------------------------------------------------------------------------------*/
//
// 菜饮主单保存 
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
	@bdate		datetime,		/*营业日期*/
	@p_mode		char(1)	,		/*折扣与服务费的计算顺序*/
	@deptno		char(2)	,		/*部门代码*/
	@pccode		char(3)	,		/*营业点码*/
	@code			char(15)	,		/*菜号*/
	@name1		char(20)	,		/*中文菜名*/
	@name2		char(20)	,		/*英文菜名*/
	@unit			char(2)	,		/*单位*/
	@guest 		integer	,
	@mode			char(3),			/*	模式代码*/
	@tea_charge	money	,
	@amount0		money	,			/*菜单价格*/
	@amount		money	,
	@number		money	,			/*菜单数量*/	            

	@dsc_rate	money,		/*主单优惠比例*/
	@serve_rate		money,		/*主单服务费率*/
	@tax_rate		money,		/*主单附加费率*/

	@total_serve_charge0	money,		/*服务费累计*/
	@total_tax_charge0	money,		/*附加费累计*/
	@total_serve_charge	money,		/*服务费累计,可能打折*/
	@total_tax_charge		money,		/*附加费累计,可能打折*/
	@charge					money,		/*费差额累计*/

	@serve_charge0	money,		/*服务费*/
	@tax_charge0	money,		/*附加费*/
	@serve_charge	money,		/*服务费,可能打折*/
	@tax_charge		money,		/*附加费,可能打折*/

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
	select @ret = 1,@msg = "主单不存在或已销单"
else if @sta ='3'
	select @ret = 1,@msg = "主单已被其他收银员结帐"
else
	begin
	select @total_tax_charge0 =0,@total_tax_charge = 0,@total_serve_charge0 = 0,@total_serve_charge = 0
	-- 茶位费数量不随人数修改
	select @guest = number from pos_dish  where menu = @menu and code = 'X'
	select @amount0 = round(@tea_charge * @guest,2),@amount = 0

	/*计算茶位费的优惠价*/
	if @guest > 0 and @tea_charge > 0
		exec p_gl_pos_create_discount	@deptno,@pccode,@mode,'X',@amount0,@dsc_rate,@result = @amount output
	update pos_dish set number = @guest,amount = @amount0,dsc = @amount0 - @amount where menu = @menu and code = 'X'
	/*计算茶位费的附加费*/
	exec p_gl_pos_create_tax @deptno,@pccode,@mode,'Y',@amount0,@amount,@tax_rate,@result0 = @total_tax_charge0 output,@result = @total_tax_charge output
	update pos_dish set tax = @total_tax_charge,tax0 = @total_tax_charge0,tax_dsc = @total_tax_charge0 - @total_tax_charge where menu = @menu and code = 'X'
	/*计算茶位费的服务费*/
	exec p_gl_pos_create_serve @deptno,@pccode,@mode,'Z',@amount0,@amount,@serve_rate,@result0 = @total_serve_charge0 output,@result = @total_serve_charge output
	update pos_dish set srv = @total_serve_charge,srv0 = @total_serve_charge0,srv_dsc = @total_serve_charge0 - @total_serve_charge where menu = @menu and code = 'X'

//	if @guest > 0 and @tea_charge > 0
//		/*计算茶位费的优惠价*/
//		exec p_gl_pos_create_discount	@deptno,@pccode,@mode,'X',@amount0,@dsc_rate,@result = @amount output
//	update pos_dish set number = @guest,amount = @amount0,dsc = @amount0 - @amount where menu = @menu and code = 'X'
//	/*计算茶位费的附加费*/
//	exec p_gl_pos_create_tax @deptno,@pccode,@mode,'Y',@amount0,@amount,@tax_rate,@result0 = @total_tax_charge0 output,@result = @total_tax_charge output
//	update pos_dish set tax = @total_tax_charge where menu = @menu and code = 'X'
//	/*计算茶位费的服务费*/
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
			if @dsc > @amount and @amount > 0 -- 预防折扣大于原价
				select @dsc = @amount
			select @amount0 = @amount
			if charindex(@dishsta,'09') > 0 
				exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@code,@amount0,@dsc_rate,@result = @amount output
			else if charindex(@dishsta,'35') > 0 
				select @amount = 0
			else if charindex(@dishsta,'7') > 0 
				select @amount = @amount0 - @dsc

--			if charindex(@dishsta,'35') = 0 and @special <> 'U'       
--          '3' 赠送不管模式，服务费不收          
			if @dishsta <>'3' and @special <> 'U'               
				begin
				exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@code,@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output
				exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@code,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
				end
			else if @dishsta <>'3' and @special = 'U'    -- 免服务费，不免税，需要计算税           
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

		if @special = 'E'        -- 单菜款待折扣、服务费、税为0
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

	/*更新MENU费用记录*/
	/* 统计时不考虑标准明细的作用, sta='M' */
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

	select @ret = 0,@msg = "成功"
	end
close c_dish
deallocate cursor c_dish

exec p_fhb_pos_tcmxft @menu

-- 计算pos_order的服务费和折扣
exec p_cyj_pos_order_amount	@menu,@pc_id

commit tran 

if @returnmode = 'R'
	select @ret,@msg
return @ret;
