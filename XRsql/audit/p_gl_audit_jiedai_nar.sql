if object_id('p_gl_audit_jiedai_nar') is not null
	drop proc p_gl_audit_jiedai_nar;

create proc p_gl_audit_jiedai_nar
	@ret				integer		out,
	@msg				varchar(70)	out
as
-----------------------------------------------------------------------------
-- 修正版(兼容新AR)，宾客账、应收账余额转到jiedai GaoLiang 2005/3/21
-- jjh 特殊处理，餐饮登记账收回不记入 dairep  cyj 2003.11.08
-----------------------------------------------------------------------------

declare
	@p_deptnos		varchar(60), 	--最多20个部门
	@p_deptnms		varchar(180),
	@p_deptenms		varchar(180),
	@deptno			char(5),
	@deptname		char(8),
	@deptename		char(8),
	@bdate			datetime,
	@bfdate			datetime,
	@duringaudit	char(1) ,
	@isfstday		char(1) ,
	@isyfstday		char(1) ,
	@actmode			char(2) ,
	@syssur			money,
	@systax			money,
	@nt_cashtl		char(8),
	@nt_cashgst		char(8),
	@nt_cashbs		char(8),
	@nt_cashar		char(8),
	@nt_netgst		char(8),
	@nt_netar		char(8),
	@nt_netpos		char(8),
	@nt_ent			char(8),
	@nt_credtl		char(8),
	@accnt			char(10),
	@accntof			char(10),
	@pccode			char(5),
	@tag				char(3),
	@roomno			char(5),
	@charge			money,
	@charge1			money,
	@charge2			money,
	@charge3			money,
	@charge4			money,
	@charge5			money,
	@credit			money,
	@toseek			varchar(90),
	@jierep			char(8),
	@tail				char(2),
	@dsc_sttype		char(2),
	@code				char(3),
	@feed				money,
	@descript1		char(5),
	@creditd			money,
	@dept_od			integer,
	@class			char(8),
	@mode				char(1),
	@day01			money,
	@day02			money,
	@day03			money,
	@day04			money,
	@day05			money,
	@day06			money,
	@day07			money,
	@day08			money,
	@day09			money,
	@day99			money,
	@toop				char(1),
	@toclass			char(8),
	@day2sum			money,
	@nday01			money,
	@nday02			money,
	@nday03			money,
	@mday05			money,
	@ment				money,
	@mdsc				money,
	@thisent			money,
	@thisdsc			money,
	@sument			money,
	@sumdsc			money,
	@billno			char(10),
	@mbillno			char(10),
	@mcredit			money,
	@en_str			varchar(40),
	@ds_str			varchar(40),
	@tor_str			varchar(40),
	@card_str		varchar(40),
	@arcreditcard	char(1), 								-- 是否用应收账管理信用卡
	@jd_str			varchar(40),
	@maccnt			char(10),
	@fee_bas			money,
	@fee_sur			money,
	@fee_ent			money,
	@fee_dsc			money,
	@amount			money,
	@modu_ids		varchar(255),
	@modu_id			char(2),
	@dist				char(4),
	@opccode			char(5),
	@number			integer,
	@sqlmark			integer,
	@deptno1			char(5),
	@deptno2			char(5),
	@paycode			char(5),
	@lic_buy_1		varchar(255),
	@lic_buy_2		varchar(255),
	@argcode			char(3),
	@nar				char(1)								-- 是否为新AR账


select @ret = 0, @msg = ''
select @actmode = value from sysoption where catalog = 'account' and item = 'actmode'
select @syssur = convert(money, value) from sysoption where catalog = 'ratemode' and item = 'syssur'
select @systax = convert(money, value) from sysoption where catalog = 'ratemode' and item = 'systax'
select @dsc_sttype = isnull((select value from sysoption where catalog = 'pos' and item = 'dsc_sttype'), 'nn')
select @en_str = isnull((select value from sysoption where catalog = 'audit' and item = 'en_str'), '')
select @ds_str = isnull((select value from sysoption where catalog = 'audit' and item = 'ds_str'), '')
select @tor_str = isnull((select value from sysoption where catalog = 'audit' and item = 'deptno_of_tor'), '')
select @card_str = isnull((select value from sysoption where catalog = 'audit' and item = 'deptno_of_card'), '')
select @arcreditcard = isnull((select value from sysoption where catalog = 'ar' and item = 'creditcard'), 'F')
select @jd_str = isnull((select value from sysoption where catalog = 'audit' and item = 'jiedai'), '1001;010010')
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
if charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0
	select @nar = 'T'
