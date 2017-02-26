drop procedure p_cq_sp_update_menu;

create proc p_cq_sp_update_menu
	@pc_id		char(4),
	@menu			char(10)
as
declare
	@ret			integer,
	@msg			char(60),
	@bdate		datetime,		            
	@p_mode		char(1)	,		                          
	@deptno		char(2)	,		            
	@pccode		char(3)	,		            
	@code			char(15)	,		        
	@name1		char(20)	,		            
	@name2		char(20)	,		            
	@unit			char(2)	,		        
	@guest 		integer	,
	@mode			char(3),			             
	@tea_charge money	,
	@amount0		money	,			            
	@amount		money	,
	@number		money	,			            

	@dsc_rate	money,		                
	@serve_rate		money,		                
	@tax_rate		money,		                

	@total_serve_charge0	money,		              
	@total_tax_charge0	money,		              
	@total_serve_charge	money,		                       
	@total_tax_charge		money,		                       
	@charge					money,		              

	@serve_charge0	money,		          
	@tax_charge0	money,		          
	@serve_charge	money,		                   
	@tax_charge		money,		                   

	@special    char(1),
	@sta        char(1), 
	@dishsta		char(1) 

select @bdate  = bdate1 from sysdata
select @p_mode = value  from sysoption where catalog = "sp_dish" and item = "p_mode"

begin tran
save  tran p_gl_pos_update_menu_s1
update sp_menu set pc_id = @pc_id where menu = @menu
select @deptno = deptno,@pccode = pccode,@sta = sta,
		 @serve_rate = serve_rate,@tax_rate = tax_rate,@dsc_rate = dsc_rate,
		 @mode = mode,@guest = guest,@tea_charge = tea_rate
  from sp_menu where menu = @menu
if @@rowcount = 0
	select @ret = 1,@msg = "主单不存在或已销单"
else if @sta ='3'
	select @ret = 1,@msg = "主单已被其他收银员结帐"
else
	begin
	select @total_tax_charge0 =0,@total_tax_charge = 0,@total_serve_charge0 = 0,@total_serve_charge = 0
	          
	select @amount0 = round(@tea_charge * @guest,2),@amount = 0
	if @guest > 0 and @tea_charge > 0
		                      
		exec p_gl_pos_create_discount	@deptno,@pccode,@mode,'X',@amount0,@dsc_rate,@result = @amount output
	update sp_dish set number = @guest,amount = @amount0,dsc = @amount0 - @amount where menu = @menu and code = 'X'

	exec p_gl_pos_create_tax @deptno,@pccode,@mode,'Y',@amount0,@amount,@tax_rate,@result0 = @total_tax_charge0 output,@result = @total_tax_charge output
	update sp_dish set tax = @total_tax_charge where menu = @menu and code = 'X'
	                      
	exec p_gl_pos_create_serve @deptno,@pccode,@mode,'Z',@amount0,@amount,@serve_rate,@result0 = @total_serve_charge0 output,@result = @total_serve_charge output
	update sp_dish set srv = @total_serve_charge where menu = @menu and code = 'X'
	declare c_dish cursor for
	 select sta,sort+code,number,amount,special from sp_dish  //cq.jm
	  where menu = @menu and code like '[0-9]%' and charindex(sta,'03579') > 0 
	open c_dish
	fetch c_dish into @dishsta,@code,@number,@amount,@special
	while @@sqlstatus = 0
	   begin
		select @serve_charge0 = 0,@serve_charge = 0,@tax_charge0 = 0,@tax_charge = 0,@charge = 0
		if charindex(@special,'XT') = 0                                     
		begin
			select @amount0 = @amount
			if charindex(@dishsta,'0129') > 0 
				                            
				exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@code,@amount0,@dsc_rate,@result = @amount output

			if charindex(@dishsta,'35') = 0 and @special <> 'U'                 
				begin
				                            
				exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@code,@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output
	
				                            
				exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@code,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
				end
		end

		if charindex(@dishsta,'012') > 0  and charindex(@special,'XT') = 0                                                
			                                 
			update sp_dish set dsc = amount - @amount, srv = @serve_charge, tax = @tax_charge
			 where current of c_dish

		select @total_serve_charge0 = @total_serve_charge0 + @serve_charge0,
					 @total_serve_charge = @total_serve_charge  + @serve_charge,
					 @total_tax_charge0 = @total_tax_charge0 + @tax_charge0,
					 @total_tax_charge = @total_tax_charge + @tax_charge
					 
		fetch c_dish into @dishsta,@code,@number,@amount,@special
		end

	                              
	update sp_dish set amount =  @total_serve_charge0, dsc = @total_serve_charge0 - @total_serve_charge
	 where menu = @menu and code = "Z"
	update sp_dish set amount =  @total_tax_charge0, dsc = @total_tax_charge0 - @total_tax_charge
	 where menu = @menu and code = "Y"

	                    
	     
	update sp_menu set amount = (select sum(amount) - sum(dsc) + sum(srv) + sum(tax) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		amount0 = (select sum(amount) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		dsc = (select sum(dsc) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		srv = (select sum(srv) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		tax = (select sum(tax) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0)
		where menu = @menu
	select @ret = 0,@msg = "成功"
	end
close c_dish
deallocate cursor c_dish
commit tran 
select @ret,@msg
return @ret;
