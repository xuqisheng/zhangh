create proc p_fhb_docu_jd
	@id	int,
	@subid	int,
	@stcode	char(3),
	@code	char(12),
	@flag	char(1),
	@ret		int out,
	@msg		varchar(60) out
as
--ע���˴�@ret ��ID�޹� -1 ʧ�� 1�ɹ�
--@price	С��λͳһ�ɲ�������
--@flag  �����־��D==>�跽��C==>����   ���¿��
declare	@number	money,
		@price	money,
		@amount	money,
		@count	int,
		@price_bit	int		--���۾�ȷ��С��λ
select @ret = 1,@msg = ''

select @price_bit = convert(integer,isnull(value,'2')) from sysoption where catalog = 'pos' and item = 'price_bit'

if @flag = 'D'		--�跽�������[��ⵥ�븺��Ҳ���ǽ跽 ����]
begin
	select @number = number,@price = price,@amount = amount from pos_st_docudtl where id = @id and subid = @subid
	select @count = count(1) from pos_store_stock where istcode = @stcode and code = @code 
	--�Ƿ��п���¼��������£���������
	if @count <= 0 
		insert pos_store_stock select @stcode,@code,@price,@number,@amount
	else
	begin
		update pos_store_stock set number = number + @number,amount = amount + @amount where istcode = @stcode and code = @code
		update pos_store_stock set price = round(amount/number,@price_bit) where number <> 0 and istcode = @stcode and code = @code
	end
	
end
else				--����������
begin
	select @number = number,@price = price,@amount = amount from pos_st_docudtl where id = @id and subid = @subid
	select @count = count(1) from pos_store_stock where istcode = @stcode and code = @code 
	--�Ƿ��п���¼��������£���������
	if @count <= 0 
		insert pos_store_stock select @stcode,@code,@price,-@number,-@amount
	else
	begin
		update pos_store_stock set number = number - @number,amount = amount - @amount where istcode = @stcode and code = @code
		--�����Ϊ�㣬��Ϊ�㣬�򵥾ݽ�����
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
--�ٴμ������Ƿ��㹻
select @number = number from pos_store_stock where istcode = @stcode and code = @code 
if @number < 0 
begin
	select @ret = -1,@msg = @stcode+'�⣬����Ϊ'+@code+'����Ʒȱ��'+convert(char,-@number)
end;