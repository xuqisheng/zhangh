drop proc p_xb_sp_adjust_dish;
create proc p_xb_sp_adjust_dish
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
	@plucode			char(10),
	@id				int,
	@plu_amount		money,
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
	@unit			char(4)	,
	@amount		money	,
	@number		money	,

	@dsc_rate		money,
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
	@dish_sta			char(1),
	@timestamp_old		varbinary(8),
	@timestamp_new		varbinary(8),
	@action 				char(4),
 	@newamount			money,
	@hx					char(1),
	@oldamount 			money,
	@srv					money,
	@tax				 	money,
	@dsc				 	money

if @opmode='F'
	select @newamount = @setamount, @hx='T'
else
	select @hx = 'F'

select @bdate  = bdate1 from sysdata
select @p_mode = value  from sysoption where catalog = "sp_dish" and item = "p_mode"

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
else if @opmode='F'
   select @action = '海鲜份量调整', @opmode='0'
else
begin
   select @ret=1,@msg='无效操作'
   return 0
end

select @opmodesta = @opmode
begin tran
save  tran p_hry_pos_adjust_dish_s1

select @timestamp_old = timestamp from sp_menu where menu = @menu
update sp_menu set pc_id = @pc_id where menu = @menu
select @code = code, @number = number, @amount = amount, @plu_amount = amount - dsc,@dsc = dsc,@srv = srv,@tax = tax,
		 @dish_sta = sta, @remark = remark,@special=special, @id = id, @plucode = sort + code
  from sp_dish where menu = @menu and inumber = @old_id
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
 from sp_menu where menu = @menu
if @@rowcount = 0
	select @ret = 1,@msg = "主单" + @menu + "已不存在或已销单"
else if @sta ='3'
	select @ret = 1,@msg = "主单" + @menu + "已被其他收银员结帐"
else
	begin
	select @name1 = name1,@name2 = name2,@unit = unit,@oprice = price  from pos_plu where id = @id
	if @@rowcount = 0
		select @ret = 1,@msg = "菜号" + rtrim(@code) + "已不存在"
	else
		begin
		select @serve_charge0 = 0,@serve_charge = 0,@tax_charge0 = 0,@tax_charge = 0,@charge = 0
		if @special <> 'T' and @special <> 'X'
			begin


			if @hx='T'
				begin

				if not exists(select 1 from pos_hxdef where pccode=@pccode and @code like code+'%')
					select @ret = 1,@msg = "该菜不属于海鲜类 !"
				else if @newamount = @number
					select @ret = 1,@msg = "份量没有改变 !"

				if @ret = 1
					goto gout
				else
					select @setamount = round(@newamount * @plu_amount / @number,2)
				end
			if charindex(@opmode , '35') > 0
				select @dsc = @amount, @srv = 0, @tax = 0
			else if @opmode='7'
				begin
				select @dsc = @setamount
				exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@plucode,@amount,@dsc,@serve_rate,@result0 = @serve_charge0 output,@result = @srv output
				exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@plucode,@amount,@dsc,@tax_rate,@result0 = @tax_charge0 output,@result = @tax output
				select @dsc = @amount - @dsc
				end
			else if @opmode='0'
				begin
				exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@plucode,@amount,@dsc_rate,@result = @dsc output
				exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@plucode,@amount,@dsc,@serve_rate,@result0 = @serve_charge0 output,@result = @srv output
				exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@plucode,@amount,@dsc,@tax_rate,@result0 = @tax_charge0 output,@result = @tax output
				select @dsc = @amount - @dsc
				end
			else if  @opmode = 'U'
				select @srv = 0 , @tax = 0, @opmodesta = @dish_sta, @special = 'U'
			else if  @opmode = 'E'
				select @special = 'E'

			if  @opmode = '0' and  @special = 'E'
				select @special = 'N', @opmodesta = '0'

			if  @opmode = '0' and  @special = 'U'
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

			if  @special = 'E'
				select @opmodesta = '0'

			if @hx='T'
				update sp_dish set number=@newamount, amount=@setamount where menu = @menu and inumber = @old_id
			else
				update sp_dish set sta=@opmodesta,remark=@reason,dsc =  @dsc,srv = @srv, tax = @tax, reason=@reason,special = @special
					where menu = @menu and inumber = @old_id

--			update sp_menu set amount = (select sum(amount - dsc + srv + tax) from sp_dish where menu = @menu and charindex(sta, '03579') > 0)
--			 where menu = @menu
			update sp_menu set amount = (select sum(amount) - sum(dsc) + sum(srv) + sum(tax) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
				amount0 = (select sum(amount) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
				dsc = (select sum(dsc) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
				srv = (select sum(srv) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0),
				tax = (select sum(tax) from sp_dish where menu = @menu and charindex(sta,'03579')>0 and charindex(rtrim(code),'YZ') =0)
				where menu = @menu


			select @charge = amount,@timestamp_new = timestamp from sp_menu where menu = @menu
			select @ret = 0,@msg = "成功"
			end
		 end
   end



gout:
if @ret <> 0
	rollback tran p_hry_pos_adjust_dish_s1
commit tran

return 0;
