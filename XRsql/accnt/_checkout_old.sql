/*  */

if exists(select * from sysobjects where name = 'p_gl_accnt_checkout')
	drop proc p_gl_accnt_checkout;

create proc p_gl_accnt_checkout
	@pc_id				char(4), 
	@mdi_id				integer, 
	@roomno				char(5), 
	@accnt				char(10), 
	@subaccnt			integer, 
	@operation			char(10), 
	@newsta				char(1), 
	@shift				char(1),
	@empno				char(10)

as
declare
	@bdate				datetime, 
	@billno				char(10),
	@master_accnt		char(10), 
//	@accnt				char(10), 
	@newnum				integer, 
	@number				integer, 
	@inumber				integer, 
	@pnumber				integer, 
	@pccode				char(2), 
	@servcode			char(1), 
	@code					char(3), 
	@charge				money, 
	@credit				money, 
	@crradjt				char(2), 
	@waiter				char(3), 
	@tofrom				char(2), 
	@cbillno				char(10), 
//	@roomno				char(5), 
	@groupno				char(7), 
	@catalog				char(3), 
	@lastnumb			integer, 
	@lastinumb			integer, 
	@lastpnumb			integer, 
	@to_lastnumb		integer, 
	@to_lastinumb		integer, 
	@balance				money, 
	@withit				char(1), 
	@retmsg				varchar(60), 
	@msg					varchar(60), 
	@ret					integer,
	@_pnumber			integer,
	@_log_date			datetime, 
	@log_date			datetime

//if (select count(1) from accthead where canpartout = 'T') = 0
//	begin
//	select @ret = 1, @msg = '夜间稽核处于关键区, 暂时还不能进行部分结帐'
//	select @ret, @msg
//	return @ret
//	end
if @operation = "SELECTED"
	select @charge = sum(a.charge), @credit = sum(a.credit) from account a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and b.accnt = a.accnt and b.number = a.number
else
	select @charge = sum(a.charge), @credit = sum(a.credit) from account a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
if @charge != @credit
	begin
	select @ret = 1, @msg = '帐未结平'
	select @ret, @msg
	return @ret
	end

select @bdate = bdate1, @ret = 0 from sysdata
begin tran
save  tran p_gl_accnt_partout_s1
exec p_GetAccnt1 @type = 'BIL', @accnt = @billno out
select @billno = 'B' + substring(@billno, 2, 9)
/* Part 1 平账、设置结账标志 */
declare c_account cursor for
	select a.accnt, a.number, a.charge, a.credit, a.billno from account a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number order by accnt, number 
open c_account
fetch c_account into @accnt, @number, @charge, @credit, @cbillno
while @@sqlstatus = 0
	begin
		if @cbillno != ''
			begin
			select @ret = 1, @msg  = @accnt + @cbillno + '的第' + rtrim(convert(char(10), @number)) + '行帐不能被部分结帐'
			goto RET_P1
			end
		else
			begin
//			update account set billno = @billno, waiter = 'OUT'
//				where accnt = @accnt and number = @number
			update account set billno = @billno where accnt = @accnt and number = @number
			// 将转账明细放入transfer_log,以便统计记账收回情况)
			update transfer_log set archarge = charge, arcredit = credit, arempno = @empno, ardate = getdate(), billno = @billno
				where araccnt = @accnt and arnumber = @number
			end
