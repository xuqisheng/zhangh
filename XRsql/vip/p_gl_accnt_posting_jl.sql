drop proc p_gl_accnt_posting;
create proc p_gl_accnt_posting			                                  
	@selemark			char(27) = 'A',	                                                    
	@modu_id				char(2), 
	@pc_id				char(4), 
	@mdi_id				integer, 
	@shift				char(1), 
	@empno				char(10), 
	@accnt				char(10), 
	@subaccnt			integer, 
	@pccode				char(5),				            
	@argcode				char(3),				                              
	@quantity			money,				          
	@amount				money, 				          
	@amount1				money, 
	@amount2				money, 
	@amount3				money, 
	@amount4				money, 
	@amount5				money, 
	@ref1					char(10),			          
	@ref2					char(50),			          
	@date					datetime, 
	@reason				char(3),				              
	@mode					char(10), 			      
	@operation			char(5), 			                                                                                                                                                                                                                             
	@a_number			integer, 			                
	@to_accnt			char(10) output, 
	@msg					varchar(60) output
as
declare
	@ret					integer, 
	@bdate				datetime,			              
	@log_date			datetime,			                
	@ref					char(24),			              
	@descript1			char(8),				              
	@descript2			char(16),			              
	@crradjt				char(2),				              
	@roomno				char(5), 			          
	@to_roomno			char(5),  			                                                
	@groupno				char(10), 
	@lastnumb			integer,
	@lastinumb			integer, 
	@lastpnumb			integer, 
	@pnumber				integer, 			                     
	@charge				money, 
	@credit				money, 
	@balance				money, 
	@catalog				char(3), 
	@selemk				char(1), 
                        
	@package_d			money, 
	@package_c			money, 
	@package_a			money, 
	@type					char(8),				              
	@rm_code				char(3),				                                              
	   
	@to_subaccnt		integer,
	@tor_str				varchar(40), 
	@traned				char(1), 
	@deptno1				char(8), 			           
	@pccodes				char(7), 			          
	@deptno2				char(5),
	@value1				money, 
	@value0				money,
	@mode1				char(10),
	@waiter				char(3),
	@hotelid				varchar(20),		/* 成员酒店号 */
	@vipcard				char(20), 
	@tor					char(1), 
	@araccnt				char(10), 
	@arname				varchar(50), 
	@guestname			varchar(50), 
	@modu_ids			varchar(255),
	@sta					char(1)


                                                              
select @selemark = @selemark + space(30), @pnumber = 0
select @mode1 = substring(@selemark, 2, 10), @waiter = substring(@selemark, 12, 3), @araccnt = substring(@selemark, 15, 10)
if @mode1 like 'P%'
	select @pnumber = convert(integer, substring(@mode1, 2, 9)), @mode1 = ''
select @ret = 0, @to_accnt = '', @traned = 'F', @log_date = getdate(), @package_d = 0, @package_c = 0, @package_a = 0
if @argcode like '9%'
	select @charge = 0, @credit = round(@amount, 2)
else
	begin
	select @charge = round(@amount, 2), @credit = 0
	if @amount1 = 0 and @amount2 = 0 and @amount3 = 0 and @amount4 = 0 and @amount5 = 0
		select @amount1= @charge
	end
select @bdate = bdate1, @selemk = substring(@selemark, 1, 1) from sysdata
if @operation like 'I%'
	select @crradjt = ''
else
	select @crradjt = 'AD'

            
exec @ret = p_gl_accnt_check_limit @accnt, @charge, @credit, @msg out
if @ret = 1
	goto RETURN_1
                                
select @deptno1 = deptno1, @deptno2 = deptno2, @ref = descript, @argcode = isnull(rtrim(@argcode), argcode) from pccode where pccode = @pccode
if @ref is null
	begin
	select @ret = 1, @msg = '系统中还未设费用码' + @pccode + ', 按 F1 有现有费用码输入帮助'
	goto RETURN_1
	end 
                                                                                
select @tor_str = isnull((select value from sysoption where catalog = 'audit' and item = 'deptno_of_tor'), '')
if @deptno2 = 'TOA' or (@deptno2 = 'TOR' and @tor_str != '')
	begin
	select @ret = 1, @msg = '不能使用当前付款方式，请用转账功能'
	goto RETURN_1
	end
                                                        
if @deptno2 = 'TOR' and not rtrim(@araccnt) is null
	begin
	select @tor = 'T'
	select @arname = b.name from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
	select @guestname = name from guest where no = @mode
	end

if @deptno2 = 'PTS'
	begin
	select @vipcard = @selemark, @tor = 'P'
	end
                        
if not rtrim(@reason) is null and not exists (select code from reason where code = @reason)
	begin
	select @ret = 1, @msg = '系统中还未设优惠理由' + @reason + ', 按 F1 有现有优惠理由输入帮助'
	goto RETURN_1
	end 
   
--select @pccodes = '%' + @pccode + '%'
select @pccodes = '%' + rtrim(@pccode) + '%'
select @deptno1 = '%' + rtrim(@deptno1) + '*%'
                    
select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#03#05#15#')
if charindex(@modu_id, @modu_ids) = 0
	begin
	if not exists(select 1 from subaccnt where type = '0' and accnt = @accnt
		and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
		and @log_date >= starting_time and @log_date <= closing_time)
		begin
		select @ret = 1, @msg = '账号(' + @accnt + ')不允许记账,只能现金结算'
		goto RETURN_1
		end 
	end
   
