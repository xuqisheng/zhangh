drop proc p_cyj_pos_order_to_dish;
create proc p_cyj_pos_order_to_dish
	@pc_id	char(4),
	@menu		char(10),
	@empno	char(10),
	@kitprn	char(1)	= 'T'			-- 本次落单是否厨房打印
as
-------------------------------------------------------------------------------*/
--
--		点菜： pos_order 导入 pos_dish, x50111 后 版本
--
-------------------------------------------------------------------------------*/
declare
	@ret				int,
	@msg				char(60),
	@orderid			int,
	@menuid			int,
	@printid			int,
	@sta				char(1),
	@special			char(1),
	@remark			char(15),
	@mshift			char(1),
	@mdate			datetime,
	@timecode		char(2),
	@plu_number		int,
	@pccode			char(3),
	@code				char(15),
	@tableno			char(4),
	@mode				char(3),
	@times			int,
	@minute			int,
	@minute1			int,
	@minute2			int,
	@deptno			char(2),
   @hxcode        char(4),
	@discount_rate	money,
	@serve_rate		money,
	@tax_rate		money,
	@serve_charge0	money,
	@tax_charge0	money,
	@serve_charge	money,
	@tax_charge		money,
	@charge			money,
	@amount0			money,
	@amount			money,
	@number			money,
	@number0			money,
	@number1			money,
   @hxnumber      money,
	@timestamp_old	varbinary(8),
	@timestamp_new	varbinary(8),
	@inumber			integer,
	@inumber1		integer,
	@sort				char(4),
	@code1			char(10),
	@plucode			char(2),
	@orderno			char(10),
	@siteno			char(1),
	@flag				char(30),
	@flag0			char(30),
	@begin			datetime,
	@end				datetime,
	@stdmx_id		int,
	@mx_id			int,
	@master_id		int,
	@bdate			datetime,
	@name1			char(30),
	@empno1			char(10),
	@pinumber		integer,
	@price			money,
	@cost				money,
	@cost_f			money,            -- 成本率
	@kitchen			char(20),
	@flag19			char(1),
	@sum_amount		money,     	 --套菜明细金额和，用于分摊套菜总金额
	@id_master		int,
	@tc_price		money,
	@tc_amount		money

select @bdate = bdate1 from sysdata

select @ret = 0,@msg = "成功"

if exists(select 1 from pos_menu where menu= @menu and sta ='3' )
	begin
	select @ret = 1, @msg = "该单已结账"
	select @ret, @msg 
	return 0
	end
if exists(select 1 from pos_menu where menu= @menu and sta ='7' )
	begin
	select @ret = 1, @msg = "该单已删除"
	select @ret, @msg 
	return 0
	end

if not exists(select 1 	from pos_order where pc_id = @pc_id and menu = @menu)
	begin
	select @ret = 0, @msg = "没有要处理的数据"
	select @ret, @msg 
	return 0
	end

select * into #order from pos_order where 1 = 2

begin tran
save  tran p_pos_order_to_dish_s1

update pos_menu set sta = sta where menu = @menu 
select @menuid =  lastnum + 1, @mdate = bdate, @mshift = shift, @pccode = pccode,@deptno = deptno,@mode = mode,
	@serve_rate = serve_rate,@tax_rate = tax_rate,@discount_rate = dsc_rate from pos_menu where menu = @menu

-- 处理已点套菜加明细
-- 处理套菜明细对套菜总价格、总金额的分摊FHB Modified At 20080609
delete #order
insert into #order select * from pos_order where pc_id = @pc_id and menu = @menu  
	and inumber1 in (select inumber from pos_dish where menu = @menu and substring(flag, 1, 1)='T')

