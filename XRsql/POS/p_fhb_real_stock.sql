create proc p_fhb_real_stock
	@stcode	char(3),
	@artcode	char(12)

as

begin
	declare	@nstcode	char(3),
				@nartcode	char(12),
				@nnumber	money,
				@nprice	money,
				@price_bit	int
select @price_bit = isnull(convert(int,value),3) from sysoption where catalog = 'pos' and item = 'price_bit'

	if @stcode is null 
		select @stcode = ''
   if	@artcode is null
		select @artcode = ''
	create table #stock_temp
	(
		stcode	char(3) null,
		stname	char(20) null,
		artcode	char(12) null,
		artname	char(40) null,
		unit	char(6) null,
		number	money null,
		price		money null,
		amount	money null
	)

	create table #stock_temp1
	(
		stcode	char(3) null,
		artcode	char(12) null,
		number	money,
		price		money null,
		amount	money null
	)


	if @stcode = '' and @artcode = ''
	begin
		insert #stock_temp select istcode,'',code,'','',number,price,amount from pos_store_stock
		--没有库存记录的物品
		declare nostock_cur1 cursor for select storecode,artcode,isnull(sum(number),0) from pos_sale 
			where not exists (select 1 from pos_store_stock where pos_store_stock.istcode = pos_sale.storecode and pos_store_stock.code = pos_sale.artcode )
				group by storecode,artcode
		open	nostock_cur1
		fetch nostock_cur1 into @nstcode,@nartcode,@nnumber
		while @@sqlstatus = 0
		begin
			--没有库存记录的物品，销售成本取物品参考价格，若没有设参考价格，则为0
			select @nprice = isnull(price,0) from pos_st_article where code = @artcode
			insert #stock_temp select @nstcode,'',@nartcode,'','',-@nnumber,@nprice,-round(@nnumber*@nprice,2)
			fetch nostock_cur1 into @nstcode,@nartcode,@nnumber
		end
		close nostock_cur1
		deallocate cursor nostock_cur1	
		--有库存记录的物品
		insert #stock_temp1 select storecode,artcode,isnull(sum(number),0),0,0 from pos_sale 
			where exists (select 1 from pos_store_stock where pos_store_stock.istcode = pos_sale.storecode and pos_store_stock.code = pos_sale.artcode )
				group by storecode,artcode
		update #stock_temp1 set price = a.price from pos_store_stock a where a.istcode = #stock_temp1.stcode and a.code = #stock_temp1.artcode
		update #stock_temp1 set amount = price*number
		update #stock_temp set #stock_temp.number = #stock_temp.number - #stock_temp1.number,#stock_temp.amount = #stock_temp.amount - #stock_temp1.amount
			from #stock_temp1 where #stock_temp.stcode = #stock_temp1.stcode and #stock_temp.artcode = #stock_temp1.artcode
		
	end
	if @stcode = '' and @artcode <> ''
	begin
		insert #stock_temp select istcode,'',code,'','',number,price,amount 
			from pos_store_stock	where code = @artcode
		--没有库存记录的物品
		declare nostock_cur2 cursor for select storecode,artcode,isnull(sum(number),0) from pos_sale 
			where artcode = @artcode and not exists (select 1 from pos_store_stock where pos_store_stock.code = @artcode and pos_store_stock.istcode = pos_sale.storecode and pos_store_stock.code = pos_sale.artcode )
				group by storecode,artcode
		open	nostock_cur2
		fetch nostock_cur2 into @nstcode,@nartcode,@nnumber
		while @@sqlstatus = 0
		begin
			--没有库存记录的物品，销售成本取物品参考价格，若没有设参考价格，则为0
			select @nprice = isnull(price,0) from pos_st_article where code = @artcode
			insert #stock_temp select @nstcode,'',@nartcode,'','',-@nnumber,@nprice,-round(@nnumber*@nprice,2)
			fetch nostock_cur2 into @nstcode,@nartcode,@nnumber
		end
		close nostock_cur2
		deallocate cursor nostock_cur2	
		--有库存记录的物品
		insert #stock_temp1 select storecode,artcode,isnull(sum(number),0),0,0 from pos_sale 
			where artcode = @artcode and exists (select 1 from pos_store_stock where pos_store_stock.code = @artcode and pos_store_stock.istcode = pos_sale.storecode and pos_store_stock.code = pos_sale.artcode )
				group by storecode,artcode
		update #stock_temp1 set price = a.price from pos_store_stock a where a.istcode = #stock_temp1.stcode and a.code = #stock_temp1.artcode
		update #stock_temp1 set amount = price*number
		update #stock_temp set #stock_temp.number = #stock_temp.number - #stock_temp1.number,#stock_temp.amount = #stock_temp.amount - #stock_temp1.amount
			from #stock_temp1 where #stock_temp.stcode = #stock_temp1.stcode and #stock_temp.artcode = #stock_temp1.artcode
		
	end
	if @stcode <>'' and @artcode = ''
	begin
		insert #stock_temp select istcode,'',code,'','',number,price,amount 
			from pos_store_stock	where istcode = @stcode
		--没有库存记录的物品
		declare nostock_cur3 cursor for select storecode,artcode,isnull(sum(number),0) from pos_sale 
			where storecode = @stcode and not exists (select 1 from pos_store_stock where pos_store_stock.istcode = @stcode and pos_store_stock.istcode = pos_sale.storecode and pos_store_stock.code = pos_sale.artcode )
				group by storecode,artcode
		open	nostock_cur3
		fetch nostock_cur3 into @nstcode,@nartcode,@nnumber
		while @@sqlstatus = 0
		begin
			--没有库存记录的物品，销售成本取物品参考价格，若没有设参考价格，则为0
			select @nprice = isnull(price,0) from pos_st_article where code = @artcode
			insert #stock_temp select @nstcode,'',@nartcode,'','',-@nnumber,@nprice,-round(@nnumber*@nprice,2)
			fetch nostock_cur3 into @nstcode,@nartcode,@nnumber
		end
		close nostock_cur3
		deallocate cursor nostock_cur3	
		--有库存记录的物品
		insert #stock_temp1 select storecode,artcode,isnull(sum(number),0),0,0 from pos_sale 
			where storecode = @stcode and exists (select 1 from pos_store_stock where pos_store_stock.istcode = @stcode and pos_store_stock.istcode = pos_sale.storecode and pos_store_stock.code = pos_sale.artcode )
				group by storecode,artcode
		update #stock_temp1 set price = a.price from pos_store_stock a where a.istcode = #stock_temp1.stcode and a.code = #stock_temp1.artcode
		update #stock_temp1 set amount = price*number
		update #stock_temp set #stock_temp.number = #stock_temp.number - #stock_temp1.number,#stock_temp.amount = #stock_temp.amount - #stock_temp1.amount
			from #stock_temp1 where #stock_temp.stcode = #stock_temp1.stcode and #stock_temp.artcode = #stock_temp1.artcode
		
	end
	if	@stcode <>'' and @artcode <> ''
	begin
		insert #stock_temp select istcode,'',code,'','',number,price,amount 
			from pos_store_stock	where istcode = @stcode and code = @artcode
		select @nnumber=isnull(sum(number),0) from pos_sale where storecode = @stcode and artcode = @artcode
		if not exists (select 1 from pos_store_stock where istcode = @stcode and code = @artcode)
		begin
			select @nprice = isnull(price,0) from pos_st_article where code = @artcode
			insert #stock_temp select @stcode,'',@artcode,'','',-@nnumber,@nprice,-round(@nnumber*@nprice,2)
		end
		else
		begin
			update #stock_temp set number = number - @nnumber,amount = amount - price*@nnumber
		end
	end
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
	update #stock_temp set price = round(amount/number,@price_bit) where number <> 0
	update #stock_temp set stname = a.descript from pos_store a where #stock_temp.stcode = a.code
	update #stock_temp set artname = a.name,unit = a.unit from pos_st_article a where #stock_temp.artcode = a.code

	--返回结果集
	select * from #stock_temp
end;