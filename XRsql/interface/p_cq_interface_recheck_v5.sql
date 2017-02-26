drop procedure p_cq_interface_recheck_v5;
create proc p_cq_interface_recheck_v5
	@menu				char(10),
	@pc_id			char(4), 
	@shift			char(1),
	@empno			char(10), 
	@pccode			char(5),	
	@paycode			char(5),		                  		                  
	@accnt			char(10),		        
	@amount			money,		--�ܽ��	          	          
	@srv				money,		--�����	          
	@dsc				money,		--�ۿ�	        
	@tax				money,		--˰
	@food				money,		--ʳƷ���	          
	@drink			money,		--��ˮ���	          
	@cig				money,		--���̽��	
	@other1			money,
	@other2			money,
	@other3			money,		          
	@option			char(5),			            
	@remark			char(32)
as

declare		
	@set			char(1),
	@pos_menu	char(10),
	@package		char(3),
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
begin tran 
save 	tran t_inteface


select @set = 'T'
select @bdate = bdate from sysdata
if @paycode is null or @paycode = ''
	select @paycode = paycode from int_menu where int_menu = @menu
if not exists(select 1 from int_menu where int_menu = @menu)
	begin
	select @ret = 1 ,@msg = @menu +'-�õ�������'
	goto gout
	end
--====================================================================
--���ж���POS_MENU�����޸õ�,����оͰ������ķ�ʽ�ؽ�
--�����POS_MENU��û�иõ���,��ô�жϸ��ʽ,�����תǰ̨��תAR,��ôֱ��
--���������Ľ����
--====================================================================
if exists(select 1 from int_menu where int_menu = @menu)
	begin
	if exists(select 1 from pos_menu where menu = (select pos_menu from int_menu where int_menu = @menu ) and sta = '3')
		begin
		select @pos_menu = pos_menu from int_menu where int_menu = @menu 
		exec @ret =  p_cyj_pos_recheck @pos_menu,@msg out
		if @ret <> 0 
			goto gout
		delete pos_dish where menu = @pos_menu
		update pos_menu set sta = '7' where menu = @pos_menu
		delete int_menu where int_menu = @menu and pos_menu = @pos_menu
		end
	else
		begin
		if not exists(select 1 from int_menu where int_menu = @menu and sta = '3')
			begin
			select @ret = 1 ,@msg = @menu +'-�õ��Ѿ����ؽ�״̬,�������ؽ�'
			goto gout
			end
		select @deptno2 = isnull(tag1,'') from paymth where paycode = @paycode
		if charindex(@deptno2, 'TOA#TOR') > 0 
			begin
			select @selemark = 'a' + @menu , @today = getdate()
			//exec @ret = p_gl_accnt_posting @selemark, '04',@pc_id,3, @shift, @empno, @accnt,1,@pccode, '',1, @amount,0,@srv,@dsc,@tax,0,@menu,@descript, @today, '', '', @option,0, '', @msg out
			select @pccode = rtrim(@pccode) + 'A', @package = ' ' + rtrim(@pccode)
			exec @ret = p_gl_accnt_post_charge @selemark, 0, 0, '04', @pc_id, @shift, @empno, @accnt, '', '', @pccode, @package, @amount, NULL, @today, NULL, 'IN', 'R', '', 'I', @msg out
			if @ret <> 0
				Goto gout
			update int_menu set sta = '5' where int_menu = @menu 
			end
		end
	end


gout:
if @ret <> 0 
	rollback tran

commit t_inteface

select @ret, @msg;
