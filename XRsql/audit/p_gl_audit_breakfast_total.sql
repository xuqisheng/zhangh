
-- 统计明天早餐的预提数 
if exists(select * from sysobjects where name = 'p_gl_audit_breakfast_total')
	drop proc p_gl_audit_breakfast_total;

create proc p_gl_audit_breakfast_total
	@bdate			datetime, 
	@type				char(1), 
	@operation		char(1) = 'S', 
	@f					money = 0 output, 
	@g					money = 0 output, 
	@m					money = 0 output, 
	@l					money = 0 output
as

create table #breakfast
(
	accnt			char(10)			not null, 					--  
	class			char(1)			not null,
	quantity		money				default 0 not null,
	amount		money				default 0 not null,
)
-- 
insert #breakfast select a.accnt, '', a.quantity, a.credit from package_detail a, package b
	where a.bdate = @bdate and a.tag < '5' and a.code = b.code and b.type = @type
update #breakfast set class = a.class
	from rmpostbucket a where #breakfast.accnt = a.accnt and a.rmpostdate = @bdate
--- 长包房特殊处理
update #breakfast set class = 'L' from master a, mktcode b 
	where #breakfast.accnt = a.accnt and a.market = b.code and b.flag='LON'

-- select @f = sum(quantity) from #breakfast where class = 'F'
-- select @g = sum(quantity) from #breakfast where class = 'G'
-- select @m = sum(quantity) from #breakfast where class = 'M'
-- select @l = sum(quantity) from #breakfast where class = 'L'
select @f = sum(amount) from #breakfast where class = 'F'
select @g = sum(amount) from #breakfast where class = 'G'
select @m = sum(amount) from #breakfast where class = 'M'
select @l = sum(amount) from #breakfast where class = 'L'
select @f = isnull(@f, 0), @g = isnull(@g, 0), @m = isnull(@m, 0), @l = isnull(@l, 0)

if @operation = 'S'
	select @f, @g, @m, @l
return 0
;