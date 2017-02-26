/* 账单流水记录（账务查询用） */
if  exists(select * from sysobjects where name = "billno_temp" and type ="U")
	drop table billno_temp
;
create table billno_temp
(
	pc_id					char(4)			not null,
	mdi_id				integer			not null,
	billno				char(10)			not null,
	charge				money				default 0 not null,
	credit				money				default 0 not null,
	tor					money				default 0 not null,				/*记帐未收*/
	accntof				char(10)			default '' not null,
	empno					char(10)			default '' not null,
	log_date				datetime			default getdate() not null,
	selected				integer			default '0' not null,
)
;
exec sp_primarykey billno_temp, pc_id, mdi_id, billno
create unique index index1 on billno_temp(pc_id, mdi_id, billno)
;

if exists(select * from sysobjects where name = "p_gl_accnt_haccount_list1")
	drop proc p_gl_accnt_haccount_list1;

create proc p_gl_accnt_haccount_list1
	@pc_id			char(4),						// IP地址
	@mdi_id			integer,						// 唯一的账务窗口ID
	@roomno			char(5),						// 房号
	@accnt			char(10),					// 账号
	@subaccnt		integer						// 子账号(如果@roomno = '99999', @subaccnt就是临时账夹的编号)
as
declare
	@charge			money,
	@credit			money,
	@count			integer

create table #account
(
	accnt			char(10)		not null,							/*帐号*/
	number		integer		not null,							/*物理序列号,每个帐号分别从1开始*/
	inumber		integer		not null,							/*关联序列号(冲帐,转帐时有用)*/
	log_date		datetime		default getdate() not null,	/*生成日期*/
	pccode		char(5)		not null,							/*营业点码*/
	charge		money			default 0 not null,				/*借方数,记录客人消费*/
	credit		money			default 0 not null,				/*贷方数,记录客人定金及结算款*/
	tofrom		char(2)		default '' not null,				/*转帐方向,"TO"或"FM"*/
	accntof		char(10)		default '' not null,				/*转帐来源或目标*/
	billno		char(10)		default '' not null				/*结帐单号*/
)
create table #billno
(
	billno		char(10)		not null,							/*结帐单号*/
	accntof		char(10)		default '' not null,				/*转帐帐号*/
	charge		money			default 0 not null,				/*借方数,记录客人消费*/
	credit		money			default 0 not null,				/*贷方数,记录客人定金及结算款*/
	tor			money			default 0 not null,				/*记帐未收*/
	empno			char(10)		default '' not null,
	log_date		datetime		null									/*日期*/
)
delete billno_temp where pc_id = @pc_id and mdi_id = @mdi_id
// 所有
if @roomno = '' and @accnt = ''
	begin
	insert #account select b.accnt, b.number, b.inumber, b.log_date, b.pccode, b.charge, b.credit, b.tofrom, isnull(b.accntof, ''), b.billno from accnt_set a, account b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt = b.accnt and b.billno <> ''
	union select b.accnt, b.number, b.inumber, b.log_date, b.pccode, b.charge, b.credit, b.tofrom, isnull(b.accntof, ''), b.billno from accnt_set a, haccount b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt = b.accnt and b.billno <> ''
	end
// 指定房间
else if @accnt = ''
	begin
	insert #account select b.accnt, b.number, b.inumber, b.log_date, b.pccode, b.charge, b.credit, b.tofrom, isnull(b.accntof, ''), b.billno from accnt_set a, account b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0 and a.accnt = b.accnt and b.billno <> ''
	union select b.accnt, b.number, b.inumber, b.log_date, b.pccode, b.charge, b.credit, b.tofrom, isnull(b.accntof, ''), b.billno from accnt_set a, haccount b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0 and a.accnt = b.accnt and b.billno <> ''
	end
// 指定团体或账号
else
	begin
	insert #account select b.accnt, b.number, b.inumber, b.log_date, b.pccode, b.charge, b.credit, b.tofrom, isnull(b.accntof, ''), b.billno from account b
		where b.accnt = @accnt and b.billno <> ''
	union select b.accnt, b.number, b.inumber, b.log_date, b.pccode, b.charge, b.credit, b.tofrom, isnull(b.accntof, ''), b.billno from haccount b
		where b.accnt = @accnt and b.billno <> ''
	end
//
insert #billno (billno, charge, credit, log_date) select a.billno, sum(a.charge), sum(a.credit), max(a.log_date)
	from #account a where not a.billno like 'T%' group by a.billno
insert #billno (billno, accntof, charge, credit, log_date)
	select billno, accntof, -1 * sum(charge), -1 * sum(credit), max(log_date)
	from #account where billno like 'T%' and tofrom = 'TO' group by billno, accntof
update #billno set tor = isnull((select sum(b.charge - b.credit - b.archarge + b.arcredit)
	from #account a, transfer_log b where a.billno = #billno.billno and a.tofrom = 'TO' and a.accnt = b.accnt and a.inumber = b.number), 0)
update #billno set empno = a.empno1, log_date = a.date1 from billno a where #billno.billno = a.billno
insert billno_temp select @pc_id, @mdi_id, billno, charge, credit, tor, accntof, empno, log_date, 0 from #billno
// 3.加上'所有未结账'和'所有选中账'
select @charge = sum(a.charge), @credit = sum(a.credit), @count = count(1)
	from account a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.billno = ''
if @count > 0
	insert billno_temp values (@pc_id, @mdi_id, '所有未结账', @charge, @credit, 0, '', '', getdate(), 0)
select 0, ''
return
;
