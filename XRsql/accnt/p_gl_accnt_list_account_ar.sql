if exists(select * from sysobjects where name = "p_gl_accnt_list_account_ar")
	drop proc p_gl_accnt_list_account_ar;

create proc p_gl_accnt_list_account_ar
	@pc_id				char(4),						-- IP地址
	@mdi_id				integer,						-- 唯一的账务窗口ID
	@roomno				char(5),						-- 房号
	@accnt				char(10),					-- 账号
	@subaccnt			integer,						-- 子账号(如果@roomno = '99999', @subaccnt就是临时账夹的编号)
	@operation			char(10),
	@langid				integer = 0
as
declare
	@selected			integer

-- 1.取出相关的结账单号
if @operation = 'ahead'
	select @selected = 1
else
	begin
	delete account_temp where pc_id = @pc_id and mdi_id = @mdi_id
	-- 团体主单
	if @roomno = '' and @accnt != ''
		begin
		if @subaccnt = 0
			begin
			insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
				select @pc_id, @mdi_id, accnt, number, mode1, billno, 0 from account
				where accnt = @accnt
			if @operation != 'uncheckout'
				insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
					select @pc_id, @mdi_id, accnt, number, mode1, billno, 0 from haccount
					where accnt = @accnt
			end
		else
			begin
			insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
				select @pc_id, @mdi_id, accnt, number, mode1, billno, 0 from account
				where accnt = @accnt and subaccnt = @subaccnt
			if @operation != 'uncheckout'
				insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
					select @pc_id, @mdi_id, accnt, number, mode1, billno, 0 from haccount
					where accnt = @accnt and subaccnt = @subaccnt
			end
		end
	-- 所有
	else if @roomno = ''
		begin
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
			select @pc_id, @mdi_id, a.accnt, a.number, a.mode1, a.billno, 0 from account a, accnt_set b
			where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.subaccnt = @subaccnt and a.accnt = b.accnt
		if @operation != 'uncheckout'
			insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
				select @pc_id, @mdi_id, a.accnt, a.number, a.mode1, a.billno, 0 from haccount a, accnt_set b
				where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.subaccnt = @subaccnt and a.accnt = b.accnt
		end
	-- 临时账夹
	else if @roomno = '99999'
		begin
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
			select @pc_id, @mdi_id, a.accnt, a.number, a.mode1, a.billno, 0 from account a, account_folder b
			where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.folder = @subaccnt and a.accnt = b.accnt and a.number = b.number
		if @operation != 'uncheckout'
			insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
				select @pc_id, @mdi_id, a.accnt, a.number, a.mode1, a.billno, 0 from haccount a, account_folder b
				where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.folder = @subaccnt and a.accnt = b.accnt and a.number = b.number
		end
	-- 指定房间
	else if @accnt = ''
		begin
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
			select @pc_id, @mdi_id, a.accnt, a.number, a.mode1, a.billno, 0 from account a, accnt_set b
			where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.roomno = @roomno and b.subaccnt = 0 and b.accnt = a.accnt
		if @operation != 'uncheckout'
			insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
				select @pc_id, @mdi_id, a.accnt, a.number, a.mode1, a.billno, 0 from haccount a, accnt_set b
				where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.roomno = @roomno and b.subaccnt = 0 and b.accnt = a.accnt
		end
	-- 指定账号
	else if @subaccnt = 0
		begin
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
			select @pc_id, @mdi_id, accnt, number, mode1, billno, 0 from account
			where accnt = @accnt
		if @operation != 'uncheckout'
			insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
				select @pc_id, @mdi_id, accnt, number, mode1, billno, 0 from haccount
				where accnt = @accnt
		end
	-- 指定账夹
	else
		begin
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
			select @pc_id, @mdi_id, accnt, number, mode1, billno, 0 from account
			where accnt = @accnt and subaccnt = @subaccnt
		if @operation != 'uncheckout'
			insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
				select @pc_id, @mdi_id, accnt, number, mode1, billno, 0 from haccount
				where accnt = @accnt and subaccnt = @subaccnt
		end
	-- 删除已被选入临时账夹的明细账务
	if @roomno != '99999'
		delete account_temp from account_folder a where account_temp.pc_id = a.pc_id and account_temp.mdi_id = a.mdi_id
			and account_temp.accnt = a.accnt and account_temp.number = a.number and a.pc_id = @pc_id and a.mdi_id = @mdi_id
	if @operation = 'uncheckout'
		delete account_temp where pc_id = @pc_id and mdi_id = @mdi_id and billno != ''
	select @selected = 0
	end