//		if charindex(@pccode, '03,05,06') > 0
//			/* 转销定金 */
//			begin
//			select @credit = b.credit - a.credit from account a, partout b
//				where a.accnt = @accnt and a.number = @number and a.accnt = b.accnt and a.number = b.number
//			if @credit != 0
//				begin
//				select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), '-ODEX')
//				exec @ret = p_hry_update_mstblncs 'A', 0, @accnt, @code, @charge, @credit, @roomno out, @groupno out, @lastnumb out, @lastinumb out, @balance out, @catalog out, @msg out 
//				if @ret = 0
//					begin
//					insert account(accnt, number, inumber, date, pccode, servcode, charge, credit, 
//						balance, shift, empno, tag, tag1, crradjt, ref, ref1, ref2, roomno, tofrom, accntof, 
//						groupno, bdate, modu_id, checkout, waiter, mode, package, pnumber, billno)
//						select @accnt, @lastnumb, @number, date, pccode, 'B', @charge, @credit, 
//						@balance, shift, empno, tag, tag1, 'AD', '调整定金', ref1, ref2, roomno, tofrom, accntof, 
//						groupno, bdate, modu_id, '    ', 'OUT', mode, package, @pnumber, @billno
//						from partout where accnt = @accnt  and checkout = @pc_id and number = @number
//					select @credit = @credit * -1, @pccode = '05', @servcode = 'A', @code = '05A'
//					select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), '-OEDX')
//					exec @ret = p_hry_update_mstblncs 'A', 0, @accnt, @code, @charge, @credit, @roomno out, @groupno out, @to_lastnumb out, @to_lastinumb out, @balance out, @catalog out, @msg out 
//					if @ret = 0
//						begin
//						insert account(accnt, number, inumber, date, pccode, servcode, charge, credit, 
//							balance, shift, empno, tag, tag1, crradjt, ref, ref1, ref2, roomno, tofrom, accntof, 
//							groupno, bdate, modu_id, package, pnumber)
//							select @accnt, @to_lastnumb, @lastnumb, date, @pccode, @servcode, @charge, @credit, 
//							@balance, shift, empno, tag, tag1, 'AD', '剩余定金', ref1, ref2, roomno, tofrom, accntof, 
//							groupno, bdate, modu_id, ' ' + @pccode, @pnumber
//							from partout where accnt = @accnt and checkout = @pc_id and number = @number
///* GaoLiang 2000/12/02 for 四川锦江(将转账明细放入transfer_log,以便统计记账收回情况) */
//						if exists (select 1 from transfer_log a, partout b where b.accnt = @accnt and 
//							b.checkout = @pc_id and b.number = @number and a.araccnt = b.accnt and a.arnumber = b.number)
//							begin
//							insert transfer_log (accnt, number, charge, credit, empno, date, araccnt, arnumber, archarge, arcredit, arempno, ardate, billno)
//								select b.accnt, b.number, @charge * -1, @credit * -1, @empno, getdate(), 
//								b.araccnt, @lastnumb, @charge * -1, @credit * -1, @empno, getdate(), @billno
//								from partout a, transfer_log b
//								where a.accnt = @accnt and a.number = @number and a.accnt = b.araccnt and a.number = b.arnumber
//							insert transfer_log (accnt, number, charge, credit, empno, date, araccnt, arnumber)
//								select b.accnt, b.number, @charge, @credit, @empno, getdate(), b.araccnt, @to_lastnumb
//								from partout a, transfer_log b
//								where a.accnt = @accnt and a.number = @number and a.accnt = b.araccnt and a.number = b.arnumber
//							end
///* End for GaoLiang 2000/12/02 */
//						end
//					else
//						begin
//						select @msg  = rtrim(@msg)+', 转销定金失败'
//						goto RET_P1
//						end
//					end
//				else
//					begin
//					select @msg  = rtrim(@msg)+', 转销定金失败'
//					goto RET_P1
//					end
//				end
//			end
//		else
//			/* 拆分帐务 */
//			begin
//			select @charge = b.charge - a.charge from account a, partout b
//				where a.accnt = @accnt and a.number = @number and a.accnt = b.accnt and a.number = b.number
//			if @charge != 0
//				begin
//				select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), '-ODEX')
//				exec @ret = p_hry_update_mstblncs 'A', 0, @accnt, @code, @charge, @credit, @roomno out, @groupno out, @lastnumb out, @lastinumb out, @balance out, @catalog out, @msg out 
//				if @ret = 0
//					begin
//					insert account(accnt, number, inumber, date, pccode, servcode, charge, credit, 
//						balance, shift, empno, tag, tag1, crradjt, ref, ref1, ref2, roomno, tofrom, accntof, 
//						groupno, bdate, modu_id, checkout, waiter, package, pnumber, billno)
//						select @accnt, @lastnumb, @number, date, pccode, servcode, @charge, @credit, 
//						@balance, shift, empno, tag, tag1, 'AD', ref, '调整帐务', ref2, roomno, tofrom, accntof, 
//						groupno, bdate, modu_id, '    ', 'OUT', ' ' + @pccode, @pnumber, @billno
//						from partout where accnt = @accnt  and checkout = @pc_id and number = @number
//					select @charge = @charge * -1
//					select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), '-OEDX')
//					exec @ret = p_hry_update_mstblncs 'A', 0, @accnt, @code, @charge, @credit, @roomno out, @groupno out, @to_lastnumb out, @to_lastinumb out, @balance out, @catalog out, @msg out 
//					if @ret = 0
//						begin
//						insert account(accnt, number, inumber, date, pccode, servcode, charge, credit, 
//							balance, shift, empno, tag, tag1, crradjt, ref, ref1, ref2, roomno, tofrom, accntof, 
//							groupno, bdate, modu_id, package, pnumber)
//							select @accnt, @to_lastnumb, @lastnumb, date, pccode, servcode, @charge, @credit, 
//							@balance, shift, empno, tag, tag1, 'AD', ref, '剩余帐务', ref2, roomno, tofrom, accntof, 
//							groupno, bdate, modu_id, package, @pnumber
//							from partout where accnt = @accnt and checkout = @pc_id and number = @number
///* GaoLiang 2000/12/02 for 四川锦江(将转账明细放入transfer_log,以便统计记账收回情况) */
//						if exists (select 1 from transfer_log a, partout b where b.accnt = @accnt and 
//							b.checkout = @pc_id and b.number = @number and a.araccnt = b.accnt and a.arnumber = b.number)
//							begin
//							insert transfer_log (accnt, number, charge, credit, empno, date, araccnt, arnumber, archarge, arcredit, arempno, ardate, billno)
//								select b.accnt, b.number, @charge * -1, @credit * -1, @empno, getdate(), 
//								b.araccnt, @lastnumb, @charge * -1, @credit * -1, @empno, getdate(), @billno
//								from partout a, transfer_log b
//								where a.accnt = @accnt and a.number = @number and a.accnt = b.araccnt and a.number = b.arnumber
//							insert transfer_log (accnt, number, charge, credit, empno, date, araccnt, arnumber)
//								select b.accnt, b.number, @charge, @credit, @empno, getdate(), b.araccnt, @to_lastnumb
//								from partout a, transfer_log b
//								where a.accnt = @accnt and a.number = @number and a.accnt = b.araccnt and a.number = b.arnumber
//							end
///* End for GaoLiang 2000/12/02 */
//						end
//					else
//						begin
//						select @msg  = rtrim(@msg)+', 拆分帐务失败'
//						goto RET_P1
//						end
//					end
//				else
//					begin
//					select @msg  = rtrim(@msg)+', 拆分帐务失败'
//					goto RET_P1
//					end
//				end
//			end
//		end
//	else
//		begin
//		select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), '-ODEX')
//		exec @ret = p_hry_update_mstblncs 'A', 0, @accnt, @code, @charge, @credit, @roomno out, @groupno out, @lastnumb out, @lastinumb out, @balance out, @catalog out, @msg out 
//		if @ret = 0
//			begin
//			if @number = @pnumber or @pnumber = 0
//				select @lastpnumb = @lastnumb, @log_date = getdate()
//			else
//				select @lastpnumb = @_pnumber, @log_date = @_log_date
//			select @_pnumber = @lastpnumb, @_log_date = @log_date
//			insert account(accnt, number, inumber, date, pccode, servcode, charge, credit, 
//				balance, shift, empno, tag, tag1, crradjt, ref, ref1, ref2, roomno, log_date, 
//				groupno, bdate, modu_id, checkout, waiter, mode, package, pnumber, billno)
//				select @accnt, @lastnumb, @lastnumb, date, pccode, servcode, @charge, @credit, 
//				@balance, shift, empno, tag, tag1, crradjt, ref, ref1, ref2, roomno, @log_date, 
//				groupno, bdate, modu_id, '    ', 'OUT', mode, package, @lastpnumb, @billno
//				from partout where accnt = @accnt  and checkout = @pc_id and number = @number
//			update accredit set tag = '9', billno = @billno, empno2 = @empno, bdate2 = @bdate, 
//				shift2 = @shift, log_date2 = getdate()
//				where accnt = @accnt and partout = @number and tag = '0' and billno = ''
//			end
//		else
//			goto RET_P1
//		end
	fetch c_account into @accnt, @number, @charge, @credit, @cbillno
	end
