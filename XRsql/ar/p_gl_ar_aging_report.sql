if exists (select * from sysobjects where name ='arrepo' and type ='U')
	drop table arrepo;
create table arrepo
(
	pc_id			char(4)			not null, 
	catalog		char(3)			not null, 
	accnt			char(10)			not null, 
	bdate			datetime			default getdate() not null, 
	roomno		char(5)			default '' not null, 
	descript		char(24)			default '' not null, 
	name			char(50)			default '' not null, 
	guestname	char(50)			default '' not null, 
	amount1		money				default 0 not null, 					-- 0 - 30
	amount2		money				default 0 not null, 					-- 31 - 60
	amount3		money				default 0 not null, 					-- 61 - 90
	amount4		money				default 0 not null, 					-- 91 - 120
	amount5		money				default 0 not null, 					-- 121 - 180
	amount6		money				default 0 not null, 					-- over 180
	amount7		money				default 0 not null, 
	amount8		money				default 0 not null, 
	amount9		money				default 0 not null, 
	amount10		money				default 0 not null, 
	amount		money				default 0 not null
)
exec sp_primarykey arrepo, pc_id, catalog, accnt, bdate, descript
create unique index index1 on arrepo(pc_id, catalog, accnt, bdate, descript)
;

------------------------------------------------------------------
--	帐龄分析表：支持截止日期、汇总分析、费用项目等
------------------------------------------------------------------
IF OBJECT_ID('dbo.p_gl_ar_aging_report') IS NOT NULL
    DROP PROCEDURE dbo.p_gl_ar_aging_report
;
create proc p_gl_ar_aging_report
	@pc_id			char(4), 
	@dates			varchar(255), 
	@option			char(10), 
	@deptno			char(4) = 'ALL', 
	@artag			varchar(20) = 'ALL', 
	@deposit			char(1) = 'T'   -- 是否包含定金
as

declare
	@count			integer, 
	@lastdate		datetime, 
	@date				datetime, 
	@empname			char(10), 
	@bno				varchar(10), 
	@bno1				varchar(10), 
	@bno2				varchar(10), 
	@pccode			char(5), 
	@total_pccode	char(5), 
	@mode				char(1),				-- d=detail  s=sumamry
	@arrepo			char(1)				-- 账龄统计方式

delete arrepo where pc_id = @pc_id

-- Mode
if @option = 'summary'
	select @mode = 's', @option = 'A'
else
	select @mode = 'd'

-- Deposit
if rtrim(@deposit) is null 
	select @deposit = 'T'
if @deposit <> 'F' 
	select @deposit = 'T'

-- 是否包含定金，通过 pccode 的大小来判断
if @deposit = 'T'
	select @pccode = 'ZZZZZ'				-- 包含定金
else
	select @pccode = '9'						-- 不包含定金

-- Record
if charindex('S', @option) > 0
	begin
	insert arrepo (pc_id, catalog, accnt, descript, name)
		select @pc_id, 'T/G', a.accnt, '', b.name
		from ar_master a, guest b where a.sta = 'S' and a.class != 'A' and a.haccnt = b.no
		union select @pc_id, 'T/G', a.accnt, '', b.name
		from har_master a, guest b where a.sta = 'S' and a.class != 'A' and a.haccnt = b.no
	end

if charindex('A', @option) > 0
	begin
	insert arrepo (pc_id, catalog, accnt, descript, name)
		select @pc_id, 'AR', a.accnt, '', b.name
		from ar_master a, guest b where a.class = 'A' and a.haccnt = b.no and (@artag='ALL' or charindex(rtrim(a.artag1), @artag) > 0)
		union select @pc_id, 'AR', a.accnt, '', b.name
		from har_master a, guest b where a.class = 'A' and a.haccnt = b.no and (@artag='ALL' or charindex(rtrim(a.artag1), @artag) > 0)
	end

-- 截止日期 = @dates 的第一个日期
select @count = 0, @lastdate = convert(datetime, substring(@dates, 1, 10))
--if exists (select 1 from ar_detail a, arrepo b where b.pc_id = @pc_id and a.accnt = b.accnt and a.bdate < @lastdate and a.audit = '0')
--	begin
--	select 1, '还有' + substring(@dates, 1, 10) + '前的账目没有审核'
--	return 0
--	end
-- 去掉第一个日期（=截止日期），增加最后一个可能最远的日期，用来计算‘更远’
select @dates = ltrim(stuff(@dates, 1, 10, '')) + '1980/01/01'

-- 
select @bno = convert(char(10), @lastdate, 111)
select @bno = substring(@bno, 4, 1) + substring(@bno, 6, 2) + substring(@bno, 9, 2)
select @bno1 = 'B' + @bno, @bno2 = 'T' + @bno

