drop proc p_fhb_docu_dayturn;
create proc p_fhb_docu_dayturn
	@pc_id	char(4),
	@vdate	datetime,
	@ret	int out,
	@msg	varchar(70) out
as
--�ս���̣�����ҹ������==>1.���ɵ������۵�01��
--2.����������죬���ɲ�۵������¿��02��
--3.���ɽ�ת����ÿ��Ľ�ת��������ǰһ��Ŀ����03
--@ret: -1 ʧ�ܣ�1 �ɹ�

select @ret = 1,@msg = '��̨�������ת�ɹ���'

declare	@stcode	char(3),
		@code		char(12),
		@dsnumber	money,
		@dsamount	money,
		@csnumber	money,
		@csamount	money,
		@dcsamount	money,		--�������ֵ
		@number	money,
		@price	money,
		@amount	money,
		@snumber	money,		--�������
		@price_bit	int,		--���۾�ȷ��С��λ
		@number_bit	int,
		@amount_bit	int,
		@artcode	char(12)
declare	@count	int,
		@index	int

select @price_bit = convert(integer,isnull(value,'2')) from sysoption where catalog = 'pos' and item = 'price_bit'
select @number_bit = convert(integer,isnull(value,'3')) from sysoption where catalog = 'pos' and item = 'num_bit'
select @amount_bit = convert(integer,isnull(value,'2')) from sysoption where catalog = 'pos' and item = 'amount_bit'

--�����¼
delete from herror_msg where pc_id =  @pc_id and modu_id = '04'
--1.���ɵ�������۵�
--a.�������������
declare sale_cur cursor for select storecode,artcode,isnull(sum(number),0) from pos_hsale where bdate = @vdate group by storecode,artcode
open sale_cur
fetch sale_cur into @stcode,@artcode,@number
while @@sqlstatus=0
begin
	select @snumber = 0
	if @stcode = '' 
		continue
	select @snumber = isnull(number,0) from pos_store_stock where istcode = @stcode and code = @artcode
	if @snumber - @number < 0
     begin 
		select @ret = -1,@msg = '['+@stcode+']��,��Ʒ['+@artcode+']��治��,�޷��������۵�,��תʧ��'
		close sale_cur
		deallocate cursor sale_cur
		update pos_store_checkout set descript = descript + @artcode + '��治��', flag = '2' where pc_id = @pc_id and code = '01'  --ʧ��
		insert herror_msg select @pc_id,'04',0,@msg
		return 0
	end
	fetch sale_cur into @stcode,@artcode,@number
end
close sale_cur
deallocate cursor sale_cur

--b.�������۵�
begin tran 
save tran dayturn_s
select @stcode = ''
select @number = 0
select @price = 0
delete from pos_consume_temp where pc_id = @pc_id
insert pos_consume_temp select @pc_id,storecode,artcode,isnull(sum(number),0) from pos_hsale where bdate = @vdate group by storecode,artcode
delete from pos_consume_temp where pc_id = @pc_id and stcode = ''
declare saledoc_cur cursor for select distinct stcode from pos_consume_temp where pc_id = @pc_id
open saledoc_cur
fetch saledoc_cur into @stcode
while @@sqlstatus=0
begin
	delete from st_docu_mst_pcid where pc_id = @pc_id
	delete from st_docu_dtl_pcid where pc_id = @pc_id
	insert st_docu_mst_pcid(pc_id,id,lockmark,ostcode,ostname,istcode,istname,vdate,vtype,vno,spcode,invoice,ref,vmark,empno,log_date,logmark,empno0,empno1,costitem,paymth,tag)
		select @pc_id,-102,'L',@stcode,'','','',@vdate,'02',0,'','','ϵͳ�������۵�','','FHB',getdate(),0,'','','','',''
	select @index = 1
	declare salemx_cur cursor for select artcode,number from pos_consume_temp where stcode = @stcode and pc_id = @pc_id
	open salemx_cur
	fetch salemx_cur into @artcode,@number
	while @@sqlstatus = 0 
	begin
		select @price = isnull(price,0) from pos_store_stock where istcode = @stcode and code = @artcode
		insert st_docu_dtl_pcid(pc_id,id,subid,code,name,unit,standent,number,amount,price,validdate,tax,deliver,rebate,csaccnt,prid,tag)
			select @pc_id,-102,@index,@artcode,'','','',@number,round(@number*@price,@amount_bit),@price,getdate(),0,0,0,'',0,''
		select @index = @index + 1
		fetch salemx_cur into @artcode,@number
	end
	close salemx_cur
	deallocate cursor salemx_cur
	exec p_fhb_docu_save @pc_id	 = @pc_id,@id = -102,@mode = 'A',@type = '02',@ret = @ret out,@msg = @msg out 
	if @ret >= 0
	begin
		select @ret = -1,@msg = @msg
		rollback tran dayturn_s
		close saledoc_cur
		deallocate cursor saledoc_cur
		update pos_store_checkout set flag = '2' where pc_id = @pc_id and code = '01'  --ʧ��
		insert herror_msg select @pc_id,'04',0,@msg
		return 0
	end
	else
		select @ret = 1
	fetch saledoc_cur into @stcode