else
	select @nar = 'F'

--
declare deptdef_cursor cursor for select code, descript, descript1 from basecode where cat = 'chgcod_deptno' order by cat
open deptdef_cursor
fetch deptdef_cursor into @deptno, @deptname, @deptename
while @@sqlstatus = 0
	begin
	select @p_deptnos = @p_deptnos + @deptno + '#'
	select @p_deptnms = @p_deptnms + substring(@deptname + space(8), 1, 8) + '#'
	select @p_deptenms = @p_deptenms + substring(@deptename + space(8), 1, 8) + '#'

	fetch deptdef_cursor into @deptno, @deptname, @deptename
	end
close deptdef_cursor
deallocate cursor deptdef_cursor
if @p_deptnms is null
	select @p_deptnms='NO DEPT  #', @p_deptenms='NO DEPT  #'

---------Initialization---------------
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
if exists ( select 1 from jierep where date = @bdate )
	update jierep set
		month01 = month01 - day01, month02 = month02-day02, month03 = month03-day03,
		month04 = month04 - day04, month05 = month05-day05, month06 = month06-day06,
 		month07 = month07 - day07, month08 = month08-day08, month09 = month09-day09,
		month99 = month99 - day99
update jierep set day01 = 0, day02 = 0, day03 = 0, day04 = 0, day05 = 0, day06 = 0, day07 = 0, day08 = 0, day09 = 0, day99 = 0, date = @bfdate
if exists ( select 1 from dairep where date = @bdate )
	update dairep set
		credit01m = credit01m - credit01, credit02m = credit02m - credit02,
		credit03m = credit03m - credit03, credit04m = credit04m - credit04,
		credit05m = credit05m - credit05, credit06m = credit06m - credit06,
		credit07m = credit07m - credit07, sumcrem = sumcrem - sumcre  ,
		debitm	= debitm - debit, creditm = creditm - credit
update dairep set
	credit01 = 0, credit02 = 0, credit03 = 0, credit04 = 0, credit05 = 0, credit06 = 0,
	credit07 = 0, sumcre = 0, debit = 0, credit = 0, date = @bfdate
if exists ( select 1 from jiedai where date = @bdate )   --css modi 重建报表会错
  update jiedai set chargem = chargem - charge, creditm = creditm - credit, applym = applym - apply
update jiedai set
	charge = 0, credit = 0, apply = 0, date = @bfdate
--------- Cash part ---------
select @nt_cashtl ='01010', @nt_cashgst='01020', @nt_cashbs ='01998', @nt_cashar ='01999',
	@nt_netgst ='02000', @nt_netar = '03000', @nt_netpos = '04000', @nt_ent = '08000', @nt_credtl = '09000'
if not exists (select 1 from dairep where class = @nt_cashtl)
	insert dairep (class, descript, descript1, order_, date) values (@nt_cashtl, '收款合计  ', 'Payment Total', '1 ', @bfdate)
if not exists (select 1 from dairep where class = @nt_cashgst)
	insert dairep (class, descript, descript1, date) values (@nt_cashgst, '  前  厅  ','  Front Office', @bfdate)
if exists (select 1 from sysobjects where name = 'bos_folio')
	begin
	if not exists (select 1 from dairep where class = @nt_cashbs)
		insert dairep (class, descript, descript1, date) values (@nt_cashbs, '  BOS收银', '  BOS', @bfdate)
	end
if not exists (select 1 from dairep where class = @nt_cashar)
	insert dairep (class, descript, descript1, date) values (@nt_cashar, '  记账回收', '  AR Back', @bfdate)
--------- other part ---------
if not exists (select 1 from dairep where class = @nt_netgst)
	insert dairep (class, descript, descript1, order_, date) values (@nt_netgst, '宾客账', 'Guest Acct.', '2 ', @bfdate)
if not exists (select 1 from dairep where class = @nt_netar)
	insert dairep (class, descript, descript1, order_, date) values (@nt_netar, 'AR账', 'AR Acct.', '3 ', @bfdate)
if not exists (select 1 from dairep where class = @nt_netpos)
	insert dairep (class, descript, descript1, order_, date) values (@nt_netpos, '餐预付', 'POS Deposit', '4 ', @bfdate)