create table #ar_account (
	accnt				char(10)		null, 
	number			integer		null, 
	charge			money			null, 
	charge9			money			null, 
	credit			money			null, 
	credit9			money			null, 
	pccode			char(5)		null, 
	bdate				datetime		null,
	tag				char(1)		null,				-- 账务类别:A.调整,P.前台转入,p.前台转入的费用明细,T.后台转帐,t.后台转帐的费用明细,Z.压缩账目,z.压缩账目的费用明细
	subtotal			char(1)		null				-- 当前行是否有明细费用:F.没有,T.有
)
select @arrepo = rtrim(value) from sysoption where catalog = 'ar' and item = 'ar_report'
select @total_pccode = rtrim(value) from sysoption where catalog = 'ar' and item = 'ar_account_pccode'
if @arrepo = 'N'
	begin
		-- new summary methold
		-- 1.未结帐(包括已压缩的)
		insert #ar_account select a.ar_accnt, a.ar_inumber, a.charge - a.charge9, a.charge9, a.credit - a.credit9, a.credit9, a.pccode, c.date, a.ar_tag, a.ar_subtotal
			from ar_account a, arrepo b,ar_detail c
			where b.pc_id = @pc_id and a.ar_accnt = b.accnt and c.date < @lastdate and a.ar_accnt = c.accnt and a.ar_inumber = c.number
		-- 2.截止日期之后结掉的账目
		insert #ar_account select a.ar_accnt, a.ar_inumber, c.amount, 0, 0, 0, a.pccode, d.date, a.tag, a.ar_subtotal
			from ar_account a, arrepo b, ar_apply c,ar_detail d
			where b.pc_id = @pc_id and a.ar_accnt = b.accnt and d.date < @lastdate and (a.ar_accnt = c.d_accnt and a.ar_number = c.d_inumber and c.bdate >= @lastdate)
				and a.ar_accnt = d.accnt and a.ar_inumber = d.number
		insert #ar_account select a.ar_accnt, a.ar_inumber, c.amount, 0, 0, 0, a.pccode, a.date, a.tag, a.ar_subtotal
			from har_account a, arrepo b, ar_apply c,har_detail d
			where b.pc_id = @pc_id and a.ar_accnt = b.accnt and d.date < @lastdate and (a.ar_accnt = c.d_accnt and a.ar_number = c.d_inumber and c.bdate >= @lastdate)
				and a.ar_accnt = d.accnt and a.ar_inumber = d.number
		
		insert #ar_account select a.ar_accnt, a.ar_inumber, 0, 0, c.amount, 0, a.pccode, a.date, a.tag, a.ar_subtotal
			from ar_account a, arrepo b, ar_apply c,ar_detail d
			where b.pc_id = @pc_id and a.ar_accnt = b.accnt and d.date < @lastdate and (a.ar_accnt = c.c_accnt and a.ar_number = c.c_inumber and c.bdate >= @lastdate)
				and a.ar_accnt = d.accnt and a.ar_inumber = d.number
		
		insert #ar_account select a.ar_accnt, a.ar_inumber, 0, 0, c.amount, 0, a.pccode, a.date, a.tag, a.ar_subtotal
			from har_account a, arrepo b, ar_apply c,har_detail d
			where b.pc_id = @pc_id and a.ar_accnt = b.accnt and d.date < @lastdate and (a.ar_accnt = c.c_accnt and a.ar_number = c.c_inumber and c.bdate >= @lastdate)
				and a.ar_accnt = d.accnt and a.ar_inumber = d.number
	end
else
	begin
	-- 1.未结帐(包括已压缩的)
	insert #ar_account select a.ar_accnt, a.ar_inumber, a.charge - a.charge9, a.charge9, a.credit - a.credit9, a.credit9, a.pccode, a.bdate, a.ar_tag, a.ar_subtotal
		from ar_account a, arrepo b
		where b.pc_id = @pc_id and a.ar_accnt = b.accnt and a.bdate < @lastdate
	-- 2.截止日期之后结掉的账目
	insert #ar_account select a.ar_accnt, a.ar_inumber, c.amount, 0, 0, 0, a.pccode, a.bdate, a.tag, a.ar_subtotal
		from ar_account a, arrepo b, ar_apply c
		where b.pc_id = @pc_id and a.ar_accnt = b.accnt and a.bdate < @lastdate and (a.ar_accnt = c.d_accnt and a.ar_number = c.d_inumber and c.bdate >= @lastdate)
	insert #ar_account select a.ar_accnt, a.ar_inumber, c.amount, 0, 0, 0, a.pccode, a.bdate, a.tag, a.ar_subtotal
		from har_account a, arrepo b, ar_apply c
		where b.pc_id = @pc_id and a.ar_accnt = b.accnt and a.bdate < @lastdate and (a.ar_accnt = c.d_accnt and a.ar_number = c.d_inumber and c.bdate >= @lastdate)
	insert #ar_account select a.ar_accnt, a.ar_inumber, 0, 0, c.amount, 0, a.pccode, a.bdate, a.tag, a.ar_subtotal
		from ar_account a, arrepo b, ar_apply c
		where b.pc_id = @pc_id and a.ar_accnt = b.accnt and a.bdate < @lastdate and (a.ar_accnt = c.c_accnt and a.ar_number = c.c_inumber and c.bdate >= @lastdate)
	insert #ar_account select a.ar_accnt, a.ar_inumber, 0, 0, c.amount, 0, a.pccode, a.bdate, a.tag, a.ar_subtotal
		from har_account a, arrepo b, ar_apply c
		where b.pc_id = @pc_id and a.ar_accnt = b.accnt and a.bdate < @lastdate and (a.ar_accnt = c.c_accnt and a.ar_number = c.c_inumber and c.bdate >= @lastdate)
	end
