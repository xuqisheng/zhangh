

// 注意 ：  
// 该文件应该没用了。 这里的过程已经有单独的文件。
// 比如，这里的工号都是 char(3) ...   simon 2007.5.21 


//insert sysoption values ('account', 'cancel_checkout', 'SELF_SHIFT');	
//ALL:冲销所有付款;SELF_ALL:冲销自己当天付款;SELF_SHIFT:冲销自己当班付款

/*	结帐时主单状态更新等	*/

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
	@empno				char(3)

as
declare
	@bdate				datetime,	 			/*营业日期*/
	@billno				char(10), 
	@accnt				char(7), 
	@class				char(3), 
	@sta					char(1), 
	@dep					datetime, 
	@balance				money, 
	@ret					integer, 
	@msg					char(60), 
	@empname				char(12), 
	@groupno				char(7),
	@invalid_sta		char(255), 
	//
	@master_accnt		char(7), 
	@number				integer

select @ret = 0, @msg = '', @billno = ''
select @empname = name from auth_login where empno = @empno
select @invalid_sta = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), '-ODEX')
select @master_accnt = accnt from selected_account where type = '2' and pc_id = @pc_id and number = 0
begin tran
save tran p_gl_accnt_checkout
if @newsta = 'O'
	begin
	update phteleclos set roomno = roomno from selected_account a 
		where a.type = '2' and a.pc_id = @pc_id and a.accnt = phteleclos.accnt
	exec p_GetAccnt1 @type = 'BIL', @accnt = @billno out
	select @billno = 'O' + substring(@billno, 2, 9)
	end
declare c_accnt cursor for
	select accnt, number from selected_account where type = '2' and pc_id = @pc_id order by number desc
