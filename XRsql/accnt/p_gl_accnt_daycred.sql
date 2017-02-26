
if exists(select * from sysobjects where name = 'p_gl_accnt_daycred')
	drop proc p_gl_accnt_daycred;

create proc p_gl_accnt_daycred	 
	@date						datetime, 
	@empno					varchar(255),
	@shift					char(1),
   @langid              integer = 0,
	@option					char(10) = 'ALL'		-- FRONT:前台,AR:AR账,ALL:所有
as
-- tag 由C01改为RMB GaoLiang 1999/07/07 
-- 应交款表生成

declare
	@class					char(1),
	@descript				char(5),
	@count					integer,
	@pccode_tor				char(5),
	@pccode_rmb				char(5),
	@empno_					char(10),
	@value1					money,
	@value2					money,
	@value3					money,
	@value4					money

create table #accnt_daycred
(
	class				char(1)	not null,				-- 款项大类
	descripts		char(16)	null,						-- 大类说明
	pccode			char(5)	not null,				-- RMB的排序码			
	descript			char(50)	null,						-- 细类说明
 	value1			money		default 0	null, 
	value2			money		default 0	null, 
	value3			money		default 0	null, 
	value4			money		default 0	null
)
--
if rtrim(@empno) is null
	select @empno = '%'
if rtrim(@shift) is null or @shift='0'  or @shift='9' 
	select @shift = '%'
select * into #account from account where 1 = 2
if @option in ('FRONT', 'ALL')
	insert #account select * from account where bdate = @date and empno like @empno and shift like @shift 
		union select * from haccount where bdate = @date and empno like @empno and shift like @shift 
if @option in ('AR', 'ALL')
	insert #account (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
	select ar_accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno
		from ar_account where bdate = @date and empno like @empno and ar_tag = 'A' and shift like @shift 
	union select ar_accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno
		from har_account where bdate = @date and empno like @empno and ar_tag = 'A' and shift like @shift 
--
if @langid = 0 
	insert #accnt_daycred(class, descripts, pccode, descript)
		select b.code, b.descript, a.pccode, '    ' + a.descript
		from pccode a, basecode b where a.argcode > '9' and a.deptno = b.code and b.cat = 'paymth_deptno'
else
	insert #accnt_daycred(class, descripts, pccode, descript)
		select b.code, b.descript1, a.pccode, '    ' + a.descript1
		from pccode a, basecode b where a.argcode > '9' and a.deptno = b.code and b.cat = 'paymth_deptno'
--
select @count = 1
declare c_accnt_daycred_class cursor for
	select code from basecode where cat = 'paymth_deptno' order by code
open c_accnt_daycred_class
fetch c_accnt_daycred_class into @class
while @@sqlstatus = 0
	begin
   if @langid = 0
   	exec p_GetChinaNumber @count, @descript out, 'T'
   else
	    exec p_GetEnglishNumber @count, @descript out, 'T'
	update #accnt_daycred set descripts = rtrim(@descript) + '. ' + descripts where class = @class
	select @count = @count + 1
	fetch c_accnt_daycred_class into @class
	end
close c_accnt_daycred_class
deallocate cursor c_accnt_daycred_class

-- 计算其他币种
update #accnt_daycred set value1 = value1 + isnull((select sum(credit) from #account 
	where pccode = #accnt_daycred.pccode and shift = '1'), 0)
update #accnt_daycred set value2 = value2 + isnull((select sum(credit) from #account 
	where pccode = #accnt_daycred.pccode and shift = '2'), 0)
update #accnt_daycred set value3 = value3 + isnull((select sum(credit) from #account 
	where pccode = #accnt_daycred.pccode and shift = '3'), 0)
update #accnt_daycred set value4 = value4 + isnull((select sum(credit) from #account 
	where pccode = #accnt_daycred.pccode and shift = '4'), 0)
-- 计算转应收账
select @pccode_tor = pccode from pccode where deptno2 = 'TOR'
update #accnt_daycred set value1 = value1 + isnull((select sum(charge) from #account 
	where accnt like 'A%' and argcode < '9' and shift = '1'), 0) where pccode = @pccode_tor
