drop procedure p_pos_interface_income;
create proc p_pos_interface_income
	@pc_id			char(4), 
	@shift			char(1),
	@empno			char(10), 
	@pccode_out		char(5),			                  
	@paycode_out	char(5),			                  
	@accnt			char(10),		        
	@guests			int,
	@amount			money,		--�ܽ��	          
	@amount_1		money,		--ʳƷ���	          
	@amount_2		money,		--��ˮ���	          
	@amount_3		money,		--���̽��			          
	@srv				money,		--�����	          
	@dsc				money,		--�ۿ�	        
	@tax				money,		--˰	          
	@option			char(5),			            
	@remark			char(32)		        
as

declare		
	@menu 		char(10),
	@set			char(1),
	@bdate		datetime,
	@descript	char(20),
	@today		datetime,
	@paycode		char(5),
	@pccode		char(5),
	@pos_pccode	char(3),
	@deptno		char(2),
	@deptno2		char(3),
	@roomno		char(6),
	@selemark	char(13),
	@menu1		char(10),
	@amount1		money,
	@amount_old money,
	@amount5		money,
	@dsc_1		money,
	@dsc_2		money,
	@dsc_3		money,
	@ret			int,
	@msg			char(64)	

select @ret = 0, @msg = ''
if @shift = '1'
	select @descript = '���'
if @shift = '2'
	select @descript = '�в�'
if @shift = '3'
	select @descript = '���'
if @shift = '4'
	select @descript = 'ҹ��'

-----------------------------------
--pos_int_pccode ע��
-----------------------------------
--class = 1 		��ʾ�������
--class = 2			��ʾ���������
-----------------------------------

select  @paycode = pccode from pos_int_pccode where class ='1' and int_code = @paycode_out
if @@rowcount = 0 
	begin
	select @paycode = @paycode_out
	select @ret = 1, @msg = @paycode_out +	'-�������Ӧ��ϵ�����ڣ���'
	Goto gout
	end
select  @pccode = pccode ,@pos_pccode = pos_pccode from pos_int_pccode where class ='2' and int_code = @pccode_out 
	and shift = @shift and pos_pccode in (select pccode from pos_pccode )
if @@rowcount = 0 
	begin
	select @pccode = @pccode_out
	select @ret = 1, @msg = @pccode_out +	'-�������Ӧ��ϵ�����ڣ���'
	Goto gout
	end

if @amount <> 	@amount_1 + @amount_2 + @amount_3 + @srv - @dsc + 	@tax
	begin
	select @ret = 1, @msg = '�ܽ��ͬ��������֮�Ͳ���'
	Goto gout
	end


select @ret = 0
begin tran 
save 	tran t_inteface


select @set = 'T'
select @bdate = bdate from sysdata

-----------����ʵ�������������foliono�����������ϵͳ��������Ψһ����

--�ؽ�-
if exists(select 1 from pos_menu where rtrim(foliono) = rtrim(@remark) and amount = @amount * -1 and setmodes = @paycode  )   
	begin
	select @menu1 = menu from pos_menu where rtrim(foliono) = rtrim(@remark)
	exec @ret = p_cyj_pos_recheck  @menu1
	if @ret = 0
	begin
	delete pos_menu where menu = @menu1
	delete pos_dish where menu = @menu1
	delete pos_pay where menu = @menu1
	select @set = 'F'
	end
	end
--����ͳ�ʱ
if exists(select 1 from pos_menu where rtrim(foliono) = rtrim(@remark) and amount <> @amount * -1   and setmodes = @paycode )   
	begin
	select @menu1 = menu from pos_menu where rtrim(foliono) = rtrim(@remark)
	exec @ret = p_cyj_pos_recheck  @menu1
	if @ret = 0
	begin
	select @amount_old = amount from pos_menu where menu = @menu1
	delete pos_menu where menu = @menu1
	delete pos_dish where menu = @menu1
	delete pos_pay where menu = @menu1
	if (@amount > 0 and @amount_old < 0) or (@amount < 0 and @amount_old > 0)    --���������
		select @amount = @amount_old + @amount
	else
		select @amount = @amount_old
	select @set = 'T'
	end
	end
--����һ���������ͬһ�ŵ��ӵĶ��ֽ��ʷ�ʽ

------------------------------


exec  p_GetAccnt1 "POS" , @menu out

