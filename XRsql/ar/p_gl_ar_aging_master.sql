if exists (select * from sysobjects where name ='p_gl_ar_aging_master' and type ='P')
	drop proc p_gl_ar_aging_master;
create proc p_gl_ar_aging_master
	@accnt				char(10),
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
	pccode				char(5),
	deptdes				char(24)		default '' null,
	deptdes1				char(24)		default '' null,
	charge1				money			default 0 null,
	credit1				money			default 0 null,
	charge2				money			default 0 null,
	credit2				money			default 0 null,
	charge3				money			default 0 null,
	credit3				money			default 0 null,
	charge4				money			default 0 null,
	credit4				money			default 0 null,
	charge5				money			default 0 null,
	credit5				money			default 0 null,
	charge6				money			default 0 null,
	credit6				money			default 0 null,
	charge9				money			default 0 null,
	credit9				money			default 0 null,
)

select @bdate = bdate1 from sysdata
select * into #account from ar_account where 1 = 2
insert #account select * from ar_account where ar_accnt = @accnt
--
insert #tor select distinct ar_accnt, ar_pnumber from #account where ar_pnumber <> 0
delete #account from #tor a where #account.ar_accnt = a.accnt and #account.ar_number = a.number
delete #account where charge = charge9 and credit = credit9
update #account set date = a.date from ar_detail a where #account.ar_accnt = a.accnt and #account.ar_number = a.number
--
insert #aging (pccode, charge1, credit1)
	select pccode, sum(charge - charge9), sum(credit - credit9)
	from #account where datediff(dd, date, @bdate) <= 30 group by pccode
insert #aging (pccode, charge2, credit2)
	select pccode, sum(charge - charge9), sum(credit - credit9)
	from #account where datediff(dd, date, @bdate) > 30 and datediff(dd, date, @bdate) <= 60 group by pccode
insert #aging (pccode, charge3, credit3)
	select pccode, sum(charge - charge9), sum(credit - credit9)
	from #account where datediff(dd, date, @bdate) > 60 and datediff(dd, date, @bdate) <= 90 group by pccode
insert #aging (pccode, charge4, credit4)
	select pccode, sum(charge - charge9), sum(credit - credit9)
	from #account where datediff(dd, date, @bdate) > 90 and datediff(dd, date, @bdate) <= 120 group by pccode
insert #aging (pccode, charge5, credit5)
	select pccode, sum(charge - charge9), sum(credit - credit9)
	from #account where datediff(dd, date, @bdate) > 120 and datediff(dd, date, @bdate) <= 180 group by pccode
insert #aging (pccode, charge6, credit6)
	select pccode, sum(charge - charge9), sum(credit - credit9)
	from #account where datediff(dd, date, @bdate) > 180 group by pccode
insert #aging (pccode, charge9, credit9)
	select pccode, sum(charge - charge9), sum(credit - credit9) from #account group by pccode
update #aging set deptdes = '未审核前台费用', deptdes1 = 'F/O', pccode = ' F/O' where pccode = ''
-- 合计
insert #aging select '', '余额', 'Balance', sum(charge1), sum(credit1), sum(charge2), sum(credit2),
	sum(charge3), sum(credit3), sum(charge4), sum(credit4), sum(charge5), sum(credit5),
	sum(charge6), sum(credit6), sum(charge9), sum(credit9) from #aging
if @@rowcount = 0
	insert #aging select '', '余额', 'Balance', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
--
delete #tor
insert #tor select distinct ar_accnt, ar_inumber from #account where charge <> charge9 or credit <> credit9
select a.* into #detail from ar_detail a, #tor b where a.accnt = b.accnt and a.number = b.number
insert #aging (pccode, deptdes, deptdes1, charge1) select 'zzzzz', '争议', 'Disputed', isnull(sum(disputed), 0)
	from #detail where datediff(dd, date, @bdate) <= 30
