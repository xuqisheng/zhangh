drop proc p_gds_bos_bill;
create proc p_gds_bos_bill
	@setnumb				char(10),
	@bcode				char(3),		-- bill_mode.code 
	@language			char(3),		-- 语种
	@bempno				char(10),	-- 打印工号
	@pc_id				char(4)
as
--------------------------------------------------------------------------------------------------
--	BOS 账单
--------------------------------------------------------------------------------------------------

-----------------------
-- 账单头尾项目
-----------------------
declare		
	@date     	datetime,		-- 结帐时间
	@empno		char(10),		-- 结帐工号
	@shift		char(1),			-- 结帐班号

	@code		   char(5),			-- 付款代码
	@codedes	   varchar(50),	-- 付款代码
	@reason	   char(3), 		-- 折扣款待理由
	@name		   varchar(24),	-- 款项码描述
	@amount		money,			-- 金额
	@room		   char(5),			-- 转帐房号
	@accnt		char(10),		-- 转帐帐号
	@cardno     char(20),		-- 卡号
	@ref			varchar(255)

delete bill_data where pc_id  = @pc_id

create table #dish
(
	id          int         			null,   --序列号
	pccode		char(5)					null,	  --费用码
   code     	char(8)     			null,   --菜谱明细码 
	name	   	varchar(50)				null,	  --菜谱名称
	price       money       			null,   --单价  
	number      money  default 0 		null,   --数量
	unit        char(4)     			null,   --单位  

	fee			money	default 0 		null,   --费用总额
	fee_base	   money	default 0 	   null,	  --基本费
	fee_serve	money	default 0 	   null,	  --服务费
	fee_tax  	money	default 0 	   null,	  --附加费
	fee_disc 	money	default 0 	   null,	  --折扣费
	refer		   varchar(40)	   		null,	  --备注

	empno1		char(10)					null,	  --录入或修改工号
	shift1		char(1)					null	  --班号
)

if @setnumb='NOCHK'  -- 未结账单 
begin 
	-- 结帐信息
	select @date=getdate(),@empno=@bempno,@shift='',@code='',@reason='',
			@name='',@amount=0,@room='*****',@accnt='NOCHK',@cardno=''

	-- 明细信息
	insert #dish 
		select b.id,b.pccode,b.code,b.name,b.price,b.number,b.unit,
				b.fee,b.fee_base,b.fee_serve,b.fee_tax,b.fee_disc,b.refer,b.empno1,b.shift1
		from bos_folio a, bos_dish b, selected_account c  
		where a.foliono=c.accnt and c.type='b' and c.pc_id=@pc_id and a.foliono=b.foliono and b.sta<>'C'

	insert #dish 
		select 0,a.pccode,'-',a.name,null,null,'',
				a.fee,a.fee_base,a.fee_serve,a.fee_tax,a.fee_disc,a.refer,a.empno1,a.shift1
		from bos_folio a, selected_account c  
		where a.foliono=c.accnt and c.type='b' and c.pc_id=@pc_id and not exists(select 1 from bos_dish b where a.foliono=b.foliono)

	select @amount = isnull((select sum(fee) from #dish),0) 
end
else if exists(select 1 from bos_account where setnumb=@setnumb)
begin  -- 当前
	-- 结帐信息
	select @date=log_date,@empno=empno,@shift=shift,@code=code,@reason=reason,
			@name=name,@amount=amount,@room=room,@accnt=accnt,@cardno=cardno
		from bos_account where setnumb=@setnumb

	-- 明细信息
	insert #dish 
		select b.id,b.pccode,b.code,b.name,b.price,b.number,b.unit,
				b.fee,b.fee_base,b.fee_serve,b.fee_tax,b.fee_disc,b.refer,b.empno1,b.shift1
		from bos_folio a, bos_dish b 
		where a.setnumb=@setnumb and a.foliono=b.foliono and a.sta='O' and b.sta<>'C'

	insert #dish 
		select 0,a.pccode,'-',a.name,null,null,'',
				a.fee,a.fee_base,a.fee_serve,a.fee_tax,a.fee_disc,a.refer,a.empno1,a.shift1
		from bos_folio a
		where a.setnumb=@setnumb and not exists(select 1 from bos_dish b where a.foliono=b.foliono)

end
else
begin		-- 历史
	-- 结帐信息
	select @date=log_date,@empno=empno,@shift=shift,@code=code,@reason=reason,
			@name=name,@amount=amount,@room=room,@accnt=accnt,@cardno=cardno
		from bos_haccount where setnumb=@setnumb

	-- 明细信息
	insert #dish 
		select b.id,b.pccode,b.code,b.name,b.price,b.number,b.unit,
				b.fee,b.fee_base,b.fee_serve,b.fee_tax,b.fee_disc,b.refer,b.empno1,b.shift1
		from bos_hfolio a, bos_hdish b 
		where a.setnumb=@setnumb and a.foliono=b.foliono and a.sta='O' and b.sta<>'C'

	insert #dish 
		select 0,a.pccode,'-',a.name,null,null,'',
				a.fee,a.fee_base,a.fee_serve,a.fee_tax,a.fee_disc,a.refer,a.empno1,a.shift1
		from bos_hfolio a
		where a.setnumb=@setnumb and not exists(select 1 from bos_hdish b where a.foliono=b.foliono)

end

-- 
if @language <> 'C' 
begin
	update #dish set name=a.descript1 from pccode a where #dish.code='-' and #dish.pccode=a.pccode
	update #dish set name=a.ename from bos_plu a where #dish.pccode=a.pccode and #dish.code=a.code
end

if @language = 'C' 
	select @codedes = descript from pccode where pccode=@code
else
	select @codedes = descript1 from pccode where pccode=@code
if @@rowcount = 0 or rtrim(@codedes) is null 
	select @codedes = ''
	
if @accnt = 'NOCHK'
	select @ref = '-------', @setnumb='-------'
else if rtrim(@accnt) is not null
	select @ref = 'Transfer to : ' + isnull(@room,'') + ' - ' + @accnt 
else if rtrim(@cardno) is not null
	select @ref = 'Card # : ' + @cardno
else
	select @ref = ''

-- Insert bill_data
insert bill_data (pc_id,descript,unit,number,price,charge)
	select @pc_id,name,unit,number,price,fee from #dish 
update bill_data set 
		char1 = @setnumb,
		char2 = @empno, 
		char3 = '20'+convert(char(8),@date,2)+' '+convert(char(8),@date,8),
		sum1 = @code + ' ' + @codedes,
		sum2 = convert(char(10),@amount),
		sum3 = @ref,
		sum4 = @bempno
	where pc_id=@pc_id

return 0
/* ### DEFNCOPY: END OF DEFINITION */
;