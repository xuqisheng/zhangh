if exists (select * from sysobjects where name  = 'p_gl_audit_sjourrep_scjj1' and type = 'P')
	drop proc p_gl_audit_sjourrep_scjj1;

create proc p_gl_audit_sjourrep_scjj1
as
declare 
	@duringaudit	char(1), 
	@isfstday		char(1), 
	@isyfstday		char(1), 
	@bdate			datetime, 
	@bfdate			datetime, 
	@modu_ids		varchar(255), 
	@retotal			char(1), 
	@ds_str			varchar(255), 
	@en_str			varchar(255),
   //
	@ment				money, 
	@mdsc				money, 
	@thisent			money, 
	@thisdsc			money, 
	@sument			money, 
	@sumdsc			money, 
	@billno			char(10), 
	@mbillno			char(10), 
	@mcredit			money, 
	@accnt			char(10), 
	@roomno			char(5),
	@pccode			char(5), 
	@tag				char(3), 
	@paymth			char(5), 
	@charge			money, 
	@credit			money, 
	@opccode			char(5), 
	@number			integer, 
	@sqlmark			integer

//
create table #gltemp
(
	accnt			char(7)		not null,
	modu_id		char(2)		not null,
	pccode		char(5)		not null,
	charge		money			not null,
	charge1		money			not null,
	charge2		money			not null,
	charge3		money			not null,
	charge4		money			not null,
	charge5		money			not null,
	crradjt		char(2)		not null,
	tofrom		char(2)		not null,
	roomno		char(5)		null
)
insert #gltemp select accnt, modu_id, pccode, charge, charge1, charge2, charge3, charge4, charge5, crradjt, tofrom, roomno from gltemp
update #gltemp set pccode = '400' where pccode < '02' and roomno like '4%'
//
create table #outtemp
(
	accnt			char(10)		not null,
	number		integer		not null,
	modu_id		char(2)		not null,
	pccode		char(5)		not null,
	charge		money			not null,
	credit		money			not null,
	tag			char(3)		null,
	crradjt		char(2)		not null,
	tofrom		char(2)		not null,
	roomno		char(5)		null,
	billno		char(10)		not null
)
//
insert #outtemp select accnt, number, modu_id, pccode, charge, credit, tag, crradjt, tofrom, roomno, billno from outtemp
update #outtemp set pccode = '400' where pccode < '02' and roomno like '4%'
/* ---------Initialization--------------- */
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate), @retotal = 'F'
delete sjourrep
insert sjourrep select * from ysjourrep where date = @bfdate
select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#03#05#')
select @ds_str = isnull((select value from sysoption where catalog = 'audit' and item = 'ds_str'), '')
select @en_str = isnull((select value from sysoption where catalog = 'audit' and item = 'en_str'), '')
if exists ( select 1 from sjourrep where date = @bdate )
	begin
	select @retotal = 'T'
	update sjourrep set balance_t = balance_l,month0 = month0 - day0, month1 = month1 - day1, month2 = month2 - day2, 
		month3 = month3 - day3, month8 = month8 - day8, month9 = month9 - day9
	end
update sjourrep set day0 = 0, day1 = 0, day2 = 0, day3 = 0, day8 = 0, day9 = 0, date = @bfdate
/* 一. 加入空项 */
insert sjourrep (date, deptno, descript, tag)
	select @bfdate, code, descript, grp from basecode
	where cat = 'chgcod_deptno6' and not code in (select deptno from sjourrep a where pccode = '')
insert sjourrep (date, deptno, descript, pccode, tag)
	select @bfdate, a.code, '    ' + b.descript, b.pccode, a.grp from basecode a, pccode b
	where cat = 'chgcod_deptno6' and b.deptno6 = a.code and not b.pccode in (select pccode from sjourrep c)