declare dishstd_cur cursor for select pinumber,inumber, id, kitchen,price from #order order by inumber
open dishstd_cur
fetch dishstd_cur into @pinumber,@inumber, @orderid, @kitchen,@price
while @@sqlstatus = 0
	begin
	select @cost = cost,@cost_f = cost_f from pos_price where id = @orderid and inumber = @pinumber
	if @cost = 0 
		select @cost = @cost_f * @price
	select @printid = isnull(max(printid)+1,1) from pos_dish 
	if @empno1 is null or @empno1 = ''
		select @empno1 = isnull(cook,'') from pos_plu_cook where id = @orderid    --FHB Modified At 20081124
	if @empno1 is null 
		select @empno1 = ''
	if @kitchen = '' or @kitchen is null
		exec p_cq_pos_get_printer @pccode,@orderid,@kitchen output
	select @sort = sort, @plucode = plucode,@flag19 = flag19 from pos_plu where id = @orderid
	insert pos_dish(menu,inumber,pinumber,plucode,sort,id,printid,code,number,price,amount,pamount,name1,name2,unit,empno,empno1,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,outno,flag,cook,kitchen,kit_ref,flag19,flag19_use)
		select @menu,@menuid,@pinumber,@plucode,sort,@orderid,@printid,code,number,price,amount,isnull(number*@cost, 0),name1,name2,unit,@empno,@empno1,@mdate,'','','M', 0, inumber1,'',0,0,0,orderno,tableno,siteno,outno,flag,cook,@kitchen,kit_ref,@flag19,''
		from #order where inumber = @inumber 
	update pos_order_cook set inumber = @menuid,sta='0' where  menu =@menu and inumber = @inumber1 and sta ='1' --配菜信息对应到pos_dish
	--销售(成本计算)FHB Modified At 20080609	                
	exec p_cyj_pos_sale  @menu, @menuid
	
	select @menuid = @menuid + 1
	fetch dishstd_cur into @pinumber,@inumber, @orderid, @kitchen,@price
	end
close dishstd_cur
deallocate cursor dishstd_cur


delete #order
insert #order select * from pos_order where menu = @menu and pc_id = @pc_id and inumber1 =0 order by inumber

declare order_cur cursor for
	select pinumber,inumber, id, sta, special, remark, code, amount, number, name1, flag, empno1,kitchen,price
		from #order where pc_id = @pc_id and menu = @menu order by inumber
open order_cur
fetch order_cur into @pinumber,@inumber, @orderid, @sta, @special, @remark, @code,@amount, @number0, @name1, @flag, @empno1,@kitchen,@price
while @@sqlstatus = 0
	begin

	                                                          
	select @number = number, @number1 = number1 from pos_assess where bdate = @bdate and id = @orderid 
	if @@rowcount = 1
		begin                                                                                                                                                                                                                     
		update pos_assess set number1= number1 + @number0 from pos_assess where bdate = @bdate and id = @orderid
		update pos_assess set payout = 'T' where bdate = @bdate and id = @orderid and number1 >= number + number2
		end
	-- 计时菜算金额
	select @timecode = timecode, @sort = sort, @plucode = plucode,@flag19 = flag19 from pos_plu where id = @orderid
   select @tableno = tableno from #order where id=@orderid                                   
	if @special = 'S'
		begin
		select @times = 1
		if rtrim(@flag) = ''
			select @flag = 'R'               
		else
			select @flag = rtrim(@flag) + 'R'               
		select @begin = getdate(),@end = getdate()
		end
--取得菜的成本金额,放入dish
	select @cost = cost,@cost_f = cost_f from pos_price where id = @orderid and inumber = @pinumber
	if @cost = 0 
		select @cost = @cost_f * @price
--取得厨房代码
	if @kitchen = '' or @kitchen is null 
		exec p_cq_pos_get_printer @pccode,@orderid,@kitchen output