-- 生成中间结果
delete account_ar where pc_id = @pc_id and mdi_id = @mdi_id
-- 1.合并转帐帐务
insert account_ar (pc_id, mdi_id, sta, accnt, charge, credit, amount, amount1, ref, ref1, ref2, shift, empno, billno)
	select @pc_id, @mdi_id, 'F', a.accnt, sum(a.charge), sum(a.credit), sum(a.charge - a.credit), sum(a.charge - a.credit), 'Transfer from F/O', a.mode1, '', '', '', a.billno
	from account a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.mode1 like 'T%'
	group by a.accnt, a.mode1, a.billno
insert account_ar (pc_id, mdi_id, sta, accnt, charge, credit, amount, amount1, ref, ref1, ref2, shift, empno, billno)
	select @pc_id, @mdi_id, 'F', a.accnt, sum(a.charge), sum(a.credit), sum(a.charge - a.credit), sum(a.charge - a.credit), 'Transfer from F/O', a.mode1, '', '', '', a.billno
	from haccount a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.mode1 like 'T%'
	group by a.accnt, a.mode1, a.billno
update account_ar set bdate = convert(datetime, '200' + substring(ref1, 2, 1) + '/' + substring(ref1, 3, 2) + '/' + substring(ref1, 5, 2)),
	log_date = convert(datetime, '200' + substring(ref1, 2, 1) + '/' + substring(ref1, 3, 2) + '/' + substring(ref1, 5, 2))
	where pc_id = @pc_id and mdi_id = @mdi_id and ref1 like 'T[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
update account_ar set fmaccnt = a.accnt, shift = a.shift1, empno = a.empno1, bdate = a.bdate, log_date = a.date1
	from billno a
	where account_ar.pc_id = @pc_id and account_ar.mdi_id = @mdi_id and account_ar.ref1 = a.billno
update account_ar set fmroomno = a.roomno, ref2 = b.name
	from master a, guest b
	where account_ar.pc_id = @pc_id and account_ar.mdi_id = @mdi_id and account_ar.fmaccnt = a.accnt and a.haccnt = b.no
update account_ar set fmroomno = a.roomno, ref2 = b.name
	from hmaster a, guest b
	where account_ar.pc_id = @pc_id and account_ar.mdi_id = @mdi_id and account_ar.fmaccnt = a.accnt and a.haccnt = b.no
-- 2.其他帐务
if @langid = 0
	insert account_ar (pc_id, mdi_id, sta, accnt, number, modu_id, pccode, argcode, charge, credit, amount, amount1, ref, ref1, ref2, shift, empno, bdate, log_date, billno)
		select @pc_id, @mdi_id, 'P', a.accnt, a.number, a.modu_id, a.pccode, a.argcode, a.charge, a.credit, a.charge + a.credit, a.charge - a.credit, a.ref, a.ref1, a.ref2, a.shift, a.empno, a.bdate, a.log_date, a.billno
		from account a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.mode1 not like 'T%'
		union select @pc_id, @mdi_id, 'P', a.accnt, a.number, a.modu_id, a.pccode, a.argcode, a.charge, a.credit, a.charge + a.credit, a.charge - a.credit, a.ref, a.ref1, a.ref2, a.shift, a.empno, a.bdate, a.log_date, a.billno
		from haccount a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.mode1 not like 'T%'
else
	insert account_ar (pc_id, mdi_id, sta, accnt, number, modu_id, pccode, argcode, charge, credit, amount, amount1, ref, ref1, ref2, shift, empno, bdate, log_date, billno)
		select @pc_id, @mdi_id, 'P', a.accnt, a.number, a.modu_id, a.pccode, a.argcode, a.charge, a.credit, a.charge + a.credit, a.charge - a.credit, isnull(c.descript1, a.ref), a.ref1, a.ref2, a.shift, a.empno, a.bdate, a.log_date, a.billno
		from account a, account_temp b, pccode c
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.mode1 not like 'T%' and a.pccode *= c.pccode
		union select @pc_id, @mdi_id, 'P', a.accnt, a.number, a.modu_id, a.pccode, a.argcode, a.charge, a.credit, a.charge + a.credit, a.charge - a.credit, isnull(c.descript1, a.ref), a.ref1, a.ref2, a.shift, a.empno, a.bdate, a.log_date, a.billno
		from haccount a, account_temp b, pccode c
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.mode1 not like 'T%' and a.pccode *= c.pccode
update account_ar set sta = 'T' where pc_id = @pc_id and mdi_id = @mdi_id and sta = 'P' and modu_id != '02'
-- 返回结果
select sta, accnt, number, fmaccnt, fmroomno, modu_id, pccode, argcode, charge, credit, amount, amount1, ref, ref1, ref2, bdate, log_date, shift, empno, billno, selected = 0, tag = ''
	from account_ar where pc_id = @pc_id and mdi_id = @mdi_id order by log_date
return
;
