create proc p_fhb_pos_tcmxft
	@menu	char(10)
as
declare	@id_master int,
		@max_inumber int,
			@sum_amount	money,
			@sum_amount_t	money,
			@dif_amount	money,
			@tc_price	money,
			@tc_amount	money
-- 处理套菜明细对套菜总价格、总金额的分摊FHB Modified At 20080609
--注意，价格还是要取之pos_price  原始价格 ，对于时价菜【不定价的菜】不还原，这里有点问题
update pos_dish set price = a.price from pos_price a where a.price <> 0 and a.id = pos_dish.id and a.inumber = pos_dish.pinumber and pos_dish.menu = @menu and pos_dish.id_master <> 0 and pos_dish.special <> 'C' and charindex(pos_dish.sta,'12') <= 0

declare priceft_cur cursor for select a.id_master,isnull(sum(a.number*a.price),0) from pos_dish a,pos_dish b where a.id_master = b.inumber and b.menu = @menu and a.menu = b.menu and a.special <> 'C' and charindex(a.sta,'12') <= 0 group by a.id_master
open priceft_cur 
fetch priceft_cur into @id_master,@sum_amount
while @@sqlstatus = 0
begin
	select @tc_price = isnull(price,0),@tc_amount = isnull(amount,0) from pos_dish where menu = @menu and inumber = @id_master
	update pos_dish set amount = round(number*price*@tc_amount/@sum_amount,2) where id_master = @id_master and menu = @menu and @sum_amount > 0 and special <> 'C' and charindex(sta,'12') <= 0
	update pos_dish set price = round(amount/number,2) where number <> 0 and id_master = @id_master and menu = @menu and @sum_amount > 0 and special <> 'C' and charindex(sta,'12') <= 0
	--检查分摊后的明细菜总金额是否与套菜金额一致，不一致则调整
	select @sum_amount_t = isnull(sum(number*price),0) from pos_dish where menu = @menu and id_master = @id_master
	select @dif_amount = @sum_amount_t - @tc_amount 
	if @dif_amount <> 0
	begin
		select @max_inumber = max(inumber) from pos_dish where  menu = @menu and id_master = @id_master
		update pos_dish set amount = amount - @dif_amount where menu = @menu and id_master = @id_master and inumber = @max_inumber
	end
	fetch priceft_cur into @id_master,@sum_amount
end
close priceft_cur
deallocate cursor priceft_cur;