----
	select @amount0 = @amount
	select @printid = isnull(max(printid)+1,1) from pos_dish 
	insert pos_dish(menu,inumber,pinumber,plucode,sort,id,printid,code,number,price,amount,pamount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,outno,flag,date1,date2,empno1,cook,kitchen,kit_ref,flag19,flag19_use)
		select menu,@menuid,@pinumber,@plucode,sort,@orderid,@printid,code,number,price,amount,isnull(number*@cost, 0),name1,name2,unit,@empno,@mdate,remark,special,@sta, inumber1,inumber1,'',0,0,0,orderno,  tableno,siteno,outno,isnull(@flag, ''),@begin,@end,@empno1,cook,@kitchen,kit_ref,@flag19,''
		from #order where menu = @menu and pc_id = @pc_id and inumber = @inumber
	update pos_order_cook set inumber = @menuid,sta='0' where  menu =@menu and inumber = @inumber and sta ='1' --配菜信息对应到pos_dish

--数据插入pos_dishcard
	if @kitprn = 'T'
		exec p_cq_newpos_input_dishcard  @menu, @menuid,@pc_id
--销售(成本计算)	                
	exec p_cyj_pos_sale  @menu, @menuid
	-- 计算服务费，折扣，税	
	if charindex(@special,'XT') = 0  and charindex(@sta, '03579') > 0 
		begin
		-- 计算服务费，折扣，税采用的代码标准是小类加代码   
		select @pccode = rtrim(@pccode)                    
		select @code1 = @sort+@code
		exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@code1,@amount,@discount_rate,@result = @amount output
		exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@code1,@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output
		exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@code1,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
		if @sta = '3'  -- 事先赠送
			select @amount = 0, @serve_charge = 0, @tax_charge = 0
		update pos_dish set dsc =  amount - @amount 	where menu = @menu and inumber = @menuid
		update pos_dish set srv =  @serve_charge 	 where menu = @menu and inumber = @menuid
		update pos_dish set tax =  @tax_charge 	 where menu = @menu and inumber = @menuid
		
		update pos_dish set amount = amount + @serve_charge0, dsc = dsc + @serve_charge0 - @serve_charge
		 where menu = @menu and code = "Z"
		update pos_dish set amount = amount + @tax_charge0, dsc = dsc + @tax_charge0 - @tax_charge
		 where menu = @menu and code = "Y"
		end

-- 套菜处理	和 一菜多吃的情况    		cq add                                                         
	if substring(@flag,1,1) = 'T' and exists(select 1 from pos_order where pc_id = @pc_id and inumber1 = @inumber and menu = @menu)
		begin
		select @master_id = @menuid ,@stdmx_id = @menuid 
		select  @orderno = orderno,@tableno = tableno,@siteno = siteno from #order where menu=@menu and pc_id = @pc_id and id = @orderid
		declare std_cursor cursor for select id,kitchen,inumber,pinumber,price from pos_order where pc_id = @pc_id and inumber1 = @inumber and menu = @menu order by inumber
		open std_cursor
		fetch std_cursor into @mx_id,@kitchen,@inumber1,@pinumber,@price
		while	@@sqlstatus = 0
			begin
			select @stdmx_id = @stdmx_id + 1
			select @plucode = plucode, @sort = sort,@flag19 = flag19  from pos_plu where id = @mx_id
			select @printid = isnull(max(printid)+1,1) from pos_dish 
			--取得厨房代码
			if @kitchen = '' or @kitchen is null
				exec p_cq_pos_get_printer @pccode,@mx_id,@kitchen output
			----
		--取得菜的成本金额,放入dish
			select @cost = cost,@cost_f = cost_f from pos_price where id = @mx_id and inumber = @pinumber
			if @cost = 0 
				select @cost = @cost_f * @price
			if @empno1 is null or @empno1 = ''
				select @empno1 = isnull(cook,'') from pos_plu_cook where id = @mx_id    --FHB Modified At 20081124
			if @empno1 is null 
				select @empno1 = ''
			insert pos_dish(menu,inumber,pinumber,plucode,sort,id,printid,code,number,price,amount,pamount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,outno,flag,empno1,cook,kitchen,kit_ref,flag19,flag19_use)
				select @menu,@stdmx_id,@pinumber,@plucode,@sort,@mx_id,@printid,code,number*@number0,price,amount*@number0,isnull(number*@number0*@cost, 0),name1,name2,unit,@empno,@mdate,'','','M', 0,@master_id,'',0,0,0,@orderno,@tableno,@siteno,outno,flag,@empno1,cook,@kitchen,kit_ref,@flag19,''
				from pos_order where pc_id = @pc_id and inumber1 = @inumber and inumber=@inumber1 and menu = @menu
			update pos_order_cook set inumber = @stdmx_id,sta='0' where  menu =@menu and inumber = @inumber1 and sta ='1' --配菜信息对应到pos_dish
			--数据插入pos_dishcard
			if @kitprn = 'T'
				exec p_cq_newpos_input_dishcard  @menu, @stdmx_id,@pc_id
			--销售(成本计算)	                
			exec p_cyj_pos_sale  @menu, @stdmx_id

			fetch std_cursor into @mx_id,@kitchen,@inumber1,@pinumber,@price
			end
		select @menuid = @stdmx_id
		close std_cursor
		deallocate cursor std_cursor
		end
	fetch order_cur into @pinumber,@inumber, @orderid, @sta, @special, @remark, @code,  @amount, @number0, @name1, @flag,@empno1,@kitchen, @price
	select @menuid = @menuid + 1
	end
