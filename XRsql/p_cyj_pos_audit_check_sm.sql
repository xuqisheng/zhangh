drop  proc p_cyj_pos_audit_check_sm;
create proc p_cyj_pos_audit_check_sm
	@date		datetime
as
----------------------------------------------------------------------------------------------*/
--
-- 餐饮数据检查，会导致底表不平的相关因素
-- 适用范围 smart 各个版本  cyj 20100331
----------------------------------------------------------------------------------------------*/

declare
	@count1			int,
	@bdate			datetime

create	table	 #list(
	sort		char(10),
	des		char(60),
	menu		char(10),
	msg		char(200)
)


select @bdate = bdate1 from sysdata
select @count1 = 0

-- 餐厅对应前台费用码错误一
insert #list
	select '100', '餐厅对应前台费用码错误' +' pos_pccode.chgcod','','餐厅号:'+pccode+'  名称:'+descript
	from pos_pccode where chgcod not in(select pccode from pccode)

-- 餐厅对应前台费用码错误二
insert #list
	select '100', '餐厅班别对应前台费用码错误'+' pos_int_pccode.pccode','','餐厅号:'+b.pos_pccode+'  名称:'+rtrim(b.name1) +' 前台费用码:'+b.pccode+'班别:'+b.shift
	from pos_pccode a, pos_int_pccode b where a.pccode=b.pos_pccode and b.class='2' and b.pccode not in(select pccode from pccode)

-- itemdef没有定义报表项目
select @count1 = count(1) from pos_itemdef a,pos_pccode b where a.pccode=b.pccode  
	and a.code not in( select c.code from  pos_namedef c where b.deptno=c.deptno and a.code=c.code)
if @count1 > 0 
	insert #list
	select '110','itemdef没有定义的报表代码'+'pos_itemdef','','部门号:'+b.deptno+' 餐厅:'+a.pccode+'代码:'+a.code from pos_itemdef a,pos_pccode b where a.pccode=b.pccode  
	and a.code not in( select c.code from  pos_namedef c where b.deptno=c.deptno and a.code=c.code)

-- 菜项没有定义报表数据项目
select @count1 = count(1) from pos_detail_jie where date = @bdate and tocode = '099'
if @count1 > 0 
	insert #list
	select '120', '有菜项没有定义报表数据项目,查菜谱和itemdef',menu,'单号:'+menu+' 菜号:'+code+'  菜名:'+name1 
	from pos_detail_jie where date = @bdate and tocode = '099'

-- 菜类没有定义报表数据项目
select @count1 = count(1) from pos_sort where rtrim(ltrim(tocode)) is null and halt <>'T'
if @count1 > 0 
	insert #list
	select '125', '有菜类没有定义报表数据项目','','类号:'+sort+'  名称:'+name1 
	from pos_sort where  rtrim(ltrim(tocode)) is null and halt <>'T'

--餐厅没有定义底表项目
select @count1 = count(1) from pos_itemdef a,pos_pccode b where a.pccode=b.pccode and a.jierep not in(select class from jierep)
if @count1 > 0 
	insert #list
	select distinct '130','餐厅没有定义底表项目'+'itemdef.jierep','',' 餐厅:'+b.pccode+'底表行:'+a.jierep
	from pos_itemdef a,pos_pccode b where a.pccode=b.pccode and a.jierep not in(select class from jierep)

--pccode 定义
select @count1 = count(1) from pccode where pccode>'9' and deptno8>'' and deptno8 not in(select code from pos_namedef)
if @count1 > 0 
	insert #list
	select distinct '150','折扣款待类付款码没有定义对应namedef报表项','',' 付款码:'+pccode+'报表项deptno8='+deptno8
	from pccode  where pccode>'9' and deptno8>'' and deptno8 not in(select code from pos_namedef)
