/* 压缩明细账目 */
if exists(select * from sysobjects where name = 'p_gl_ar_compress' and type='P')
	drop proc p_gl_ar_compress;

create proc p_gl_ar_compress
	@pc_id					char(4), 
	@mdi_id					integer, 
	@shift					char(1), 
	@empno					char(10), 
	@accnt					char(10),
	@subaccnt				integer, 
	@guestname				char(50),
	@guestname2				char(50),
	@pccode					char(5), 
	@argcode					char(2),
	@ref2						char(50),
	@operation				char(2) = 'FS',				/* 第一位 : F.按费用汇总压缩,T.按明细压缩
																		第二位 : S.Select返回,R.Return返回 */

	@msg						char(100) output
as
declare
	@ret						integer, 
	@log_date				datetime,						/* 发生时间 */
	@bdate					datetime,						/* 营业日期 */
	@date						datetime,						/* 明细账目的营业日期 */
	@ref						char(24),
	@ref1						char(10),
	@quantity				money, 
	@credit					money, 
	@charge					money, 
	@credit0					money, 
	@charge0					money, 
	@credit1					money, 
	@charge1					money, 
	@credit9					money, 
	@charge9					money, 
	@lastnumb				integer, 
	@lastinumb				integer, 
	@ar_pnumber				integer, 
	@charge2					money, 
	@charge3					money, 
	@charge4					money, 
	@charge5					money, 
	@package_d				money, 
	@package_c				money, 
	@package_a				money, 
	@balance					money, 
	@catalog					char(3), 
	@billno					char(10),
	@old						varchar(60),
	@new						varchar(60)

select @log_date = getdate(), @bdate = bdate1 from sysdata
select @ref = isnull((select descript from pccode where pccode = @pccode), ''), @guestname = isnull(@guestname, ''), @guestname2 = isnull(@guestname2, '')
--
if (select count(distinct accnt) from account_temp where pc_id = @pc_id and mdi_id = @mdi_id and selected = 1) > 1
	begin
	select @ret = 1, @msg = '不同账号的明细账目不能压缩在一起'
	goto RETURN_2
	end
if @operation like 'F%' and (select count(1) from account_temp where pc_id = @pc_id and mdi_id = @mdi_id and selected = 1) < 2
	begin
	select @ret = 1, @msg = '至少要两条明细账才能压缩在一起'
	goto RETURN_2
	end
if exists(select 1 from account_temp a, ar_detail b
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 and a.accnt = b.accnt and a.number = b.number and b.audit = '0')
	begin
	select @ret = 1, @msg = '未审核账目不能压缩'
	goto RETURN_2
	end
if exists(select 1 from account_temp a, ar_account b
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 and a.accnt = b.ar_accnt and a.number = b.ar_inumber and b.bdate = @bdate)
	begin
	select @ret = 1, @msg = '当天发生、调整或转帐的账目不能压缩'
	goto RETURN_2
	end
--
delete ar_compress where pc_id = @pc_id and mdi_id = @mdi_id
begin tran
save tran transfer
exec p_GetAccnt1 @type = 'BIL', @accnt = @billno out
select @billno = 'Z' + substring(@billno, 2, 9), @ret = 0
-- 锁住相关账号
update ar_master set sta = sta from account_temp a where ar_master.accnt = a.accnt
select @quantity = count(1), @charge = sum(b.charge), @credit = sum(b.credit), @charge0 = sum(b.charge0), @credit0 = sum(b.credit0),
	@charge1 = sum(b.charge1), @credit1 = sum(b.credit1), @charge9 = sum(b.charge9), @credit9 = sum(b.credit9)
	from account_temp a, ar_detail b
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 and a.accnt = b.accnt and a.number = b.number
exec @ret = p_gl_ar_update_balance @accnt, 0, 0, @lastnumb out, @ar_pnumber out, @balance out, 'YY', @msg out
-- ar_detail
insert ar_detail(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, audit, 
	quantity, charge, credit, charge0, credit0, charge1, credit1, charge9, credit9, balance, shift, empno, crradjt, tag, reason, guestname, guestname2, ref, ref1, ref2)
	select @accnt, @subaccnt, @lastnumb, @lastnumb, '02', @log_date, @bdate, @bdate, @pccode, @argcode, '1', 
	1, @charge, @credit, @charge0, @credit0, @charge1, @credit1, @charge9, @credit9, @balance, @shift, @empno, '', 'Z', '', @guestname, @guestname2, @ref, @billno, @ref2
