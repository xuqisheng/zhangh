if exists (select * from sysobjects where name = 'p_gds_audit_act_bal' and type ='P')
   drop proc p_gds_audit_act_bal
;
create  proc p_gds_audit_act_bal
	@mode				char(1) = 'A',                   -- 'R'  -  recount all
	@ret				integer		out,
	@msg				varchar(60)	out
as
-----------------------------------------------------------------------------
-- 帐户试算平衡表 （余额表）
--	两种计算方式：	1。全部重建      mode = 'R'  
--						2。每日累加计算  mode = 'A'
--
--	由于各个酒店针对项目的要求不同，统计的deptno 需要工程人员临时调整
--
-----------------------------------------------------------------------------

declare
   @bdate			datetime,
   @bfdate			datetime,
   @sdate			datetime,
   @duringaudit	char(1),
	@billno			char(7),
	@lic_buy_1		varchar(255),
	@lic_buy_2		varchar(255)

//select @mode = 'R', @ret = 0, @msg = 'OK !'
select @ret = 0, @msg = 'OK !'
--------- bdate ---------
select @duringaudit = audit from gate
if @duringaudit = 'T'
   select @bdate = bdate from sysdata
else
   select @bdate = bdate from accthead

select @bfdate  = dateadd(day, -1, @bdate)
select @sdate   = dateadd(day, -400, @bdate)  -- 保留天数

select @billno  = '_' + substring(convert(char(4), datepart(yy, dateadd(dd, 1, @bdate))), 4, 1) +
	substring(convert(char(3), datepart(mm, dateadd(dd, 1, @bdate)) + 100), 2, 2) +
	substring(convert(char(3), datepart(dd, dateadd(dd, 1, @bdate)) + 100), 2, 2) + '%'

---------表准备---------
truncate table act_bal
truncate table act_bal_serve
delete yact_bal where date = @bdate
delete yact_bal where date < @sdate

---------计算模式---------
if @mode <> 'R'
	select @mode = 'A'
if @mode = 'A' and not exists(select 1 from yact_bal where date = @bfdate)
	select @mode = 'R'
if @mode = 'A'
	insert act_bal_serve select * from yact_bal where date = @bfdate

---------有效记录---------
insert act_bal(date, accnt, name, sta, roomno, groupno, arr, dep, tilld, tillc, tillbl)
	select @bfdate, accnt, haccnt, sta, roomno, groupno, arr, dep, charge, credit, charge - credit
	from master_till where sta <> 'D' and lastnumb > 0
insert act_bal(date, accnt, name, sta, roomno, groupno, arr, dep, tilld, tillc, tillbl)
	select @bfdate, accnt, haccnt, sta, '', '', arr, dep, charge + charge0, credit + credit0, charge + charge0 - credit - credit0
	from ar_master_till where sta <> 'D' and lastnumb > 0
update act_bal set lastd = a.charge, lastc = a.credit, lastbl = a.charge - a.credit
	from master_last a where act_bal.accnt = a.accnt
update act_bal set lastd = a.charge + a.charge0, lastc = a.credit + a.credit0, lastbl = a.charge + a.charge0 - a.credit - a.credit0
	from ar_master_last a where act_bal.accnt = a.accnt
update act_bal set name   = a.name from guest a where act_bal.name = a.no
update act_bal set oroomno = a.oroomno from rmsta a where act_bal.roomno = a.roomno
--
create table #account
(
	accnt			char(10)			not null,
	deptno6		char(5)			not null,
	amount		money				default 0 not null
)
insert #account select a.accnt, isnull(b.deptno6, '99'), sum(a.charge) from gltemp a, pccode b
	where a.pccode *= b.pccode and a.pccode < '9' group by a.accnt, isnull(b.deptno6, '99')
insert #account select a.accnt, isnull(b.deptno, 'Z'), sum(a.credit) from gltemp a, pccode b
	where a.pccode *= b.pccode and a.pccode >= '9' group by a.accnt, isnull(b.deptno, 'Z')
