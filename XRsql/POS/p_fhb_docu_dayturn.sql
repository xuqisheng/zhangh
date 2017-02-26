drop proc p_fhb_docu_dayturn;
create proc p_fhb_docu_dayturn
	@pc_id	char(4),
	@vdate	datetime,
	@ret	int out,
	@msg	varchar(70) out
as
--日结过程：放在夜审里面==>1.生成当天销售单01；
--2.检查借贷金额差异，生成差价单，更新库存02；
--3.生成结转单，每天的结转单，就是前一天的库存量03
--@ret: -1 失败；1 成功

select @ret = 1,@msg = '吧台进销存结转成功！'

declare	@stcode	char(3),
		@code		char(12),
		@dsnumber	money,
		@dsamount	money,
		@csnumber	money,
		@csamount	money,
		@dcsamount	money,		--借贷金额差值
		@number	money,
		@price	money,
		@amount	money,
		@snumber	money,		--库存数量
		@price_bit	int,		--单价精确度小数位
		@number_bit	int,
		@amount_bit	int,
		@artcode	char(12)
declare	@count	int,
		@index	int

select @price_bit = convert(integer,isnull(value,'2')) from sysoption where catalog = 'pos' and item = 'price_bit'
select @number_bit = convert(integer,isnull(value,'3')) from sysoption where catalog = 'pos' and item = 'num_bit'
select @amount_bit = convert(integer,isnull(value,'2')) from sysoption where catalog = 'pos' and item = 'amount_bit'

--出错记录
delete from herror_msg where pc_id =  @pc_id and modu_id = '04'
--1.生成当天的销售单
--a.检测账面库存数量
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
		select @ret = -1,@msg = '['+@stcode+']库,物品['+@artcode+']库存不足,无法产生销售单,结转失败'
		close sale_cur
		deallocate cursor sale_cur
		update pos_store_checkout set descript = descript + @artcode + '库存不足', flag = '2' where pc_id = @pc_id and code = '01'  --失败
		insert herror_msg select @pc_id,'04',0,@msg
		return 0
	end
	fetch sale_cur into @stcode,@artcode,@number
end
close sale_cur
deallocate cursor sale_cur

--b.生成销售单
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
		select @pc_id,-102,'L',@stcode,'','','',@vdate,'02',0,'','','系统生成销售单','','FHB',getdate(),0,'','','','',''
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
		update pos_store_checkout set flag = '2' where pc_id = @pc_id and code = '01'  --失败
		insert herror_msg select @pc_id,'04',0,@msg
		return 0
	end
	else
		select @ret = 1
	fetch saledoc_cur into @stcode
end
close saledoc_cur
deallocate cursor saledoc_cur

update pos_store_checkout set flag = '1' where pc_id = @pc_id and code = '01'   --成功
--2.核算当天的借贷数量、金额是否相平，金额不平，则生成差价单,调整库存金额
delete from pos_st_jiedaice where pc_id = @pc_id
declare bars_cur cursor for select istcode,code from pos_store_stock
open bars_cur
fetch bars_cur into @stcode,@code
while @@sqlstatus=0
begin
	--借：上期结转数+本期入库数   贷：结转到下期数+本期出库数
	select @dsnumber = isnull(sum(number),0),@dsamount = isnull(sum(amount),0) from pos_st_documst a,pos_st_docudtl b 
		where a.id = b.id and charindex(a.vtype,'00#01#03#04') > 0 and a.istcode = @stcode and vdate = @vdate and b.code = @code
	select @csnumber = isnull(sum(number),0),@csamount = isnull(sum(amount),0) from pos_st_documst a,pos_st_docudtl b
		where a.id = b.id and charindex(a.vtype,'02#03') > 0 and a.ostcode = @stcode and vdate = @vdate and b.code = @code
 	select @csnumber = @csnumber + a.number,@csamount  = @csamount + a.amount from pos_store_stock a 
		where a.istcode = @stcode and a.code = @code
	--借贷数量不平，业务单据有问题，结转不成功，返回；借贷数量平，但借贷金额不平，则生成差价单，继续结转
	if @dsnumber <> @csnumber 
	begin
		select @ret = -1,@msg = '本日发生单据借贷数量不平！'
		insert herror_msg select @pc_id,'04',0,@msg
		return 0
	end
	select @dcsamount = @dsamount - @csamount
	if @dcsamount <> 0				--金额不平，生成差价单，调整库存金额，差价单vtype='05',该单自动生成，不允许手动修改
		insert pos_st_jiedaice select @pc_id,@stcode,@code,@dcsamount
	fetch bars_cur into @stcode,@code
end
close bars_cur
deallocate cursor bars_cur
select @count = count(1) from pos_st_jiedaice where pc_id = @pc_id

--生成差价单
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
   			select @pc_id,-105,'','','',@stcode,'',@vdate,'05',0,'','','借贷差额','','FHB',getdate(),0,'','','','','' 
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
		exec p_fhb_docu_save @pc_id	 = @pc_id,@id = -105,@mode = 'A',@type = '05',@ret = @ret out,@msg = @msg out     --@ret 成功返回id的相反数，失败返回正数
		if @ret >= 0
		begin
			select @ret = -1,@msg = '生成差价单保存失败==>吧台进销存结转失败！'
			rollback tran dayturn_s
			close stcode_cur
			deallocate cursor stcode_cur
			update pos_store_checkout set flag = '2' where pc_id = @pc_id and code = '02'   --失败
			insert herror_msg select @pc_id,'04',0,@msg
			return 0	
		end
		else
		begin
			--更新差价单的数量，单价
			update pos_st_docudtl set number = a.number from pos_store_stock a,pos_st_documst b 
				where b.id = pos_st_docudtl.id and b.id = -@ret and a.istcode = b.istcode and pos_st_docudtl.code = a.code
			update pos_st_docudtl set price = round(amount/number,@price_bit) where id = -@ret and number <> 0     --此处price小数位没有通过参数统一控制
			select @ret = 1
		end

		fetch stcode_cur into @stcode
	end
	close stcode_cur
	deallocate cursor stcode_cur
end

update pos_store_checkout set flag = '1' where pc_id = @pc_id and code = '02'   --成功
--3.生成结转单'00'
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
   		select @pc_id,-100,'','','',@stcode,'',dateadd(dd,1,@vdate),'00',0,'','','结转单','','FHB',getdate(),0,'','','','','' 
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
	exec p_fhb_docu_save @pc_id	 = @pc_id,@id = -100,@mode = 'A',@type = '00',@ret = @ret out,@msg = @msg out     --@ret 成功返回id的相反数，失败返回正数
	if @ret >= 0
	begin
		select @ret = -1,@msg = '生成结转单保存失败==>吧台进销存结转失败！'
		rollback tran dayturn_s
		close jz_cur
		deallocate cursor jz_cur
		update pos_store_checkout set flag = '2' where pc_id = @pc_id and code = '03'   --失败
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

update pos_store_checkout set flag = '1' where pc_id = @pc_id and code = '03'   --成功
if @ret = 1
begin
	select @msg = '吧台进销存结转成功！'
	update pos_st_sysdata set truedate = dateadd(dd,1,@vdate)     --结转成功更改当天日期
	update pos_store_checkout set flag = '1' where pc_id = @pc_id and code = '04'   --成功
end
else
	select @msg = '吧台进销存结转失败！'

select @ret,@msg
return 0;