
IF OBJECT_ID('p_gds_adtrep_cashrep') IS NOT NULL
    DROP PROCEDURE p_gds_adtrep_cashrep
;
create proc p_gds_adtrep_cashrep
   @date   		datetime,
	@langid		int = 0
as
----------------------------------------------------------
--	Cross 风格 - 现金收入汇总表
----------------------------------------------------------
create table #gcashrep (
	tag			char(4)			not null,
	site			char(2)			not null,
	sitedes		varchar(20)		null,
	pay			char(3)			not null,
	paydes		varchar(20)		null,
	amount		money	default 0 not null
)

declare
	@monthbeg  		datetime,
	@isfstday  		char(1),
	@isyfstday 		char(1)

declare	
	@des_day			char(4),
	@des_month		char(4),
	@des_fo			varchar(20),
	@des_ar			varchar(20),
	@des_bus			varchar(20),
	@des_ttl			varchar(20)

-- 常规描述
if @langid <> 0 
	select @des_day='DAY',@des_month='MTD', @des_fo='FO', @des_ar='AR', @des_bus='BS'
else
	select @des_day='本日',@des_month='本月', @des_fo='前  厅', @des_ar='ＡＲ帐', @des_bus='商务中心'

-- 日期
select @monthbeg = @date, @isfstday='F'
exec p_hry_audit_fstday @monthbeg, @isfstday out, @isyfstday out
while @isfstday = 'F'
	begin
	select @monthbeg=dateadd(dd,-1,@monthbeg)
	exec p_hry_audit_fstday @monthbeg,@isfstday out,@isyfstday out
	end

-- Get data
insert #gcashrep(tag,site,pay,amount)
  select @des_day,class,ccode,isnull(sum(credit),0) from ycashrep
		where date=@date --and ccode like '9%' and ccode<'999'
			group by class,ccode
insert #gcashrep(tag,site,pay,amount)
  select @des_month,class,ccode,isnull(sum(credit),0) from ycashrep
		where date>=@monthbeg and date<=@date --and ccode like '9%' and ccode<'999'
			group by class,ccode



insert #gcashrep(tag,site,pay,amount)
	select @des_day,a.site,a.pay,0 from #gcashrep a
			where a.tag=@des_month and a.pay not in
				(select b.pay from #gcashrep b where b.tag=@des_day)
insert #gcashrep(tag,site,pay,amount)
	select @des_month,a.site,a.pay,0 from #gcashrep a
			where a.tag=@des_day and a.pay not in
				(select b.pay from #gcashrep b where b.tag=@des_month)


update #gcashrep set sitedes=a.descript from pccode a
	where #gcashrep.site=a.pccode
update #gcashrep set sitedes=@des_fo where site='01'
update #gcashrep set sitedes=@des_ar where site='02'
update #gcashrep set sitedes=@des_bus where site='03'
if @langid = 0 
	update #gcashrep set paydes=a.descript from pccode a where #gcashrep.pay=a.deptno1
else
	update #gcashrep set paydes=a.descript1 from pccode a where #gcashrep.pay=a.deptno1

insert #gcashrep(tag,site,sitedes,pay,paydes,amount)
	select tag,site,sitedes,'{{{','ZZZ Total',sum(amount)
		from #gcashrep group by tag, site, sitedes


select sitedes,paydes,tag,amount from #gcashrep
	order by site,pay,tag desc
return 0
;
