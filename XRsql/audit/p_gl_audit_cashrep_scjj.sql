///* 四川锦江总出纳(总出款员收入日报表) */
//if exists (select * from sysobjects where name ='cashrep_scjj' and type ='U')
//	drop table cashrep_scjj;
//
//create table cashrep_scjj
//(
//	date				datetime	not null,							/*  */
//	deptno			char(2)	default '' not null,				/* 部门码 */
//	deptname			char(16)	default '' not null,				/* 收入分类描述 */
//	day1				money		default 0 not null,				/* 现金金额 */
//	day2				money		default 0 not null,				/* 支票金额 */
//	day3				money		default 0 not null,				/* 信用卡金额 */
//	month1			money		default 0 not null,				/* 现金金额 */
//	month2			money		default 0 not null,				/* 支票金额 */
//	month3			money		default 0 not null				/* 信用卡金额 */
//)
//exec sp_primarykey cashrep_scjj, deptno
//create unique index index1 on cashrep_scjj(deptno)
//;
//
//if exists (select * from sysobjects where name ='ycashrep_scjj' and type ='U')
//	drop table ycashrep_scjj;
//
//create table ycashrep_scjj
//(
//	date				datetime	not null,							/*  */
//	deptno			char(2)	default '' not null,				/* 部门码 */
//	deptname			char(16)	default '' not null,				/* 收入分类描述 */
//	day1				money		default 0 not null,				/* 现金金额 */
//	day2				money		default 0 not null,				/* 支票金额 */
//	day3				money		default 0 not null,				/* 信用卡金额 */
//	month1			money		default 0 not null,				/* 现金金额 */
//	month2			money		default 0 not null,				/* 支票金额 */
//	month3			money		default 0 not null				/* 信用卡金额 */
//)
//exec sp_primarykey ycashrep_scjj, date, deptno
//create unique index index1 on ycashrep_scjj(date, deptno)
//;
//

if exists (select * from sysobjects where name = 'p_gl_audit_cashrep_scjj' and type = 'P')
	drop proc p_gl_audit_cashrep_scjj;
create proc p_gl_audit_cashrep_scjj
	@lset				varchar(12)  
as

declare 
	@duringaudit	char(1), 
	@isfstday		char(1), 
	@isyfstday		char(1), 
	@bdate			datetime, 
	@bfdate			datetime, 
	@codecls			char(1), 
	@count			integer, 
	@deptnos			char(12), 
	@cdeptno			char(2), 
	@deptno			char(2), 
	@amount			money

select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
if exists ( select * from cashrep_scjj where date = @bdate )
	update cashrep_scjj set month1 = month1 - day1, month2 = month2 - day2, month3 = month3 - day3
update cashrep_scjj set day1 = 0, day2 = 0, day3 = 0, date = @bfdate
select @count = 0, @deptnos = '  #10#15#'
while @count < 3
	begin
	select @cdeptno = substring(@deptnos, @count * 3 + 1, 2)
	if @count = 0
		// 前台收银
		declare c_cursor cursor for
			select b.deptno, c.deptno, sum(a.charge)
			from  account_detail a, pccode b, pccode c
			where a.modu_id = '02' and a.paycode = b.pccode and charindex(b.deptno, @lset) > 0 and a.pccode = c.pccode
			group by b.deptno, c.deptno
	else if @count = 1
		// 餐饮收银
		declare c_cursor cursor for 
			select b.deptno, @cdeptno, sum(a.creditd)
			from  deptdai a, pccode b
			where a.daymark = 'D' and a.shift = '9' and a.empno = '{{{' and a.paytail = ''
			and substring(a.pccode, 2, 2) = substring(b.pccode, 2, 2) and charindex(b.deptno, @lset) > 0 
			group by b.deptno
	else if @count = 2
		// 商务中心
		declare c_cursor cursor for 
			select b.deptno, @cdeptno, sum(a.creditd)
			from  bosdai a, pccode b
			where a.daymark = 'D' and a.shift = '9' and a.empno = '{{{' and a.paytail = ''
			and substring(a.paycode, 2, 2) = substring(b.pccode, 2, 2)	and charindex(b.deptno, @lset) > 0 
			group by b.deptno
	open c_cursor
	fetch c_cursor into @codecls, @deptno, @amount
	while @@sqlstatus = 0 
		begin
		if not exists (select 1 from cashrep_scjj where deptno = @deptno)
			insert cashrep_scjj (date, deptno) values (@bfdate, @deptno)
		if @codecls = 'A'
			update cashrep_scjj set day1 = day1 + @amount where deptno = @deptno
		else if @codecls = 'B'
			update cashrep_scjj set day2 = day2 + @amount where deptno = @deptno
		else
			update cashrep_scjj set day3 = day3 + @amount where deptno = @deptno
		fetch c_cursor into @codecls, @deptno, @amount
		end 
	close c_cursor
	deallocate cursor c_cursor
	select @count = @count + 1
	end 
