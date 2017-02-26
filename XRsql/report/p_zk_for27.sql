if exists (select * from sysobjects where name ='p_zk_for27' and type ='P')
	drop proc p_zk_for27;
create proc p_zk_for27
	@begin			datetime,
	@end				datetime,
	@class			char(200),
	@type				char(200),
	@proom			char(1),				--T:含假房房类	F:不含假房
	@ratetype		char(1)				--N:净房价	P:含包价房价
	
as
	
---------------------------------------------
-- 统计和预测
---------------------------------------------
declare
	@cday				datetime,
	@tday				datetime,
	@ttrm				int

select @tday = bdate1 from sysdata
select @ttrm = count(1) from rmsta
--
create table #for27 ( cdate	char(20) not null,
							 toc  money default 0  not null,
							 ar   money  not null,
							 cr	money  not null,
							 com		money		 not null,
							 hu		money		 not null,
							 di   money  not null,
							 ni	money  not null,
							 dg		money		 not null,
							 ng   money  not null,
							 o	money  not null,
							 tr		money		 not null,
							 avr   money  not null,
							 dr	money  not null,
							 oor		money		 not null,
							 ac   money  not null,
							 ttr		int		not null,
							 sort		numeric		identity)

select @cday = @begin
while @cday <= @end
	begin
	insert #for27 select convert(char(10),@cday,11),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	if convert(char(10),@cday,11) = convert(char(10),dateadd(dd,-1,@tday),11)
		insert #for27 select 'History Subtotal',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	select @cday = dateadd(dd,1,@cday)
	end
insert #for27 select 'Forecast Subtotal',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
insert #for27 select 'Total',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

--统计部分
update #for27 set ttr = (select @ttrm - count(1) from rm_ooo b where b.sta='O' and convert(char(10),b.dbegin,11)<=#for27.cdate and convert(char(10),b.dend,11)>=#for27.cdate) 
update #for27 set toc = isnull((select count(distinct roomno+convert(char(8),date,11)) from ycus_xf where sta = 'I' and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate = convert(char(10),date,11)),0) from ycus_xf where cdate = convert(char(10),ycus_xf.date,11) and cdate < convert(char(10),@tday,11)
update #for27 set ar = isnull((select count(distinct roomno+convert(char(8),date,11)) from ycus_xf where sta = 'I' and convert(char(10),arr,11) = #for27.cdate and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate = convert(char(10),date,11)),0) from ycus_xf where cdate = convert(char(10),ycus_xf.date,11) and cdate < convert(char(10),@tday,11)
update #for27 set com = isnull((select count(distinct roomno+convert(char(8),date,11)) from ycus_xf where sta = 'I' and market in (select code from mktcode where flag = 'COM') and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate = convert(char(10),date,11)),0) from ycus_xf where cdate = convert(char(10),ycus_xf.date,11) and cdate < convert(char(10),@tday,11)
update #for27 set hu = isnull((select count(distinct roomno+convert(char(8),date,11)) from ycus_xf where sta = 'I' and market in (select code from mktcode where flag = 'HSE') and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate = convert(char(10),date,11)),0) from ycus_xf where cdate = convert(char(10),ycus_xf.date,11) and cdate < convert(char(10),@tday,11)
update #for27 set di = isnull((select count(distinct roomno+convert(char(8),date,11)) from ycus_xf where sta = 'I' and groupno = '' and restype in (select code from restype where definite='T') and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate = convert(char(10),date,11)),0) from ycus_xf where cdate = convert(char(10),ycus_xf.date,11) and cdate < convert(char(10),@tday,11)
update #for27 set ni = isnull((select count(distinct roomno+convert(char(8),date,11)) from ycus_xf where sta = 'I' and groupno = '' and restype in (select code from restype where definite='F') and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate = convert(char(10),date,11)),0) from ycus_xf where cdate = convert(char(10),ycus_xf.date,11) and cdate < convert(char(10),@tday,11)
update #for27 set dg = isnull((select count(distinct roomno+convert(char(8),date,11)) from ycus_xf where sta = 'I' and groupno <> '' and restype in (select code from restype where definite='T') and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate = convert(char(10),date,11)),0) from ycus_xf where cdate = convert(char(10),ycus_xf.date,11) and cdate < convert(char(10),@tday,11)
update #for27 set ng = isnull((select count(distinct roomno+convert(char(8),date,11)) from ycus_xf where sta = 'I' and groupno <> '' and restype in (select code from restype where definite='F') and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate = convert(char(10),date,11)),0) from ycus_xf where cdate = convert(char(10),ycus_xf.date,11) and cdate < convert(char(10),@tday,11)
update #for27 set o = toc / ttr *100
if @ratetype = 'N'
	update #for27 set tr = isnull((select sum(xf_rm - xf_rm_svc - xf_rm_bf - xf_rm_cms - xf_rm_lau - xf_rm_opak) from ycus_xf where sta = 'I' and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate = convert(char(10),date,11)),0) from ycus_xf where cdate = convert(char(10),ycus_xf.date,11) and cdate < convert(char(10),@tday,11)
