if exists(select * from sysobjects where name = 'p_gl_accnt_srepo')
	drop proc p_gl_accnt_srepo;

create proc p_gl_accnt_srepo
	@date				datetime, 
	@empno			varchar(255), 
	@shift			char(1),
   @langid			integer = 0,
	@option			char(10) = 'ALL'		-- FRONT:前台,AR:AR账,ALL:所有
as
--  输帐报表生成 

declare
	@accnt			char(10), 
	@billno			char(10), 
	@pccode			char(5), 
	@argcode			char(3), 
	@lic_buy_1		varchar(255),
	@lic_buy_2		varchar(255),
	@credit			money, 
	@charge			money,			 	
	@crradjt			char(2), 
	@tofrom			char(2), 
	@modu_id			char(2), 
	@pccode_tor		char(5),
	@accntof			char(10),
	@empno_			char(10)

create table #srepo
(
	deptno			char(5)		not null, 					--  款项或费用, 'CRD/CHG' 
	pccode			char(5)		not null, 					--  to charge, is pccode, to credit, is paycode 
	deptname			char(24)		null, 						--  大类的中文名称 
	descript			char(24)		null, 						--  中文名称 
	f_in				money			default 0 	not null, 	--  前台 
	b_in  			money			default 0 	not null, 	--  后台 (录入, 定金) 
	f_out				money			default 0 	not null, 	--  前台 
	b_out				money			default 0 	not null, 	--  后台 (退款, 部结) 
	f_tran			money			default 0 	not null, 	--  前台 
	b_tran			money			default 0 	not null, 	--  后台 (转入, 清算) 
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
insert #srepo(deptno, deptname, pccode, descript) select deptno, '', pccode, '  ' + descript from pccode
update #srepo set deptname = a.descript from basecode a where #srepo.deptno = a.code and a.cat = 'chgcod_deptno'
update #srepo set deptname = a.descript from basecode a where #srepo.deptno = a.code and a.cat = 'paymth_deptno'
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
-- 计算转应收账(兼容“按行转AR账”及用“转AR账”付款)
if not (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
	begin
	select @pccode_tor = pccode from pccode where deptno2 = 'TOR'
	declare c_tor cursor for
		select accnt, pccode, argcode, credit, charge, crradjt, tofrom, accntof, modu_id, billno from #account
	open c_tor
	fetch c_tor into @accnt, @pccode, @argcode, @credit, @charge, @crradjt, @tofrom, @accntof, @modu_id, @billno
	while @@sqlstatus = 0
		begin
		if @argcode < '9' and @accnt like 'A%'
			begin
			if @accntof like 'A%'				-- 记帐
				update #srepo set b_in = b_in + @charge where pccode = @pccode_tor
			else										-- 客帐
				update #srepo set b_tran = b_tran + @charge where pccode = @pccode_tor
			end
		fetch c_tor into @accnt, @pccode, @argcode, @credit, @charge, @crradjt, @tofrom, @accntof, @modu_id, @billno
		end
	close c_tor
	deallocate cursor c_tor
	end
-- 删除当天的冲账转账明细
delete #account where not (crradjt in ('', 'AD', 'CT') or (crradjt like 'L%' and tofrom = ''))
--
declare c_srepo cursor for
	select accnt, pccode, argcode, credit, charge, crradjt, tofrom, accntof, modu_id, billno from #account
open c_srepo
fetch c_srepo into @accnt, @pccode, @argcode, @credit, @charge, @crradjt, @tofrom, @accntof, @modu_id, @billno
while @@sqlstatus = 0
	begin
	if @argcode > '9'
		begin
		if @accnt not like 'A%'					-- 客帐
			begin
			if @argcode in ('98')				-- 定金
				update #srepo set f_in = f_in + @credit where pccode = @pccode
			else										-- 清算
				update #srepo	set f_tran = f_tran + @credit where pccode = @pccode
			end
		else
			begin
			if @argcode in ('98')				-- 定金
				update #srepo set b_in = b_in + @credit where pccode = @pccode
			else										-- 清算
				update #srepo set b_tran = b_tran + @credit where pccode = @pccode
			end
		end
	else
		begin
		if @accnt not like 'A%'					-- 客帐
			begin
			if @modu_id = '02'					-- 录入
				update #srepo set f_in = f_in + @charge where pccode = @pccode
			else										-- 转帐
				update #srepo set f_tran = f_tran + @charge where pccode = @pccode
			end
		else
			begin
			if @modu_id = '02'					-- 录入
				update #srepo set b_in = b_in + @charge where pccode = @pccode
			else										-- 转帐
				update #srepo set b_tran = b_tran + @charge where pccode = @pccode
			end
		end
	fetch c_srepo into @accnt, @pccode, @argcode, @credit, @charge, @crradjt, @tofrom, @accntof, @modu_id, @billno
	end
close c_srepo
deallocate cursor c_srepo
delete #srepo where f_in = 0 and b_in = 0 and f_out = 0 and b_out = 0 and f_tran = 0 and b_tran = 0

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

select dc = 1, @empno, a.deptno, a.pccode, a.deptname, '   ' + a.descript, a.f_in, a.b_in, a.f_out, a.b_out, a.f_tran, a.b_tran from #srepo a where a.pccode < '9' and @langid = 0
	union select dc = 2, @empno, a.deptno, a.pccode, a.deptname, '   ' + a.descript,  a.f_in, a.b_in, a.f_out, a.b_out, a.f_tran, a.b_tran from #srepo a where a.pccode > '9' and @langid = 0
	union select dc = 1, @empno, a.deptno, a.pccode, c.descript1, '   ' + b.descript1, a.f_in, a.b_in, a.f_out, a.b_out, a.f_tran, a.b_tran from #srepo a, pccode b, basecode c where a.pccode *= b.pccode  and a.deptno *= c.code and c.cat = 'chgcod_deptno' and a.pccode < '9' and @langid <> 0
	union select dc = 2, @empno, a.deptno, a.pccode, c.descript1, '   ' + b.descript1, a.f_in, a.b_in, a.f_out, a.b_out, a.f_tran, a.b_tran from #srepo a, pccode b, basecode c where a.pccode *= b.pccode  and a.deptno *= c.code and c.cat = 'paymth_deptno' and a.pccode > '9' and @langid <> 0

return 0
;