IF OBJECT_ID('p_gl_accnt_transfer_charge') IS NOT NULL
    DROP PROCEDURE p_gl_accnt_transfer_charge
;
create proc p_gl_accnt_transfer_charge
	@modu_id					char(2),
	@pc_id					char(4),
	@mdi_id					integer,
	@shift					char(1),
	@empno					char(10),
	@pccode					char(5),
	@amount					money,
	@ref1						char(10),
	@ref2						char(50),
	@to_accnt				char(10),
	@to_subaccnt			integer
as
declare
	@ret						integer,
	@msg						char(60),
	@accnt					char(10),
	@subaccnt				integer,
	@argcode					char(3),
	@deptno1					char(8),
	@pccodes					char(7),
	@log_date				datetime,
	@bdate					datetime,
	@ref						char(245),
	@crradjt					char(2),
	@credit					money,
	@charge					money,
	@roomno					char(5),
	@groupno					char(10),
	@lastnumb				integer,
	@lastinumb				integer,
	@balance					money,
	@catalog					char(3),
	@to_roomno				char(5),
	@to_lastnumb			integer,
	@to_lastinumb			integer,
	@billno					char(10)

-- 检查营业代码是否存在
select @deptno1 = deptno1, @ref = descript, @argcode = argcode from pccode where pccode = @pccode
if @@rowcount = 0
	begin
	select @ret = 1, @msg = '系统没有设置营业代码[%1]^' + @pccode 
	goto RETURN_2
	end

if exists(select 1 from account_temp where pc_id = @pc_id and mdi_id = @mdi_id and selected = 1 and accnt = @to_accnt)
	begin
	select @ret = 1, @msg = '源账号与目的账号重复'
	goto RETURN_2
	end
select @log_date = getdate(), @bdate = bdate1 from sysdata
-- 检查目的账号的允许记帐
select @pccodes = '%' + rtrim(@pccode) + '%'
select @deptno1 = '%' + rtrim(@deptno1) + '*%'
if @argcode < '9' and not exists(select 1 from subaccnt where type = '0' and accnt = @to_accnt
	and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
	and @log_date >= starting_time and @log_date <= closing_time)
	begin
	select @ret = 1, @msg = '账号(%1)不允许记账,只能现金结算^' + @to_accnt
	goto RETURN_2
	end
-- 检查目的账号的限额
select @charge = sum(a.charge), @credit = sum(a.credit) from account a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.accnt = b.accnt and a.number = b.number
exec @ret = p_gl_accnt_check_limit @to_accnt, @charge, @credit, @msg out
if @ret = 1
	goto RETURN_2

begin tran
save tran transfer
exec p_GetAccnt1 @type = 'BIL', @accnt = @billno out
select @billno = 'T' + substring(@billno, 2, 9), @ret = 0
-- 锁住相关账号
update master set sta = sta from account_temp a
	where (a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 and master.accnt = a.accnt) or master.accnt = @to_accnt

declare c_number cursor for
	select a.accnt, min(a.subaccnt), - sum(a.charge), - sum(a.credit)
	from account a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.accnt = b.accnt and a.number = b.number
	group by a.accnt
open c_number
fetch c_number into @accnt, @subaccnt, @charge, @credit
while @@sqlstatus =  0
	begin
	-- 检查源账号的限额
	exec @ret = p_gl_accnt_check_limit @accnt, @charge, @credit, @msg out
	if @ret = 1
		goto RETURN_1
	exec @ret = p_gl_accnt_update_balance @accnt, @pccode, @charge, @credit, @roomno out,
		@groupno out, @lastnumb out, @lastinumb out, @balance out, @catalog out, @msg out
	if @ret = 0
		begin
		insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode,
			quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance,
			shift, empno, crradjt, tofrom, accntof, tag, ref, ref1, ref2, roomno, groupno, mode, mode1, billno)
			select @accnt, @subaccnt, @lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @bdate, @pccode, @argcode,
			- 1, @charge - @credit, 0, 0, 0, 0, 0, 0, 0, 0, 0, @balance,
			@shift, @empno, 'CT', 'TO', @to_accnt, @catalog, @ref, @ref1, @ref2, @roomno, @groupno, '', '', @billno
		if @@rowcount = 0
			begin
			select @ret = 1, @msg = '源帐务表插入失败'
			goto RETURN_1
			end
		else																	-- 记目的帐号
			begin
			exec @ret = p_gl_accnt_update_balance @to_accnt, @pccode, @amount, 0, @to_roomno out,
				@groupno out, @to_lastnumb out, @to_lastinumb out, @balance out, @catalog out, @msg out
			if @ret != 0
				goto RETURN_1
			else
				begin
				select @pccodes = '%' + @pccode + '%'
				select @deptno1 = '%' + rtrim(@deptno1) + '*%'
				if not exists (select name from subaccnt where type = '5' and accnt = @to_accnt and subaccnt = @to_subaccnt)
					select @to_subaccnt = isnull((select max(subaccnt) from subaccnt where type = '5' and accnt = @to_accnt
						and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
						and @bdate >= starting_time and @bdate <= closing_time), 1)
				insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode,
					quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance,
					shift, empno, crradjt, tofrom, accntof, tag, ref, ref1, ref2, roomno, groupno, mode, mode1)
					select @to_accnt, @to_subaccnt, @to_lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @bdate, @pccode, @argcode,
					1, @credit - @charge, 0, 0, 0, 0, 0, 0, 0, 0, 0, @balance,
					@shift, @empno, 'CT', 'FM', @accnt, @catalog, @ref, @ref1, @ref2, @roomno, @groupno, '', @billno
				if @@rowcount = 0
					begin
					select @ret = 1, @msg = '目的帐务表插入失败'
					goto RETURN_1
					end
				else
					-- 将转账明细放入transfer_log,以便统计记账收回情况
					begin
					if @to_accnt like 'AR%'
						begin
						if exists (select 1 from transfer_log where araccnt = @accnt and arnumber = @lastnumb)
							update transfer_log set araccnt = @to_accnt, arnumber = @lastnumb, empno = @empno, date = getdate()
								where araccnt = @accnt and arnumber = @lastnumb
						else
							insert transfer_log (accnt, number, charge, credit, empno, date, araccnt, arnumber)
								select accnt, number, - charge, - credit, @empno, getdate(), @to_accnt, @to_lastnumb
								from account where accnt = @accnt and number = @lastnumb
						end
					else
						delete transfer_log where araccnt = @accnt and arnumber = @lastnumb
					--
					select @ret = 0, @msg = @billno
					end
				end
			end
		end
	else
		begin
		rollback tran transfer
		select @ret = 1
		end
	fetch c_number into @accnt, @subaccnt, @charge, @credit
	end
close c_number
deallocate cursor c_number
update account set billno = @billno from account_temp a
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 and account.accnt = a.accnt and account.number = a.number and account.billno = ''
select @balance = sum(charge - credit) from account where billno = @billno
if @balance <> 0
	select @ret = 1, @msg = '转账失败'
RETURN_1:
if @ret != 0
	rollback tran transfer
else
	insert billno (billno, accnt, bdate, empno1, shift1)
		select @billno, min(accnt), @bdate, @empno, @shift
		from account_temp where pc_id = @pc_id and mdi_id = @mdi_id
commit tran
RETURN_2:
select @ret, @msg
return @ret
;