else
	update #for27 set tr = isnull((select sum(xf_rm) from ycus_xf where sta = 'I' and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate = convert(char(10),date,11)),0) from ycus_xf where cdate = convert(char(10),ycus_xf.date,11) and cdate < convert(char(10),@tday,11)
update #for27 set avr = tr / toc where toc <>0
update #for27 set dr = isnull((select count(distinct roomno+convert(char(8),date,11)) from ycus_xf where sta = 'I' and convert(char(10),dep,11) = #for27.cdate and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate = convert(char(10),date,11)),0) from ycus_xf where cdate = convert(char(10),ycus_xf.date,11) and cdate < convert(char(10),@tday,11)
update #for27 set oor = isnull((select count(1) from rm_ooo b where b.sta='O' and convert(char(10),b.dbegin,11)<=#for27.cdate and convert(char(10),b.dend,11)>=#for27.cdate) ,0)
update #for27 set ac = isnull((select sum(gstno) + sum(children) from ycus_xf where sta = 'I' and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate = convert(char(10),date,11)),0) from ycus_xf where cdate = convert(char(10),ycus_xf.date,11) and cdate < convert(char(10),@tday,11)

--预测部分
update #for27 set toc = isnull((select count(distinct accnt) from rsvsrc_detail where type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate >= convert(char(10),arr,11) and #for27.cdate < convert(char(10),dep,11)),0) from rsvsrc_detail where cdate >= convert(char(10),@tday,11)
update #for27 set ar = isnull((select count(distinct accnt) from rsvsrc_detail where convert(char(10),arr,11) = #for27.cdate and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate >= convert(char(10),arr,11) and #for27.cdate < convert(char(10),dep,11)),0) from rsvsrc_detail where cdate >= convert(char(10),@tday,11)
update #for27 set com = isnull((select  count(distinct accnt) from rsvsrc_detail where market in (select code from mktcode where flag = 'COM') and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate >= convert(char(10),arr,11) and #for27.cdate < convert(char(10),dep,11)),0) from rsvsrc_detail where cdate >= convert(char(10),@tday,11)
update #for27 set hu = isnull((select  count(distinct accnt) from rsvsrc_detail where market in (select code from mktcode where flag = 'HSE') and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate >= convert(char(10),arr,11) and #for27.cdate < convert(char(10),dep,11)),0) from rsvsrc_detail where cdate >= convert(char(10),@tday,11)
update #for27 set di = isnull((select  count(distinct accnt) from rsvsrc_detail where accnt in (select accnt from master where groupno = '') and accnt in (select accnt from master where restype in (select code from restype where definite='T')) and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate >= convert(char(10),arr,11) and #for27.cdate < convert(char(10),dep,11)),0) from rsvsrc_detail where cdate >= convert(char(10),@tday,11)
update #for27 set ni = isnull((select  count(distinct accnt) from rsvsrc_detail where accnt in (select accnt from master where groupno = '') and accnt in (select accnt from master where restype in (select code from restype where definite='F')) and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate >= convert(char(10),arr,11) and #for27.cdate < convert(char(10),dep,11)),0) from rsvsrc_detail where cdate >= convert(char(10),@tday,11)
update #for27 set dg = isnull((select  count(distinct accnt) from rsvsrc_detail where accnt in (select accnt from master where groupno <> '') and accnt in (select accnt from master where restype in (select code from restype where definite='T')) and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate >= convert(char(10),arr,11) and #for27.cdate < convert(char(10),dep,11)),0) from rsvsrc_detail where cdate >= convert(char(10),@tday,11)
update #for27 set ng = isnull((select  count(distinct accnt) from rsvsrc_detail where accnt in (select accnt from master where groupno <> '') and accnt in (select accnt from master where restype in (select code from restype where definite='F')) and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate >= convert(char(10),arr,11) and #for27.cdate < convert(char(10),dep,11)),0) from rsvsrc_detail where cdate >= convert(char(10),@tday,11)
update #for27 set o = toc / ttr *100
if @ratetype = 'N'
	update #for27 set tr = isnull((select sum(qrate)/isnull(count(qrate),0)*#for27.toc from rsvsrc_detail where type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate >= convert(char(10),arr,11) and #for27.cdate < convert(char(10),dep,11)),0) from rsvsrc_detail where cdate >= convert(char(10),@tday,11)
