
if exists(select * from sysobjects where name = 'p_gds_accnt_checkout')
	drop proc p_gds_accnt_checkout;

create proc p_gds_accnt_checkout
	@pc_id				char(4), 
	@mdi_id				integer, 
	@roomno				char(5), 
	@accnt				char(10), 
	@subaccnt			integer, 
	@operation			char(10), 
	@shift				char(1),
	@empno				char(10),
	@retmode				char(1) = 'S',
	@msg					varchar(60)='' output 
as
----------------------------------------------------------------------------------
--  结帐
--				该过程跟 p_gl_accnt_checkout 基本一致，只是可以通过 output 返回 
----------------------------------------------------------------------------------
declare
	@bdate				datetime, 
	@billno				char(10),
	@master_accnt		char(10), 
	@caccnt				char(10), 
	@newnum				integer, 
	@number				integer, 
	@inumber				integer, 
	@pnumber				integer, 
	@pccode				char(5), 
	@code					char(5), 
	@charge				money, 
	@credit				money, 
	@selected			integer,
	@rowcount			integer, 
	@crradjt				char(2), 
	@waiter				char(3), 
	@tofrom				char(2), 
	@cbillno				char(10), 
--	@roomno				char(5), 
--	@groupno				char(10), 
	@catalog				char(3), 
	@lastnumb			integer, 
	@lastinumb			integer, 
	@lastpnumb			integer, 
	@to_lastnumb		integer, 
	@to_lastinumb		integer, 
	@balance				money, 
	@withit				char(1), 
	@retmsg				varchar(60), 
	@ret					integer,
	@_pnumber			integer,
	@_log_date			datetime, 
	@log_date			datetime

--if (select count(1) from accthead where canpartout = 'T') = 0
--	begin
--	select @ret = 1, @msg = '夜间稽核处于关键区, 暂时还不能进行部分结账'
--	if @retmode='S'
--		select @ret, @msg
--	return @ret
--	end
if @operation = "SELECTED"
	select @selected = 1
else
	select @selected = 0
select @charge = sum(round(a.charge, 2)), @credit = sum(round(a.credit, 2)), @rowcount = count(1) from account a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected >= @selected and b.accnt = a.accnt and b.number = a.number
if @charge != @credit
	begin
	select @ret = 1, @msg = '账未结平'
	if @retmode='S'
		select @ret, @msg
	return @ret
	end
--
select @bdate = bdate1, @ret = 0, @msg = '' from sysdata
if @roomno = '' and @accnt = ''				-- 所有
	select @master_accnt = max(a.accnt) from accnt_set a, account b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and (a.sta in ('I', 'R', 'S') or (a.accnt = b.accnt and b.billno = ''))
else if @accnt = ''								-- 指定房间
	select @master_accnt = max(a.accnt) from accnt_set a, account b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0 and (a.sta in ('I', 'R', 'S') or (a.accnt = b.accnt and b.billno = ''))
else													-- 指定团体或账号
	select @master_accnt = @accnt
--
if rtrim(@master_accnt) is null
	begin
	select @ret = 1, @msg = '没有需要结的账'
	if @retmode='S'
		select @ret, @msg
	return @ret
	end
--
begin tran
save  tran p_gds_accnt_checkout
exec p_GetAccnt1 @type = 'BIL', @accnt = @billno out
select @billno = 'B' + substring(@billno, 2, 9)
-- Part 1 平账、设置结账标志 
-- 锁住相关的主单
update master set sta = sta from account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected >= @selected and master.accnt = b.accnt
update account set billno = @billno from account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected >= @selected
	and b.accnt = account.accnt and b.number = account.number and account.billno = ''
if @@rowcount != @rowcount
	begin
	select @ret = 1, @msg = '有' + convert(char(5), @rowcount - @@rowcount) + '行非有效账目，不能被结账'
	goto RET_P1
	end
else
	-- 将转账明细放入transfer_log,以便统计记账收回情况
	update transfer_log set archarge = a.charge, arcredit = a.credit, arempno = @empno, ardate = getdate(), billno = a.billno
		from account a where a.billno = @billno and transfer_log.araccnt = a.accnt and transfer_log.arnumber = a.number
-- Part 2 处理合并结账 
declare c_union cursor for select distinct accnt from account where billno = @billno order by accnt
open c_union
fetch c_union into @caccnt
while @@sqlstatus = 0
	begin
	select @balance = sum(credit - charge) from account where billno = @billno and accnt = @caccnt
	if @balance != 0
		exec @ret = p_gl_accnt_checkout_union @pc_id, @shift, @empno, @master_accnt, @caccnt, 'OUT', @billno, @balance out, @msg out
	if @ret !=0
		goto RET_P2
	fetch c_union into @caccnt
	end
RET_P2:
close c_union
deallocate cursor c_union
--
if (select sum(round(charge, 2) - round(credit, 2)) from account where billno = @billno) != 0
	select @ret = 1, @msg = '账未结平'
else
	begin
-- Part 3 释放资源 
	insert billno (billno, accnt, bdate, empno1, shift1) select @billno, @master_accnt, @bdate, @empno, @shift
	if @operation = 'CHECKOUT' and @roomno != '99999' and @subaccnt = 0
		exec @ret = p_gl_accnt_release_resource @pc_id, @mdi_id, @roomno, @accnt, 'O', @shift, @empno, 'R', @msg out
	end
RET_P1:
if @ret != 0
	rollback tran p_gds_accnt_checkout
else
	select @msg = @billno
commit tran
if @retmode='S'
	select @ret, @msg
return @ret
;
