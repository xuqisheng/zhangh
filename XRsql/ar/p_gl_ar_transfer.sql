if exists(select * from sysobjects where name = 'p_gl_ar_transfer' and type='P')
	drop proc p_gl_ar_transfer;

create proc p_gl_ar_transfer
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
	@default_deptno1		char(5),
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
	@to_guestname			char(50),
	@groupno					char(7), 
	@lastnumb				integer, 
	@lastinumb				integer, 
	@balance					money, 
	@catalog					char(3), 
	@to_lastnumb			integer, 
	@to_lastinumb			integer, 
	@billno					char(10), 
	@accnt					char(10),
	@guestname				char(50),
	@subaccnt				integer,
	@number					integer,
	@inumber					integer,
	@last_inumber			integer

if @to_accnt not like 'A%'  -- 禁止转帐到前台 gds 2008.4.22 
	begin
	select @ret = 1, @msg = '只能转到AR帐户'
	goto RETURN_2
	end
if exists(select 1 from account_temp where pc_id = @pc_id and mdi_id = @mdi_id and selected = 1 and accnt = @to_accnt)
	begin
	select @ret = 1, @msg = '源账号与目的账号重复'
	goto RETURN_2
	end
if exists(select 1 from account_temp a, ar_detail b
	where pc_id = @pc_id and mdi_id = @mdi_id and a.selected = 1 and a.accnt = b.accnt and a.number = b.number and b.audit in ('0', '2'))
	begin
	select @ret = 1, @msg = '未审核账目不能转账'
	goto RETURN_2
	end
select @log_date = getdate(), @bdate = bdate1, @last_inumber = 0 from sysdata
select @default_deptno1 = (select min(code) from basecode where cat = 'chgcod_deptno1')
-- 检查目的账号的允许记帐
--declare c_locksta cursor for 
--	select a.pccode, a.argcode, c.deptno1 from ar_detail a, account_temp b, pccode c
--		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.accnt = b.accnt and a.number = b.number and a.pccode = c.pccode
--open c_locksta
--fetch c_locksta into @pccode, @argcode, @deptno1
--while @@sqlaudit =  0
--	begin
--	select @pccodes = '%' + rtrim(@pccode) + '%'
--	select @deptno1 = '%' + rtrim(@deptno1) + '*%'
--	if @argcode < '9' and not exists(select 1 from subaccnt where type = '0' and accnt = @to_accnt
--		and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
--		and @log_date >= starting_time and @log_date <= closing_time)
--		begin
--		select @ret = 1, @msg = '账号(' + @to_accnt + ')不允许记账,只能现金结算'
--		goto RETURN_2
--		end 
--	fetch c_locksta into @pccode, @argcode, @deptno1
--	end
--close c_locksta
--deallocate cursor c_locksta
-- 检查目的账号的限额
select @charge = sum(a.charge), @credit = sum(a.credit) from ar_detail a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.accnt = b.accnt and a.number = b.number
if @to_accnt like 'A%'
	exec @ret = p_gl_ar_check_limit @to_accnt, @charge, @credit, @msg out
else
	exec @ret = p_gl_accnt_check_limit @to_accnt, @charge, @credit, @msg out
if @ret = 1
	goto RETURN_2
-- 检查源账号的限额
select @charge = - @charge, @credit = - @credit
exec @ret = p_gl_ar_check_limit @accnt, @charge, @credit, @msg out
if @ret = 1
	goto RETURN_2
--
begin tran
save tran transfer
exec p_GetAccnt1 @type = 'BIL', @accnt = @billno out
select @billno = 'T' + substring(@billno, 2, 9), @ret = 0
-- 锁住相关账号
if @to_accnt like 'A%'
	begin
	update ar_master set sta = sta from account_temp a where ar_master.accnt = a.accnt or ar_master.accnt = @to_accnt
	select @to_guestname = b.name from ar_master a, guest b where a.accnt = @to_accnt and a.haccnt = b.no
	end
else
	begin
	update ar_master set sta = sta from account_temp a where ar_master.accnt = a.accnt
	update master set sta = sta from account_temp a where master.accnt = @to_accnt
	select @to_guestname = b.name, @to_roomno = a.roomno from master a, guest b where a.accnt = @to_accnt and a.haccnt = b.no
	end
-- 插明细账
declare c_number cursor for 
	select e.name, a.ar_accnt, a.ar_subaccnt, a.ar_number, a.ar_inumber, - b.charge, - b.credit, a.pccode, isnull(c.deptno1, @default_deptno1)
	from ar_account a, account_temp b, pccode c, ar_master d, guest e
	where b.pc_id = @pc_id and b.mdi_id = - @mdi_id and b.selected = 1 and a.ar_accnt = b.accnt and a.ar_number = b.number
	and a.ar_accnt = d.accnt and d.haccnt = e.no and a.pccode *= c.pccode
	order by a.ar_accnt, a.ar_inumber, a.ar_number