select @count1 = count(1) from pccode a where  a.pccode > '9' and a.deptno8>' ' and  (select count(1) from pccode b where a.deptno8 = b.deptno8 and b.pccode>'9')>1
if @count1 > 0 
	insert #list
	select distinct '170','折扣款待类付款码deptno8定义有重复','',' 付款码:'+pccode+'报表项deptno8='+deptno8
	 from pccode a where  a.pccode > '9' and a.deptno8>' ' and  (select count(1) from pccode b where a.deptno8 = b.deptno8 and b.pccode>'9')>1

-- **以下检查营业数据**
-- 转前台，餐饮数据和前台数据不一致
if exists(select 1 from sysoption where catalog ='hotel' and (item ='lic_buy.1' or item ='lic_buy.2') and charindex('nar,',value)>0)
	begin          
    -- 新ar，信用卡通过ar核销
	select @count1 = count(1) from pos_menu a where a.sta='3' 
	and isnull((select sum(b.charge) from ar_account b where b.ref1=a.menu and b.modu_id='04'),0)
	+isnull((select sum(e.charge) from account e where e.ref1=a.menu and e.modu_id='04'),0)
	<>isnull((select sum(c.amount) from pos_pay c, pccode d where c.menu=a.menu and c.crradjt='NR' and c.sta='3' and c.paycode=d.pccode and (d.deptno2='TOR' or d.deptno2='TOA' or deptno4='ISC')),0)
	if @count1 > 0 
		insert #list
		select '300','转前台餐饮数据和前台数据不一致',a.menu,a.menu+"  餐厅:"+f.descript+ "  桌号:"+a.tableno+"  金额:"+convert(varchar,a.amount) from pos_menu a,pos_pccode f where  a.sta='3' and a.pccode=f.pccode
		and isnull((select sum(b.charge) from ar_account b where b.ref1=a.menu and b.modu_id='04'),0)
		+isnull((select sum(e.charge) from account e where e.ref1=a.menu and e.modu_id='04'),0)
		<>isnull((select sum(c.amount) from pos_pay c, pccode d where c.menu=a.menu and c.crradjt='NR' and c.sta='3' and c.paycode=d.pccode and (d.deptno2='TOR' or d.deptno2='TOA' or deptno4='ISC')),0)
	end
else
	begin
    -- 老ar，信用卡不通过ar核销
	select @count1 = count(1) from pos_menu a where a.sta='3' 
	and isnull((select sum(b.charge) from ar_account b where b.ref1=a.menu and b.modu_id='04'),0)
	+isnull((select sum(e.charge) from account e where e.ref1=a.menu and e.modu_id='04'),0)
	<>isnull((select sum(c.amount) from pos_pay c, pccode d where c.menu=a.menu and c.crradjt='NR' and c.sta='3' and c.paycode=d.pccode and (d.deptno2='TOR' or d.deptno2='TOA')),0)
	if @count1 > 0 
		insert #list
		select '300','转前台餐饮数据和前台数据不一致',a.menu,a.menu+"  餐厅:"+f.descript+ "  桌号:"+a.tableno+"  金额:"+convert(varchar,a.amount) from pos_menu a,pos_pccode f where  a.sta='3' and a.pccode=f.pccode
		and isnull((select sum(b.charge) from ar_account b where b.ref1=a.menu and b.modu_id='04'),0)
		+isnull((select sum(e.charge) from account e where e.ref1=a.menu and e.modu_id='04'),0)
		<>isnull((select sum(c.amount) from pos_pay c, pccode d where c.menu=a.menu and c.crradjt='NR' and c.sta='3' and c.paycode=d.pccode and (d.deptno2='TOR' or d.deptno2='TOA' )),0)
	end

-- 校验联单错误
---- 剔除状态不一致的未结账的联单
update pos_menu set pcrec ='' from pos_menu where pcrec in (select pcrec from pos_menu where sta='3' and pcrec >'') and sta<>'3'	
update pos_tmenu set pcrec ='' from pos_tmenu where pcrec in (select pcrec from pos_tmenu where sta='3' and pcrec >'') and sta<>'3'	
update pos_hmenu set pcrec ='' from pos_hmenu where bdate = dateadd(day,-1, @bdate) and pcrec in (select pcrec from pos_hmenu where bdate = dateadd(day,-1, @bdate) and sta='3' and pcrec >'') and sta<>'3'	
---- 更新联单号是其他单号的联单
update  pos_menu set pcrec =(select min(c.menu) from pos_menu c where a.pcrec = c.pcrec and c.pcrec>'')
	from pos_menu a where a.pcrec>'' and a.pcrec not in (select b.menu from pos_menu b where a.pcrec = b.pcrec and b.pcrec>'')
