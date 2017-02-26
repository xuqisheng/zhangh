drop proc p_cq_pos_checkout;
create proc p_cq_pos_checkout
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
	@remark			char(50)	
as
declare
	@menu1		char(10),
   @ret			integer,
	@guestid		char(7),
   @msg			char(60),
   @lastnum		integer,
   @lastnum1	integer,
   @number		integer,
	@bdate		datetime,
	@today		datetime,
	@package		char(3),
	@name1		varchar(20),
	@name2		varchar(30),
	@special		char(1),
	@debit		money,
   @credit		money,
	@descript1	char(3),
	@tag1			char(3),
	@roomno		varchar(20),
	@selemark	char(13),
	@lastnumb	integer,
	@inbalance	money

select @bdate = bdate1,@today = getdate() from sysdata
select @ret = 0, @msg = '结帐成功', @roomno=''

select @selemark = 'a餐厅转账'
select @pccode = value from sysoption where catalog = 'pos_int' and item = 'pccode'
if @pccode = '' or @pccode is null  
	select @pccode = min(pccode) from pos_pccode 

select @pccode = rtrim(@pccode) + 'A', @package = ' ' + rtrim(@pccode)

begin tran
save tran p_gl_pos_checkout_s
//exec  p_GetAccnt1 "POS" , @menu out
//insert pos_menu (tag,   menu,tables, guest,bdate,shift,deptno,pccode,posno,tableno,mode,dsc_rate,reason,tea_rate,
//				serve_rate,tax_rate, srv,dsc,tax,amount,amount0,amount1,empno1,empno2,empno3,sta,paid,setmodes,cusno,haccnt,tranlog,  
//				foliono,remark,roomno,accnt,lastnum,pcrec,pc_id,guestid,saleid,empno1_name,tag1,tag2,tag3)
//	select '0', @menu, 1, 1,@bdate,'1','02', @pccode, '10', '', '000',0,'',0,
//				0,0,0,0,0,@amount,@amount,0,'','','HRY','3','1','C86','','','',
//				'','','','',3,'','.111','','','','','',''
//
//insert pos_dish(menu,inumber,plucode,sort,id,printid,code,number,amount,name1,name2,unit,empno,bdate,remark,special,sta, id_cancel,id_master,reason,srv,dsc,tax,orderno, tableno,siteno,flag,date1,date2)
//		select @menu,4,'10','0001',6,0,'001001',1,@amount,'食品费用','charge','','HRY',@bdate,'','N','0', 0,0,'',0,0,0,'', '','','',null,null
//				
//
//insert into pos_pay
//		select @menu,1,1,'C86',@accnt,'','',@amount,'3','NR','','HRY',@bdate,'1',getdate(),'', ''
//

exec @ret = p_gl_accnt_post_charge @selemark, 0, 0, '04', @pc_id, @shift, @empno, @accnt, '', '', @pccode, @package, @amount, NULL, @today, NULL, 'IN', 'R', '', 'I', @msg out

if @ret <> 0
   rollback tran p_gl_pos_checkout_s
commit tran
select @ret,@msg;
