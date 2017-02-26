drop procedure p_cq_interface_income_v5;
create proc p_cq_interface_income_v5
	@menu				char(10),	--�Է�����
	@pc_id			char(4), 
	@shift			char(1),
	@empno			char(10), 
	@pccode			char(5),		--���ʷ�����
	@paycode			char(5),		--���ʽ      		                  
	@accnt			char(10),	--�ʺ�
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
	@remark			char(32),
	@postselect    char(1)		--���˷�ʽѡ��,1,ֻ���˲���POS�����ɵ���,<>1,��POS���ɵ���        
as

declare		
	@set			char(1),
	@package		char(3),
	@pos_menu	char(10),
	@bdate		datetime,
	@descript	char(20),
	@today		datetime,
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

select @ret = 0
select @pos_menu = ''
begin tran 
save 	tran t_inteface

select @bdate = bdate1 from sysdata

if exists(select 1 from int_menu where int_menu = @menu)
	select @ret = 1,@msg = @menu + '-�õ����ѱ�ռ��'
else
	begin
--====================================================================
--���ݲ����ж��Ƿ�Ҫ��POS�����ɵ���,���ʺŹ��˺Ϳͷ������ǲ����ɵ�
--���������˵Ļ�,�����еĵ��Ӷ�Ҫ��POS������
--====================================================================
	if @postselect <> '1' 
		begin
		exec  p_GetAccnt1 "POS" , @pos_menu out
		select @deptno = isnull(deptno,'') from chgcod where pccode = @pccode
		insert pos_menu (tag,   menu,tables, guest,date0,bdate,shift,deptno,pccode,posno,tableno,mode,dsc_rate,reason,tea_rate,
					serve_rate,tax_rate, srv,dsc,tax,amount,amount0,amount1,empno1,empno2,empno3,sta,paid,setmodes,cusno,haccnt,tranlog,  
					foliono,remark,roomno,accnt,lastnum,pcrec,pc_id,guestid,saleid,amount2,amount3,amount4,amount5,amount6)
		select '0', @pos_menu, 1, @guests, getdate(),@bdate,@shift,@deptno, @pos_pccode, '10', @tableno, '000',0,'',0,
					0,0,@srv,@dsc,0,@amount,@amount,0,'','',@empno,'3','1',@paycode,'','','',
					@menu,'','','',3,'',@pc_id,'','',0,0,0,0,0
		
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
			if @food > 0 
				insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
					select @pos_menu,4,'10','0001',6,0,'001001',1,@food,'ʳƷ����','charge','',@empno,@bdate,'','N','0', 0,0,'',@srv,@dsc_1,@tax,'', '','','',null,null
			if @drink > 0
				insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
					select @pos_menu,5,'10','0001',6,0,'101001',2,@drink,'��ˮ����','charge','',@empno,@bdate,'','N','0', 0,0,'',0,@dsc_2,0,'', '','','',null,null
			if @cig > 0
				insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
					select @pos_menu,6,'10','0001',6,0,'201001',3,@cig,'���̷���','charge','',@empno,@bdate,'','N','0', 0,0,'',0,@dsc_3,0,'', '','','',null,null
			insert into pos_pay
				select @pos_menu,1,1,@paycode,@accnt,'','',@amount,'3','NR','',@empno,@bdate,@shift,getdate(),'', ''
		end
	if @pos_menu = '' 
		select @menu1 = @menu
	else
		select @menu1 = @pos_menu
--====================================================================
--���ù��˹���
--====================================================================		
	select @deptno2 = isnull(tag1,'') from paymth where paycode = @paycode
	if charindex(@deptno2, 'TOA#TOR') > 0 
		begin
		select @selemark = 'a' + @menu , @today = getdate()
		//exec @ret = p_gl_accnt_posting @selemark, '04',@pc_id,3, @shift, @empno, @accnt,1,@pccode, '',1, @amount,0,@srv,@dsc,@tax,0,@menu1,@descript, @today, '', '', @option,0, '', @msg out
		select @pccode = rtrim(@pccode) + 'A', @package = ' ' + rtrim(@pccode)
		exec @ret = p_gl_accnt_post_charge @selemark, 0, 0, '04', @pc_id, @shift, @empno, @accnt, '', '', @pccode, @package, @amount, NULL, @today, NULL, 'IN', 'R', '', 'I', @msg out
		if @ret <> 0
			Goto gout
		end
		
	if exists(select 1 from int_menu where int_menu = @menu)
		delete int_menu where int_menu = @menu
--�ѶԷ��ĵ��ź�POS�ĵ��Ź������浽����
	insert int_menu select @menu,@pos_menu,@accnt,@paycode,'3'
	if @@rowcount = 0 
		select @ret = 2
	end


gout:
if @ret <> 0 
	rollback tran

commit t_inteface

select @ret, @msg;