if not exists (select 1 from dairep where class = @nt_ent)
	insert dairep (class, descript, descript1, order_, date) values (@nt_ent, '款待额', 'ENT', '5 ', @bfdate)
if not exists (select 1 from dairep where class = @nt_credtl)
	insert dairep (class, descript, descript1, order_, date) values (@nt_credtl, '贷方总计', 'Credit Total', '6 ', @bfdate)

--------- Part one:deal with gltemp ---------------
select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#05#')
declare gltemp_cursor cursor for
	select a.accnt, a.accntof, a.pccode, a.tag, a.charge, a.charge1, a.charge2, a.charge3, a.charge4, a.charge5, a.credit, a.modu_id, a.roomno, b.deptno, b.jierep, b.tail ,b.argcode
	from gltemp a, pccode b where a.pccode *= b.pccode
open gltemp_cursor
fetch gltemp_cursor into @accnt, @accntof, @pccode, @tag, @charge, @charge1, @charge2, @charge3, @charge4, @charge5, @credit, @modu_id, @roomno, @deptno, @jierep, @tail ,@argcode
while @@sqlstatus = 0
	begin
	if @argcode = '98'					-- @pccode > '9'
		begin
		if @accnt like 'A%' and @accntof like 'A%' and @tag in ('T', 't')
		-- 后台账户之间转账
			select @toseek = ''
		else if charindex(@deptno, @tor_str) > 0
		-- 前台转AR账记入AR账发生额
			exec p_gl_audit_jiedai_jiedai @nar, @accntof, @credit, 0, 0
		else if @arcreditcard = 'T' and (charindex(@deptno, @card_str) > 0 or exists(select 1 from bankcard where pccode = @pccode))
		-- 信用卡付款记入AR账发生额(只有选项开着的时候才有效)
			exec p_gl_audit_jiedai_jiedai @nar, @accntof, @credit, 0, 0
		else if @accnt like 'A%'
		-- AR账收的现金
			select @toseek = @nt_cashar + '#' + @nt_cashtl + '#'
		else
		-- 前台收的现金
			select @toseek = @nt_cashgst + '#' + @nt_cashtl + '#'
		while datalength(@toseek) > 0
			begin
			exec p_gl_audit_jiedai_dai @toseek output, @tail, @credit
			end
		exec p_gl_audit_jiedai_jiedai @nar, @accnt, 0, @credit, 0
		fetch gltemp_cursor into @accnt, @accntof, @pccode, @tag, @charge, @charge1, @charge2, @charge3, @charge4, @charge5, @credit, @modu_id, @roomno, @deptno, @jierep, @tail,@argcode
		continue
		end
	if @pccode = '' and @tag in ('P')
		select @charge = 0
	exec p_gl_audit_jiedai_jiedai @nar, @accnt, @charge, 0, 0
	update dairep set sumcre = sumcre + @charge where class = @nt_credtl
	-- 总台输入部分及电话计费需统计入底表借方
	if @pccode <> '' and charindex(@modu_id, @modu_ids) > 0
		exec p_gl_audit_jiedai_jie @jierep, @tail, @roomno, @pccode, @tag, @charge, @charge1, @charge2, @charge3, @charge4, @charge5
	fetch gltemp_cursor into @accnt, @accntof, @pccode, @tag, @charge, @charge1, @charge2, @charge3, @charge4, @charge5, @credit, @modu_id, @roomno, @deptno, @jierep, @tail,@argcode
	end
close gltemp_cursor
deallocate cursor gltemp_cursor
---------Part two-1:deal with deptjie and deptdai---------------
----------------A:deal with deptjie ( CQ modified for pccode change to 5 )
declare deptjie_cursor cursor for
	select c.chgcod, a.code, a.feed, b.jierep, b.tail from deptjie a, pos_itemdef b, pos_pccode c
	where a.daymark = 'D' and a.shift = '9' and a.empno ='{{{' and a.code < '6' and a.pccode = b.pccode and a.code = b.code and a.pccode = c.pccode and b.pccode = c.pccode
open deptjie_cursor
fetch deptjie_cursor into @pccode, @code, @feed, @jierep, @tail
while @@sqlstatus = 0
	begin
	exec p_gl_audit_jiedai_jie @jierep, @tail, '', @pccode, '', @feed, 0, 0, 0, 0, 0
	fetch deptjie_cursor into @pccode, @code, @feed, @jierep, @tail
	end
close deptjie_cursor
deallocate cursor deptjie_cursor

