if exists (select * from sysobjects where name ='p_gl_ar_aging' and type ='P')
	drop proc p_gl_ar_aging;
create proc p_gl_ar_aging
	@pc_id				char(4),						// IP地址
	@mdi_id				integer,						// 唯一的账务窗口ID
	@accnt				char(10),
	@subaccnt			integer,
	@option				char(1) = 'P',				// P.按pccode;D.按部门
	@langid				integer = 0
as

declare
	@bdate				datetime

create table #tor
(
	accnt					char(10),
	number				integer
)
create table #aging
(
	days					integer,
	descript				char(24),
	descript1			char(24),
	pccode				char(5),
	deptdes				char(24)		default '' null,
	deptdes1				char(24)		default '' null,
	charge				money			default 0 not null,				/* 借方 */
	credit				money			default 0 not null,				/* 贷方 */
	disputed				money			default 0 not null,				/* 争议金额 */
)

select @bdate = bdate1 from sysdata
select * into #account from ar_account where 1 = 2
if @accnt = ''
	insert #account select a.* from ar_account a, accnt_set b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.ar_accnt
else if @subaccnt = 0
	insert #account select * from ar_account where ar_accnt = @accnt
else
	insert #account select * from ar_account where ar_accnt = @accnt and ar_subaccnt = @subaccnt
--
insert #tor select distinct ar_accnt, ar_pnumber from #account where ar_pnumber <> 0
delete #account from #tor a where #account.ar_accnt = a.accnt and #account.ar_number = a.number
delete #account where (charge = charge9 and credit = credit9) or ar_subtotal = 'T'
update #account set date = a.date from ar_detail a where #account.ar_accnt = a.accnt and #account.ar_number = a.number
--
if @option != 'P'
	update #account set pccode = a.deptno from pccode a where #account.pccode = a.pccode and a.argcode < '9'
--
insert #aging (days, descript, descript1, pccode, charge, credit)
	select 30, '30天以内', 'Up to 30 days old', pccode, sum(charge - charge9), sum(credit - credit9)
	from #account where datediff(dd, date, @bdate) <= 30 group by pccode
insert #aging (days, descript, descript1, pccode, charge, credit)
	select 60, '31 - 60天', '31 - 60 days old', pccode, sum(charge - charge9), sum(credit - credit9)
	from #account where datediff(dd, date, @bdate) > 30 and datediff(dd, date, @bdate) <= 60 group by pccode
insert #aging (days, descript, descript1, pccode, charge, credit)
	select 90, '61 - 90天', '61 - 90 days old', pccode, sum(charge - charge9), sum(credit - credit9)
	from #account where datediff(dd, date, @bdate) > 60 and datediff(dd, date, @bdate) <= 90 group by pccode
insert #aging (days, descript, descript1, pccode, charge, credit)
	select 120, '91 - 120天', '91 - 120 days old', pccode, sum(charge - charge9), sum(credit - credit9)
	from #account where datediff(dd, date, @bdate) > 90 and datediff(dd, date, @bdate) <= 120 group by pccode
insert #aging (days, descript, descript1, pccode, charge, credit)
	select 180, '121 - 180天', '121 - 180 days old', pccode, sum(charge - charge9), sum(credit - credit9)
	from #account where datediff(dd, date, @bdate) > 120 and datediff(dd, date, @bdate) <= 180 group by pccode
insert #aging (days, descript, descript1, pccode, charge, credit)
	select 181, '181天以上', 'Over 181 days old', pccode, sum(charge - charge9), sum(credit - credit9)
	from #account where datediff(dd, date, @bdate) > 180 group by pccode
insert #aging (days, descript, descript1, pccode, charge, credit)
	select 200, '合计', 'Total', pccode, sum(charge - charge9), sum(credit - credit9) from #account group by pccode
--
delete #tor
insert #tor select distinct ar_accnt, ar_inumber from #account where charge <> charge9 or credit <> credit9
select a.* into #detail from ar_detail a, #tor b where a.accnt = b.accnt and a.number = b.number
insert #aging (days, descript, descript1, pccode, disputed)
	select 30, '30天以内', 'Up to 30 days old', 'zzzzz', isnull(sum(disputed), 0)
	from #detail where datediff(dd, date, @bdate) <= 30
