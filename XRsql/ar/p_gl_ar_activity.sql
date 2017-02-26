if exists (select * from sysobjects where name ='p_gl_ar_activity' and type ='P')
	drop proc p_gl_ar_activity;
create proc p_gl_ar_activity
	@accnt			char(10), 
	@number			integer,
	@langid			integer = 0
as
declare
	@ref				varchar(50),
	@pay_for			varchar(20),
	@pay_by			varchar(20),
	@cnumber			integer
--
create table #detail1
(
	roomno			char(5)		null,
	guestname		char(50)		null,
	guestname2		char(50)		null,
	ref				char(50)		null,
	ref1				char(10)		null,
	ref2				char(100)	null,
	pccode			char(5)		null,
	bdate				datetime		null,
	charge			money			null,				// 消费
	credit			money			null,				// 付款
	apply_charge	money			null,				// 已核销消费
	apply_credit	money			null,				// 已核销付款
	empno				char(10)		null,
	shift				char(1)		null,
	date				datetime		null,
	log_date			datetime		null,
	billno			char(10)		null,
	apply_empno		char(10)		null,
	apply_shift		char(1)		null,
	apply_bdate		datetime		null,
	apply_date		datetime		null,
	ar_accnt			char(10)		null,
	ar_number		integer		null,
	ar_inumber		integer		null,
	ar_tag			char(10)		null,
	ar_subtotal		char(1)		null,
	ar_pnumber		integer		null,
	ar_date			datetime		null
)
select * into #detail2 from #detail1
if @langid = 0
	select @ref = '核销', @pay_for = 'Pay for ', @pay_by = 'Pay by '
else
	select @ref = 'Check Out', @pay_for = 'Pay for ', @pay_by = 'Pay by '
--
if @number = 0																				-- All Activity
	begin
	insert #detail2 (ref, ref1, ref2, pccode, bdate, charge, credit, apply_charge, apply_credit, empno, shift, date, log_date, billno, ar_accnt, ar_number, ar_inumber, ar_tag, ar_subtotal, ar_pnumber)
		select ref, ref1, ref2, pccode, bdate, charge, credit, charge9, credit9, empno, shift, date, log_date, billno, ar_accnt, ar_number, ar_inumber, ar_tag, ar_subtotal, ar_pnumber
		from ar_account where ar_accnt = @accnt
	insert #detail2 (ref, ref1, ref2, pccode, bdate, charge, credit, apply_charge, apply_credit, empno, shift, date, log_date, billno, ar_accnt, ar_number, ar_inumber, ar_tag, ar_subtotal, ar_pnumber)
		select ref, ref1, ref2, pccode, bdate, charge, credit, charge9, credit9, empno, shift, date, log_date, billno, ar_accnt, ar_number, ar_inumber, ar_tag, ar_subtotal, ar_pnumber
		from har_account where ar_accnt = @accnt
	-- 时间同步
	update #detail2 set ar_date = a.log_date from ar_detail a where #detail2.ar_accnt = a.accnt and #detail2.ar_inumber = a.number
	update #detail2 set ar_date = a.log_date from har_detail a where #detail2.ar_accnt = a.accnt and #detail2.ar_inumber = a.number
	update #detail2 set ar_tag = 'ZIP' where ar_tag = 'Z'
	--
--	insert #detail2 (ref, ref1, ref2, pccode, bdate, charge, credit, apply_charge, apply_credit, empno, shift, date, log_date, ar_accnt, ar_number, ar_inumber, ar_tag, apply_empno, apply_shift, apply_bdate, apply_date, ar_date)
--		select @ref, billno, '', '', bdate, 0, 0, sum(amount), 0, empno, shift, bdate, log_date, @accnt, 0, 0, 'C/O', empno, shift, bdate, log_date, log_date
--		from ar_apply where d_accnt = @accnt or c_accnt = @accnt group by billno, bdate, empno, shift, log_date
-- 新核销
	insert #detail2 (ref, ref1, ref2, pccode, bdate, charge, credit, apply_charge, apply_credit, empno, shift, date, log_date, ar_accnt, ar_number, ar_inumber, ar_tag, apply_empno, apply_shift, apply_bdate, apply_date, ar_date)
		select @ref, billno, '', '', bdate, 0, 0, sum(amount), 0, empno, shift, bdate, log_date, @accnt, 0, 0, 'C/O', empno, shift, bdate, log_date, log_date
		from ar_apply where d_accnt = @accnt and c_accnt = @accnt group by billno, bdate, empno, shift, log_date
	insert #detail2 (ref, ref1, ref2, pccode, bdate, charge, credit, apply_charge, apply_credit, empno, shift, date, log_date, ar_accnt, ar_number, ar_inumber, ar_tag, apply_empno, apply_shift, apply_bdate, apply_date, ar_date)
		select @ref, billno, '', '', bdate, 0, 0, sum(amount) / 2, 0, empno, shift, bdate, log_date, @accnt, 0, 0, 'C/O', empno, shift, bdate, log_date, log_date
		from ar_apply where (d_accnt = @accnt and c_accnt = '') or (d_accnt = '' and c_accnt = @accnt)
		group by billno, bdate, empno, shift, log_date
	end