///* 处理提前结帐 GaoLiang 2000/11/14 */
//declare c_ahead cursor for
//	select accnt, number, inumber, pnumber, pccode, servcode, charge, credit
//	from partout where checkout = @pc_id and package = ' 02' and inumber = 0 order by accnt, number 
//open c_ahead
//fetch c_ahead into @accnt, @number, @inumber, @pnumber, @pccode, @servcode, @charge, @credit
//while @@sqlstatus = 0
//	begin
//	select @code = @pccode + @servcode, @charge = -1 * @charge
//	select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), '-ODEX')
//	exec @ret = p_hry_update_mstblncs 'A', 0, @accnt, @code, @charge, @credit, @roomno out, @groupno out, @lastnumb out, @lastinumb out, @balance out, @catalog out, @msg out 
//	if @ret = 0
//		begin
//		if @number = @pnumber or @pnumber = 0
//			select @lastpnumb = @lastnumb, @log_date = getdate()
//		else
//			select @lastpnumb = @_pnumber, @log_date = @_log_date
//		select @_pnumber = @lastpnumb, @_log_date = @log_date
//		insert account(accnt, number, inumber, date, pccode, servcode, charge, credit, 
//			balance, shift, empno, tag, tag1, crradjt, ref, ref1, ref2, roomno, log_date, 
//			groupno, bdate, modu_id, checkout, waiter, mode, package, pnumber, billno)
//			select @accnt, @lastnumb, @lastnumb, date, pccode, servcode, @charge, @credit, 
//			@balance, shift, empno, tag, tag1, 'AD', ref, ref1, ref2, roomno, @log_date, 
//			groupno, bdate, modu_id, '    ', '', mode, package, @lastpnumb, ''
//			from partout where accnt = @accnt  and checkout = @pc_id and number = @number
//		end
//	else
//		goto RET_P1
//	fetch c_ahead into @accnt, @number, @inumber, @pnumber, @pccode, @servcode, @charge, @credit
//	end
/* Part 2 处理合并结帐 */
select @master_accnt = max(accnt) from account where billno = @billno and arrangement = '99'
declare c_union cursor for select distinct accnt from account where billno = @billno order by accnt
open c_union
fetch c_union into @accnt
while @@sqlstatus = 0
	begin
	select @balance = sum(credit - charge) from account where billno = @billno and accnt = @accnt
	if @balance != 0
		exec @ret = p_gl_accnt_checkout_union @pc_id, @shift, @empno, @master_accnt, @accnt, 'OUT', @billno, @balance out, @msg out
	if @ret !=0
		goto RET_P2
	fetch c_union into @accnt
	end
