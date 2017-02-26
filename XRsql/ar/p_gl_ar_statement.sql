if exists(select * from sysobjects where name = "p_gl_ar_statement1")
	drop proc p_gl_ar_statement1;

create proc p_gl_ar_statement1
	@pc_id				char(4),						// IP地址
	@mdi_id				integer,						// 唯一的账务窗口ID
	@selected			integer,						// 1.选中账;0.所有
	@langid				char(1)
as

create table #detail
(
	accnt				char(10)			not null,					/*账号*/
	number			integer			not null,					/*账次*/
	charge			money				default 0 not null,		/**/
	credit			money				default 0 not null		/**/
)
insert #detail (accnt, number, charge, credit)
	select a.accnt, a.number, a.charge + a.charge0 - a.charge9, a.credit + a.credit0 - a.credit9
	from ar_detail a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected >= @selected and b.accnt = a.accnt and b.number = a.number
delete #detail where charge = 0 and credit = 0
// 返回结果
if @langid = 'C'
	select a.date, a.ref1, a.guestname, b.charge, b.credit, balance = b.charge - b.credit
		from ar_detail a, #detail b where b.accnt = a.accnt and b.number = a.number and a.pnumber = 0
		order by a.log_date
else
	select a.date, a.ref1, a.guestname2, b.charge, b.credit, balance = b.charge - b.credit
		from ar_detail a, #detail b where b.accnt = a.accnt and b.number = a.number and a.pnumber = 0
		order by a.log_date
return
;

if exists (select * from sysobjects where name ='p_gl_ar_statement2' and type ='P')
	drop proc p_gl_ar_statement2;
create proc p_gl_ar_statement2
	@pc_id				char(4),						// IP地址
	@mdi_id				integer,						// 唯一的账务窗口ID
	@selected			integer,						// 1.选中账;0.所有
	@langid				char(1)
as

declare
	@bdate				datetime,
	@amount1				money,
	@amount2				money,
	@amount3				money,
	@amount4				money,
	@amount5				money,
	@amount6				money

create table #tor
(
	accnt					char(10),
	number				integer
)
--
select @bdate = bdate1 from sysdata
select * into #account from ar_account where 1 = 2
insert #account select a.* from ar_account a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected >= @selected and b.accnt = a.ar_accnt and b.number = a.ar_inumber
--
insert #tor select distinct ar_accnt, ar_pnumber from #account where ar_pnumber <> 0
--delete #account from #tor a where #account.ar_accnt = a.accnt and #account.ar_number = a.number
--delete #account where charge = charge9 and credit = credit9
delete #account where ar_subtotal='T'
update #account set date = a.date from ar_detail a where #account.ar_accnt = a.accnt and #account.ar_number = a.number
--
select @amount1 = sum(charge - charge9 - credit + credit9)
	from #account where datediff(dd, date, @bdate) <= 30
select @amount2 = sum(charge - charge9 - credit + credit9)
	from #account where datediff(dd, date, @bdate) > 30 and datediff(dd, date, @bdate) <= 60
select @amount3 = sum(charge - charge9 - credit + credit9)
	from #account where datediff(dd, date, @bdate) > 60 and datediff(dd, date, @bdate) <= 90
select @amount4 = sum(charge - charge9 - credit + credit9)
	from #account where datediff(dd, date, @bdate) > 90 and datediff(dd, date, @bdate) <= 180
select @amount5 = sum(charge - charge9 - credit + credit9)
	from #account where datediff(dd, date, @bdate) > 180 and datediff(dd, date, @bdate) <= 365
select @amount6 = sum(charge - charge9 - credit + credit9)
	from #account where datediff(dd, date, @bdate) > 365
--
select @amount1, @amount2, @amount3, @amount4, @amount5, @amount6
return 0
;
