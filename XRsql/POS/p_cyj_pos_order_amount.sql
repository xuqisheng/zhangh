/*---------------------------------------------------------------------------------------------*/
//
// 计算order的amount，考虑服务费、折扣
//
/*---------------------------------------------------------------------------------------------*/

if exists(select * from sysobjects where name = "p_cyj_pos_order_amount")
	drop proc p_cyj_pos_order_amount
;

create proc p_cyj_pos_order_amount
	@menu			char(10),
	@pc_id		char(4)
as
declare
	@code			char(12),  -- plucode+sort+code
	@number		money,
	@price		money,
	@id			integer,

	@ret			integer,
	@msg			char(60),
	@deptno		char(2)	,		/*部门代码*/
	@pccode		char(3)	,		/*营业点码*/
	@mode			char(3),			/*	模式代码*/
	@tea_charge	money	,
	@amount		money	,
	@amount0		money	,			/*菜单价格*/

	@dsc_rate	money,			/*主单优惠比例*/
	@serve_rate		money,		/*主单服务费率*/
	@tax_rate		money,		/*主单附加费率*/


	@serve_charge0	money,		/*服务费*/
	@tax_charge0	money,		/*附加费*/
	@serve_charge	money,		/*服务费,可能打折*/
	@tax_charge		money,		/*附加费,可能打折*/

	@sta        char(1), 
	@dsc			money,
	@inumber		int


select @deptno = deptno,@pccode = pccode,@serve_rate = serve_rate,@tax_rate = tax_rate,@dsc_rate = dsc_rate, @mode = mode
  from pos_menu where menu = @menu


declare c_order cursor for
 select inumber,sta, id,  number,amount from pos_order  where menu = @menu  and pc_id = @pc_id
open c_order
fetch c_order into @inumber,@sta,@id, @number,@amount0
while @@sqlstatus = 0
	begin
	select @code =  plucode+sort+code from pos_plu_all where id = @id
	select @serve_charge0 = 0,@serve_charge = 0,@tax_charge0 = 0,@tax_charge = 0
	
	
	exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@code,@amount0,@dsc_rate,@result = @amount output

	exec p_gl_pos_create_serve		@deptno,@pccode,@mode,@code,@amount0,@amount,@serve_rate,@result0 = @serve_charge0 output,@result = @serve_charge output
	exec p_gl_pos_create_tax		@deptno,@pccode,@mode,@code,@amount0,@amount,@tax_rate,@result0 = @tax_charge0 output,@result = @tax_charge output
	
	update pos_order set srv = @serve_charge,dsc = amount - @amount, tax = @tax_charge
		where menu = @menu and pc_id = @pc_id and inumber = @inumber

	fetch c_order into @inumber,@sta,@id, @number,@amount0
	end
close c_order
deallocate cursor c_order
;
