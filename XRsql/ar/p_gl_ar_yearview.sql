if exists (select * from sysobjects where name ='p_gl_ar_yearview' and type ='P')
	drop proc p_gl_ar_yearview;
create proc p_gl_ar_yearview
	@pc_id				char(4),						// IP地址
	@mdi_id				integer,						// 唯一的账务窗口ID
	@accnt				char(10),
	@subaccnt			integer,
	@langid				integer = 0
as

declare
	@count				integer, 
	@enddate				datetime,					// 截止日期
	@charge				money, 
	@credit				money, 
	@balance				money, 
	@apply				money, 
	@disputed			money, 
	@b_date				datetime,
	@e_date				datetime,
	@empname				char(10)

create table #yearview
(
	year					char(4),
	month					char(6),
	descript				char(20),
	descript1			char(20),
	b_date				datetime,
	e_date				datetime,
	charge				money			default 0 not null,				/* 借方 */
	credit				money			default 0 not null,				/* 贷方 */
	balance				money			default 0 not null,				/* 余额 */
	apply					money			default 0 not null,				/* 核销 */
	disputed				money			default 0 not null,				/* 争议金额 */
)

select * into #detail from ar_detail where 1 = 2
select * into #account from ar_account where 1 = 2
select * into #apply from ar_apply where 1 = 2
if @accnt = ''
	begin
	insert #detail select a.* from ar_detail a, accnt_set b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt
		union all select a.* from har_detail a, accnt_set b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt
	insert #account select a.* from ar_account a, accnt_set b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.ar_accnt
		union all select a.* from har_account a, accnt_set b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.ar_accnt
	insert #apply select a.* from ar_apply a, accnt_set b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and a.d_accnt = b.accnt
		union all select a.* from ar_apply a, accnt_set b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and a.c_accnt = b.accnt
	end
else if @subaccnt = 0
	begin
	insert #detail select * from ar_detail where accnt = @accnt
		union all select * from har_detail where accnt = @accnt
	insert #account select * from ar_account where ar_accnt = @accnt
		union all select * from har_account where ar_accnt = @accnt
	insert #apply select * from ar_apply where d_accnt = @accnt or c_accnt = @accnt
	end
else
	begin
	insert #detail select * from ar_detail where accnt = @accnt and subaccnt = @subaccnt
		union all select * from har_detail where accnt = @accnt and subaccnt = @subaccnt
	insert #account select * from ar_account where ar_accnt = @accnt and subaccnt = @subaccnt
		union all select * from har_account where ar_accnt = @accnt and subaccnt = @subaccnt
	insert #apply select a.* from ar_apply a, ar_detail b where a.d_accnt = @accnt and a.d_accnt = b.accnt and b.subaccnt = @subaccnt
		union all select a.* from ar_apply a, ar_detail b where a.c_accnt = @accnt and a.c_accnt = b.accnt and b.subaccnt = @subaccnt
		union all select a.* from ar_apply a, har_detail b where a.d_accnt = @accnt and a.d_accnt = b.accnt and b.subaccnt = @subaccnt
		union all select a.* from ar_apply a, har_detail b where a.c_accnt = @accnt and a.c_accnt = b.accnt and b.subaccnt = @subaccnt
	end
delete #account where ar_subtotal = 'T' or ar_tag in ('Z', 'z')
--
select @e_date = dateadd(dd, 1, bdate1), @b_date = dateadd(dd, 1 - datepart(dd, bdate1), bdate1) from sysdata
select @count = 0, @enddate = @e_date
while @count < 12
	begin
	insert #yearview (year, month, descript, descript1, b_date, e_date)
		select convert(char(4), datepart(yy, @b_date)), substring(convert(char(10), @b_date), 1, 3), '', '', @b_date, @e_date
	select @count = @count + 1, @e_date = @b_date, @b_date = dateadd(mm, - 1, @b_date)
	end
insert #yearview (year, month, descript, descript1, b_date, e_date) select '', '', '更早', 'Rest', '2000/01/01', @e_date
--
update #yearview set charge = isnull((select sum(a.charge) from #account a where a.bdate >= #yearview.b_date and a.bdate < #yearview.e_date), 0),
	credit = isnull((select sum(b.credit) from #account b where b.bdate >= #yearview.b_date and b.bdate < #yearview.e_date), 0),
	disputed = isnull((select sum(c.disputed) from #detail c where c.bdate >= #yearview.b_date and c.bdate < #yearview.e_date), 0)
update #yearview set balance = (select sum(a.charge - a.credit) from #yearview a where a.b_date <= #yearview.b_date)
update #yearview set apply = isnull((select sum(a.amount) from #apply a where a.bdate >= #yearview.b_date and a.bdate < #yearview.e_date), 0)
select @charge = sum(charge), @credit = sum(credit), @apply = sum(apply), @disputed = sum(disputed) from #yearview
select @balance = balance from #yearview where e_date = @enddate
--
insert #yearview (year, month, descript, descript1, b_date, e_date, charge, credit, balance, apply, disputed)
	select '', '', '合计', 'Total', '1900/01/01', '1900/01/01', @charge, @credit, @balance, @apply, @disputed
if @langid = 0
	begin
	update #yearview set descript = year + '年' + ltrim(substring('  一月  二月  三月  四月  五月  六月  七月  八月  九月  十月十一月十二月', datepart(mm, b_date) * 6 - 5, 6))
		where month <> ''
	select descript, charge, credit, balance, apply, disputed from #yearview order by b_date desc
	end
else
	begin
	update #yearview set descript1 = month + ' ' + year where month <> ''
	select descript1, charge, credit, balance, apply, disputed from #yearview order by b_date desc
	end
--
return 0
;
