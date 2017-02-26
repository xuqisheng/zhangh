if exists(select 1 from sysobjects where name = 'p_gl_accnt_bill_detail')
	drop  proc  p_gl_accnt_bill_detail;
create proc  p_gl_accnt_bill_detail
	@pc_id				char(4), 
	@mdi_id				integer, 
	@empno				char(10),
	@roomno				char(5), 
	@accnt				char(10), 
	@billno				char(10), 
	@code					char(3),
	@printall			char(1) = 'T'

as
declare 
	@language			char(1),
	@history				char(1),
	@lic_buy_1			varchar(255),
	@lic_buy_2			varchar(255),
	@nar					char(1),
	@empno1				char(10),
	@caccnt				char(10), 
	@count				money, 
	@count1				money, 
	@arr					datetime, 
	@dep					datetime, 
	@last_date			datetime, 
	@bdate				datetime, 
	@last_roomno		char(5), 
	@last_accntof		char(10), 
	@accntof				char(10), 
	@pccode				char(5), 
	@charge				money, 
	@credit				money, 
	@amount				money, 
	@mode					char(10),
	@log_date			datetime,
	@shift				char(1),
	@ref2					varchar(50),
	@title				char(20),
   @bos_setnumb		varchar(10),
   @bos_foliono		varchar(10),
   @bos_hsetnumb		varchar(10),
   @bos_hfoliono		varchar(10),
	@rm_pccodes			varchar(255)					-- 房费费用码

select @rm_pccodes = value from sysoption where catalog='audit' and item='room_charge_pccodes'
if @@rowcount = 0 or @rm_pccodes is null
	select @rm_pccodes = '1000 ,1001 ,1002 ,1003 ,1004 ,1005 ,1006 ,'
select @language= substring(@code, 3, 1), @code = substring(@code, 1, 2), @history = 'F'
--
create table #billmode
(
	accnt			char(10)		not null,							/* 账号 */
	subaccnt		integer		default 0 not null,				/* 子账号(用整数好像更方便一点？) */
	number		integer		not null,							/* 物理序列号,每个账号分别从1开始 */
	inumber		integer		not null,							/* 关联序列号(冲账,转账时有用) */
	modu_id		char(2)		not null,							/* 模块号 */
	log_date		datetime		default getdate() not null,	/* 生成日期 */
	bdate			datetime		not null,							/* 营业日期 */
	date			datetime		default getdate() not null,	/* 传票日期 */
	pccode		char(5)		not null,							/* 营业点码 */
	argcode		char(3)		default '' null,					/* 改编码(打印在账单的代码) */
	quantity		money			default 0 not null,				/* 数量 */
	charge		money			default 0 not null,				/* 借方数,记录客人消费 */
	charge1		money			default 0 not null,				/* 借方数(基本费) */
	charge2		money			default 0 not null,				/* 借方数(优惠费) */
	charge3		money			default 0 not null,				/* 借方数(服务费) */
	charge4		money			default 0 not null,				/* 借方数(税、附加费) */
	charge5		money			default 0 not null,				/* 借方数(其它) */
	package_d	money			default 0 not null,				/* 实际使用Package的金额,对应Package_Detail.charge */
	package_c	money			default 0 not null,				/* Package允许消费的金额,对应Package.credit,Package_Detail.credit */
	package_a	money			default 0 not null,				/* Package的实际金额,对应Package.amount */
	credit		money			default 0 not null,				/* 贷方数,记录客人定金及结算款 */
	balance		money			default 0 not null,				/* 新加字段 */
//
	shift			char(1)		not null,							/* 操作员班号 */
	empno			char(10)		not null,							/* 操作员工号 */
	crradjt		char(2)		default '' not null,				/* 账务标志(详见说明书) */
	waiter		char(3)		default '' not null,				/* 信用卡刷卡行代码 */
	tag			char(3)		null,									/* 市场码 */
	reason		char(3)		null,									/* 优惠理由 */
	tofrom		char(2)		default '' not null,				/* 转账方向,"TO"或"FM" */
	accntof		char(10)		default '' not null,				/* 转账来源或目标 */
	subaccntof	integer		default 0 not null,				/* 转账子账号(用整数好像更方便一点？) */
	ref			char(24)		default '' null,					/* 费用（账务）描述 */
	ref1			char(10)		default '' null,					/* 单号 */
	ref2			char(50)		default '' null,					/* 摘要 */
	roomno		char(5)		default '' not null,				/* 房号 */
	groupno		char(10)		default '' not null,				/* 团号 */
	mode			char(10)		null,									/* 房费明细信息 */
	billno		char(10)		default '' not null,				/* 结账单号 */
// 以下字段好像均不需要了？
	empno0		char(10)		null,									/* 分账（工号） */
	date0			datetime		null,									/* 分账（时间） */
	shift0		char(1)		null,									/* 分账（班号） */
	mode1			char(10)		null,									/* 稽核用 */
	pnumber		integer		default 0 null,					/* 同一个包的号码与第一条的inumber相同 */
	package		char(3)		null									/* 分账标志 */
)
select @count = count(1) from account a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and a.accnt = b.accnt and a.number = b.number

