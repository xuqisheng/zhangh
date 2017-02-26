if exists(select 1 from sysobjects where name ='p_cyj_pos_audit_check' and type ='P')
	drop  proc p_cyj_pos_audit_check;
create proc p_cyj_pos_audit_check
as
/*--------------------------------------------------------------------------------------------*/
//
// 餐饮数据检查，会导致底表不平的相关因素
//
/*--------------------------------------------------------------------------------------------*/

declare
	@count1			int,
	@bdate			datetime

create	table	 #list(
	sort		char(10),
	des		char(60),
	menu		char(10),
	msg		char(200)
)

select @bdate = bdate from sysdata
select @count1 = 0

-- 餐厅对应前台费用码错误一
insert #list
	select '100', '餐厅对应前台费用码错误:' +' pos_pccode.chgcod','','餐厅号:'+pccode+'  名称:'+descript
	from pos_pccode where chgcod not in(select pccode from pccode)

-- 餐厅对应前台费用码错误二
insert #list
	select '110', '餐厅班别对应前台费用码错误:'+' pos_int_pccode.pccode','','餐厅号:'+b.pos_pccode+'  名称:'+b.name1 +' 前台费用码:'+b.pccode+'班别:'+b.shift
	from pos_pccode a, pos_int_pccode b where a.pccode=b.pos_pccode and b.class='2' and b.pccode not in(select pccode from pccode)

-- itemdef没有定义报表项目
select @count1 = count(1) from pos_itemdef a,pos_pccode b where a.pccode=b.pccode  
	and a.code not in( select c.code from  pos_namedef c where b.deptno=c.deptno and a.code=c.code)
if @count1 > 0 
	insert #list
	select '120','pos_itemdef有没有定义的报表代码:'+'pos_itemdef','','部门号:'+b.deptno+' 餐厅:'+a.pccode+'代码:'+a.code from pos_itemdef a,pos_pccode b where a.pccode=b.pccode  
	and a.code not in( select c.code from  pos_namedef c where b.deptno=c.deptno and a.code=c.code)

-- 菜项没有定义报表数据项目
select @count1 = count(1) from pos_detail_jie where date = @bdate and tocode = '099'
if @count1 > 0 
	insert #list
	select '130', '有菜项没有定义报表数据项目:',menu,'单号:'+menu+' 菜号:'+code+'  菜名:'+name1 
	from pos_detail_jie where date = @bdate and tocode = '099'

--餐厅没有定义底表项目
select @count1 = count(1) from pos_itemdef a,pos_pccode b where a.pccode=b.pccode and a.jierep not in(select class from jierep)
if @count1 > 0 
	insert #list
	select distinct '140','餐厅没有定义底表项目:'+'pos_itemdef.jierep','',' 餐厅:'+b.pccode+'  底表行:'+a.jierep
	from pos_itemdef a,pos_pccode b where a.pccode=b.pccode and a.jierep not in(select class from jierep)

-- 转前台，餐饮数据和前台数据不一致
select @count1 = count(1) from pos_menu a where a.sta='3' 
and isnull((select sum(b.charge) from ar_account b where b.ref1=a.menu and b.modu_id='04'),0)
+isnull((select sum(e.charge) from account e where e.ref1=a.menu and e.modu_id='04'),0)
<>isnull((select sum(c.amount) from pos_pay c, pccode d where c.menu=a.menu and c.crradjt='NR' and c.sta='3' and c.paycode=d.pccode and (d.deptno2='TOR' or d.deptno2='TOA')),0)
if @count1 > 0 
	insert #list
	select '200','转前台餐饮数据和前台数据不一致',a.menu,a.menu+"  餐厅:"+f.descript+ "  桌号:"+a.tableno+"  金额:"+convert(varchar,a.amount) from pos_menu a,pos_pccode f where  a.sta='3' and a.pccode=f.pccode
	and isnull((select sum(b.charge) from ar_account b where b.ref1=a.menu and b.modu_id='04'),0)
	+isnull((select sum(e.charge) from account e where e.ref1=a.menu and e.modu_id='04'),0)
	<>isnull((select sum(c.amount) from pos_pay c, pccode d where c.menu=a.menu and c.crradjt='NR' and c.sta='3' and c.paycode=d.pccode and (d.deptno2='TOR' or d.deptno2='TOA')),0)

-- 餐单金额和菜合计不一致
select @count1 = count(1) from pos_menu a where a.sta='3'
and a.amount<>isnull((select sum(b.amount - b.dsc + b.srv + b.tax) from pos_dish b where a.menu=b.menu and charindex(rtrim(ltrim(b.code)),'YZ')=0),0)
if @count1 > 0 
	insert #list
	select '210','menu.amount和dish合计不一致',a.menu,a.menu+"  餐厅:"+f.descript+ "  桌号:"+a.tableno+"  金额:"+convert(varchar,a.amount) from pos_menu a,pos_pccode f where  a.sta='3' and a.pccode=f.pccode
	and a.amount<>isnull((select sum(b.amount - b.dsc + b.srv + b.tax) from pos_dish b where a.menu=b.menu and charindex(rtrim(ltrim(b.code)),'YZ')=0),0)

-- 餐单服务费和菜服务费合计不一致
select @count1 = count(1) from pos_menu a where a.sta='3'
and isnull((select b.amount from pos_dish b where a.menu=b.menu and rtrim(ltrim(b.code)) ='Z'),0)
  <>isnull((select sum(c.srv) from pos_dish c where a.menu=c.menu and charindex(rtrim(ltrim(c.code)),'YZ')=0),0)
if @count1 > 0 
	insert #list
	select '220','dish.Z和dish服务费合计不一致',a.menu,a.menu+"  餐厅:"+f.descript+ "  桌号:"+a.tableno+"  金额:"+convert(varchar,a.amount) from pos_menu a,pos_pccode f where  a.sta='3' and a.pccode=f.pccode
	and isnull((select b.amount from pos_dish b where a.menu=b.menu and rtrim(ltrim(b.code)) ='Z'),0)
  	<>isnull((select sum(c.srv) from pos_dish c where a.menu=c.menu and charindex(rtrim(ltrim(c.code)),'YZ')=0),0)

-- 设置已经检查过餐饮设置和数据标志
update sysoption set value ='T' where catalog='pos' and item='audit_check'

select * from #list
;