///* 二. 总台 */
//update sjourrep set day0 = day0 + 
//	isnull((select sum(a.charge) from #gltemp a where charindex(a.modu_id, @modu_ids) > 0 and a.pccode = sjourrep.pccode and a.servcode != 'H'), 0)
//// 后台和宾馆帐输入的(房费和餐费)优惠统计到二次折扣
//update sjourrep set day2 = day2 - 
//	isnull((select sum(a.charge) from #gltemp a where charindex(a.modu_id, @modu_ids) > 0 
//	and a.pccode < '40' and a.pccode = sjourrep.pccode and a.servcode = 'H' and (accnt like 'A%' or substring(accnt, 2, 2) = '95')
//	and (a.crradjt in ('', 'AD', 'SP', 'CT') or (substring(a.crradjt,1,1) = 'L' and a.tofrom = ''))), 0)
//// 剩下的优惠统计到减免打折
//update sjourrep set day1 = day1 - day2 - 
//	isnull((select sum(a.charge) from #gltemp a where charindex(a.modu_id, @modu_ids) > 0 and a.pccode = sjourrep.pccode and a.servcode = 'H'), 0)
/* 二. 总台 */
// 发生数
update sjourrep set day0 = day0 + isnull((select sum(a.charge1 + a.charge3 + a.charge4 + a.charge5) from #gltemp a, pccode b
	where charindex(a.modu_id, @modu_ids) > 0 and a.pccode = sjourrep.pccode and a.pccode = b.pccode and b.deptno8 != 'RB'), 0)
// 减免打折
update sjourrep set day1 = day1 + isnull((select sum(a.charge2) from #gltemp a, pccode b
	where charindex(a.modu_id, @modu_ids) > 0 and a.pccode = sjourrep.pccode and a.pccode = b.pccode and b.deptno8 != 'RB'), 0)
// 二次折扣
update sjourrep set day2 = day2 - isnull((select sum(a.charge) from #gltemp a, pccode b
	where charindex(a.modu_id, @modu_ids) > 0 and a.pccode = sjourrep.pccode and a.pccode = b.pccode and b.deptno8 = 'RB'), 0)
//
declare out_cursor cursor for
	select accnt, number, pccode, charge, tag, roomno from #outtemp where billno = @mbillno and pccode < '9' order by accnt, number
declare outtemp_cursor cursor for 
	select a.billno, a.accnt, a.number, b.deptno2, a.credit, a.roomno
	from #outtemp a, pccode b where a.pccode > '9' and a.pccode = b.pccode order by a.billno, a.accnt, a.number
open outtemp_cursor
fetch outtemp_cursor into @billno, @accnt, @number, @paymth, @credit, @roomno
select @sqlmark = @@sqlstatus
while @sqlmark = 0
	begin
	select @mbillno = @billno, @mdsc = 0, @ment = 0, @mcredit = 0
	while @sqlmark = 0 and @mbillno = @billno
		begin
		if charindex(@paymth, @en_str) > 0 
			select @ment = @ment + round(@credit, 2)
		else if charindex(@paymth, @ds_str) > 0 
			select @mdsc = @mdsc + round(@credit, 2)
		select @mcredit = @mcredit + round(@credit, 2)
		fetch outtemp_cursor into @billno, @accnt, @number, @paymth, @credit, @roomno
		select @sqlmark = @@sqlstatus
		end
	if round(@ment, 2) = 0 and round(@mdsc, 2) = 0
		continue
	if round(@mcredit, 2) = 0
		begin
		update sjourrep set day3 = day3 + (@ment + @mdsc) where pccode = '004'
		continue
		end
	//
	select @sumdsc = 0, @sument = 0, @opccode = null
	open out_cursor
	fetch out_cursor into @accnt, @number, @pccode, @charge, @tag, @roomno
	while @@sqlstatus = 0
		begin
		if @opccode is null and @charge <> 0 
			select @opccode = @pccode
		select @thisdsc = round(@charge * @mdsc / @mcredit * 1.0 , 2)
		select @thisent = round(@charge * @ment / @mcredit * 1.0 , 2)
		update sjourrep set day3 = day3 + @thisent + @thisdsc where pccode = @pccode
		select @sument = @sument + @thisent, @sumdsc = @sumdsc + @thisdsc
		fetch out_cursor into @accnt, @number, @pccode, @charge, @tag, @roomno
		end
	close out_cursor 
	//
	if round(@sument, 2) <> round(@ment, 2)
		update sjourrep set day3 = day3 + (@ment - @sument) where pccode = @opccode
	if round(@sumdsc, 2) <> round(@mdsc, 2)
		update sjourrep set day3 = day3 + (@mdsc - @sumdsc) where pccode = @opccode
	end
