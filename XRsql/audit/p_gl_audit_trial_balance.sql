if exists (select * from sysobjects where name ='p_gl_audit_trial_balance' and type ='P')
	drop proc p_gl_audit_trial_balance;
create proc p_gl_audit_trial_balance
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
	@type				char(2), 
	@deptno			char(5), 
	@deptno2			char(5), 
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
	@paymth			char(5), 
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
	@paytail			char(1), 
	@dept_od			integer, 
	@class			char(8), 
	@mode				char(1), 
	@en_str			varchar(40), 
	@ds_str			varchar(40), 
	@tor_str			varchar(40), 
	@card_str		varchar(40), 
	@jd_str			varchar(40), 
	@maccnt			char(10), 
	@fee_bas			money, 
	@fee_sur			money, 
	@fee_ent			money, 
	@fee_dsc			money, 
	@amount1			money, 
	@amount2			money, 
	@amount3			money, 
	@modu_ids		varchar(255), 
	@modu_id			char(2), 
	@dist				char(4), 
	@opccode			char(5), 
	@number			integer, 
	@sqlmark			integer,
	@tag1				char(5),
	@lic_buy_1		varchar(255),
	@lic_buy_2		varchar(255),
	@nar				char(1)								-- 是否为新AR账

select @ret = 0, @msg = ''
select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#05#')
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
if charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0
	select @nar = 'T'
else
	select @nar = 'F'
---------Initialization--------------- 
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
if exists ( select 1 from trial_balance where date = @bdate )
	update trial_balance set month = month - day, year = year - day where charindex('*', code) = 0
else
	update trial_balance set day = isnull((select a.day from ytrial_balance a
		where a.date = @bfdate and a.type = trial_balance.type and a.code = trial_balance.code), 0)
		where trial_balance.code = '*'
update trial_balance set day = 0 where charindex('*', code) = 0
update trial_balance set day = isnull((select a.day from ytrial_balance a where a.date = @bfdate and a.type = '50' and a.code = '20'), 0)
	where type = '10' and code = ' *'
update trial_balance set day = isnull((select a.day from ytrial_balance a where a.date = @bfdate and a.type = '60' and a.code = '60'), 0)
	where type = '60' and code = '1*'
update trial_balance set day = isnull((select a.day from ytrial_balance a where a.date = @bfdate and a.type = '70' and a.code = '70'), 0)
	where type = '70' and code = '1*'
update trial_balance set date = @bfdate
--------- Part one:deal with gltemp --------------- 
select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#05#')
declare gltemp_cursor cursor for 
	select a.accnt, a.accntof, a.pccode, a.tag, a.charge, a.credit, a.modu_id, a.roomno, b.deptno, b.deptno2, b.tail
	from gltemp a, pccode b where a.pccode *= b.pccode
open gltemp_cursor
fetch gltemp_cursor into @accnt, @accntof, @pccode, @tag, @charge, @credit, @modu_id, @roomno, @deptno, @deptno2, @tail
while @@sqlstatus = 0
	begin
	if @pccode < '9'
		select @type = '20'
	else if rtrim(@deptno2) in ('PO', 'RF')
		select @type = '30'
	else
		select @type = '40'
	if not exists (select 1 from trial_balance where type = @type and code = @pccode)
		insert trial_balance select @bdate, @type, pccode, descript, descript1, 0, 0, 0
			from pccode where pccode = @pccode
	--
	if not @accnt like 'A%' and @pccode < '9'									-- 前台收入
		begin
		if charindex(@modu_id, @modu_ids) > 0
			update trial_balance set day = day + @charge where type = @type and code = @pccode
		end
	else if not @accnt like 'A%'													-- 前台付款
		update trial_balance set day = day - @credit where type = @type and code = @pccode
	else if @accnt like 'A%' and @tag = 'P'									-- 前台转AR
		update trial_balance set day = day + @charge - @credit where type = '60' and code = '20'
	else if @accnt like 'A%' and @tag = 'A' and @pccode < '9'			-- 后台收入
		update trial_balance set day = day + @charge where type = '60' and code = '30'
	else if @accnt like 'A%' and @tag = 'A'									-- 后台付款
		update trial_balance set day = day - @credit where type = '60' and code = '40'
	fetch gltemp_cursor into @accnt, @accntof, @pccode, @tag, @charge, @credit, @modu_id, @roomno, @deptno, @deptno2, @tail
	end