close order_cur
deallocate cursor order_cur

-- 处理套菜明细对套菜总价格、总金额的分摊FHB Modified At 20080609
/*declare priceft_cur cursor for select a.id_master,isnull(sum(a.number*a.price),0) from pos_dish a,pos_dish b where a.id_master = b.inumber and b.menu = @menu and a.menu = b.menu group by a.id_master
open priceft_cur 
fetch priceft_cur into @id_master,@sum_amount
while @@sqlstatus = 0
begin
	select @tc_price = isnull(price,0),@tc_amount = isnull(amount,0) from pos_dish where menu = @menu and inumber = @id_master
	update pos_dish set amount = round(number*price*@tc_amount/@sum_amount,2) where id_master = @id_master and menu = @menu and @sum_amount > 0
	update pos_dish set price = round(amount/number,2) where id_master = @id_master and menu = @menu and @sum_amount > 0
	fetch priceft_cur into @id_master,@sum_amount
end
close priceft_cur
deallocate cursor priceft_cur*/
exec p_fhb_pos_tcmxft @menu
--                                                                   


-- 计算主单的服务费，折扣，税	
update pos_menu set srv = (select sum(srv) from pos_dish where menu = @menu and charindex(sta,'03579')>0)
	where menu = @menu
update pos_menu set tax = (select sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0)
	where menu = @menu
update pos_menu set dsc = (select sum(dsc) from pos_dish where menu = @menu and charindex(sta,'03579')>0)
	where menu = @menu
update pos_menu set amount0 = (select sum(amount) from pos_dish where menu = @menu and charindex(sta,'03579')>0)
	where menu = @menu
update pos_menu set amount = (select sum(amount) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	+ (select sum(srv) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	+ (select sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	- (select sum(dsc) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	where menu = @menu
update pos_menu set lastnum = @menuid  - 1 where menu = @menu
-- 计算没台的消费额
update pos_tblav set amount = isnull((select sum(amount) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0 )
	+ (select sum(srv) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	+ (select sum(tax) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	- (select sum(dsc) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0), 0)
	from pos_tblav a where a.menu = @menu  and sta ='7'
delete pos_order where menu = @menu and pc_id = @pc_id

exec  p_cyj_pos_update_menu  @pc_id,@menu
goout:
if @ret <> 0 
	rollback tran p_pos_order_to_dish_s1

commit tran
select @ret,@msg;