RETURN_1:
if @ret ! = 0
	begin
	if @operation like '_S%'
		select @ret, @msg, 0, 0, @to_accnt
	return @ret
	end
          
begin tran
save tran posting_1
                
update master set sta = sta where accnt = @accnt
select @roomno = roomno from master where accnt = @accnt
if @operation like 'I_Y%' and not @argcode like '9%'
	exec @ret = p_gl_accnt_posting_package @pc_id, @mdi_id, @accnt, @pccode out, @charge out, @package_d out, @package_c out, @package_a out, @bdate, @log_date, @msg out
if @ret != 0
	goto RETURN_2
                                                                        
                                     
if not exists (select name from subaccnt where accnt = @accnt and subaccnt = @subaccnt)
	select @subaccnt = isnull((select max(subaccnt) from subaccnt where type = '5' and accnt = @accnt
		and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
		and @log_date >= starting_time and @log_date <= closing_time), 1)
select @to_accnt = to_accnt from subaccnt where type = '5' and accnt = @accnt and subaccnt = @subaccnt

--增加to_accnt的状态判断，以免O的客人也因ROUTING入帐了  tcr    2004.9.21
if not rtrim(@to_accnt) is null                                                                   
	begin
   select @sta = sta from master where accnt=@to_accnt
	if @sta in ('O','D')
		select @to_accnt = ''           
	end

                                                                              
if @operation like 'I__Y%' and not rtrim(@to_accnt) is null and not (@to_accnt like 'A%' and @tor_str != '')
	begin
	begin tran
	save tran posting_2
	exec @ret = p_gl_accnt_update_balance @to_accnt, @pccode, @charge, @credit, @to_roomno out, 
		@groupno out, @lastnumb out, 0, @balance out, @catalog out, @msg out 
	            
	if @ret != 0
		begin
		rollback tran posting_2
		commit tran
		end
	else
		begin
		                      
		select @to_subaccnt = isnull((select max(subaccnt) from subaccnt where type = '5' and accnt = @to_accnt
			and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
			and @bdate >= starting_time and @bdate <= closing_time), 1)
		insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
			quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
			crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber)
			values(@to_accnt, @to_subaccnt, @lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
			@quantity, @charge, @amount1, @amount2, @amount3, @amount4, @amount5, @package_d, @package_c, @package_a, @credit, @balance, @shift, @empno,
			@crradjt, @waiter, @catalog, @reason, '', @accnt, @subaccnt, @ref, @ref1, @ref2, @roomno, @groupno, @mode, @mode1, @pnumber)
                                                                                                                  
		if @@rowcount = 0
			begin
			rollback tran posting_2
			commit tran 
			end
	  else
			begin
			commit tran
			update package_detail set account_accnt = @to_accnt, account_number = @lastnumb, account_date = @log_date
				where posted_accnt = @accnt and account_accnt = ''
			select @traned = 'T'
			end
		end
	end
                                        
if @traned = 'F'
	begin
	select @to_accnt = null
	exec @ret = p_gl_accnt_update_balance @accnt, @pccode, @charge, @credit, @roomno out, @groupno out, 
		@lastnumb out, 0, @balance out, @catalog out, @msg out
	if @ret = 0 
		begin
		if @operation like 'A%'
			select @lastinumb = @a_number
		insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
			quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
			crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof)
			values(@accnt, @subaccnt, @lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
			@quantity, @charge, @amount1, @amount2, @amount3, @amount4, @amount5, @package_d, @package_c, @package_a, @credit, @balance, @shift, @empno,
			@crradjt, @waiter, @catalog, @reason, @ref, @ref1, @ref2, @roomno, @groupno, @mode, @mode1, @pnumber, @araccnt)
		if @@rowcount = 0
			select @ret =1, @msg = '账务表插入失败'
		else
			begin
			select @ret = 0, @msg = '成功'
			update package_detail set account_accnt = @accnt, account_number = @lastnumb, account_date = @log_date
				where posted_accnt = @accnt and account_accnt = ''
			            
			if @tor = 'T'
				begin
				select @charge = @credit, @credit = 0, @pccode = '', @argcode='', 
					@ref = '客房费用', @ref2 = isnull(@arname, '')+ '(' + isnull(@guestname, '') + ')'
				exec @ret = p_gl_accnt_update_balance @araccnt, @pccode, @charge, @credit, '', '', 
					@lastinumb out, 0, @balance out, @catalog out, @msg out
				insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
					quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
					crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof)
					values(@araccnt, @subaccnt, @lastinumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
					1, @charge, @amount1, @amount2, @amount3, @amount4, @amount5, @package_d, @package_c, @package_a, @credit, @balance, @shift, @empno,
					@crradjt, @waiter, @catalog, @reason, @ref, @ref1, @ref2, @roomno, @groupno, @mode, @mode1, @pnumber, @accnt)
				end
                                                                                       
                                                             
               
                                                                                         
                                                    
                                                                 
			end
		end
	end

-- 使用贵宾卡积分付款
if @deptno2 = 'PTS'
	begin
	select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
 	exec @ret = p_gds_vipcard_posting '', @modu_id, @pc_id, @mdi_id, @shift, @empno, @vipcard, @hotelid, @bdate, '-', @amount, @amount, 0, 0, 0, @quantity, '', @accnt, '','','','R', @ret output, @msg output
	end

RETURN_2:
if @ret ! = 0
	rollback tran posting_1
commit tran
if @operation like '_S%'
	select @ret, @msg, @lastnumb, @balance, isnull(@to_accnt, @accnt)
return @ret;
