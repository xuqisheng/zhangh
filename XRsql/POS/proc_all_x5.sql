if exists(select 1 from sysobjects where name = 'p_cq_pos_cond_sale' and type = 'P')
	drop proc p_cq_pos_cond_sale;

create proc p_cq_pos_cond_sale
	@menu			char(10),
	@menuid		integer,
	@id			integer,
	@pinumber	integer
as
declare
		@empno		char(10),
		@bdate		datetime,
		@number		integer,
		@amount		money
		

select @empno = empno ,@bdate = bdate,@number = number,@amount = amount from pos_dish where menu = @menu and inumber = @menuid
insert pos_sale
	select @menu,@menuid,a.pccode,a.id,@number,@amount,a.inumber,a.condid,b.unit,b.descript,@number*a.number,
		@number*a.number*b.price,@empno,@bdate,getdate()
		from pos_pldef_price a ,pos_condst b where a.condid = b.condid and a.id = @id and a.inumber = @pinumber
return 0
;

if exists(select 1 from sysobjects where name = 'p_cq_pos_get_printer' and type = 'P')
	drop proc p_cq_pos_get_printer;

create proc p_cq_pos_get_printer
	@pccode		char(3),
	@id			integer,
	@kitchen		char(20) output
as
declare
		@plucode		char(6),
		@pluid		integer


select @pluid = convert(integer,value) from sysoption where catalog = 'pos' and item = 'pluid'
select @plucode = plucode+sort from pos_plu where id = @id 
--先找本菜在该营业点是否有定义
if exists(select 1 from pos_prnscope where pccode = @pccode and id = @id and pluid = @pluid)	  
	select @kitchen = kitchens from pos_prnscope where pccode = @pccode and id = @id and pluid = @pluid
else
	begin
--再找本菜是否有默认的定义
	if exists(select 1 from pos_prnscope where pccode = '###' and id = @id and pluid = @pluid)	  
		select @kitchen = kitchens from pos_prnscope where pccode = '###' and id = @id and pluid = @pluid
	else
		begin
--接着找本菜对应的类在该营业点是否有定义
		if exists(select 1 from pos_prnscope where pccode = @pccode and plucode+plusort = @plucode and pluid = @pluid)	  
			select @kitchen = kitchens from pos_prnscope where pccode = @pccode and plucode+plusort = @plucode and pluid = @pluid
		else
			begin
--最后找本菜对应的类是否有默认定义
			if exists(select 1 from pos_prnscope where pccode = '###' and plucode+plusort = @plucode and pluid = @pluid)	  
				select @kitchen = kitchens from pos_prnscope where pccode = '###' and plucode+plusort = @plucode and pluid = @pluid
			else
				select @kitchen = ''
			end
		end
	end

return 0
;

drop procedure p_cq_pos_retrieve_likeplu;
create proc p_cq_pos_retrieve_likeplu
		@shift				char(1),
		@menu					char(10)
 
as
declare 
		@id					integer,
		@inumber				integer,
		@unit					char(4),
		@price				money,
		@pccode_1			char(3),
		@pccode				char(3),
		@ii					integer,
		@add					integer

create table #like
(
	id			integer,
	plucode	char(2),
	sort		char(4),
	code		char(6),
	menu		char(5)
)
select @pccode = pccode from pos_menu where menu = @menu
insert #like select a.id,a.plucode,a.sort,a.code,a.menu from pos_plu a ,pos_hgsplu b,pos_menu c where a.id = b.id and b.haccnt = c.haccnt and c.menu = @menu

create table #plu 
(
	pccode		char(3),
	pccode1		char(100),
	id				integer,
	code			char(6),
	helpcode		char(30),
	plucode		char(2),
	dept			char(1),
	sort			char(4),
	name1			char(30),
	name2			char(50),
	unit1			char(4),
	price1		money,
	inumber1		integer,
	unit2			char(4),
	price2		money,
	inumber2		integer,
	unit3			char(4),
	price3		money,
	inumber3		integer,
	unit4			char(4),
	price4		money,
	inumber4		integer,
	adds			integer
)


declare c_plu cursor for 
	select a.pccode,a.id,a.inumber,a.unit,a.price from pos_price a,#like b where 
	a.id= b.id  and a.halt = 'F' and substring(b.menu,convert(int,@shift),1) = '1' and pccode='###' order by a.id,a.inumber
open c_plu
fetch c_plu into @pccode_1,@id,@inumber,@unit,@price
while @@sqlstatus = 0 
	begin
	select @add = 0
	select @pccode = @pccode_1
	select @add = adds from #plu where pccode = @pccode and id = @id
	if @add = 0 or @add is null
		insert #plu select @pccode,'',@id,'','','','','','','',@unit,@price,@inumber,'',0,0,'',0,0,'',0,0,1
	if @add = 1 
		update #plu set inumber2 = @inumber,unit2 = @unit,price2 = @price,adds = @add + 1 where id = @id and pccode = @pccode
	if @add = 2 
		update #plu set inumber3 = @inumber,unit3 = @unit,price3 = @price,adds = @add + 1 where id = @id and pccode = @pccode
//	if @add = 3 
//		update #plu set inumber4 = @inumber,unit4 = @unit,price4 = @price,adds = @add + 1 where id = @id and pccode = @pccode
	if @add >=3 
		update #plu set adds = @add + 1 where id = @id and pccode = @pccode
	fetch c_plu into @pccode_1,@id,@inumber,@unit,@price
	end
close c_plu
deallocate cursor c_plu

declare c_plu1 cursor for 
	select a.pccode,a.id,a.inumber,a.unit,a.price from pos_price a,#like b where 
	a.id= b.id and a.halt = 'F' and substring(b.menu,convert(int,@shift),1) = '1' and pccode <> '###' and a.pccode = @pccode order by a.id,a.inumber
open c_plu1
fetch c_plu1 into @pccode_1,@id,@inumber,@unit,@price
while @@sqlstatus = 0 
	begin
	select @add = 0
	select @pccode = @pccode_1
	update #plu set pccode1 = pccode1 + @pccode+'#' where id = @id and pccode = '###' and charindex(@pccode,pccode1)=0
	select @add = adds from #plu where pccode = @pccode and id = @id
	if @add = 0 or @add is null
		insert #plu select @pccode,'',@id,'','','','','','','',@unit,@price,@inumber,'',0,0,'',0,0,'',0,0,1
	if @add = 1 
		update #plu set inumber2 = @inumber,unit2 = @unit,price2 = @price,adds = @add + 1 where id = @id and pccode = @pccode
	if @add = 2 
		update #plu set inumber3 = @inumber,unit3 = @unit,price3 = @price,adds = @add + 1 where id = @id and pccode = @pccode
//	if @add = 3 
//		update #plu set inumber4 = @inumber,unit4 = @unit,price4 = @price,adds = @add + 1 where id = @id and pccode = @pccode
	if @add >=3 
		update #plu set adds = @add + 1 where id = @id and pccode = @pccode
	fetch c_plu1 into @pccode_1,@id,@inumber,@unit,@price
	end
close c_plu1
deallocate cursor c_plu1


select a.pccode,a.pccode1,b.code,a.id,b.helpcode,dept=substring(b.code,1,1),b.sort,b.name1,b.name2,
	a.unit1,a.price1,a.inumber1,a.unit2,a.price2,a.inumber2,
	a.unit3,a.price3,a.inumber3,a.unit4,a.price4,a.inumber4,a.adds,number=1.000,b.condgp1,b.condgp2,b.flag0,b.flag1,b.flag2,b.flag3,b.flag4,b.flag5,b.flag6,b.flag7,b.flag8,b.flag9,b.th_sort from #plu a,pos_plu b where a.id = b.id
//
return 0;

drop procedure p_cq_pos_retrieve_plu;
create proc p_cq_pos_retrieve_plu
		@plucodes			char(120),
		@shift				char(1),
		@pccodes				char(200)
 
as
declare 
		@id					integer,
		@inumber				integer,
		@unit					char(4),
		@price				money,
		@pccode_1			char(3),
		@pccode				char(3),
		@ii					integer,
		@add					integer

create table #plu 
(
	pccode		char(3),
	pccode1		char(100),
	id				integer,
	code			char(6),
	helpcode		char(30),
	plucode		char(2),
	dept			char(1),
	sort			char(4),
	name1			char(30),
	name2			char(50),
	unit1			char(4),
	price1		money,
	inumber1		integer,
	unit2			char(4),
	price2		money,
	inumber2		integer,
	unit3			char(4),
	price3		money,
	inumber3		integer,
	unit4			char(4),
	price4		money,
	inumber4		integer,
	adds			integer
)


declare c_plu cursor for 
	select a.pccode,a.id,a.inumber,a.unit,a.price from pos_price a,pos_plu b where 
	a.id= b.id and charindex(b.plucode, @plucodes) > 0 and a.halt = 'F' and substring(b.menu,convert(int,@shift),1) = '1' and pccode='###' order by a.id,a.inumber
open c_plu
fetch c_plu into @pccode_1,@id,@inumber,@unit,@price
while @@sqlstatus = 0 
	begin
	select @add = 0
	select @pccode = @pccode_1
	select @add = adds from #plu where pccode = @pccode and id = @id
	if @add = 0 or @add is null
		insert #plu select @pccode,'',@id,'','','','','','','',@unit,@price,@inumber,'',0,0,'',0,0,'',0,0,1
	if @add = 1 
		update #plu set inumber2 = @inumber,unit2 = @unit,price2 = @price,adds = @add + 1 where id = @id and pccode = @pccode
	if @add = 2 
		update #plu set inumber3 = @inumber,unit3 = @unit,price3 = @price,adds = @add + 1 where id = @id and pccode = @pccode
//	if @add = 3 
//		update #plu set inumber4 = @inumber,unit4 = @unit,price4 = @price,adds = @add + 1 where id = @id and pccode = @pccode
	if @add >=3 
		update #plu set adds = @add + 1 where id = @id and pccode = @pccode
	fetch c_plu into @pccode_1,@id,@inumber,@unit,@price
	end
close c_plu
deallocate cursor c_plu

declare c_plu1 cursor for 
	select a.pccode,a.id,a.inumber,a.unit,a.price from pos_price a,pos_plu b where 
	a.id= b.id and charindex(b.plucode, @plucodes) > 0 and a.halt = 'F' and substring(b.menu,convert(int,@shift),1) = '1' and pccode <> '###' and charindex(pccode,@pccodes)>0 order by a.id,a.inumber
open c_plu1
fetch c_plu1 into @pccode_1,@id,@inumber,@unit,@price
while @@sqlstatus = 0 
	begin
	select @add = 0
	select @pccode = @pccode_1
	update #plu set pccode1 = pccode1 + @pccode+'#' where id = @id and pccode = '###' and charindex(@pccode,pccode1)=0
	select @add = adds from #plu where pccode = @pccode and id = @id
	if @add = 0 or @add is null
		insert #plu select @pccode,'',@id,'','','','','','','',@unit,@price,@inumber,'',0,0,'',0,0,'',0,0,1
	if @add = 1 
		update #plu set inumber2 = @inumber,unit2 = @unit,price2 = @price,adds = @add + 1 where id = @id and pccode = @pccode
	if @add = 2 
		update #plu set inumber3 = @inumber,unit3 = @unit,price3 = @price,adds = @add + 1 where id = @id and pccode = @pccode
//	if @add = 3 
//		update #plu set inumber4 = @inumber,unit4 = @unit,price4 = @price,adds = @add + 1 where id = @id and pccode = @pccode
	if @add >=3 
		update #plu set adds = @add + 1 where id = @id and pccode = @pccode
	fetch c_plu1 into @pccode_1,@id,@inumber,@unit,@price
	end
close c_plu1
deallocate cursor c_plu1


select a.pccode,a.pccode1,b.code,a.id,b.helpcode,dept=substring(b.code,1,1),b.sort,b.name1,b.name2,
	a.unit1,a.price1,a.inumber1,a.unit2,a.price2,a.inumber2,
	a.unit3,a.price3,a.inumber3,a.unit4,a.price4,a.inumber4,a.adds,number=1.000,b.condgp1,b.condgp2,b.flag0,b.flag1,b.flag2,b.flag3,b.flag4,b.flag5,b.flag6,b.flag7,b.flag8,b.flag9,b.th_sort from #plu a,pos_plu b where a.id = b.id
//
return 0;

/*--------------------------------------------------------------------------------------------------*/
//
//	调整dish
//	赠送, 全免, 打折, 免服务费, 取消 -- 赠送, 全免, 打折, 免服务费
//	修改分量  --  针对海鲜管理
//	赠送, 全免 -- 不改amount, 修改dsc = amount
//	单菜赠送       special = 'E'， 结账时自动加一款待付款（detail中不分摊）
//
/*--------------------------------------------------------------------------------------------------*/

if exists(select 1 from sysobjects where name = 'p_cyj_pos_adjust_dish' and type ='P')
	drop proc p_cyj_pos_adjust_dish;
create proc p_cyj_pos_adjust_dish
	@menu			char(10),
	@empno		char(10),
	@old_id		integer,
	@pc_id		char(8),
	@opmode		char(1),
	@reason		char(3),
	@setamount	money
as
declare
	@code				char(6),
	@plucode			char(10),         // sort + code 用于模式计算        
	@id				int,
	@plu_amount		money,            // 折扣后金额
	@plu_amount0	money,
	@remark			char(15),
	@opmodesta		char(1),          

	@ret			integer,
	@msg			char(60),
	@bdate		datetime,
	@p_mode		char(1)	,
	@deptno		char(2)	,
	@pccode		char(10)	,
	@mode			char(3),
	@new_id		integer	,
	@name1		char(20)	,
	@name2		char(30)	,
	@amount		money	,              // 原金额
	@number		money	,

	@dsc_rate		money,
	@serve_rate		money,
	@tax_rate		money,

	@serve_charge0	money,
	@tax_charge0	money,
	@serve_charge	money,
	@tax_charge		money,
	@charge			money,

	@special				char(1),
	@sta					char(1),
	@dish_sta			char(1),
	@timestamp_old		varbinary(8),
	@timestamp_new		varbinary(8),
	@action 				char(4),
 	@newamount			money,
	@hx					char(1),
	@oldamount 			money,
	@srv					money,			//服务费		
	@tax				 	money,         //税
	@dsc				 	money          //优惠  

if @opmode='F'	
	select @newamount = @setamount, @hx='T'
else
	select @hx = 'F'

select @bdate  = bdate1 from sysdata
select @p_mode = value  from sysoption where catalog = "pos_dish" and item = "p_mode"

if @opmode = 'R'
   select @action = '赠送',@opmode='3'
else if @opmode='N'
   select @action = '全免',@opmode='5'
else if @opmode='D'
   select @action = '折扣',@opmode='7'
else if @opmode='U'
   select @action = '免服务费'
else if @opmode='E'
   select @action = '单菜款待'
else if @opmode='C'
   select @action = '取消',@opmode='0'
else if @opmode='F'								// 修改海鲜分量  -- gds 
   select @action = '海鲜份量调整', @opmode='0'
else
begin
   select @ret=1,@msg='无效操作'
   return 0
end

select @opmodesta = @opmode
begin tran
save  tran p_hry_pos_adjust_dish_s1

select @timestamp_old = timestamp from pos_menu where menu = @menu
update pos_menu set pc_id = @pc_id where menu = @menu
select @code = code, @number = number, @amount = amount, @plu_amount = amount - dsc,@dsc = dsc,@srv = srv,@tax = tax,
		 @dish_sta = sta, @remark = remark,@special=special, @id = id, @plucode = sort + code
  from pos_dish where menu = @menu and inumber = @old_id
if charindex(@sta,'12')>0
	begin
	if @dish_sta = '1'
		select @ret = 1,@msg = "当前帐目已被冲销,不能进行"+@action+"处理"
	else
		select @ret = 1,@msg = "当前帐目被用来冲销,不能进行"+@action+"处理"
	commit tran
	select @ret,@msg,@charge
	return 0
	end

select @deptno = deptno,@pccode = pccode,@new_id = lastnum + 1,@sta = sta,@mode = mode,
		 @serve_rate = serve_rate,@tax_rate = tax_rate,@dsc_rate = dsc_rate
  from pos_menu where menu = @menu
if @@rowcount = 0
	select @ret = 1,@msg = "主单" + @menu + "已不存在或已销单"
else if @sta ='3'
	select @ret = 1,@msg = "主单" + @menu + "已被其他收银员结帐"
else
	begin
	select @name1 = name1,@name2 = name2  from pos_plu where id = @id
	if @@rowcount = 0
		select @ret = 1,@msg = "菜号" + rtrim(@code) + "已不存在"
	else
		begin
		select @serve_charge0 = 0,@serve_charge = 0,@tax_charge0 = 0,@tax_charge = 0,@charge = 0
		if @special <> 'T' and @special <> 'X'
			begin

			// gds  - 海鲜
			if @hx='T' 
				begin
				// 有效性
//				if not exists(select 1 from pos_hxdef where pccode=@pccode and @code like code+'%')
//					select @ret = 1,@msg = "该菜不属于海鲜类 !"
//				else if @newamount = @number 
//					select @ret = 1,@msg = "份量没有改变 !"

				if @ret = 1 
					goto gout					
				else
					select @setamount = round(@newamount * @plu_amount / @number,2)
				end
			if charindex(@opmode , '35') > 0     // 赠送，全免 dsc = amount, srv = 0 , tax = 0
				select @dsc = @amount, @srv = 0, @tax = 0 
			else if @opmode='7'                  // 折扣处理, 重算服务费，税
				begin
				select @dsc = @setamount
				exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@plucode,@amount,@dsc,@serve_rate,@result0 = @serve_charge0 output,@result = @srv output
				exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@plucode,@amount,@dsc,@tax_rate,@result0 = @tax_charge0 output,@result = @tax output
				select @dsc = @amount - @dsc
				end
			else if @opmode='0'                   // 取消, 从菜谱中取回原值; 重算优惠，服务费，税
				begin
				exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@plucode,@amount,@dsc_rate,@result = @dsc output
				exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@plucode,@amount,@dsc,@serve_rate,@result0 = @serve_charge0 output,@result = @srv output
				exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@plucode,@amount,@dsc,@tax_rate,@result0 = @tax_charge0 output,@result = @tax output
				select @dsc = @amount - @dsc
				end
			else if  @opmode = 'U'   				  //     单菜免服务费, 不需算服务费, 附加税
				select @srv = 0 , @tax = 0, @opmodesta = @dish_sta, @special = 'U' 
			else if  @opmode = 'E'   				  //     单菜款待
				select @special = 'E'

			if  @opmode = '0' and  @special = 'E' //   取消单菜款待
				select @special = 'N', @opmodesta = '0'

			if  @opmode = '0' and  @special = 'U' //   取消免服务费
				begin
				exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@plucode,@amount,@plu_amount,@serve_rate,@result0 = @serve_charge0 output,@result = @srv output
				select @opmodesta = @dish_sta, @special = 'N' 
				end
			if substring(@remark,1,3)=@empno and @opmode='0'
				select @remark=''
			else if @opmode<>'0'
				select @remark=@empno
			else if @hx<>'T'
				select @remark=@empno+'-',@setamount=@oldamount
			
			if  @special = 'E' // 单菜款待
				select @opmodesta = '0'

			if @hx='T'
				update pos_dish set number=@newamount, amount=@setamount where menu = @menu and inumber = @old_id
			else
				update pos_dish set sta=@opmodesta,remark=@reason,dsc =  @dsc,srv = @srv, tax = @tax, reason=@reason,special = @special
					where menu = @menu and inumber = @old_id