-- 语种处理
create table #pccode(pccode char(5) not null, descript char(50) default '' null )
create index index1 on #pccode(pccode)
if rtrim(@language) is null select @language='C'
if @language = '1' or @language = 'C' 
	insert #pccode select pccode, descript from pccode 
else if @language = '2' or @language = 'E' 
	insert #pccode select pccode, isnull(descript1,descript) from pccode 
else if @language = '3' or @language = 'J' 
	insert #pccode select pccode, isnull(descript2,descript) from pccode 
else if @language = '4' or @language = 'G' 
	insert #pccode select pccode, isnull(descript3,descript) from pccode 
else
	insert #pccode select pccode, isnull(descript1,descript) from pccode 


if @billno = '所有选中账'
	begin
	insert into #billmode select a.* from account a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.accnt = b.accnt and a.number = b.number
	insert into #billmode select a.* from haccount a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.accnt = b.accnt and a.number = b.number
	insert #billmode (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
		select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, a.charge-a.charge9, a.charge1-a.charge9, a.charge2,
		a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, a.credit-a.credit9, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.ar_tag, a.reason,
		a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, a.billno
		from ar_account a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.ar_accnt = b.accnt and a.ar_number = b.number
	insert #billmode (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
		select a.ar_accnt, a.subaccnt, a.ar_number, a.ar_inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, a.charge-a.charge9, a.charge1-a.charge9, a.charge2,
		a.charge3, a.charge4, a.charge5, a.package_d, a.package_c, a.package_a, a.credit-a.credit9, a.balance, a.shift, a.empno, a.crradjt, a.waiter, a.ar_tag, a.reason,
		a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.ref2, a.roomno, a.groupno, a.mode, a.billno
		from har_account a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.ar_accnt = b.accnt and a.ar_number = b.number
	end
else if @billno = '所有未结账'
	insert into #billmode select a.* from account a, account_temp b
		where b.pc_id= @pc_id and b.mdi_id = @mdi_id and b.billno = '' and a.accnt = b.accnt and a.number = b.number
else if @billno like 'T%'
	begin
	insert into #billmode select a.* from account a where billno = @billno
	insert into #billmode select a.* from haccount a where billno = @billno
	select @accntof = max(accntof), @log_date = max(log_date), @bdate = max(bdate), @shift = max(shift)
		from #billmode where tofrom = 'TO'
	delete #billmode where tofrom = 'TO'
	select @amount = sum(charge - credit) from #billmode
	if @accntof like 'A%'
		select @pccode = pccode from pccode where deptno2 = 'TOR'
	else
		select @pccode = pccode from pccode where deptno2 = 'TOA'
	if exists (select 1 from master where accnt = @accntof)
		select @ref2 = isnull(rtrim(a.roomno),a.accnt) + '    ' + b.name
			from master a, guest b where a.accnt = @accntof and a.haccnt = b.no
	else
		select @ref2 = isnull(rtrim(a.roomno), a.accnt) + '    ' + b.name
			from hmaster a, guest b where a.accnt = @accntof and a.haccnt = b.no
	insert #billmode(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
		quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
		crradjt, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, mode1)
		select @accnt, 1, 9999, 9999, '02', @log_date, @bdate, @log_date, @pccode, '99', 
		@amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, @amount, 0, @shift, @empno,
		'', '', '', '', '', 1, descript, '', isnull(@ref2, ''), '', '', '', '' from pccode where pccode = @pccode
	end
else if exists (select 1 from ar_apply where billno = @billno)					-- 新AR核销账单
	begin
	create table #apply
	(
		type				char(1)		null,
		accnt				char(10)		null,
		number			integer		null,
		charge			money			default 0 null,
		credit			money			default 0 null,
	)
	insert #apply (type, accnt, number, charge) select 'D', d_accnt, d_number, sum(amount)
		from ar_apply where billno = @billno group by d_accnt, d_number
	insert #apply (type, accnt, number, credit) select 'C', c_accnt, c_number, sum(amount)
		from ar_apply where billno = @billno group by c_accnt, c_number
	delete #apply where accnt = '' and number = 0
	--
	insert #billmode (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
		select a.accnt, a.subaccnt, a.number, a.inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, b.charge, b.charge,
		0, 0, 0, 0, 0, 0, 0, b.credit, a.balance, a.shift, a.empno, a.crradjt, '', a.tag, a.reason,
		a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.guestname + '/' + a.ref2, a.roomno, '', '', @billno
		from ar_detail a, #apply b
		where a.accnt = b.accnt and a.number = b.number
	insert #billmode (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
		select a.accnt, a.subaccnt, a.number, a.inumber, a.modu_id, a.log_date, a.bdate, a.date, a.pccode, a.argcode, a.quantity, b.charge, b.charge,
		0, 0, 0, 0, 0, 0, 0, b.credit, a.balance, a.shift, a.empno, a.crradjt, '', a.tag, a.reason,
		a.tofrom, a.accntof, a.subaccntof, a.ref, a.ref1, a.guestname + '/' + a.ref2, a.roomno, '', '', @billno
		from har_detail a, #apply b
		where a.accnt = b.accnt and a.number = b.number
	end