open c_number
fetch c_number into @guestname, @accnt, @subaccnt, @number, @inumber, @charge, @credit, @pccode, @deptno1
while @@sqlstatus =  0
	begin
	if @charge != 0 or @credit != 0
		begin
		select @crradjt = 'LT'
		exec @ret = p_gl_ar_update_balance @accnt, @charge, @credit, @lastnumb out, @lastinumb out, @balance out, 'NY', @msg out
		if @ret = 0
			begin
			update ar_detail set charge0 = charge0 + @charge, credit0 = credit0 + @credit where accnt = @accnt and number = @inumber
			insert ar_account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
				quantity, charge, charge1, credit, balance, shift, empno, crradjt, waiter, tag, reason, ref, ref1, ref2,
				mode, mode1, pnumber, tofrom, accntof, billno, ar_accnt, ar_subaccnt, ar_number, ar_inumber, ar_pnumber, ar_tag)
				select @accnt, subaccnt, @lastinumb, @number, modu_id, @log_date, @bdate, date, pccode, argcode, 
				quantity, @charge, @charge, @credit, @balance, @shift, @empno, @crradjt, '', @catalog, '', ref, @billno,
				'Transfer to ' + isnull(rtrim(@to_roomno), @to_accnt) + '/' + @to_guestname,
				'', mode1, pnumber, 'TO', @to_accnt, @billno, @accnt, @subaccnt, @lastinumb, @inumber, ar_pnumber, 'T'
				from ar_account where ar_accnt = @accnt and ar_number = @number
			if @@rowcount = 0
				begin
				select @ret = 1, @msg = '源帐务表插入失败'
				goto RETURN_1
				end
			else
				begin
				select @charge = - @charge, @credit = - @credit
				-- 转到应收账
				if @to_accnt like 'A%'
					begin
					if @last_inumber != @inumber
						begin
						-- 插汇总账
						exec @ret = p_gl_ar_update_balance @to_accnt, 0, 0, @to_lastnumb out, @to_lastinumb out, @balance out, 'YY', @msg out 
						if @ret = 0
							begin
							insert ar_detail(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, audit, 
								shift, empno, crradjt, tag, tofrom, accntof, reason, guestname, guestname2, ref, ref1, ref2)
								select @to_accnt, @to_subaccnt, @to_lastnumb, @number, modu_id, @log_date, @bdate, date, pccode, argcode, audit, 
								shift, empno, crradjt, 'T', 'FM', @accnt, reason, guestname, guestname2, ref, @billno, 'Transfer from ' + @guestname
								from ar_detail where accnt = @accnt and number = @inumber
							insert ar_account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
								shift, empno, crradjt, waiter, tag, reason, ref, ref1, ref2,
								mode, mode1, pnumber, tofrom, accntof, ar_accnt, ar_subaccnt, ar_number, ar_inumber, ar_tag, ar_subtotal)
								select @to_accnt, @to_subaccnt, @to_lastinumb, @to_lastinumb, modu_id, @log_date, @bdate, date, pccode, argcode, 
								@shift, @empno, @crradjt, '', 'T', '', ref, @billno, 'Transfer from ' + isnull(rtrim(@guestname), '') + '/' + ref2,
								'', mode1, pnumber, 'FM', @accnt, @to_accnt, @to_subaccnt, @to_lastinumb, @to_lastnumb, 'T', 'T'
								from ar_account where ar_accnt = @accnt and ar_number = @number
							if @@rowcount = 0
								begin
								select @ret = 1, @msg = '目的帐务表插入失败'
								goto RETURN_1
								end
							end
						end
					update ar_detail set charge0 = charge0 + @charge, credit0 = credit0 + @credit where accnt = @to_accnt and number = @to_lastnumb
					update ar_account set charge = charge + @charge, charge1 = charge1 + @charge, credit = credit + @credit where ar_accnt = @to_accnt and ar_number = @to_lastinumb
					exec @ret = p_gl_ar_update_balance @to_accnt, @charge, @credit, @lastnumb out, @lastinumb out, @balance out, 'NY', @msg out 
					if @ret = 0
						begin
						insert ar_account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
							quantity, charge, charge1, credit, balance, shift, empno, crradjt, waiter, tag, reason, ref, ref1, ref2,
							mode, mode1, pnumber, tofrom, accntof, ar_accnt, ar_subaccnt, ar_number, ar_inumber, ar_pnumber, ar_tag)
							select @to_accnt, @to_subaccnt, @lastinumb, @lastnumb, modu_id, @log_date, @bdate, date, pccode, argcode, 
							quantity, @charge, @charge, @credit, @balance, @shift, @empno, @crradjt, '', '', '', ref, @billno, ref2,
							'', mode1, pnumber, 'FM', @accnt, @to_accnt, @to_subaccnt, @lastinumb, @to_lastnumb, @to_lastinumb, 't'
							from ar_account where ar_accnt = @accnt and ar_number = @number
						if @@rowcount = 0
							begin
							select @ret = 1, @msg = '目的帐务表插入失败'
							goto RETURN_1
							end
						end
					select @last_inumber = @inumber
					end
				-- 转到前台
				else
					begin
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
						from ar_account where ar_accnt = @accnt and ar_number = @number
						if @@rowcount = 0
							begin
							select @ret = 1, @msg = '目的帐务表插入失败'
							goto RETURN_1
							end
						end
					end
				end
			end
		end
	fetch c_number into @guestname, @accnt, @subaccnt, @number, @inumber, @charge, @credit, @pccode, @deptno1
	end
close c_number
deallocate cursor c_number
RETURN_1:
if @ret != 0
	rollback tran transfer
else
	begin
	select @ret = 0, @msg = @billno
	insert billno (billno, accnt, bdate, empno1, shift1) select @billno, min(accnt), @bdate, @empno, @shift
		from account_temp where pc_id = @pc_id and mdi_id = @mdi_id
	end
commit tran
RETURN_2:
select @ret, @msg
return @ret
;