----------------B:deal with deptdai -----------------------------
declare deptdai_cursor cursor for
select a.pccode, b.pccode, a.paycode, a.descript1, a.creditd, b.deptno2, b.tail, b.deptno8, c.deptno
	from deptdai a, pccode b, pccode c, pos_pccode d
	where a.daymark = 'D' and a.shift ='9' and a.empno ='{{{'  and a.pccode = d.pccode and c.pccode = d.chgcod
	and substring(a.paycode, 2, 2) > '  ' and substring(a.paycode, 2, 2) < '99' and  substring(a.paycode,2,2) = substring(b.deptno1,2,2)
	and substring(a.paycode, 1, 1) <> 'F' and substring(a.paycode, 1, 1) <> 'G'
--
open deptdai_cursor
fetch deptdai_cursor into @pccode, @paycode, @deptno1, @descript1, @creditd, @deptno2, @tail, @dist, @deptno
while @@sqlstatus = 0
	begin
	if charindex(rtrim(@deptno2), 'TOR#TOA#TOG#') != 0 or @tail in ('09', '10') 
			or (exists(select 1 from bankcard where pccode = @paycode) and @nar = 'T' and @arcreditcard = 'T')
		-- 信用卡是否记入AR账选项,只判断bankcard中的记录还不够 hbb 2005.09.28
		begin
		fetch deptdai_cursor into @pccode, @paycode, @deptno1, @descript1, @creditd, @deptno2, @tail, @dist, @deptno
		continue
		end
	--
	if @tail <= '06' and @tail > '00'
		begin
		--
		if substring(@deptno1, 1, 1) = 'B'
			begin
			select @toseek = ''
			update dairep set credit = credit + @creditd, sumcre = sumcre - @creditd where class = @nt_netpos
			update dairep set sumcre = sumcre + @creditd where class = @nt_credtl
			end
		else if substring(@deptno1, 1, 1) = 'E'
			begin
			select @toseek = substring(@nt_cashtl, 1, 2) + @deptno + '    #' + @nt_cashtl + '#'
			update dairep set debit = debit + @creditd, sumcre = sumcre + @creditd where class = @nt_netpos
			end
		else										--'C'
			select @toseek = substring(@nt_cashtl, 1, 2) + @deptno + '    #' + @nt_cashtl + '#' + @nt_credtl + '#'
		while datalength(@toseek) > 0
			begin
			if not exists (select * from dairep where class = substring(@toseek, 1, 8))
				begin
				select @deptname = descript from basecode where cat = 'chgcod_deptno' and code = @deptno
				insert dairep (class, descript, descript1, date) values (substring(@toseek, 1, 8), '  ' + @deptname, '  ' + @deptename, @bfdate)
				end
				exec p_gl_audit_jiedai_dai @toseek output, @tail, @creditd
			end
		end
	else
		begin
		if charindex(@tail, '07#08#') > 0
			begin
			if @tail = '08'
				begin
				update dairep set sumcre = sumcre + @creditd where class = @nt_ent
				select @dept_od = (charindex(@deptno, @p_deptnos) + 3) / 4
				if @dept_od < 1
					select @dept_od = 1
				if not exists (select 1 from dairep where class = substring(@nt_ent, 1, 2) + @deptno)
					insert dairep (class, descript, descript1, date) values (substring(@nt_ent, 1, 2) + @deptno, '  ' + substring(@p_deptnms, (@dept_od - 1) * 9 + 1, 8), '  ' + substring(@p_deptenms, (@dept_od - 1) * 9 + 1, 8), @bfdate)
				update dairep set sumcre = sumcre + @creditd
					where class in (substring(@nt_ent, 1, 2) + @deptno, @nt_credtl)
				end
			if not rtrim(@dist) is null
				begin
--				select @jierep = a.jierep, @tail = a.tail from pos_itemdef a,pos_pccode b where a.pccode = b.pccode and b.chgcod = @pccode and a.code = @dist  --cq modi
				select @jierep = a.jierep, @tail = a.tail from pos_itemdef a,pos_pccode b where a.pccode = b.pccode and b.pccode = @pccode and a.code = @dist  --cyj modi
				if @@rowcount > 0
					begin
					if @tail = '08'
						update jierep set day08 = day08 + @creditd where class = @jierep
					else
						update jierep set day09 = day09 + @creditd where class = @jierep
					end
				end
			end
		end
	fetch deptdai_cursor into @pccode, @paycode, @deptno1, @descript1, @creditd, @deptno2, @tail, @dist, @deptno
	end
