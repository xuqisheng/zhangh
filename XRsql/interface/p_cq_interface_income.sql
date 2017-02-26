drop procedure p_cq_interface_income;
create proc p_cq_interface_income
	@menu				char(10),	--对方单号
	@pc_id			char(4), 
	@shift			char(1),
	@empno			char(10), 
	@pccode			char(5),		--入帐费用码pccode-->pccode或餐饮的餐厅号pos_pccode-->pccode
	@paycode			char(5),		--付款方式      		                  
	@accnt			char(10),	--帐号
	@roomno			char(6),
	@guestno			char(7),
	@tableno			char(6),		--桌号  
	@guests			int,			--人数
	@amount			money,		--总金额	          	          
	@srv				money,		--服务费	          
	@dsc				money,		--折扣	        
	@tax				money,		--税
	@food				money,		--食品金额	          
	@drink			money,		--酒水金额	          
	@cig				money,		--香烟金额	
	@other1			money,		--其他金额1
	@other2			money,		--其他金额2
	@other3			money,		--其他金额3
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
--费用码从pos_int_pccode取得
--============================================================
select @pos_pccode = @pccode
if not exists(select 1 from pos_int_pccode where class = '2' and pos_pccode = @pos_pccode and shift = @shift)
	begin
	select @ret = 1, @msg = @pos_pccode + '在的费用码没有定义--pos_int_pccode'
	Goto gout
	end
select @pccode = pccode from pos_int_pccode where class = '2' and pos_pccode = @pos_pccode and shift = @shift
------------------------------------------------------
select @bdate = bdate1 from sysdata
select @roomno = isnull(roomno,'') from master where accnt = @accnt and sta in ('I','S')
if not exists(select 1 from pccode where pccode = @paycode)
	begin
	select @ret = 1, @msg = @paycode +	'-付款码不存在！！'
	Goto gout
	end
--====================================================================
--根据餐数判断是否要在POS里生成单子,用帐号挂账和客房挂账是不生成的
--用其他挂账的话,是所有的单子都要在POS里生成
--@postselect根据要求赋值
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
	
	--菜谱里应有'001001','101001','201001'三个菜，ID号也应根据实际情况调整
	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
		select @pos_menu,1,'','',0,0,'Z',1,@srv,'服务费','','',@empno,@bdate,'','N','0', 0,0,'',@srv,0,0,'', '','','',null,null
	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
		select @pos_menu,2,'','',0,0,'Y',1,@tax,'附加费','','',@empno,@bdate,'','N','0', 0,0,'',@tax,0,0,'', '','','',null,null

--折扣，服务费和附加费都集中算在食品上
--这里要判一下折扣，服务费和附加费到底算在什么费用上，还是要不要分摊？可能要修改
--如果食品有金额，折扣算到食品上，否则酒水有金额，折扣算到酒水上，否则香烟有金额，折扣算到香烟上
	select @dsc_1 = 0, @dsc_2 = 0, @dsc_3 = 0
	if @food <> 0 
		select @dsc_1 = @dsc
	else if @drink <> 0 
		select @dsc_2 = @dsc
	else if @cig <> 0 
		select @dsc_3 = @dsc
	if @food <> 0 
		insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
			select @pos_menu,4,'10','0001',6,0,'001001',1,@food,'食品费用','charge','',@empno,@bdate,'','N','0', 0,0,'',@srv,@dsc_1,@tax,'', '','','',null,null
	if @drink <> 0
		insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
			select @pos_menu,5,'10','0001',6,0,'101001',2,@drink,'酒水费用','charge','',@empno,@bdate,'','N','0', 0,0,'',0,@dsc_2,0,'', '','','',null,null
	if @cig <> 0
		insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
			select @pos_menu,6,'10','0001',6,0,'201001',3,@cig,'香烟费用','charge','',@empno,@bdate,'','N','0', 0,0,'',0,@dsc_3,0,'', '','','',null,null
--不区分的话自动按食品入帐
	if @food = 0 and  @drink = 0 and @cig = 0
		insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
			select @pos_menu,4,'10','0001',6,0,'001001',1,@amount,'食品费用','charge','',@empno,@bdate,'','N','0', 0,0,'',@srv,@dsc_1,@tax,'', '','','',null,null

	insert into pos_pay
		select @pos_menu,1,1,@paycode,@accnt,@roomno,'',@amount,'3','NR','',@empno,@bdate,@shift,getdate(),'', '','',
			0.00,'','',0

	end

if @pos_menu = '' 
	select @menu1 = @menu
else
	select @menu1 = @pos_menu
--====================================================================
--调用挂账过程
--====================================================================		
--================new ar
if (select value from sysoption where catalog = 'ar' and item = 'creditcard') = 'T'
	begin
	select @accnt_bank = ''
	if exists(select 1 from bankcard where pccode = @paycode)        -- 付款码判断是否自动转ar
		and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
		begin
		select @accnt_bank = min(accnt) from bankcard where pccode = @paycode
		if rtrim(@accnt_bank) is null
			begin
			select @ret = 1, @msg = @paycode + ' 没有转账账号'
			Goto gout
			end
		select @remark = '接口转账'
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
			select @ret = 1, @msg = @accnt +	'-账号不存在！！'
			Goto gout
			end
		end	
	else
		begin	
		if not exists(select 1 from master where accnt = @accnt and sta in ('I','R','S')) 
			begin
			select @ret = 1, @msg = @accnt +	'-账号不存在！！'
			Goto gout
			end
		end
	select @selemark = 'a'+@paycode , @today = getdate()
	exec @ret = p_gl_accnt_posting @selemark, '04',@pc_id,3, @shift, @empno, @accnt,1,@pccode, '',1, @amount,0,@srv,@dsc,@tax,0,@menu1,@remark, @today, '', '', @option,0, '', @msg out
	if @ret <> 0
		Goto gout
	
	end

--把对方的单号和POS的单号关联保存到表里
select @inumber = isnull(max(inumber),0) + 1 from int_menu where int_menu = @menu
insert int_menu select @inumber,@menu,@pos_menu,@accnt,@paycode,'3'
if @@rowcount = 0 
	select @ret = 1


gout:
if @ret <> 0 
	rollback tran

commit t_inteface

select @ret, @msg;
