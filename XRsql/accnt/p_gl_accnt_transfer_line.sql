if exists(select * from sysobjects where name = 'p_gl_accnt_transfer_line' and type='P')
	drop proc p_gl_accnt_transfer_line;

create proc p_gl_accnt_transfer_line
	@pc_id					char(4), 
	@mdi_id					integer, 
	@shift					char(1), 
	@empno					char(10), 
	@to_accnt				char(10), 
	@to_subaccnt			integer
as
-- 按行转帐 
declare
	@ret						integer, 
	@msg						char(60), 
	@deptno1					char(8), 						-- %05*% 
	@pccodes					char(7), 						-- %004%
	@argcode					char(2),
	@log_date				datetime,						--发生时间
	@bdate					datetime,						--营业日期
	@crradjt					char(2),							--帐务标志
	@pccode					char(5), 
	@credit					money, 
	@charge					money, 
	@roomno					char(5), 
	@to_roomno				char(5), 
	@groupno					char(10), 
	@lastnumb				integer, 
	@lastinumb				integer, 
	@balance					money, 
	@catalog					char(3), 
	@to_lastinumb			integer, 
	@checkout				char(4), 
	@billno					char(10), 
	@number					integer,
	@accnt					char(10),
	@min_accnt				char(10)

--
if exists(select 1 from account_temp a, master b, account c where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 
	and a.accnt = b.accnt and b.sta='R' and a.accnt=c.accnt and a.number=c.number and c.argcode='98' and c.billno='')
begin 
	exec @ret = p_gds_auth_check @empno, 'act!ccuse', 'R', @msg output 
	if @ret<>0	-- 暂时不考虑是否转入同住或者联房 
	begin 
		select @ret = 1, @msg = '权限不足，不能处理预订金'
		goto RETURN_2
	end 	
end 

-- 
if exists(select 1 from account_temp where pc_id = @pc_id and mdi_id = @mdi_id and selected = 1 and accnt = @to_accnt)
	begin
	select @ret = 1, @msg = '源账号与目的账号重复'
	goto RETURN_2
	end
select @log_date = getdate(), @bdate = bdate1 from sysdata
-- 检查目的账号的允许记帐
declare c_locksta cursor for 
	select a.pccode, a.argcode, c.deptno1 from account a, account_temp b, pccode c
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.accnt = b.accnt and a.number = b.number and a.pccode = c.pccode
open c_locksta
fetch c_locksta into @pccode, @argcode, @deptno1
while @@sqlstatus =  0
	begin
	select @pccodes = '%' + rtrim(@pccode) + '%'
	select @deptno1 = '%' + rtrim(@deptno1) + '*%'
	if @argcode < '9' and not exists(select 1 from subaccnt where type = '0' and accnt = @to_accnt
		and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
		and @log_date >= starting_time and @log_date <= closing_time)
		begin
		select @ret = 1, @msg = '账号(%1)不允许记账,只能现金结算^' + @to_accnt
		goto RETURN_2
		end 
	fetch c_locksta into @pccode, @argcode, @deptno1
	end
close c_locksta
deallocate cursor c_locksta
-- 检查目的账号的限额
select @charge = sum(a.charge), @credit = sum(a.credit) from account a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.accnt = b.accnt and a.number = b.number
exec @ret = p_gl_accnt_check_limit @to_accnt, @charge, @credit, @msg out
if @ret = 1
	goto RETURN_2
-- 检查源账号的限额
select @charge = - @charge, @credit = - @credit
exec @ret = p_gl_accnt_check_limit @accnt, @charge, @credit, @msg out
if @ret = 1
	goto RETURN_2
--
begin tran
save tran transfer
exec p_GetAccnt1 @type = 'BIL', @accnt = @billno out
select @billno = 'T' + substring(@billno, 2, 9), @ret = 0
-- 锁住相关账号
update master set sta = sta from account_temp a
	where (a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 and master.accnt = a.accnt) or master.accnt = @to_accnt
--
declare c_number cursor for 
	select a.accnt, a.number, - a.charge, - a.credit, a.pccode, c.deptno1 from account a, account_temp b, pccode c
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.accnt = b.accnt and a.number = b.number and a.pccode = c.pccode
	order by a.accnt, a.number
