drop proc p_gds_bos_bill;
create proc p_gds_bos_bill
	@setnumb				char(10),
	@bcode				char(3),		-- bill_mode.code 
	@language			char(3),		-- ����
	@bempno				char(10),	-- ��ӡ����
	@pc_id				char(4)
as
--------------------------------------------------------------------------------------------------
--	BOS �˵�
--------------------------------------------------------------------------------------------------

-----------------------
-- �˵�ͷβ��Ŀ
-----------------------
declare		
	@date     	datetime,		-- ����ʱ��
	@empno		char(10),		-- ���ʹ���
	@shift		char(1),			-- ���ʰ��

	@code		   char(5),			-- �������
	@codedes	   varchar(50),	-- �������
	@reason	   char(3), 		-- �ۿۿ������
	@name		   varchar(24),	-- ����������
	@amount		money,			-- ���
	@room		   char(5),			-- ת�ʷ���
	@accnt		char(10),		-- ת���ʺ�
	@cardno     char(20),		-- ����
	@ref			varchar(255)

delete bill_data where pc_id  = @pc_id

create table #dish
(
	id          int         			null,   --���к�
	pccode		char(5)					null,	  --������
   code     	char(8)     			null,   --������ϸ�� 
	name	   	varchar(50)				null,	  --��������
	price       money       			null,   --����  
	number      money  default 0 		null,   --����
	unit        char(4)     			null,   --��λ  

	fee			money	default 0 		null,   --�����ܶ�
	fee_base	   money	default 0 	   null,	  --������
	fee_serve	money	default 0 	   null,	  --�����
	fee_tax  	money	default 0 	   null,	  --���ӷ�
	fee_disc 	money	default 0 	   null,	  --�ۿ۷�
	refer		   varchar(40)	   		null,	  --��ע

	empno1		char(10)					null,	  --¼����޸Ĺ���
	shift1		char(1)					null	  --���
)

if @setnumb='NOCHK'  -- δ���˵� 
begin 
	-- ������Ϣ
	select @date=getdate(),@empno=@bempno,@shift='',@code='',@reason='',
			@name='',@amount=0,@room='*****',@accnt='NOCHK',@cardno=''

	-- ��ϸ��Ϣ
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
begin  -- ��ǰ
	-- ������Ϣ
	select @date=log_date,@empno=empno,@shift=shift,@code=code,@reason=reason,
			@name=name,@amount=amount,@room=room,@accnt=accnt,@cardno=cardno
		from bos_account where setnumb=@setnumb

	-- ��ϸ��Ϣ
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
begin		-- ��ʷ
	-- ������Ϣ
	select @date=log_date,@empno=empno,@shift=shift,@code=code,@reason=reason,
			@name=name,@amount=amount,@room=room,@accnt=accnt,@cardno=cardno
		from bos_haccount where setnumb=@setnumb

	-- ��ϸ��Ϣ
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