end
close saledoc_cur
deallocate cursor saledoc_cur

update pos_store_checkout set flag = '1' where pc_id = @pc_id and code = '01'   --�ɹ�
--2.���㵱��Ľ������������Ƿ���ƽ����ƽ�������ɲ�۵�,���������
delete from pos_st_jiedaice where pc_id = @pc_id
declare bars_cur cursor for select istcode,code from pos_store_stock
open bars_cur
fetch bars_cur into @stcode,@code
while @@sqlstatus=0
begin
	--�裺���ڽ�ת��+���������   ������ת��������+���ڳ�����
	select @dsnumber = isnull(sum(number),0),@dsamount = isnull(sum(amount),0) from pos_st_documst a,pos_st_docudtl b 
		where a.id = b.id and charindex(a.vtype,'00#01#03#04') > 0 and a.istcode = @stcode and vdate = @vdate and b.code = @code
	select @csnumber = isnull(sum(number),0),@csamount = isnull(sum(amount),0) from pos_st_documst a,pos_st_docudtl b
		where a.id = b.id and charindex(a.vtype,'02#03') > 0 and a.ostcode = @stcode and vdate = @vdate and b.code = @code
 	select @csnumber = @csnumber + a.number,@csamount  = @csamount + a.amount from pos_store_stock a 
		where a.istcode = @stcode and a.code = @code
	--���������ƽ��ҵ�񵥾������⣬��ת���ɹ������أ��������ƽ���������ƽ�������ɲ�۵���������ת
	if @dsnumber <> @csnumber 
	begin
		select @ret = -1,@msg = '���շ������ݽ��������ƽ��'
		insert herror_msg select @pc_id,'04',0,@msg
		return 0
	end
	select @dcsamount = @dsamount - @csamount
	if @dcsamount <> 0				--��ƽ�����ɲ�۵�������������۵�vtype='05',�õ��Զ����ɣ��������ֶ��޸�
		insert pos_st_jiedaice select @pc_id,@stcode,@code,@dcsamount
	fetch bars_cur into @stcode,@code
end
close bars_cur
deallocate cursor bars_cur
select @count = count(1) from pos_st_jiedaice where pc_id = @pc_id

--���ɲ�۵�
if @count > 0 
begin
	declare stcode_cur cursor for select distinct stcode from pos_st_jiedaice where pc_id = @pc_id
	open stcode_cur
	fetch stcode_cur into @stcode
	while @@sqlstatus = 0 
	begin
		delete from st_docu_mst_pcid where pc_id = @pc_id
		delete from st_docu_dtl_pcid where pc_id = @pc_id
		insert st_docu_mst_pcid(pc_id,id,lockmark,ostcode,ostname,istcode,istname,vdate,vtype,vno,spcode,invoice,ref,vmark,empno,log_date,logmark,empno0,empno1,costitem,paymth,tag)
   			select @pc_id,-105,'','','',@stcode,'',@vdate,'05',0,'','','������','','FHB',getdate(),0,'','','','','' 
		select @index = 1
		declare code_cur cursor for select code,amount from pos_st_jiedaice where pc_id = @pc_id and stcode = @stcode
		open code_cur
		fetch code_cur into @code,@amount
		while @@sqlstatus = 0 
		begin
			insert st_docu_dtl_pcid(pc_id,id,subid,code,name,unit,standent,number,amount,price,validdate,tax,deliver,rebate,csaccnt,prid,tag)
				select @pc_id,-105,@index,@code,'','','',0,@amount,0,getdate(),0,0,0,'',0,''
			select @index = @index + 1
			fetch code_cur into @code,@amount
		end
		close code_cur
		deallocate cursor code_cur
		exec p_fhb_docu_save @pc_id	 = @pc_id,@id = -105,@mode = 'A',@type = '05',@ret = @ret out,@msg = @msg out     --@ret �ɹ�����id���෴����ʧ�ܷ�������
		if @ret >= 0
		begin
			select @ret = -1,@msg = '���ɲ�۵�����ʧ��==>��̨�������תʧ�ܣ�'
			rollback tran dayturn_s
			close stcode_cur
			deallocate cursor stcode_cur
			update pos_store_checkout set flag = '2' where pc_id = @pc_id and code = '02'   --ʧ��
			insert herror_msg select @pc_id,'04',0,@msg
			return 0	
		end
		else
		begin
			--���²�۵�������������
			update pos_st_docudtl set number = a.number from pos_store_stock a,pos_st_documst b 
				where b.id = pos_st_docudtl.id and b.id = -@ret and a.istcode = b.istcode and pos_st_docudtl.code = a.code
			update pos_st_docudtl set price = round(amount/number,@price_bit) where id = -@ret and number <> 0     --�˴�priceС��λû��ͨ������ͳһ����
			select @ret = 1
		end

		fetch stcode_cur into @stcode
	end
	close stcode_cur
	deallocate cursor stcode_cur
