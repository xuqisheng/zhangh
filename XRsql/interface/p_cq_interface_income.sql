drop procedure p_cq_interface_income;
create proc p_cq_interface_income
	@menu				char(10),	--�Է�����
	@pc_id			char(4), 
	@shift			char(1),
	@empno			char(10), 
	@pccode			char(5),		--���ʷ�����pccode-->pccode������Ĳ�����pos_pccode-->pccode
	@paycode			char(5),		--���ʽ      		                  
	@accnt			char(10),	--�ʺ�
	@roomno			char(6),
	@guestno			char(7),
	@tableno			char(6),		--����  
	@guests			int,			--����
	@amount			money,		--�ܽ��	          	          
	@srv				money,		--�����	          
	@dsc				money,		--�ۿ�	        
	@tax				money,		--˰
	@food				money,		--ʳƷ���	          
	@drink			money,		--��ˮ���	          
	@cig				money,		--���̽��	
	@other1			money,		--�������1
	@other2			money,		--�������2
	@other3			money,		--�������3
	@option			char(5),			            
	@remark			char(32)  
as

declare		
	@set			char(1),
	@postselect char(1),
	@inumber		integer,
	@pos_menu	char(10),
	@bdate		datetime,
	@descript	char(20),
	@today		datetime,
	@pos_pccode	char(3),
	@deptno		char(2),
	@deptno2		char(3),
	@selemark	char(13),
	@menu1		char(10),
	@lic_buy_1 	char(255),
	@lic_buy_2 	char(255),
	@amount1		money,
	@amount_old money,
	@amount5		money,
	@dsc_1		money,
	@dsc_2		money,
	@dsc_3		money,
	@accnt_bank char(10),
	@ret			int,
	@msg			char(64)	


select @ret = 0
select @pos_menu = ''
select @lic_buy_1 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.1'
select @lic_buy_2 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.2'
begin tran
save 	tran t_inteface

--============================================================
--�������pos_int_pccodeȡ��
--============================================================
select @pos_pccode = @pccode
if not exists(select 1 from pos_int_pccode where class = '2' and pos_pccode = @pos_pccode and shift = @shift)
	begin
	select @ret = 1, @msg = @pos_pccode + '�ڵķ�����û�ж���--pos_int_pccode'
	Goto gout
	end
select @pccode = pccode from pos_int_pccode where class = '2' and pos_pccode = @pos_pccode and shift = @shift
------------------------------------------------------
select @bdate = bdate1 from sysdata
select @roomno = isnull(roomno,'') from master where accnt = @accnt and sta in ('I','S')
if not exists(select 1 from pccode where pccode = @paycode)
	begin
	select @ret = 1, @msg = @paycode +	'-�����벻���ڣ���'
	Goto gout
	end
--====================================================================
--���ݲ����ж��Ƿ�Ҫ��POS�����ɵ���,���ʺŹ��˺Ϳͷ������ǲ����ɵ�
--���������˵Ļ�,�����еĵ��Ӷ�Ҫ��POS������
--@postselect����Ҫ��ֵ
--====================================================================
if @postselect <> '1' 
	begin
	exec  p_GetAccnt1 "POS" , @pos_menu out
	select @deptno = isnull(deptno,'') from pccode where pccode = @pccode
	insert pos_menu (tag,   menu,tables, guest,date0,bdate,shift,deptno,pccode,posno,tableno,mode,dsc_rate,reason,tea_rate,
				serve_rate,tax_rate, srv,dsc,tax,amount,amount0,amount1,empno1,empno2,empno3,sta,paid,setmodes,cusno,haccnt,tranlog,  
				foliono,remark,roomno,accnt,lastnum,pcrec,pc_id,guestid,saleid,empno1_name,resno,cardno,systype,tag1,tag2,tag3)
	select '0', @pos_menu, 1, @guests, getdate(),@bdate,@shift,@deptno, @pos_pccode, '10', @tableno, '000',0,'',0,
				0,0,@srv,@dsc,0,@amount,@amount,0,'','',@empno,'3','1',@paycode,'','','',
				@menu,'','','',3,'',@pc_id,'','','','','','','','',''
	
	--������Ӧ��'001001','101001','201001'�����ˣ�ID��ҲӦ����ʵ���������
	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
		select @pos_menu,1,'','',0,0,'Z',1,@srv,'�����','','',@empno,@bdate,'','N','0', 0,0,'',@srv,0,0,'', '','','',null,null
	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
		select @pos_menu,2,'','',0,0,'Y',1,@tax,'���ӷ�','','',@empno,@bdate,'','N','0', 0,0,'',@tax,0,0,'', '','','',null,null