close deptdai_cursor
deallocate cursor deptdai_cursor
---------Part two-2:deal with bosjie and bosdai--------------
----------------A:deal with bosjie --------------------------
-- 处理底表借方全部, 底表贷方的款待部分
declare bosjie_cursor cursor for
	select a.code, a.fee_bas, a.fee_sur + a.fee_tax, a.fee_ent, a.fee_dsc, b.deptno, b.jierep, b.tail
		from bosjie a, pccode b, bos_pccode c
	where a.daymark = 'D' and a.shift = '9' and a.empno ='{{{' and a.code < '999'
			and a.code = c.pccode and c.chgcod=b.pccode
open bosjie_cursor
fetch bosjie_cursor into @pccode, @fee_bas, @fee_sur, @fee_ent, @fee_dsc, @deptno, @jierep, @tail
while @@sqlstatus = 0
	begin
	update jierep set day06 = day06 + @fee_sur, day08 = day08 + @fee_ent, day09 = day09 + @fee_dsc
		where class = @jierep
	exec p_gl_audit_jiedai_jie @jierep, @tail, '', @pccode, '', @fee_bas, 0, 0, 0, 0, 0
	-- ent data
	update dairep set sumcre = sumcre + @fee_ent where class = @nt_ent
	select @dept_od = (charindex(@deptno, @p_deptnos) + 3) / 4
	if @dept_od < 1
		select @dept_od = 1
	if not exists (select 1 from dairep where class = substring(@nt_ent, 1, 2) + @deptno)
		insert dairep (class, descript, descript1, date) values (substring(@nt_ent, 1, 2) + @deptno, '  ' + substring(@p_deptnms, (@dept_od - 1) * 9 + 1, 8), '  ' + substring(@p_deptenms, (@dept_od - 1) * 9 + 1, 8), @bfdate)
	update dairep set sumcre = sumcre + @fee_ent
		where class in (substring(@nt_ent, 1, 2) + @deptno, @nt_credtl)
	fetch bosjie_cursor into @pccode, @fee_bas, @fee_sur, @fee_ent, @fee_dsc, @deptno, @jierep, @tail
	end
close bosjie_cursor
deallocate cursor bosjie_cursor
----------------B:deal with bosdai --------------------------
-- 处理底表贷方现金部分:贷方款待数据由bosjie负责提供, 贷方宾客账及记账由gltemp中提供
declare bosdai_cursor cursor for
	select a.paycode, a.creditd, isnull(b.deptno2, '   '), b.tail
	from bosdai a, pccode b
	where a.daymark = 'D' and a.shift ='9' and a.empno ='{{{' and a.paycode <> '999' and a.paycode <> '993' and a.paycode <> '994' and a.paycode *= b.pccode
open bosdai_cursor
fetch bosdai_cursor into @descript1, @creditd, @deptno2, @tail
while @@sqlstatus = 0
	begin
	if charindex(@deptno2, 'TOR#TOA#TOG#DSC#ENT') != 0 
		or (exists(select 1 from bankcard where pccode = @descript1) and @nar = 'T' and @arcreditcard = 'T')
		-- 信用卡是否记入AR账选项,只判断bankcard中的记录还不够 hbb 2005.09.28
		begin
		fetch bosdai_cursor into @descript1, @creditd, @deptno2, @tail
		continue
		end
	select @toseek = @nt_cashbs + '#' + @nt_cashtl + '#' + @nt_credtl + '#'
	while datalength(@toseek) > 0
		begin
		exec p_gl_audit_jiedai_dai @toseek output, @tail, @creditd
		end
	fetch bosdai_cursor into @descript1, @creditd, @deptno2, @tail
	end
close bosdai_cursor
deallocate cursor bosdai_cursor
---------Part three:deal with discount and entertainment (营业收入倒扣计入Rebate栏day07) --------
declare out_cursor cursor for
	select a.accnt, a.number, a.pccode, a.charge, a.tag, a.roomno, b.deptno, b.jierep, b.tail from outtemp a, pccode b
	where a.billno = @mbillno and b.argcode < '9' and a.pccode = b.pccode order by accnt, number
declare outtemp_cursor cursor for
	select a.billno, a.roomno, a.accnt, a.number, b.deptno2, a.credit from outtemp a, pccode b
	where b.argcode > '9' and a.pccode = b.pccode order by a.billno, a.accnt, a.number