update  pos_tmenu set pcrec =(select min(c.menu) from pos_tmenu c where a.pcrec = c.pcrec and c.pcrec>'')
	from pos_tmenu a where a.pcrec>'' and a.pcrec not in (select b.menu from pos_tmenu b where a.pcrec = b.pcrec and b.pcrec>'')
update  pos_hmenu set pcrec =(select min(c.menu) from pos_hmenu c where a.pcrec = c.pcrec and c.pcrec>'' and c.bdate = dateadd(day,-1, @bdate))
	from pos_hmenu a where a.pcrec>'' and a.bdate = dateadd(day,-1, @bdate) and a.pcrec not in (select b.menu from pos_hmenu b where a.pcrec = b.pcrec and b.pcrec>'' and b.bdate = dateadd(day,-1, @bdate))

--	检测 menu,dish,pay 的金额是否正确
create table #pcrec (menu char(10) default '' not null)
select * into #menu from pos_menu where 1=2
select * into #dish from pos_dish where 1=2
select * into #pay from pos_pay where 1=2
if @date = @bdate 
	begin
	insert into #menu select * from pos_menu where sta ='2'
	insert into #dish select a.* from pos_dish a,#menu b where a.menu=b.menu and charindex(a.sta,'03579A')>0
	insert into #pay  select a.* from pos_pay  a,#menu b where a.menu=b.menu
	end
else
	begin
	insert into #menu select * from pos_hmenu where sta ='2' and bdate=@date
	insert into #dish select a.* from pos_hdish a,#menu b where a.menu=b.menu  and charindex(a.sta,'03579A')>0
	insert into #pay  select a.* from pos_hpay  a,#menu b where a.menu=b.menu
	end
update #menu set pcrec = menu where pcrec = '' or pcrec is null
insert into #pcrec select distinct pcrec from #menu
insert #list 
select '800','dish合计和pay合计不一致', a.menu, convert(varchar,(select sum(b.amount - b.dsc + b.tax + b.srv) from #dish b, #menu d where d.pcrec=a.menu and d.menu = b.menu and charindex(b.sta,'03579A')>0 and b.code <>'Y' and b.code<>'Z')) + ','
	+ convert(varchar,(select sum(c.amount) from #pay c, #menu e where e.pcrec=a.menu and e.menu = c.menu) )
	from #pcrec a 
	where (select sum(b.amount - b.dsc + b.tax + b.srv) from #dish b, #menu d where d.pcrec=a.menu and d.menu = b.menu and charindex(b.sta,'03579A')>0 and b.code <>'Y' and b.code<>'Z') 
	<> (select sum(c.amount) from #pay c, #menu e where e.pcrec=a.menu and e.menu = c.menu) 

insert #list 
select '830','款待类付款超出菜品金额合计',a.menu,'款待类付款超出菜品金额合计，会无法分摊，导致报表不平！'
	from #pcrec a 
	where (select sum(b.amount - b.dsc + b.tax + b.srv) from #dish b, #menu d where d.pcrec=a.menu and d.menu = b.menu and charindex(b.sta,'03579A')>0 and b.code <>'Y' and b.code<>'Z') 
	< (select sum(c.amount) from #pay c, #menu e, pccode f where e.pcrec=a.menu and e.menu = c.menu and c.paycode=f.pccode and f.deptno8<'' ) 

-- 校验营业日期
update pos_pay set bdate = a.bdate from pos_menu a where a.menu = pos_pay.menu
update pos_tpay set bdate = a.bdate from pos_tmenu a where a.menu = pos_tpay.menu


select sort,des,menu,msg from #list order by sort
;