else
	begin
	insert into #billmode select a.* from account a where billno = @billno
	insert into #billmode select a.* from haccount a where billno = @billno
	end
--
if @code = '24'							-- AR账单 
	begin
	select * into #account_ar from account_ar where 1=2
	insert #account_ar (pc_id, mdi_id, sta, accnt, charge, credit, amount, amount1, ref, ref1, ref2, shift, empno, billno)
		select @pc_id, @mdi_id, 'F', a.accnt, sum(a.charge), sum(a.credit), sum(a.charge - a.credit), sum(a.charge - a.credit), 'Transfer from F/O', a.mode1, '', '', '', a.billno
		from #billmode a where a.mode1 like 'T%' group by a.accnt, a.mode1, a.billno
	update #account_ar set fmaccnt = a.accnt, shift = a.shift1, empno = a.empno1, bdate = a.bdate, log_date = a.date1
		from billno a where #account_ar.pc_id = @pc_id and #account_ar.mdi_id = @mdi_id and #account_ar.ref1 = a.billno
	update #account_ar set fmroomno = a.roomno, ref2 = b.name
		from master a, guest b
		where #account_ar.pc_id = @pc_id and #account_ar.mdi_id = @mdi_id and #account_ar.fmaccnt = a.accnt and a.haccnt = b.no
	update #account_ar set fmroomno = a.roomno, ref2 = b.name
		from hmaster a, guest b
		where #account_ar.pc_id = @pc_id and #account_ar.mdi_id = @mdi_id and #account_ar.fmaccnt = a.accnt and a.haccnt = b.no
	end
--
delete #billmode where pccode = '9'
if @printall != 'A'
	delete #billmode where accnt != @accnt
update #billmode set log_date = date where charindex(pccode, @rm_pccodes)>0
update #billmode set ref2='' where ref2 is null 
delete bill_data where pc_id = @pc_id

if @code = '21'								-- 完全明细 
	begin
	--不显示同住房费为零的客人
	update #billmode set tag = isnull(a.flag, '') from mktcode a where #billmode.tag *= a.code
	delete #billmode where charge = 0 and credit = 0 and tag != 'COM'

	insert bill_data(pc_id, code, charge, credit, item, descript, descript1, logdate)
		select @pc_id, a.pccode, a.charge, a.credit, substring(convert(char(10), a.date, 101), 1, 5) +space(4)+ isnull(rtrim(b.descript), a.ref) + space(2) + 
		substring(a.ref2, 1, 5) , isnull(a.ref1, ''), right(accntof,10), a.log_date
		from #billmode a, #pccode b where a.pccode *= b.pccode and a.ref2 like '%([0-9][0-9][0-9][0-9]/[0-1][0-9]/[0-3][0-9])%'

	insert bill_data(pc_id, code, charge, credit, item, descript, descript1, logdate)
		select @pc_id, a.pccode, a.charge, a.credit, substring(convert(char(10), a.date, 101), 1, 5) +space(4)+ isnull(rtrim(b.descript), a.ref) + space(2) + 
		rtrim(a.ref2 + space(1) + rtrim(a.ref1)) + '['+rtrim(a.roomno)+']' , isnull(a.ref1, ''), right(accntof,10), a.log_date
		from #billmode a, #pccode b where a.pccode *= b.pccode and (a.ref2 not like '%([0-9][0-9][0-9][0-9]/[0-1][0-9]/[0-3][0-9])%' or rtrim(a.ref2) is null)
			and rtrim(a.roomno) is not null and rtrim(a.accntof) is not null and a.ref2 not like '%]%'

	insert bill_data(pc_id, code, charge, credit, item, descript, descript1, logdate)
		select @pc_id, a.pccode, a.charge, a.credit, substring(convert(char(10), a.date, 101), 1, 5) +space(4)+ isnull(rtrim(b.descript), a.ref) + space(2) + 
		rtrim(a.ref2 + space(1) + rtrim(a.ref1)), isnull(a.ref1, ''), right(accntof,10), a.log_date
		from #billmode a, #pccode b where a.pccode *= b.pccode and (a.ref2 not like '%([0-9][0-9][0-9][0-9]/[0-1][0-9]/[0-3][0-9])%' or rtrim(a.ref2) is null)
			and (rtrim(a.roomno) is null or rtrim(a.accntof) is null or a.ref2 like '%]%')
																				 
	end