open c_accnt
fetch c_accnt into @accnt, @number
while @@sqlstatus = 0
	begin
	exec p_hry_accnt_class @accnt, @class out
	if substring(@class, 1, 1) in ('C')
		begin
		update armst set sta = sta where accnt = @accnt
		select @sta = sta, @balance = depr_cr + addrmb - rmb_db from armst where accnt = @accnt
		if @number > 0 and @balance != 0 and @newsta = 'O'
			exec @ret = p_gl_accnt_checkout_union 'A', '', @pc_id, @shift, @empno, @master_accnt, @accnt, '', '', @balance out, @msg out
		if @ret !=0
			goto RET_P
		if charindex(@sta, @invalid_sta) > 0
			begin
			select @ret = 1, @msg = '已为结帐状态'
			goto RET_P
			end
		update armst set sta = @newsta where accnt = @accnt
		if @newsta = 'O'
			begin
			if @balance != 0
				begin
				select @ret = 1, @msg = '帐未结平'
				goto RET_P
				end 
			update account set billno = @billno where accnt = @accnt and rtrim(billno) is null
			end
		if exists(select 1 from allouts where accnt = @accnt)
			update allouts set stabacktoi = '', empno = @empno, date = getdate(), billno = @billno where accnt = @accnt
		else
			insert allouts select accnt, sta, '', @empno, getdate(), @billno from armst where accnt = @accnt
		update armst set ressta = @sta, logmark = logmark + 1, cby = @empno, cbyname = @empname, changed = getdate() where accnt = @accnt
		end
	else if substring(@class, 1, 1) in ('G')
		begin
		update grpmst set sta = sta where accnt = @accnt
		if exists (select 1 from master where groupno = @accnt and charindex(sta, 'I') > 0 )
			begin
			select @ret = 1, @msg = '团体' + @accnt + '还有在店成员若干, 请先为成员结帐退房'
			goto RET_P
			end
		else if exists (select 1 from master where groupno = @accnt and charindex(sta, 'RCG') > 0 )
			begin
			select @ret = 1, @msg = '团体' + @accnt + '还有预订成员若干, 请先为成员结帐退房'
			goto RET_P
			end
		else if @newsta != 'S' and exists (select 1 from master where groupno = @accnt and charindex(sta, 'S') > 0 )
			begin
			select @ret = 1, @msg = '团体' + @accnt + '还有挂帐成员若干, 请先为成员结帐'
			goto RET_P
			end
		update master set sta = sta where groupno = @accnt
		if exists (select 1 from master where groupno = @accnt and lastnumb > 0 and charindex(sta, @invalid_sta) = 0)
			begin
			select @ret = 1, @msg = '团体' + @accnt + '还有若干成员帐未结清, 请先为成员结帐'
			goto RET_P
			end
		select @sta = sta, @balance = depr_cr + addrmb - rmb_db from grpmst where accnt = @accnt
		if @number > 0 and @balance != 0 and @newsta = 'O'
			exec @ret = p_gl_accnt_checkout_union 'A', '', @pc_id, @shift, @empno, @master_accnt, @accnt, '', '', @balance out, @msg out
		if @ret !=0
			goto RET_P
		if charindex(@sta, @invalid_sta) > 0
			begin
			select @ret = 1, @msg = '已为结帐状态'
			goto RET_P
			end
		update grpmst set sta = @newsta where accnt = @accnt
		if @newsta = 'O'
			begin
			if @balance != 0
				begin
				select @ret = 1, @msg = '帐未结平'
				goto RET_P
				end
			exec @ret = p_hry_reserve_release_block @accnt 
			update account set billno = @billno where accnt = @accnt and rtrim(billno) is null
			// 将当前团体的非有效成员(L,N,X) Check Out
			update master set resdep = @dep, ressta = @sta, sta = @newsta, dep = getdate(),
				logmark = logmark + 1, cby = @empno, cbyname = @empname, changed = getdate() 
				where groupno = @accnt and sta in ('L', 'N', 'X')
			update guest set sta = @newsta, dep = getdate(),
				logmark = logmark + 1, cby = @empno, cbyname = @empname, changed = getdate() 
				where groupno = @accnt and sta in ('L', 'N', 'X')
			end 
		if exists(select 1 from allouts where accnt = @accnt)
			update allouts set stabacktoi = '', empno = @empno, date = getdate(), billno = @billno where accnt = @accnt
		else
			insert allouts select accnt, sta, '', @empno, getdate(), @billno from grpmst where accnt = @accnt
		update grpmst set ressta = @sta, logmark = logmark + 1, cby = @empno, cbyname = @empname, changed = getdate()	where accnt = @accnt
		end
	else if substring(@class, 1, 1) in ('T', 'M', 'H')
		begin
		select @groupno = groupno from master where accnt = @accnt
		if @groupno > = '0000000'
			update grpmst set sta = sta where accnt = @groupno
		update master set sta = sta where accnt = @accnt
		select @sta = sta, @dep = dep, @balance = depr_cr + addrmb - rmb_db from master where accnt = @accnt
		if @number > 0 and @balance != 0 and @newsta = 'O'
			exec @ret = p_gl_accnt_checkout_union 'A', '', @pc_id, @shift, @empno, @master_accnt, @accnt, '', '', @balance out, @msg out
		if @ret !=0
			goto RET_P
		if charindex(@sta, @invalid_sta) > 0
			begin
			select @ret = 1, @msg = '已为结帐状态'
			goto RET_P
			end
		update master set sta = @newsta, dep = getdate() where accnt = @accnt
		if @newsta = 'O'
			begin
			if @balance != 0
				begin
				select @ret = 1,	@msg = '帐未结平'
				goto RET_P
				end
			update account set billno = @billno where accnt = @accnt and rtrim(billno) is null
			end
		if exists(select 1 from allouts where accnt = @accnt)
			update allouts set stabacktoi = '', empno = @empno, date = getdate(), billno = @billno where accnt = @accnt
		else
			insert allouts select accnt, sta, '', @empno, getdate(), @billno from master where accnt = @accnt
		update master set resdep = @dep, ressta = @sta where accnt = @accnt
		exec @ret = p_hry_reserve_chktprm @accnt, '2', '', @empno, '', 1, 1, @msg out
		update master set logmark = logmark + 1, cby = @empno, cbyname = @empname, changed = getdate()	where accnt = @accnt
		update guest set logmark = logmark + 1, cby = @empno, cbyname = @empname, changed = getdate()	where accnt = @accnt
		end
	fetch c_accnt into @accnt, @number
	end
