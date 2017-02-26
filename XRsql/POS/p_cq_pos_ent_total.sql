drop proc p_cq_pos_ent_total;
create proc p_cq_pos_ent_total
	@pccodes			varchar(120),	-- Pccode 限制
	@date1			datetime,		-- 报表日期
	@date2			datetime,		-- 报表日期
	@type				char(1)
as

declare
	@bdate				datetime,	-- 营业日期
	@sbegin				varchar(10),			            
	@send					varchar(10),
	@pccode				char(3)

create table #out
(
	reason			char(3),
	descript			char(30),
	code				char(5),
	descript1		char(30),
	amount			money
)

select @sbegin = convert(char(6),@date1, 12) + '0000'
select @send 	= convert(char(6),@date2, 12) + '9999'
if @type = '1' 
	begin
	insert #out
		select a.reason,'',b.pccode,'',sum(a.amount) from pos_pay a,pos_menu b where a.menu = b.menu and b.sta = '3'
			and a.crradjt = 'NR' and a.paycode in (select pccode from pccode where deptno2 ='ENT') and a.menu >= @sbegin and a.menu <= @send
			group by a.reason,b.pccode order by b.pccode
	insert #out
		select a.reason,'',b.pccode,'',sum(a.amount) from pos_hpay a,pos_hmenu b where a.menu = b.menu and b.sta = '3'
			and a.crradjt = 'NR' and a.paycode in (select pccode from pccode where deptno2 ='ENT') and a.menu >= @sbegin and a.menu <= @send
			group by a.reason,b.pccode order by b.pccode
	update #out set descript = a.descript from reason a where a.code = #out.reason 
	update #out set descript1 = a.descript from pos_pccode a where a.pccode = #out.code
	insert #out select a.code,a.descript,b.pccode,b.descript,0 from reason a,pos_pccode b
		where  a.p02 > 0 and a.code not in (select reason from #out where code = b.pccode) order by b.pccode
	end
else
	begin
	select @pccode = pccode from pos_pccode where descript like '%'+@pccodes+'%'
	insert #out
		select c.reason3,'',c.tocode,'',sum(c.amount3) from pos_menu b,pos_detail_jie c where  b.sta = '3' and b.pccode = @pccode
			and b.menu >= @sbegin and b.menu <= @send and c.type = 'ENT'
				and b.menu = c.menu
			group by c.reason3,c.tocode order by c.tocode
	insert #out
		select c.reason3,'',c.tocode,'',sum(c.amount3) from pos_hmenu b,pos_detail_jie c where  b.sta = '3' and b.pccode = @pccode
			and b.menu >= @sbegin and b.menu <= @send and c.type = 'ENT'
				and b.menu = c.menu
			group by c.reason3,c.tocode order by c.tocode
	update #out set descript = a.descript from reason a where a.code = #out.reason 
	update #out set descript1 = a.descript from pos_namedef a where a.code = #out.code
	insert #out select a.code,a.descript,b.code,b.descript,0 from reason a,pos_namedef b
		where  a.p02 > 0 and b.code <'06' and a.code not in (select reason from #out where code = b.code) order by b.code
	end


select reason,descript,code,descript1,amount from #out order by reason,code
	 

;