--
declare @deptno6 char(5), @count int
select @count=0
declare c_deptno cursor for select code from basecode where cat='chgcod_deptno6' order by sequence
open c_deptno
fetch c_deptno into @deptno6
while @@sqlstatus=0
begin
	select @count=@count+1
	if @count=1
		update act_bal set day01 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
	else if @count=2
		update act_bal set day02 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
	else if @count=3
		update act_bal set day03 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
	else if @count=4
		update act_bal set day04 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
	else if @count=5
		update act_bal set day05 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
	else if @count=6
		update act_bal set day06 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
	else if @count=7
		update act_bal set day07 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
	else if @count=8
		update act_bal set day08 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
	else if @count=9
		update act_bal set day09 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
	else if @count=10
		update act_bal set day10 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
	else if @count=11
		update act_bal set day11 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
	else if @count=12
		update act_bal set day12 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
	fetch c_deptno into @deptno6
end
close c_deptno

update act_bal set cred01 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = 'A'),0)
update act_bal set cred02 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = 'B'),0)
update act_bal set cred03 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = 'C'),0)
update act_bal set cred04 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = 'D'),0)
update act_bal set cred05 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 > 'D'),0)

------------------------
------ 累加计算 -------
------------------------
if @mode = 'A'  
	begin
	update act_bal set
		ttd01 = ttd01 + day01, ttd02 = ttd02 + day02,
		ttd03 = ttd03 + day03, ttd04 = ttd04 + day04,
		ttd05 = ttd05 + day05, ttd06 = ttd06 + day06,
		ttd07 = ttd07 + day07, ttd08 = ttd08 + day08,
		ttd09 = ttd09 + day09, ttd10 = ttd10 + day10,
		tcrd01 = tcrd01 + cred01, tcrd02 = tcrd02 + cred02,
		tcrd03 = tcrd03 + cred03, tcrd04 = tcrd04 + cred04,
		tcrd05 = tcrd05 + cred05
		where accnt not in (select accnt from act_bal_serve)

	update act_bal set
		act_bal.ttd01 = a.ttd01 + act_bal.day01, act_bal.ttd02 = a.ttd02 + act_bal.day02,
		act_bal.ttd03 = a.ttd03 + act_bal.day03, act_bal.ttd04 = a.ttd04 + act_bal.day04,
		act_bal.ttd05 = a.ttd05 + act_bal.day05, act_bal.ttd06 = a.ttd06 + act_bal.day06,
		act_bal.ttd07 = a.ttd07 + act_bal.day07, act_bal.ttd08 = a.ttd08 + act_bal.day08,
		act_bal.ttd09 = a.ttd08 + act_bal.day09, act_bal.ttd10 = a.ttd10 + act_bal.day10,
		act_bal.tcrd01 = a.tcrd01 + act_bal.cred01, act_bal.tcrd02 = a.tcrd02 + act_bal.cred02,
		act_bal.tcrd03 = a.tcrd03 + act_bal.cred03, act_bal.tcrd04 = a.tcrd04 + act_bal.cred04,
		act_bal.tcrd05 = a.tcrd05 + act_bal.cred05
		from act_bal_serve a where act_bal.accnt = a.accnt
	end