close gltemp_cursor
deallocate cursor gltemp_cursor
---------Part two-1:deal with deptjie and deptdai---------------
----------------A:deal with deptjie ----------------------------- 
declare deptjie_cursor cursor for
	select c.chgcod, a.code, a.feed, b.jierep, b.tail from deptjie a, pos_itemdef b, pos_pccode c
	where a.daymark = 'D' and a.shift = '9' and a.empno ='{{{' and a.code < '6' and a.pccode = b.pccode and a.code = b.code and a.pccode = c.pccode and b.pccode = c.pccode
open deptjie_cursor
fetch deptjie_cursor into @pccode, @code, @feed, @jierep, @tail
while @@sqlstatus = 0
	begin
	if not exists (select 1 from trial_balance where type = '20' and code = @pccode)
		insert trial_balance select @bdate, '20', @pccode, descript, descript1, 0, 0, 0
			from pccode where pccode = @pccode
--
	update trial_balance set day = day + @feed where type = '20' and code = @pccode
	fetch deptjie_cursor into @pccode, @code, @feed, @jierep, @tail
	end
close deptjie_cursor
deallocate cursor deptjie_cursor

----------------B:deal with deptdai ----------------------------- 
declare deptdai_cursor cursor for
select a.pccode, a.paycode, b.pccode, a.creditd, b.deptno2, b.tail, c.deptno, a.paytail
	from deptdai a, pccode b, pccode c, pos_pccode d 
	where a.daymark = 'D' and a.shift ='9' and a.empno ='{{{'  and a.pccode = d.pccode and c.pccode = d.chgcod
	and substring(a.paycode, 2, 2) > '  ' and substring(a.paycode, 2, 2) < '99' and  substring(a.paycode,2,2) = substring(b.deptno1,2,2)
	and substring(a.paycode, 1, 1) <> 'F' and substring(a.paycode, 1, 1) <> 'G'	
--
open deptdai_cursor
fetch deptdai_cursor into @pccode, @paymth, @descript1, @creditd, @tag1, @tail, @deptno, @paytail
while @@sqlstatus = 0
	begin
	if charindex(@tag1, 'TOA#TOG') = 0 and @paytail = ''
		begin
		if substring(@paymth, 1, 1) = 'B'
			select @pccode = @pccode
		else if substring(@paymth, 1, 1) = 'E'
			select @pccode = @pccode
		else										--'C'
			begin
			if @deptno2 in ('PO', 'RF')
				select @type = '30'
			else
				select @type = '40'
			if not exists (select 1 from trial_balance where type = @type and code = @descript1)
				insert trial_balance select @bdate, @type, pccode, descript, descript1, 0, 0, 0
					from pccode where pccode = @descript1
			--
			update trial_balance set day = day - @creditd where type = @type and code = @descript1
			-- DSC ENT补到收入中
//			if @tail in ('07', '08')
//				begin
//				if not exists (select 1 from trial_balance where type = '20' and code = @descript1)
//					insert trial_balance select @bdate, '20', @pccode, descript, descript1, 0, 0, 0
//						from pccode where pccode = @pccode
//			--
//				update trial_balance set day = day + @creditd where type = '20' and code = @descript1
//				end
			end
		end
	fetch deptdai_cursor into @pccode, @paymth, @descript1, @creditd, @tag1, @tail, @deptno, @paytail
	end 
close deptdai_cursor
deallocate cursor deptdai_cursor

---------Part two-2:deal with bosjie and bosdai-------------- 
----------------A:deal with bosjie -------------------------- 
-- 处理底表借方全部, 底表贷方的款待部分 
declare bosjie_cursor cursor for
	select b.pccode, a.fee_bas, a.fee_sur + a.fee_tax, a.fee_ent, a.fee_dsc, b.deptno, b.jierep, b.tail
	from bosjie a, pccode b, bos_pccode c
	where a.daymark = 'D' and a.shift = '9' and a.empno ='{{{' and a.code < '999'
	and a.code = c.pccode and c.chgcod = b.pccode
open bosjie_cursor
fetch bosjie_cursor into @pccode, @fee_bas, @fee_sur, @fee_ent, @fee_dsc, @deptno, @jierep, @tail
while @@sqlstatus = 0
	begin
	if not exists (select 1 from trial_balance where type = '20' and code = @pccode)
		begin