//
if not exists (select 1 from cashrep_scjj where deptno = '06')
	insert cashrep_scjj (date, deptno, deptname) values (@bfdate, '06', '预付 - 冲预付')
create table #credit
(
	empno			char(10)	null, 
	pccode		char(5)	default '' not null, 
	argcode		char(3)	default '' not null, 
	tag			char(3)	null, 
	charge		money		default 0 not null,			/* 借方 */
	credit		money		default 0 not null,			/* 贷方 */
	crradjt		char(2)	null, 
	tofrom		char(2)	null, 
	billno		char(10)	null
)
insert #credit select empno, pccode, argcode, tag, charge, credit, crradjt, tofrom, billno
	from gltemp where pccode > '9'
delete #credit
	where not (crradjt in ('', 'AD', 'SP', 'CT') or (crradjt like 'L%' and tofrom = ''))
update #credit set billno = '' where billno like 'T%'
update #credit set argcode = '98' where argcode = '99' and billno = ''
update cashrep_scjj set day1 = day1 + isnull((select sum(a.credit) from #credit a, pccode b 
	where a.argcode in ('98') and a.credit > 0 and a.pccode = b.pccode and b.deptno = 'A'), 0)
	where deptno = '06'
update cashrep_scjj set day2 = day2 + isnull((select sum(a.credit) from #credit a, pccode b 
	where a.argcode in ('98') and a.credit > 0 and a.pccode = b.pccode and b.deptno = 'B'), 0)
	where deptno = '06'
update cashrep_scjj set day3 = day3 + isnull((select sum(a.credit) from #credit a, pccode b 
	where a.argcode in ('98') and a.credit > 0 and a.pccode = b.pccode and b.deptno in ('C', 'D')), 0)
	where deptno = '06'
//
update cashrep_scjj set day1 = day1 - isnull((select sum(credit) from outtemp a, pccode b 
	where a.argcode in ('98') and a.billno != '' and a.pccode = b.pccode and b.deptno = 'A'), 0) + 
	isnull((select sum(credit) from #credit a, pccode b 
	where a.argcode in ('98') and a.credit < 0 and a.pccode = b.pccode and b.deptno = 'A'), 0)
 	where deptno = '06'
update cashrep_scjj set day2 = day2 - isnull((select sum(credit) from #credit a, pccode b 
	where a.argcode in ('98') and a.billno != '' and a.pccode = b.pccode and b.deptno = 'B'), 0) + 
	isnull((select sum(credit) from #credit a, pccode b 
	where a.argcode in ('98') and a.credit < 0 and a.billno = '' and a.pccode = b.pccode and b.deptno = 'B'), 0)
 	where deptno = '06'
update cashrep_scjj set day3 = day3 - isnull((select sum(credit) from #credit a, pccode b 
	where a.argcode in ('98') and a.billno != '' and a.pccode = b.pccode and b.deptno in ('C', 'D')), 0) + 
	isnull((select sum(credit) from #credit a, pccode b 
	where a.argcode in ('98') and a.credit < 0 and a.billno = '' and a.pccode = b.pccode and b.deptno in ('C', 'D')), 0)
 	where deptno = '06'
//
update cashrep_scjj set deptname = a.descript from basecode a
	where a.cat = 'chgcod_deptno' and cashrep_scjj.deptno = a.code
exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday  = 'T'
	update cashrep_scjj set month1 = 0, month2 = 0, month3 = 0
update cashrep_scjj set month1 = month1 + day1, month2 = month2 + day2, month3 = month3 + day3, date = @bdate 
delete ycashrep_scjj where date = @bdate 
insert ycashrep_scjj select * from cashrep_scjj
return 0
;
