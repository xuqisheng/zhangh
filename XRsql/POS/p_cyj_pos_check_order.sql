/*------------------------------------------------------------------------------------*/
//
//		�������򣬰���̨�Ⱥ󣬰������������Ա㻮��Ա�߲�; 
//		�Ѿ�����ĵ��ͽ��ʵĵ�������ʾ
//		pos_menu.amount1 �����û��Զ�����˴��� 
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
	empno			char(10),         -- // ֵ̨Ա
	amount		money default 0,
	date1			datetime,         -- // ��̨ʱ��
	dished		int   default 0 , 	     		-- // �����
	checked		int	default 0 ,        		-- // ����������
	checkrate	money default 0 ,        		-- // ����������
	amount1		money	default 100,         	-- //�Զ�����˴���
	tag3			char(1)	         				-- //T ����
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