if exists(select * from sysobjects where name = "p_gl_ar_list_account")
	drop proc p_gl_ar_list_account;

create proc p_gl_ar_list_account
	@pc_id				char(4),						// IP地址
	@mdi_id				integer,						// 唯一的账务窗口ID
	@roomno				char(5),						// 房号
	@accnt				char(10),					// 账号
	@subaccnt			integer,						// 子账号(如果@roomno = '99999', @subaccnt就是临时账夹的编号)
	@operation			char(10),
	@langid				integer = 0
as
declare
	@selected			integer

if @operation = 'ahead'
	select @selected = 1
else
	begin
	delete account_temp where pc_id = @pc_id and mdi_id = @mdi_id
	select * into #ar_detail from ar_detail where accnt = @accnt
	if @operation != 'uncheckout'
				insert #ar_detail	select * from har_detail where accnt = @accnt

	// 团体主单
	if @roomno = '' and @accnt != ''
		begin
		if @subaccnt = 0
			begin
			insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, charge, credit)
				select @pc_id, @mdi_id, accnt, number, mode1, billno, charge + charge0 - charge9, credit + credit0 - credit9 from #ar_detail
				where accnt = @accnt
			end
		else
			begin
			insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, charge, credit)
				select @pc_id, @mdi_id, accnt, number, mode1, billno, charge + charge0 - charge9, credit + credit0 - credit9 from #ar_detail
				where accnt = @accnt and subaccnt = @subaccnt
			end
		end
	// 所有
	else if @roomno = ''
		begin
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, charge, credit)
			select @pc_id, @mdi_id, a.accnt, a.number, a.mode1, a.billno, a.charge + a.charge0 - a.charge9, a.credit + a.credit0 - a.credit9 from #ar_detail a, accnt_set b
			where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.subaccnt = @subaccnt and a.accnt = b.accnt
		end
	// 临时账夹
	else if @roomno = '99999'
		begin
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, charge, credit)
			select @pc_id, @mdi_id, a.accnt, a.number, a.mode1, a.billno, a.charge + a.charge0 - a.charge9, a.credit + a.credit0 - a.credit9 from #ar_detail a, account_folder b
			where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.folder = @subaccnt and a.accnt = b.accnt and a.number = b.number
		end
	// 指定房间
	else if @accnt = ''
		begin
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, charge, credit)
			select @pc_id, @mdi_id, a.accnt, a.number, a.mode1, a.billno, a.charge + a.charge0 - a.charge9, a.credit + a.credit0 - a.credit9 from #ar_detail a, accnt_set b
			where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.roomno = @roomno and b.subaccnt = 0 and b.accnt = a.accnt
		end
	// 指定账号
	else if @subaccnt = 0
		begin
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, charge, credit)
			select @pc_id, @mdi_id, accnt, number, mode1, billno, charge + charge0 - charge9, credit + credit0 - credit9 from #ar_detail
			where accnt = @accnt
		end
	// 指定账夹
	else
		begin
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, charge, credit)
			select @pc_id, @mdi_id, accnt, number, mode1, billno, charge + charge0 - charge9, credit + credit0 - credit9 from #ar_detail
			where accnt = @accnt and subaccnt = @subaccnt
		end
	// 删除已被选入临时账夹的明细账务
	if @roomno != '99999'
		delete account_temp from account_folder a where account_temp.pc_id = a.pc_id and account_temp.mdi_id = a.mdi_id
			and account_temp.accnt = a.accnt and account_temp.number = a.number and a.pc_id = @pc_id and a.mdi_id = @mdi_id
	if @operation = 'uncheckout'
		delete account_temp where pc_id = @pc_id and mdi_id = @mdi_id and charge = 0 and credit = 0
	select @selected = 0
	end
// 返回结果
if @langid = 0
	select a.accnt, a.subaccnt, a.number, a.pccode, a.argcode, a.empno, a.shift, a.log_date, a.guestname, a.guestname2, a.ref, a.ref1, a.ref2,
		a.modu_id, a.charge, a.credit,a.charge0, a.credit0,a.charge9, a.credit9, a.disputed, a.accntof,
		crradjt, package, tran_accnt = a.tofrom + a.accntof, a.bdate, a.date, a.roomno, a.billno, a.audit, ar_tag = tag, @selected, tag = ''
		from #ar_detail a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.pnumber = 0
		order by a.log_date
else
	select a.accnt, a.subaccnt, a.number, a.pccode, a.argcode, a.empno, a.shift, a.log_date, a.guestname, a.guestname2, isnull(c.descript1, a.ref), a.ref1, a.ref2,
		a.modu_id, a.charge, a.credit,a.charge0, a.credit0,a.charge9, a.credit9, a.disputed, a.accntof,
		crradjt, package, tran_accnt = a.tofrom + a.accntof, a.bdate, a.date, a.roomno, a.billno, a.audit, ar_tag = tag, @selected, tag = ''
		from #ar_detail a, account_temp b, pccode c
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.pnumber = 0 and a.pccode *= c.pccode
		order by a.log_date
return
;
