create proc p_fhb_docu_jd
	@id	int,
	@subid	int,
	@stcode	char(3),
	@code	char(12),
	@flag	char(1),
	@ret		int out,
	@msg		varchar(60) out
as
--注：此处@ret 与ID无关 -1 失败 1成功
--@price	小数位统一由参数控制
--@flag  借贷标志：D==>借方；C==>贷方   更新库存
declare	@number	money,
		@price	money,
		@amount	money,
		@count	int,
		@price_bit	int		--单价精确度小数位
select @ret = 1,@msg = ''

select @price_bit = convert(integer,isnull(value,'2')) from sysoption where catalog = 'pos' and item = 'price_bit'

if @flag = 'D'		--借方库存增加[入库单入负数也算是借方 例外]
begin
	select @number = number,@price = price,@amount = amount from pos_st_docudtl where id = @id and subid = @subid
	select @count = count(1) from pos_store_stock where istcode = @stcode and code = @code 
	--是否有库存纪录，有则更新，无则新增
	if @count <= 0 
		insert pos_store_stock select @stcode,@code,@price,@number,@amount
	else
	begin
		update pos_store_stock set number = number + @number,amount = amount + @amount where istcode = @stcode and code = @code
		update pos_store_stock set price = round(amount/number,@price_bit) where number <> 0 and istcode = @stcode and code = @code
	end
	
end
else				--贷方库存减少
begin
	select @number = number,@price = price,@amount = amount from pos_st_docudtl where id = @id and subid = @subid
	select @count = count(1) from pos_store_stock where istcode = @stcode and code = @code 
	--是否有库存纪录，有则更新，无则新增
	if @count <= 0 
		insert pos_store_stock select @stcode,@code,@price,-@number,-@amount
	else
	begin
		update pos_store_stock set number = number - @number,amount = amount - @amount where istcode = @stcode and code = @code
		--若库存为零，金额不为零，则单据金额更新
		select @number = number,@amount = amount from pos_store_stock where istcode = @stcode and code = @code
		if @number = 0 and @amount <> 0
		begin
			update pos_st_docudtl set amount = amount + @amount where id = @id and subid = @subid
			update pos_st_docudtl set price = round(amount/number,@price_bit) where number <> 0 and id = @id and subid = @subid
			update pos_store_stock set amount = 0 where istcode = @stcode and code = @code
		end
		--update pos_store_stock set price = round(amount/number,@price_bit) where number <> 0 and istcode = @stcode and code = @code
	end
end
--再次检验库存是否足够
select @number = number from pos_store_stock where istcode = @stcode and code = @code 
if @number < 0 
begin
	select @ret = -1,@msg = @stcode+'库，编码为'+@code+'的物品缺货'+convert(char,-@number)
end;