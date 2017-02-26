if exists(select * from sysobjects where name = "p_gl_ar_audit")
	drop proc p_gl_ar_audit
;
create proc p_gl_ar_audit
	@pc_id				char(4),
	@mdi_id				integer,
	@accnt				char(10),					-- 账号
	@number				integer,						-- 账次
	@empno				char(10),
	@shift				char(1),
	@option				char(2)						-- 选项
as
-------------------------------------------------------
-- AR帐务审核 
-------------------------------------------------------

declare
	@subaccnt			integer,
	@ar_number			integer,
	@billno				char(10),
	@count				integer,
	@caccnt				char(10),
	@cnumber				integer,
	@charge				money,
	@credit				money,
	@lastnumb			integer,
	@lastinumb			integer,
	@balance				money,
	@log_date			datetime,
	@ret					integer,
	@msg					varchar(60)

if exists (select 1 from ar_detail where accnt = @accnt and number = @number and audit = '1')
	begin
	select @ret = 1, @msg = '当前账务已被审核'
	goto RETURN_2
	end
if exists (select 1 from ar_audit where pc_id = @pc_id and mdi_id = @mdi_id and type = 'T' and argcode>='9')
	begin
	select @ret = 1, @msg = '审核帐务不允许出现付款，请使用【总额汇总】方法审核'
	goto RETURN_2
	end
select @log_date = getdate(), @ret = 0, @msg = ''
select @billno = min(billno), @count = count(distinct billno), @charge = sum(charge), @credit = sum(credit) from ar_audit
	where pc_id = @pc_id and mdi_id = @mdi_id and type = 'T'
declare c_audit cursor for select accnt, number, charge, credit from ar_audit
	where pc_id = @pc_id and mdi_id = @mdi_id and type = 'T' order by accnt, number
begin tran
save tran audit_1
update ar_detail set audit = '1', charge = @charge, credit = @credit, billno = @billno, empno0 = @empno, date0 = @log_date, shift0 = @shift
	where accnt = @accnt and number = @number

update ar_account set charge = @charge, charge1 = @charge, charge2 = 0, charge3 = 0, charge4 = 0, charge5 = 0, credit = @credit,
	billno = @billno, empno0 = @empno, date0 = @log_date, shift0 = @shift, ar_subtotal = 'T'
	where ar_accnt = @accnt and ar_inumber = @number and ar_tag = 'P'
select @subaccnt = ar_subaccnt, @ar_number = ar_number
	from ar_account where ar_accnt = @accnt and ar_inumber = @number
--
open c_audit
fetch c_audit into @caccnt, @cnumber, @charge, @credit
while @@sqlstatus = 0
	begin
	if @charge != 0 or @credit != 0
		begin
		exec @ret = p_gl_ar_update_balance @accnt, 0, 0, 0, @lastnumb out, @balance out, 'NY', @msg out
		if @ret != 0 
			goto RETURN_1
		insert ar_account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
			quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
			crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, billno, 
			ar_accnt, ar_subaccnt, ar_number, ar_inumber, ar_tag, ar_pnumber)
			select accnt, subaccnt, number, inumber, modu_id, getdate(), bdate, date, pccode, argcode, 
			quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
			crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, billno, 
			@accnt, @subaccnt, @lastnumb, @number, 'p', @ar_number
			from ar_audit where pc_id = @pc_id and mdi_id = @mdi_id and type = 'T' and accnt = @caccnt and number = @cnumber
		end
	fetch c_audit into @caccnt, @cnumber, @charge, @credit
	end 
close c_audit
deallocate cursor c_audit
--
RETURN_1:
if @ret ! = 0
	rollback tran audit_1
commit tran
RETURN_2:
select @ret, @msg
return 0
;