open outtemp_cursor
fetch outtemp_cursor into @billno, @roomno, @accnt, @number, @deptno2, @credit
select @sqlmark = @@sqlstatus
while @sqlmark = 0
	begin
	exec p_gl_audit_jiedai_jiedai @nar, @accnt, 0, 0, @credit
	select @mbillno = @billno, @maccnt = @accnt, @mdsc = 0, @ment = 0, @mcredit = 0
	while @sqlmark = 0 and @mbillno = @billno
		begin
		if charindex(@deptno2, @en_str) > 0
			select @ment = @ment + round(@credit, 2)
		else if charindex(@deptno2, @ds_str) > 0
			select @mdsc = @mdsc + round(@credit, 2)
		select @mcredit = @mcredit + round(@credit, 2)
		fetch outtemp_cursor into @billno, @roomno, @accnt, @number, @deptno2, @credit
		select @sqlmark = @@sqlstatus
		end
	--
	if round(@ment, 2) = 0 and round(@mdsc, 2) = 0
		continue
	if substring(@maccnt, 1, 1) = 'A'
		select @toseek = @nt_cashar + '#' + @nt_cashtl + '#'
	else
		select @toseek = @nt_cashgst + '#' + @nt_cashtl + '#'
	while datalength(@toseek) > 0
		begin
		update dairep set credit07 = credit07 - @ment - @mdsc, sumcre = sumcre - @ment - @mdsc
			where class = substring(@toseek, 1, 8)
		select @toseek = stuff(@toseek, 1, 9, null)
		end
	if round(@mcredit, 2) = 0
		begin
		select @number = charindex(';', @jd_str)
		select @pccode = substring(@jd_str, 1, @number - 1), @jierep = substring(@jd_str, @number + 1, 20)
--		select @tail = tail, @deptno = deptno, @amount = - @ment - @mdsc from pccode where pccode = @pccode
--		update jierep set day08 = day08 + @ment, day09 = day09 + @mdsc where class = @jierep
--		exec p_gl_audit_jiedai_jie @jierep, '07', @roomno, @pccode, @tag, @amount, 0, 0, 0, 0, 0
		select @tail = tail, @deptno = deptno from pccode where pccode = @pccode
		select @amount = - @ment
		exec p_gl_audit_jiedai_jie @jierep, '07,08', @roomno, @pccode, @tag, @amount, 0, 0, 0, 0, 0
		select @amount = - @mdsc
		exec p_gl_audit_jiedai_jie @jierep, '07,09', @roomno, @pccode, @tag, @amount, 0, 0, 0, 0, 0
		update dairep set sumcre = sumcre + @ment where class = @nt_ent
		select @dept_od = (charindex(@deptno, @p_deptnos) + 3) / 4
		if @dept_od < 1
			select @dept_od = 1
		if not exists (select 1 from dairep where class = substring(@nt_ent, 1, 2) + @deptno)
			insert dairep (class, descript, descript1, date) values (substring(@nt_ent, 1, 2) + @deptno, '  ' + substring(@p_deptnms, (@dept_od - 1) * 9 + 1, 8),  '  ' + substring(@p_deptenms, (@dept_od - 1) * 9 + 1, 8), @bfdate)
		update dairep set sumcre = sumcre + @ment where class in (substring(@nt_ent, 1, 2) + @deptno)
		update dairep set sumcre = sumcre - @mdsc where class = @nt_credtl
		continue
		end
	select @sumdsc = 0, @sument = 0, @opccode = null
	open out_cursor
	fetch out_cursor into @accnt, @number, @pccode, @charge, @tag, @roomno, @deptno, @jierep, @tail
	while @@sqlstatus = 0
		begin
		if @opccode is null and @charge <> 0
			select @opccode = @pccode
		select @thisdsc = round(@charge * @mdsc / @mcredit * 1.0 , 2)
		select @thisent = round(@charge * @ment / @mcredit * 1.0 , 2)