else
------------------------
------ 全部重算 -------
------------------------
	begin
	select * into #gltemp from gltemp where 1 = 2
	select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
	select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
	truncate table #account
	--
	if charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0
		begin
		truncate table #gltemp
		insert #gltemp (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
			charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
			tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
			select ar_accnt, subaccnt, ar_number, ar_inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
			charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, ar_tag, reason,
			tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno
			from ar_account where bdate <= @bdate and ar_subtotal = 'F'
		update #gltemp set pccode = '' where argcode >= '9' and charge != 0
		insert #account select a.accnt, isnull(b.deptno6, '99'), sum(a.charge) from #gltemp a, pccode b
			where a.pccode *= b.pccode and a.charge <> 0 group by a.accnt, isnull(b.deptno6, '99')
		insert #account select a.accnt, isnull(b.deptno, 'Z'), sum(a.credit) from #gltemp a, pccode b
			where a.pccode *= b.pccode and a.credit <> 0 group by a.accnt, isnull(b.deptno, 'Z')
		end
	--
	insert #account select a.accnt, isnull(b.deptno6, '99'), sum(a.charge) from account a, pccode b
		where a.bdate < = @bdate and (a.billno = '' or a.billno like @billno) and a.pccode *= b.pccode and a.argcode < '9'
		group by a.accnt, isnull(b.deptno6, '99')
	insert #account select a.accnt, isnull(b.deptno, 'Z'), sum(a.credit) from account a, pccode b
		where a.bdate < = @bdate and (a.billno = '' or a.billno like @billno) and a.pccode *= b.pccode and a.argcode >= '9'
		group by a.accnt, isnull(b.deptno, 'Z')
	--
	select @count=0
	open c_deptno
	fetch c_deptno into @deptno6
	while @@sqlstatus=0
	begin
		select @count=@count+1
		if @count=1
			update act_bal set day01 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
		else if @count=2
			update act_bal set day02 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
		else if @count=3
			update act_bal set day03 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
		else if @count=4
			update act_bal set day04 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
		else if @count=5
			update act_bal set day05 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
		else if @count=6
			update act_bal set day06 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
		else if @count=7
			update act_bal set day07 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
		else if @count=8
			update act_bal set day08 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
		else if @count=9
			update act_bal set day09 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
		else if @count=10
			update act_bal set day10 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
		else if @count=11
			update act_bal set day11 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
		else if @count=12
			update act_bal set day12 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = @deptno6),0)
		fetch c_deptno into @deptno6
	end
	close c_deptno

	--
	update act_bal set tcrd01 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = 'A'),0)
	update act_bal set tcrd02 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = 'B'),0)
	update act_bal set tcrd03 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = 'C'),0)
	update act_bal set tcrd04 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 = 'D'),0)
	update act_bal set tcrd05 = isnull((select sum(a.amount) from #account a where act_bal.accnt = a.accnt and a.deptno6 > 'D'),0)
	end

-- 计算合计项、余额
--update act_bal set date = @bdate,
--	day99 = day01 + day02 + day03 + day04 + day05 + day06 + day07 + day08 + day09 + day10,
--	ttd99 = ttd01 + ttd02 + ttd03 + ttd04 + ttd05 + ttd06 + ttd07 + ttd08 + ttd09 + ttd10,
--	cred99 = cred01 + cred02 + cred03 + cred04 + cred05,
--	tcrd99 = tcrd01 + tcrd02 + tcrd03 + tcrd04 + tcrd05
-- 以下三句话其实就是上面的一个语句。 因为在 linux 环境下，对 update 长度有限制 
-- 2007.9.12 simon 
update act_bal set date = @bdate,
	day99 = day01 + day02 + day03 + day04 + day05 + day06 + day07 + day08 + day09 + day10
update act_bal set 
	ttd99 = ttd01 + ttd02 + ttd03 + ttd04 + ttd05 + ttd06 + ttd07 + ttd08 + ttd09 + ttd10
update act_bal set 
	cred99 = cred01 + cred02 + cred03 + cred04 + cred05,
	tcrd99 = tcrd01 + tcrd02 + tcrd03 + tcrd04 + tcrd05


-- 不减，留待系统检查
--update act_bal set tillbl = ttd99 - tcrd99

-- 存储数据
insert yact_bal select * from act_bal

-- 纠正改名的问题
-- update yact_bal set name = isnull((select b.name from act_bal b where b.accnt = yact_bal.accnt ), name)

deallocate cursor c_deptno
return @ret
;
