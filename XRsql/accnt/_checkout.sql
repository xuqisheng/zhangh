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
	@selected			integer,
	@rowcount			integer, 
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
//	select @ret = 1, @msg = 'ҹ����˴��ڹؼ���, ��ʱ�����ܽ��в��ֽ���'
//	select @ret, @msg
//	return @ret
//	end
if @operation = "SELECTED"
	select @selected = 1
else
	select @selected = 0
select @charge = sum(a.charge), @credit = sum(a.credit), @rowcount = count(1) from account a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected >= @selected and b.accnt = a.accnt and b.number = a.number
if @charge != @credit
	begin
	select @ret = 1, @msg = '��δ��ƽ'
	select @ret, @msg
	return @ret
	end

select @bdate = bdate1, @ret = 0, @msg = '' from sysdata
begin tran
save  tran p_gl_accnt_checkout
exec p_GetAccnt1 @type = 'BIL', @accnt = @billno out
select @billno = 'B' + substring(@billno, 2, 9)
/* Part 1 ƽ�ˡ����ý��˱�־ */
// ��ס��ص�����
update master set sta = sta from account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected >= @selected and master.accnt = b.accnt
update account set billno = @billno from account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected >= @selected and b.accnt = account.accnt and b.number = account.number
if @@rowcount != @rowcount
	begin
	select @ret = 1, @msg = '��' + convert(char(5), @rowcount - @@rowcount) + '���ʲ��ܱ����ֽ���'
	goto RET_P1
	end
else
	// ��ת����ϸ����transfer_log,�Ա�ͳ�Ƽ����ջ����)
	update transfer_log set archarge = a.charge, arcredit = a.credit, arempno = @empno, ardate = getdate(), billno = a.billno
		from account a where a.billno = @billno and transfer_log.araccnt = a.accnt and transfer_log.arnumber = a.number
/* Part 2 ����ϲ����� */
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
//
if (select sum(round(charge, 2) - round(credit, 2)) from account where billno = @billno) != 0
	select @ret = 1, @msg = '��δ��ƽ'
else
	begin
/* Part 3 �ͷ���Դ */
	insert billno (billno, accnt, bdate, empno1, shift1) select @billno, @master_accnt, @bdate, @empno, @shift
	if @operation = 'CHECKOUT' and @roomno != '99999' and @subaccnt = 0
		exec @ret = p_gl_accnt_release_resource @pc_id, @mdi_id, @roomno, @accnt, 'O', @shift, @empno, 'R', @msg out
	end
RET_P1:
if @ret != 0
	rollback tran p_gl_accnt_checkout
commit tran
select @ret, @msg
return @ret
;

///* ����ĳ�β��ֽ��� */
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
//// ת������
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
//	select @ret = 1, @msg = 'ҹ����˴��ڹؼ���,��ʱ�����ܽ��в��ֽ����йز���'
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
//		select @ret = 1, @msg = '�ʺ�' + @accnt + '������'
//	else if charindex(@sta, @msg) > 0
//		select @ret = 1, @msg = '�ʺ�' + @accnt + '�ѽ���,�����ٽ��в��ֽ����йز���'
//	if @ret != 0
//		goto RET_P1
//	fetch c_accnt into @accnt
//	end
//select @count = count(1) from account where waiter ='OUT' and billno = @billno
//if @count = 0
//	select @ret = 1, @msg = 'û�н��ʵ���Ϊ' + rtrim(@billno) + '�Ĳ��ֽ���'
//else
//	begin
//	select @count = count(1) from account where waiter ='OLD' and billno = @billno
//	if @count > 0
//		select @ret = 1, @msg = 'ֻ�ܳ������췢���Ĳ��ֽ���'
//	end
//if @ret != 0
//	goto RET_P1
///* ����ת������(�������񲿽�)��Ŀ */
//declare c_adjust cursor for
//	select accnt, number, pnumber, ref, ref1 from account where billno = @billno 
//open c_adjust
//fetch c_adjust into @accnt, @number, @pnumber, @ref, @ref1
//while @@sqlstatus = 0
//	begin
//	if @ref = '��������' or @ref1 = '��������'
//		begin
//		exec p_GetAccnt1 @type = 'BIL', @accnt = @c_billno out
//		select @c_billno = 'C' + substring(@c_billno, 2, 9)
//		select @tmp_waiter = waiter, @tmp_billno = billno from account 
//			where accnt = @accnt and inumber = @number and pnumber = @pnumber
//		if not rtrim(@tmp_waiter) is null or @tmp_billno like '[OP]%'
//			begin
//				close c_adjust
//				deallocate cursor c_adjust
//				select @ret = 1, @msg = '���ȳ������ʵ���Ϊ"' + rtrim(@tmp_billno) + '"�Ĳ��ֽ���'
//				goto RET_P1
//			end
//		update account set crradjt = 'CO', billno = @c_billno 
//			where accnt = @accnt and billno = '' and inumber = @number and pnumber = @pnumber
//		if @@rowcount = 1											// �ж�ʣ������&�����Ѿ��Ƿ��Ѿ���ת��
//			update account set crradjt = 'C ', waiter = '', billno = @c_billno where current of c_adjust
//		else
//			update account set crradjt = '', waiter = '', billno = '' where current of c_adjust
///* GaoLiang 2000/12/02 for �Ĵ�����(��ת����ϸ����transfer_log,�Ա�ͳ�Ƽ����ջ����) */
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
///* �����ϲ�������Ŀ */
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
//			select @ret = 1, @msg = @msg + ' -- ��������ʧ��'  // gds
//			goto RET_P2
//			end
//		end
//	fetch c_account into @accnt, @number, @credit, @tag, @tag1, @tmp_shift, @tmp_empno
//	end
///* GaoLiang 2000/12/02 for �Ĵ�����(��ת����ϸ����transfer_log,�Ա�ͳ�Ƽ����ջ����) */
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