update #accnt_daycred set value2 = value2 + isnull((select sum(charge) from #account 
	where accnt like 'A%' and argcode < '9' and shift = '2'), 0) where pccode = @pccode_tor
update #accnt_daycred set value3 = value3 + isnull((select sum(charge) from #account 
	where accnt like 'A%' and argcode < '9' and shift = '3'), 0) where pccode = @pccode_tor
update #accnt_daycred set value4 = value4 + isnull((select sum(charge) from #account 
	where accnt like 'A%' and argcode < '9' and shift = '4'), 0) where pccode = @pccode_tor
-- 如果pccode中的现金分开，这一段就不用了
select @pccode_rmb = value from sysoption where catalog = 'account' and item = 'p_gl_accnt_daycred'
if not rtrim(@pccode_rmb) is null
 begin
   if @langid=0 
		begin
		-- 拆分 RMB
			update #accnt_daycred set descript = '    定金' where pccode = @pccode_rmb
			insert #accnt_daycred select class, descripts, pccode,'    结账款' , 0, 0, 0, 0 from #accnt_daycred where pccode = @pccode_rmb
			-- RMB
			select @value1 = sum(credit) from #account where argcode = '99' and pccode = @pccode_rmb and shift = '1'
			select @value2 = sum(credit) from #account where argcode = '99' and pccode = @pccode_rmb and shift = '2'
			select @value3 = sum(credit) from #account where argcode = '99' and pccode = @pccode_rmb and shift = '3'
			select @value4 = sum(credit) from #account where argcode = '99' and pccode = @pccode_rmb and shift = '4'
			update #accnt_daycred set value1 = value1 - isnull(@value1, 0), value2 = value2 - isnull(@value2, 0),
				value3 = value3 - isnull(@value3, 0), value4 = value4 - isnull(@value4, 0)
				where pccode = @pccode_rmb and descript = '    定金'
			update #accnt_daycred set value1 = isnull(@value1, 0), value2 = isnull(@value2, 0),
				value3 = isnull(@value3, 0), value4 = isnull(@value4, 0)
				where pccode = @pccode_rmb and descript = '    结账款'
		end
   else
		begin
		-- 拆分 RMB
			update #accnt_daycred set descript = '    Deposit' where pccode = @pccode_rmb
			insert #accnt_daycred select class, descripts, pccode,'    Payment' , 0, 0, 0, 0 from #accnt_daycred where pccode = @pccode_rmb
			-- RMB
			select @value1 = sum(credit) from #account where argcode = '99' and pccode = @pccode_rmb and shift = '1'
			select @value2 = sum(credit) from #account where argcode = '99' and pccode = @pccode_rmb and shift = '2'
			select @value3 = sum(credit) from #account where argcode = '99' and pccode = @pccode_rmb and shift = '3'
			select @value4 = sum(credit) from #account where argcode = '99' and pccode = @pccode_rmb and shift = '4'
			update #accnt_daycred set value1 = value1 - isnull(@value1, 0), value2 = value2 - isnull(@value2, 0),
				value3 = value3 - isnull(@value3, 0), value4 = value4 - isnull(@value4, 0)
				where pccode = @pccode_rmb and descript = '    Deposit'
			update #accnt_daycred set value1 = isnull(@value1, 0), value2 = isnull(@value2, 0),
				value3 = isnull(@value3, 0), value4 = isnull(@value4, 0)
				where pccode = @pccode_rmb and descript = '    Payment'
		end
 end 

if @empno = '%'
	begin
--	if @langid =0 
--		select @empno ='所有收银员'
--	else
--		select @empno ='All Cashier'
-- 显示所有前台收银员的用户名
	select @empno = '' 
	declare c_accnt_empno cursor for
		select distinct empno from #account
	open c_accnt_empno
	fetch c_accnt_empno into @empno_
	while @@sqlstatus = 0
		begin
		 select @empno = @empno + rtrim(@empno_) + ' ;'
		 fetch c_accnt_empno into @empno_
		end
	close c_accnt_empno
	deallocate cursor c_accnt_empno
	end 

delete #accnt_daycred where value1=0 and value2=0 and value3=0 and value4=0 -- 2009.8 simon 
select @empno, * from #accnt_daycred order by class, pccode

return 0
;