insert #aging (pccode, deptdes, deptdes1, charge2) select 'zzzzz', '争议', 'Disputed', isnull(sum(disputed), 0)
	from #detail where datediff(dd, date, @bdate) > 30 and datediff(dd, date, @bdate) <= 60
insert #aging (pccode, deptdes, deptdes1, charge3) select 'zzzzz', '争议', 'Disputed', isnull(sum(disputed), 0)
	from #detail where datediff(dd, date, @bdate) > 60 and datediff(dd, date, @bdate) <= 90
insert #aging (pccode, deptdes, deptdes1, charge4) select 'zzzzz', '争议', 'Disputed', isnull(sum(disputed), 0)
	from #detail where datediff(dd, date, @bdate) > 90 and datediff(dd, date, @bdate) <= 120
insert #aging (pccode, deptdes, deptdes1, charge5) select 'zzzzz', '争议', 'Disputed', isnull(sum(disputed), 0)
	from #detail where datediff(dd, date, @bdate) > 120 and datediff(dd, date, @bdate) <= 180
insert #aging (pccode, deptdes, deptdes1, charge6) select 'zzzzz', '争议', 'Disputed', isnull(sum(disputed), 0)
	from #detail where datediff(dd, date, @bdate) > 180
insert #aging (pccode, deptdes, deptdes1, charge9) select 'zzzzz', '争议', 'Disputed', isnull(sum(disputed), 0)
	from #detail
if not exists (select 1 from #aging where pccode= 'zzzzz')
	insert #aging select 'zzzzz', '争议', 'Disputed', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
--
//if exists (select 1 from #aging where days = 30)
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 30, '30天以内', 'Up to 30 days old', '', sum(charge - credit), 0 from #aging where days = 30
//else
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 30, '30天以内', 'Up to 30 days old', '', 0, 0
//if exists (select 1 from #aging where days = 60)
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 60, '31 - 60天', '31 - 60 days old', '', sum(charge - credit), 0 from #aging where days = 60
//else
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 60, '31 - 60天', '31 - 60 days old', '', 0, 0
//if exists (select 1 from #aging where days = 90)
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 90, '61 - 90天', '61 - 90 days old', '', sum(charge - credit), 0 from #aging where days = 90
//else
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 90, '61 - 90天', '61 - 90 days old', '', 0, 0
//if exists (select 1 from #aging where days = 120)
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 120, '91 - 120天', '91 - 120 days old', '', sum(charge - credit), 0 from #aging where days = 120
//else
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 120, '91 - 120天', '91 - 120 days old', '', 0, 0
//if exists (select 1 from #aging where days = 180)
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 180, '121 - 180天', '121 - 180 days old', '', sum(charge - credit), 0 from #aging where days = 180
//else
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 180, '121 - 180天', '121 - 180 days old', '', 0, 0
//if exists (select 1 from #aging where days = 181)
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 181, '181天以上', 'Over 181 days old', '', sum(charge - credit), 0 from #aging where days = 181
//else
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 181, '181天以上', 'Over 181 days old', '', 0, 0
//if exists (select 1 from #aging where days = 200)
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 200, '合计', 'Total', '', sum(charge - credit), 0 from #aging where days = 200
//else
//	insert #aging (days, descript, descript1, pccode, charge, credit)
//		select 200, '合计', 'Total', '', 0, 0
//--
update #aging set deptdes = a.descript, deptdes1 = a.descript1 from pccode a where #aging.pccode = a.pccode
if @langid = 0
	select pccode, deptdes, sum(charge1 - credit1), sum(charge2 - credit2),
		sum(charge3 - credit3), sum(charge4 - credit4), sum(charge5 - credit5),
		sum(charge6 - credit6), sum(charge9 - credit9)
		from #aging group by pccode, deptdes order by pccode
else
	select pccode, deptdes1, sum(charge1 - credit1), sum(charge2 - credit2),
		sum(charge3 - credit3), sum(charge4 - credit4), sum(charge5 - credit5),
		sum(charge6 - credit6), sum(charge9 - credit9)
		from #aging group by pccode, deptdes1 order by pccode
return 0
;
