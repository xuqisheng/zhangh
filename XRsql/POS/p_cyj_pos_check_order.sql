/*------------------------------------------------------------------------------------*/
//
//		划单排序，按开台先后，按划单率排序，以便划单员催菜; 
//		已经上完的单和结帐的单不需显示
//		pos_menu.amount1 用于用户自定义出菜次序 
//
/*------------------------------------------------------------------------------------*/
if exists(select 1 from sysobjects where name = 'p_cyj_pos_check_order' and type = 'P')
	drop proc p_cyj_pos_check_order;
create proc p_cyj_pos_check_order
	@pccodes				char(100)
as

create table #menulist
(
	menu			char(10),
	tableno		char(5),
	empno			char(10),         -- // 值台员
	amount		money default 0,
	date1			datetime,         -- // 开台时间
	dished		int   default 0 , 	     		-- // 点菜数
	checked		int	default 0 ,        		-- // 划单出菜数
	checkrate	money default 0 ,        		-- // 划单出菜率
	amount1		money	default 100,         	-- //自定义出菜次序
	tag3			char(1)	         				-- //T 叫起
)
create table #dishlist
(
	menu			char(10),
	code			char(10),
	flag			char(10)
)

insert #menulist
select a.menu, a.tableno, a.empno3, amount, a.date0 , 0, 0, 0, amount1, tag3 from pos_menu a where charindex(a.pccode, @pccodes) > 0 
	and a.paid = '0' and exists(select 1 from pos_dish b where a.menu = b.menu and charindex('O', b.flag) = 0 and charindex(rtrim(ltrim(code)), 'XYZ') = 0)
insert #dishlist select a.menu, a.code, a.flag from pos_dish a, pos_menu b  where a.menu = b.menu and charindex(b.pccode, @pccodes) > 0 and b.paid = '0'

update #menulist set dished = (select count(1) from pos_dishcard b where b.menu = a.menu ),
	checked = (select count(1) from pos_dish b where b.menu = a.menu and charindex(rtrim(ltrim(code)), 'XYZ') = 0
	and charindex(b.sta, '03579') > 0 and charindex('O', b.flag) >0 ) 
 from #menulist a

update #menulist set checkrate = round(1.0 * checked / dished, 2) from #menulist where dished <> 0 
update #menulist set amount1 = 100 where amount1 = 0 

select * from #menulist order by checkrate
;