else
	begin
	if @number < 0																			-- 压缩明细
		declare c_activity cursor for
			select number from har_detail where accnt = @accnt and pnumber = - @number
			union select number from har_detail where accnt = @accnt and pnumber = - @number
	else																						-- Activity
		declare c_activity cursor for
			select number from ar_detail where accnt = @accnt and number = @number
			union select number from har_detail where accnt = @accnt and number = @number
	open c_activity
	fetch c_activity into @cnumber
	while @@sqlstatus = 0
		begin
		truncate table #detail1
		insert #detail1 (ref, ref1, ref2, pccode, bdate, charge, credit, apply_charge, apply_credit, empno, shift, date, log_date, billno, ar_accnt, ar_number, ar_inumber, ar_tag, ar_subtotal, ar_pnumber)
			select ref, ref1, ref2, pccode, bdate, charge, credit, charge9, credit9, empno, shift, date, log_date, billno, ar_accnt, ar_number, ar_inumber, ar_tag, ar_subtotal, ar_pnumber
			from ar_account where ar_accnt = @accnt and ar_inumber = @cnumber
		insert #detail1 (ref, ref1, ref2, pccode, bdate, charge, credit, apply_charge, apply_credit, empno, shift, date, log_date, billno, ar_accnt, ar_number, ar_inumber, ar_tag, ar_subtotal, ar_pnumber)
			select ref, ref1, ref2, pccode, bdate, charge, credit, charge9, credit9, empno, shift, date, log_date, billno, ar_accnt, ar_number, ar_inumber, ar_tag, ar_subtotal, ar_pnumber
			from har_account where ar_accnt = @accnt and ar_inumber = @cnumber
		-- 时间同步
		update #detail1 set ar_date = a.log_date from ar_detail a where #detail1.ar_accnt = a.accnt and #detail1.ar_inumber = a.number
		update #detail1 set ar_date = a.log_date from har_detail a where #detail1.ar_accnt = a.accnt and #detail1.ar_inumber = a.number
		-- Pay By (当前)
		insert #detail1 (ref, ref1, ref2, pccode, bdate, charge, credit, apply_charge, apply_credit, empno, shift, date, log_date, ar_number, ar_inumber, ar_tag, ar_date)
			select @pay_by + a.ref, c.billno, @pay_by + isnull(rtrim(a.roomno), rtrim(a.accntof)) + '/' + a.guestname + '/' + a.ref2,
			a.pccode, c.bdate, 0, b.credit, 0, sum(c.amount), c.empno, c.shift, c.bdate, c.log_date, a.number, a.number, 'C/O', c.log_date
			from ar_detail a, ar_account b, ar_apply c
			where c.d_accnt = @accnt and c.d_number = @cnumber and a.accnt = c.c_accnt and a.number = c.c_number and b.ar_accnt = c.c_accnt and b.ar_number = c.c_inumber
			group by a.ref, c.billno, a.roomno, a.accntof, a.guestname, a.ref2, a.pccode, c.bdate, b.credit, c.empno, c.shift, c.bdate, c.log_date, a.number, a.number
		-- Pay By (历史)
		insert #detail1 (ref, ref1, ref2, pccode, bdate, charge, credit, apply_charge, apply_credit, empno, shift, date, log_date, ar_number, ar_inumber, ar_tag, ar_date)
			select @pay_by + a.ref, c.billno, @pay_by + isnull(rtrim(a.roomno), rtrim(a.accntof)) + '/' + a.guestname + '/' + a.ref2,
			a.pccode, c.bdate, 0, b.credit, 0, sum(c.amount), c.empno, c.shift, c.bdate, c.log_date, a.number, a.number, 'C/O', c.log_date
			from har_detail a, har_account b, ar_apply c
			where c.d_accnt = @accnt and c.d_number = @cnumber and a.accnt = c.c_accnt and a.number = c.c_number and b.ar_accnt = c.c_accnt and b.ar_number = c.c_inumber
			group by a.ref, c.billno, a.roomno, a.accntof, a.guestname, a.ref2, a.pccode, c.bdate, b.credit, c.empno, c.shift, c.bdate, c.log_date, a.number, a.number
		-- Pay For (当前)
		insert #detail1 (ref, ref1, ref2, pccode, bdate, charge, credit, apply_charge, apply_credit, empno, shift, date, log_date, ar_accnt, ar_number, ar_inumber, ar_tag, apply_empno, apply_shift, apply_bdate, apply_date, ar_date)
			select @pay_for + '[' + isnull(rtrim(a.roomno), rtrim(a.accntof)) + ']' + a.guestname, c.billno, a.ref2,
			a.pccode, c.bdate, a.charge + a.charge0, 0, sum(c.amount), 0, c.empno, c.shift, c.bdate, c.log_date, a.accnt, a.number, a.number, 'C/O', c.empno, c.shift, c.bdate, c.log_date, c.log_date
			from ar_detail a, ar_apply c where c.c_accnt = @accnt and c.c_number = @cnumber and a.accnt = c.d_accnt and a.number = c.d_number
			group by a.roomno, a.accntof, a.guestname, c.billno, a.ref2, a.pccode, a.charge, a.charge0, c.bdate, c.empno, c.shift, c.bdate, c.log_date, a.accnt, a.number
		-- Pay For (历史)
		insert #detail1 (ref, ref1, ref2, pccode, bdate, charge, credit, apply_charge, apply_credit, empno, shift, date, log_date, ar_accnt, ar_number, ar_inumber, ar_tag, apply_empno, apply_shift, apply_bdate, apply_date, ar_date)
			select @pay_for + '[' + isnull(rtrim(a.roomno), rtrim(a.accntof)) + ']' + a.guestname, c.billno, a.ref2,
			a.pccode, c.bdate, a.charge + a.charge0, 0, sum(c.amount), 0, c.empno, c.shift, c.bdate, c.log_date, a.accnt, a.number, a.number, 'C/O', c.empno, c.shift, c.bdate, c.log_date, c.log_date
			from har_detail a, ar_apply c where c.c_accnt = @accnt and c.c_number = @cnumber and a.accnt = c.d_accnt and a.number = c.d_number
			group by a.roomno, a.accntof, a.guestname, c.billno, a.ref2, a.pccode, a.charge, a.charge0, c.bdate, c.empno, c.shift, c.bdate, c.log_date, a.accnt, a.number
		insert #detail2 select * from #detail1
		fetch c_activity into @cnumber
		end
	close c_activity
	deallocate cursor c_activity
	end