insert #aging (days, descript, descript1, pccode, disputed)
	select 60, '31 - 60天', '31 - 60 days old', 'zzzzz', isnull(sum(disputed), 0)
	from #detail where datediff(dd, date, @bdate) > 30 and datediff(dd, date, @bdate) <= 60
insert #aging (days, descript, descript1, pccode, disputed)
	select 90, '61 - 90天', '61 - 90 days old', 'zzzzz', isnull(sum(disputed), 0)
	from #detail where datediff(dd, date, @bdate) > 60 and datediff(dd, date, @bdate) <= 90
insert #aging (days, descript, descript1, pccode, disputed)
	select 120, '91 - 120天', '91 - 120 days old', 'zzzzz', isnull(sum(disputed), 0)
	from #detail where datediff(dd, date, @bdate) > 90 and datediff(dd, date, @bdate) <= 120
insert #aging (days, descript, descript1, pccode, disputed)
	select 180, '121 - 180天', '121 - 180 days old', 'zzzzz', isnull(sum(disputed), 0)
	from #detail where datediff(dd, date, @bdate) > 120 and datediff(dd, date, @bdate) <= 180
insert #aging (days, descript, descript1, pccode, disputed)
	select 181, '181天以上', 'Over 181 days old', 'zzzzz', isnull(sum(disputed), 0)
	from #detail where datediff(dd, date, @bdate) > 180
insert #aging (days, descript, descript1, pccode, disputed)
	select 200, '合计', 'Total', 'zzzzz', isnull(sum(disputed), 0) from #detail
update #aging set pccode = ' F/O' where pccode = ''
--
if exists (select 1 from #aging where days = 30)
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 30, '30天以内', 'Up to 30 days old', '', sum(charge - credit), 0 from #aging where days = 30
else
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 30, '30天以内', 'Up to 30 days old', '', 0, 0
if exists (select 1 from #aging where days = 60)
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 60, '31 - 60天', '31 - 60 days old', '', sum(charge - credit), 0 from #aging where days = 60
else
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 60, '31 - 60天', '31 - 60 days old', '', 0, 0
if exists (select 1 from #aging where days = 90)
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 90, '61 - 90天', '61 - 90 days old', '', sum(charge - credit), 0 from #aging where days = 90
else
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 90, '61 - 90天', '61 - 90 days old', '', 0, 0
if exists (select 1 from #aging where days = 120)
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 120, '91 - 120天', '91 - 120 days old', '', sum(charge - credit), 0 from #aging where days = 120
else
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 120, '91 - 120天', '91 - 120 days old', '', 0, 0
if exists (select 1 from #aging where days = 180)
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 180, '121 - 180天', '121 - 180 days old', '', sum(charge - credit), 0 from #aging where days = 180
else
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 180, '121 - 180天', '121 - 180 days old', '', 0, 0
if exists (select 1 from #aging where days = 181)
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 181, '181天以上', 'Over 181 days old', '', sum(charge - credit), 0 from #aging where days = 181
else
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 181, '181天以上', 'Over 181 days old', '', 0, 0
if exists (select 1 from #aging where days = 200)
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 200, '合计', 'Total', '', sum(charge - credit), 0 from #aging where days = 200
else
	insert #aging (days, descript, descript1, pccode, charge, credit)
		select 200, '合计', 'Total', '', 0, 0
--
	update #aging set deptdes = a.descript, deptdes1 = a.descript1 from pccode a where #aging.pccode = a.pccode
if @option != 'P'
	update #aging set deptdes = a.descript, deptdes1 = a.descript1 from basecode a where a.cat = 'chgcod_deptno' and #aging.pccode = a.code
--
update #aging set deptdes = '未审核前台费用', deptdes1 = 'F/O' where pccode = ' F/O'
update #aging set deptdes = '余额', deptdes1 = 'Balance' where pccode = ''
update #aging set deptdes = '争议', deptdes1 = 'Disputed' where pccode = 'zzzzz'
if @langid = 0
	select days,  descript, pccode, deptdes, amount = charge + credit + disputed from #aging order by days, pccode
else
	select days,  descript1, pccode, deptdes1, amount = charge + credit + disputed from #aging order by days, pccode
return 0
;