else
	update #for27 set tr = isnull((select sum(rate)/isnull(count(rate),0)*#for27.toc from rsvsrc_detail where type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate >= convert(char(10),arr,11) and #for27.cdate < convert(char(10),dep,11)),0) from rsvsrc_detail where cdate >= convert(char(10),@tday,11)
update #for27 set avr = tr / toc where toc <>0
update #for27 set dr = isnull((select count(distinct accnt) from rsvsrc_detail where convert(char(10),dep,11) = #for27.cdate and type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate >= convert(char(10),arr,11) and #for27.cdate < convert(char(10),dep,11)),0) from rsvsrc_detail where cdate >= convert(char(10),@tday,11)
update #for27 set ac = isnull((select sum(gstno+child)/isnull(count(rate),0)*#for27.toc from rsvsrc_detail where type in (select type from typim where (charindex(rtrim(gtype)+',',@class)>0 or @class='%') and (charindex(rtrim(type)+',',@type)>0 or @type='%') and (tag='K' or @proom='T')) and #for27.cdate >= convert(char(10),arr,11) and #for27.cdate < convert(char(10),dep,11)),0) from rsvsrc_detail where cdate >= convert(char(10),@tday,11)

//--总计
update #for27 set toc = (select sum(toc) from #for27 where cdate < convert(char(10),@tday,11)) where rtrim(cdate) = 'History Subtotal'
update #for27 set ar = (select sum(ar) from #for27 where cdate < convert(char(10),@tday,11)) where rtrim(cdate) = 'History Subtotal'
update #for27 set com = (select sum(com) from #for27 where cdate < convert(char(10),@tday,11)) where rtrim(cdate) = 'History Subtotal'
update #for27 set hu = (select sum(hu) from #for27 where cdate < convert(char(10),@tday,11)) where rtrim(cdate) = 'History Subtotal'
update #for27 set di = (select sum(di) from #for27 where cdate < convert(char(10),@tday,11)) where rtrim(cdate) = 'History Subtotal'
update #for27 set ni = (select sum(ni) from #for27 where cdate < convert(char(10),@tday,11)) where rtrim(cdate) = 'History Subtotal'
update #for27 set dg = (select sum(dg) from #for27 where cdate < convert(char(10),@tday,11)) where rtrim(cdate) = 'History Subtotal'
update #for27 set ng = (select sum(ng) from #for27 where cdate < convert(char(10),@tday,11)) where rtrim(cdate) = 'History Subtotal'
update #for27 set o = (select sum(o) from #for27 where cdate < convert(char(10),@tday,11)) where rtrim(cdate) = 'History Subtotal'
update #for27 set tr = (select sum(tr) from #for27 where cdate < convert(char(10),@tday,11)) where rtrim(cdate) = 'History Subtotal'
update #for27 set dr = (select sum(dr) from #for27 where cdate < convert(char(10),@tday,11)) where rtrim(cdate) = 'History Subtotal'
update #for27 set oor = (select sum(oor) from #for27 where cdate < convert(char(10),@tday,11)) where rtrim(cdate) = 'History Subtotal'
update #for27 set ac = (select sum(ac) from #for27 where cdate < convert(char(10),@tday,11)) where rtrim(cdate) = 'History Subtotal'
update #for27 set avr = isnull((select tr/toc from #for27 where rtrim(cdate) = 'History Subtotal' and toc <> 0),0) where rtrim(cdate) = 'History Subtotal'

