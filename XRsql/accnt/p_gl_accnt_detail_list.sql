if exists(select * from sysobjects where name = 'p_gl_accnt_detail_list' and type = 'P')
	drop proc p_gl_accnt_detail_list;

create proc p_gl_accnt_detail_list
	@date						datetime,
	@empno					char(10),
	@shift					char(1),
	@type						char(15),
	@langid					integer = 0,
	@option					char(10) = 'ALL'		-- FRONT:前台,AR:AR账,ALL:所有
as

if rtrim(@empno) is null
	select @empno = '%'
if rtrim(@shift) is null
	select @shift = '%'
-- 准备明细账
select *, name = space(50) into #account from account where 1 = 2
if @type like 'CHECKOUT%'
	begin
	if @option in ('FRONT', 'ALL')
		insert #account select a.*, space(50) from account a, billno b
			where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'B%' and a.billno = b.billno
			union select a.*, space(50) from haccount a, billno b
			where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'B%' and a.billno = b.billno
	if @option in ('AR', 'ALL')
		begin
		create table #ar_apply
		(
			d_accnt		char(10)		not null,
			d_inumber	integer		not null,
			c_accnt		char(10)		not null,
			c_inumber	integer		not null,
			amount		money			default 0 not null,
			billno		char(10)		not null
		)
		insert #ar_apply select a.d_accnt, a.d_inumber, '', 0, isnull(sum(a.amount), 0), a.billno
			from ar_apply a, billno b
			where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'B%' and a.billno = b.billno
			group by a.d_accnt, a.d_inumber, a.billno
		insert #ar_apply select '', 0, a.c_accnt, a.c_inumber, isnull(sum(a.amount), 0), a.billno
			from ar_apply a, billno b
			where b.bdate = @date and b.empno1 like @empno and b.shift1 like @shift and b.billno like 'B%' and a.billno = b.billno
			group by a.c_accnt, a.c_inumber, a.billno
		delete #ar_apply where d_accnt = '' and d_inumber = 0 and c_accnt = '' and c_inumber = 0
		
		insert #account (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
			charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
			tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
			select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, b.amount, a.charge1, a.charge2,
			a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, a.credit, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
			a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
			from ar_account a, #ar_apply b where b.d_accnt = a.ar_accnt and b.d_inumber = a.ar_number
			union select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, b.amount, a.charge1, a.charge2,
			a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, a.credit, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
			a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
			from har_account a, #ar_apply b where b.d_accnt = a.ar_accnt and b.d_inumber = a.ar_number
		insert #account (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
			charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
			tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
			select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, a.charge, a.charge1, a.charge2,
			a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, b.amount, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
			a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
			from ar_account a, #ar_apply b where b.c_accnt = a.ar_accnt and b.c_inumber = a.ar_number
			union select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, a.charge, a.charge1, a.charge2,
			a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, b.amount, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.tag, a.reason,
			a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, b.billno
			from har_account a, #ar_apply b where b.c_accnt = a.ar_accnt and b.c_inumber = a.ar_number
		end
	end
else
	begin
	if @option in ('FRONT', 'ALL')
		insert #account select *, space(50) from account where bdate = @date and empno like @empno and shift like @shift
			union select *, space(50) from haccount where bdate = @date and empno like @empno and shift like @shift
	if @option in ('AR', 'ALL')
		insert #account (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
			charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
			tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno, name)
		select accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
			charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
			tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno, space(50)
			from ar_account where bdate = @date and empno like @empno and shift like @shift and ar_tag = 'A'
		union select accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
			charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
			tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno, space(50)
			from har_account where bdate = @date and empno like @empno and shift like @shift and ar_tag = 'A'
	end
-- 名称
update #account set name = b.name from master a, guest b where #account.accnt = a.accnt and a.haccnt = b.no
update #account set name = b.name from hmaster a, guest b where #account.accnt = a.accnt and a.haccnt = b.no
update #account set name = b.name from ar_master a, guest b where #account.accnt = a.accnt and a.haccnt = b.no
update #account set name = b.name from har_master a, guest b where #account.accnt = a.accnt and a.haccnt = b.no
--
if @type = 'CHECKOUT'
 begin
  if @langid = 0 
		select billno, roomno, accnt, name, log_date, ref, charge, credit, ref2, ref1,
		char12 = isnull(rtrim(tofrom), '--') + accntof, pccode, argcode, reason, crradjt, number, empno, shift
		from #account
		order by billno, roomno, accnt, pccode
   else
		select a.billno, a.roomno, a.accnt, a.name, a.log_date, b.descript1, a.charge, a.credit, a.ref2, a.ref1,
		char12 = isnull(rtrim(a.tofrom), '--') + a.accntof, a.pccode, a.argcode, a.reason, a.crradjt, a.number, a.empno, a.shift
		from #account a,pccode b where a.pccode *= b.pccode
		order by a.billno, a.roomno, a.accnt, a.pccode
  end 