//
close outtemp_cursor
deallocate cursor outtemp_cursor
deallocate cursor out_cursor

   
update sjourrep set day8 = day8 + 
	isnull((select sum(a.charge) from #outtemp a where a.pccode = sjourrep.pccode and a.accnt like 'A%'), 0)
update sjourrep set day9 = day9 + 
	isnull((select sum(a.charge) from #outtemp a where a.pccode = sjourrep.pccode),0)
/* 三. 综合收银 */
update sjourrep set day1 = day1 + 
	isnull((select sum(a.creditd) from deptdai a where a.pccode = sjourrep.pccode and a.shift='9' and empno = '{{{' and paycode > 'C99' and paycode < 'D99'), 0)
update sjourrep set day9 = day9 + 
	isnull((select sum(a.creditd) from deptdai a where a.pccode = sjourrep.pccode and a.shift='9' and empno = '{{{' and paycode < '970'), 0)
update sjourrep set day0 = day0 + 
	isnull((select sum(a.creditd) from deptdai a where a.pccode = sjourrep.pccode and a.shift='9' and empno = '{{{' and paycode > 'C99' and paycode < 'D99'), 0) +
	isnull((select sum(a.creditd) from deptdai a where a.pccode = sjourrep.pccode and a.shift='9' and empno = '{{{' and paycode = 'C99'), 0)
/* 四. BOS */
update sjourrep set day0 = day0 + 
	isnull((select sum(a.fee_ttl) from bosjie a where a.code = sjourrep.pccode and a.shift='9' and empno = '{{{'), 0)
update sjourrep set day1 = day1 + 
	isnull((select sum(a.fee_dsc + a.fee_ent) from bosjie a where a.code = sjourrep.pccode and a.shift='9' and empno = '{{{'), 0)
update sjourrep set day9 = day9 + 
	isnull((select sum(a.fee_ttl - a.fee_dsc - a.fee_ent) from bosjie a where a.code = sjourrep.pccode and a.shift='9' and empno = '{{{'), 0) - 
	isnull((select sum(b.charge) from #gltemp b where charindex(b.modu_id, '06#03#66#') > 0  and b.pccode = sjourrep.pccode), 0)
/* 六. 汇总 */
if not exists (select 1 from sjourrep where deptno = '{{')
	begin
	insert sjourrep (date, deptno, descript, pccode, tag) 
		select distinct @bfdate, '{{', '合计', '', tag from sjourrep
	insert sjourrep (date, deptno, descript, pccode, tag) select @bfdate, '{{', '总计', '', '{'
	end
update sjourrep set balance_l = isnull((select sum(a.balance_l) from sjourrep a where a.deptno = sjourrep.deptno and a.pccode != ''), 0),
	day0 = isnull((select sum(a.day0) from sjourrep a where a.deptno = sjourrep.deptno and a.pccode != ''), 0),
	day1 = isnull((select sum(a.day1) from sjourrep a where a.deptno= sjourrep.deptno and a.pccode != ''), 0),
	day2 = isnull((select sum(a.day2) from sjourrep a where a.deptno = sjourrep.deptno and a.pccode != ''), 0),
	day3 = isnull((select sum(a.day3) from sjourrep a where a.deptno = sjourrep.deptno and a.pccode != ''), 0),
	day8 = isnull((select sum(a.day8) from sjourrep a where a.deptno = sjourrep.deptno and a.pccode != ''), 0),
	day9 = isnull((select sum(a.day9) from sjourrep a where a.deptno = sjourrep.deptno and a.pccode != ''), 0),
	balance_t = isnull((select sum(a.balance_t) from sjourrep a where a.deptno = sjourrep.deptno and a.pccode != ''), 0)
	where pccode = ''
update sjourrep set balance_l = isnull((select sum(a.balance_l) from sjourrep a where a.tag = sjourrep.tag and a.pccode != ''), 0),
	day0 = isnull((select sum(a.day0) from sjourrep a where a.tag = sjourrep.tag and a.pccode != ''), 0),
	day1 = isnull((select sum(a.day1) from sjourrep a where a.tag = sjourrep.tag and a.pccode != ''), 0),
	day2 = isnull((select sum(a.day2) from sjourrep a where a.tag = sjourrep.tag and a.pccode != ''), 0),
	day3 = isnull((select sum(a.day3) from sjourrep a where a.tag = sjourrep.tag and a.pccode != ''), 0),
	day8 = isnull((select sum(a.day8) from sjourrep a where a.tag = sjourrep.tag and a.pccode != ''), 0),
	day9 = isnull((select sum(a.day9) from sjourrep a where a.tag = sjourrep.tag and a.pccode != ''), 0),
	balance_t = isnull((select sum(a.balance_t) from sjourrep a where a.tag = sjourrep.tag and a.pccode != ''), 0)
	where deptno = '{{' and tag != '{'
update sjourrep set balance_l = isnull((select sum(a.balance_l) from sjourrep a where a.pccode != ''), 0),
	day0 = isnull((select sum(a.day0) from sjourrep a where a.pccode != ''), 0),
	day1 = isnull((select sum(a.day1) from sjourrep a where a.pccode != ''), 0),
	day2 = isnull((select sum(a.day2) from sjourrep a where a.pccode != ''), 0),
	day3 = isnull((select sum(a.day3) from sjourrep a where a.pccode != ''), 0),
	day8 = isnull((select sum(a.day8) from sjourrep a where a.pccode != ''), 0),
	day9 = isnull((select sum(a.day9) from sjourrep a where a.pccode != ''), 0),
	balance_t = isnull((select sum(a.balance_t) from sjourrep a where a.pccode != ''), 0)
	where deptno = '{{' and tag = '{'
if not exists (select 1 from sjourrep where tag ='1' and  deptno = '09')            
	begin
	insert sjourrep (date, deptno, descript, pccode, tag) 
		select distinct @bfdate, '09', '客房小计', '', '1' 
	end
update sjourrep set balance_l = isnull((select sum(a.balance_l) from sjourrep a where a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and  a.pccode = ''), 0),
	day0 = isnull((select sum(a.day0) from sjourrep a where  a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and a.pccode != ''), 0),
	day1 = isnull((select sum(a.day1) from sjourrep a where  a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and a.pccode != ''), 0),
	day2 = isnull((select sum(a.day2) from sjourrep a where  a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and a.pccode != ''), 0),
	day3 = isnull((select sum(a.day3) from sjourrep a where  a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and a.pccode != ''), 0),
	day8 = isnull((select sum(a.day8) from sjourrep a where  a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and a.pccode != ''), 0),
	day9 = isnull((select sum(a.day9) from sjourrep a where  a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and a.pccode != ''), 0),
	month0 = isnull((select sum(a.month0) from sjourrep a where  a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and a.pccode != ''), 0),
	month1 = isnull((select sum(a.month1) from sjourrep a where  a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and a.pccode != ''), 0),
	month2 = isnull((select sum(a.month2) from sjourrep a where  a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and a.pccode != ''), 0),
	month3 = isnull((select sum(a.month3) from sjourrep a where  a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and a.pccode != ''), 0),
	month8 = isnull((select sum(a.month8) from sjourrep a where  a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and a.pccode !=''), 0),
	month9 = isnull((select sum(a.month9) from sjourrep a where  a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and a.pccode != ''), 0),
	balance_t = isnull((select sum(a.balance_t) from sjourrep a where a.tag ='1' and charindex(a.deptno, '05 #07 #35 ') >0 and  a.pccode != ''), 0)
	where deptno = '09' and tag = '1' and pccode =''
//   
exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @retotal = 'F'
	update sjourrep set balance_l = balance_t
if @isfstday = 'T'
	update sjourrep set month0 = 0, month1 = 0, month2 = 0, month3 = 0, month9 = 0
update sjourrep set month0 = month0 + day0, month1 = month1 + day1, month2 = month2 + day2, month3 = month3 + day3,
	month8 = month8 + day8, month9 = month9 + day9, balance_t = balance_l + day0 - day1 - day2 - day9, date = @bdate
delete ysjourrep where date = @bdate
insert ysjourrep select * from sjourrep
return 0;
;
