drop procedure p_cq_sp_adjust_dish;
create proc p_cq_sp_adjust_dish

	@menu			char(10),

	@empno		char(10),

	@old_id		integer,

	@pc_id		char(8),			          

	@add_remark	char(15)=NULL,

   @li_inumber integer

as

declare

	@code				char(6),		        

	@plucode			char(4),

   @modcode       char(15),		        

	@plu_amount		money,			          

	@plu_amount0	money,			        

	@remark			char(15),		        

	@id				int,		        



	@ret			integer,

	@msg			char(60),

	@bdate		datetime,		            

	@p_mode		char(1)	,		                          

	@deptno		char(2)	,		 

	@pccode		char(3)	,		            

	@mode			char(3),			           

	@new_id		integer	,		          

	@name1		char(20)	,		            

	@name2		char(30)	,		            

	@unit			char(4)	,		        

	@amount0		money	,			          

	@amount		money	,			                

	@number		money	,			            

	@shift 		char(1),

	@empno1		char(10),



	@dsc_rate	money,		                

	@serve_rate		money,		                

	@tax_rate		money,		                



	@serve_charge0	money,		

	@tax_charge0	money,		                  

	@serve_charge	money,		 

	@tax_charge		money,		                           

	@charge			money,		              



	@oprice				money,

	@special				char(1),

	@sta					char(1), 

	@timestamp_old		varbinary(8),

	@timestamp_new		varbinary(8)



select @bdate  = bdate1 from sysdata

select @p_mode = value  from sysoption where catalog = "sp_dish" and item = "p_mode"



begin tran

save  tran p_hry_pos_adjust_dish_s1

select @timestamp_old = timestamp from sp_menu where menu = @menu

update sp_menu set pc_id = @pc_id where menu= @menu

select @code = code, @number = - number, @plu_amount0 = - amount, @plu_amount = - amount,

		 @sta = sta, @remark = remark, @empno1 =empno1, @plucode = plucode, @id = id

  from sp_dish where menu = @menu and inumber = @old_id



if charindex(@sta,'03579')=0

	begin

	select @ret = 1,@msg = "当前帐目不能被冲销"

	commit tran 

	select @ret,@msg,@charge,@timestamp_old,@timestamp_new

	return 0

	end



                       

declare @newsta char(1)

select @newsta = convert(char(1),convert(int,@sta) + 1)



select @deptno = deptno,@pccode = pccode,@new_id = lastnum + 1,@sta = sta,@mode = mode,

		 @serve_rate = serve_rate,@tax_rate = tax_rate,@dsc_rate = dsc_rate, @shift = shift, @bdate = bdate

  from sp_menu where menu = @menu

if @@rowcount = 0

	select @ret = 1,@msg = "主单" + @menu+ "已不存在或已销单"

else if @sta ='3'

	select @ret = 1,@msg = "主单" + @menu + "已被其他收银员结帐"

else

	begin

	select @name1 = name1,@name2 = name2,@unit = unit,@oprice = price,@special=special,@modcode=plucode+','+sort+','+code

	  from pos_plu where plucode = @plucode and code = @code

	if @@rowcount = 0

		select @ret = 1,@msg = "菜号" + rtrim(@code) + "已不存在"

	else

		begin

	                                              

			select @name1=name1,@name2=@name2 from sp_dish where menu=@menu and inumber=@old_id

	              



			select @serve_charge0 = 0,@serve_charge = 0,@tax_charge0 = 0,@tax_charge = 0,@charge = 0

			select @amount0 = @plu_amount0

			if @special = 'T' or @special = 'X'

				select @amount = @plu_amount

			else

				begin

				if @sta='0'

					                            

					exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@modcode,@amount0,@dsc_rate,@result = @amount output

				else

					select @amount = @plu_amount





				exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@modcode,@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output



				                       

				exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@modcode,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output

				end

			             

			update sp_dish set sta = @newsta where menu = @menu and inumber = @old_id

			insert sp_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,number,amount,dsc,srv,tax,empno,empno1,bdate,remark,special,sta,id_cancel,orderno)

				   select @menu,@new_id,plucode,sort,id,@code,@name1,@name2,@unit,@number,@amount,- dsc,- srv,- tax,@empno,@empno1,@bdate,@add_remark,@special,'2',@old_id,orderno

-- hbb 2002.12.24

--				   select @menu,@new_id,plucode,sort,id,@code,@name1,@name2,@unit,@number,@amount, dsc,srv,tax,@empno,@empno1,@bdate,@remark,@special,'2',@old_id

			from sp_dish where menu = @menu and inumber = @old_id



			                

			update pos_empnoav set sta ='0' where bdate = @bdate and shift =@shift and empno = @empno1 and inumber = @old_id



			declare @cur_id integer

			declare @app_id integer

			select @app_id= @new_id

			declare std_mx_cur cursor for

				select id from sp_dish where menu=@menu and sta='M' and id_master=@old_id order by id

			open std_mx_cur

			fetch std_mx_cur into @cur_id

			while @@sqlstatus = 0

			begin

				select @app_id = @app_id + 1

				insert sp_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,number,amount,dsc,srv,tax,empno,bdate,remark,special,sta,id_cancel,id_master,orderno)

				   select @menu,@app_id,plucode,sort,id,code,name1,name2,unit,- number,-amount,-dsc,-srv,-tax,@empno,@bdate,@add_remark,special,'2',@cur_id,@new_id,orderno

						from sp_dish where menu=@menu and id = @cur_id

				fetch std_mx_cur into @cur_id

			end

			close std_mx_cur

			deallocate cursor std_mx_cur

              

			update pos_assess set number1 = number1 + @number where id = @id



                  

                                               

			update sp_dish set sta='1' where menu=@menu and sta='M' and id_master=@old_id



			

			update sp_menu set amount = amount + @amount + round(@serve_charge,2) + @tax_charge,lastnum = @app_id

			 where menu = @menu

			select @charge = amount,@timestamp_new = timestamp from sp_menu where menu = @menu

			select @ret = 0,@msg = "成功"

		end



	update sp_menu set srv = (select sum(srv) from sp_dish where menu = @menu and charindex(sta,'03579')>0)
	
		where menu = @menu
	
	update sp_menu set tax = (select sum(tax) from sp_dish where menu = @menu and charindex(sta,'03579')>0)
	
		where menu = @menu
	
	update sp_menu set dsc = (select sum(dsc) from sp_dish where menu = @menu and charindex(sta,'03579')>0)
	
		where menu = @menu
	
	update sp_menu set amount0 = (select sum(amount) from sp_dish where menu = @menu and charindex(sta,'03579')>0)
	
		where menu = @menu
	
	update sp_menu set amount = (select sum(amount) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	
		+ (select sum(srv) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	
		+ (select sum(tax) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	
		- (select sum(dsc) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	
		where menu = @menu
	
	
	update pos_tblav set amount = isnull((select sum(amount) from sp_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0 )
	
		+ (select sum(srv) from sp_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	
		+ (select sum(tax) from sp_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	
		- (select sum(dsc) from sp_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0), 0)
	
		from pos_tblav a where a.menu = @menu  and sta ='7'
	  
	update sp_plaav set sta = 'I' ,dishtype = 'F' ,dnumber = 0 where sp_menu = @menu and dnumber = @old_id
                                       
   delete pos_hxsale where menu=@menu and inumber=@li_inumber

 end

commit tran 

select @ret,@msg,@charge

return 0
;