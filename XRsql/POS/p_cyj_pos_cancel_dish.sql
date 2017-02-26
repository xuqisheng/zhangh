drop  proc p_cyj_pos_cancel_dish;
create proc p_cyj_pos_cancel_dish
	@menu			char(10),
	@empno		char(10),
	@old_id		integer,
	@pc_id		char(8),			          
	@add_remark	char(50)=NULL,
   @li_inumber integer,
	@retmode		char(1) = 'R'
as
-------------------------------------------------------------------------------------------------
--
--			点菜冲消dish
--
-------------------------------------------------------------------------------------------------
declare
	@code				char(6),		        
	@plucode			char(4),
   @modcode       char(15),		        
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
	@amount		money	,			                
	@number		money	,			            
	@shift 		char(1),
	@empno1		char(10),

	@charge			money,		              

	@special				char(1),
	@dish_sta			char(1), 
	@menu_sta			char(1), 
	@newsta 				char(1),
	@cur_id 				int,
	@app_id 				int,
	@lastnum				int,
	@printid				int

select @bdate  = bdate1 from sysdata
select @p_mode = value  from sysoption where catalog = "pos_dish" and item = "p_mode"

begin tran
save  tran p_hry_pos_adjust_dish_s1
update pos_menu set pc_id = @pc_id where menu= @menu
select @code = code, @number = - number, @dish_sta = sta, @remark = remark, @empno1 =empno1, @plucode = plucode, @id = id, @special=special
  from pos_dish where menu = @menu and inumber = @old_id
if charindex(@dish_sta,'03579M')=0 or (@dish_sta = 'M' and @special ='C')
	begin
	select @ret = 1,@msg = "当前帐目不能被冲销"
	commit tran 
	select @ret,@msg,@charge
	return 0
	end

select @printid = isnull(max(printid)+1,1) from pos_dish                        
select @deptno = deptno,@pccode = pccode,@new_id = lastnum + 1,@menu_sta = sta,@mode = mode,
		 @shift = shift, @bdate = bdate
  from pos_menu where menu = @menu
if @@rowcount = 0
	select @ret = 1,@msg = "主单" + @menu+ "已不存在或已销单"
else if @menu_sta ='3'
	select @ret = 1,@msg = "主单" + @menu + "已被其他收银员结帐"
else
	begin
	select @name1 = name1,@name2 = name2,@special=special,@modcode = sort+code 
	  from pos_plu where plucode = @plucode and code = @code
	if @@rowcount = 0
		select @ret = 1,@msg = "菜号" + rtrim(@code) + "已不存在"
	else
		begin
			if @dish_sta = 'M'    -- 套菜明细冲销, 对应special改为 ‘C’, sta 改为 ‘1’和‘2’
				begin
				
				insert pos_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,price,number,amount,dsc,srv,tax,empno,empno1,bdate,remark,special,sta,id_cancel,id_master,orderno,kitchen,printid,flag,tableno)
						select @menu,@new_id,plucode,sort,id,code,name1,name2,unit,price,-1 * number, -1 * amount,-1 * dsc,-1 * srv,-1 * tax,@empno,@empno1,@bdate,@add_remark,'C','2',id_cancel,id_master,orderno,kitchen,@printid,flag,tableno
				from pos_dish where menu = @menu and inumber = @old_id
				--数据插入pos_dishcard
				exec p_cq_newpos_input_dishcard  @menu, @new_id,@pc_id
				--冲销明细成本
				exec p_cyj_pos_sale @menu,@new_id
				update pos_dish set special = 'C', sta = '1' from pos_dish where menu = @menu and inumber = @old_id
				update pos_menu set lastnum = lastnum + 1 from pos_menu where menu = @menu
				--////////FHB Added///////////
				exec p_fhb_pos_tcmxft @menu
				--//////////////////////
				select @ret = 0,@msg = "ok"
				commit tran 
				select @ret,@msg,@charge
				return 0
				end

			select @newsta = convert(char(1),convert(int,@dish_sta) + 1)
			select @name1=name1,@name2=@name2 from pos_dish where menu=@menu and inumber=@old_id

			insert pos_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,price,number,amount,dsc,srv,tax,empno,empno1,bdate,remark,special,sta,id_cancel,kitchen,printid,flag,tableno)
				   select @menu,@new_id,plucode,sort,id,@code,@name1,@name2,unit,price,-number,-amount,- dsc,- srv,- tax,@empno,@empno1,@bdate,@add_remark,@special,'2',@old_id,kitchen,@printid,flag,tableno
			from pos_dish where menu = @menu and inumber = @old_id
			--数据插入pos_dishcard
			exec p_cq_newpos_input_dishcard  @menu, @new_id,@pc_id
			--冲销成本
			exec p_cyj_pos_sale @menu,@new_id
			select @lastnum = @new_id
			
