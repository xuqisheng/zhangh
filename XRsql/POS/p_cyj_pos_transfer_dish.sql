/*-----------------------------------------------------------------------------*/
//
//  餐单间转菜
//
/*-----------------------------------------------------------------------------*/


if object_id('p_cyj_pos_transfer_dish') is not null
	drop proc p_cyj_pos_transfer_dish
;
create proc p_cyj_pos_transfer_dish
	@pc_id			char(4),
	@smenu			char(10),        -- 原单号
	@omenu			char(10),        -- 目的单号
	@sinumber		int,				  -- 原序号
	@empno			char(10)
as
declare
	@inumber		integer,
	@inumber1	integer,
	@inumber2	integer,
	@ret			integer,
	@sta			char(1),
	@msg			char(60), 
	@add_remark char(40),
	@flag			char(1)             -- 是否套菜

select @ret = 0, @msg =''

begin tran
save  tran p_hry_pos_input_dish_s1
select @inumber = lastnum, @sta = sta from pos_menu where menu = @omenu

if @@rowcount = 0
	select @ret = 1,@msg = "菜单“" + @omenu + "”已不存在或已销单"
else if @sta ='3'
	select @ret = 1,@msg = "菜单“" + @omenu + "”已被其他收银员结帐"
else if @sta ='7'
	select @ret = 1,@msg = "菜单“" + @omenu + "”已被删除"

select @sta = sta from pos_menu where menu = @smenu
if @@rowcount = 0
	select @ret = 1,@msg = "菜单“" + @smenu + "”已不存在或已销单"
else if @sta ='3'
	select @ret = 1,@msg = "菜单“" + @smenu + "”已被其他收银员结帐"
else if @sta ='7'
	select @ret = 1,@msg = "菜单“" + @smenu + "”已被删除"

select @sta = sta from pos_dish where menu = @smenu and inumber = @sinumber
if charindex(@sta, '12') > 0 
	select @ret = 1, @msg = '该菜已经被冲销'
if @sta =  'M'
	select @ret = 1, @msg = '该菜是套菜的明细菜，不能转'

if @ret = 0 
	begin
	select @inumber = lastnum + 1 from pos_menu where menu = @omenu
	insert pos_dish(menu,inumber,plucode,sort,code,id,printid,name1,name2,unit,number,amount,empno,bdate,remark,special,id_cancel,id_master,reason,empno1,price,pinumber,pamount,date1,sta,flag)
		select @omenu,@inumber,plucode,sort,code,id,printid,name1,name2,unit,number,amount,empno,bdate,rtrim(@empno)+'-转菜<- '+@smenu,special,id_cancel,id_master,reason,@empno,price,pinumber,pamount,getdate(),sta,flag
	from pos_dish where menu = @smenu and inumber = @sinumber

	select @inumber2 = @inumber
	select @flag = substring(flag, 1, 1) from pos_dish where menu = @smenu and inumber = @sinumber
	if @flag ='T'  -- 套菜处理 
		begin
		declare c_cur cursor for select inumber from pos_dish where menu = @smenu and id_master = @sinumber and sta ='M' 
		open c_cur
		fetch c_cur into @inumber1
		while @@sqlstatus = 0 
			begin
			select @inumber2 = @inumber2 + 1
			insert pos_dish(menu,inumber,plucode,sort,code,id,printid,name1,name2,unit,number,amount,empno,bdate,remark,special,id_cancel,id_master,reason,empno1,price,pinumber,pamount,date1,sta,flag)
				select @omenu,@inumber2,plucode,sort,code,id,printid,name1,name2,unit,number,amount,empno,bdate,rtrim(@empno)+'-转菜<- '+@smenu,special,id_cancel,@inumber,reason,@empno,price,pinumber,pamount,getdate(),sta,flag
			from pos_dish where menu = @smenu and inumber = @inumber1
			fetch c_cur into @inumber1
			end
		close c_cur
		deallocate cursor c_cur
		end
		
	update pos_menu set lastnum = @inumber2   where menu = @omenu
	
	exec  p_cyj_pos_update_menu  @pc_id,@omenu
	select @add_remark = rtrim(@empno)+'-转菜-> '+@omenu
	exec p_cyj_pos_cancel_dish @smenu, @empno, @sinumber, @pc_id, @add_remark, 0, 'S'
	exec  p_cyj_pos_update_menu  @pc_id,@smenu

	end
if @ret <> 0 
	rollback tran p_hry_pos_input_dish_s1
commit tran
select @ret, @msg
;