--			update pos_menu set amount = (select sum(amount - dsc + srv + tax) from pos_dish where menu = @menu and charindex(sta, '03579') > 0)
--			 where menu = @menu
			update pos_menu set amount = (select sum(amount) - sum(dsc) + sum(srv) + sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
				amount0 = (select sum(amount) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
				dsc = (select sum(dsc) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
				srv = (select sum(srv) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
				tax = (select sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0)
				where menu = @menu


			select @charge = amount,@timestamp_new = timestamp from pos_menu where menu = @menu
			select @ret = 0,@msg = "成功"
			end
		 end
   end



gout:
if @ret <> 0 
	rollback tran p_hry_pos_adjust_dish_s1
commit tran 
//select @ret,@msg,@charge
return 0
;


if exists(select 1 from sysobjects where name = 'p_cyj_pos_cancel_dish' and type = 'P')
	drop proc p_cyj_pos_cancel_dish;

create proc p_cyj_pos_cancel_dish
	@menu			char(10),
	@empno		char(10),
	@old_id		integer,
	@pc_id		char(8),			          
	@add_remark	char(15)=NULL,
   @li_inumber integer
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
	@lastnum				int

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
				insert pos_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,number,amount,dsc,srv,tax,empno,empno1,bdate,remark,special,sta,id_cancel,id_master,orderno)
						select @menu,@new_id,plucode,sort,id,code,name1,name2,unit,-1 * number, -1 * amount,-1 * dsc,-1 * srv,-1 * tax,@empno,@empno1,@bdate,@add_remark,'C','2',id_cancel,id_master,orderno
				from pos_dish where menu = @menu and inumber = @old_id
				-- 吧台处理标志
				if exists(select 1 from pos_dish where menu = @menu and inumber = @old_id and charindex('B', upper(flag))>0)
					update pos_dish set flag = 'B' where menu = @menu and inumber = @new_id 
--	 			exec p_cyj_bar_pos_sale @menu, @new_id
				update pos_dish set special = 'C', sta = '1' from pos_dish where menu = @menu and inumber = @old_id
				update pos_menu set lastnum = lastnum + 1 from pos_menu where menu = @menu
				select @ret = 0,@msg = "ok"
				commit tran 
				select @ret,@msg,@charge
				return 0
				end

			select @newsta = convert(char(1),convert(int,@dish_sta) + 1)
			select @name1=name1,@name2=@name2 from pos_dish where menu=@menu and inumber=@old_id

			insert pos_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,number,amount,dsc,srv,tax,empno,empno1,bdate,remark,special,sta,id_cancel)
				   select @menu,@new_id,plucode,sort,id,@code,@name1,@name2,unit,-number,-amount,- dsc,- srv,- tax,@empno,@empno1,@bdate,@add_remark,@special,'2',@old_id
			from pos_dish where menu = @menu and inumber = @old_id
			select @lastnum = @new_id
			-- 吧台处理标志
			if exists(select 1 from pos_dish where menu = @menu and inumber = @old_id and charindex('B', upper(flag))>0)
				update pos_dish set flag = 'B' where menu = @menu and inumber = @new_id 
-- 			exec p_cyj_bar_pos_sale @menu, @new_id
	
-- 套菜冲销, 处理明细
			select @app_id= @new_id
			declare std_mx_cur cursor for
				select inumber from pos_dish where menu=@menu and sta='M' and id_master=@old_id order by id
			open std_mx_cur
			fetch std_mx_cur into @cur_id
			while @@sqlstatus = 0
			begin
				select @app_id = @app_id + 1
				insert pos_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,number,amount,dsc,srv,tax,empno,bdate,remark,special,sta,id_cancel,id_master)
				   select @menu,@app_id,plucode,sort,id,code,name1,name2,unit,- number,-amount,-dsc,-srv,-tax,@empno,@bdate,@add_remark,special,'2',@cur_id,@new_id
						from pos_dish where menu=@menu and id = @cur_id
				select @lastnum = @app_id
				-- 吧台处理标志
				if exists(select 1 from pos_dish where menu = @menu and inumber = @cur_id and charindex('B', upper(flag))>0)
					update pos_dish set flag = 'B' where menu = @menu and inumber = @app_id 
--	 			exec p_cyj_bar_pos_sale @menu, @app_id
				fetch std_mx_cur into @cur_id
			end
			close std_mx_cur
			deallocate cursor std_mx_cur
			update pos_menu set lastnum = @lastnum  from pos_menu where menu = @menu
-- 更新被冲dish的状态
			update pos_dish set sta = @newsta where menu = @menu and inumber = @old_id
-- 更新技师状态			                
			update pos_assess set number1 = number1 + @number where id = @id
			update pos_dish set sta='1' where menu=@menu and sta='M' and id_master=@old_id
			select @charge = amount from pos_menu where menu = @menu
			select @ret = 0,@msg = "成功"
		end

-- 服务费合计
	update pos_dish set amount = (select sum(srv) from pos_dish where menu = @menu and charindex(rtrim(ltrim(code)), 'YZ') =0 and charindex(sta,'03579')>0 ) where menu = @menu and rtrim(ltrim(code)) = 'Z'
-- 税合计
	update pos_dish set amount = (select sum(tax) from pos_dish where menu = @menu and charindex(rtrim(ltrim(code)), 'YZ') =0 and charindex(sta,'03579')>0 ) where menu = @menu and rtrim(ltrim(code)) = 'Y'
-- 计算menu合计
	update pos_menu set amount = (select sum(amount) - sum(dsc) + sum(srv) + sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		amount0 = (select sum(amount) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		dsc = (select sum(dsc) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		srv = (select sum(srv) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		tax = (select sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0)
		where menu = @menu
-- 计算餐桌合计
	update pos_tblav set amount = isnull((select sum(amount) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0 )
	+ (select sum(srv) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	+ (select sum(tax) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	- (select sum(dsc) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0), 0)
	from pos_tblav a where a.menu = @menu  and sta ='7'
  
 end
commit tran 
select @ret,@msg,@charge
return 0;


//alter table pos_int_pccode add start_time char(8);
//alter table pos_int_pccode add end_time char(8);

if exists(select * from sysobjects where name = 'p_cyj_pos_checkout' and type = 'P')
	drop proc p_cyj_pos_checkout;
create proc p_cyj_pos_checkout
	@pc_id	char(4), 
	@modu_id	char(2), 
	@shift	char(1), 
	@empno	char(10), 
	@menus	char(255), 
   @retmode	char(1),
   @option  char(5),
	@ret			int  output,
	@msg			char(60) output
as
--------------------------------------------------------------------------------------------------------
-- 
--	POS 结帐 
--	结帐临时表pos_checkout中放零头和冲定金内容, 零头要插入pos_pay, 冲定金更新定金行的menu0,inumber
--	有零头修改pos_menu的srv, 否则 amount <> amount0 + srv - dsc + tax
-- 转前台时不用pccode 取用pos_pccode.chgcode, 或者通过pos_int_pccode取费用码
-- 转前台有两种模式：直转和接口方式 sysoption : pos, using_interface
--------------------------------------------------------------------------------------------------------
declare
	@menu			char(10), 
	@menu0		char(10), 
	@menu1		char(10), 
   @lastnum		integer, 
   @lastnum1	integer, 
   @number		integer, 
   @inumber		integer, 
	@bdate		datetime,	 	            
	@today		datetime,	 	                
	@paycode		char(5), 		          
	@pccode		char(3),
   @chgcod     char(3), 		      
	@package		char(3), 		            
	@name1		varchar(20), 
	@name2		varchar(30), 
	@special		char(1), 
	@debit		money, 		          
   @credit		money, 		          
	@descript1	char(5), 
	@tag1			char(3), 
   @tag3       char(3),                   
	@toaccnt		char(15), 
	@accnt		char(10), 
	@guestid		char(7), 
	@roomno		varchar(20),
	@amount		money, 
	@amount0		money, 
	@selemark	char(27), 
	@lastnumb	integer, 
	@ld_odd		money,		            
	@li_oddcode int,	              
	@plucode		char(2),                
	@code			char(6),                
	@sort			char(4),                
	@bkfpay		char(3),		                
	@bkfaccnt	char(7),
   @mode       char(3),
   @amount1    money,
   @amount2    money,		              
   @amount3    money,
   @amount4    money,
   @amount5    money,
   @reason     char(3),
   @subaccnt   int,						-- 用于AR帐的分帐号
   @foliono	   char(20),				-- 转前台时备注存入account.ref2
   @cardno	   char(20),				-- 卡号
 	@refer 		varchar(20), 
	@ipos 		int,
	@tmp_menus	char(255),
	@postoption	char(10),				-- 是否转前台时启用pos_int_pccode
	@interface	char(1),					-- 是否转前台时启用餐饮接口
	@quantity	money,
	@vipnumber	int, 
	@hotelid		varchar(20),			-- 成员酒店号 
	@log_date	datetime,				-- 服务器时间 
	@vipbalance	money,
	@ref			char(20),
	@pcdes		varchar(32),
	@exclpart 	char(8),
	@shift_menu	char(1),					-- 根据预设时段算出开单班别
	@date0		datetime,				-- 开单时间
	@sftoption	char(1),
	@accnt_bank	char(10),				-- 信用卡对应的ar帐号
	@lic_buy_1 	char(255),
	@lic_buy_2 	char(255),
	@bank			char(10)

select @log_date = getdate()
select @bdate = bdate1 from sysdata
select @ret = 0, @msg = '结帐成功', @roomno='', @modu_id = '04', @tmp_menus = @menus

select @lic_buy_1 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.1'
select @lic_buy_2 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.2'

begin tran
save tran p_cyj_pos_checkout_s

select @exclpart = exclpart from accthead 
if not rtrim(@exclpart) is null
	begin
	select @ret = 1, @msg = '正在稽核独占部分, 请稍候'
	goto loop1
	end

if exists(select 1 from pos_menu where charindex(menu, @menus) > 0 and sta ='3' )
	begin
	select @ret = 1, @msg = "结账单中有已结账"
	goto loop1
	end
if exists(select 1 from pos_menu where charindex(menu, @menus) > 0 and sta ='7' )
	begin
	select @ret = 1, @msg = "结账单中有已删除"
	goto loop1
	end

select @interface = rtrim(ltrim(value)) from sysoption where catalog = 'pos' and item ='using_interface'
if @@rowcount = 0
	select @interface = 'F' 

if exists(select * from accthead where  exclpart <> '' and exclpart is not null)
   begin
	select @ret = 1
	goto loop1
	end              

if datalength(rtrim(@menus)) / 11 <> (select count(1) from pos_menu where charindex(menu, @menus) > 0 and paid = '0')
	begin
	select @ret = 1, @msg = '主单号不存在, 或状态有误'
	goto loop1
	end

if exists(select code from pos_dish where charindex(menu, @menus) > 0 and charindex('r',  flag) > 0)
	begin
	select @ret = 1, @msg = '只有在所有计时项目停止后才能结帐'
	goto loop1
	end

if charindex(@menus, '##') = datalength(@menus) - 1
	select @menu = substring(@menus, 1, charindex('##', @menus))
select @menu = substring(@menus, 1, 10)
update pos_menu set menu = menu where charindex(menu, @menus) > 0

select @li_oddcode = convert(int,remark), @ld_odd = isnull(amount, 0) 
	from pos_checkout where pc_id = @pc_id and menu = @menu and number = 0                                                    
if @@rowcount = 0 
	select @ld_odd = 0 
else
	begin
	select @name1 = name1,@name2 =name2, @special = special, @sort=sort,@code=code,@plucode = plucode from pos_plu_all where id = @li_oddcode
	if @@rowcount = 0
		begin
		select @ret = 1, @msg = '零头（或最低消费）代码“' + convert(char(10),@li_oddcode) + '”不存在'
		goto loop1
		end
	else if @special <> 'T'  //cq.jm
		begin
		select @ret = 1, @msg = '零头（或最低消费）代码“' + convert(char(10),@li_oddcode) + '”的类型不是特殊类'
		goto loop1
		end
	end

select @pccode = pccode , @package = ' ' + pccode from pos_menu where menu = @menu
--select @chgcod = chgcod, @pcdes = descript from pos_pccode where pccode=@pccode
update pos_dish set menu = menu where charindex(menu, @menus) > 0
select @debit = isnull(sum(amount - dsc + srv + tax), 0) from pos_dish
 where charindex(menu, @menus) > 0  and charindex(sta,'03579')>0 and charindex(rtrim(code), 'YZ') = 0
									  
select @credit = isnull(sum(amount), 0) from pos_pay
 where charindex(menu, @menus) > 0 and charindex(sta , '23' ) > 0 and charindex(crradjt, 'C CO') = 0
if round(@debit + @ld_odd, 2) <> round(@credit, 2)
	begin
	select @ret = 1, @msg = '借'+convert(char(10),@debit+@ld_odd)+'贷'+convert(char(10),@credit)+'不平, 请检查'
	goto loop1
	end

-- 零头或定金																									
declare c_checkout cursor for
	select paycode, id, menu1, number, remark, amount
	from pos_checkout where menu = @menu and pc_id = @pc_id
open c_checkout
fetch c_checkout into @paycode, @inumber, @menu0, @number, @toaccnt, @amount
while @@sqlstatus = 0 
	begin
	if @number = 0                  
		begin
		select @lastnum = lastnum + 1 from pos_menu where menu = @menu
		insert pos_dish(menu, inumber, plucode,id, sort, code, number, name1, name2, special, amount,dsc,srv,tax,sta, empno, bdate, date0, remark)
		select @menu, @lastnum, @plucode, @li_oddcode,@sort,@code, 1, @name1, @name2, @special, @amount,0,0,0,'A', @empno, @bdate, @log_date, '零头'
		update pos_menu set amount = amount + @ld_odd, srv = srv + @ld_odd, lastnum = @lastnum where menu = @menu
		end
	if rtrim(ltrim(@menu0)) <> null and @number > 0                     
		begin
																			
		select @inumber = number from pos_pay where menu0 = menu0 and inumber = @number
		update pos_pay set menu0 = @menu, inumber = @inumber where menu = @menu0  and number = @number
		end
	fetch c_checkout into @paycode, @inumber, @menu0, @number, @toaccnt, @amount
	end

declare c_pay cursor for
	select paycode, number, remark, accnt, amount, foliono, quantity, cardno, bank
	from pos_pay where menu = @menu  and charindex(sta, '23') >0 and charindex(crradjt, 'C #CO') = 0
open c_pay
fetch c_pay into @descript1, @number, @toaccnt, @bkfaccnt, @amount, @foliono, @quantity, @cardno, @bank
while (@@sqlstatus = 0)
	begin
	select @lastnum = lastnum + 1 from pos_menu where menu = @menu
	select @name1 =descript, @paycode = deptno1, @tag1 = deptno2,@tag3 = deptno4
		from pccode where pccode = @descript1 and argcode>'9'
	if @@rowcount = 0
		begin
		select @ret = 1, @msg = '付款代码“' + @descript1 + '”不存在!'
		goto loop1
		end

	select @accnt_bank = ''
//	if exists(select 1 from bankcard where pccode = @descript1)        -- 付款码判断是否自动转ar
//		and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
//		begin
//		select @accnt_bank = accnt from bankcard where pccode = @descript1 and bankcode = @bank
//		if rtrim(@accnt_bank) is null
//			begin
//			select @ret = 1, @msg = @descript1 + ' 没有转账账号'
//			goto loop1
//			end
//		end

	if rtrim(@toaccnt) is  null and @tag1 like 'TO%'
		begin
		select @ret = 1, @msg = '没有转账账号'
		goto loop1
		end
	else if rtrim(@toaccnt) is not null and (@tag1 like 'TO%' or @accnt_bank >'') and charindex(@interface, 'YyTt')=0
		begin
		select @selemark = 'a' + @descript1 + space(5) + @bank , @today = @log_date,@mode=mode,@amount1=amount0,@amount2=dsc,@amount3=srv,@amount4=tax,@amount5=amount1 from pos_menu where menu = @menu
		if @amount2 > 0 
			select @reason = min(reason) from pos_dish where menu=@menu and dsc > 0
		select @accnt = substring(@toaccnt, 1, charindex('-', @toaccnt) - 1), @guestid = isnull(substring(@toaccnt, charindex('-', @toaccnt) + 1, 7), '')
		if rtrim(@guestid) is null	
			select @subaccnt = 0
//		else
//			begin
//			select @subaccnt = subaccnt from subaccnt where type = "5" and accnt = @accnt and haccnt = @guestid
//			if @@rowcount = 0 
//				select @subaccnt = 0
//			end

-----处理餐厅和费用码一对多时的转前台问题, pos_int_pccode.class='2' 为 费用码对照记录
		select @postoption = rtrim(value) from sysoption where catalog = 'pos' and item = 'using_pos_int_pccode'
		if charindex(rtrim(@postoption), 'tTyY') > 0
			begin 
			select @sftoption = rtrim(value) from sysoption where catalog = 'pos' and item = 'posting_front_shift'
			if charindex(rtrim(@sftoption), 'tTyY') > 0
				begin
				select @date0 = date0 from pos_menu where menu = @menu
				if not exists(select 1 from pos_int_pccode where class='2' and pos_pccode = @pccode and @date0 >convert(datetime, convert(char(10),@date0, 10)+' '+ start_time))
					select @shift_menu = max(shift) from pos_int_pccode where class='2' and pos_pccode = @pccode
				else
					select @shift_menu = shift from pos_int_pccode where class='2' and pos_pccode = @pccode
						and @date0 >convert(datetime, convert(char(10),@date0, 10)+' '+ start_time)
						and @date0 <=convert(datetime, convert(char(10),@date0, 10)+' '+ end_time)
				end
			if rtrim(@shift_menu) is null
				select @shift_menu = @shift

			select @chgcod = ''
			select @chgcod = pccode from pos_int_pccode where class ='2' and shift = @shift_menu and pos_pccode = @pccode
			if rtrim(@chgcod) is null or @chgcod = '' 
				select @chgcod = pccode from pos_int_pccode where class ='2' and ltrim(rtrim(shift)) = null and pos_pccode = @pccode

			if rtrim(@chgcod) is null or @chgcod = '' 
				begin
				select @ret = 1, @msg = '该餐厅('+@pccode+')<'+@shift_menu+'班>对应的费用码没有定义'
				goto loop1
				end
			end
-----处理餐厅和费用码一对多时的转前台问题, pos_int_pccode.class='2' 为 费用码对照记录

		if not exists(select 1 from chgcod where pccode = @chgcod)
			begin
			select @ret = 1, @msg = '不存在费用码' + @chgcod
			goto loop1
			end
		--exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id,3, @shift, @empno, @accnt,@subaccnt, @chgcod, '',1, @amount,@amount1,@amount2,@amount3,@amount4,@amount5,@menu,@foliono, @today, '', @mode, @option, 0, '', @msg out
		select @chgcod = rtrim(@chgcod) + 'A'
		exec @ret = p_gl_accnt_post_charge @selemark, 0, 0, @modu_id, @pc_id, @shift, @empno, @accnt, @guestid, '', @chgcod, @package, @amount, NULL, @today, NULL, 'IN', 'R', '', 'I', @msg out
		

																							//declare p_posting procedure for p_gl_accnt_posting
																							//	@selemark		= "A",
																							//	@modu_id			= :modu_id,
																							//	@pc_id			= :pc_id,
																							//	@mdi_id			= :is_parm.mdi_id,
																							//	@shift			= :shift,
																							//	@empno			= :empno,
																							//	@accnt			= :ls_accnt,
																							//	@subaccnt		= :ll_subaccnt,
																							//	@pccode			= :ls_pccode,
																							//	@argcode			= :ls_argcode,
																							//	@quantity		= :ld_quantity,
																							//	@amount			= :ld_amount,
																							//	@amount1			= 0,
																							//	@amount2			= 0,
																							//	@amount3			= 0,
																							//	@amount4			= 0,
																							//	@amount5			= 0,
																							//	@ref1				= :ls_ref1,
																							//	@ref2				= :ls_ref2,
																							//	@date				= :ldt_date,
																							//	@reason			= :ls_reason01,
																							//	@mode				= "",
																							//	@operation		= :ls_option,
																							//	@a_number		= 0,
																							//	@to_accnt		= :ls_accntof,
																							//	@msg				= "";


		if @ret != 0
			goto loop1
		else
			begin
			select @roomno = roomno from master where accnt = @accnt
			if @@rowcount = 0
				select @roomno = ''
			else
				select @roomno = @roomno + '-' + @toaccnt, @name1 = @name1 + '(' + @roomno + ')'
			end
		end
					 
		 
	if rtrim(@toaccnt) is not null and @tag3 = 'BR' 
		begin
		select @selemark = 'a' + menu , @today = @log_date from pos_menu where menu = @menu
		select @accnt = substring(@toaccnt, 1, 10), @guestid = isnull(substring(@toaccnt, 11, 7), '')
																																																														 
		if @ret != 0
			break
		else
			begin
			select @roomno = roomno from master where accnt = @accnt
			if @@rowcount = 0
				select @roomno = ''
			else
				select @roomno = @roomno + '-' + @toaccnt, @name1 = @name1 + '(' + @roomno + ')'
			end
		end
					  
	-- 早餐特殊处理		  
	if rtrim(@bkfaccnt) is not null and @descript1 = @bkfpay
		begin
		select @amount0 = amount0 - amount1 from room_bkf where accnt = @bkfaccnt and bdate = @bdate
		if @@rowcount = 0                        
			begin
			select @amount0 = sum(amount0 - amount1) from room_bkf where groupno = @bkfaccnt and bdate = @bdate
			if @@rowcount = 0 
				begin
				select @ret = 1, @msg = '账号有误'
				goto loop1
				end
			declare  c_bkf_group cursor for select accnt from room_bkf where groupno = @bkfaccnt and bdate= @bdate
			open c_bkf_group
			fetch c_bkf_group into @accnt
			while @@sqlstatus = 0 and @amount > 0
				begin
				if exists(select 1 from room_bkf where  accnt = @accnt and bdate = @bdate and  amount0 = amount1 )	
					begin
					fetch c_bkf_group into @accnt
					continue
					end
				if exists(select 1 from room_bkf where  accnt = @accnt and bdate = @bdate and @amount > amount0 - amount1 )	
					begin
					update room_bkf set amount1 = amount0 where accnt = @accnt and bdate = @bdate
					select @amount = @amount - amount0 from room_bkf where  accnt = @accnt and bdate = @bdate
					end
				else
					begin
					update room_bkf set amount1 = amount1 + @amount where accnt = @accnt and bdate = @bdate
					select @amount = 0
					end
				fetch c_bkf_group into @accnt
				end
			close c_bkf_group
			deallocate cursor c_bkf_group
			end
		if @amount > @amount0 
			begin
			select @ret = 1, @msg = '早餐费超支'+convert(char(10), @amount - @amount0)
			goto loop1
			end

		update room_bkf set amount1 = amount1 + @amount where accnt = @bkfaccnt and bdate = @bdate
		end

-- 联单设置setmode  cyj 05.03.24
	update pos_menu set setmodes = @descript1 + char(ascii(setmodes) - ascii(setmodes) + ascii('*'))
	 where charindex(menu, @menus)>0
	update pos_menu set lastnum = @lastnum  where menu = @menu
--	update pos_menu set setmodes = @descript1 + char(ascii(setmodes) - ascii(setmodes) + ascii('*')), lastnum = @lastnum
--	 where menu = @menu

	if substring(@option, 3, 1) = 'Y'
		update pos_pay set remark  = rtrim(remark) + '@' where menu = @menu and number = @number

	-- 使用贵宾卡积分付款, 储值卡付款
	if @tag1 = 'PTS' or @tag1 = 'CAR'
		begin
		select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
		select @ref = convert(char(10), @number), @pcdes = rtrim(@pcdes) + ' - Pos'
		--exec @ret = p_gds_vipcard_posting '', '04', @pc_id, 0, @shift, @empno, @cardno, @hotelid, @bdate, '-', @amount, @amount, 0, 0, 0, @quantity, '', @menu, @ref, @menu, @pcdes,'R', @ret output, @msg output
		end
	//
	fetch c_pay into @descript1, @number, @toaccnt, @bkfaccnt, @amount, @foliono, @quantity, @cardno, @bank
	end
close c_pay
deallocate cursor c_pay

select @lastnum = lastnum from pos_menu where menu = @menu

-- 联单备注
while datalength(rtrim(@tmp_menus)) > 11
	begin
		select @menu1 = substring(@tmp_menus, 12, 10)
		select @amount = isnull(sum(amount), 0) from pos_dish
			where menu = @menu1 and not code like ' %' and charindex(sta,'03579')>0
		update pos_menu set remark = @menu + '---合并' + remark
			where menu = @menu1
		select @tmp_menus = substring(@tmp_menus, 12, datalength(@tmp_menus) - 11)
	end

select @refer = isnull(rtrim(remark), '') from pos_menu where menu = @menu
select @ipos = charindex('|', @refer)
if @ipos > 0 
	select @refer = substring(@refer, 1, @ipos - 1)
if @roomno <> ''
	select @refer = @refer + '|' + @roomno

update pos_menu set sta = '3', paid = '1', empno3 = @empno, shift = @shift, lastnum = @lastnum, remark=@refer
 where charindex(menu, @menus)>0

delete pos_tblav where charindex(menu,@menus)>0


loop1:
if @ret <> 0 
   rollback tran p_cyj_pos_checkout_s
commit tran

delete herror_msg where pc_id=@pc_id and modu_id=@modu_id
insert herror_msg(pc_id,modu_id,ret,msg) values (@pc_id,@modu_id,@ret,@msg+@toaccnt)

if @retmode <> 'R'
   select @ret, @msg
return @ret;

if exists(select 1 from sysobjects where name ='p_cyj_pos_create_min_charge' and type = 'P')
	drop proc p_cyj_pos_create_min_charge;
create proc p_cyj_pos_create_min_charge
	@menu			char(10),
	@min_charge	money	output,			            -- 最低消费金额
   @hamount    money,									-- 调整后最低消费
	@retmode		char(1) = "S"	
as
----------------------------------------------------------------------------------------------
--
--		计算最低消费
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

if @mode = '1' and @amount * @tables > @charge        -- 按桌
	select @min_charge = @amount * @tables
else if @mode = '2' and @amount * @guest > @charge    -- 按人
	select @min_charge = @amount * @guest

if  @hamount  <>0
	if @hamount <> @min_charge 
		select @min_charge = @hamount
   
if @retmode = 'S'
	select @min_charge
return 0;

/*-----------------------------------------------------------------------------*/
//
//	餐饮明细输入, PDA 输入调用改过程
//
// 如果有 缺菜 !  2001/06/17   		标记海鲜
// 酒水吧库存     2002/05/20   
//
/*-----------------------------------------------------------------------------*/


if object_id('p_cyj_pos_input_dish') is not null
	drop proc p_cyj_pos_input_dish
;
create proc p_cyj_pos_input_dish
	@menu			char(10),
	@empno		char(10),
	@id			int,						//   菜唯一号
	@plu_number	money,      		   //   数量
	@plu_price	money,      		   //   单价
	@flag			char(10),            //   附加态 M -- 套菜
	@remark		char(15),
	@name1		char(20),
	@pc_id		char(8),
	@empno1		char(20),
	@dish_add	varchar(100),        //   附加项描述，如烹饪要求等  
	@unit			char(4)
as
declare
	@ret			integer  ,
	@msg			char(60) ,
	@bdate		datetime,
	@p_mode		char(1)	,
	@mdate		datetime,
	@mshift		char(1),
	@deptno		char(2)	,
	@pccode		char(10)	,
	@mode			char(3),
	@code			char(6),
	@sort			char(4),
	@code1		char(10),
	@plucode		char(2),
	@inumber		integer	,
	@printid		integer	,
	@name2		char(30)	,
	@amount0		money	,
	@amount		money	,
	@number		money	,
	@number1		money	,

	@dsc_rate		money,
	@serve_rate		money,
	@tax_rate		money,

	@serve_charge0	money,
	@tax_charge0	money,
	@serve_charge	money,
	@tax_charge		money,
	@charge			money,

	@timecode		char(3),
	@times			integer,
	@minute			integer,
	@minute1			integer,
	@minute2			integer,

	@special				char(1),
	@sta					char(1),
	@timestamp_old		varbinary(8),
	@timestamp_new		varbinary(8),
	@reason3			char(2),
	@cookid			char(2),
	@kitchen			char(5),
	@drinkid			integer,
	@dinnerid		integer,
	@hx				int, 
	@line 			int,
	@cur_code 		char(6),
	@cur_name1 		char(20),
	@cur_name2 		char(30),
  	@cur_unit 		char(4),
	@cur_number 	money,
	@cur_amount0 	money,
  	@cur_special 	char(1),
	@cur_cont 		char(1),
	@cur_cookid 	char(2),
  	@cur_kitchen 	char(5),
	@cur_plucode 	char(2),
	@cur_sort 		char(4),
	@cur_id 			int,
	@mx_id 			integer

select @hx = 0

select @bdate  = bdate1 from sysdata
select @p_mode = value  from sysoption where catalog = "pos_dish" and item = "p_mode"
select @reason3 = ''

begin tran
save  tran p_hry_pos_input_dish_s1
select @timestamp_old = timestamp from pos_menu where menu = @menu
update pos_menu set pc_id = @pc_id where menu = @menu
select @mdate = bdate,@mshift = shift,@deptno = deptno,@pccode = pccode,@inumber = lastnum + 1,@sta = sta,
		 @mode = mode,@serve_rate = serve_rate,@tax_rate = tax_rate,@dsc_rate = dsc_rate
  from pos_menu where menu = @menu

if @@rowcount = 0
	select @ret = 1,@msg = "菜单“" + @menu + "”已不存在或已销单"
else if @sta ='3'
	select @ret = 1,@msg = "菜单“" + @menu + "”已被其他收银员结帐"
else if @sta ='7'
	select @ret = 1,@msg = "菜单“" + @menu + "”已被删除"

else
	begin
	select @name1 = rtrim(@name1)
	select @name1 = isnull(@name1,name1),@name2 = isnull(name2,''),@special=special,
		@plucode = plucode, @sort = sort, @code = code
	  from pos_plu where id = @id
	if @@rowcount = 0
		begin
		select @name1 = isnull(@name1,name1),@name2 = isnull(name2,''),@special=special
		  from pos_plu where code = @code
		if @@rowcount = 0
			begin
			select @ret = 1,@msg = "菜号“" + rtrim(@code) + "”已不存在"
			goto gout
			end
		end	
	// 估清单：pos_assess有记录才作判断. 在客户端提示，不再在此强制停止执行
	/*
	select @number = number, @number1 = number1 from pos_assess where bdate = @bdate and id = @id 
	if @@rowcount = 1
		if @plu_number >= @number - @number1		// 份数不够
			begin
			select @ret = 1,@msg = @name1 + '---' + rtrim(@code) + '只有' + convert(char(8), @number - @number1)+'份，已不够点!'
			goto gout
			end
	*/
	// 原来的名字 -- gds--------------------------------->>>

	declare @minid int
	select @minid=isnull(min(id),0) from pos_dish where menu=@menu and code=@code
	if @minid > 0
		select @name1=name1,@name2=@name2 from pos_dish where menu=@menu and code=@code
	// 原来的名字 -- gds--------------------------------->>>

	select @serve_charge0 = 0,@serve_charge = 0,@tax_charge0 = 0,@tax_charge = 0,@charge = 0
	select @number = @plu_number
	select @amount0 = round(@plu_price * @number,2)
	if @special = 'T'
		select @amount = @amount0,@amount0 = 0
	else if @special = 'X'
		select @amount = @amount0,@reason3 = isnull(substring(@remark,1,2),'')
	select @printid = isnull(max(printid)+1,1) from pos_dish 
	insert pos_dish(menu,inumber,plucode,sort,code,id,printid,name1,name2,unit,number,amount,empno,bdate,remark,special,id_cancel,id_master,reason,empno1)
		select @menu,@inumber,@plucode,@sort,@code,@id,@printid,@name1,@name2,@unit,@number,@amount0,@empno,@bdate,@remark,@special,0,0,@reason3,@empno1
//	exec p_cyj_bar_pos_sale @menu, @inumber
//	// 附加项输入
//	if rtrim(@dish_add) <> '' and not rtrim(@dish_add) is null
//		insert pos_dish_add(menu, inumber, descript) values(@menu, @inumber, rtrim(@dish_add))

	if charindex(@special,'XT') = 0            
		begin
		/*折扣，服务费，税处理*/
		select @code1 = @sort + @code
		exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@code1,@amount0,@dsc_rate,@result = @amount output
		exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@code1,@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output
		exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@code1,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
	
		update pos_dish set dsc =  amount - @amount 	where menu = @menu and inumber = @inumber
		update pos_dish set srv =  @serve_charge 	 where menu = @menu and inumber = @inumber
		update pos_dish set tax =  @tax_charge 	 where menu = @menu and inumber = @inumber
	
		update pos_dish set amount = amount + @serve_charge0, dsc = dsc + @serve_charge0 - @serve_charge
		 where menu = @menu and code = "Z"
		update pos_dish set amount = amount + @tax_charge0, dsc = dsc + @tax_charge0 - @tax_charge
		 where menu = @menu and code = "Y"
		end

	select @mx_id = @inumber

//	if charindex('M', upper(@flag)) > 0       //  有些套菜的内容事先没定义，要临时输入
//	begin
//
//		declare std_mx_cur cursor for
//			select a.code,a.name1,a.name2,a.unit,a.number,a.special,a.id,a.amount
//				from pos_dish_pcid a,pos_plu b where pc_id = @pc_id and  a.master_id = b.id
//		open std_mx_cur
//		fetch std_mx_cur into @cur_code,@cur_name1,@cur_name2,@cur_unit,@cur_number,@cur_special,@cur_id,@cur_amount0
//		while @@sqlstatus = 0
//		begin
//			select @cur_plucode = plucode,@cur_sort = sort from pos_plu where id = @cur_id
//			select @mx_id = @mx_id + 1
//			select @printid = isnull(max(printid)+1,1) from pos_dish 
//			insert pos_dish(menu,inumber,plucode,sort,id,printid,code,name1,name2,unit,number,amount,empno,bdate,remark,special,sta,id_cancel,id_master,reason,empno1)
//				select @menu,@mx_id,@plucode,@sort,@id,@printid,@cur_code,@cur_name1,isnull(@cur_name2,''),isnull(@cur_unit,''),@cur_number,isnull(@cur_amount0,0),@empno,@bdate,'',isnull(@cur_special,''),'M',0,@inumber,'',@empno1 //cq
//			exec p_cyj_bar_pos_sale @menu, @mx_id
//			fetch std_mx_cur into @cur_code,@cur_name1,@cur_name2,@cur_unit,@cur_number,@cur_special,@cur_id,@cur_amount0
//		end
//		close std_mx_cur
//		deallocate cursor std_mx_cur
//	end
//
//	delete pos_dish_pcid where pc_id = @pc_id and menu = @menu
//
//	insert pos_empnoav (empno, menu, bdate, shift, sta, inumber)
//		select @empno1,@menu, @bdate, @mshift, '1', @inumber
//  计算每台的消费
	update pos_tblav set amount = isnull((select sum(amount) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0 )
		+ (select sum(srv) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
		+ (select sum(tax) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
		- (select sum(dsc) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0), 0)
		from pos_tblav a where a.menu = @menu  and sta ='7'

	update pos_menu set amount = amount + @amount + @serve_charge + @tax_charge,lastnum = @mx_id
	 where menu = @menu
	select @charge = amount,@timestamp_new = timestamp from pos_menu where menu = @menu
	select @ret = 0,@msg = "成功"
//   估清单
	update pos_assess set number1 = number1 + @plu_number where id = @id
//   酒水吧库存
//	exec p_cyj_bar_pos_sale @menu, @id
	end

gout:
if @ret <> 0 
	rollback tran p_hry_pos_input_dish_s1
else
	if @hx = 1 
		select @msg = 'hx' + convert(char(4), @line)
commit tran

select @ret,@msg,@charge
return 0

;

	


if exists(select 1 from sysobjects where name = 'p_cyj_pos_order_to_dish' and type = 'P')
	drop procedure p_cyj_pos_order_to_dish;

create proc p_cyj_pos_order_to_dish
	@pc_id	char(4),
	@menu		char(10),
	@empno	char(10)
as
-------------------------------------------------------------------------------*/
--
--		点菜： pos_order 导入 pos_dish
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
	@inumber			money,
	@sort				char(4),
	@code1			char(10),
	@plucode			char(2),
	@orderno			char(10),
	@siteno			char(1),
	@flag				char(10),
	@flag0			char(10),
	@begin			datetime,
	@end				datetime,
	@stdmx_id		int,
	@mx_id			int,
	@master_id		int,
	@bdate			datetime,
	@name1			char(30),
	@empno1			char(10),
	@pinumber		integer,
	@cost				money,
	@kitchen			char(20)

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
	select @ret = 1, @msg = "没有要处理的数据"
	select @ret, @msg 
	return 0
	end

select * into #order from pos_order where 1 = 2
insert #order select * from pos_order where menu = @menu and pc_id = @pc_id and inumber1 =0 order by inumber

begin tran
save  tran p_pos_order_to_dish_s1

update pos_menu set sta = sta where menu = @menu 

select @menuid =  lastnum + 1, @mdate = bdate, @mshift = shift, @pccode = pccode,@deptno = deptno,@mode = mode,
	@serve_rate = serve_rate,@tax_rate = tax_rate,@discount_rate = dsc_rate from pos_menu where menu = @menu

declare order_cur cursor for
	select pinumber,inumber, id, sta, special, remark, code, amount, number, name1, flag, empno1,kitchen
		from #order where pc_id = @pc_id and menu = @menu order by inumber
open order_cur
fetch order_cur into @pinumber,@inumber, @orderid, @sta, @special, @remark, @code,@amount, @number0, @name1, @flag, @empno1,@kitchen
while @@sqlstatus = 0
	begin

	                                                          
	select @number = number, @number1 = number1 from pos_assess where bdate = @bdate and id = @orderid 
	if @@rowcount = 1
		begin
	                                                                                                                                                                                                                        
		update pos_assess set number1= number1 + @number0 from pos_assess where bdate = @bdate and id = @orderid
		end
	-- 计时菜算金额
	select @timecode = timecode, @sort = sort, @plucode = plucode from pos_plu where id = @orderid
   select @tableno = tableno from #order where id=@orderid    //桌号不直接从POS_plu里取cq.jm
	if @special = 'S'
		begin
		select @times = 1
		if rtrim(@flag) = ''
			select @flag = 'R'               
		else
			select @flag = rtrim(@flag) + 'R'               
		select @plu_number = count(1) from pos_time_code where timecode = @timecode
		if @plu_number = 0
			begin
			select @ret = 1,@msg = "时段码“" + rtrim(@timecode) + "”未定义"
			goto goout
			end
		select @begin = getdate(),@end = getdate()
		end
--取得菜的成本金额,放入dish
	select @cost = cost from pos_price where id = @orderid and inumber = @pinumber
--取得厨房代码
	if @kitchen = '' or @kitchen is null
		exec p_cq_pos_get_printer @pccode,@orderid,@kitchen output
----
	select @amount0 = @amount
	select @printid = isnull(max(printid)+1,1) from pos_dish 
	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,price,amount,pamount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2,empno1,cook,kitchen,kit_ref)
		select menu,@menuid,@plucode,sort,@orderid,@printid,code,number,price,amount,number*@cost,name1,name2,unit,@empno,@mdate,remark,special,'0', inumber1,inumber1,'',0,0,0,orderno,  tableno,siteno,isnull(@flag, ''),@begin,@end,@empno1,cook,@kitchen,kit_ref
		from #order where menu = @menu and pc_id = @pc_id and inumber = @inumber

--销售(成本计算)	                
	exec p_cq_pos_cond_sale  @menu, @menuid,@orderid,@pinumber
   
-- 套菜处理	和 一菜多吃的情况    		cq add                                                         
	if substring(@flag,1,1) = 'T' and exists(select 1 from pos_order where pc_id = @pc_id and inumber1 = @inumber and menu = @menu)
		begin
		select @master_id = @menuid ,@stdmx_id = @menuid 
		select  @orderno = orderno,@tableno = tableno,@siteno = siteno from #order where menu=@menu and pc_id = @pc_id and id = @orderid
		declare std_cursor cursor for select id,kitchen from pos_order where pc_id = @pc_id and inumber1 = @inumber and menu = @menu order by id
		open std_cursor
		fetch std_cursor into @mx_id,@kitchen
		while	@@sqlstatus = 0
			begin
			select @stdmx_id = @stdmx_id + 1
			select @plucode = plucode, @sort = sort from pos_plu where id = @mx_id
			select @printid = isnull(max(printid)+1,1) from pos_dish 
			--取得厨房代码
			if @kitchen = '' or @kitchen is null
				exec p_cq_pos_get_printer @pccode,@mx_id,@kitchen output
			----
			insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,pamount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno, flag,cook,kitchen,kit_ref)
				select @menu,@stdmx_id,@plucode,@sort,@mx_id,@printid,code,number*@number0 ,@number0 * amount,0,name1,name2,unit,@empno,@mdate,'','','M', 0,@master_id,'',0,0,0,@orderno,@tableno,@siteno,flag,cook,@kitchen,kit_ref
				from pos_order where pc_id = @pc_id and inumber1 = @inumber and id = @mx_id and menu = @menu

			fetch std_cursor into @mx_id,@kitchen
			end
		select @menuid = @stdmx_id
		close std_cursor
		deallocate cursor std_cursor
		end
	-- 计算服务费，折扣，税	
	if charindex(@special,'XT') = 0  and charindex(@sta, '03579') > 0 
		begin
		-- 计算服务费，折扣，税采用的代码标准是小类加代码                        
		select @code1 = @sort+@code
		exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@code1,@amount,@discount_rate,@result = @amount output
		exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@code1,@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output
		exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@code1,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output

		update pos_dish set dsc =  amount - @amount 	where menu = @menu and inumber = @menuid
		update pos_dish set srv =  @serve_charge 	 where menu = @menu and inumber = @menuid
		update pos_dish set tax =  @tax_charge 	 where menu = @menu and inumber = @menuid

		update pos_dish set amount = amount + @serve_charge0, dsc = dsc + @serve_charge0 - @serve_charge
		 where menu = @menu and code = "Z"
		update pos_dish set amount = amount + @tax_charge0, dsc = dsc + @tax_charge0 - @tax_charge
		 where menu = @menu and code = "Y"
		end
	fetch order_cur into @pinumber,@inumber, @orderid, @sta, @special, @remark, @code,  @amount, @number0, @name1, @flag,@empno1,@kitchen
	select @menuid = @menuid + 1
	end
close order_cur
deallocate cursor order_cur

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


if exists(select 1 from sysobjects where name ='p_cyj_pos_recheck' and type ='P') 
	drop proc p_cyj_pos_recheck;

create proc p_cyj_pos_recheck
	@menu		char(10)
as
--------------------------------------------------------------------------------------
--
-- pos 重新结帐 : 追回重结
-- 转前台不用pccode用pos_pccode.chgcod
--	清空 pos_menu_bill.payamount, oddamount
-- 转前台时要判断是否采用接口方式
--------------------------------------------------------------------------------------
declare
	@paid						char(1),
	@current_menu			char(10),
	@empno					char(10),
	@menu_remark			char(20),
	@refer					char(20),
	@lastnum					integer,
	@nnumber					integer,
	@number					integer,
	@paycode					char(15),
	@shift					char(1),
	@pccode					char(3),
	@chgcod					char(5),
	@package					char(3),
	@tag1						char(3),
	@tag3						char(3),
	@amount					money,
	@amount1					money,
	@amount2					money,
	@amount3					money,
	@amount4					money,
	@amount5					money,
	@charge					money,
	@pc_id					char(4),
	@selemark				char(13), 
	@accnt					char(20),
	@guestid					char(20),
	@bdate					datetime,
	@ret						integer,
   @msg						char(60), 
	@count					integer,
	@pcrec					char(10),
	@remark					char(40),
	@option 					char(5),
	@postoption 			char(1),			--	是否采用pos_int_pccode
	@interface				char(1),			-- 是否采用接口方式
	@foliono					char(20),
	@quantity				money,
	@vipnumber				int, 
	@hotelid					varchar(20),	-- 成员酒店号 
	@log_date				datetime,		-- 服务器时间 
	@vipbalance				money,
	@ref						char(20),
	@pcdes					varchar(32)	

select @ret = 0 , @msg = '', @log_date = getdate()

select @interface = rtrim(ltrim(value)) from sysoption where catalog = 'pos' and item ='using_interface'
if @@rowcount = 0
select @interface = 'F' 

begin tran
save  tran t_check
if exists(select 1 from pos_menu where menu = @menu and sta <> '3')
	begin
	select @ret = 1, @msg = '不是结账状态'
	goto gout
	end
select @pcrec = pcrec, @paid = paid, @current_menu = menu, @menu_remark = remark, @shift = shift, @empno = empno3, 
	@pccode = pccode, @package = ' ' + pccode, @bdate = bdate, @pc_id = pc_id	from pos_menu where menu = @menu

if rtrim(ltrim(@pcrec)) <> null      // 菜单合并
	declare c_menu cursor for
		select menu,lastnum from pos_menu where pcrec =  @pcrec
else
	declare c_menu cursor for
		select menu,lastnum from pos_menu where menu = @menu

declare c_pay cursor for       //要冲掉使用定金和结帐款
	select number, paycode, - amount, accnt, remark, foliono, - quantity from pos_pay
		where menu = @current_menu and charindex(sta, '23') >0 and charindex(crradjt, 'C #CO') = 0
open c_menu
fetch c_menu into @current_menu, @lastnum
while @@sqlstatus =0
	begin
	select @nnumber = @lastnum, @charge = 0
	/* 恢复桌号 */
	if exists(select 1 from pos_tblav where menu = @current_menu and pos_tblav.inumber = 0)
		update pos_tblav set sta = '7' where menu = @current_menu and pos_tblav.inumber = 0
	else
		insert pos_tblav (menu, inumber,tableno, bdate, shift, sta, pcrec)
			select @current_menu,0,tableno,@bdate,@shift,'7', isnull(pcrec, '') from pos_menu where menu = @current_menu
	//
	open c_pay
	fetch c_pay into @number, @paycode, @amount, @accnt,@remark, @foliono, @quantity
	while @@sqlstatus =0
		begin
		select @nnumber = max(number) + 1 from pos_pay where menu = @current_menu 
		select @tag1 = deptno2 from pccode where pccode = @paycode
		if rtrim(@accnt) is not null and @tag1 like "TO%"  and charindex(@interface, 'YyTt')=0
			begin
			select @guestid = ''
-----处理餐厅和费用码一对多时的转前台问题, pos_int_pccode.class='2' 为 费用码对照记录
			select @postoption = rtrim(value) from sysoption where catalog = 'pos' and item = 'using_pos_int_pccode'
			if charindex(rtrim(@postoption), 'tTyY') > 0
				begin 
				select @chgcod = pccode from pos_int_pccode where class ='2' and shift = @shift and pos_pccode = @pccode
				if rtrim(@chgcod) is null or @chgcod = '' 
					begin
					select @ret = 1, @msg = '该餐厅('+@pccode+')<'+@shift+'班>对应的费用码没有定义'
					close c_pay
					close c_menu
					deallocate cursor c_pay
					deallocate cursor c_menu
					goto gout
					end
				end
-----处理餐厅和费用码一对多时的转前台问题, pos_int_pccode.class='2' 为 费用码对照记录

			if charindex('@',@remark) >0              -- 用过package
				select @option	 = 'IRYN'
			else
				select @option	 = 'IRNN'

			select @selemark = 'a' + menu, @amount1= -1 * amount0,@amount2=-1 * dsc,@amount3=-1 * srv,@amount4=-1 * tax,@amount5=-1 * amount1 from pos_menu where menu = @current_menu
			--exec @ret = p_gl_accnt_posting     @selemark, '04',@pc_id,3, @shift, @empno, @accnt, 0, @chgcod, '', 1, @amount, @amount, @amount2,@amount3,@amount4,@amount5,@current_menu, '', @bdate, '', '', @option, 0, '', @msg output
			exec @ret = p_gl_accnt_post_charge @selemark, 0, 0, '04', @pc_id, @shift, @empno, @accnt, @guestid, '', @chgcod, @package, @amount, NULL, @bdate, NULL, 'IN', 'R', '', 'I', @msg out
			if @ret != 0
				begin
				select @ret = 1
				goto gout
				end
--				rollback trigger with raiserror 55555 @msg
			end
		insert into pos_pay(menu,number,inumber,paycode,accnt,roomno,foliono,amount,sta,crradjt,reason,empno,bdate,shift,log_date,remark, menu0, quantity)
			select menu,@nnumber,@number,paycode,accnt,roomno,foliono,- amount,sta,'CO',reason,@empno,@bdate,@shift,@log_date,remark, menu0, @quantity
			from pos_pay where menu = @current_menu and number = @number
		update pos_pay set crradjt = 'C ' where menu = @current_menu and number = @number

		-- 使用贵宾卡积分付款, 储值卡付款
		if @tag1 = 'PTS' or @tag1 = 'CAR'
			begin
			select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
			select @ref = convert(char(10), @nnumber), @pcdes = rtrim(@pcdes) + ' - PosRechk'
			--exec @ret = p_gds_vipcard_posting '', '04', @pc_id, 0, @shift, @empno, @foliono, @hotelid, @bdate, '-', @amount, @amount, 0, 0, 0, @quantity, '', @menu, @ref, @menu, @pcdes,'R', @ret output, @msg output
			end

		fetch c_pay into @number, @paycode, @amount, @accnt, @remark, @foliono, @quantity
		end
	close c_pay
	// 冲销零头
	select @number = inumber, @charge = amount - dsc + srv + tax from pos_dish where menu = @current_menu and sta ='A'
	if @@rowcount = 1
		begin
		update pos_dish set sta = '1' where menu = @current_menu and inumber = @number
		insert pos_dish(menu,inumber,plucode,sort,id, code, number, name1, name2, unit, amount,dsc,srv,tax, special, sta, empno, bdate, remark)
			select menu, @lastnum + 1,plucode,sort,id, code, - number, name1, name2, unit, - amount,- dsc,  - srv, - tax, special, '2', @empno, bdate, remark
			from pos_dish where menu = @current_menu and inumber = @number
		update pos_dish set sta = '1' where menu = @current_menu and sta ='A'
		/*更新MENU费用记录, 减掉零头金额*/
		update pos_menu set amount = amount - @charge, lastnum = @lastnum + 1 where menu = @current_menu
		end
	update pos_pay set menu0 = '', inumber = 0 where menu0 = @current_menu
	update pos_menu set paid = '0', sta = '5', empno3 = @empno, date0 = @log_date where menu = @current_menu
	delete pos_detail_jie where menu = @current_menu
	delete pos_detail_dai where menu = @current_menu
	fetch c_menu into @current_menu, @lastnum
	end
close c_menu
deallocate cursor c_pay
deallocate cursor c_menu

--	清空现金付款和找零信息 pos_menu_bill.payamount, oddamount
update pos_menu_bill set payamount=0,oddamount=0 from pos_menu_bill a , pos_menu b where b.menu=@menu and (a.menu=b.menu or a.menu=b.pcrec)
gout:
if @ret <> 0 
	rollback tran
commit t_check
select @ret, @msg
;	
drop  procedure p_cyj_pos_res_cancel;
create procedure p_cyj_pos_res_cancel
	@resno			char(10),
	@empno			char(10)
as
declare
	@ret				int,
	@msg				char(64)

select @ret = 0 , @msg = ''

begin tran
save  tran t_res_cancel
if exists(select 1 from pos_pay where menu=@resno and sta = '1' and charindex(crradjt, 'C CO') = 0)
	begin
	select @ret = 1 , @msg = '有定金,不能取消预定'
	end

	update pos_reserve set sta = '0', empno = @empno, bdate = getdate() where resno = @resno
	update pos_tblav set sta = '0' where menu = @resno

if @ret <> 0
	rollback tran t_res_cancel
commit tran

select @ret, @msg
;
drop  proc p_cyj_pos_reserve_menu;
create proc p_cyj_pos_reserve_menu
	@resno		char(10),
	@posno		char(2),
	@empno		char(10),
	@pc_id		char(4)
as
declare
	@menu				char(10),
	@pccode			char(3),
	@shift			char(1),
	@serve_rate		money,
	@tax_rate		money,
	@tea_rate		money,
	@ret				integer,
   @ls_sort       char(4),
   @ls_code       char(6),
   @ls_name1      char(30),
   @ls_name2      char(50),
   @ls_unit       char(4),
   @ls_special    char(1),
   @ld_price      money,
   @ls_flag       char(10),
   @ls_tableno    char(6),
   @il_inumber    integer,
   @id            integer,
   @inumber       integer,
   @numb          integer,
   @tag1          char(2),
   @tag2          char(2),
   @more	         char(1)               -- Y 预定多场

select @pccode = pccode, @shift  = shift,@ls_tableno=tableno, @more = more from pos_reserve where resno = @resno
select @il_inumber=max(isnull(inumber,0)) from pos_order where pc_id=@pc_id
select @il_inumber=isnull(@il_inumber,0)
begin tran
save  tran p_cyj_reserve_s1
exec @ret = p_GetAccnt1 'POS', @menu output
if @shift = "1"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge1 from pos_pccode where pccode = @pccode
else if @shift = "2"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge2 from pos_pccode where pccode = @pccode
else if @shift = "3"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge3 from pos_pccode where pccode = @pccode
else if @shift = "4"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge4 from pos_pccode where pccode = @pccode
else
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_rate = tea_charge5 from pos_pccode where pccode = @pccode

insert pos_menu (tag, menu, tables, guest, bdate, shift, deptno, pccode, posno, tableno, mode, tea_rate, serve_rate, tax_rate, empno3, sta, paid, cusno, haccnt,accnt,saleid, pc_id, remark, resno)
	select tag, @menu, tables, guest, bdate, shift, deptno, pccode, @posno, tableno, mode, @tea_rate, @serve_rate, @tax_rate, @empno, "2", "0", cusno, haccnt,accnt, saleid,@pc_id, rtrim(substring(unit,1, 35)) + '-预定', @resno
	from pos_reserve where resno = @resno
if @@rowcount <> 1
	select @ret = 1

//预订点菜转为正式
update pos_order set menu = @menu where menu = @resno
                                                                            

if @more <> 'Y'     -- 只预定一场
	update pos_reserve set sta = "7", empno = @empno, date = getdate(), menu=@menu where resno = @resno

delete pos_tblav where menu = @menu
update pos_tblav set menu = @menu, sta = '7' where menu = @resno

if @ret <> 0
	rollback tran p_cyj_reserve_s1
commit tran p_cyj_reserve_s1
return 0

;

drop  proc p_cyj_pos_rsv_rebuild_one;
create proc p_cyj_pos_rsv_rebuild_one
	@resno		char(10)					                  
as

declare
	@tableno				char(6),
	@bdate				datetime,
	@shift				char(1),
	@pccode				char(3),
	@guest				int,       				         
	@tables				int,       				     
	@piccnt				int,       				     
	@blockcnt			int,       				     
	@menu_reserve		char(1)

if @resno > '' 
	begin
//	if exists(select 1 from pos_menu where menu = @resno and sta in('2', '5'))
//		select @menu_reserve = 'm', @tableno = tableno, @tables = tables, @pccode = pccode, @bdate = bdate, @shift = shift, @guest = guest from pos_menu where menu = @resno
//	else if exists(select 1 from pos_reserve where resno = @resno and sta in('1', '2'))
//		select @menu_reserve = 'r', @tableno = tableno, @tables = tables, @pccode = pccode, @bdate = convert(datetime,convert(char(10), date0, 1)), @shift = shift, @guest = guest from pos_reserve where resno = @resno
//	else
//		return
//
//	delete pos_rsvdtl where resno = @resno 
//	insert into pos_rsvdtl(resno, pccode, tableno, bdate, shift, quantity, guest)
//		select @resno, @pccode, '', @bdate, @shift, @tables, @guest
//	                                         
//	insert into pos_rsvdtl(resno, pccode, tableno, bdate, shift, quantity, guest)
//		select @resno, @pccode, tableno, @bdate, @shift,  1, 0 from pos_tblav 
//		where menu = @resno and datediff(day, bdate,@bdate) =0 and shift = @shift and charindex(sta, '17') > 0
//	select @piccnt = sum(quantity) from pos_rsvdtl where resno = @resno and rtrim(tableno) is null and datediff(day, bdate,@bdate) =0 and shift = @shift
//	if @piccnt > @tables                                    
//		update pos_rsvdtl set quantity = @piccnt where resno = @resno and rtrim(tableno) is null  and datediff(day, bdate,@bdate) =0 and shift = @shift
//													 
//	select @piccnt = sum(quantity) from pos_rsvdtl where pccode = @pccode and datediff(day, bdate,@bdate) =0 and shift = @shift and tableno > ''
//	select @blockcnt = sum(quantity) from pos_rsvdtl where pccode = @pccode and datediff(day, bdate,@bdate) =0 and shift = @shift and rtrim(tableno) is null
//	if not exists(select 1 from pos_rsvpc where pccode = @pccode and datediff(day, bdate,@bdate) =0 and shift = @shift)
//		insert into pos_rsvpc select @pccode, @bdate, @shift, @blockcnt, @piccnt, @guest
//	update pos_rsvpc set blockcnt = @blockcnt, piccnt = @piccnt
//		where pccode = @pccode and datediff(day,bdate,@bdate) =0 and shift = @shift

	                              
	if @menu_reserve = 'm'
		update pos_menu set tables = (select count(1) from pos_tblav b where b.menu = @resno and b.sta ='7' ) from pos_menu a where a.menu = @resno
	end

;

drop proc  p_cyj_pos_table_nup;
create proc p_cyj_pos_table_nup
	@bdate		datetime,				          
	@shift		char(1),					          
	@pccode		char(3),
	@tableno		char(4),             -- 查询起始台号， X5后版本不用，保证版本统一留着
	@pccodes		char(255),
	@status		char(4),					          
	@menu			char(10),				    
	@foot			char(1) = 'F'	,
	@flag			char(1) 					--1.餐位图  2.	列表	                                          
as
-------------------------------------------------------------------------------------------------
--
--	餐位图一: datawindow用nup显示格式
--	 台位图有以下基本状态
--		sta = '0'  --- 空闲
--		sta = '1'  --- 预定
--		sta = '2'  --- 开台
--		sta = '3'  --- 点单
--		sta = '4'  --- 烧菜
--		sta = '5'  --- 上菜
--		sta = '6'  --- 上完
--		附加态：
--		是否已打单；和选中单是否同单；联单；是否有计时；
--
-------------------------------------------------------------------------------------------------

declare
	@sta			char(1),
	@box			char(1),
	@timesta		char(1),                                    
	@showtimes	int,						                              
	@num0			int,						        
	@num1			int,						        
	@num2			int,						        	
	@num3			int,						        
	@num4			int,						        	
	@num5			int,						        
	@num6			int,						        
	@num7			int,
	@num8			int,			
	@num			int						        

create table #tblsta
(
	tableno 		char(16)      default space(16) not null,
	pcdes			char(20)      default space(20) not null,
	tabdes1		char(10)      default space(10) not null,
	tabdes2		char(10)      default space(10) not null,
	maxno			int     		  default 0 not null,
	pccode		char(3)       default space(3) not null,
	sta			char(1)       default space(1) not null,
	remark1		char(10)      default space(10) not null,
	remark2		char(20)      default space(20) not null,
	menu			char(10)      default space(10) not null,
	box			char(1)       default space(1) not null,
	timesta		int      	  default 0 not null,                                      
	lasttimes	char(4)		  default ''  null,    		                                    
	showtime		char(10)		  default 'F' null,                                          
	jion			char(10)		  default 'F' null,                                                  
	prn			char(10)		  default 'F' null,
	tag_des		char(10)		  null,
	bdate			datetime		  ,
	shift			char(1)		  not null,
	tables		integer			,
	guests		integer			,
	empno3		char(10)			,
	amount		money				,
	pcrec			char(10),	
	resno			char(10)        
)

select @box = '0'

if @status = '所有'
begin
	if @flag = '1'
		begin
		insert into #tblsta
		SELECT b.tableno, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = b.sta, remark1 = d.resno, remark2 = isnull(d.phone,''), b.menu, box = @box, timesta =0, lasttimes ='',showtime='0', jion = 'F',prn='F',
					e.descript,b.bdate,d.shift,d.tables,d.guest,d.empno,0.00,'',d.resno
		 FROM pos_tblsta a, pos_tblav b, pos_pccode c, pos_reserve d,basecode e
		 WHERE d.pccode = c.pccode and d.resno = b.menu  and b.sta > '0' and b.tableno *= a.tableno and datediff(day, b.bdate, @bdate)=0 and b.shift = @shift and d.sta <> '7' 
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and b.menu = d.resno and d.tag = e.code and e.cat = 'pos_tag'
			
		UNION ALL SELECT rtrim(b.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = b.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), b.menu, box = @box, 
					timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,b.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno
		 FROM pos_tblsta a, pos_tblav b, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode and d.menu = b.menu and b.sta > '0' and b.tableno *= a.tableno and datediff(day, b.bdate, @bdate)=0 and b.shift = @shift
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and b.menu = d.menu and d.tag = e.code and e.cat = 'pos_tag'
					
		UNION ALL SELECT a.tableno, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), a.maxno, a.pccode,
				 sta = "0", '', '', '', box = @box, timesta =0, lasttimes ='',showtime='0', jion='F',prn='F',
					'',getdate(),'',0,0,'',0.00,'',''
		 FROM pos_tblsta a, pos_pccode c
		 WHERE a.pccode = c.pccode and (a.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(a.pccode), @pccodes) > 0))
				and (select isnull(max(b.sta), '0') from pos_tblav b where b.tableno = a.tableno and datediff(day, b.bdate, @bdate) = 0 and b.shift = @shift) = '0'
					
		 ORDER BY d.pccode, b.tableno, sta
		end
	else if @flag = '2'  --列表有效
		begin
		insert into #tblsta
		SELECT b.tableno, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = b.sta, remark1 = d.resno, remark2 = isnull(d.phone,''), b.menu, box = @box, timesta =0, lasttimes ='',showtime='0', jion = 'F',prn='F',
					e.descript,b.bdate,d.shift,d.tables,d.guest,d.empno,0.00,'',d.resno
		 FROM pos_tblsta a, pos_tblav b, pos_pccode c, pos_reserve d,basecode e
		 WHERE d.pccode = c.pccode and d.resno = b.menu  and b.sta > '0' and b.tableno *= a.tableno and datediff(day, b.bdate, @bdate)=0 and b.shift = @shift and d.sta <> '7' 
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and b.menu = d.resno and d.tag = e.code and e.cat = 'pos_tag'
					
		UNION ALL SELECT rtrim(b.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = b.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), b.menu, box = @box, 
				timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,b.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno
		 FROM pos_tblsta a, pos_tblav b, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode and d.menu = b.menu and b.sta > '0' and b.tableno *= a.tableno and datediff(day, b.bdate, @bdate)=0 and b.shift = @shift
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and b.menu = d.menu and d.tag = e.code and e.cat = 'pos_tag'
		end
	else if @flag = '3'	--列表删除
		begin
		insert into #tblsta
		SELECT rtrim(d.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = d.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), d.menu, box = @box, 
				timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,d.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno
		 FROM pos_tblsta a, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode  and d.tableno *= a.tableno and datediff(day, d.bdate, @bdate)=0 and d.shift = @shift
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and d.tag = e.code and e.cat = 'pos_tag'
					and d.sta = '7'
		end
	else if @flag = '4'	--列表结帐
		begin
		insert into #tblsta
		SELECT rtrim(d.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = d.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), d.menu, box = @box, 
				timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,d.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno
		 FROM pos_tblsta a, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode  and d.tableno *= a.tableno and datediff(day, d.bdate, @bdate)=0 and d.shift = @shift
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and d.tag = e.code and e.cat = 'pos_tag'
					and d.sta = '3'
		end
	else if @flag = '5'  --列表所有
		begin
		insert into #tblsta
		SELECT b.tableno, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = b.sta, remark1 = d.resno, remark2 = isnull(d.phone,''), b.menu, box = @box, timesta =0, lasttimes ='',showtime='0', jion = 'F',prn='F',
					e.descript,b.bdate,d.shift,d.tables,d.guest,d.empno,0.00,'',d.resno
		 FROM pos_tblsta a, pos_tblav b, pos_pccode c, pos_reserve d,basecode e
		 WHERE d.pccode = c.pccode and d.resno = b.menu  and b.sta > '0' and b.tableno *= a.tableno and datediff(day, b.bdate, @bdate)=0 and b.shift = @shift and d.sta <> '7' 
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and b.menu = d.resno and d.tag = e.code and e.cat = 'pos_tag'
					
		UNION ALL SELECT rtrim(d.tableno) + '-' + d.foliono, isnull(c.descript,''), isnull(a.descript1,''), isnull(a.descript2,''), isnull(a.maxno,0), d.pccode,
				 sta = d.sta, remark1 = d.menu, remark2 = ltrim(convert(char(20), d.amount)), d.menu, box = @box, 
				timesta =0, lasttimes='',
				showtime='0',jion='F',prn='F',
				e.descript,d.bdate,d.shift,d.tables,d.guest,d.empno3,d.amount,d.pcrec,d.resno
		 FROM pos_tblsta a, pos_pccode c, pos_menu d ,basecode e
		 WHERE d.pccode = c.pccode and d.tableno *= a.tableno and datediff(day, d.bdate, @bdate)=0 and d.shift = @shift
				 and (d.pccode = @pccode or ((rtrim(@pccode) is null) and charindex(rtrim(d.pccode), @pccodes) > 0)) and d.tag = e.code and e.cat = 'pos_tag'
		end
	
end 
else if @status = '空闲'
	insert into  #tblsta
	SELECT a.tableno, isnull(c.descript,''), isnull(a.descript1,''),isnull(a.descript2,''), a.maxno, a.pccode,
			 '0', '', '', '', box = @box, timesta =0, lasttimes ='',showtime='0',jion='F',prn='F',
				'',getdate(),'',0,0,'',0.00,'',''
	 FROM pos_tblsta a, pos_pccode c
	 WHERE a.pccode = c.pccode and (a.pccode = @pccode or (@pccode = '  ' and charindex(rtrim(a.pccode), @pccodes) > 0))
	 		and (select isnull(max(b.sta), '0') from pos_tblav b where b.tableno = a.tableno and datediff(day, b.bdate, @bdate) = 0 and b.shift = @shift) = '0'
	 ORDER BY a.pccode, a.tableno
   
delete #tblsta from #tblsta a  where sta = '7' and  tableno + menu in (select tableno + menu from #tblsta b where a.tableno = b.tableno and a.menu = b.menu and b.sta ='8')

update #tblsta set sta = '3' from #tblsta a, pos_menu b where a.menu = b.menu and b.amount > 0 
update #tblsta set sta = '4' from #tblsta a where exists(select 1 from pos_dish b where a.menu = b.menu and charindex('c',lower(b.flag)) > 0 )
update #tblsta set sta = '5' from #tblsta a where exists(select 1 from pos_dish b where a.menu = b.menu and charindex('o',lower(b.flag)) > 0 )
update #tblsta set sta = '6' from #tblsta a where not exists(select 1 from pos_dish b where a.menu = b.menu and charindex('o',lower(b.flag)) = 0  and  charindex(rtrim(code),'XYZ') =0 ) and exists(select 1 from pos_dish c where a.menu = c.menu and charindex(rtrim(code),'XYZ') =0)


                    
select @showtimes = convert(int, rtrim(value)) from sysoption where catalog = 'pos' and item ='showtimes'
if @@rowcount = 0 
begin
	insert into sysoption values('pos', 'showtimes', '0')
	select @showtimes = 0
end 
update #tblsta set showtime = 'T' where convert(int, lasttimes) - @showtimes < 0

if rtrim(@menu) <> null 
	begin
	update #tblsta set jion = 'J' where menu in (select b.menu from pos_tblav a, pos_tblav b  where a.menu = @menu  and a.pcrec = b.pcrec and rtrim(a.pcrec)<>null)
	update #tblsta set jion = 'T' where menu = @menu 
	end

update #tblsta set prn = 'T' from #tblsta a, pos_menu_bill b where a.menu = b.menu and inumber >0

update #tblsta set jion = '' where jion <> 'J' and jion <> 'T'
update #tblsta set jion = '★' where jion = 'T'
update #tblsta set jion = '☆' where jion = 'J'

update #tblsta set prn = '' where prn <> 'T'
update #tblsta set prn = 'Ｐ' where prn = 'T'

select a.*,sta0 = b.sta,b.date0 from #tblsta a,pos_menu b where a.menu *= b.menu order by a.pccode,a.tableno


;

if exists(select 1 from sysobjects where name = 'p_gl_pos_adjust_dish' and type = 'P')
	drop proc p_gl_pos_adjust_dish;

create proc p_gl_pos_adjust_dish
	@menu			char(10),
	@empno		char(10),
	@old_id		integer,
	@pc_id		char(8),			          
	@add_remark	char(15)=NULL,
   @li_inumber integer
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
	@unit			char(4)	,		        
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
	@lastnum				int

select @bdate  = bdate1 from sysdata
select @p_mode = value  from sysoption where catalog = "pos_dish" and item = "p_mode"

begin tran
save  tran p_hry_pos_adjust_dish_s1
update pos_menu set pc_id = @pc_id where menu= @menu
select @code = code, @number = - number,@unit = unit, @dish_sta = sta, @remark = remark, @empno1 =empno1, @plucode = plucode, @id = id, @special=special
  from pos_dish where menu = @menu and inumber = @old_id
if charindex(@dish_sta,'03579M')=0 or (@dish_sta = 'M' and @special ='C')
	begin
	select @ret = 1,@msg = "当前帐目不能被冲销"
	commit tran 
	select @ret,@msg,@charge
	return 0
	end

                       
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
				insert pos_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,number,amount,dsc,srv,tax,empno,empno1,bdate,remark,special,sta,id_cancel,id_master,orderno)
						select @menu,@new_id,plucode,sort,id,code,name1,name2,unit,-1 * number, -1 * amount,-1 * dsc,-1 * srv,-1 * tax,@empno,@empno1,@bdate,@add_remark,'C','2',id_cancel,id_master,orderno
				from pos_dish where menu = @menu and inumber = @old_id
				-- 吧台处理标志
				if exists(select 1 from pos_dish where menu = @menu and inumber = @old_id and charindex('B', upper(flag))>0)
					update pos_dish set flag = 'B' where menu = @menu and inumber = @new_id 
	 			exec p_cyj_bar_pos_sale @menu, @new_id
				update pos_dish set special = 'C', sta = '1' from pos_dish where menu = @menu and inumber = @old_id
				update pos_menu set lastnum = lastnum + 1 from pos_menu where menu = @menu
				select @ret = 0,@msg = "ok"
				commit tran 
				select @ret,@msg,@charge
				return 0
				end

			select @newsta = convert(char(1),convert(int,@dish_sta) + 1)
			select @name1=name1,@name2=@name2 from pos_dish where menu=@menu and inumber=@old_id

			insert pos_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,number,amount,dsc,srv,tax,empno,empno1,bdate,remark,special,sta,id_cancel)
				   select @menu,@new_id,plucode,sort,id,@code,@name1,@name2,@unit,-number,-amount,- dsc,- srv,- tax,@empno,@empno1,@bdate,@add_remark,@special,'2',@old_id
			from pos_dish where menu = @menu and inumber = @old_id
			select @lastnum = @new_id
			-- 吧台处理标志
			if exists(select 1 from pos_dish where menu = @menu and inumber = @old_id and charindex('B', upper(flag))>0)
				update pos_dish set flag = 'B' where menu = @menu and inumber = @new_id 
 			exec p_cyj_bar_pos_sale @menu, @new_id
	
-- 套菜冲销, 处理明细
			select @app_id= @new_id
			declare std_mx_cur cursor for
				select inumber from pos_dish where menu=@menu and sta='M' and id_master=@old_id order by id
			open std_mx_cur
			fetch std_mx_cur into @cur_id
			while @@sqlstatus = 0
			begin
				select @app_id = @app_id + 1
				insert pos_dish(menu,inumber,plucode,sort,id,code,name1,name2,unit,number,amount,dsc,srv,tax,empno,bdate,remark,special,sta,id_cancel,id_master)
				   select @menu,@app_id,plucode,sort,id,code,name1,name2,unit,- number,-amount,-dsc,-srv,-tax,@empno,@bdate,@add_remark,special,'2',@cur_id,@new_id
						from pos_dish where menu=@menu and id = @cur_id
				select @lastnum = @app_id
				-- 吧台处理标志
				if exists(select 1 from pos_dish where menu = @menu and inumber = @cur_id and charindex('B', upper(flag))>0)
					update pos_dish set flag = 'B' where menu = @menu and inumber = @app_id 
	 			exec p_cyj_bar_pos_sale @menu, @app_id
				fetch std_mx_cur into @cur_id
			end
			close std_mx_cur
			deallocate cursor std_mx_cur
			update pos_menu set lastnum = @lastnum  from pos_menu where menu = @menu
-- 更新被冲dish的状态
			update pos_dish set sta = @newsta where menu = @menu and inumber = @old_id
-- 更新技师状态			                
			update pos_empnoav set sta ='0' where bdate = @bdate and shift =@shift and empno = @empno1 and inumber = @old_id
			update pos_assess set number1 = number1 + @number where id = @id
			update pos_dish set sta='1' where menu=@menu and sta='M' and id_master=@old_id
			select @charge = amount from pos_menu where menu = @menu
			select @ret = 0,@msg = "成功"
		end

-- 服务费合计
	update pos_dish set amount = (select sum(srv) from pos_dish where menu = @menu and charindex(rtrim(ltrim(code)), 'YZ') =0 and charindex(sta,'03579')>0 ) where menu = @menu and rtrim(ltrim(code)) = 'Z'
-- 税合计
	update pos_dish set amount = (select sum(tax) from pos_dish where menu = @menu and charindex(rtrim(ltrim(code)), 'YZ') =0 and charindex(sta,'03579')>0 ) where menu = @menu and rtrim(ltrim(code)) = 'Y'
-- 计算menu合计
	update pos_menu set amount = (select sum(amount) - sum(dsc) + sum(srv) + sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		amount0 = (select sum(amount) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		dsc = (select sum(dsc) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		srv = (select sum(srv) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
		tax = (select sum(tax) from pos_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0)
		where menu = @menu
-- 计算餐桌合计
	update pos_tblav set amount = isnull((select sum(amount) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0 )
	+ (select sum(srv) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	+ (select sum(tax) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0)
	- (select sum(dsc) from pos_dish where menu = @menu and tableno = a.tableno and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ')=0), 0)
	from pos_tblav a where a.menu = @menu  and sta ='7'
  
--cq modify 更新配料的销售还有消菜原因
   delete pos_hxsale where menu=@menu and inumber=@li_inumber
 end
commit tran 
select @ret,@msg,@charge
return 0;


drop  proc p_gl_pos_detail;
create proc p_gl_pos_detail
	@as_menu				char(10), 			                          
	@date					datetime				              
as
--------------------------------------------------------------------------------------------------------
--
--    统计交班表和部门日报表前的准备数据pos_detail_jie, pos_detail_dai
--	 服务费和税取自dish.code = Z,Y
--	 菜的金额 = amount - dsc
--	 单菜款待特殊处理 pos_dish.special = 'E'	
--	 p_gl_pos_get_item_code @pccode, @plu_code, @tocode out ---> @plu_code = @plucode + @sort + @code
--	 四川锦江 p_gl_pos_get_item_code @pccode, @plu_code, @tocode out ---> @plu_code = @sort + @code
--
--	 #dai.distribute 5.0从paymth.distribute char(4) 取, x5从pccode.deptno8 char(3), 取时前面加 'T'
--	 光标直接调用 Pos_menu, pos_dish, pos_pay 可能有死锁，容易造成报表统计不准， 改为临时表
--
--------------------------------------------------------------------------------------------------------

declare
	@bdate				datetime, 			            
                                  
   @master_menu		char(10),			          
   @pcrec				varchar(20), 		          
   @menu					char(10), 			          
	@deptno				char(2), 			          
	@pccode				char(3), 			          
	@posno				char(2), 			          
	@shift				char(1), 
	@empno				char(10), 
	@paid					char(1), 
	@sta					char(1), 
	@pay_sta				char(1), 			                             
	@mode					char(3), 			        
	@dsc_rate			money, 				          
	@serve_rate			money, 				            
	@tax_rate			money, 				            
                                  
	@sort					char(4), 			        
	@code					char(6), 			        
	@plucode				char(2),
   @modcode          char(15),
	@plu_code			char(10),			                            
	@inumber				integer, 			            
	@type					char(1), 			                                                         
	@name1				char(20), 			            
	@name2				char(20), 			            
	@number				money, 				        
	@amount0				money, 				          
	@dsc_amount			money, 				            
	@amount				money, 				                
	@amount1				money, 				                                        
	@amount2				money, 				                                
	@amount3				money, 				                                
	@amount4				money, 				    
	@serve0				money, 				            
	@serve1				money, 				                                          
	@serve2				money, 				                                  
	@serve3				money, 				                                  
	@tax0					money, 				            
	@tax1					money, 				                                          
	@tax2					money, 				                                  
	@tax3					money, 				                                  
	@reason				char(3), 			
	@reason1				char(3), 			                        
	@reason2				char(3), 			                      
	@reason3				char(3), 			                                          
   @special				char(1), 			              
                      
   @i						integer, 
	@distribute			char(3), 
   @tocode				char(3), 			                        
   @paycode				char(5), 
   @jamount				money, 
   @damount				money, 
   @thispart			money, 
   @sumpart				money, 
   @divval				money, 
   @diffpart			money, 
   @credit				money, 
   @dsc					money, 
   @srv					money, 
   @tax					money, 
   @pccodes				varchar(255),
	@p_menu				char(11)          -- @as_menu  + '%'
   
create table #menu
(
	menu			char(10)		not null, 				            
	charge		money			default 0 not null 	         
)
create unique index #menu on #menu (menu)
   
create table #jie
(
	menu			char(10)		not null, 				            
	code			char(15)		not null, 				           
	id				integer		not null, 				              
	amount		money			default 0 not null, 	          
	special		char(1)		not null,				                      
	reason		char(3)		not null 				              
)
create unique index #jie on #jie (menu, code, id)
declare c_jie cursor for select menu, code, id, amount, special from #jie where amount <> 0 order by code 
   
create table #dai
(
	paycode		char(5)		default '', 				                            
	distribute	char(4)		default '', 				                                    
	amount		money			default 0,		 
	reason3		char(3)		default ''					                                  
)	 
create unique index #dai on #dai (paycode, reason3)
declare c_dai cursor for select paycode, distribute, sum(amount), reason3 from #dai where amount <> 0 
	group by paycode, distribute, reason3
	order by paycode, distribute, reason3
   
create table #jiedai
(
	menu			char(10)		not null, 				          
	code			char(15)		not null, 				          
	id				integer		not null, 				              
	paycode		char(5)		default '', 			                          
	amount		money			default 0, 
	reason3		char(3)		default ''				                  
)	 
create unique index #jiedai on #jiedai (menu, code, id, paycode, reason3)
declare c_jiedai cursor for select menu, code, id from #jiedai where paycode = @paycode and reason3 = @reason3 order by code 
   
select @bdate = bdate1 from sysdata
if ltrim(rtrim(@as_menu)) is null
	select @p_menu = '%'
else
	select @p_menu = @as_menu + '%'


if @date = @bdate																								        
	begin
	select * into #pos_menu from pos_menu 
	select * into #dish from pos_dish 
	select * into #pay from pos_pay 

	select @pcrec = pcrec from pos_menu where menu = @as_menu

	declare c_master_menu cursor for
		select distinct menu, pcrec, paid from #pos_menu where menu like @p_menu and (pcrec = '' or pcrec is null)
		union select pcrec, pcrec, paid from #pos_menu where menu like @p_menu and (pcrec <> '' and pcrec is not null)
	   order by menu
	declare c_menu cursor for
		select menu, pccode, shift, empno3, paid, deptno, posno, mode, reason, dsc_rate, serve_rate, tax_rate, bdate
		from #pos_menu where menu = @master_menu or (pcrec = @pcrec and @pcrec >'')
		order by menu
	declare c_dish cursor for
		select plucode,sort, code, name1, inumber, number, amount, dsc, srv, tax, special, reason, sta
		from #dish where menu = @menu and charindex(sta, '03579A') >0 order by code, id                                   
	declare c_pay cursor for                                                    
		select paycode, number, amount, sta, reason    
		from #pay where menu = @menu and charindex(sta, '23') > 0 order by paycode, number  
                                         
	end
else if datediff(dd, @date, @bdate) = 1																        
	begin
                                                                         
	select @pcrec = pcrec from pos_tmenu where menu = @as_menu

	declare c_master_menu cursor for
		select distinct menu, pcrec, paid from pos_tmenu where menu like @p_menu and pcrec = '' or pcrec is null
		union select pcrec, pcrec, paid from pos_tmenu where menu like @p_menu and pcrec <> '' and pcrec is not null
	   order by menu
	declare c_menu cursor for
		select menu, pccode, shift, empno3, paid, deptno, posno, mode, reason, dsc_rate, serve_rate, tax_rate, bdate
		from pos_tmenu where menu = @master_menu or (pcrec = @pcrec and @pcrec >'')
		order by menu
	declare c_dish cursor for
		select plucode,sort, code, name1, inumber, number, amount, dsc, srv, tax, special, reason, sta
		from pos_tdish where menu = @menu and charindex(sta, '03579A') >0  order by code, id                                   
	declare c_pay cursor for                                                    
		select paycode, number, amount, sta, reason    
		from pos_tpay where menu = @menu and charindex(sta, '23') > 0 order by paycode, number  
	end
else																												        
	begin
	select * into #hmenu from pos_hmenu where bdate = @date
	create index index1 on #menu(menu)

	select @pcrec = pcrec from pos_hmenu where menu = @as_menu

	declare c_master_menu cursor for
		select distinct menu, pcrec, paid from #hmenu where menu like @p_menu and pcrec = '' or pcrec is null
		union select pcrec, pcrec, paid from #hmenu where menu like @p_menu and pcrec <> '' and pcrec is not null
		order by menu
	declare c_menu cursor for
		select menu, pccode, shift, empno3, paid, deptno, posno, mode, reason, dsc_rate, serve_rate, tax_rate, bdate
		from #hmenu where menu = @master_menu or (pcrec = @pcrec and @pcrec >'')
		order by menu
	declare c_dish cursor for
		select plucode,sort, code, name1, inumber, number, amount, dsc, srv, tax, special, reason, sta
		from pos_hdish where menu = @menu  and charindex(sta, '03579A') >0 order by code, id                                   
	declare c_pay cursor for       
		select paycode, number, amount, sta, reason    
		from pos_hpay where menu = @menu and charindex(sta, '23') > 0 order by paycode, number  
	end


if (select substring(ltrim(rtrim(@p_menu)),1,1)) = '%' or ltrim(rtrim(@p_menu)) is null
	begin 
	delete pos_detail_jie where date = @date
	delete pos_detail_dai where date = @date 
   end
else           --  对jie,dai 删除时注意是否有连单
	if @date = @bdate																								        
		begin
		delete pos_detail_jie where date = @date and menu like @p_menu or menu in(select menu from #pos_menu where pcrec = @pcrec and @pcrec >'')
		delete pos_detail_dai where date = @date and menu like @p_menu or menu in(select menu from #pos_menu where pcrec = @pcrec and @pcrec >'')
		end
	else
		begin
		delete pos_detail_jie where date = @date and menu like @p_menu or menu in(select menu from #hmenu where pcrec = @pcrec and @pcrec >'')
		delete pos_detail_dai where date = @date and menu like @p_menu or menu in(select menu from #hmenu where pcrec = @pcrec and @pcrec >'')
		end

                       
open c_master_menu
fetch c_master_menu into @master_menu, @pcrec, @paid
while @@sqlstatus =0
   begin
	if @paid <> '1' or exists (select 1 from pos_detail_jie where date = @date and menu = @master_menu)
		begin
		fetch c_master_menu into @master_menu, @pcrec, @paid
		continue
		end
	   
                            
                                        
   truncate table #jie 
   truncate table #dai
   truncate table #jiedai
	open c_menu
	fetch c_menu into @menu, @pccode, @shift, @empno, @paid, @deptno, @posno, @mode, @reason1, @dsc_rate, @serve_rate, @tax_rate, @date
	while @@sqlstatus =0
	   begin
                                                  
		open c_dish
		fetch c_dish into @plucode,@sort, @code, @name1, @inumber, @number, @amount, @dsc, @srv, @tax, @special, @reason3, @sta
		while @@sqlstatus = 0
			begin
         select @modcode=@sort + @code   
			if substring(@code, 1, 4) = '' or @sta in ('B', 'C') -- or 	( @amount = 0  ) 
				begin
				fetch c_dish into  @plucode ,@sort, @code, @name1, @inumber, @number, @amount, @dsc, @srv, @tax, @special, @reason3, @sta
				continue
				end
			else
				begin
				           
				if not exists (select 1 from #menu where menu = @menu)
					insert #menu (menu, charge) values (@menu, @amount -  @dsc )
				else
					update #menu set charge = charge + @amount - @dsc where menu = @menu
				select @serve0 = 0, @tax0 = 0, @serve1 = 0, @tax1 = 0, @serve2 = 0, @tax2 = 0, @serve3 = 0, @tax3 = 0, @type = '0'
                                                                           
                                                              
                                                  
                                                                 
                                        

                                                   
                                                   
                                                   
				if @special = 'T'                                 -- 特殊类只用于零头处理，统计时等同于普通类 cyj 04.11.23
					select @special = 'N'
				if @special = 'T'
					select @amount3 =  - @amount, @amount1 = 0, @amount2 = 0, @amount = 0
				else if  @special = 'X'
					select @amount3 = @dsc, @amount1 = 0, @amount2 = 0
				else
					begin
                                    
					if @sta > '0' and @sta <= '9'                         
						begin
						select @type = convert(char(1), convert(int, @sta) + 1)
						select @amount3 = @dsc
						                              
						exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@modcode,@amount,@dsc_rate,@result = @dsc_amount output
						                                
						select @dsc_amount = @amount - @dsc_amount
						                                      
						select @amount3 = @amount3 - @dsc_amount
						end
					else
						select @amount3 = 0, @dsc_amount = @dsc
					if @sta <> 'A'       -- 如果是零头，不必计算折扣和服务费
						begin
						                                
						exec p_gl_pos_get_discount	@deptno, @pccode, @mode, @modcode, @amount, @dsc_amount, @dsc_rate, @result1 = @amount1 output, @result2 = @amount2 output, @result3 = @reason2 output
						                                  
						exec p_gl_pos_get_serve		@deptno, @pccode, @mode, @modcode, @amount, @amount1, @amount2, @serve_rate, @result0 = @serve0 output, @result1 = @serve1 output, @result2 = @serve2 output
						                                  
						exec p_gl_pos_get_tax		@deptno, @pccode, @mode, @modcode, @amount, @amount1, @amount2, @tax_rate, @result0 = @tax0 output, @result1 = @tax1 output, @result2 = @tax2 output
						end
					else
						select @amount1=0, @amount2=0, @amount3=0, @serve0=0, @serve1=0, @serve2=0,@serve3=0, @tax0=0, @tax1=0, @tax2=0, @tax3=0
					end

                                  
				insert #jie (menu, code, id, amount, special, reason) values (@menu, @code, @inumber, @amount - @dsc, @special,@reason3 )
				select @tocode = tocode from pos_speed where fmcode = @pccode + rtrim(ltrim(@sort)) + @code
				if @@rowcount = 0
					begin  
					select @plu_code =  rtrim(isnull(rtrim(ltrim(@sort)), '')) + @code     --cq modify in 'dfhs'
                                        
                                      
                                                                          

					exec p_gl_pos_get_item_code @pccode, @plu_code, @tocode out
                                         
                                            
					delete from pos_speed where fmcode = @pccode+rtrim(ltrim(@sort))+@code
					insert pos_speed (fmcode, tocode) select @pccode+rtrim(ltrim(@sort))+@code, @tocode
						where (select count(1) from pos_speed where fmcode = @pccode+rtrim(ltrim(@sort))+@code) = 0
					end 
                           
                
				insert pos_detail_jie values(@date, @deptno, @posno, @pccode, @shift, @empno, @menu, @modcode, @inumber, @type, @name1, @name2, @number, isnull(@amount, 0), isnull(@amount1, 0), isnull(@amount2, 0), isnull(@amount3,0), 
					isnull(@serve0, 0), isnull(@serve1, 0), isnull(@serve2, 0), isnull(@serve3, 0), isnull(@tax0, 0), isnull(@tax1, 0), isnull(@tax2, 0), isnull(@tax3, 0), @reason2, @reason1, @reason3, @special, @tocode)
				end  
			fetch c_dish into @plucode,@sort, @code, @name1, @inumber, @number, @amount, @dsc, @srv, @tax, @special, @reason3, @sta
			end
		close c_dish

		open c_pay
		fetch c_pay into  @paycode, @number, @amount, @pay_sta,@reason
		while @@sqlstatus = 0 
			begin
			if not exists (select 1 from pccode where rtrim(pccode) = @paycode and deptno8 > '')
				select @reason = ''
			if @pay_sta = '2'
				select @reason = '定',@reason3 = '定'
			              
			select @paycode = deptno1 from pccode where rtrim(deptno1) = @paycode 
			if not exists (select 1 from #dai where paycode = @paycode and reason3 = @reason)
				insert #dai (paycode, amount, reason3) values (@paycode, @amount, @reason)
			else
				update #dai set amount = amount + @amount where paycode = @paycode and reason3 = @reason
			fetch c_pay into  @paycode, @number, @amount, @pay_sta,@reason
			end
		close c_pay
		fetch c_menu into @menu, @pccode, @shift, @empno, @paid, @deptno, @posno, @mode, @reason1, @dsc_rate, @serve_rate, @tax_rate, @date
		end
	close c_menu
	                           
	update #dai set distribute = 'T' + pccode.deptno8
		from pccode where pccode.pccode = #dai.paycode and substring(pccode.deptno8,1, 1) > ''
                                               
                       
	select @i = 0
	while @i < 2
		begin
		if exists ( select 1 from #dai where ((@i = 0 and substring(distribute, 1, 1) = 'T') or (@i = 1 and substring(distribute, 1, 1) <> 'T')) and amount <> 0 )
			begin
			select @credit = isnull(sum(amount), 0) from #dai
			if @credit <> 0
				begin
				                     
				select @dsc = isnull(sum(amount),0) from #jie where special = 'E'
				open c_dai
				fetch c_dai into @paycode, @distribute, @damount, @reason3
				while @@sqlstatus = 0
					begin
					                                                  
					if (@i = 0 and (substring(@distribute, 1, 1) <> 'T' or  @damount = @dsc)) or (@i = 1 and substring(@distribute, 1, 1) = 'T')
						begin
							fetch c_dai into @paycode, @distribute, @damount, @reason3
							continue
						end
					if @i = 0                          
						select @damount = @damount - @dsc
					select @sumpart = 0, @divval = @damount / (@credit - @dsc)
					open c_jie
					fetch c_jie into @menu, @code, @inumber, @jamount, @special
					while @@sqlstatus = 0
						begin
						if	@special = 'E'
							begin
							fetch c_jie into @menu, @code, @inumber, @jamount, @special
							continue
							end
						select @thispart = round( @jamount * @divval , 2)
						select @sumpart  = @sumpart + @thispart 
						insert #jiedai (menu, code, id, paycode, amount, reason3) values (@menu, @code, @inumber, @paycode, @thispart, @reason3)
						fetch c_jie into @menu, @code, @inumber, @jamount, @special
						end
					close c_jie
					select @diffpart = @damount  - @sumpart
					if @diffpart <> 0
						begin 
						open c_jiedai
						fetch c_jiedai into @menu, @code, @inumber
						while @@sqlstatus = 0
							begin
							update #jiedai set amount = amount + @diffpart
								where menu = @menu and code = @code and id = @inumber and paycode = @paycode and reason3 = @reason3
							if @@rowcount = 1
								break
							fetch c_jiedai into @menu, @code, @inumber
							end
						close c_jiedai
						end 
					fetch c_dai into @paycode, @distribute, @damount, @reason3
					end
				close c_dai
				                      
				if @i = 0 		
					begin
					select @paycode = pccode from pccode where deptno2 = 'ENT'
					insert #jiedai (menu, code, id, paycode, amount, reason3) 
					select @menu, code, id, @paycode, amount, reason from #jie where  special = 'E'
					end
				insert pos_detail_dai (date, menu, paycode, amount, reason3)
				select @date, menu, paycode, sum(amount), reason3 from #jiedai group by menu, paycode, reason3
				if @i = 0
					begin
					insert pos_detail_jie (date, deptno, posno, pccode, shift, empno, menu, code, id, type, name1, name2, number, amount0, amount1, amount2, amount3, 
					serve0, serve1, serve2, serve3, tax0, tax1, tax2, tax3, reason1, reason2,reason3, special, tocode)
                select date, a.deptno, a.posno,a.pccode, a.shift, a.empno, a.menu, a.code, a.id, isnull(b.paycode,''), a.name1, a.name2,a.number,a.amount0,a.amount1,a.amount2, isnull(b.amount,0),
                a.serve0,a.serve1,a.serve2,a.serve3,a.tax0,a.tax1,a.tax2,a.tax3,a.reason1,a.reason2, isnull(b.reason3,''),a.special, a.tocode
						from pos_detail_jie a, #jiedai b where a.date = @date and a.menu = b.menu and a.id = b.id
					end
				truncate table #jiedai
				end
			end
		select @i = @i + 1
		end
		if not exists ( select 1 from pos_detail_dai where date = @date and menu = @menu  )
			insert pos_detail_dai (date, menu, paycode, amount, reason3)
			select @date, @menu, paycode, sum(amount), reason3 from #dai group by paycode, reason3
		if exists ( select 1 from pos_detail_dai where date = @date and menu = @menu ) and
			not exists ( select 1 from pos_detail_jie where date = @date and menu = @menu )
			begin
			select @tocode = min(code) from pos_itemdef where pccode = @pccode
                                                                                                                
			insert pos_detail_jie values(@date, @deptno, @posno, @pccode, @shift, @empno, @menu, '', 0, '', '', '', 0, 0, 0, 0, 0, 
				0, 0, 0, 0, 0, 0, 0, 0, '', '', '', 'N', @tocode)
			end
	fetch c_master_menu into @master_menu, @pcrec, @paid
	end
close c_master_menu
   
deallocate cursor c_master_menu
deallocate cursor c_menu
deallocate cursor c_dish
deallocate cursor c_pay
deallocate cursor c_jie
deallocate cursor c_dai
deallocate cursor c_jiedai
                      
insert #jiedai (menu, paycode, code, id)
select menu, min(paycode), '', 0 from pos_detail_dai where menu in 
(select menu from #menu a where charge <> (select sum(amount) from pos_detail_dai b where a.menu = b.menu))
group by menu
update #jiedai set amount = (select sum(amount) from pos_detail_dai b where date = @date and #jiedai.menu = b.menu group by menu)
update pos_detail_dai set pos_detail_dai.amount = pos_detail_dai.amount + b.charge - a.amount
from #jiedai a, #menu b where a.menu = b.menu and a.menu = pos_detail_dai.menu and a.paycode = pos_detail_dai.paycode

return 0
;


if exists ( select * from sysobjects where name = 'p_gl_pos_shiftrep' and type  = 'P')
	drop proc p_gl_pos_shiftrep;
create proc p_gl_pos_shiftrep
	@pc_id				char(4),			-- 站点 
	@limpcs				varchar(120),	-- Pccode 限制
	@date					datetime,		-- 报表日期 
	@empno				char(10),		-- 工号 null 表示所有工号 
	@shift				char(1),			-- 班别 null 表示所有班别 
	@break				char(1),			-- '1' 只统计交班表posjie,posdai 
	@langid				int	=0			-- 语种 0 中文 
as
--------------------------------------------------------------------------------------------------
--
-- 餐饮交班表--
-- posdai.code = 'FF1' 转登记AR账, 已经包含在转AR里，只需在最后单列    --  
-- posdai.code = 'G'   登记账结账, 包括转到其他账   jjhotel cyj --  
--
--------------------------------------------------------------------------------------------------
declare
	@bdate				datetime,	--营业日期
	@type					char(3), 
	@tocode				char(3), 
	@pccod            char(5),
	@pccode1          char(3),
	@deptno1          char(3),
	@deptno8          char(3),
	@payname          char(12),
	@descript1			char(12), 
	--  
	@dsc_sttype 		char(2) , 
	@p_daokous			varchar(100), 
	@daokou	  			char(1) , 
	-- menu information required 
	@menu					char(10), 		--主单号 
	@pccode				char(3), 		--营业点 
	-- dish information required 
	@code					char(3), 		--付款码 
	@amount				money, 			--菜单金额
	-- tmp variables 
	@descript			char(12), 
	@paycode				char(3), 
	@paytail				char(1), 
	@i						integer, 
	@feed					money, 
	@feedd				money, 
	@pccodes				varchar(255), 
	@modu_ids			varchar(255), 
	@codes				varchar(255), 
	@paycodes			varchar(255), 
	@vpos					integer,
	@tocode1          char(3),
	@amountall        money

-- Xubin added 2000/07/10,更新pos_namedef
--insert pos_namedef select '602','<赠送>' where not exists(select 1 from pos_namedef where code = '602')
--insert pos_namedef select '605','<全免>' where not exists(select 1 from pos_namedef where code = '605')
--insert pos_namedef select '607','<单菜折扣>' where not exists(select 1 from pos_namedef where code = '607')

if rtrim(@empno) is null
	select @empno = '%'
if rtrim(@shift) is null
	select @shift = '%'
select @bdate = bdate1 from sysdata
-- get posposdef pccodes --
select @pccodes = pccodes  from pos_station where pc_id = @pc_id
select @dsc_sttype = value from sysoption where catalog = 'pos' and item = 'dsc_sttype'
if @@rowcount = 0
	select @dsc_sttype  = 'nn' 
select @p_daokous = null
--
select * into #account from account where 1 = 2
select * into #pos_menu from pos_menu where 1 = 2
select * into #pos_pay from pos_pay where 1 = 2
select * into #pos_reserve from pos_reserve where 1 = 2
select * into #pos_detail_jie_link from pos_detail_jie_link where 1=2

if @date = @bdate
	begin
	insert #account select * from account where bdate = @date and empno like @empno and shift like @shift
	insert #pos_menu select * from pos_menu
	insert #pos_pay select * from pos_pay where  bdate = @date
	insert #pos_reserve select * from pos_reserve
	end
else
	begin
	insert #account select * from account where bdate = @date and empno like @empno and shift like @shift
		union select * from haccount where bdate = @date and empno like @empno and shift like @shift
	insert #pos_menu select * from pos_hmenu where bdate = @date
	insert #pos_pay select * from pos_hpay where  bdate = @date
	insert #pos_pay select * from pos_pay where  bdate = @date         -- 可能有定金
	insert #pos_reserve select * from pos_reserve where resno in (select menu from #pos_pay)
	insert #pos_reserve select * from pos_hreserve where resno in (select menu from #pos_pay) and resno not in(select resno from #pos_reserve)
	end
delete #account where charindex(modu_id, @modu_ids) = 0 or charindex(pccode, @pccodes) = 0 or charindex(pccode, @limpcs) = 0
delete #pos_menu where not empno3 like @empno or not shift like @shift or charindex(pccode, @pccodes) = 0 or charindex(pccode, @limpcs) = 0
declare c_pccode cursor for select pccode, daokou from pos_pccode
open c_pccode
fetch c_pccode into @pccode, @daokou
while @@sqlstatus = 0
	begin
	select @p_daokous = @p_daokous + @pccode + @daokou+'#'
	fetch c_pccode into @pccode, @daokou
	end
close c_pccode
deallocate cursor c_pccode
-- preparation --
delete posjie where pc_id = @pc_id  
delete posdai where pc_id = @pc_id

-- 分摊处理 --
exec p_gds_pos_detail_jie_link @pc_id, @date, '0'

--******************************************************--
-- 根据pos_detail_jie, pos_detail_dai生成posjie, posdai --
--******************************************************--
insert into #pos_detail_jie_link select * from pos_detail_jie_link where date = @date and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 and pc_id = @pc_id and shift like @shift and empno like @empno 
update #pos_detail_jie_link set amount0 = 0,amount1= 0,amount2 = 0 where type in (select pccode from pccode where pccode>'900' and deptno8<>'' and deptno8 is not null) and special <>'E'

-- 所有点菜
insert posjie  (pc_id, pccode, code, feed)  select @pc_id,pccode,tocode, sum(amount0 -amount1 - amount2 - amount3)
	from #pos_detail_jie_link where date = @date  and special <> 'E'
	group by pccode,tocode

-- 单菜折扣
insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '607', sum(amount3)
	from #pos_detail_jie_link where date = @date and type = '8' and special = 'N'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 
	and pc_id = @pc_id
	group by pccode
insert posdai (pc_id, pccode, paycode, paytail, creditd) select @pc_id, pccode, 'D93', char(29), sum(amount3)
	from #pos_detail_jie_link where date = @date and type = '8' and special = 'N'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 
	and pc_id = @pc_id
	group by pccode
-- 全免
insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '605', sum(amount3)
	from #pos_detail_jie_link where date = @date and type = '6' and special = 'N'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 
	and pc_id = @pc_id
	group by pccode
insert posdai (pc_id, pccode, paycode, paytail, creditd) select @pc_id, pccode, 'D93', char(28), sum(amount3)
	from #pos_detail_jie_link where date = @date and type = '6' and special = 'N'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 
	and pc_id = @pc_id
	group by pccode
-- 赠送
insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '602', sum(amount3)
	from #pos_detail_jie_link where date = @date and type = '4' and special = 'N'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 
	and pc_id = @pc_id
	group by pccode
insert posdai (pc_id, pccode, paycode, paytail, creditd) select @pc_id, pccode, 'D93', char(27), sum(amount3)
	from #pos_detail_jie_link where date = @date and type = '4' and special = 'N'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 
	and pc_id = @pc_id
	group by pccode
-- 百分比折扣
insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '610', sum(amount1+amount2)
	from #pos_detail_jie_link where date = @date and type in ('0','4','6','8') and special <> 'T'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 
	and pc_id = @pc_id
	group by pccode
insert posdai (pc_id, pccode, paycode, paytail, creditd) select @pc_id, pccode, 'D93', char(30), sum(amount1+amount2)
	from #pos_detail_jie_link where date = @date and type in ('0','4','6','8') and special <> 'T'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 
	and pc_id = @pc_id
	group by pccode
-- 特优码折扣
insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '620', sum(amount3)
	from #pos_detail_jie_link where date = @date and type = '0' and special = 'T'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 
	and pc_id = @pc_id
	group by pccode
insert posdai (pc_id, pccode, paycode, paytail, creditd) select @pc_id, pccode, 'D93', char(31), sum(amount3)
	from #pos_detail_jie_link where date = @date and type = '0' and special = 'T'
	and shift like @shift and empno like @empno
	and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0 
	and pc_id = @pc_id
	group by pccode
-- 折扣，款待
insert posjie (pc_id, pccode, code, feed) select  @pc_id,a.pccode,substring(b.deptno8,1,3),sum(a.amount3)
	from #pos_detail_jie_link a,pccode b where a.date = @date and b.pccode = a.type
	and shift like @shift and empno like @empno 
	and charindex(a.pccode, @pccodes) > 0 and charindex(a.pccode, @limpcs) > 0 
	and pc_id = @pc_id
	group by a.pccode,substring(b.deptno8,1,3)

//declare c_cur2 cursor for			 --select distinct paycode from pos_detail_dai
//   select c.pccode,c.deptno8      --@pc_id,a.pccode, c.pccode, '', sum(b.amount)
//		from pccode c
//		where c.deptno8 <> '' and c.deptno8 is not null and c.pccode > '900'
//		
//open c_cur2 
//fetch c_cur2 into @pccod,@deptno8
//while @@sqlstatus = 0
//	begin
//--	SELECT @pccod,@payname
//	insert posjie (pc_id, pccode, code, feed) select @pc_id, a.pccode, @deptno8, sum(a.amount3)
//	from #pos_detail_jie_link a,pccode b where a.date = @date and b.pccode = a.type --a.type = '0' and a.special = 'E' --b.deptno1 = a.type
//	and shift like @shift and empno like @empno and b.pccode = @pccod
//	and charindex(a.pccode, @pccodes) > 0 and charindex(a.pccode, @limpcs) > 0 
//	and pc_id = @pc_id
//	group by a.pccode , b.deptno8
//	fetch c_cur2 into @pccod,@deptno8
//	end
//close c_cur2
//deallocate cursor c_cur2



--insert posjie (pc_id, pccode, code, feed) select @pc_id, a.pccode, b.deptno8, sum(a.amount0)
--	from #pos_detail_jie_link a,pccode b where a.date = @date and b.pccode = a.type --a.type = '0' and a.special = 'E' --b.deptno1 = a.type
--	and shift like @shift and empno like @empno
--	and charindex(a.pccode, @pccodes) > 0 and charindex(a.pccode, @limpcs) > 0 group by a.pccode --, b.deptno8
-- 借方总计
insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '999', sum(feed)
	from posjie where pc_id = @pc_id  group by pccode
-- 借方合计
insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '6', sum(feed)
	from posjie where pc_id = @pc_id and code < '6' group by pccode
-- 人均消费
insert posjie (pc_id, pccode, code, feed) select distinct @pc_id, pccode, '99B', 0
	from posjie where pc_id = @pc_id
-- 前台入账
select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#03#05#')
insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, 'ZZZ', sum(charge) from #account group by pccode
-- 人数
insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '99A', sum(guest) from #pos_menu
	where paid = '1' group by pccode
---- 逃帐
if exists (select 1 from #pos_menu where paid = '0')
	insert posjie (pc_id, pccode, code, feed) select @pc_id, pccode, '900', sum(amount) from #pos_menu
	where paid = '0' group by pccode

-- 贷方明细
-- a.冲减预付
insert posdai (pc_id, pccode, paycode, paytail, creditd,descript) 
		select @pc_id, a.pccode, 'B' + substring(c.deptno1,2,2), '', sum(b.amount),c.descript
		from #pos_menu a, pos_detail_dai b,pccode c
		where a.menu = b.menu and a.paid = '1'
		and b.paycode = c.pccode and substring(b.reason3, 1, 2) = '定' and (c.deptno8 = '' or c.deptno8 is null)
		group by a.pccode, c.deptno1, c.descript

-- b.实收
insert posdai (pc_id, pccode, paycode, paytail, creditd) 
	select @pc_id, a.pccode,  c.deptno1, '', sum(b.amount)
	from #pos_menu a, pos_detail_dai b,pccode c
	where a.menu = b.menu and a.paid = '1'
	and b.paycode =  c.pccode and substring(b.reason3, 1, 2) <> '定' and (c.deptno8 = '' or c.deptno8 is null)
	group by a.pccode, c.deptno1


-- c.折扣款待
insert posdai (pc_id, pccode, paycode, paytail, creditd) 
	select @pc_id,a.pccode,'D' + substring(c.deptno1, 2, 2),'',sum(b.amount)
	from #pos_menu a, pos_detail_dai b,pccode c
	where a.menu = b.menu and a.paid = '1'
	and b.paycode =  c.pccode and c.deptno8 <> '' and c.deptno8 is not null
	group by a.pccode, c.deptno1

//declare c_cur1 cursor for --select distinct paycode from pos_detail_dai
//   select c.pccode,c.descript,deptno1      --@pc_id,a.pccode, c.pccode, '', sum(b.amount)
//		from pccode c
//		where c.deptno8 <> '' and c.deptno8 is not null and c.pccode > '900'
//		
//open c_cur1 
//fetch c_cur1 into @pccod,@payname,@deptno1
//while @@sqlstatus = 0
//	begin
//	insert posdai (pc_id, pccode, paycode, paytail, creditd) 
//		select @pc_id, a.pccode, 'D' + substring(@deptno1,2,2), '', sum(b.amount)
//		from #pos_menu a, pos_detail_dai b,pccode c
//		where a.menu = b.menu and a.paid = '1'
//		and b.paycode =  c.pccode and b.paycode = @pccod and c.deptno8 <> '' and c.deptno8 is not null
//		group by a.pccode, c.deptno1
//	fetch c_cur1 into @pccod,@payname,@deptno1
//	end
//close c_cur1
//deallocate cursor c_cur1
//

-- 预收定金
insert posdai (pc_id, pccode, paycode, paytail, creditd, descript) 
	select @pc_id, a.pccode, 'E' + substring(c.deptno1, 2, 2), '', sum(b.amount),'预收'
	from #pos_reserve a, #pos_pay b, pccode c
	where a.resno = b.menu and b.bdate = @date and b.shift like @shift and b.empno like @empno
	and b.sta = '1' and charindex(b.crradjt, 'C CO') = 0
	and b.paycode = c.pccode
	group by a.pccode, c.deptno1, b.paycode

-- 转登记AR账
//if exists(select 1 from sysoption where catalog = 'hotel' and item = 'name' and value like '%锦江宾馆%')
//	insert posdai (pc_id, pccode, paycode, paytail, creditd, descript) 
//		select @pc_id, a.pccode, 'FF1', '', sum(b.amount),'转登记账'
//		from #pos_menu a, #pos_pay b, pccode c, master d
//		where a.menu = b.menu and b.bdate = @date and b.shift like @shift and b.empno like @empno
//		--and charindex(a.pccode, @pccodes) > 0 and charindex(a.pccode, @limpcs) > 0 
//		and b.accnt = d.accnt and d.accnt like 'AR%' and d.artag1 = 'Z'
//		and charindex(b.crradjt, 'C CO') = 0  
//		and b.paycode = c.pccode
//		group by a.pccode, c.deptno1
//
-- jjhotel 特殊处理
-- 登记AR账收回
-----jjh----------------------------
//declare	@billno		char(10), @sum_charge money
//select * into #araccnt0 from account where 1=2
//select * into #araccnt from account where 1=2
//insert into #araccnt0 select a.* from account a, master b where a.accnt = b.accnt and a.accnt like 'AR%' and b.artag1 = 'Z' and a.bdate = @date and a.shift like @shift and a.empno like @empno
//insert into #araccnt0 select a.* from haccount a, master b where a.accnt = b.accnt and a.accnt like 'AR%' and b.artag1 = 'Z' and a.bdate = @date and a.shift like @shift and a.empno like @empno
//insert into #araccnt0 select b.* from #araccnt0 a,account b where a.accnt = b.accnt and a.billno = b.billno and substring(a.billno,2,5) = substring(convert(char(8), @date, 12),2,5) and b.bdate <> @date
//insert into #araccnt0 select b.* from #araccnt0 a,haccount b where a.accnt = b.accnt and a.billno = b.billno and substring(a.billno,2,5) = substring(convert(char(8), @date, 12),2,5) and b.bdate <> @date
//
//insert into #araccnt select distinct * from #araccnt0
//	-- 只需当日发生账和当日结的账
//delete #araccnt where bdate <> @date and billno not like 'B%'

	-- 结账
//insert posdai (pc_id, pccode, paycode, paytail, creditd, descript) 
//	select @pc_id, a.pccode, 'G' + substring(c.deptno1,2,2), '', 0, ''
//	from #araccnt a, #araccnt b, pccode c
//	where a.accnt = b.accnt and a.billno = b.billno and a.billno like 'B%' and a.pccode < '9' and b.pccode > '9'
//	and b.pccode = c.pccode
//	group by a.pccode, b.pccode
//
//declare	@tmp_pc		char(3), @tmp_charge money
//
//declare  c_billno cursor  for select distinct billno from #araccnt where billno like 'B%' and substring(billno,2,5) = substring(convert(char(8), @date,12),2,5)
//declare  c_pc     cursor  for select pccode, charge from #araccnt where pccode < '9' and billno = @billno
//open c_billno
//fetch c_billno into @billno
//while @@sqlstatus = 0 
//	begin
//	select @sum_charge = sum(charge) from #araccnt where billno = @billno
//	if @sum_charge <> 0
//		begin
//		open c_pc
//		fetch c_pc into @tmp_pc, @tmp_charge
//		while @@sqlstatus = 0 
//			begin
//			update posdai set creditd = creditd + round(@tmp_charge * c.credit / @sum_charge, 2) 
//			from posdai a, #araccnt c, pccode b where c.billno = @billno and c.pccode > '9'
//			and a.pccode = @tmp_pc   and a.paycode = 'G' + substring(b.deptno1, 2, 2)
//			and c.pccode = b.pccode
//
//			fetch c_pc into @tmp_pc, @tmp_charge
//			end
//		close c_pc
//		end
//	fetch c_billno into @billno
//	end
//close c_billno
//deallocate cursor c_billno
//deallocate cursor c_pc

	-- 转走账
//insert posdai (pc_id, pccode, paycode, paytail, creditd, descript) 
//	select @pc_id, a.pccode, 'GG1' , '', sum(-1 * a.charge), '转走账'
//	from #araccnt a 
//	where  a.billno  like 'T%' and a.pccode < '9'
//	group by a.pccode
//	-- 输入账
//insert posdai (pc_id, pccode, paycode, paytail, creditd, descript) 
//	select @pc_id, a.pccode, 'GG2' , '', sum(a.charge), '输入账'
//	from #araccnt a 
//	where  rtrim(a.billno) is null and pccode < '9' and a.modu_id ='02'
//	group by a.pccode
//
-----jjh----------------------------



-- 贷方总计
insert posdai (pc_id, pccode, paycode, paytail, descript, creditd) 
	select @pc_id, pccode, 'D99', '', '总    计', sum(creditd)
	from posdai where pc_id = @pc_id and paycode < 'D99' group by pccode

-- 贷方合计
update posdai set descript = '合并结帐', paycode = 'C--' where pc_id = @pc_id and paycode = ''
insert posdai (pc_id, pccode, paycode, paytail, descript, creditd) 
	select @pc_id, pccode, 'C99', '', '**合计**', sum(creditd) 
	from posdai where pc_id = @pc_id and paycode < 'C99' group by pccode
if exists (select 1 from posdai where paycode like 'B%')
	begin
	insert posdai (pc_id, pccode, paycode, paytail, descript, creditd) 
		select @pc_id, pccode, 'B', '', '  冲预付', sum(creditd) 
		from posdai where pc_id = @pc_id and paycode like 'B%' group by pccode
	insert posdai (pc_id, pccode, paycode, paytail, descript, creditd) 
		select @pc_id, pccode, 'C', '', '  实收款', sum(creditd) 
		from posdai where pc_id = @pc_id and paycode > 'C' and paycode < 'C99' group by pccode
	end
insert posdai (pc_id, pccode, paycode, paytail, descript, creditd) 
	select @pc_id, pccode, 'E', '', '  预收合计', sum(creditd) 
	from posdai where pc_id = @pc_id and paycode like 'E%' group by pccode

-- jjhotel 特殊处理
-- 登记AR账收回
---------------------------------
//insert posdai (pc_id, pccode, paycode, paytail, descript, creditd) 
//	select @pc_id, pccode, 'G', '', '  登记收回', sum(creditd) 
//	from posdai where pc_id = @pc_id and paycode like 'G%' group by pccode
//-- after treatment 1 --
if @langid = 0 
	begin
	update posjie set descript = a.descript from pos_namedef a, chgcod b, pos_pccode c,pos_int_pccode d
		where posjie.pc_id = @pc_id and posjie.pccode = c.pccode and b.pccode = d.pccode and c.pccode = d.pos_pccode and d.shift = @shift and a.deptno = b.deptno and a.code = posjie.code
	update posjie set descript = pccode.descript from pccode where posjie.pc_id = @pc_id 
		and posjie.code = substring(pccode.deptno1, 1, 3) and posjie.code > '6' -- and posjie.code < '999'
	end
else
	begin
	update posjie set descript = a.descript from pos_namedef a, chgcod b, pos_pccode c,pos_int_pccode d
		where posjie.pc_id = @pc_id and posjie.pccode = c.pccode and b.pccode = d.pccode and c.pccode = d.pos_pccode and d.shift = @shift and a.deptno = b.deptno and a.code = posjie.code
	update posjie set descript = pccode.descript from pccode where posjie.pc_id = @pc_id 
		and posjie.code = substring(pccode.deptno1, 1, 3) and posjie.code > '6' -- and posjie.code < '999'
	end

---------------------------------

--
-- 修改前
--update posdai set descript = pccode.descript from pccode
--	where posdai.pc_id = @pc_id and substring(posdai.paycode, 2, 2) = substring(pccode.deptno8, 1, 2) and paytail = ' ' and paycode not like 'G%' and paycode not like 'E%' and paycode not like 'B%' and paycode not like 'C%'
-- 修改后
if @langid = 0 
	begin
	update posdai set descript = pccode.descript from pccode
		where posdai.pc_id = @pc_id and substring(posdai.paycode, 2, 2) = substring(pccode.deptno8, 1, 2) and paytail = ' ' and paycode not like 'G%' and paycode not like 'E%' and paycode not like 'B%' and paycode not like 'C%' and paycode >'999'
	update posdai set descript = pccode.descript from pccode
		where posdai.pc_id = @pc_id and posdai.paycode = pccode.pccode and paytail = ' ' and pccode.pccode >'900' 
	update posdai set descript = pccode.descript from pccode
		where posdai.pc_id = @pc_id and substring(posdai.paycode, 2, 2) = substring(pccode.deptno1, 2, 2) and paytail = ' ' and pccode.pccode >'900' 
	update posdai set descript1 = pccode.descript from pccode
		where posdai.pc_id = @pc_id and substring(posdai.paycode, 2, 2) = substring(pccode.deptno8, 1, 2)  and paycode not like 'E%' and paycode not like 'F%'
	update posdai set descript = '百分比折扣' where pc_id = @pc_id and paycode = 'D93' and paytail = char(30)
	update posdai set descript = '特优码折扣' where pc_id = @pc_id and paycode = 'D93' and paytail = char(31)
	
	update posdai set descript = '<赠送>' where pc_id = @pc_id and paycode = 'D93' and paytail = char(27)
	update posdai set descript = '<全免>' where pc_id = @pc_id and paycode = 'D93' and paytail = char(28)
	update posdai set descript = '<单菜折扣>' where pc_id = @pc_id and paycode = 'D93' and paytail = char(29)
	update posdai set descript = '<款待>' where pc_id = @pc_id and paycode = 'D94' 
	update posdai set descript = '<折扣>' where pc_id = @pc_id and paycode = 'D93' and paytail =''
	end
else
	begin
	update posdai set descript = pccode.descript1 from pccode
		where posdai.pc_id = @pc_id and substring(posdai.paycode, 2, 2) = substring(pccode.deptno8, 1, 2) and paytail = ' ' and paycode not like 'G%' and paycode not like 'E%' and paycode not like 'B%' and paycode not like 'C%' and paycode >'999'
	update posdai set descript = pccode.descript1 from pccode
		where posdai.pc_id = @pc_id and posdai.paycode = pccode.pccode and paytail = ' ' and pccode.pccode >'900' 
	update posdai set descript = pccode.descript1 from pccode
		where posdai.pc_id = @pc_id and substring(posdai.paycode, 2, 2) = substring(pccode.deptno1, 2, 2) and paytail = ' ' and pccode.pccode >'900' 
	update posdai set descript1 = pccode.descript1 from pccode
		where posdai.pc_id = @pc_id and substring(posdai.paycode, 2, 2) = substring(pccode.deptno8, 1, 2)  and paycode not like 'E%' and paycode not like 'F%'
	update posdai set descript = 'Per DSC' where pc_id = @pc_id and paycode = 'D93' and paytail = char(30)
	update posdai set descript = 'Spec. DSC' where pc_id = @pc_id and paycode = 'D93' and paytail = char(31)
	
	update posdai set descript = 'Reward' where pc_id = @pc_id and paycode = 'D93' and paytail = char(27)
	update posdai set descript = 'Free' where pc_id = @pc_id and paycode = 'D93' and paytail = char(28)
	update posdai set descript = 'Dish DSC' where pc_id = @pc_id and paycode = 'D93' and paytail = char(29)
	update posdai set descript = 'ENT' where pc_id = @pc_id and paycode = 'D94' 
	update posdai set descript = 'DSC' where pc_id = @pc_id and paycode = 'D93' and paytail =''
	update posdai set descript = '*Sub total*' where pc_id = @pc_id and paycode = 'C99' 
	update posdai set descript = 'Total' where pc_id = @pc_id and paycode = 'D99' 
	update posdai set descript = '  Eearnest Used' where pc_id = @pc_id and paycode = 'B' 
	update posdai set descript = '  Gathering' where pc_id = @pc_id and paycode = 'C' 
	update posdai set descript = '  Eearnest' where pc_id = @pc_id and paycode = 'E' 

	end



--delete posjie where pc_id = @pc_id and feed = 0
--delete posdai where pc_id = @pc_id and creditd = 0
--
declare c_posjie cursor for select pccode, feed from posjie where code = '999' and pc_id = @pc_id
open c_posjie 
fetch c_posjie into @pccode, @feed
while @@sqlstatus = 0
	begin
	select @feedd = isnull((select feed from posjie where pc_id = @pc_id and pccode = @pccode and code = '99A'), 0)
	if @feedd = 0
		update posjie set feed = 0 where pc_id = @pc_id and pccode = @pccode and code = '99B'
	else
		update posjie set feed = round(@feed/@feedd, 2) where pc_id = @pc_id and pccode = @pccode and code  = '99B'
	fetch c_posjie into @pccode, @feed
	end
close c_posjie
deallocate cursor c_posjie
-- 
--select * from posdai
if charindex(@break, '1') > 0
	return 0
delete pos_shift_detail  where pc_id = @pc_id  

declare c_detail_jie cursor for
	select pccode, menu, '0', amount0, tocode, '金额' from #pos_detail_jie_link
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0
		and type = '0' and special <> 'T'
		and pc_id = @pc_id
	union all select pccode, menu, '1', amount1+amount2, tocode, '百分比折扣' from #pos_detail_jie_link
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0
		and type = '0' and special <> 'T'
		and pc_id = @pc_id
-- Xubin added 2000/07/10,更新pos_namedef
	union all select pccode, menu, '2', amount3, tocode, '特优码折扣' from #pos_detail_jie_link
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0	and special = 'T'
		and charindex(type,'486') = 0
		and pc_id = @pc_id
	union all select pccode, menu, '4', amount3, tocode, '赠送' from #pos_detail_jie_link
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0	and special = 'N'
		and type = '4'
		and pc_id = @pc_id
	union all select pccode, menu, '6', amount3, tocode, '全免' from #pos_detail_jie_link
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0	and special = 'N'
		and type = '6'
		and pc_id = @pc_id
	union all select pccode, menu, '8', amount3, tocode, '单菜折扣' from #pos_detail_jie_link
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0	and special = 'N'
		and type = '8'
		and pc_id = @pc_id
	union all select pccode, menu, '0', amount0, tocode, '金额' from #pos_detail_jie_link
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0
		and (type = '8' or type = '6' or type = '4') and special = 'N'
		and pc_id = @pc_id
	union all select pccode, menu, '1', amount1+amount2, tocode, '百分比折扣' from #pos_detail_jie_link
		where date = @date and shift like @shift and empno like @empno
		and charindex(pccode, @pccodes) > 0 and charindex(pccode, @limpcs) > 0
		and (type = '8' or type = '6' or type = '4') and special = 'N'
		and pc_id = @pc_id
	union all select a.pccode, a.menu, a.type, a.amount3, a.tocode, rtrim(b.descript1)+rtrim(b.descript2)
		from #pos_detail_jie_link a, pccode b
		where b.deptno1 = a.type and a.date = @date and a.shift like @shift and a.empno like @empno
		and charindex(a.pccode, @pccodes) > 0 and charindex(a.pccode, @limpcs) > 0
		and a.pc_id = @pc_id
--		and a.type <> ''

--********************************************--
-- 根据#pos_detail_jie_link生成pos_shift_detail借方 --
--********************************************--
-- get pos_namedef codes --

declare c_namedef cursor for select distinct code, descript
	from posjie where pc_id = @pc_id and code < '6' order by code
open c_namedef 
fetch c_namedef into @code, @descript
while @@sqlstatus = 0 
	begin
	select @codes = @codes + @code +'#'
	fetch c_namedef into @code, @descript
	end 
close c_namedef
deallocate cursor c_namedef
-- statistics begins --
open c_detail_jie
fetch c_detail_jie into @pccode, @menu, @type, @amount, @tocode, @descript1
while @@sqlstatus  = 0
	begin
	if @amount = 0 and @type <> '0'
		begin
		fetch c_detail_jie into @pccode, @menu, @type, @amount, @tocode, @descript1
		continue
		end
	if not exists (select 1 from pos_shift_detail where pc_id = @pc_id and pccode = @pccode and menu = @menu and type = '{{{')
		begin
		insert pos_shift_detail (pc_id, pccode, menu, descript1, type) values (@pc_id, @pccode, @menu, '合计', '{{{')
		if not exists ( select 1 from pos_shift_detail where pc_id = @pc_id and pccode = @pccode and menu = '小计' and type = '{{{')
			begin
			insert pos_shift_detail (pc_id, pccode, menu, descript1, type) values (@pc_id, @pccode, '小计', '合计', '{{{')
			if not exists ( select 1 from pos_shift_detail where pc_id = @pc_id and menu = '总计' and type = '{{{')
				insert pos_shift_detail (pc_id, pccode, menu, descript1, type) values (@pc_id, '{{', '总计', '合计', '{{{')
			end
		end
	if not exists (select 1 from pos_shift_detail where pc_id = @pc_id and pccode = @pccode and menu = @menu and type = @type)
		begin
		insert pos_shift_detail (pc_id, pccode, menu, descript1, type) values (@pc_id, @pccode, @menu, @descript1, @type)
		if not exists ( select 1 from pos_shift_detail where pc_id = @pc_id and pccode = @pccode and menu = '小计' and type = @type)
			begin
			insert pos_shift_detail (pc_id, pccode, menu, descript1, type) values (@pc_id, @pccode, '小计', @descript1, @type)
			if not exists ( select 1 from pos_shift_detail where pc_id = @pc_id and menu = '总计' and type = @type)
				insert pos_shift_detail (pc_id, pccode, menu, descript1, type) values (@pc_id, '{{', '总计', @descript1, @type)
			end
		end
	select @i = 0 ,  @vpos = convert(int, (charindex(@tocode, @codes) + 3) / 4)
	while @i < 2
		begin
		if @i = 1
			begin
			if @type <> '0'
				select @amount = - @amount
			select @type = '{{{'
			end
--select @pccode, @menu, @type, @amount, @tocode, @descript1,@vpos

		 if @vpos = 1
			 update pos_shift_detail set jie1 = jie1 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 2
			 update pos_shift_detail set jie2 = jie2 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 3
			 update pos_shift_detail set jie3 = jie3 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 4
			 update pos_shift_detail set jie4 = jie4 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 5
			 update pos_shift_detail set jie5 = jie5 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 6
			 update pos_shift_detail set jie6 = jie6 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 7
			 update pos_shift_detail set jie7 = jie7 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 8
			 update pos_shift_detail set jie8 = jie8 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 9
			 update pos_shift_detail set jie9 = jie9 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 10
			 update pos_shift_detail set jie10 = jie10 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 11
			 update pos_shift_detail set jie11 = jie11 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 12
			 update pos_shift_detail set jie12 = jie12 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 13
			 update pos_shift_detail set jie13 = jie13 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 14
			 update pos_shift_detail set jie14 = jie14 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 15
			 update pos_shift_detail set jie15 = jie15 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 16
			 update pos_shift_detail set jie16 = jie16 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 17
			 update pos_shift_detail set jie17 = jie17 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 18
			 update pos_shift_detail set jie18 = jie18 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 19
			 update pos_shift_detail set jie19 = jie19 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 20
			 update pos_shift_detail set jie20 = jie20 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 21
			 update pos_shift_detail set jie21 = jie21 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 22
			 update pos_shift_detail set jie22 = jie22 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 23
			 update pos_shift_detail set jie23 = jie23 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 24
			 update pos_shift_detail set jie24 = jie24 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 25
			 update pos_shift_detail set jie25 = jie25 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 26
			 update pos_shift_detail set jie26 = jie26 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 27
			 update pos_shift_detail set jie27 = jie27 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 28
			 update pos_shift_detail set jie28 = jie28 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else if @vpos = 29
			 update pos_shift_detail set jie29 = jie29 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 else
			 update pos_shift_detail set jie30 = jie30 + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		 update pos_shift_detail set jiettl = jiettl + @amount where pc_id = @pc_id and ((pccode = @pccode and (menu = @menu or menu = '小计')) or menu = '总计') and type = @type
		select @i = @i + 1
		end
	fetch c_detail_jie into @pccode, @menu, @type, @amount, @tocode, @descript1
	end 
close c_detail_jie
deallocate cursor c_detail_jie

--**************************************--
-- 根据pos_dish生成pos_shift_detail贷方 --
--**************************************--
-- get paymth codes --
declare c_paymth cursor for select distinct paycode, paytail
	from posdai where pc_id = @pc_id and substring(paycode, 2, 2) <> '99' order by paycode, paytail
open c_paymth
fetch c_paymth into @paycode, @paytail
while @@sqlstatus = 0 
	begin
	select @paycodes = @paycodes + substring(@paycode, 2, 2) + @paytail +'#'
	fetch c_paymth into @paycode, @paytail
	end 
close c_paymth
deallocate cursor c_paymth
--

declare c_detail_dai cursor for select b.pccode, a.menu, c.deptno1, a.amount
	from pos_detail_dai a, #pos_menu b, pccode c where a.menu = b.menu and b.paid = '1' and a.paycode = c.pccode and c.argcode >'9'
	order by a.menu, a.paycode
open c_detail_dai
fetch c_detail_dai into @pccode, @menu, @code, @amount
while @@sqlstatus = 0
	begin
	select @vpos = convert(int, (charindex(substring(@code, 2, 2)+' ', @paycodes)+3)/4)
	if exists (select 1 from pos_shift_detail where pccode = @pccode and menu = @menu and type = @code)
		select @type = @code
	else
		select @type = '{{{'
	exec p_gl_pos_shiftdai @vpos, @amount, @pc_id, @pccode, @menu, @type
	fetch c_detail_dai into @pccode, @menu, @code, @amount
	end 
close c_detail_dai
deallocate cursor c_detail_dai
-- 百分比折, 特优码折 --
declare c_shift_detail cursor for
	select pccode, menu, type, jiettl from pos_shift_detail
		where pc_id = @pc_id and datalength(rtrim(menu)) = 10 and type in ('1', '2','4','6','8')
open c_shift_detail
fetch c_shift_detail into @pccode, @menu, @type, @amount
while @@sqlstatus = 0
	begin
	if @type = '1'
		select @vpos = convert(int, (charindex('93'+char(30), @paycodes)+3)/4)
	else if @type = '2'
		select @vpos = convert(int, (charindex('93'+char(31), @paycodes)+3)/4)
	else if @type = '4'
		select @vpos = convert(int, (charindex('93'+char(27), @paycodes)+3)/4)
	else if @type = '6'
		select @vpos = convert(int, (charindex('93'+char(28), @paycodes)+3)/4)
	else if @type = '8'
		select @vpos = convert(int, (charindex('93'+char(29), @paycodes)+3)/4)
	exec p_gl_pos_shiftdai @vpos, @amount, @pc_id, @pccode, @menu, @type
	fetch c_shift_detail into @pccode, @menu, @type, @amount
	end
close c_shift_detail
deallocate cursor c_shift_detail
-- 人数 --
update pos_shift_detail set guest = isnull((select b.guest from #pos_menu b where b.menu = pos_shift_detail.menu), 0)
	where pc_id = @pc_id
-- 小计 --
delete pos_shift_detail where type = '0' and (select count(1) from pos_shift_detail a where a.menu = pos_shift_detail.menu and pc_id = @pc_id) = 2
update pos_shift_detail set guest = (select sum(guest) from pos_shift_detail b where b.pc_id = @pc_id and b.pccode = pos_shift_detail.pccode and b.type = '{{{')
	where pc_id = @pc_id and menu = '小计'
-- 总计 --
update pos_shift_detail set guest = (select sum(guest) from pos_shift_detail b where b.pc_id = @pc_id and b.menu = '小计' and b.type = '{{{')
	where pc_id = @pc_id and menu = '总计'
update pos_shift_detail set descript = b.descript from  pos_pccode b where  pos_shift_detail.pccode = b.pccode

return 0
;


drop  proc p_hry_pos_pshiftrep1;
create proc p_hry_pos_pshiftrep1
   @pc_id   char(4)

as

declare
   @code    char(3),
   @coden   char(1),
   @pccode  char(3),
   @pccodes varchar(120),
   @spccode char(3),
   @fee     money,
   @vpos    int,
   @tl      money,
   @count   money,
   @avfee   money,
   @jiedai  char(1),
   @itemcnt int

declare c_pccode cursor for select distinct pccode from posjie where pc_id = @pc_id
	union  select distinct pccode from posdai where pc_id = @pc_id
order by pccode

open  c_pccode
fetch c_pccode into @pccode
while @@sqlstatus = 0
   begin
   select @pccodes = @pccodes + @pccode +'#'
   fetch c_pccode into @pccode
   end
close c_pccode
deallocate cursor c_pccode
delete  pdeptrep where pc_id = @pc_id
insert  pdeptrep (pc_id,jiedai,code,descript) select distinct @pc_id,'A',code,descript from posjie where pc_id = @pc_id
declare c_ydeptjie cursor for select pccode,code,feed from posjie where pc_id = @pc_id
				       order by pccode,code
select @spccode = ''
open  c_ydeptjie
fetch c_ydeptjie into @pccode,@code,@fee
while @@sqlstatus = 0
   begin
   if @spccode <> @pccode
	   select @spccode=@pccode,@vpos = convert(int,(charindex(@pccode,@pccodes)+3)/4)
   if @vpos = 1
	  update pdeptrep set v1 = v1 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 2
	  update pdeptrep set v2 = v2 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 3
	  update pdeptrep set v3 = v3 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 4
	  update pdeptrep set v4 = v4 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 5
	  update pdeptrep set v5 = v5 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 6
	  update pdeptrep set v6 = v6 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 7
	  update pdeptrep set v7 = v7 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 8
	  update pdeptrep set v8 = v8 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 9
	  update pdeptrep set v9= v9 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 10
	  update pdeptrep set v10 = v10 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 11
	  update pdeptrep set v11 = v11 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 12
	  update pdeptrep set v12 = v12 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 13
	  update pdeptrep set v13 = v13 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 14
	  update pdeptrep set v14 = v14 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 15
	  update pdeptrep set v15 = v15 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 16
	  update pdeptrep set v16 = v16 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 17
	  update pdeptrep set v17 = v17 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 18
	  update pdeptrep set v18 = v18 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 19
	  update pdeptrep set v19 = v19 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 20
	  update pdeptrep set v20 = v20 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 21
	  update pdeptrep set v21 = v21 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 22
	  update pdeptrep set v22 = v22 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 23
	  update pdeptrep set v23 = v23 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 24
	  update pdeptrep set v24 = v24 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 25
	  update pdeptrep set v25 = v25 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 26
	  update pdeptrep set v26 = v26 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 27
	  update pdeptrep set v27 = v27 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 28
	  update pdeptrep set v28 = v28 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 29
	  update pdeptrep set v29 = v29 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 30
	  update pdeptrep set v30 = v30 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   if @vpos = 31
	  update pdeptrep set v31 = v31 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 32
	  update pdeptrep set v32 = v32 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 33
	  update pdeptrep set v33 = v33 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 34
	  update pdeptrep set v34 = v34 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 35
	  update pdeptrep set v35 = v35 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 36
	  update pdeptrep set v36 = v36 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 37
	  update pdeptrep set v37 = v37 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 38
	  update pdeptrep set v38 = v38 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 39
	  update pdeptrep set v39 = v39 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   else if @vpos = 40
	  update pdeptrep set v40 = v40 + @fee where pc_id = @pc_id and jiedai='A' and code = @code
   fetch c_ydeptjie into @pccode,@code,@fee
   end
close c_ydeptjie
deallocate cursor c_ydeptjie
update pdeptrep set vtl = v1+v2+v3+v4+v5+v6+v7+v8+v9+v10+v11+v12+v13+v14+v15+v16+v17+v18+v19+v20+v21+v22+v23+v24+v25+v26+v27+v28+v29+v30+v31+v32+v33+v34+v35+v36+v37+v38+v39+v40
		 where pc_id = @pc_id and jiedai ='A'
select @count = vtl from pdeptrep where pc_id = @pc_id and jiedai ='A' and code ='99A'
select @tl    = vtl from pdeptrep where pc_id = @pc_id and jiedai ='A' and code ='999'
if @count = 0
   select @avfee = 0
else
   select @avfee = @tl/@count
update pdeptrep set vtl = @avfee where pc_id = @pc_id and jiedai ='A' and code ='99B'
insert pdeptrep (pc_id,jiedai,code,coden,descript)
	   select distinct @pc_id,'B',paycode,paytail,descript from posdai
					   where pc_id = @pc_id
declare c_ydeptdai cursor for select pccode,paycode,paytail,creditd from posdai
				   where pc_id = @pc_id
				   order by pccode,paycode,paytail
select @spccode = ''
open c_ydeptdai
fetch c_ydeptdai into @pccode,@code,@coden,@fee
while @@sqlstatus = 0
   begin
   if @spccode <> @pccode
	  select @spccode=@pccode,@vpos = convert(int,(charindex(@pccode,@pccodes)+3)/4)
   if @vpos = 1
	  update pdeptrep set v1 = v1 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 2
	  update pdeptrep set v2 = v2 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 3
	  update pdeptrep set v3 = v3 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 4
	  update pdeptrep set v4 = v4 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 5
	  update pdeptrep set v5 = v5+ @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 6
	  update pdeptrep set v6 = v6 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 7
	  update pdeptrep set v7= v7 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 8
	  update pdeptrep set v8 = v8 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 9
	  update pdeptrep set v9 = v9 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 10
	  update pdeptrep set v10 = v10 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 11
	  update pdeptrep set v11 = v11 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 12
	  update pdeptrep set v12 = v12 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 13
	  update pdeptrep set v13 = v13 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 14
	  update pdeptrep set v14 = v14 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 15
	  update pdeptrep set v15 = v15 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 16
	  update pdeptrep set v16 = v16 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
  else if @vpos = 17
	  update pdeptrep set v17 = v17 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 18
	  update pdeptrep set v18 = v18 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 19
	  update pdeptrep set v19 = v19 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 20
	  update pdeptrep set v20 = v20 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 21
	  update pdeptrep set v21 = v21 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 22
	  update pdeptrep set v22 = v22 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 23
	  update pdeptrep set v23 = v23 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 24
	  update pdeptrep set v24 = v24 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 25
	  update pdeptrep set v25 = v25 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 26	  update pdeptrep set v26 = v26 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 27
	  update pdeptrep set v27 = v27 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 28
	  update pdeptrep set v28 = v28 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 29
	  update pdeptrep set v29 = v29 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 30
	  update pdeptrep set v30 = v30 +@fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   if @vpos = 31
	  update pdeptrep set v31 = v31 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 32
	  update pdeptrep set v32 =v32 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 33
	  update pdeptrep set v33 = v33 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 34
	  update pdeptrep set v34 = v34 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 35
	  update pdeptrep set v35 = v35 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 36
	  update pdeptrep set v36 = v36 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 37
	  update pdeptrep set v37 = v37 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 38
	  update pdeptrep set v38 = v38 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 39
	  update pdeptrep set v39 = v39 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   else if @vpos = 40
	  update pdeptrep set v40 = v40 + @fee where pc_id = @pc_id and jiedai='B' and code = @code and coden= @coden
   fetch c_ydeptdai into @pccode,@code,@coden,@fee
   end
close c_ydeptdai
deallocate cursor c_ydeptdai
update pdeptrep set vtl = v1+v2+v3+v4+v5+v6+v7+v8+v9+v10+v11+v12+v13+v14+v15+v16+v17+v18+v19+v20+v21+v22+v23+v24+v25+v26+v27+v28+v29+v30+v31+v32+v33+v34+v35+v36+v37+v38+v39+v40
		 where pc_id = @pc_id and jiedai ='B'
select @itemcnt = 0
declare c_pdeptrep cursor for select jiedai,code,coden from pdeptrep
                   where pc_id = @pc_id order by jiedai,code,coden
open c_pdeptrep
fetch  c_pdeptrep into @jiedai,@code,@coden
while @@sqlstatus = 0
   begin
   select @itemcnt = @itemcnt + 1
   update pdeptrep set itemcnt = @itemcnt where pc_id = @pc_id and jiedai = @jiedai
                                                and code = @code and coden = @coden
   fetch  c_pdeptrep into @jiedai,@code,@coden
   end
close c_pdeptrep
deallocate cursor c_pdeptrep
update pdeptrep set itemcnt = itemcnt - (select count(*) from pdeptrep b where b.pc_id = @pc_id and b.jiedai ='A')
                where pdeptrep.pc_id = @pc_id and pdeptrep.jiedai ='B'
update pdeptrep set itemcnt = (select max(itemcnt)+1 from pdeptrep where pdeptrep.pc_id = @pc_id and pdeptrep.jiedai ='B') where pdeptrep.pc_id = @pc_id  and pdeptrep.code ='B'
return 0
;
