if object_id('p_hbb_analyse_country_rep') is not null
	drop proc p_hbb_analyse_country_rep;
create proc p_hbb_analyse_country_rep
	@begin			datetime,
	@end				datetime,
	@langid			integer = 0,
	@tag				char(2) = 'SA'	-- Serviced Apartment 为了分开酒店与公寓

as

declare
	@diff_days		integer

create table #natrep(
	code				char(3)			default '' not null,
	descript			char(40)			default '' not null,
	no					char(7)			default '' not null,
	accnt				char(10)			default '' not null,
	guests			money				default 0  not null,
	nts				money				default 0  not null,
	rm					money				default 0  not null,
	fb					money				default 0  not null,
	ot					money				default 0  not null,
	ttl				money				default 0  not null
)

select @diff_days = datediff(day,@begin,@end)

--insert #natrep(no,accnt,code) select a.haccnt,a.accnt,isnull(rtrim(b.country),b.nation)
--	from hmaster a,guest b,ycus_xf c where c.bdate >= @begin and c.bdate <= @end and a.haccnt = b.no

-- 最大统计区间 1 年
if @diff_days > 366 
	goto RET_P

select accnt,master,gstno,i_days,rm,fb,ot,ttl into #custmp
	from ycus_xf where date >= @begin and date <= @end and accnt like 'F%'
update #custmp set i_days = 0 where accnt != master 

insert #natrep(accnt,guests,nts,rm,fb,ot,ttl) select accnt,sum(gstno),sum(i_days),sum(rm),sum(fb),sum(ot),sum(ttl)
	from #custmp 
group by accnt

if @tag = 'SA'
	begin
	delete #natrep from  master a where #natrep.accnt = a.accnt and substring(a.extra,2,1) like '[^89]%' 
	delete #natrep from hmaster a where #natrep.accnt = a.accnt and substring(a.extra,2,1) like '[^89]%' 
	end
else
	begin
	delete #natrep from  master a where #natrep.accnt = a.accnt and substring(a.extra,2,1) like '[89]%' 
	delete #natrep from hmaster a where #natrep.accnt = a.accnt and substring(a.extra,2,1) like '[89]%' 
	end

update #natrep set no = a.haccnt from hmaster a where #natrep.accnt = a.accnt
update #natrep set no = a.haccnt from master  a where #natrep.accnt = a.accnt and rtrim(#natrep.no) is null

update #natrep set code = a.country from guest a where #natrep.no = a.no

if @langid = 0
	update #natrep set descript = a.descript  from countrycode a where #natrep.code = a.code 
else
	update #natrep set descript = a.descript1 from countrycode a where #natrep.code = a.code 

--select a.accnt,a.pccode,a.item,a.amount1,a.amount2 into #income 
--	from master_income a,#natrep b where a.accnt = b.accnt 
--
--update #natrep set 
--	guests = isnull((select sum(a.amount2) from #income a where #natrep.accnt = a.accnt and rtrim(a.pccode) is null 
--						  and a.item = 'I_GUESTS'),0)
--
--update #natrep set 
--	nts = isnull((select sum(a.amount2) from #income a where #natrep.accnt = a.accnt and charindex(rtrim(a.pccode),@rm_pccodes) > 0 
--					  and rtrim(a.item) is null),0)
--
--update #natrep set 
--	rm = isnull((select sum(a.amount1) from #income a where #natrep.accnt = a.accnt and charindex(rtrim(a.pccode),@rm_pccodes) > 0 
--					 and rtrim(a.item) is null),0)
--
--update #natrep set 
--	fb = isnull((select sum(a.amount1) from #income a,pccode b where #natrep.accnt = a.accnt and a.pccode = b.pccode 
--					 and b.deptno7 = 'fb' and rtrim(a.item) is null),0)
--
--update #natrep set 
--	ot = isnull((select sum(a.amount1) from #income a,pccode b where #natrep.accnt = a.accnt and a.pccode = b.pccode 
--					 and b.deptno7 in ('en','sp','ot') and rtrim(a.item) is null),0)

--update #natrep set ttl = rm + fb + ot

RET_P:
--select * from #natrep
select code,descript,sum(guests),sum(nts),sum(rm),sum(fb),sum(ot),sum(ttl) from #natrep 
	group by code,descript

return ;