-- 套菜冲销, 处理明细
			select @app_id= @new_id
			declare std_mx_cur cursor for
				select inumber from pos_dish where menu=@menu and sta='M' and id_master=@old_id order by inumber
			open std_mx_cur
			fetch std_mx_cur into @cur_id
			while @@sqlstatus = 0
			begin
				select @app_id  = @app_id  + 1
				select @printid = @printid + 1
				insert pos_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,price,number,amount,dsc,srv,tax,empno,bdate,remark,special,sta,id_cancel,id_master,kitchen,printid,flag,tableno)
				   select @menu,@app_id,plucode,sort,id,code,name1,name2,unit,price,- number,-amount,-dsc,-srv,-tax,@empno,@bdate,@add_remark,special,'2',@cur_id,@new_id,kitchen,@printid,flag,tableno
						from pos_dish where menu=@menu and inumber = @cur_id
				--数据插入pos_dishcard
				exec p_cq_newpos_input_dishcard  @menu, @app_id,@pc_id
				--冲销明细成本
				exec p_cyj_pos_sale @menu,@app_id

				select @lastnum = @app_id
				fetch std_mx_cur into @cur_id
			end
			close std_mx_cur
			deallocate cursor std_mx_cur
			update pos_menu set lastnum = @lastnum  from pos_menu where menu = @menu
-- 更新被冲dish的状态
			update pos_dish set sta = @newsta where menu = @menu and inumber = @old_id
			update pos_assess set number1 = number1 + @number where id = @id
			update pos_dish set sta='1' where menu=@menu and sta='M' and id_master=@old_id
			select @charge = amount from pos_menu where menu = @menu
			select @ret = 0,@msg = "成功"
		end

-- 服务费合计
	update pos_dish set amount = isnull((select sum(srv) from pos_dish where menu = @menu and charindex(rtrim(ltrim(code)), 'YZ') =0 and charindex(sta,'03579')>0 ),0) where menu = @menu and rtrim(ltrim(code)) = 'Z'
-- 税合计
	update pos_dish set amount = isnull((select sum(tax) from pos_dish where menu = @menu and charindex(rtrim(ltrim(code)), 'YZ') =0 and charindex(sta,'03579')>0 ),0) where menu = @menu and rtrim(ltrim(code)) = 'Y'
-- 计算menu合计
	update pos_menu set amount = isnull((select sum(amount) - sum(dsc) + sum(srv) + sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),0),
		amount0 = isnull((select sum(amount) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),0),
		dsc = isnull((select sum(dsc) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),0),
		srv = isnull((select sum(srv) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),0),
		tax = isnull((select sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),0)
		where menu = @menu
-- 计算餐桌合计
	update pos_tblav set amount = isnull((select sum(amount) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0 )
	+ (select sum(srv) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	+ (select sum(tax) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	- (select sum(dsc) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0), 0)
	from pos_tblav a where a.menu = @menu  and sta ='7'
  
 end
commit tran 
if @retmode = 'R'
	select @ret,@msg,@charge
return 0;