--		select @amount = - @thisent - @thisdsc
--		update jierep set day08 = day08 + @thisent, day09 = day09 + @thisdsc where class = @jierep
--		exec p_gl_audit_jiedai_jie @jierep, '07', @roomno, @pccode, @tag, @amount, 0, 0, 0, 0, 0
		select @amount = - @thisent
		exec p_gl_audit_jiedai_jie @jierep, '07,08', @roomno, @pccode, @tag, @amount, 0, 0, 0, 0, 0
		select @amount = - @thisdsc
		exec p_gl_audit_jiedai_jie @jierep, '07,09', @roomno, @pccode, @tag, @amount, 0, 0, 0, 0, 0
		update dairep set sumcre = sumcre + @thisent where class = @nt_ent
		select @dept_od = (charindex(@deptno, @p_deptnos) + 3) / 4
		if @dept_od < 1
			select @dept_od = 1
		if not exists (select 1 from dairep where class = substring(@nt_ent, 1, 2) + @deptno)
			insert dairep (class, descript, descript1, date) values (substring(@nt_ent, 1, 2) + @deptno, '  ' + substring(@p_deptnms, (@dept_od - 1) * 9 + 1, 8),  '  ' + substring(@p_deptenms, (@dept_od - 1) * 9 + 1, 8), @bfdate)
		update dairep set sumcre = sumcre + @thisent where class in (substring(@nt_ent, 1, 2) + @deptno)
		update dairep set sumcre = sumcre - @thisdsc where class = @nt_credtl
		select @sument = @sument + @thisent, @sumdsc = @sumdsc + @thisdsc
		fetch out_cursor into @accnt, @number, @pccode, @charge, @tag, @roomno, @deptno, @jierep, @tail
		end
	close out_cursor
	if round(@sument, 2) <> round(@ment, 2)
		begin
		select @jierep = jierep, @tail = tail, @deptno = deptno, @amount = - @ment + @sument from pccode where pccode = @opccode
--		update jierep set day08 = day08 + (@ment - @sument) where class = @jierep
--		exec p_gl_audit_jiedai_jie @jierep, '07', @roomno, @opccode, @tag, @amount, 0, 0, 0, 0, 0
		exec p_gl_audit_jiedai_jie @jierep, '07,08', @roomno, @opccode, @tag, @amount, 0, 0, 0, 0, 0
		update dairep set sumcre = sumcre + (@ment - @sument) where class = @nt_ent
		select @dept_od = (charindex(@deptno, @p_deptnos) + 3) / 4
		if @dept_od < 1
			select @dept_od = 1
		if not exists (select 1 from dairep where class = substring(@nt_ent, 1, 2) + @deptno)
			insert dairep (class, descript, descript1, date) values (substring(@nt_ent, 1, 2) + @deptno, '  ' + substring(@p_deptnms, (@dept_od - 1) * 9 + 1, 8),  '  ' + substring(@p_deptenms, (@dept_od - 1) * 9 + 1, 8), @bfdate)
		update dairep set sumcre = sumcre + (@ment - @sument)
			where class = substring(@nt_ent, 1, 2) + @deptno
		end
	if round(@sumdsc, 2) <> round(@mdsc, 2)
		begin
		select @jierep = jierep, @tail = tail, @deptno = deptno, @amount = - @mdsc + @sumdsc from pccode where pccode = @opccode
--		update jierep set day09 = day09 + (@mdsc - @sumdsc) where class = @jierep
--		exec p_gl_audit_jiedai_jie @jierep, '07', @roomno, @opccode, @tag, @amount, 0, 0, 0, 0, 0
		exec p_gl_audit_jiedai_jie @jierep, '07,09', @roomno, @opccode, @tag, @amount, 0, 0, 0, 0, 0
		update dairep set sumcre = sumcre - (@mdsc - @sumdsc) where class = @nt_credtl
		end
	end
close outtemp_cursor
deallocate cursor outtemp_cursor
deallocate cursor out_cursor
--------- Part foure:after treatment --------
declare jierep_D_cursor cursor for select class, mode, day01, day02, day03 from jierep
	where charindex(mode, 'dD') > 0
open jierep_D_cursor
fetch jierep_D_cursor into @class, @mode, @day01, @day02, @day03
while @@sqlstatus = 0
	begin
	if @mode ='D'
		begin
		select @day2sum = @day01 + @day02
		select @nday01 = round(@day2sum / 1.10, 2)
		update jierep set day01 = @nday01, day02 = @day2sum - @nday01 where class = @class
		end
	else
		begin
		select @day2sum = @day01 + @day02 + @day03
		select @nday01 = round(@day2sum / (1.00 + @syssur + @systax), 2)
		select @nday02 = round(@nday01 * @syssur * 1.00, 2)
		select @nday03 = round(@nday01 * @systax * 1.00, 2)
		update jierep set day01 = @day2sum - @nday02 - @nday03, day02 = @nday02, day03 = @nday03
			where class = @class
		end
	fetch jierep_D_cursor into @class, @mode, @day01, @day02, @day03
	end
