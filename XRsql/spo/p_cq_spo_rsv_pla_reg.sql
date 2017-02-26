
/*==============================================================================*/
//	康乐系统预定转登记：按场地登记, 可多场登记
/*==============================================================================*/

if exists(select * from sysobjects where name = "p_cq_spo_rsv_pla_reg")
	drop proc p_cq_spo_rsv_pla_reg
;

create proc p_cq_spo_rsv_pla_reg
	@resno		char(10),
	@place		char(10),		/*场地号*/			
	@inumber		int,				/*序号 */			
	@empno		char(10),
	@shift		char(1),
	@pc_id		char(4)			/*站点号*/
as
declare
	@menu				char(10),
	@pccode			char(3),
	@serve_rate		money,
	@tax_rate		money,
	@tea_charge		money,
	@ret				int,
	@bdate			datetime,
	@amount			money

select @bdate = bdate from sysdata
select @amount = isnull(price,0) from pos_plu where id = (select convert(integer,plucode) from sp_place where placecode = @place)
select @pccode = b.pccode from sp_place a, sp_place_sort b  where a.placecode = @place and a.sort = b.sort
begin tran
save  tran p_hry_pos_reserve_menu_s1
if exists(select 1 from sp_reserve where resno = @resno and menu <> '' and menu is not null)
	select @menu = menu from sp_reserve where resno = @resno and menu <> '' and menu is not null
else
	exec @ret = p_GetAccnt1 'POS', @menu output
if @shift = "1"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_charge = tea_charge1 from pos_pccode where pccode = @pccode
else if @shift = "2"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_charge = tea_charge2 from pos_pccode where pccode = @pccode
else if @shift = "3"
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_charge = tea_charge3 from pos_pccode where pccode = @pccode
else
	select @serve_rate = serve_rate, @tax_rate = tax_rate, @tea_charge = tea_charge4 from pos_pccode where pccode = @pccode

update sp_plaav set menu = @menu,menu1 = @menu, sta = 'I' from sp_plaav where menu = @resno and inumber = @inumber
update sp_reserve set menu = @menu where resno = @resno
--如果所有场地都已经登记，则主单状态也变为登记
if not exists(select 1 from sp_plaav where menu = @resno and sta = 'R')
	update sp_reserve set sta = '7' where resno = @resno 
commit tran 
return 0
;