else if @code = '24'							-- AR账单 
	begin
	insert #account_ar (pc_id, mdi_id, sta, accnt, number, modu_id, pccode, charge, credit, amount, amount1, ref, ref1, ref2, shift, empno, bdate, log_date, billno)
		select @pc_id, @mdi_id, 'P', a.accnt, a.number, a.modu_id, a.pccode, a.charge, a.credit, a.charge + a.credit, a.charge - a.credit, isnull(c.descript1, a.ref), a.ref1, a.ref2, a.shift, a.empno, a.bdate, a.log_date, a.billno
		from #billmode a, pccode c where a.mode1 not like 'T%' and a.pccode *= c.pccode
	insert bill_data(pc_id, code, charge, credit, item, descript, logdate)
		select @pc_id, isnull(pccode, ''), charge, credit, substring(convert(char(10), log_date, 101), 1, 5) + '  ' + substring(ref + space(24), 1, 24) + 
		substring(ref2 + space(50), 1, 50), isnull(ref1, ''), log_date from #account_ar
	end
else if @code = '25'							-- 按费用分类 
	begin
	insert bill_data(pc_id, code, charge, credit, item)
		select @pc_id, a.argcode, sum(a.charge), sum(a.credit), space(8) + b.descript +  '    (' + convert(varchar,count(1))+')'
		from #billmode a, argcode b where a.pccode < '9' and a.argcode = b.argcode
		group by a.argcode, b.descript having sum(a.charge) <> 0 or sum(a.credit) <> 0
	insert bill_data(pc_id, code, charge, credit, item)
		select @pc_id, a.pccode, sum(a.charge), sum(a.credit), space(8) + b.descript +  '    (' + convert(varchar,count(1))+')'
		from #billmode a, #pccode b where a.pccode > '9' and a.pccode = b.pccode
		group by a.pccode, b.descript having sum(a.charge) <> 0 or sum(a.credit) <> 0
	end
else if @code = '26'							-- 按日期分类 
	begin
								  
	insert bill_data(pc_id, code, charge, credit, item, logdate)
	select  @pc_id, a.pccode, sum(a.charge), sum(a.credit), char40 = convert(char(10), a.date, 102)+space(6)+b.descript+space(4)+convert(varchar,count(1)) + ' X ' + convert(varchar,a.charge), convert(char(10), a.date, 102)
	from #billmode a,pccode b where a.pccode < '9' and a.pccode=b.pccode 
	group by convert(char(10), a.date, 102), a.pccode, b.descript, a.charge having (sum(a.charge) <> 0 or sum(a.credit) <> 0)
	and count(*) > 1

	insert bill_data(pc_id, code,  charge, credit, item, descript1, logdate)
	select @pc_id, a.pccode, a.charge, a.credit, char40 = convert(char(10), a.date, 102)+space(4)+b.descript+space(2)+substring(a.ref2, 1, 5), right(a.accntof,10), convert(char(10), a.date, 102)
	from #billmode a,pccode b where a.pccode < '9' and a.pccode=b.pccode and a.ref2 like '%([0-9][0-9][0-9][0-9]/[0-1][0-9]/[0-3][0-9])%'
	having (select count(1) from #billmode c where a.pccode=c.pccode and a.charge = c.charge 
	and convert(char(10), a.date, 102) = convert(char(10), c.date, 102)) = 1
	and (a.charge <> 0 or a.credit <> 0)

	insert bill_data(pc_id, code,  charge, credit, item, descript1, logdate)
	select @pc_id, a.pccode, a.charge, a.credit, char40 = convert(char(10), a.date, 102)+space(4)+b.descript+space(2)+ rtrim(a.ref2 + space(1) + rtrim(a.ref1)) + '['+rtrim(a.roomno)+']', right(a.accntof,10), convert(char(10), a.date, 102)
	from #billmode a,pccode b where a.pccode < '9' and a.pccode=b.pccode and (a.ref2 not like '%([0-9][0-9][0-9][0-9]/[0-1][0-9]/[0-3][0-9])%' or rtrim(a.ref2) is null) and rtrim(a.roomno) is not null and rtrim(a.accntof) is not null and a.ref2 not like '%]%'
	having (select count(1) from #billmode c where a.pccode=c.pccode and a.charge = c.charge 
	and convert(char(10), a.date, 102) = convert(char(10), c.date, 102)) = 1
	and (a.charge <> 0 or a.credit <> 0)

	insert bill_data(pc_id, code,  charge, credit, item, descript1, logdate)
	select @pc_id, a.pccode, a.charge, a.credit, char40 = convert(char(10), a.date, 102)+space(4)+b.descript+space(2)+ rtrim(a.ref2 + space(1) + rtrim(a.ref1)), right(a.accntof,10), convert(char(10), a.date, 102)
	from #billmode a,pccode b where a.pccode < '9' and a.pccode=b.pccode and (a.ref2 not like '%([0-9][0-9][0-9][0-9]/[0-1][0-9]/[0-3][0-9])%' or rtrim(a.ref2) is null) and (rtrim(a.roomno) is null or rtrim(a.accntof) is null or a.ref2 like '%]%')
	having (select count(1) from #billmode c where a.pccode=c.pccode and a.charge = c.charge 
	and convert(char(10), a.date, 102) = convert(char(10), c.date, 102)) = 1
	and (a.charge <> 0 or a.credit <> 0)
	
