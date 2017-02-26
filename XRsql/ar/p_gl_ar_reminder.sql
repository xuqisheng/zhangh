if exists(select * from sysobjects where name = "p_gl_ar_reminder")
	drop proc p_gl_ar_reminder;

create proc p_gl_ar_reminder
	@pc_id				char(4),						// IP地址
	@mdi_id				integer,						// 唯一的账务窗口ID
	@selected			integer,						// 1.选中账;0.所有
	@option				char(2),						// A.逾期;C.当前
	@langid				char(1)
as
declare
	@bdate				datetime,
	@accnt				char(10),
	@cycle				char(5),
	@days					integer

select @bdate = bdate1 from sysdata
-- 根据催帐周期决定逾期账务, 现暂时定30天
select @accnt = min(accnt) from account_temp where pc_id = @pc_id and mdi_id = @mdi_id and selected > @selected
select @cycle = cycle from ar_master where accnt = @accnt
select @days = 30
--
create table #detail
(
	accnt				char(10)			not null,					/*账号*/
	number			integer			not null,					/*账次*/
	charge			money				default 0 not null,
	credit			money				default 0 not null,
	date				datetime			not null,
	age				char(10)			default '' not null
)
insert #detail (accnt, number, charge, credit, date)
	select a.accnt, a.number, a.charge + a.charge0 - a.charge9, a.credit + a.credit0 - a.credit9, date
	from ar_detail a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected >= @selected and b.accnt = a.accnt and b.number = a.number
delete #detail where charge = 0 and credit = 0
if @option like 'C%'
	delete #detail where datediff(dd, date, @bdate) > @days
else
	delete #detail where datediff(dd, date, @bdate) <= @days
-- 如要将账龄显示为其他格式(如0-30)改下面这一句
update #detail set age = convert(char(10), datediff(dd, date, @bdate))
-- 返回结果
if @langid = 'C'
	select a.date, b.age, a.ref1, a.guestname, b.charge, b.credit, balance = b.charge - b.credit
		from ar_detail a, #detail b where b.accnt = a.accnt and b.number = a.number and a.pnumber = 0
		order by a.log_date
else
	select a.date, b.age, a.ref1, a.guestname2, b.charge, b.credit, balance = b.charge - b.credit
		from ar_detail a, #detail b where b.accnt = a.accnt and b.number = a.number and a.pnumber = 0
		order by a.log_date
return
;