select @pccode, @fee_bas, @fee_sur, @fee_ent, @fee_dsc, @deptno, @jierep, @tail
		insert trial_balance select @bdate, '20', @pccode, descript, descript1, 0, 0, 0
			from pccode where pccode = @pccode
		end

	update trial_balance set day = day + @fee_bas + @fee_sur + @fee_ent where type = '20' and code = @pccode
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
fetch bosdai_cursor into @descript1, @creditd, @tag1, @tail
while @@sqlstatus = 0
	begin
	if charindex(@tag1, 'TOA#TOG') = 0
		begin
		if @deptno2 in ('PO', 'RF')
			select @type = '30'
		else
			select @type = '40'
		if not exists (select 1 from trial_balance where type = @type and code = @descript1)
			insert trial_balance select @bdate, @type, pccode, descript, descript1, 0, 0, 0
				from pccode where pccode = @descript1
		--
		update trial_balance set day = day - @creditd where type = @type and code = @descript1
		-- DSC ENT补到收入中
//		if @tail in ('07', '08')
//			begin
//			if not exists (select 1 from trial_balance where type = '20' and code = @pccode)
//				insert trial_balance select @bdate, '20', @pccode, descript, descript1, 0, 0, 0
//					from pccode where pccode = @pccode
//		--
//			update trial_balance set day = day + @creditd where type = '20' and code = @pccode
//			end
		end 
	fetch bosdai_cursor into @descript1, @creditd, @tag1, @tail
	end 
close bosdai_cursor
deallocate cursor bosdai_cursor

---------Part four : after treatment -------- 
select @amount1 = day from trial_balance where type = '10' and code = ' *'
select @amount2 = sum(day) from trial_balance where type in ('20', '30', '40') and code < '{{{{{'
update trial_balance set day = isnull(@amount2, 0) where type = '50' and code = '00'
update trial_balance set day = isnull(@amount1, 0) + isnull(@amount2, 0) where type = '50' and code = '10'
update trial_balance set day = isnull((select sum(a.day) from trial_balance a where a.type = '20' and a.code < '{{{{{'), 0)
	where type = '20' and code = '{{{{{'
update trial_balance set day = isnull((select sum(a.day) from trial_balance a where a.type = '30' and a.code < '{{{{{'), 0)
	where type = '30' and code = '{{{{{'
update trial_balance set day = isnull((select sum(a.day) from trial_balance a where a.type = '40' and a.code < '{{{{{'), 0)
	where type = '40' and code = '{{{{{'
-- GRAND TOTAL
update trial_balance set day = isnull(@amount1, 0) + isnull(@amount2, 0) where type = '50' and code = '10'
select @amount3 = sum(charge - credit) from master_till
update trial_balance set day = isnull(@amount3, 0) where type = '50' and code = '20'
update trial_balance set day = isnull(@amount1, 0) + isnull(@amount2, 0) - isnull(@amount3, 0) where type = '50' and code = '{{{{{'
-- CITY LEDGER
select @amount1 = sum(day) from trial_balance where type = '60' and code > '1' and code < '5'
update trial_balance set day = isnull(@amount1, 0) where type = '60' and code = '50'
create table #ar_balance (
	code			char(10)			not null,
	descript		varchar(50)		not null,
	descript1	varchar(50)		not null,
	balance		money				default 0 not null
)
insert #ar_balance select b.grp, '', '', sum(a.charge - a.credit)
	from ar_master_till a, basecode b where a.artag1 = b.code and b.cat = 'artag1' group by b.grp
update #ar_balance set descript = a.descript, descript1 = a.descript1
	from basecode a where #ar_balance.code = a.code and a.cat = 'argrp1'
insert trial_balance select @bdate, '60', '60' + a.code, '(' + a.descript + ')', '(' + a.descript1 + ')', 0, 0, 0
	from #ar_balance a where not a.code in (select substring(code, 3, 3) from trial_balance where type = '60' and code like '60%')
update trial_balance set day = a.balance from #ar_balance a
	where trial_balance.type = '60' and trial_balance.code = '60' + a.code
select @amount2 = sum(balance) from #ar_balance
update trial_balance set day = isnull(@amount2, 0) where type = '60' and code = '60'
update trial_balance set day = isnull(@amount1, 0) - isnull(@amount2, 0) where type = '60' and code = '{{{{{'
-------deal with saving --------- 
exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isyfstday ='T'
	update trial_balance set month = day, year = day, date = @bdate
else if @isfstday ='T'
	update trial_balance set month = day, year = year + day, date = @bdate
else
	update trial_balance set month = month + day, year = year + day, date = @bdate
update trial_balance set month = day, year = day  where charindex('*', code) > 0

delete ytrial_balance where date = @bdate
insert ytrial_balance select * from trial_balance
return @ret
;