close jierep_D_cursor
deallocate cursor jierep_D_cursor
select @mday05 = isnull(sum(day08), 0) from jierep
update jierep set day01 = @mday05 where mode = 'E'
declare jierep_cursor cursor for select toop, toclass, day01, day02, day03, day04, day05, day06, day07, day08, day09
	from jierep where rectype = 'B'
open jierep_cursor
fetch jierep_cursor into @toop, @toclass, @day01, @day02, @day03, @day04, @day05, @day06, @day07, @day08, @day09
while @@sqlstatus = 0
	begin
	while @toclass <> space(8)
		begin
		if @toop = '+'
			update jierep set
				day01 = day01 + @day01, day02 = day02 + @day02, day03 = day03 + @day03,
				day04 = day04 + @day04, day05 = day05 + @day05, day06 = day06 + @day06,
				day07 = day07 + @day07, day08 = day08 + @day08, day09 = day09 + @day09
				where class = @toclass
		else
			update jierep set
				day01 = day01 - @day01, day02 = day02 - @day02, day03 = day03 - @day03,
				day04 = day04 - @day04, day05 = day05 - @day05, day06 = day06 - @day06,
				day07 = day07 - @day07, day08 = day08 - @day08, day09 = day09 - @day09
				where class = @toclass
		select @toclass = toclass, @toop = toop from jierep where class = @toclass
		if @@rowcount = 0
			select @toclass = space(8)
		end
	fetch jierep_cursor into @toop, @toclass, @day01, @day02, @day03, @day04, @day05, @day06, @day07, @day08, @day09
	end
close jierep_cursor
deallocate cursor jierep_cursor
update jierep set day99 = day01 + day02 + day03 + day04 + day05 + day06 + day07
-------deal with saving ---------
--2009-2-13 clg 应该提到前面,否则上月余额不对
update dairep set dairep.last_bl = a.till_bl from ydairep a
	where dairep.class = a.class and datediff(dd, a.date, @bdate) = 1
update jiedai set jiedai.last_charge = a.till_charge, jiedai.last_credit = a.till_credit from yjiedai a
	where jiedai.class = a.class and datediff(dd, a.date, @bdate) = 1

exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday ='T'
	begin
	update jierep set
		month01 = day01, month02 = day02, month03 = day03, month04 = day04,
		month05 = day05, month06 = day06, month07 = day07, month08 = day08,
		month09 = day09, month99 = day99, date	= @bdate
	update dairep set
		last_blm = last_bl, credit01m = credit01, credit02m = credit02, credit03m = credit03,
		credit04m = credit04, credit05m = credit05, credit06m = credit06, credit07m = credit07,
		sumcrem = sumcre, debitm = debit, creditm = credit, date = @bdate
	update jiedai set
		last_chargem = last_charge, last_creditm = last_credit,
		chargem = charge, creditm = credit, applym = apply, date = @bdate
	end
else
	begin
	update jierep set
		month01 = month01 + day01, month02 = month02 + day02, month03 = month03 + day03,
		month04 = month04 + day04, month05 = month05 + day05, month06 = month06 + day06,
		month07 = month07 + day07, month08 = month08 + day08, month09 = month09 + day09,
		month99 = month99 + day99, date	 = @bdate
	update dairep set
		credit01m = credit01m + credit01, credit02m = credit02m + credit02,
		credit03m = credit03m + credit03, credit04m = credit04m + credit04,
		credit05m = credit05m + credit05, credit06m = credit06m + credit06, credit07m = credit07m + credit07,
		sumcrem	= sumcrem + sumcre, debitm = debitm + debit,
		creditm = creditm + credit, date = @bdate
	update jiedai set
		chargem = chargem + charge, creditm = creditm + credit, applym = applym + apply, date = @bdate
	end

update dairep set till_bl = last_bl + debit - credit, date = @bdate
update jiedai set till_charge = last_charge + charge - apply, till_credit = last_credit + credit - apply, date = @bdate

delete yjierep where date = @bdate
insert yjierep select * from jierep
delete ydairep where date = @bdate
insert ydairep select * from dairep
delete yjiedai where date = @bdate
insert yjiedai select * from jiedai

--
exec p_gl_statistic_saveas 'pcid', @bdate, 'jiedai'

return @ret
;