drop procedure p_cq_pos_res_credit;
create proc p_cq_pos_res_credit
	@resno			char(10),
	@pc_id			char(4), 
	@shift			char(1),
	@empno			char(10), 
	@pccode			char(5),		--入帐费用码pccode-->pccode或餐饮的餐厅号pos_pccode-->pccode
	@paycode			char(5),		--付款方式   
	@amount			money,   		                  
	@foliono			char(20),			            
	@remark			char(32)  
as

declare		
	@id			int,
	@pos_menu	char(10),
	@pos_pccode	char(3),
	@deptno		char(2),
	@deptno2		char(2),
	@bdate		datetime,
	@ret			int,
	@msg			char(64)	


select @ret = 0
select @pos_menu = ''
select @id = convert(int,value) from sysoption where catalog = 'pos' and item = 'res_credit'
if not exists(select 1 from pos_plu where id = @id)
	begin
	select @ret = 1, @msg = rtrim(convert(char,@id)) + '在的菜谱中没有定义--pos_plu'
	Goto gout
	end
//select @lic_buy_1 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.1'
//select @lic_buy_2 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.2'
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
if not exists(select 1 from pccode where pccode = @paycode)
	begin
	select @ret = 1, @msg = @paycode +	'-付款码不存在！！'
	Goto gout
	end

	exec  p_GetAccnt1 "POS" , @pos_menu out
	select @deptno = isnull(deptno,'') from pos_pccode where pccode = @pos_pccode

	insert pos_menu (tag,tag1,tag2,tag3,source,market,menu,tables,guest,date0,bdate,shift,deptno,pccode,posno,tableno,
			mode,dsc_rate,reason,tea_rate,serve_rate,tax_rate,srv,dsc,tax,amount,amount0,amount1,empno1,empno2,empno3,
			sta,paid,setmodes,cusno,haccnt,foliono,remark,roomno,accnt,lastnum,pcrec,pc_id,timestamp,saleid,resno,cardno,
				checkid )
	select '0','','','','','', @pos_menu, 1, 1, getdate(),@bdate,@shift,@deptno, @pos_pccode, '', '', 
			'000',0,'',0,0,0,0,0,0,@amount,@amount,0,'','',@empno,
			'3','1',@paycode,'','',	@foliono,@remark,'','',3,'',@pc_id,'','',@resno,'',''
	if @@rowcount = 0 
		begin
		select @ret = 1, @msg = '数据插入失败'
		Goto gout
		end

	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
		select @pos_menu,1,'','',0,0,'Z',1,0,'服务费','','',@empno,@bdate,'','N','0', 0,0,'',0,0,0,'', '','','',null,null
	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
		select @pos_menu,2,'','',0,0,'Y',1,0,'附加费','','',@empno,@bdate,'','N','0', 0,0,'',0,0,0,'', '','','',null,null


	insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2,flag19,flag19_use)
		select @pos_menu,4,a.plucode,a.sort,a.id,0,a.code,1,@amount,a.name1,a.name2,'',@empno,@bdate,@remark,'N','0', 0,0,'',0,0,0,'', '','',a.flag0+a.flag1+a.flag2+a.flag3+a.flag4
				+a.flag5+a.flag6+a.flag7+a.flag8+a.flag9+a.flag10+a.flag11+a.flag12+a.flag13+a.flag14+a.flag15+
					a.flag16+a.flag17+a.flag18+a.flag19+'FFFFFFFFFF',null,null,a.flag19,''
			from pos_plu a where a.id = @id

	insert into pos_pay(menu, number, inumber, paycode, accnt, roomno, foliono, amount, sta, crradjt, reason, empno, bdate, shift, log_date, remark, menu0)
		select @pos_menu,1,1,@paycode,'','',@foliono,@amount,'3','NR','',@empno,@bdate,@shift,getdate(),@remark, @resno
		



gout:
if @ret <> 0 
	rollback tran

commit t_inteface

select @ret, @msg;
