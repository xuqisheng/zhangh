if exists(select 1 from sysobjects where name ='p_cyj_pos_cost_report' and type ='P')
	drop proc p_cyj_pos_cost_report;
create proc p_cyj_pos_cost_report
	@type				char(10),       -- 类型: dish -- 统计菜品及对应配料成本, cond -- 统计配料耗用及对应菜品销售
	@pccode			char(3),        -- 餐厅
	@date1			datetime,       -- 开始统计日期
	@date2			datetime        -- 结束统计日前
as
---------------------------------------------------------------------------------------------------
--
--  餐饮成本统计报表
--
---------------------------------------------------------------------------------------------------

create table #report(
	pccode			char(3),
	pcdes				char(18),
	code				char(6),
	name1				char(30),
	dishunit			char(4),
	dishnumber		money,
	dishamount		money,
	condid			int,
	condcode			char(10),
	condunit			char(4),
	conddes			char(40),
	condnumber		money,
	condamount		money,
	rate				money
)
if @type = 'dish' -- 统计菜品及对应配料成本
	begin
	insert #report(pccode,pcdes,code,name1,dishunit,dishnumber,dishamount,condcode,conddes,condnumber,condamount,rate)
		select c.pccode,'',a.code,a.name1,a.unit,a.number,a.amount-a.dsc+a.srv+a.tax,'','',sum(b.number),sum(b.amount),0 
	from pos_hdish a,pos_hsale b,pos_hmenu c 
	where a.menu=c.menu and charindex(a.sta,  '03579')>0 and a.code<'X' 
	and a.menu=b.menu and a.inumber=b.inumber 
	and (c.pccode  = @pccode or @pccode = '###')
	and a.bdate>=@date1 and a.bdate<=@date2
	group by c.pccode,a.code,a.name1,a.unit,a.number,a.amount-a.dsc+a.srv+a.tax
	order by c.pccode,a.code,a.name1,a.unit,a.number,a.amount-a.dsc+a.srv+a.tax
	update #report set rate = condamount / dishamount * 100 where dishamount <> 0 
	update #report set pcdes = b.descript from #report a, pos_pccode b where a.pccode = b.pccode
	select pcdes,code,name1,dishnumber,dishunit,dishamount,condnumber,condamount,rate from #report order by pcdes,code
	end
else       --  统计配料耗用及对应菜品销售
	begin
	insert #report(pccode,pcdes,code,name1,dishunit,dishnumber,dishamount,condid,condcode,condunit,conddes,condnumber,condamount,rate)
		select c.pccode,'',a.code,a.name1,a.unit,a.number,a.amount-a.dsc+a.srv+a.tax,b.condid,d.sequence,b.unit,b.descript,b.number,b.amount,0 
	from pos_hdish a,pos_hsale b,pos_hmenu c, pos_condst d 
	where a.menu=c.menu and charindex(a.sta,  '03579')>0 and a.code<'X' 
	and a.menu=b.menu and a.inumber=b.inumber 
	and (c.pccode  = @pccode or @pccode = '###')
	and a.bdate>=@date1 and a.bdate<=@date2
	and b.condid = d.condid 
	update #report set pcdes = b.descript from #report a, pos_pccode b where a.pccode = b.pccode
	select pcdes,condcode,conddes,condnumber,condunit,condamount,code,name1,dishnumber,dishunit,dishamount,condid from #report order by pcdes,condcode
	end
;