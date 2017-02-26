if exists(select * from sysobjects where name = 'p_gl_ar_detail_list' and type = 'P')
	drop proc p_gl_ar_detail_list;

create proc p_gl_ar_detail_list
	@date1					datetime,
	@date2					datetime,
	@empno					char(10),
	@shift					char(1),
	@langid					integer = 0,
	@option					char(10) = 'F/O'		-- F/O,POS,BOS
as

if rtrim(@empno) is null
	select @empno = '%'
if rtrim(@shift) is null
	select @shift = '%'
--
create table #pccode(pccode char(5) null) 
insert #pccode(pccode) select pccode from pccode where charindex('TOR', deptno2)>0

-- 准备明细账
select *, name = space(50), arname = space(50),sno=space(10) into #account from account where 1 = 2
if @option in ('F/O')
	begin
	insert #account select *, space(50), space(50),sno=space(10) from account
		where bdate >= @date1 and bdate <= @date2 and empno like @empno and shift like @shift
		union select *, space(50), space(50) ,sno=space(10) from haccount
		where bdate >= @date1 and bdate <= @date2 and empno like @empno and shift like @shift
	delete #account where pccode not in (select pccode from #pccode)
	-- 名称
	update #account set name = b.name from master a, guest b where #account.accnt = a.accnt and a.haccnt = b.no
	update #account set name = b.name from hmaster a, guest b where #account.accnt = a.accnt and a.haccnt = b.no
	update #account set name = b.name from ar_master a, guest b where #account.accnt = a.accnt and a.haccnt = b.no
	update #account set name = b.name from har_master a, guest b where #account.accnt = a.accnt and a.haccnt = b.no
	end
else if @option in ('POS')
	begin
	insert #account (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno, name, arname,sno)
		select menu, 0, 0, 0, '04', log_date, bdate, bdate, paycode, '99', amount, 0, 0, 0,
		0, 0, 0, 0, 0, 0, amount, 0, shift, empno, '', bank, '', '',
		'', accnt, 1, '', '', ref, roomno, '', '', '', '', '',''
		from pos_pay where bdate >= @date1 and bdate <= @date2 and empno like @empno and shift like @shift
		union select menu, 0, 0, 0, '04', log_date, bdate, bdate, paycode, '99', amount, 0, 0, 0,
		0, 0, 0, 0, 0, 0, amount, 0, shift, empno, '', bank, '', '',
		'', accnt, 1, '', '', ref, roomno, '', '', '', '', '',''
		from pos_hpay where bdate >= @date1 and bdate <= @date2 and empno like @empno and shift like @shift
	delete #account where pccode not in (select pccode from #pccode) 
	update #account set mode = a.pccode from pos_menu a where #account.accnt = a.menu
	update #account set mode = a.pccode from pos_hmenu a where #account.accnt = a.menu
	if @langid = 0
		update #account set name = a.descript from pos_pccode a where #account.mode = a.pccode
	else
		update #account set name = a.descript1 from pos_pccode a where #account.mode = a.pccode
	end
else if @option in ('BOS')
	begin
	insert #account (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno, name, arname,sno)
		select setnumb, 0, 0, 0, modu, log_date, bdate, bdate, code, '99', quantity, 0, 0, 0,
		0, 0, 0, 0, 0, 0, amount, 0, shift, empno, '', cardtype, '', '',
		'', accnt, 1, '', '', ref, room, '', '', '', '', '',''
		from bos_account where bdate >= @date1 and bdate <= @date2 and empno like @empno and shift like @shift
		union select setnumb, 0, 0, 0, modu, log_date, bdate, bdate, code, '99', quantity, 0, 0, 0,
		0, 0, 0, 0, 0, 0, amount, 0, shift, empno, '', cardtype, '', '',
		'', accnt, 1, '', '', ref, room, '', '', '', '', '',''
		from bos_haccount where bdate >= @date1 and bdate <= @date2 and empno like @empno and shift like @shift
	delete #account where pccode not in (select pccode from #pccode) 
	if @langid = 0
		update #account set name = a.descript from basecode a where a.cat = 'moduno' and #account.modu_id = a.code
	else
		update #account set name = a.descript1 from basecode a where a.cat = 'moduno' and #account.modu_id = a.code
	end
--
update #account set arname = b.name from master a, guest b where #account.accntof = a.accnt and a.haccnt = b.no
update #account set arname = b.name from hmaster a, guest b where #account.accntof = a.accnt and a.haccnt = b.no
update #account set arname = b.name from ar_master a, guest b where #account.accntof = a.accnt and a.haccnt = b.no
update #account set arname = b.name from har_master a, guest b where #account.accntof = a.accnt and a.haccnt = b.no
update #account set sno = b.sno from ar_master a, guest b where #account.accntof = a.accnt and a.haccnt = b.no
update #account set sno = b.sno from har_master a, guest b where #account.accntof = a.accnt and a.haccnt = b.no

--
if @langid = 0 
	select roomno, accnt,sno, name, accntof, arname, log_date, ref, ref1, ref2, credit,
		pccode, argcode, crradjt, number, empno, shift, billno
		from #account order by accntof, log_date
else
	select a.roomno, a.accnt,a.sno,a.name, a.accntof, a.arname, a.log_date, b.descript1, a.ref1, a.ref2, a.credit,
		a.pccode, a.argcode, a.crradjt, a.number, a.empno, a.shift, a.billno
		from #account a,pccode b where a.pccode *= b.pccode order by a.accntof, a.log_date
;