end

update pos_store_checkout set flag = '1' where pc_id = @pc_id and code = '02'   --�ɹ�
--3.���ɽ�ת��'00'
delete from pos_store_stock_temp 
insert pos_store_stock_temp select * from pos_store_stock 
declare jz_cur cursor for select distinct istcode from pos_store_stock_temp 
open jz_cur	
fetch jz_cur into @stcode
while @@sqlstatus = 0
begin
	delete from st_docu_mst_pcid where pc_id = @pc_id
	delete from st_docu_dtl_pcid where pc_id = @pc_id
	insert st_docu_mst_pcid(pc_id,id,lockmark,ostcode,ostname,istcode,istname,vdate,vtype,vno,spcode,invoice,ref,vmark,empno,log_date,logmark,empno0,empno1,costitem,paymth,tag)
   		select @pc_id,-100,'','','',@stcode,'',dateadd(dd,1,@vdate),'00',0,'','','��ת��','','FHB',getdate(),0,'','','','','' 
	select @index = 1
	declare jzmx_cur cursor for select code,number,price,amount from pos_store_stock_temp where istcode = @stcode
	open jzmx_cur
	fetch jzmx_cur into @code,@number,@price,@amount
	while @@sqlstatus = 0 
	begin
		insert st_docu_dtl_pcid(pc_id,id,subid,code,name,unit,standent,number,amount,price,validdate,tax,deliver,rebate,csaccnt,prid,tag)
			select @pc_id,-100,@index,@code,'','','',@number,@amount,@price,getdate(),0,0,0,'',0,''
		select @index = @index + 1
		fetch jzmx_cur into @code,@number,@price,@amount
	end
	close jzmx_cur
	deallocate cursor jzmx_cur
	exec p_fhb_docu_save @pc_id	 = @pc_id,@id = -100,@mode = 'A',@type = '00',@ret = @ret out,@msg = @msg out     --@ret �ɹ�����id���෴����ʧ�ܷ�������
	if @ret >= 0
	begin
		select @ret = -1,@msg = '���ɽ�ת������ʧ��==>��̨�������תʧ�ܣ�'
		rollback tran dayturn_s
		close jz_cur
		deallocate cursor jz_cur
		update pos_store_checkout set flag = '2' where pc_id = @pc_id and code = '03'   --ʧ��
		insert herror_msg select @pc_id,'04',0,@msg
		return 0
		
	end
	else
	begin
		select @ret = 1
	end
	fetch jz_cur into @stcode
end
close jz_cur
deallocate cursor jz_cur

commit tran 

update pos_store_checkout set flag = '1' where pc_id = @pc_id and code = '03'   --�ɹ�
if @ret = 1
begin
	select @msg = '��̨�������ת�ɹ���'
	update pos_st_sysdata set truedate = dateadd(dd,1,@vdate)     --��ת�ɹ����ĵ�������
	update pos_store_checkout set flag = '1' where pc_id = @pc_id and code = '04'   --�ɹ�
end
else
	select @msg = '��̨�������תʧ�ܣ�'

select @ret,@msg
return 0;