RET_P:
close c_accnt
deallocate cursor c_accnt
if @ret = 0
	begin
	select @bdate = bdate1 from sysdata
	select @number = min(number) from selected_account where type = '2' and pc_id = @pc_id
	insert billno (billno, accnt, bdate, empno1, shift1) 
		select @billno, accnt, @bdate, @empno, @shift
		from selected_account where type = '2' and pc_id = @pc_id and number = @number
/* GaoLiang 2000/12/02 for 四川锦江(将转账明细放入transfer_log,以便统计记账收回情况) */
	if @newsta = 'O'
		update transfer_log set archarge = a.charge, arcredit = a.credit, arempno = @empno, ardate = getdate(), billno = @billno
			from account a
			where a.billno = @billno and a.accnt = transfer_log.araccnt and a.number = transfer_log.arnumber
/* End for GaoLiang 2000/12/02 */
	select @msg = @billno
	end
else
	rollback tran p_gl_accnt_checkout
commit tran
select @ret, @msg
return @ret
; 

/* 处理合并结帐(pccode + servecode = '03D') */

if  exists(select * from sysobjects where name = 'p_gl_accnt_checkout_union')
	drop proc p_gl_accnt_checkout_union;

create proc p_gl_accnt_checkout_union
	@selemark			char(1) = 'A', 		/*输入参数确保非NULL*/
	@modu_id				char(2), 
	@pc_id				char(4), 
	@shift				char(1), 
	@empno				char(3), 
	@master_accnt		char(7), 
	@accnt				char(7), 
	@waiter				char(3), 
	@billno				char(10), 
	@credit				money out,				/**/
   @msg  		      varchar(60) out      /*返回信息*/
as
declare
	@ret					integer, 
	@bdate				datetime,	 			/*营业日期*/
	@descript0			char(12),				/*付款码大类说明*/
	@paycode				char(3), 				/*付款方式内部码*/
	@paymth				char(3), 				/*付款方式内部码*/
	@code					char(3), 				/*费用代码*/
	@c_billno			char(8), 
	@roomno				char(5), 
	@groupno				char(7), 
	@lastnumb			integer, 
	@lastinumb			integer, 
	@to_lastnumb		integer, 
	@to_lastinumb		integer, 
	@charge				money, 
	@balance				money, 
	@catalog				char(3), 
	@crradjt				char(2), 
	@checkout			char(4)

select @ret = 0, @msg = isnull((select value from sysoption where catalog = 'account' and item = 'invalid'), '-ODEX')
select @bdate = bdate1, @checkout = '    ' from sysdata
if substring(@selemark, 1, 1) != 'A'
	select @checkout = @pc_id
if @selemark='A'
	select @modu_id = '02'
select @code = '03D', @paycode = '', @paymth = '', @descript0 = '结帐付款', @c_billno = '合并结帐', @charge = 0, @crradjt = 'CT'
begin tran
save tran p_gl_accnt_checkout_union_s1

