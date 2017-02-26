if exists (select * from sysobjects where name ='p_gl_ar_compress_detail' and type ='P')
	drop proc p_gl_ar_compress_detail;
create proc p_gl_ar_compress_detail
	@accnt			char(10), 
	@number			integer,
	@langid			integer = 0
as
declare
	@ref				varchar(50),
	@pay_for			varchar(20),
	@pay_by			varchar(20),
@count integer,
	@selected		integer,
	@tree_level		integer

select @tree_level = 0, @selected = 0
--
select *, tree_level = 0, tree_order = right('     ' + convert(char(6), number), 6) + space(249) into #detail
	from ar_detail where accnt = @accnt and number = @number
while @@rowcount > 0
	begin
	select @tree_level = @tree_level + 1
	insert #detail select a.*, @tree_level, substring(tree_order, 1, @tree_level * 6) + right('     ' + convert(char(6), a.number), 6)
		from har_detail a, #detail b
		where b.tree_level = @tree_level - 1 and a.accnt = b.accnt and a.pnumber = b.number
	end
--
// ·µ»Ø½á¹û
if @langid = 0
	select a.accnt, a.subaccnt, a.number, a.pccode, a.argcode, a.empno, a.shift, a.log_date, a.guestname, a.guestname2, a.ref, a.ref1, a.ref2,
		a.modu_id, a.charge, a.credit,a.charge0, a.credit0,a.charge9, a.credit9, a.disputed, a.accntof,
		crradjt, package, tran_accnt = a.tofrom + a.accntof, a.bdate, a.date, a.roomno, a.billno, a.audit, ar_tag = tag, tree_level, @selected, tag = ''
		from #detail a order by a.tree_order
else
	select a.accnt, a.subaccnt, a.number, a.pccode, a.argcode, a.empno, a.shift, a.log_date, a.guestname, a.guestname2, isnull(c.descript1, a.ref), a.ref1, a.ref2,
		a.modu_id, a.charge, a.credit,a.charge0, a.credit0,a.charge9, a.credit9, a.disputed, a.accntof,
		crradjt, package, tran_accnt = a.tofrom + a.accntof, a.bdate, a.date, a.roomno, a.billno, a.audit, ar_tag = tag, tree_level, @selected, tag = ''
		from #detail a, pccode c where a.pccode *= c.pccode order by a.tree_order
return 0
;
