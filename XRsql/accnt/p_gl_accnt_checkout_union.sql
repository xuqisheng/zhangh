
if  exists(select * from sysobjects where name = 'p_gl_accnt_checkout_union')
	drop proc p_gl_accnt_checkout_union;

create proc p_gl_accnt_checkout_union
	@pc_id				char(4), 
	@shift				char(1), 
	@empno				char(10), 
	@master_accnt		char(10), 
	@accnt				char(10), 
	@waiter				char(3), 
	@billno				char(10), 
	@credit				money out,				--
   @msg  		      varchar(60) out      --返回信息
as
-- 处理合并结帐pccode = '9'
declare
	@modu_id				char(2), 
	@subaccnt			integer, 
	@argcode		char(2), 
	@quantity			integer, 
	@ret					integer, 
	@bdate				datetime,	 			--营业日期
	@ref					char(24),				--付款码大类说明
	@paycode				char(5), 				--付款方式内部码
	@paymth				char(5), 				--付款方式内部码
	@pccode				char(5), 				--费用代码
	@c_billno			char(8), 
	@roomno				char(5), 
	@groupno				char(10), 
	@lastnumb			integer, 
	@lastinumb			integer, 
	@to_lastnumb		integer, 
	@to_lastinumb		integer, 
	@charge				money, 
	@balance				money, 
	@catalog				char(3), 
	@crradjt				char(2)

select @ret = 0, @msg = isnull((select value from sysoption where catalog = 'account' and item = 'invalid'), '-ODEXW')
select @bdate = bdate1 from sysdata
select @modu_id = '02', @pccode = '9', @subaccnt = 1, @argcode = '99', @charge = 0, @quantity = 1, @crradjt = 'CT', @paycode = '', @paymth = ''
begin tran
save tran p_gl_accnt_checkout_union_s1

update master set sta = sta where accnt = @master_accnt or accnt = @accnt
select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), '-ODEXW')
exec @ret = p_gl_accnt_update_balance @master_accnt, @pccode, @charge, @credit, @roomno out, @groupno out, 
	@lastnumb out, @lastinumb out, @balance out, @catalog out, @msg out
if @ret = 0
	begin
	insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
		quantity, credit, balance, shift, empno, tag, crradjt, tofrom, accntof, subaccntof, 
		ref, ref1, ref2, roomno, groupno, mode, mode1, billno)
		values(@master_accnt, @subaccnt, @lastnumb, @lastnumb, @modu_id, getdate(), @bdate, @bdate, @pccode, @argcode, 
		@quantity, @credit, @balance, @shift, @empno, @catalog, @crradjt, 'TO', @accnt, @subaccnt, 
		'结帐付款--合并结帐', '', '为' + @accnt + '付款', @roomno, @groupno, '', '', @billno)
	if @@rowcount !=  0
		begin
		select @credit = @credit * -1
		select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'valid_sta'), 'HISR')
		exec @ret = p_gl_accnt_update_balance @accnt, @pccode, @charge, @credit, @roomno out, @groupno out, 
			@to_lastnumb out, @to_lastinumb out, @balance out, @catalog out, @msg out
		if @ret != 0
			begin
			rollback tran p_gl_accnt_checkout_union_s1
			select @ret = 1
			end
		else
			begin
			insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
				quantity, credit, balance, shift, empno, tag, crradjt, tofrom, accntof, subaccntof, 
				ref, ref1, ref2, roomno, groupno, mode, mode1, billno)
				values(@accnt, @subaccnt, @to_lastnumb, @lastnumb, @modu_id, getdate(), @bdate, @bdate, @pccode, @argcode, 
				@quantity, @credit, @balance, @shift, @empno, @catalog, @crradjt, 'FM', @master_accnt, @subaccnt, 
				'结帐付款--合并结帐', '', '由' + @master_accnt + '付款', @roomno, @groupno, '', '', @billno)
			if @@rowcount = 0
				begin
				select @ret = 1, @msg = '帐务表插入失败'
				rollback tran p_gl_accnt_checkout_union_s1
				end
			else
				select @ret = 0, @msg = '成功', @credit = 0
			end
		end
	else
		begin
		select @ret = 1, @msg = '帐务表插入失败'
		rollback tran p_gl_accnt_checkout_union_s1
		end
	end
else
	begin
	rollback tran p_gl_accnt_checkout_union_s1
	select @ret = 1
	end
commit tran 
return @ret
;