update ar_detail set pnumber  = @lastnumb from account_temp a
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 and a.accnt = ar_detail.accnt and a.number = ar_detail.number
insert har_detail select b.* from account_temp a, ar_detail b
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 and a.accnt = b.accnt and a.number = b.number
delete ar_detail from account_temp a
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 and a.accnt = ar_detail.accnt and a.number = ar_detail.number
-- ar_account
insert ar_account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
	quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
	crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, 
	ar_accnt, ar_subaccnt, ar_number, ar_inumber, ar_tag, ar_subtotal, charge9, credit9)
	values(@accnt, @subaccnt, @ar_pnumber, @ar_pnumber, '02', @log_date, @bdate, @bdate, @pccode, @argcode, 
	@quantity, @charge, @charge, 0, 0, 0, 0, 0, 0, 0, @credit, @balance, @shift, @empno,
	'', '', '', '', @ref, @billno, @ref2, '', '', '', '', 
	@accnt, @subaccnt, @ar_pnumber, @lastnumb, 'Z', 'T', @charge9, @credit9)
-- 按类别日期汇总(增加日期是为了账龄表的准确)
if @operation like 'F%'
	insert ar_compress select @pc_id, @mdi_id, b.pccode, b.bdate, @billno, @ref2, b.ar_subtotal, sum(b.quantity),
		sum(b.charge), sum(b.charge1), sum(b.charge2), sum(b.charge3), sum(b.charge4), sum(b.charge5),
		sum(b.package_d), sum(b.package_c), sum(b.package_a), sum(b.credit), sum(b.charge9), sum(b.credit9)
		from account_temp a, ar_account b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 and a.accnt = b.ar_accnt and a.number = b.ar_inumber
		group by b.pccode, b.bdate, b.ar_subtotal
else
	insert ar_compress select @pc_id, @mdi_id, b.pccode, b.bdate, b.ref1, b.ref2, b.ar_subtotal,
		b.quantity, b.charge, b.charge1, b.charge2, b.charge3, b.charge4, b.charge5,
		b.package_d, b.package_c, b.package_a, b.credit, b.charge9, b.credit9
		from account_temp a, ar_account b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 and a.accnt = b.ar_accnt and a.number = b.ar_inumber
declare c_pccode cursor for
	select a.pccode, a.bdate, b.descript, a.ref1, a.ref2, a.quantity, a.charge, a.charge1, a.charge2, a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, a.credit, a.charge9, a.credit9
	from ar_compress a, pccode b where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.ar_subtotal = 'F' and a.pccode *= b.pccode
	order by pccode
open c_pccode
fetch c_pccode into @pccode, @date, @ref, @ref1, @ref2, @quantity, @charge, @charge1, @charge2, @charge3, @charge4, @charge5, @package_d, @package_c, @package_a, @credit, @charge9, @credit9
while @@sqlstatus = 0
	begin
	exec @ret = p_gl_ar_update_balance @accnt, 0, 0, @lastnumb out, @lastinumb out, @balance out, 'NY', @msg out
	insert ar_account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
		quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
		crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, 
		ar_accnt, ar_subaccnt, ar_number, ar_inumber, ar_pnumber, ar_tag, charge9, credit9)
		values(@accnt, @subaccnt, @lastinumb, @lastinumb, '02', @log_date, @date, @date, @pccode, @argcode, 
		@quantity, @charge, @charge1, @charge2, @charge3, @charge4, @charge5, @package_d, @package_c, @package_a, @credit, @balance, @shift, @empno,
		'', '', '', '', @ref, @ref1, @ref2, '', '', '', '', 
		@accnt, @subaccnt, @lastinumb, @lastnumb, @ar_pnumber, 'z', @charge9, @credit9)
	fetch c_pccode into @pccode, @date, @ref, @ref1, @ref2, @quantity, @charge, @charge1, @charge2, @charge3, @charge4, @charge5, @package_d, @package_c, @package_a, @credit, @charge9, @credit9
	end
close c_pccode
deallocate cursor c_pccode
insert har_account select b.* from account_temp a, ar_account b
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 and a.accnt = b.ar_accnt and a.number = b.ar_inumber
delete ar_account from account_temp a
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.selected = 1 and a.accnt = ar_account.ar_accnt and a.number = ar_account.ar_inumber
--
RETURN_1:
if @ret != 0
	rollback tran transfer
else
	begin
	insert billno (billno, accnt, bdate, empno1, shift1) 
		select @billno, min(accnt), @bdate, @empno, @shift 
		from account_temp where pc_id = @pc_id and mdi_id = @mdi_id
	update billno set empno2 = @empno, shift2 = @shift, date2 = @log_date where billno = @billno
	select @old = '', @new = @billno + '[' + rtrim(convert(char(10), @lastnumb)) + ']'
	insert into lgfl (columnname, accnt, old, new, empno, date)
		values ('a_compress', @accnt, @old, @new, @empno, @log_date)
	end
commit tran
RETURN_2:
if @operation like '_S%'
	select @ret, @msg
return @ret
;