open c_number
fetch c_number into @accnt, @number, @charge, @credit, @pccode, @deptno1
select @min_accnt = isnull(@accnt, '')
while @@sqlstatus =  0
	begin
	exec @ret = p_gl_accnt_crradjt @accnt, @number, 'LT', @shift, @empno, @msg out
	if @ret = 0 
		begin
		select @crradjt = substring(@msg, 1, 2)
		exec @ret = p_gl_accnt_update_balance @accnt, @pccode, @charge, @credit, @roomno out, 
			@groupno out, @lastnumb out, @lastinumb out, @balance out, @catalog out, @msg out 
		if @ret = 0
			begin
			update account set crradjt = @crradjt, billno = @billno where accnt = @accnt and number = @number and billno = ''
			if @@rowcount = 0
				begin
				select @ret = 1, @msg = '要转的账目[%1--%2]非有效账目，转账失败^' + @accnt+'^'+ltrim(convert(char(10), @number))
				goto RETURN_1
				end
			insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
				quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance,
				shift, empno, crradjt, tofrom, accntof, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, package, billno)
				select accnt, subaccnt, @lastnumb, number, modu_id, @log_date, @bdate, date, pccode, argcode, 
				- quantity, - charge, - charge1, - charge2, - charge3, - charge4, - charge5, - package_d, - package_c, - package_a, - credit, @balance,
				@shift, @empno, @crradjt, 'TO', @to_accnt, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, package, @billno
				from account where accnt = @accnt and number = @number
			if @@rowcount = 0
				begin
				select @ret = 1, @msg = '源帐务表插入失败'
				goto RETURN_1
				end
			else
				begin
				select @credit = @credit * -1, @charge = @charge * -1
				exec @ret = p_gl_accnt_update_balance @to_accnt, @pccode, @charge, @credit, @to_roomno out, 
					@groupno out, @lastnumb out, @lastinumb out, @balance out, @catalog out, @msg out 
				if @ret != 0
					goto RETURN_1
				else
					begin
					select @pccodes = '%' + rtrim(@pccode) + '%'
					select @deptno1 = '%' + rtrim(@deptno1) + '*%'
					if not exists (select name from subaccnt where type = '5' and accnt = @to_accnt and subaccnt = @to_subaccnt)
						select @to_subaccnt = isnull((select max(subaccnt) from subaccnt where type = '5' and accnt = @to_accnt
							and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
							and @bdate >= starting_time and @bdate <= closing_time), 1)
					insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
						quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance,
						shift, empno, crradjt, tofrom, accntof, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, package)
						select @to_accnt, @to_subaccnt, @lastnumb, number, modu_id, @log_date, @bdate, date, pccode, argcode, 
						quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, @balance,
						@shift, @empno, 'LT', 'FM', @accnt, tag, reason, ref, ref1, ref2, roomno, groupno, mode, @billno, pnumber, package
--						@shift, @empno, 'LT', 'FM', @accnt, @catalog, reason, ref, ref1, ref2, @roomno, @groupno, mode, mode1
					from account where accnt = @accnt and number = @number
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
							if exists (select 1 from transfer_log where araccnt = @accnt and arnumber = @number)
								update transfer_log set araccnt = @to_accnt, arnumber = @lastnumb, empno = @empno, date = getdate() 
									where araccnt = @accnt and arnumber = @number
							else
								insert transfer_log (accnt, number, charge, credit, empno, date, araccnt, arnumber)
									select accnt, number, charge, credit, @empno, getdate(), @to_accnt, @lastnumb
									from account where accnt = @accnt and number = @number
							end
						else
							delete transfer_log where araccnt = @accnt and arnumber = @number
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
		end
	fetch c_number into @accnt, @number, @charge, @credit, @pccode, @deptno1
	end
close c_number
deallocate cursor c_number
RETURN_1:
if @ret != 0
	rollback tran transfer
else
	insert billno (billno, accnt, bdate, empno1, shift1) 
		select @billno, @min_accnt, @bdate, @empno, @shift
commit tran
RETURN_2:
select @ret, @msg
return @ret
;