--�ۿۣ�����Ѻ͸��ӷѶ���������ʳƷ��
--����Ҫ��һ���ۿۣ�����Ѻ͸��ӷѵ�������ʲô�����ϣ�����Ҫ��Ҫ��̯������Ҫ�޸�
--���ʳƷ�н��ۿ��㵽ʳƷ�ϣ������ˮ�н��ۿ��㵽��ˮ�ϣ����������н��ۿ��㵽������
	select @dsc_1 = 0, @dsc_2 = 0, @dsc_3 = 0
	if @food <> 0 
		select @dsc_1 = @dsc
	else if @drink <> 0 
		select @dsc_2 = @dsc
	else if @cig <> 0 
		select @dsc_3 = @dsc
	if @food <> 0 
		insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
			select @pos_menu,4,'10','0001',6,0,'001001',1,@food,'ʳƷ����','charge','',@empno,@bdate,'','N','0', 0,0,'',@srv,@dsc_1,@tax,'', '','','',null,null
	if @drink <> 0
		insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
			select @pos_menu,5,'10','0001',6,0,'101001',2,@drink,'��ˮ����','charge','',@empno,@bdate,'','N','0', 0,0,'',0,@dsc_2,0,'', '','','',null,null
	if @cig <> 0
		insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
			select @pos_menu,6,'10','0001',6,0,'201001',3,@cig,'���̷���','charge','',@empno,@bdate,'','N','0', 0,0,'',0,@dsc_3,0,'', '','','',null,null
--�����ֵĻ��Զ���ʳƷ����
	if @food = 0 and  @drink = 0 and @cig = 0
		insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
			select @pos_menu,4,'10','0001',6,0,'001001',1,@amount,'ʳƷ����','charge','',@empno,@bdate,'','N','0', 0,0,'',@srv,@dsc_1,@tax,'', '','','',null,null

	insert into pos_pay
		select @pos_menu,1,1,@paycode,@accnt,@roomno,'',@amount,'3','NR','',@empno,@bdate,@shift,getdate(),'', '','',
			0.00,'','',0

	end

if @pos_menu = '' 
	select @menu1 = @menu
else
	select @menu1 = @pos_menu
--====================================================================
--���ù��˹���
--====================================================================		
--================new ar
if (select value from sysoption where catalog = 'ar' and item = 'creditcard') = 'T'
	begin
	select @accnt_bank = ''
	if exists(select 1 from bankcard where pccode = @paycode)        -- �������ж��Ƿ��Զ�תar
		and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
		begin
		select @accnt_bank = min(accnt) from bankcard where pccode = @paycode
		if rtrim(@accnt_bank) is null
			begin
			select @ret = 1, @msg = @paycode + ' û��ת���˺�'
			Goto gout
			end
		select @remark = '�ӿ�ת��'
		end
	end
--=============================
select @deptno2 = isnull(deptno2,'') from pccode where pccode = @paycode
if charindex(@deptno2, 'TOA#TOR') > 0 or rtrim(@accnt_bank) is not null
	begin
	if rtrim(@accnt_bank) is not null
		select @accnt = @accnt_bank
	if @accnt like 'AR%'
		begin
		if not exists(select 1 from ar_master where accnt = @accnt and sta in ('I','R','S')) 
			begin
			select @ret = 1, @msg = @accnt +	'-�˺Ų����ڣ���'
			Goto gout
			end
		end	
	else
		begin	
		if not exists(select 1 from master where accnt = @accnt and sta in ('I','R','S')) 
			begin
			select @ret = 1, @msg = @accnt +	'-�˺Ų����ڣ���'
			Goto gout
			end
		end
	select @selemark = 'a'+@paycode , @today = getdate()
	exec @ret = p_gl_accnt_posting @selemark, '04',@pc_id,3, @shift, @empno, @accnt,1,@pccode, '',1, @amount,0,@srv,@dsc,@tax,0,@menu1,@remark, @today, '', '', @option,0, '', @msg out
	if @ret <> 0
		Goto gout
	
	end

--�ѶԷ��ĵ��ź�POS�ĵ��Ź������浽����
select @inumber = isnull(max(inumber),0) + 1 from int_menu where int_menu = @menu
insert int_menu select @inumber,@menu,@pos_menu,@accnt,@paycode,'3'
if @@rowcount = 0 
	select @ret = 1


gout:
if @ret <> 0 
	rollback tran

commit t_inteface

select @ret, @msg;
