if object_id("p_gl_audit_brepo") is not null
  drop proc p_gl_audit_brepo ;
create proc p_gl_audit_brepo
	@date				datetime,
	@empno			char(16),
	@shift			char(1),
   @langid			integer = 0,
	@option			char(10) = 'ALL'		-- FRONT:前台,AR:AR账,ALL:所有
as
-- 收款员输账报表   

create table #daycred
(
	pccode		char(5)	default '' not null,
	descript		char(24)	default '' not null,
	amount1		money		default 0 not null,
	amount2		money		default 0 not null,
	amount3		money		default 0 not null,
	amount4		money		default 0 not null,
	amount5		money		default 0 not null,
	amount6		money		default 0 not null,
	amount7		money		default 0 not null,
	amount8		money		default 0 not null,
	amount9		money		default 0 not null,
)

if rtrim(@empno) is null
	select @empno = '%'
if rtrim(@shift) is null
	select @shift = '%'

-- 原来只考虑前台 
--select * into #account from account where bdate = @date and empno like @empno and shift like @shift
--	union select * from haccount where bdate = @date and empno like @empno and shift like @shift
--update #account set argcode = '98' where argcode = '99' and billno = ''

-- 现在兼顾后台 ar 
select * into #account from account where 1 = 2
if @option in ('FRONT', 'ALL')
	insert #account select * from account where bdate = @date and empno like @empno and shift like @shift 
		union select * from haccount where bdate = @date and empno like @empno and shift like @shift
update #account set argcode = '98' where argcode = '99' and billno = ''
if @option in ('AR', 'ALL')
	insert #account (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno)
	select ar_accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno
	from ar_account where bdate = @date and empno like @empno and shift like @shift and ar_tag = 'A'
	union select ar_accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, quantity, charge, charge1, charge2,
		charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno, crradjt, waiter, tag, reason,
		tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno
	from har_account where bdate = @date and empno like @empno and shift like @shift and ar_tag = 'A'

--
delete #account where billno like '[C,T]%'
insert #daycred (pccode, descript) select distinct a.pccode, b.descript
	from #account a, pccode b where a.pccode = b.pccode

update #daycred set amount9 = isnull((select sum(charge) from #account a
	where a.pccode = #daycred.pccode), 0)
update #daycred set amount2 = amount2 + isnull((select sum(charge2) from #account a
	where a.pccode = #daycred.pccode and not a.crradjt in ('AD', 'LA')), 0)
update #daycred set amount3 = amount3 + isnull((select sum(charge3) from #account a
	where a.pccode = #daycred.pccode and not a.crradjt in ('AD', 'LA')), 0)
update #daycred set amount4 = amount4 + isnull((select sum(charge4) from #account a
	where a.pccode = #daycred.pccode and not a.crradjt in ('AD', 'LA')), 0)
update #daycred set amount5 = amount5 + isnull((select sum(charge5) from #account a
	where a.pccode = #daycred.pccode and not a.crradjt in ('AD', 'LA')), 0)
update #daycred set amount7 = amount7 + isnull((select sum(charge) from #account a
	where a.pccode = #daycred.pccode and a.crradjt in ('AD', 'LA') and a.charge > 0), 0)
update #daycred set amount8 = amount8 - isnull((select sum(charge) from #account a
	where a.pccode = #daycred.pccode and a.crradjt in ('AD', 'LA') and a.charge < 0), 0)
update #daycred set amount1 = amount9 + amount2 - amount3 - amount4 - amount5 - amount7 + amount8

update #daycred set amount1 = amount1 + isnull((select sum(credit) from #account a
	where a.argcode in ('98') and a.pccode = #daycred.pccode), 0)
update #daycred set amount2 = amount2 + isnull((select sum(credit) from #account a
	where a.argcode in ('99') and a.credit > 0 and a.pccode = #daycred.pccode), 0)
update #daycred set amount3 = amount3 - isnull((select sum(credit) from #account a
	where a.argcode in ('99') and a.credit < 0 and a.pccode = #daycred.pccode), 0)
update #daycred set amount9 = amount1 + amount2 - amount3 where pccode > '9'

if @empno = '%' 
   begin
		if @langid=0 
			select @empno = "所有收银员"
      else
			select @empno = "All Cashier"
	end 

select @empno,a.descript, a.amount1, a.amount2, a.amount3, a.amount4, a.amount5, a.amount6, a.amount7, a.amount8, a.amount9 , class = '1', a.pccode
	from #daycred a where a.pccode < '9' and @langid=0
union all 
select @empno,a.descript, a.amount1, a.amount2, a.amount3, a.amount4, a.amount5, a.amount6, a.amount7, a.amount8, a.amount9 , class = '2', a.pccode
	from #daycred a where a.pccode > '9' and @langid=0
union all 
select @empno,b.descript1, a.amount1, a.amount2, a.amount3, a.amount4, a.amount5, a.amount6, a.amount7, a.amount8, a.amount9 , class = '1', a.pccode
	from #daycred a,pccode b where a.pccode *=b.pccode and  a.pccode < '9' and @langid<>0
union all 
select @empno,b.descript1, a.amount1, a.amount2, a.amount3, a.amount4, a.amount5, a.amount6, a.amount7, a.amount8, a.amount9 , class = '2', a.pccode
	from #daycred a,pccode b where a.pccode *=b.pccode and  a.pccode > '9' and @langid<>0
	order by a.class, a.pccode

return 0;
