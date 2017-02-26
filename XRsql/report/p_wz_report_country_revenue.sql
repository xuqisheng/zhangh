IF OBJECT_ID('p_wz_report_country_revenue') IS NOT NULL
    DROP PROCEDURE p_wz_report_country_revenue
;
create proc p_wz_report_country_revenue
		@date			datetime

as


--准备数据的临时表1
create table #tmp
(		code		char(3)		not null,
		rooms		money			default 0,
		revenue	money			default 0,
		prs		money			default 0,
		arr_rms	money			default 0,
		arr_prs	money			default 0
)
--准备数据的临时表2
create table #tmp1
(		code		char(3)		not null,
		rooms		money			default 0,
		revenue	money			default 0,
		prs		money			default 0,
		arr_rms	money			default 0,
		arr_prs	money			default 0
)

create table #woutput
(		code			char(3)		not null,   --country code
		d_rooms		money			default 0,
		d_revenue	money			default 0,
		d_prs			money			default 0,
		d_arr_rms	money			default 0,
		d_arr_prs	money			default 0,

		m_rooms		money			default 0,
		m_revenue	money			default 0,
		m_prs			money			default 0,
		m_arr_rms	money			default 0,
		m_arr_prs	money			default 0,

		y_rooms		money			default 0,
		y_revenue	money			default 0,
		y_prs			money			default 0,
		y_arr_rms	money			default 0,
		y_arr_prs	money			default 0
)


--1.准备当天的数据
insert #tmp(code,rooms,revenue,prs)
	select b.nation,a.i_days,a.rm,a.gstno	from ycus_xf a,guest b where a.haccnt = b.no and datediff(dd,a.date,@date) = 0
			and (a.accnt not like 'C%' or a.accnt not like 'A%') and b.nation <> ''

insert #tmp(code,arr_rms,arr_prs)
	select b.nation,a.i_days,a.gstno from ycus_xf a,guest b where a.haccnt = b.no and datediff(dd,a.date,@date) = 0
			and (a.accnt not like 'C%' or a.accnt not like 'A%')  and b.nation <> '' and t_arr = 'T'

insert #woutput(code,d_rooms,d_revenue,d_prs,d_arr_rms,d_arr_prs)
	select code,sum(rooms),sum(revenue),sum(prs),sum(arr_rms),sum(arr_prs) from #tmp group by code

--2.准备月的数据
delete #tmp

insert #tmp(code,rooms,revenue,prs)
	select b.nation,a.i_days,a.rm,a.gstno	from ycus_xf a,guest b where a.haccnt = b.no and datediff(mm,a.date,@date) = 0
			and (a.accnt not like 'C%' or a.accnt not like 'A%') and b.nation <> ''

insert #tmp(code,arr_rms,arr_prs)
	select b.nation,a.i_days,a.gstno from ycus_xf a,guest b where a.haccnt = b.no and datediff(mm,a.date,@date) = 0
			and (a.accnt not like 'C%' or a.accnt not like 'A%')  and b.nation <> '' and t_arr = 'T'

--补woutput没有的code
insert #woutput(code) select distinct #tmp.code from #tmp where #tmp.code not in (select code from #woutput)

insert #tmp1(code,rooms,revenue,prs,arr_rms,arr_prs)
	select code,sum(rooms),sum(revenue),sum(prs),sum(arr_rms),sum(arr_prs) from #tmp group by code

update #woutput set m_rooms = rooms ,m_revenue = revenue,m_prs = prs,m_arr_rms = arr_rms,m_arr_prs = arr_prs
	from #tmp1 where #woutput.code = #tmp1.code

--2.准备年的数据
delete #tmp
delete #tmp1

insert #tmp(code,rooms,revenue,prs)
	select b.nation,a.i_days,a.rm,a.gstno	from ycus_xf a,guest b where a.haccnt = b.no and datediff(yy,a.date,@date) = 0
			and (a.accnt not like 'C%' or a.accnt not like 'A%') and b.nation <> ''


insert #tmp(code,arr_rms,arr_prs)
	select b.nation,a.i_days,a.gstno from ycus_xf a,guest b where a.haccnt = b.no and datediff(yy,a.date,@date) = 0
			and (a.accnt not like 'C%'  or a.accnt not like 'A%')  and b.nation <> '' and t_arr = 'T'

--补woutput没有的code
insert #woutput(code) select distinct #tmp.code from #tmp where #tmp.code not in (select code from #woutput)

insert #tmp1(code,rooms,revenue,prs,arr_rms,arr_prs)
	select code,sum(rooms),sum(revenue),sum(prs),sum(arr_rms),sum(arr_prs) from #tmp group by code

update #woutput set y_rooms = rooms ,y_revenue = revenue,y_prs = prs,y_arr_rms = arr_rms,y_arr_prs = arr_prs
	from #tmp1 where #woutput.code = #tmp1.code

select code,d_rooms,d_revenue,d_prs,d_arr_rms,d_arr_prs,m_rooms,m_revenue,m_prs,m_arr_rms,m_arr_prs,
	y_rooms,y_revenue,y_prs,y_arr_rms,y_arr_prs from #woutput order by code

return 0
;