--		insert bill_data(pc_id, code, charge, credit, item, logdate)
--		select  @pc_id, a.pccode, sum(a.charge), sum(a.credit), char40 = convert(char(10), a.date, 102)+space(6)+b.descript+space(4)+convert(varchar,count(1)) + ' X ' + convert(varchar,a.charge), convert(char(10), a.date, 102)
--		from #billmode a,pccode b where a.pccode < '9' and a.pccode=b.pccode anda.tofrom <> 'TO' 
--		group by convert(char(10), a.date, 102), a.pccode, b.descript, a.charge having (sum(a.charge) <> 0 or sum(a.credit) <> 0)
--		and count(*) = 1

	insert bill_data(pc_id, code, charge, credit, item, logdate)
		select @pc_id, code = a.pccode, sum(a.charge), sum(a.credit), convert(char(10), a.date, 102)+space(4)+ b.descript, convert(char(10), a.date, 102)
		from #billmode a, #pccode b where a.pccode > '9' and a.pccode = b.pccode
		group by convert(char(10), a.date, 102), a.pccode, b.descript having sum(a.charge) <> 0 or sum(a.credit) <> 0
	end
else if @code = '27'							-- 按房间费用分类 
	begin
	insert bill_data(pc_id, code, charge, credit, item)
		select @pc_id, code = a.roomno, sum(a.charge), sum(a.credit), space(8) + a.roomno + '  ' + b.descript
		from #billmode a, argcode b where a.pccode < '9' and a.argcode = b.argcode
		group by a.roomno, a.argcode, b.descript having sum(a.charge) <> 0 or sum(a.credit) <> 0
	insert bill_data(pc_id, code, charge, credit, item)
		select @pc_id, code = a.roomno, sum(a.charge), sum(a.credit), space(8) + a.roomno + '  ' + b.descript
		from #billmode a, #pccode b where a.pccode > '9' and a.pccode = b.pccode
		group by a.roomno, a.pccode, b.descript having sum(a.charge) <>0 or sum(a.credit) <> 0
	end
else if @code = '28'                   --按成员分类
    begin
    insert bill_data(pc_id, code, charge, credit, item)
		select @pc_id, code = a.accnt, sum(a.charge), sum(a.credit), '['
		from #billmode a
		group by a.accnt having sum(a.charge) <>0 or sum(a.credit) <> 0
    update bill_data set item=item+b.roomno+']'+c.name from master b, guest c where b.accnt=bill_data.code and b.haccnt=c.no and bill_data.pc_id=@pc_id
    end