--
update #detail2 set #detail2.roomno = a.roomno, #detail2.guestname = a.guestname, #detail2.guestname2 = a.guestname2
	from ar_detail a where #detail2.ar_tag in ('A', 'P', 'T') and #detail2.ar_accnt = a.accnt and #detail2.ar_inumber = a.number
update #detail2 set #detail2.roomno = a.roomno, #detail2.guestname = a.guestname, #detail2.guestname2 = a.guestname2
	from har_detail a where #detail2.ar_tag in ('A', 'P', 'T') and #detail2.ar_accnt = a.accnt and #detail2.ar_inumber = a.number
update #detail2 set ref2 = rtrim(guestname) + '/' + ref2 where not rtrim(guestname) is null
update #detail2 set ref2 = '[' + rtrim(roomno) + ']' + ref2 where not rtrim(roomno) is null
--
update #detail2 set charge = (select sum(a.charge) from #detail2 a
	where a.ar_accnt = #detail2.ar_accnt and a.ar_pnumber = #detail2.ar_number and a.ar_tag in ('p', 't')),
	credit = (select sum(b.credit) from #detail2 b
	where b.ar_accnt = #detail2.ar_accnt and b.ar_pnumber = #detail2.ar_number and b.ar_tag in ('p', 't'))
	where ar_tag in ('P', 'T') and ar_subtotal = 'T'
--
if @langid = 0
	select ref, ref1, ref2, pccode, bdate, charge, credit, apply_charge, apply_credit, empno, shift, date, log_date, 
		billno, apply_empno, apply_shift, apply_bdate, apply_date, ar_tag, ar_number, ar_inumber, ar_date, selected = 0
		from #detail2 order by ar_date, ar_inumber, ar_number
else
	select isnull(b.descript1, a.ref), a.ref1, a.ref2, a.pccode, a.bdate, a.charge, a.credit, a.apply_charge, a.apply_credit, a.empno, a.shift, a.date, a.log_date,
		a.billno, a.apply_empno, a.apply_shift, a.apply_bdate, a.apply_date, a.ar_tag, a.ar_number, a.ar_inumber, a.ar_date, selected = 0
		from #detail2 a, pccode b where a.pccode *= b.pccode order by a.ar_date, a.ar_inumber, a.ar_number
return 0
;
