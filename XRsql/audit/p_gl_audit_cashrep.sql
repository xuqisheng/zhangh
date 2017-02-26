/* 现金收入表统计过程 */
if exists (select * from sysobjects where name = 'p_gl_audit_cashrep' and type = 'P')
	drop proc p_gl_audit_cashrep;
create proc p_gl_audit_cashrep
	@lset				varchar(12)
as

declare
	@duringaudit	char(1),
	@bdate			datetime,
	@class			char(2),
	@_class			char(2),
	@pccode		char(10),
	@shift			char(1),
	@empno			char(10),
	@credit			money,
	@cclass			char(1),
	@ccode			char(3),
	@cset				varchar(30)

select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @cset = '01#02#03#04#'
delete cashrep
while datalength(@cset) > 0
	begin
	select @class = substring(@cset, 1, 2)
	select @cset = stuff(@cset, 1, 3, null)
	if @class = '01'
		declare c_cursor cursor for
--      select '01', '前厅', a.shift, a.empno, a.credit, b.deptno, a.pccode
        select '01', '', a.shift, a.empno, a.credit, b.deptno, b.deptno1
			from  gltemp a, pccode b
			where not a.accnt like 'A%' and a.pccode > '9' and a.pccode = b.pccode and charindex(b.deptno, @lset) > 0
--			union all select '01', '前厅', a.shift, a.empno, a.charge, b.deptno, b.pccode
			union all select '01', '', a.shift, a.empno, a.charge, b.deptno, b.deptno1
			from  gltemp a, pccode b
			where a.accnt like 'A%' and a.pccode < '9'
			and b.pccode = '988' and charindex(rtrim(b.deptno), @lset) > 0
	else if @class = '02'
--		declare c_cursor cursor for select '02', '', a.shift, a.empno, a.credit, b.deptno, a.pccode
		declare c_cursor cursor for select '02', '', a.shift, a.empno, a.credit, b.deptno, b.deptno1
			from  gltemp a, pccode b
			where a.accnt like 'A%' and a.pccode > '9' and a.pccode = b.pccode and charindex(rtrim(b.deptno), @lset) > 0
	else if  @class = '03'
--		declare c_cursor cursor for select '03', c.descript, a.shift, a.empno, a.amount, b.deptno, a.code
		declare c_cursor cursor for select '03', a.modu, a.shift, a.empno, a.amount, b.deptno, b.deptno1
			from  bos_haccount a, pccode b, basecode c
			where a.bdate = @bdate and a.code = b.pccode and charindex(rtrim(b.deptno), @lset) > 0
			and a.modu = c.code and c.cat = 'moduno'
	else if  @class = '04'
		declare c_cursor cursor for select d.deptno, d.pccode, a.shift, a.empno, a.creditd, b.deptno, b.deptno1
			from  deptdai a, pccode b, pos_pccode c, pccode d
			where a.daymark = 'D' and a.shift <> '9' and a.empno <> '{{{' and a.paytail = ''
			and substring(a.paycode, 2, 2) = substring(b.deptno1, 2, 2) and charindex(rtrim(b.deptno), @lset) > 0 and a.pccode = c.pccode and substring(a.paycode, 1, 1) <> 'B'
			and c.chgcod = d.pccode
	open c_cursor
	fetch c_cursor into @_class, @pccode, @shift, @empno, @credit, @cclass, @ccode
	while @@sqlstatus = 0
		begin
		--if @ccode = '902'
		--	select @ccode = '901'
		--if @ccode = '904'
		--	select @ccode = '903'
		--else if @ccode like 'B%'
		--	select @ccode = '9' + substring(@ccode, 2, 2), @credit = 0
		--else if @ccode like 'E%'
		--	select @ccode = '9' + substring(@ccode, 2, 2)

		if not exists (select 1 from cashrep where class = @_class and pccode =@pccode and shift = @shift and empno = @empno and cclass = @cclass and ccode = @ccode)
			insert cashrep (class, pccode, shift, empno, cclass, ccode)
			values (@_class, @pccode, @shift, @empno, @cclass, @ccode)
		update cashrep set credit = credit + @credit
			where class = @_class and pccode =@pccode and shift = @shift and empno = @empno and cclass = @cclass and ccode = @ccode
		fetch c_cursor into @_class, @pccode, @shift, @empno, @credit, @cclass, @ccode
		end
	close c_cursor
	deallocate cursor c_cursor
	end
-- update cashrep set ename = b.name from sys_empno b where cashrep.empno = b.empno
-- update cashrep set sname = b.descript from basecode b where b.cat= 'shift' and cashrep.shift = b.code







update cashrep set date = @bdate
delete ycashrep where date = @bdate
insert ycashrep select * from cashrep
return 0
;