--
delete #ar_account where subtotal = 'T'
-- update #ar_account set pccode = (select min(pccode) from pccode where deptno2 = 'TOR') where pccode = ''
--
create table #ar_detail (
	accnt				char(10)		null, 
	number			integer		null, 
	charge			money			null, 
	credit			money			null
)
insert #ar_detail select accnt, number, sum(charge), sum(credit)
	from #ar_account group by accnt, number
delete #ar_account from #ar_detail a
	where #ar_account.accnt = a.accnt and #ar_account.number = a.number and a.charge = 0 and a.credit = 0
--
update #ar_account set pccode = @total_pccode where not pccode in (select pccode from pccode where pccode < @pccode)
create index index1 on #ar_account(accnt, pccode, bdate)
-- begin 
while char_length(@dates) > 0
	begin
	select @count = @count + 1, @date = convert(datetime, substring(@dates, 1, 10)), @dates = substring(@dates, 11, 255)
	if @count = 1
		update arrepo set amount1 = isnull((select sum(a.charge - a.credit) from #ar_account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and a.accnt = arrepo.accnt
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and substring(c.deptno + '     ', 1, 5) + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode < @pccode), 0)
	else if @count = 2
		update arrepo set amount2 = isnull((select sum(a.charge - a.credit) from #ar_account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id  and a.accnt = arrepo.accnt
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and substring(c.deptno + '     ', 1, 5) + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode < @pccode), 0)
	else if @count = 3
		update arrepo set amount3 = isnull((select sum(a.charge - a.credit) from #ar_account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id  and a.accnt = arrepo.accnt 
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and substring(c.deptno + '     ', 1, 5) + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode < @pccode), 0)
	else if @count = 4
		update arrepo set amount4 = isnull((select sum(a.charge - a.credit) from #ar_account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and a.accnt = arrepo.accnt 
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and substring(c.deptno + '     ', 1, 5) + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode < @pccode), 0)
	else if @count = 5
		update arrepo set amount5 = isnull((select sum(a.charge - a.credit) from #ar_account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and  a.accnt = arrepo.accnt
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and substring(c.deptno + '     ', 1, 5) + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode < @pccode), 0)
	else if @count = 6
		update arrepo set amount6 = isnull((select sum(a.charge - a.credit) from #ar_account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and  a.accnt = arrepo.accnt 
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and substring(c.deptno + '     ', 1, 5) + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode < @pccode), 0)
	else if @count = 7
		update arrepo set amount7 = isnull((select sum(a.charge - a.credit) from #ar_account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and a.accnt = arrepo.accnt 
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and substring(c.deptno + '     ', 1, 5) + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode < @pccode), 0)
	else if @count = 8
		update arrepo set amount8 = isnull((select sum(a.charge - a.credit) from #ar_account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and a.accnt = arrepo.accnt 
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and substring(c.deptno + '     ', 1, 5) + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode < @pccode), 0)
	else if @count = 9
		update arrepo set amount9 = isnull((select sum(a.charge - a.credit) from #ar_account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and a.accnt = arrepo.accnt  
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and substring(c.deptno + '     ', 1, 5) + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode < @pccode), 0)
	else
		update arrepo set amount10 = isnull((select sum(a.charge - a.credit) from #ar_account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and a.accnt = arrepo.accnt 
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and substring(c.deptno + '     ', 1, 5) + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode < @pccode), 0)

	select @lastdate = @date
	end
   
delete arrepo where amount1 = 0 and amount2 =0 and amount3 = 0 and amount4 = 0 and amount5 =0 and amount6 = 0 and
	amount7 = 0 and amount8 = 0 and amount9 = 0 and amount10 = 0 and pc_id = @pc_id
update arrepo set amount = amount1 + amount2 + amount3 + amount4 + amount5 + amount6 + amount7 + amount8 + amount9 + amount10
	where pc_id = @pc_id

-- 产生汇总记录
if @mode = 's'
	begin
	select * into #arrepo from arrepo where 1=2
	insert #arrepo select * from arrepo where pc_id = @pc_id
	delete arrepo where pc_id = @pc_id
	insert arrepo (pc_id, catalog, accnt, name, amount1, amount2, amount3, amount4, amount5, amount6, amount7, amount8, amount9, amount10, amount)
		select @pc_id, 'AR', a.code, a.descript, sum(c.amount1), sum(c.amount2), sum(c.amount3), sum(c.amount4), sum(c.amount5), 
		sum(c.amount6), sum(c.amount7), sum(c.amount8), sum(c.amount9), sum(c.amount10), sum(c.amount)	
		from basecode a, ar_master b , #arrepo c
		where a.code = b.artag1 and b.accnt = c.accnt and a.cat = 'artag1' and c.pc_id = @pc_id
		group by a.code, a.descript
	end

select 0, ''
return 0
;
