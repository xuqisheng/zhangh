
if exists(select 1 from sysobjects where name ='p_cyj_pos_adj_check' and type ='P')
	drop proc p_cyj_pos_adj_check;
create proc p_cyj_pos_adj_check
	@date			datetime
as
--------------------------------------------------------
--
--		pos检测 menu,dish,pay 的金额是否正确
--
--------------------------------------------------------
declare	
	@bdate	datetime
select @bdate = bdate1 from sysdata

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
select 'dish合计和pay合计不一致', a.menu, (select sum(b.amount - b.dsc + b.tax + b.srv) from #dish b, #menu d where d.pcrec=a.menu and d.menu = b.menu and charindex(b.sta,'03579A')>0 and b.code <>'Y' and b.code<>'Z') ,
	(select sum(c.amount) from #pay c, #menu e where e.pcrec=a.menu and e.menu = c.menu) 
	from #pcrec a 
	where (select sum(b.amount - b.dsc + b.tax + b.srv) from #dish b, #menu d where d.pcrec=a.menu and d.menu = b.menu and charindex(b.sta,'03579A')>0 and b.code <>'Y' and b.code<>'Z') 
	<> (select sum(c.amount) from #pay c, #menu e where e.pcrec=a.menu and e.menu = c.menu) 
select 'dish Z 服务费不等于明细服务费合计',a.menu,a.srv,(select b.amount from #dish b where a.menu=b.menu and b.code ='Z'),
	(select sum(c.srv) from #dish c where a.menu=c.menu and c.code <>'Y' and c.code <>'Z')
	from #menu a where 
	(select b.amount from #dish b where a.menu=b.menu and b.code ='Z') <>
	(select sum(c.srv) from #dish c where a.menu=c.menu and c.code <>'Y' and c.code <>'Z') 

;
