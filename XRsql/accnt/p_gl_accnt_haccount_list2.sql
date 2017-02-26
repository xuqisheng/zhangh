if exists(select * from sysobjects where name = "p_gl_accnt_haccount_list2")
	drop proc p_gl_accnt_haccount_list2;

create proc p_gl_accnt_haccount_list2
	@pc_id			char(4),						// IP地址
	@mdi_id			integer						// 唯一的账务窗口ID
as

create table #subtotal
(
	pccode			char(5)			not null,
	ref				char(24)			null,
	amount			money				null,
	amount1			money				null
)

insert #subtotal select a.pccode, a.ref, amount = sum(a.charge + a.credit), amount1 = sum(a.charge - a.credit)
	from account a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
	group by a.pccode, a.ref order by a.pccode
insert #subtotal select a.pccode, a.ref, amount = sum(a.charge + a.credit), amount1 = sum(a.charge - a.credit)
	from haccount a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
	group by a.pccode, a.ref order by a.pccode
select pccode, ref, sum(amount), sum(amount1), selected = 1
	from #subtotal group by pccode, ref order by pccode
return
;