-- 准备bill_mst
--delete bill_mst where pc_id = @pc_id
if @accnt = ''
	select @accnt = isnull((select min(accnt) from #billmode), '')
-- 所有
if @roomno = '' and @accnt = ''
	declare c_accnt cursor for select accnt from accnt_set
		where pc_id= @pc_id and mdi_id = @mdi_id and subaccnt = 0 order by roomno desc
-- 指定房间
else if @accnt = ''
	declare c_accnt cursor for select accnt from accnt_set
		where pc_id = @pc_id and mdi_id = @mdi_id and roomno = @roomno and subaccnt = 0 order by accnt
-- 指定团体或账号
else
	declare c_accnt cursor for select accnt from accnt_set
		where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt and subaccnt = 0
open c_accnt
fetch c_accnt into @caccnt
while @@sqlstatus = 0
	begin
	if @caccnt != ''
		break
	fetch c_accnt into @caccnt
	end
close c_accnt
deallocate cursor c_accnt
--
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
if @caccnt like 'A%' and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
	begin
	select @nar = 'T'
	if not exists (select 1 from ar_master where accnt = @caccnt)
		select @history = 'T'
	end
else
	begin
	select @nar = 'F'
	if not exists (select 1 from master where accnt = @caccnt)
		select @history = 'T'
	end
--为了能打印出Total,Balance
if not exists(select 1 from bill_data where pc_id = @pc_id)
	insert bill_data(pc_id, code, charge, credit, item) select @pc_id, '', 0, 0, ''
--
select @charge = sum(charge), @credit = sum(credit) from #billmode
if @nar = 'F' and @history ='F'
	begin
	if @billno like 'B%'
		begin
		select @empno1 = empno1 from billno where billno = @billno
		update bill_data set char1=b.name, char2=a.cusno, char3=a.groupno, char4=isnull(b.street ,''), char5=isnull(rtrim(@empno1), @empno), char6=a.roomno, char7=@caccnt, char8=isnull(@ref2, ''),char9=(select descript1 + '  '+ descript from countrycode where code=b.nation), date1=isnull(a.citime, a.arr), date2=isnull(a.cotime, a.dep), mone1= a.gstno, sum1='消费合计：       ' + convert(char(10), @charge), sum2 ='付款合计：       ' + convert(char(10), @credit)
			from master a, guest b where a.accnt = @caccnt and a.haccnt = b.no and bill_data.pc_id = @pc_id
--		insert bill_mst(pc_id, char1, char2, char3, char4, char5, char6, char7, char8,char9, date1, date2, mone1, sum1, sum2)
--			select @pc_id, b.name, a.cusno, a.groupno, isnull(b.street ,''), isnull(rtrim(@empno1), @empno), a.roomno, @caccnt, isnull(@ref2, ''),(select descript1 + '  '+ descript from countrycode where code=b.nation), isnull(a.citime, a.arr), isnull(a.cotime, a.dep), a.gstno,
--			'消费合计：       ' + convert(char(10), @charge), '付款合计：       ' + convert(char(10), @credit)
--			from master a, guest b where a.accnt = @caccnt and a.haccnt = b.no
		end
	else
		update bill_data set char1=b.name, char2=a.cusno, char3=a.groupno, char4=isnull(b.street ,''), char5=@empno, char6=a.roomno, char7=@caccnt, char8=isnull(@ref2, ''),char9=(select descript1 + '  '+ descript from countrycode where code=b.nation), date1=isnull(a.citime, a.arr), date2=isnull(a.cotime, a.dep), mone1= a.gstno, sum1='消费合计：       ' + convert(char(10), @charge), sum2 ='付款合计：       ' + convert(char(10), @credit)
			from master a, guest b where a.accnt = @caccnt and a.haccnt = b.no and bill_data.pc_id = @pc_id
--		insert bill_mst(pc_id, char1, char2, char3, char4, char5, char6, char7, char8,char9, date1, date2, mone1, sum1, sum2)
--			select @pc_id, b.name, a.cusno, a.groupno, isnull(b.street,''),@empno, a.roomno, @caccnt, isnull(@ref2, ''),(select descript1 + '  '+ descript from countrycode where code=b.nation), isnull(a.citime, a.arr), isnull(a.cotime, a.dep), a.gstno,
--			'消费合计：       ' + convert(char(10), @charge), '付款合计：       ' + convert(char(10), @credit)
--			from master a, guest b where a.accnt = @caccnt and a.haccnt = b.no

	-- 加入称谓 add by cq
	select @title = c.short from master a,guest b,greeting c where a.accnt = @caccnt and a.haccnt = b.no and b.lang = c.lang and b.title = c.code
	if not (@@rowcount = 0 or rtrim(@title) is null)
		begin
		if (select b.lang from master a,guest b where a.accnt = @caccnt and a.haccnt = b.no) = 'C'
			update bill_data set char1 = char1+' '+rtrim(@title) where bill_data.pc_id = @pc_id 
		else
			update bill_data set char1 = rtrim(@title) +' '+char1 where bill_data.pc_id = @pc_id 
		end
	end
else if @nar = 'F' 
	begin
	if @billno like 'B%'
		begin
		select @empno1 = empno1 from billno where billno =@billno
		update bill_data set char1=b.name, char2=a.cusno, char3=a.groupno, char4=isnull(b.street ,''), char5=isnull(rtrim(@empno1), @empno), char6=a.roomno, char7=@caccnt, char8=isnull(@ref2, ''),char9=(select descript1 + '  '+ descript from countrycode where code=b.nation), date1=isnull(a.citime, a.arr), date2=isnull(a.cotime, a.dep), mone1= a.gstno, sum1='消费合计：       ' + convert(char(10), @charge), sum2 ='付款合计：       ' + convert(char(10), @credit)
			from hmaster a, guest b where a.accnt = @caccnt and a.haccnt = b.no and bill_data.pc_id = @pc_id
--		insert bill_mst(pc_id, char1, char2, char3, char4, char5, char6, char7, char8, char9, date1, date2, mone1, sum1, sum2)
--			select @pc_id,b.name, a.cusno, a.groupno, isnull(b.street,''), isnull(rtrim(@empno1), @empno), a.roomno, @caccnt, isnull(@ref2, ''),(select descript1 + '  '+ descript from countrycode where code=b.nation), isnull(a.citime, a.arr), isnull(a.cotime, a.dep), a.gstno,
--			'消费合计：       ' + convert(char(10), @charge), '付款合计：    ' + convert(char(10), @credit)
--			from hmaster a, guest b where a.accnt = @caccnt and a.haccnt = b.no
		end
	else
		update bill_data set char1=b.name, char2=a.cusno, char3=a.groupno, char4=isnull(b.street ,''), char5=@empno, char6=a.roomno, char7=@caccnt, char8=isnull(@ref2, ''),char9=(select descript1 + '  '+ descript from countrycode where code=b.nation), date1=isnull(a.citime, a.arr), date2=isnull(a.cotime, a.dep), mone1= a.gstno, sum1='消费合计：       ' + convert(char(10), @charge), sum2 ='付款合计：       ' + convert(char(10), @credit)
			from hmaster a, guest b where a.accnt = @caccnt and a.haccnt = b.no and bill_data.pc_id = @pc_id
--		insert bill_mst(pc_id, char1, char2, char3, char4, char5, char6, char7, char8, char9, date1, date2, mone1, sum1, sum2)
--			select @pc_id,b.name, a.cusno, a.groupno, isnull(b.street,''), @empno, a.roomno, @caccnt, isnull(@ref2, ''),(select descript1 + '  '+ descript from countrycode where code=b.nation), isnull(a.citime, a.arr), isnull(a.cotime, a.dep), a.gstno,
--			'消费合计： ' + convert(char(10), @charge), '付款合计：       ' + convert(char(10), @credit)
--			from hmaster a, guest b where a.accnt = @caccnt and a.haccnt = b.no
	-- 加入称谓 add by cq
	select @title = c.short from hmaster a,guest b,greeting c where a.accnt = @caccnt and a.haccnt = b.no and b.lang = c.lang and b.title = c.code
	if not (@@rowcount = 0 or rtrim(@title) is null)
		begin
		if (select b.lang from master a,guest b where a.accnt = @caccnt and a.haccnt = b.no) = 'C'
			update bill_data set char1 = char1+' '+rtrim(@title) where bill_data.pc_id = @pc_id 
		else
			update bill_data set char1 = rtrim(@title) +' '+char1 where bill_data.pc_id = @pc_id 
		end
	end
else if @history ='F'
	begin
	if @billno like 'B%'
		begin
		select @empno1 = empno1 from billno where billno = @billno
		update bill_data set char1=b.name, char4=isnull(b.street ,''), char5=isnull(rtrim(@empno1), @empno), char7=@caccnt, char8=isnull(@ref2, ''),char9=(select descript1 + '  '+ descript from countrycode where code=b.nation), date1=a.arr, date2=a.dep, sum1='消费合计：       ' + convert(char(10), @charge), sum2 ='付款合计：       ' + convert(char(10), @credit)
			from ar_master a, guest b where a.accnt = @caccnt and a.haccnt = b.no and bill_data.pc_id = @pc_id
--		insert bill_mst(pc_id, char1, char2, char3, char4, char5, char6, char7, char8,char9, date1, date2, mone1, sum1, sum2)
--			select @pc_id, b.name, a.cusno, a.groupno, isnull(b.street ,''), isnull(rtrim(@empno1), @empno), a.roomno, @caccnt, isnull(@ref2, ''),(select descript1 + '  '+ descript from countrycode where code=b.nation), isnull(a.citime, a.arr), isnull(a.cotime, a.dep), a.gstno,
--			'消费合计：       ' + convert(char(10), @charge), '付款合计：       ' + convert(char(10), @credit)
--			from master a, guest b where a.accnt = @caccnt and a.haccnt = b.no
		end
	else
		update bill_data set char1=b.name, char4=isnull(b.street ,''), char5=@empno, char7=@caccnt, char8=isnull(@ref2, ''),char9=(select descript1 + '  '+ descript from countrycode where code=b.nation), date1=a.arr, date2=a.dep, sum1='消费合计：       ' + convert(char(10), @charge), sum2 ='付款合计：       ' + convert(char(10), @credit)
			from ar_master a, guest b where a.accnt = @caccnt and a.haccnt = b.no and bill_data.pc_id = @pc_id
--		insert bill_mst(pc_id, char1, char2, char3, char4, char5, char6, char7, char8,char9, date1, date2, mone1, sum1, sum2)
--			select @pc_id, b.name, a.cusno, a.groupno, isnull(b.street,''),@empno, a.roomno, @caccnt, isnull(@ref2, ''),(select descript1 + '  '+ descript from countrycode where code=b.nation), isnull(a.citime, a.arr), isnull(a.cotime, a.dep), a.gstno,
--			'消费合计：       ' + convert(char(10), @charge), '付款合计：       ' + convert(char(10), @credit)
--			from master a, guest b where a.accnt = @caccnt and a.haccnt = b.no

	-- 加入称谓 add by cq
	select @title = c.short from master a,guest b,greeting c where a.accnt = @caccnt and a.haccnt = b.no and b.lang = c.lang and b.title = c.code
	if not (@@rowcount = 0 or rtrim(@title) is null)
		begin
		if (select b.lang from master a,guest b where a.accnt = @caccnt and a.haccnt = b.no) = 'C'
			update bill_data set char1 = char1+' '+rtrim(@title) where bill_data.pc_id = @pc_id 
		else
			update bill_data set char1 = rtrim(@title) +' '+char1 where bill_data.pc_id = @pc_id 
		end
	end
else
	begin
	if @billno like 'B%'
		begin
		select @empno1 = empno1 from billno where billno =@billno
		update bill_data set char1=b.name, char4=isnull(b.street ,''), char5=isnull(rtrim(@empno1), @empno), char7=@caccnt, char8=isnull(@ref2, ''),char9=(select descript1 + '  '+ descript from countrycode where code=b.nation), date1=a.arr, date2=a.dep, sum1='消费合计：       ' + convert(char(10), @charge), sum2 ='付款合计：       ' + convert(char(10), @credit)
			from har_master a, guest b where a.accnt = @caccnt and a.haccnt = b.no and bill_data.pc_id = @pc_id
--		insert bill_mst(pc_id, char1, char2, char3, char4, char5, char6, char7, char8, char9, date1, date2, mone1, sum1, sum2)
--			select @pc_id,b.name, a.cusno, a.groupno, isnull(b.street,''), isnull(rtrim(@empno1), @empno), a.roomno, @caccnt, isnull(@ref2, ''),(select descript1 + '  '+ descript from countrycode where code=b.nation), isnull(a.citime, a.arr), isnull(a.cotime, a.dep), a.gstno,
--			'消费合计：       ' + convert(char(10), @charge), '付款合计：    ' + convert(char(10), @credit)
--			from hmaster a, guest b where a.accnt = @caccnt and a.haccnt = b.no
		end
	else
		update bill_data set char1=b.name, char4=isnull(b.street ,''), char5=@empno, char7=@caccnt, char8=isnull(@ref2, ''),char9=(select descript1 + '  '+ descript from countrycode where code=b.nation), date1=a.arr, date2=a.dep, sum1='消费合计：       ' + convert(char(10), @charge), sum2 ='付款合计：       ' + convert(char(10), @credit)
			from har_master a, guest b where a.accnt = @caccnt and a.haccnt = b.no and bill_data.pc_id = @pc_id
--		insert bill_mst(pc_id, char1, char2, char3, char4, char5, char6, char7, char8, char9, date1, date2, mone1, sum1, sum2)
--			select @pc_id,b.name, a.cusno, a.groupno, isnull(b.street,''), @empno, a.roomno, @caccnt, isnull(@ref2, ''),(select descript1 + '  '+ descript from countrycode where code=b.nation), isnull(a.citime, a.arr), isnull(a.cotime, a.dep), a.gstno,
--			'消费合计： ' + convert(char(10), @charge), '付款合计：       ' + convert(char(10), @credit)
--			from hmaster a, guest b where a.accnt = @caccnt and a.haccnt = b.no
	-- 加入称谓 add by cq
	select @title = c.short from hmaster a,guest b,greeting c where a.accnt = @caccnt and a.haccnt = b.no and b.lang = c.lang and b.title = c.code
	if not (@@rowcount = 0 or rtrim(@title) is null)
		begin
		if (select b.lang from master a,guest b where a.accnt = @caccnt and a.haccnt = b.no) = 'C'
			update bill_data set char1 = char1+' '+rtrim(@title) where bill_data.pc_id = @pc_id 
		else
			update bill_data set char1 = rtrim(@title) +' '+char1 where bill_data.pc_id = @pc_id 
		end
	end
update bill_data set char2 = a.name from guest a where bill_data.pc_id = @pc_id and bill_data.char2 = a.no 
update bill_data set char3 = a.name from guest a where bill_data.pc_id = @pc_id and bill_data.char3 = a.no 

update bill_data set item = item+'('+(select b.name from master a,guest b where bill_data.descript1=a.accnt and a.haccnt=b.no)+')' where
	descript1 <> '' and descript1 in (select accnt from master)
update bill_data set item = item+'('+(select b.name from hmaster a,guest b where bill_data.descript1=a.accnt and a.haccnt=b.no)+')' where
	descript1 <> '' and descript1 not in (select accnt from master)

select 0, ''
;