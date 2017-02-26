// 为ar_audit准备原始明细账
if exists(select * from sysobjects where name = "p_gl_ar_preaudit2")
	drop proc p_gl_ar_preaudit2;

create proc p_gl_ar_preaudit2
	@pc_id				char(4),
	@mdi_id				integer,
	@accnt				char(10),					// 账号
	@number				integer,						// 账次
	@empno				char(10),
	@shift				char(1),
	@option				char(2)						// 选项
as
declare
	@accntof				char(10),
	@ref					char(24),
	@ref1					char(10),
	@pccode				char(5),
	@pccode_charge		char(5),
	@pccode_credit		char(5),
	@argcode				char(2),
	@bdate				datetime,
	@date					datetime,
	@caccnt				char(10),
	@count				integer

delete ar_audit where pc_id = @pc_id and mdi_id = @mdi_id and type = 'T'
select @accntof = accntof, @bdate = bdate, @date = date, @ref1 = ref1
	from ar_detail where accnt = @accnt and number = @number
if @option = '1'
	insert ar_audit(pc_id, mdi_id, type, accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
		quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
		crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, billno)
		select pc_id, mdi_id, 'T', accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
		quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
		crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, billno
		from ar_audit where pc_id = @pc_id and mdi_id = @mdi_id and type = 'F'
else if @option = '2'
	begin
	--
	select * into #ar_audit from ar_audit where 1 = 2
//	insert #ar_audit(pc_id, mdi_id, type, accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
//		quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
//		crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber)
//		select @pc_id, @mdi_id, 'T', @accntof, 1, 0, 0, '02', getdate(), @bdate, @date, pccode, argcode, 
//		sum(quantity), sum(charge), sum(charge1), sum(charge2), sum(charge3), sum(charge4), sum(charge5), sum(package_d), sum(package_c), sum(package_a), sum(credit), 0, 
//		@shift, @empno, '', '', '', '', '', '', 0, ref, @ref1, '', '', '', '', '', 0
//		from ar_audit where pc_id = @pc_id and mdi_id = @mdi_id and type = 'F'
//		group by pccode, argcode, ref
	insert #ar_audit(pc_id, mdi_id, type, accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
		quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
		crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, billno)
		select @pc_id, @mdi_id, 'T', @accntof, 1, 0, 0, '02', getdate(), @bdate, @date, b.pccode, b.argcode, 
		sum(a.quantity), sum(a.charge), sum(a.charge1), sum(a.charge2), sum(a.charge3), sum(a.charge4), sum(a.charge5), sum(a.package_d), sum(a.package_c), sum(package_a), sum(a.credit), 0, 
		@shift, @empno, '', '', '', '', '', '', 0, b.descript, a.billno, '', '', '', '', '', 0, a.billno
		from ar_audit a, pccode b where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.type = 'F' and a.pccode = b.pccode
		group by b.pccode, b.argcode, b.descript, a.billno
	-- 补序号
	update #ar_audit set number = (select count(1) from #ar_audit a where a.pc_id = @pc_id and a.mdi_id = @mdi_id
		and a.type = 'T' and a.pccode <= #ar_audit.pccode) where pc_id = @pc_id and mdi_id = @mdi_id and type = 'T'
	--
	insert ar_audit select * from #ar_audit
	end
else if @option = '3'
	begin
	select @pccode_charge = value from sysoption where catalog = 'ar' and item = 'ar_account_pccode_charge'
	select @pccode_credit = value from sysoption where catalog = 'ar' and item = 'ar_account_pccode_credit'
	if exists (select 1 from pccode where pccode = @pccode_charge) and exists (select 1 from pccode where pccode = @pccode_credit)
		begin
		select @ref = descript, @argcode = argcode from pccode where pccode = @pccode_charge
		insert ar_audit(pc_id, mdi_id, type, accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
			quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
			crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, billno)
			select @pc_id, @mdi_id, 'T', @accntof, 1, 1, 1, '02', getdate(), @bdate, @date, @pccode_charge, @argcode, 
			count(1), sum(charge), sum(charge1), sum(charge2), sum(charge3), sum(charge4), sum(charge5), sum(package_d), sum(package_c), sum(package_a), 0, 0, 
			@shift, @empno, '', '', '', '', '', '', 0, @ref, billno, '', '', '', '', '', 0, billno
			from ar_audit where pc_id = @pc_id and mdi_id = @mdi_id and type = 'F'
			group by billno having sum(credit) <> 0
		select @ref = descript, @argcode = argcode from pccode where pccode = @pccode_credit
		insert ar_audit(pc_id, mdi_id, type, accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
			quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
			crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, billno)
			select @pc_id, @mdi_id, 'T', @accntof, 1, 2, 2, '02', getdate(), @bdate, @date, @pccode_credit, @argcode, 
			count(1), 0, 0, 0, 0, 0, 0, 0, 0, 0, sum(credit), 0, 
			@shift, @empno, '', '', '', '', '', '', 0, @ref, billno, '', '', '', '', '', 0, billno
			from ar_audit where pc_id = @pc_id and mdi_id = @mdi_id and type = 'F'
			group by billno having sum(credit) <> 0
		end
	else
		begin
		select @pccode = value from sysoption where catalog = 'ar' and item = 'ar_account_pccode'
		if not exists (select 1 from pccode where pccode = @pccode)
			select @pccode = min(pccode) from pccode
		select @ref = descript, @argcode = argcode from pccode where pccode = @pccode
		insert ar_audit(pc_id, mdi_id, type, accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
			quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
			crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, billno)
			select @pc_id, @mdi_id, 'T', @accntof, 1, 0, 0, '02', getdate(), @bdate, @date, @pccode, @argcode, 
			count(1), sum(charge) - sum(credit), sum(charge1) - sum(credit), sum(charge2), sum(charge3), sum(charge4), sum(charge5), sum(package_d), sum(package_c), sum(package_a), 0, 0, 
			@shift, @empno, '', '', '', '', '', '', 0, @ref, billno, '', '', '', '', '', 0, billno
			from ar_audit where pc_id = @pc_id and mdi_id = @mdi_id and type = 'F'
			group by billno
		end
	end
select 0, ''
return 0
;
