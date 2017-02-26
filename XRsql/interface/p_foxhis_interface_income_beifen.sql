drop procedure p_foxhis_interface_income;
create proc p_foxhis_interface_income
	@menu				char(10),
	@pc_id			char(4), 
	@shift			char(1),
	@empno			char(10), 
	@pccode			char(5),	
	@paycode			char(5),		                  		                  
	@accnt			char(10),		        
	@guests			int,
	@amount			money,		--总金额	          	          
	@srv				money,		--服务费	          
	@dsc				money,		--折扣	        
	@tax				money,		--税
	@food				money,		--食品金额	          
	@drink			money,		--酒水金额	          
	@cig				money,		--香烟金额	
	@other1			money,
	@other2			money,
	@other3			money,		          
	@option			char(5),			            
	@remark			char(32)		        
as

declare		
	@set			char(1),
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

select @ret = 0, @msg = ''
if @shift = '1'
	select @descript = '早餐'
if @shift = '2'
	select @descript = '中餐'
if @shift = '3'
	select @descript = '晚餐'
if @shift = '4'
	select @descript = '夜餐'



//if @amount <> 	@amount_1 + @amount_2 + @amount_3 + @srv - @dsc + 	@tax
//	begin
//	select @ret = 1, @msg = '总金额同各分项金额之和不等'
//	Goto gout
//	end


select @ret = 0
begin tran 
save 	tran t_inteface


select @set = 'T'
select @bdate = bdate from sysdata



//exec  p_GetAccnt1 "POS" , @menu out
//
//if @set = 'T'
//	begin
//	select @deptno = isnull(deptno,'') from pccode where pccode = @pccode
//	select @deptno2 = isnull(deptno2,'') from pccode where pccode = @paycode
//--select @remark = isnull(descript,'') from pos_pccode where chgcod = @pccode
//	select @descript = @remark +'-' +@descript
//	if charindex(@deptno2, 'TOA#TOR') > 0 
//		begin
//		if not exists(select 1 from master where accnt = @accnt and sta in ('I','R','S'))  -- gds modi. for RS
//			begin
//			select @ret = 1, @msg = @accnt +	'-账号不存在！！'
//			Goto gout
//			end

			select @selemark = 'a' + @menu , @today = getdate()

			exec @ret = p_gl_accnt_posting @selemark, '04',@pc_id,3, @shift, @empno, @accnt,1,@pccode, '',1, @amount,0,@srv,@dsc,@tax,0,@menu,@descript, @today, '', '', @option,0, '', @msg out
			if @ret <> 0
				Goto gout
//	--exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id,3, @shift, @empno, @accnt,@subaccnt, @chgcod, '',1, @amount,@amount1,@amount2,@amount3,@amount4,@amount5,@menu,'', @today, '', @mode, @option, 0, '', @msg out
//	                                                                                                                                                                         
//		end
//	--select @pccode = rtrim(pccode) from pos_pccode where ltrim(rtrim(chgcod)) = ltrim(rtrim(@pccode))
//	insert pos_menu (tag,   menu,tables, guest,date0,bdate,shift,deptno,pccode,posno,tableno,mode,dsc_rate,reason,tea_rate,
//				serve_rate,tax_rate, srv,dsc,tax,amount,amount0,amount1,empno1,empno2,empno3,sta,paid,setmodes,cusno,haccnt,tranlog,  
//				foliono,remark,roomno,accnt,lastnum,pcrec,pc_id,guestid,saleid,empno1_name,tag1,tag2,tag3)
//	select '0', @menu, 1, @guests, getdate(),@bdate,@shift,@deptno, @pos_pccode, '10', '', '000',0,'',0,
//				0,0,@srv,@dsc,0,@amount,@amount,0,'','',@empno,'3','1',@paycode,'','','',
//				@remark,'','','',3,'',@pc_id,'','','','','',''
//	
//	--菜谱里应有'001001','101001','201001'三个菜，ID号也应根据实际情况调整
//	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
//		select @menu,1,'','',0,0,'Z',1,@srv,'服务费','','',@empno,@bdate,'','N','0', 0,0,'',@srv,0,0,'', '','','',null,null
//	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
//		select @menu,2,'','',0,0,'Y',1,@tax,'附加费','','',@empno,@bdate,'','N','0', 0,0,'',@tax,0,0,'', '','','',null,null
//
//	--折扣，服务费和附加费都集中算在食品上
//	--这里要判一下折扣，服务费和附加费到底算在什么费用上，还是要不要分摊？可能要修改
//	--如果食品有金额，折扣算到食品上，否则酒水有金额，折扣算到酒水上，否则香烟有金额，折扣算到香烟上
//
//	select @dsc_1 = 0, @dsc_2 = 0, @dsc_3 = 0
//	if @amount_1 <> 0 
//		select @dsc_1 = @dsc
//	else if @amount_2 <> 0 
//		select @dsc_2 = @dsc
//	else if @amount_3 <> 0 
//		select @dsc_3 = @dsc
//
//	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
//		select @menu,4,'10','0001',6,0,'001001',1,@amount_1,'食品费用','charge','',@empno,@bdate,'','N','0', 0,0,'',@srv,@dsc_1,@tax,'', '','','',null,null
//	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
//		select @menu,5,'10','0001',6,0,'101001',2,@amount_2,'酒水费用','charge','',@empno,@bdate,'','N','0', 0,0,'',0,@dsc_2,0,'', '','','',null,null
//	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
//		select @menu,6,'10','0001',6,0,'201001',3,@amount_3,'香烟费用','charge','',@empno,@bdate,'','N','0', 0,0,'',0,@dsc_3,0,'', '','','',null,null
//	insert into pos_pay
//		select @menu,1,1,@paycode,@accnt,'','',@amount,'3','NR','',@empno,@bdate,@shift,getdate(),'', ''
//	end
//
gout:
if @ret <> 0 
	rollback tran

commit t_inteface

select @ret, @msg;
