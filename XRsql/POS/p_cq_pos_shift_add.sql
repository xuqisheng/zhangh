drop proc p_cq_pos_shift_add;
create proc p_cq_pos_shift_add
	@limpcs				varchar(120),	-- Pccode 限制
	@date					datetime,		-- 报表日期
	@empno				char(10),		-- 工号 null 表示所有工号
	@shift				char(1)			-- 班别 null 表示所有班别

as
------------------------------------------------------------------------------------
--
--		餐饮交班表的明细菜打印
--
------------------------------------------------------------------------------------

declare
	@bdate				datetime			-- 营业日期

select * into #pos_menu from pos_menu where 1 = 2
select * into #pos_dish from pos_dish where 1 = 2
create table #dish 
(
	shift			char(1),
	menu			char(10),
	inumber		int,
	name1			char(50),
	amount1		money,
	amount2		money,
	amount3		money
)
select @bdate = bdate1 from sysdata
if @bdate = @date
	begin
	insert #pos_menu select a.* from pos_menu a where charindex(a.pccode, @limpcs)>0 and
	 a.bdate=@date and (a.empno3=@empno or @empno='') and a.sta = '3'
	and (a.shift=@shift or @shift ='')
	insert #pos_dish select * from pos_dish
	end
else
	begin
	insert #pos_menu select a.* from pos_hmenu a where charindex(a.pccode, @limpcs)>0 and
	 a.bdate=@date and (a.empno3=@empno or @empno='') and a.sta = '3'
	and (a.shift=@shift or @shift ='')
	insert #pos_dish select * from pos_hdish where bdate = @date
	end

insert #dish
	select a.shift,b.menu,b.inumber,b.name1,b.amount+b.srv-b.dsc ,0,0
	from #pos_menu a,#pos_dish b,pos_plu_all c where 
	a.menu = b.menu and b.id = c.id 	and b.sta = '2' and substring(b.flag,30,1)='T'

insert #dish 
	select a.shift,b.menu,b.inumber,b.name1,0 ,b.dsc,b.amount
	from #pos_menu a,#pos_dish b,pos_plu_all c where 
a.menu = b.menu and b.id = c.id and charindex(b.sta,'03579')>0 and (b.dsc<>0 or b.amount < 0)
and b.menu+convert(char,b.inumber)
not in (select menu+convert(char,inumber) from #dish)

update #dish set amount3 = 0 where amount3>0
select shift,menu,'',sum(amount1),sum(amount2),sum(amount3) from #dish group by shift,menu order by shift,menu
;