exec p_hry_lock_two_master @master_accnt, @accnt
select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), '-ODEX')
exec @ret = p_hry_update_mstblncs 'A', 0, @master_accnt, @code, @charge, @credit, @roomno out, @groupno out, @lastnumb out, @lastinumb out, @balance out, @catalog out, @msg out
if @ret = 0
	begin
	if @selemark ='A'
		insert account(accnt, number, inumber, pccode, servcode, credit, balance, shift, empno, 
			tag, tag1, ref, ref1, roomno, groupno, crradjt, tofrom, accntof, bdate, modu_id, checkout, waiter, billno, pnumber, package)
			values(@master_accnt, @lastnumb, @lastnumb, substring(@code, 1, 2), substring(@code, 3, 1), 
			@credit, @balance, @shift, @empno, @paycode, @paymth, @descript0, 
			@c_billno, @roomno, @groupno, @crradjt, 'TO', @accnt, @bdate, @modu_id, @checkout, @waiter, @billno, @lastnumb, ' ' + substring(@code, 1, 2))
	else
		insert partout (accnt, number, inumber, pccode, servcode, credit, balance, shift, empno, 
			tag, tag1, ref, ref1, roomno, groupno, crradjt, tofrom, accntof, bdate, modu_id, checkout, waiter, billno, pnumber, package)
			values(@master_accnt, @lastnumb, 0, substring(@code, 1, 2), substring(@code, 3, 1), 
			@credit, @balance, @shift, @empno, @paycode, @paymth, @descript0, 
			@c_billno, @roomno, @groupno, @crradjt, 'TO', @accnt, @bdate, @modu_id, @checkout, @waiter, @billno, 0, ' ' + substring(@code, 1, 2))
	if @@rowcount !=  0
		begin
		select @credit = @credit * -1
		select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'valid_sta'), 'HISRCG')
		exec @ret = p_hry_update_mstblncs 'A', 0, @accnt, @code, @charge, @credit, @roomno out, @groupno out, @to_lastnumb out, @to_lastinumb out, @balance out, @catalog out, @msg out
		if @ret != 0
			begin
			rollback tran p_gl_accnt_checkout_union_s1
			select @ret = 1
			end
		else
			begin
//			insert account(accnt, number, inumber, date, pccode, servcode, charge, credit, 
//				balance, shift, empno, tag, tag1, crradjt, ref, ref1, ref2, roomno, 
//				groupno, tofrom, accntof, bdate, modu_id, guestid, pnumber, package)
//				select @to_accnt, @lastnumb, inumber, date, pccode, servcode, charge, credit, 
//				@balance, @shift, @empno, tag, tag1, @crradjt, ref, ref1, ref2, @roomno, 
//				@groupno, 'FM', @accnt, @bdate, @modu_id, @to_guestid, @lastnumb + @pnumber - @number, package
//				from account where accnt = @accnt and number = @number
			if @selemark ='A'
				insert account(accnt, number, inumber, pccode, servcode, credit, balance, shift, empno, 
					tag, tag1, ref, ref1, roomno, groupno, crradjt, tofrom, accntof, bdate, modu_id, checkout, waiter, billno, pnumber, package)
					values(@accnt, @to_lastnumb, @lastnumb, substring(@code, 1, 2), substring(@code, 3, 1), 
					@credit, @balance, @shift, @empno, @paycode, @paymth, @descript0, 
					@c_billno, @roomno, @groupno, @crradjt, 'FM', @master_accnt, @bdate, @modu_id, @checkout, @waiter, @billno, @to_lastnumb, ' ' + substring(@code, 1, 2))
			else
				insert partout (accnt, number, inumber, pccode, servcode, credit, balance, shift, empno, 
					tag, tag1, ref, ref1, roomno, groupno, crradjt, tofrom, accntof, bdate, modu_id, checkout, waiter, billno, pnumber, package)
					values(@accnt, @to_lastnumb, 0, substring(@code, 1, 2), substring(@code, 3, 1), 
					@credit, @balance, @shift, @empno, @paycode, @paymth, @descript0, 
					@c_billno, @roomno, @groupno, @crradjt, 'FM', @master_accnt, @bdate, @modu_id, @checkout, @waiter, @billno, 0, ' ' + substring(@code, 1, 2))
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


