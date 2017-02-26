-- 由 p_gl_accnt_cancel_account 调用冲销指定账目
 
if exists(select * from sysobjects where name = 'p_gl_ar_cancel_account')
	drop proc p_gl_ar_cancel_account
;
create proc p_gl_ar_cancel_account		
	@accnt				char(10), 
	@number				integer, 
	@shift				char(1), 
	@empno				char(10),
	@msg					char(60)		out
as
----------------------------------------------------------
-- 输入参数确保非NULL, 包括费用和款项 
----------------------------------------------------------
declare
	@ret					integer, 
	@bdate				datetime, 					--营业日期
	@log_date			datetime,
	@package_date		datetime,
	@crradjt				char(2), 					--账务标志
	@pccode				char(5), 
	@waiter				char(3), 
	@credit				money, 
	@charge				money, 
	@credit9				money, 
	@charge9				money, 
	@package_d			money, 
	@roomno				char(5), 
	@groupno				char(10), 
	@lastnumb			integer, 
	@lastinumb			integer, 
	@balance				money, 
	@catalog				char(3), 
	@billno				char(10),
	@pos					integer,
	@amount				money,
	@ref					varchar(24),
	@ref1					varchar(10),
	@ref2					varchar(50),
	@cardtype			char(10), 
	@cardno 				char(20), 
	@cardar				char(10),
	@id					char(10),
	@deptno2				char(5),
	@araccnt				char(10), 
	@artag1				char(1),
	@artag1s				char(40),
	@araudit				char(1),
	@arnumber			integer,
	@arinumber			integer, 
	@arlastnumb			integer,
	@arlastinumb		integer, 
	@arbalance			money, 
	@arref2				char(50),			-- 摘要
	@arsubaccnt			integer, 
	@status				char(1),
	@option				char(2),
	@subaccnt			integer, 
	@guestname			varchar(50), 
	@guestname2			varchar(50), 
	@modu_id				char(2),
	@quantity			money,
	@hotelid 			varchar(20),
	@arcreditcard		char(1)

select @ret = 0, @bdate = bdate1, @log_date = getdate() from sysdata
select @arcreditcard = isnull((select value from sysoption where catalog = 'ar' and item = 'creditcard'), 'F')
begin tran
save tran cancel
select @credit = - credit, @araccnt = accntof, @pccode = pccode, @waiter = waiter
	from account where accnt = @accnt and number = @number
if @arcreditcard = 'F' and exists (select 1 from bankcard where pccode = @pccode)
	goto RETURN_1
-- 信用卡(要临时取账号)
else if exists (select 1 from bankcard where pccode = @pccode)
	begin
	select @araccnt = accnt from bankcard where pccode = @pccode and bankcode = @waiter
	select @araudit = '2'
	end
else
-- AR账
	begin
	select @artag1 = a.artag1 from ar_master a where a.accnt = @araccnt
-- 这个判断取消，必须审核 2007.9.18 simon 
--	select @artag1s = isnull((select value from sysoption where catalog = 'ar' and item = 'artag1_of_need_transfer'), '')
--	if charindex(@artag1, @artag1s) > 0
		select @araudit = '0'
--	else
--		select @araudit = '1'
	end
update ar_master set sta = sta where accnt = @araccnt
select @arinumber = ar_inumber, @arnumber = ar_number, @charge9 = charge9, @credit9 = credit9
	from ar_account where ar_accnt = @araccnt and ar_tag = 'P' and accnt = @accnt and number = @number
if @@rowcount = 0
--	select @ret = 1, @msg = '原始AR账务有错'+@accnt+ @araccnt+convert(char(10), @number)
	select @ret = 1, @msg = 'AR账务已被压缩, 不能冲账'
else if @charge9 != 0 or @credit9 != 0
	select @ret = 1, @msg = 'AR账务已被核销过, 不能冲账'
else
	begin
	select @status = audit from ar_detail where accnt = @araccnt and number = @arinumber
	if @araudit = @status
	-- 原始AR账务还没有审核
		begin
		exec @ret = p_gl_ar_update_balance @araccnt, @credit, 0, 0, @arlastinumb out, @arbalance out, 'NY', @msg out
		select @arlastnumb = @arinumber
		end
	else
	-- 原始AR账务已审核
		exec @ret = p_gl_ar_update_balance @araccnt, @credit, 0, @arlastnumb out, @arlastinumb out, @arbalance out, 'YY', @msg out
	if @ret = 0 
		begin
		insert ar_account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
			quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
			crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof,
			ar_accnt, ar_subaccnt, ar_number, ar_inumber, ar_tag, charge9, credit9)
			select accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
			- quantity, - charge, - charge1, - charge2, - charge3, - charge4, - charge5, - package_d, - package_c, - package_a,  -credit, balance, shift, empno,
			crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof,
			ar_accnt, ar_subaccnt, @arlastinumb, @arlastnumb, ar_tag, 0, 0
			from ar_account where ar_accnt = @araccnt and ar_number = @arnumber
		if @@rowcount = 0
			select @ret = 1, @msg = 'AR账务表插入失败'
		else
			begin
			select @ret = 0, @msg = '成功'
			if @araudit = @status
				update ar_detail set quantity = quantity + @credit, charge = charge + @credit
					where accnt = @araccnt and number = @arlastnumb
			else
				insert ar_detail(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, accntof, subaccntof, 
					quantity, charge, credit, balance, shift, empno, crradjt, roomno, tag, reason, guestname, guestname2, ref, ref1, ref2, audit)
					select accnt, subaccnt, @arlastnumb, @number, modu_id, log_date, bdate, date, pccode, argcode, accntof, subaccntof, 
					quantity, @credit, 0, balance, shift, empno, crradjt, roomno, tag, reason, guestname, guestname2, ref, ref1, ref2, @araudit
					from ar_detail where accnt = @araccnt and number = @arinumber
			end
		end
	end
RETURN_1:
if @ret != 0
	rollback tran cancel
commit tran
return @ret
;