update #for27 set toc = (select sum(toc) from #for27 where cdate >= convert(char(10),@tday,11) and cdate <= '9') where rtrim(cdate) = 'Forecast Subtotal'
update #for27 set ar = (select sum(ar) from #for27 where cdate >= convert(char(10),@tday,11) and cdate <= '9') where rtrim(cdate) = 'Forecast Subtotal'
update #for27 set com = (select sum(com) from #for27 where cdate >= convert(char(10),@tday,11) and cdate <= '9') where rtrim(cdate) = 'Forecast Subtotal'
update #for27 set hu = (select sum(hu) from #for27 where cdate >= convert(char(10),@tday,11) and cdate <= '9') where rtrim(cdate) = 'Forecast Subtotal'
update #for27 set di = (select sum(di) from #for27 where cdate >= convert(char(10),@tday,11) and cdate <= '9') where rtrim(cdate) = 'Forecast Subtotal'
update #for27 set ni = (select sum(ni) from #for27 where cdate >= convert(char(10),@tday,11) and cdate <= '9') where rtrim(cdate) = 'Forecast Subtotal'
update #for27 set dg = (select sum(dg) from #for27 where cdate >= convert(char(10),@tday,11) and cdate <= '9') where rtrim(cdate) = 'Forecast Subtotal'
update #for27 set ng = (select sum(ng) from #for27 where cdate >= convert(char(10),@tday,11) and cdate <= '9') where rtrim(cdate) = 'Forecast Subtotal'
update #for27 set o = (select sum(o) from #for27 where cdate >= convert(char(10),@tday,11) and cdate <= '9') where rtrim(cdate) = 'Forecast Subtotal'
update #for27 set tr = (select sum(tr) from #for27 where cdate >= convert(char(10),@tday,11) and cdate <= '9') where rtrim(cdate) = 'Forecast Subtotal'
update #for27 set dr = (select sum(dr) from #for27 where cdate >= convert(char(10),@tday,11) and cdate <= '9') where rtrim(cdate) = 'Forecast Subtotal'
update #for27 set oor = (select sum(oor) from #for27 where cdate >= convert(char(10),@tday,11) and cdate <= '9') where rtrim(cdate) = 'Forecast Subtotal'
update #for27 set ac = (select sum(ac) from #for27 where cdate >= convert(char(10),@tday,11) and cdate <= '9') where rtrim(cdate) = 'Forecast Subtotal'
update #for27 set avr = isnull((select tr/toc from #for27 where rtrim(cdate) = 'Forecast Subtotal' and toc <> 0 ),0) where rtrim(cdate) = 'Forecast Subtotal'

update #for27 set toc = (select sum(toc) from #for27 where rtrim(cdate) in ('History Subtotal','Forecast Subtotal')) where rtrim(cdate) = 'Total'
update #for27 set ar = (select sum(ar) from #for27 where rtrim(cdate) in ('History Subtotal','Forecast Subtotal')) where rtrim(cdate) = 'Total'
update #for27 set com = (select sum(com) from #for27 where rtrim(cdate) in ('History Subtotal','Forecast Subtotal')) where rtrim(cdate) = 'Total'
update #for27 set hu = (select sum(hu) from #for27 where rtrim(cdate) in ('History Subtotal','Forecast Subtotal')) where rtrim(cdate) = 'Total'
update #for27 set di = (select sum(di) from #for27 where rtrim(cdate) in ('History Subtotal','Forecast Subtotal')) where rtrim(cdate) = 'Total'
update #for27 set ni = (select sum(ni) from #for27 where rtrim(cdate) in ('History Subtotal','Forecast Subtotal')) where rtrim(cdate) = 'Total'
update #for27 set dg = (select sum(dg) from #for27 where rtrim(cdate) in ('History Subtotal','Forecast Subtotal')) where rtrim(cdate) = 'Total'
update #for27 set ng = (select sum(ng) from #for27 where rtrim(cdate) in ('History Subtotal','Forecast Subtotal')) where rtrim(cdate) = 'Total'
update #for27 set o = (select sum(o) from #for27 where rtrim(cdate) in ('History Subtotal','Forecast Subtotal')) where rtrim(cdate) = 'Total'
update #for27 set tr = (select sum(tr) from #for27 where rtrim(cdate) in ('History Subtotal','Forecast Subtotal')) where rtrim(cdate) = 'Total'
update #for27 set dr = (select sum(dr) from #for27 where rtrim(cdate) in ('History Subtotal','Forecast Subtotal')) where rtrim(cdate) = 'Total'
update #for27 set oor = (select sum(oor) from #for27 where rtrim(cdate) in ('History Subtotal','Forecast Subtotal')) where rtrim(cdate) = 'Total'
update #for27 set ac = (select sum(ac) from #for27 where rtrim(cdate) in ('History Subtotal','Forecast Subtotal')) where rtrim(cdate) = 'Total'
update #for27 set avr = isnull((select tr/toc from #for27 where rtrim(cdate) = 'Total' and toc <> 0),0) where rtrim(cdate) = 'Total'






select * from #for27 order by sort


;