///*	撤消结帐	*/
//
//if	exists(select * from sysobjects where name = 'p_gl_accnt_cancel_checkout')
//	drop proc p_gl_accnt_cancel_checkout;
//
//create proc p_gl_accnt_cancel_checkout
//	@accnt				char(7), 
//	@request				char(1), 
//	@shift				char(1), 
//	@empno				char(3)
//
//as
//declare
//	@class				char(3), 
//	@sta					char(1), 
//	@sta_tm				char(1), 
//	@ret					integer, 
//	@msg					char(60), 
//	@empname				char(12), 
//	//
//	@tag					char(3),
//	@tag1					char(3),
//	@tmp_shift			char(1),
//	@tmp_empno			char(3),
//	@correct				char(10),
//	//
//	@billno				char(10), 
//	@c_billno			char(10), 
//	@master_accnt		char(7), 
//	@number				integer,
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
//
//select @ret = 0, @msg = ''
//select @master_accnt = @accnt, @code = '03A', @charge = 0
//select @empname = name from auth_login where empno = @empno
//select @billno = billno from allouts where accnt = @master_accnt
//select @correct = value from sysoption where catalog = 'account' and item = 'cancel_checkout'
//begin tran
//save tran p_gl_accnt_cancel_checkout
//declare c_account cursor for
//	select number, credit, tag, tag1, shift, empno from account where accnt = @accnt and pccode = '03' and billno = @billno
////	select number, credit from account where accnt = @accnt and pccode = '03' and billno = @billno and rtrim(tag) is null and rtrim(tag1) is null
//// 保证团体主单首先撤销结帐状态 GaoLiang 2000/3/26
//declare c_accnt cursor for
//	select accnt from allouts where billno = @billno order by substring(accnt, 2, 6) desc
//open c_accnt
//fetch c_accnt into @accnt
//while @@sqlstatus = 0
//	begin
//	exec p_hry_accnt_class @accnt, @class out
//	if substring(@class, 1, 1) in ('C')
//		begin
//		update armst set sta = sta where accnt = @accnt
//		select @sta_tm = sta_tm, @sta = sta from armst where accnt = @accnt
//		if @sta = 'D' and @sta_tm = 'O'
//			begin
//			select @ret = 1, @msg = '是上营业日结的帐, 不能撤消'
//			goto RET_P
//			end
//		else if @sta != 'O'
//			begin
//			select @ret = 1, @msg = '非结帐状态, 不需撤消'
//			goto RET_P
//			end
//		update armst set sta = ressta, logmark = logmark + 1, cby = @empno, cbyname = @empname, changed = getdate() where accnt = @accnt
//		end
//	else if substring(@class, 1, 1) in ('G')
//		begin
//		update grpmst set sta = sta where accnt = @accnt
//		select @sta_tm = sta_tm, @sta = sta from grpmst where accnt = @accnt
//		if @sta = 'D' and @sta_tm = 'O'
//			begin
//			select @ret = 1, @msg = '是上营业日结的帐, 不能撤消'
//			goto RET_P
//			end
//		else if @sta != 'O'
//			begin
//			select @ret = 1, @msg = '非结帐状态, 不需撤消'
//			goto RET_P
//			end
//		update grpmst set sta = ressta, logmark = logmark + 1, cby = @empno, cbyname = @empname, changed = getdate() where accnt = @accnt
//		end
//	else if substring(@class, 1, 1) in ('T', 'M', 'H')
//		begin
//		select @groupno = groupno from master where accnt = @accnt
//		if @@rowcount = 1 and @groupno != space(7)
//			begin
//			update grpmst set sta = sta where accnt = @accnt
//			select @sta = sta from grpmst where accnt = @groupno
//			end		
//		select @sta = sta, @sta_tm = sta_tm from master where accnt = @accnt
//		if @sta = 'D' and @sta_tm = 'O'
//			begin
//			select @ret = 1, @msg = '因是上营业日结帐退的房, 不能撤消'
//			goto RET_P
//			end
//		else if @sta != 'O'
//			begin
//			select @ret = 1, @msg = '非结帐状态, 不需撤消'
//			goto RET_P
//			end
//		update master set dep = resdep, sta = ressta, logmark = logmark + 1, cby = @empno, cbyname = @empname, changed = getdate()	where accnt = @accnt
//		exec @ret = p_hry_reserve_chktprm @accnt, @request, 'T', @empno, '', 1, 1, @msg out
//		update master set logmark = logmark + 1, cby = @empno, cbyname = @empname, changed = getdate() where accnt = @accnt
//		update guest set logmark = logmark + 1, cby = @empno, cbyname = @empname, changed = getdate() where accnt = @accnt
//		end
//	/* 冲销合并结帐帐目 */
//	open c_account
//	fetch c_account into @number, @credit, @tag, @tag1, @tmp_shift, @tmp_empno
//	while @@sqlstatus = 0
//		begin
//		if @correct = 'ALL' or (@correct = 'SELF_ALL' and @tmp_empno = @empno) or 
//			(@correct = 'SELF_SHIFT' and @tmp_empno = @empno and @tmp_shift = @shift) or 
//			(rtrim(@tag) is null and rtrim(@tag1) is null)
//			begin
//			select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'valid_sta'), 'HISRCG')
//			select @credit = @credit * - 1
//			exec @ret = p_hry_update_mstblncs 'A', 0, @accnt, @code, @charge, @credit, @roomno out, @groupno out, @lastnumb out, @lastinumb out, @balance out, @catalog out, @msg out
//			if @ret = 0
//				begin
//				exec p_GetAccnt1 @type = 'BIL', @accnt = @c_billno out
//				select @c_billno = 'C' + substring(@c_billno, 2, 9)
//				insert account(accnt, number, inumber, pccode, servcode, credit, balance, 
//					shift, empno, tag, tag1, ref, ref1, roomno, groupno, crradjt, tofrom, accntof, 
//					bdate, modu_id, checkout, waiter, pnumber, package, subaccnt, billno)
//					select accnt, @lastnumb, inumber, substring(@code, 1, 2), substring(@code, 3, 1), 
//					@credit, @balance, @shift, @empno, tag, tag1, ref, ref1, roomno, groupno, 'CO', tofrom, accntof, 
//					bdate, modu_id, checkout, waiter, pnumber, package, subaccnt, @c_billno
//					from account where accnt = @accnt and number = @number
//				update account set crradjt = 'C ', billno = @c_billno where current of c_account
//				end
//			else
//				begin
//				select @ret = 1, @msg = '帐务表插入失败'
//				goto RET_P
//				end
//			end
//		fetch c_account into @number, @credit, @tag, @tag1, @tmp_shift, @tmp_empno
//		end
//	close c_account
///* GaoLiang 2000/12/02 for 四川锦江(将转账明细放入transfer_log,以便统计记账收回情况) */
//	update transfer_log set archarge = 0, arcredit = 0, arempno = @empno, ardate = getdate(), billno = ''
//		from account a
//		where a.accnt = @accnt and a.billno = @billno and a.accnt = transfer_log.araccnt and a.number = transfer_log.arnumber
///* End for GaoLiang 2000/12/02 */
//	update account set billno = '' where accnt = @accnt and billno = @billno
//	update allouts set stabacktoi = 'T', billno = '' where accnt = @accnt
//	fetch c_accnt into @accnt
//	end
//RET_P:
//close c_accnt
//deallocate cursor c_accnt
//deallocate cursor c_account
//if @ret = 0
//	update billno set empno2 = @empno, shift2 = @shift, date2 = getdate() where billno = @billno
//else
//	rollback tran p_gl_accnt_cancel_checkout
//commit tran
//select @ret, @msg
//return @ret
//;