if @set = 'T'
	begin
	select @deptno = isnull(deptno,'') from pccode where pccode = @pccode
	select @deptno2 = isnull(deptno2,'') from pccode where pccode = @paycode
--select @remark = isnull(descript,'') from pos_pccode where chgcod = @pccode
	select @descript = @remark +'-' +@descript
	if charindex(@deptno2, 'TOA#TOR') > 0 
		begin
		if not exists(select 1 from master where accnt = @accnt and sta in ('I','R','S'))  -- gds modi. for RS
			begin
			select @ret = 1, @msg = @accnt +	'-�˺Ų����ڣ���'
			Goto gout
			end
			select @selemark = 'a' + @menu , @today = getdate()

			exec @ret = p_gl_accnt_posting @selemark, '04',@pc_id,3, @shift, @empno, @accnt,1,@pccode, '',1, @amount,0,@srv,@dsc,@tax,0,@menu,@descript, @today, '', '', @option,0, '', @msg out
			if @ret <> 0
				Goto gout
	--exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id,3, @shift, @empno, @accnt,@subaccnt, @chgcod, '',1, @amount,@amount1,@amount2,@amount3,@amount4,@amount5,@menu,'', @today, '', @mode, @option, 0, '', @msg out
	                                                                                                                                                                         
		end
	--select @pccode = rtrim(pccode) from pos_pccode where ltrim(rtrim(chgcod)) = ltrim(rtrim(@pccode))
	insert pos_menu (tag,   menu,tables, guest,date0,bdate,shift,deptno,pccode,posno,tableno,mode,dsc_rate,reason,tea_rate,
				serve_rate,tax_rate, srv,dsc,tax,amount,amount0,amount1,empno1,empno2,empno3,sta,paid,setmodes,cusno,haccnt,tranlog,  
				foliono,remark,roomno,accnt,lastnum,pcrec,pc_id,guestid,saleid,empno1_name,tag1,tag2,tag3)
	select '0', @menu, 1, @guests, getdate(),@bdate,@shift,@deptno, @pos_pccode, '10', '', '000',0,'',0,
				0,0,@srv,@dsc,0,@amount,@amount,0,'','',@empno,'3','1',@paycode,'','','',
				@remark,'','','',3,'',@pc_id,'','','','','',''
	
	--������Ӧ��'001001','101001','201001'�����ˣ�ID��ҲӦ����ʵ���������
	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
		select @menu,1,'','',0,0,'Z',1,@srv,'�����','','',@empno,@bdate,'','N','0', 0,0,'',@srv,0,0,'', '','','',null,null
	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
		select @menu,2,'','',0,0,'Y',1,@tax,'���ӷ�','','',@empno,@bdate,'','N','0', 0,0,'',@tax,0,0,'', '','','',null,null

	--�ۿۣ�����Ѻ͸��ӷѶ���������ʳƷ��
	--����Ҫ��һ���ۿۣ�����Ѻ͸��ӷѵ�������ʲô�����ϣ�����Ҫ��Ҫ��̯������Ҫ�޸�
	--���ʳƷ�н��ۿ��㵽ʳƷ�ϣ������ˮ�н��ۿ��㵽��ˮ�ϣ����������н��ۿ��㵽������

	select @dsc_1 = 0, @dsc_2 = 0, @dsc_3 = 0
	if @amount_1 <> 0 
		select @dsc_1 = @dsc
	else if @amount_2 <> 0 
		select @dsc_2 = @dsc
	else if @amount_3 <> 0 
		select @dsc_3 = @dsc

	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
		select @menu,4,'10','0001',6,0,'001001',1,@amount_1,'ʳƷ����','charge','',@empno,@bdate,'','N','0', 0,0,'',@srv,@dsc_1,@tax,'', '','','',null,null
	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
		select @menu,5,'10','0001',6,0,'101001',2,@amount_2,'��ˮ����','charge','',@empno,@bdate,'','N','0', 0,0,'',0,@dsc_2,0,'', '','','',null,null
	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
		select @menu,6,'10','0001',6,0,'201001',3,@amount_3,'���̷���','charge','',@empno,@bdate,'','N','0', 0,0,'',0,@dsc_3,0,'', '','','',null,null
	insert into pos_pay
		select @menu,1,1,@paycode,@accnt,'','',@amount,'3','NR','',@empno,@bdate,@shift,getdate(),'', ''
	end

gout:
if @ret <> 0 
	rollback tran

commit t_inteface

select @ret, @msg;