else if @type = 'CHECKOUT_CREDIT'
 begin
  if @langid = 0 
		select billno, roomno, accnt, name, log_date, ref, charge, credit, ref2, ref1,
		char12 = isnull(rtrim(tofrom), '--') + accntof, pccode, argcode, reason, crradjt, number, empno, shift
		from #account where pccode > '9'
		order by billno, roomno, accnt, number
	else
		select a.billno, a.roomno, a.accnt, a.name, a.log_date, b.descript1, a.charge, a.credit, a.ref2, a.ref1,
		char12 = isnull(rtrim(a.tofrom), '--') + a.accntof, a.pccode, a.argcode, a.reason, a.crradjt, a.number, a.empno, a.shift
		from #account a,pccode b  where a.pccode > '9' and a.pccode *= b.pccode
		order by a.billno, a.roomno, a.accnt, a.number
 end

else if @type = 'POST'   -- 按照费用码排序，客户端有分组
	begin
		 if @langid = 0 
			select roomno, accnt, name, log_date, ref, charge, credit, ref2, ref1,
			char12 = isnull(rtrim(tofrom), '--') + accntof, pccode, argcode, reason, crradjt, number, empno, shift
			from #account where (crradjt in ('', 'AD', 'SP', 'CT') or (crradjt like 'L%' and tofrom = '')) and pccode<>'9'
			order by pccode, roomno, accnt
		 else
			select a.roomno, a.accnt, a.name, a.log_date, b.descript1, a.charge, a.credit, a.ref2, a.ref1,
			char12 = isnull(rtrim(a.tofrom), '--') + a.accntof, a.pccode, a.argcode, a.reason, a.crradjt, a.number, a.empno, a.shift
			from #account a,pccode b where a.pccode *=b.pccode  and (a.crradjt in ('', 'AD', 'SP', 'CT') or (a.crradjt like 'L%' and a.tofrom = '')) and a.pccode<>'9'
			order by a.pccode, a.roomno, a.accnt
	end
else if @type = 'POST_CREDIT'   -- 按照费用码排序，客户端有分组
	begin
		 if @langid = 0 
			select roomno, accnt, name, log_date, ref, charge, credit, ref2, ref1,
			char12 = isnull(rtrim(tofrom), '--') + accntof, pccode, argcode, reason, crradjt, number, empno, shift
			from #account where pccode > '9' and (crradjt in ('', 'AD', 'SP', 'CT') or (crradjt like 'L%' and tofrom = ''))
			order by pccode, tag, credit
	   else
			select a.roomno, a.accnt, a.name, a.log_date, b.descript1, a.charge, a.credit, a.ref2, a.ref1,
			char12 = isnull(rtrim(a.tofrom), '--') + a.accntof, a.pccode, a.argcode, a.reason, a.crradjt, a.number, a.empno, a.shift
			from #account a,pccode b where a.pccode *=b.pccode and a.pccode > '9' and (a.crradjt in ('', 'AD', 'SP', 'CT') or (a.crradjt like 'L%' and a.tofrom = ''))
			order by a.pccode, a.tag, a.credit
	end 
else if @type = 'POST_ADJUST'  -- 排序标记 billno, 尽量成对出现
	begin
		 if @langid = 0 
			select a.roomno, a.accnt, a.name, a.log_date, a.ref, a.charge, a.credit, a.ref2, a.ref1,
			char12 = isnull(rtrim(a.tofrom), '--') + a.accntof, a.pccode, a.argcode, a.reason, a.crradjt, a.number, a.empno, a.shift
			from #account a, pccode b where a.pccode = b.pccode and (a.crradjt in ('C', 'CO', 'AD') or b.deptno8 = 'RB')
			order by a.roomno, a.accnt, a.pccode, a.billno, a.number
		 else
			select a.roomno, a.accnt, a.name, a.log_date, b.descript1, a.charge, a.credit, a.ref2, a.ref1,
			char12 = isnull(rtrim(a.tofrom), '--') + a.accntof, a.pccode, a.argcode, a.reason, a.crradjt, a.number, a.empno, a.shift
			from #account a, pccode b where a.pccode = b.pccode and ((a.crradjt in ('C', 'CO', 'AD') or b.deptno8 = 'RB'))
			order by a.roomno, a.accnt, a.pccode, a.billno, a.number
	end
;