RET_P2:
close c_union
deallocate cursor c_union
RET_P1:
close c_account
deallocate cursor c_account
//
if (select sum(round(charge, 2) - round(credit, 2)) from account where billno = @billno) != 0
	select @ret = 1, @msg = '帐未结平'
//if @ret = 0
//	begin
//	select @number = min(number) from selected_account where type = '2' and pc_id = @pc_id
//	insert billno (billno, accnt, bdate, empno1, shift1) 
//		select @billno, accnt, @bdate, @empno, @shift
//		from selected_account where type = '2' and pc_id = @pc_id and number = @number
//	select @msg = @billno
//	end
//else
//	rollback tran p_gl_accnt_partout_s1
commit tran
select @ret, @msg
return @ret
;

///* 撤消某次部分结帐 */
//if exists(select * from sysobjects where name = 'p_gl_accnt_cancel_partout')
//	drop proc p_gl_accnt_cancel_partout;
//
//create proc p_gl_accnt_cancel_partout
//	@shift			char(1),
//	@empno			char(3),
//	@billno			char(10)
//as
//declare
//	@ret					integer,
//	@msg					varchar(60),
//	@accnt				char(7),
//	@sta					char(1),
//	@count				integer,
//	@number				integer,
//	@pnumber				integer,
//	@ref					char(8),
//	@ref1					char(8),
//// 转销定金
//	@c_billno			char(10),
//	@tmp_waiter			char(3),
//	@tmp_billno			char(10),
//	@tag					char(3),
//	@tag1					char(3),
//	@tmp_shift			char(1),
//	@tmp_empno			char(3),
//	@correct				char(10),
////
//	@code					char(3), 
//	@roomno				char(5), 
//	@groupno				char(7), 
//	@lastnumb			integer, 
//	@lastinumb			integer, 
//	@credit				money, 
//	@charge				money, 
//	@balance				money, 
//	@catalog				char(3)
//
//select @ret = 0, @code = '03A', @charge = 0
//select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), 'ODEX')
//select @correct = value from sysoption where catalog = 'account' and item = 'cancel_partout'
//if (select count(1) from accthead where canpartout ='T') = 0
//	begin
//	select @ret = 1, @msg = '夜间稽核处于关键区,暂时还不能进行部分结帐有关操作'
//	select @ret, @msg
//	return @ret
//	end
//begin tran
//save tran p_gl_accnt_cancel_partout_s1
//declare c_accnt cursor for
//	select distinct accnt from account where billno = @billno
//open c_accnt
//fetch c_accnt into @accnt
//while @@sqlstatus = 0
//	begin
//	if substring(@accnt, 1, 1) = 'A'
//		begin
//		update armst set sta = sta where accnt = @accnt
//		select @sta = sta from armst where accnt = @accnt
//		end
//	else if substring(@accnt, 2, 2) >= '80' and substring(@accnt,2,2) < '95'
//		begin
//		update grpmst set sta = sta where accnt = @accnt
//		select @sta = sta from grpmst where accnt = @accnt
//		end 
//	else
//		begin
//		update master set sta = sta where accnt = @accnt
//		select @sta = sta from master where accnt = @accnt
//		end
//	if @sta is null
//		select @ret = 1, @msg = '帐号' + @accnt + '不存在'
//	else if charindex(@sta, @msg) > 0
//		select @ret = 1, @msg = '帐号' + @accnt + '已结帐,不能再进行部分结帐有关操作'
//	if @ret != 0
//		goto RET_P1
//	fetch c_accnt into @accnt
//	end
//select @count = count(1) from account where waiter ='OUT' and billno = @billno
//if @count = 0
//	select @ret = 1, @msg = '没有结帐单号为' + rtrim(@billno) + '的部分结帐'
//else
//	begin
//	select @count = count(1) from account where waiter ='OLD' and billno = @billno
//	if @count > 0
//		select @ret = 1, @msg = '只能撤消当天发生的部分结帐'
//	end
//if @ret != 0
//	goto RET_P1
///* 冲销转销定金(或拆分帐务部结)帐目 */
//declare c_adjust cursor for
//	select accnt, number, pnumber, ref, ref1 from account where billno = @billno 
//open c_adjust
//fetch c_adjust into @accnt, @number, @pnumber, @ref, @ref1
//while @@sqlstatus = 0
//	begin
//	if @ref = '调整定金' or @ref1 = '调整帐务'
//		begin
//		exec p_GetAccnt1 @type = 'BIL', @accnt = @c_billno out
//		select @c_billno = 'C' + substring(@c_billno, 2, 9)
//		select @tmp_waiter = waiter, @tmp_billno = billno from account 
//			where accnt = @accnt and inumber = @number and pnumber = @pnumber
//		if not rtrim(@tmp_waiter) is null or @tmp_billno like '[OP]%'
//			begin
//				close c_adjust
//				deallocate cursor c_adjust
//				select @ret = 1, @msg = '请先撤消结帐单号为"' + rtrim(@tmp_billno) + '"的部分结帐'
//				goto RET_P1
//			end
//		update account set crradjt = 'CO', billno = @c_billno 
//			where accnt = @accnt and billno = '' and inumber = @number and pnumber = @pnumber
//		if @@rowcount = 1											// 判断剩余账务&定金已经是否已经被转账
//			update account set crradjt = 'C ', waiter = '', billno = @c_billno where current of c_adjust
//		else
//			update account set crradjt = '', waiter = '', billno = '' where current of c_adjust
///* GaoLiang 2000/12/02 for 四川锦江(将转账明细放入transfer_log,以便统计记账收回情况) */
//		if exists (select 1 from transfer_log a, account b where b.accnt = @accnt and 
//			b.number = @number and a.araccnt = b.accnt and a.arnumber = b.number)
//			begin
//			delete transfer_log where araccnt = @accnt and arnumber = @number
//			delete transfer_log from account a
//				where a.accnt = @accnt and a.inumber = @number and a.pnumber = @pnumber 
//				and a.accnt = transfer_log.araccnt and a.number = transfer_log.arnumber
//			end
///* End for GaoLiang 2000/12/02 */
//		end
//	fetch c_adjust into @accnt, @number, @pnumber, @ref, @ref1
//	end
//close c_adjust
//deallocate cursor c_adjust
///* 冲销合并结帐帐目 */
//declare c_account cursor for
//	select accnt, number, credit, tag, tag1, shift, empno from account where billno = @billno and pccode = '03'
////	select accnt, number, credit from account where billno = @billno and pccode = '03' and rtrim(tag) is null and rtrim(tag1) is null
//open c_account
//fetch c_account into @accnt, @number, @credit, @tag, @tag1, @tmp_shift, @tmp_empno
//while @@sqlstatus = 0
//	begin
//	if @correct = 'ALL' or (@correct = 'SELF_ALL' and @tmp_empno = @empno) or 
//		(@correct = 'SELF_SHIFT' and @tmp_empno = @empno and @tmp_shift = @shift) or 
//		(rtrim(@tag) is null and rtrim(@tag1) is null)
//		begin
//		select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'valid_sta'), '+HIS')
//		select @credit = @credit * -1
//		exec @ret = p_hry_update_mstblncs 'A', 0, @accnt, @code, @charge, @credit, @roomno out, @groupno out, @lastnumb out, @lastinumb out, @balance out, @catalog out, @msg out
//		if @ret = 0
//			begin
//			exec p_GetAccnt1 @type = 'BIL', @accnt = @c_billno out
//			select @c_billno = 'C' + substring(@c_billno, 2, 9)
//			insert account(accnt, number, inumber, pccode, servcode, credit, balance,
//				shift, empno, tag, tag1, ref, ref1, roomno, groupno, crradjt, tofrom,
//				accntof, bdate, modu_id, checkout, pnumber, package, subaccnt, billno)
//				select accnt, @lastnumb, inumber, substring(@code, 1, 2), substring(@code, 3, 1), 
//				@credit, @balance, @shift, @empno, tag, tag1, ref, ref1, roomno, groupno, 
//				'CO', tofrom, accntof, bdate, modu_id, checkout, pnumber, package, subaccnt, @c_billno
//				from account where accnt = @accnt and number = @number
//			update account set crradjt = 'C ', waiter = '', billno = @c_billno where current of c_account
//			end
//		else
//			begin
//			select @ret = 1, @msg = @msg + ' -- 帐务表插入失败'  // gds
//			goto RET_P2
//			end
//		end
//	fetch c_account into @accnt, @number, @credit, @tag, @tag1, @tmp_shift, @tmp_empno
//	end
///* GaoLiang 2000/12/02 for 四川锦江(将转账明细放入transfer_log,以便统计记账收回情况) */
//update transfer_log set archarge = 0, arcredit = 0, arempno = @empno, ardate = getdate(), billno = ''
//	from account a
//	where a.accnt = @accnt and a.billno = @billno and a.accnt = transfer_log.araccnt and a.number = transfer_log.arnumber
///* End for GaoLiang 2000/12/02 */
//update account set waiter = '', billno = '' where billno = @billno
//RET_P2:
//close c_account
//deallocate cursor c_account
//RET_P1:
//close c_accnt
//deallocate cursor c_accnt
//if @ret = 0
//	update billno set empno2 = @empno, shift2 = @shift, date2 = getdate() where billno = @billno
//else
//	rollback tran p_gl_accnt_cancel_partout_s1
//commit tran
//select @ret, @msg 
//return @ret
//;
//