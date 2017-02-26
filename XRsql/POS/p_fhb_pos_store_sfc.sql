create proc p_fhb_pos_store_sfc
	@stcode	char(3),
	@bdate	datetime,
	@edate	datetime
as
declare	 @cur_date datetime,
		 @stcode1	char(3),
		 @artcode	char(12)

select @cur_date = truedate from pos_st_sysdata
if @bdate is null or @bdate = '1900-1-1'
	select @bdate = @cur_date
if @edate is null or @edate = '1900-1-1'
	select @edate = @cur_date

begin 
create table #store_sfc
(
	stcode	char(3) null,
	stname	char(20) null,
	artcode	char(12) null,
	artname	char(40) null,
	unit	char(6) null,
	qcnumber	money null,			--期初数量
	qcamount	money null,			--期初金额
	zbnumber	money null,			--直拨数量
	zbamount	money null,			--直拨金额
	drnumber	money null,			--调入数量
	dramount	money null,			--调入金额
	dcnumber	money null,			--调出数量
	dcamount	money null,			--调出金额
	xsnumber	money null,			--销售数量
	xsamount	money null,			--销售金额
	tjnumber	money null,			--调价数量
	tjamount	money null,			--调价金额
	pdnumber	money null,			--盘盈/亏数量
	pdamount	money null,			--盘盈/亏数量
	qmnumber	money null,			--期末数量
	qmamount	money null			--期末金额
)

create table #sfc_temp
(
	stcode	char(3),
	artcode	char(12),
	number	money,
	amount	money
)
if @stcode = '' or @stcode is null
	insert #store_sfc (stcode,artcode) select distinct istcode,b.code from pos_st_documst a,pos_st_docudtl b where a.id = b.id and istcode <> ''
else
	insert #store_sfc (stcode,artcode) select distinct @stcode,b.code from pos_st_documst a,pos_st_docudtl b where a.id = b.id and (a.istcode = @stcode)  -- or a.ostcode = @stcode


--期初
update #store_sfc set qcnumber = isnull(b.number,0),qcamount = isnull(b.amount,0) from pos_st_documst a,pos_st_docudtl b where a.id = b.id and a.vdate = @bdate and a.vtype = '00' and a.istcode = #store_sfc.stcode and b.code = #store_sfc.artcode
--直拨
insert #sfc_temp select a.istcode,b.code,isnull(sum(b.number),0),isnull(sum(b.amount),0) from pos_st_documst a,pos_st_docudtl b where a.id = b.id and a.vdate >= @bdate and a.vdate <= @edate and a.vtype = '01' and exists (select 1 from #store_sfc where a.istcode = #store_sfc.stcode and b.code = #store_sfc.artcode) group by a.istcode,b.code
update #store_sfc set zbnumber = isnull(a.number,0),zbamount = isnull(a.amount,0) from #sfc_temp a where #store_sfc.stcode = a.stcode and #store_sfc.artcode = a.artcode
--调入
delete from #sfc_temp
insert #sfc_temp select a.istcode,b.code,isnull(sum(b.number),0),isnull(sum(b.amount),0) from pos_st_documst a,pos_st_docudtl b where a.id = b.id and a.vdate >= @bdate and a.vdate <= @edate and a.vtype = '03' and exists (select 1 from #store_sfc where a.istcode = #store_sfc.stcode and b.code = #store_sfc.artcode) group by a.istcode,b.code
update #store_sfc set drnumber = isnull(a.number,0),dramount = isnull(a.amount,0) from #sfc_temp a where #store_sfc.stcode = a.stcode and #store_sfc.artcode = a.artcode

--调出
delete from #sfc_temp
insert #sfc_temp select a.ostcode,b.code,isnull(sum(b.number),0),isnull(sum(b.amount),0) from pos_st_documst a,pos_st_docudtl b where a.id = b.id and a.vdate >= @bdate and a.vdate <= @edate and a.vtype = '03' and exists (select 1 from #store_sfc where a.ostcode = #store_sfc.stcode and b.code = #store_sfc.artcode) group by a.ostcode,b.code
update #store_sfc set dcnumber = isnull(a.number,0),dcamount = isnull(a.amount,0) from #sfc_temp a where #store_sfc.stcode = a.stcode and #store_sfc.artcode = a.artcode

--销售
delete from #sfc_temp
insert #sfc_temp select a.ostcode,b.code,isnull(sum(b.number),0),isnull(sum(b.amount),0) from pos_st_documst a,pos_st_docudtl b where a.id = b.id and a.vdate >= @bdate and a.vdate <= @edate and a.vtype = '02' and exists (select 1 from #store_sfc where a.ostcode = #store_sfc.stcode and b.code = #store_sfc.artcode) group by a.ostcode,b.code
update #store_sfc set xsnumber = isnull(a.number,0),xsamount = isnull(a.amount,0) from #sfc_temp a where #store_sfc.stcode = a.stcode and #store_sfc.artcode = a.artcode

--调价
delete from #sfc_temp
insert #sfc_temp select a.istcode,b.code,isnull(sum(b.number),0),isnull(sum(b.amount),0) from pos_st_documst a,pos_st_docudtl b where a.id = b.id and a.vdate >= @bdate and a.vdate <= @edate and a.vtype = '05' and exists (select 1 from #store_sfc where a.istcode = #store_sfc.stcode and b.code = #store_sfc.artcode) group by a.istcode,b.code
update #store_sfc set tjnumber = isnull(a.number,0),tjamount = isnull(a.amount,0) from #sfc_temp a where #store_sfc.stcode = a.stcode and #store_sfc.artcode = a.artcode

--盘点
delete from #sfc_temp
insert #sfc_temp select a.istcode,b.code,isnull(sum(b.number),0),isnull(sum(b.amount),0) from pos_st_documst a,pos_st_docudtl b where a.id = b.id and a.vdate >= @bdate and a.vdate <= @edate and a.vtype = '04' and exists (select 1 from #store_sfc where a.istcode = #store_sfc.stcode and b.code = #store_sfc.artcode) group by a.istcode,b.code
update #store_sfc set pdnumber = isnull(a.number,0),pdamount = isnull(a.amount,0) from #sfc_temp a where #store_sfc.stcode = a.stcode and #store_sfc.artcode = a.artcode

--期末


declare qm_cur cursor for select distinct stcode,artcode from #store_sfc
open qm_cur
fetch qm_cur into @stcode1,@artcode
while @@sqlstatus = 0 
begin 
	if exists(select 1 from pos_st_documst a,pos_st_docudtl b where a.id = b.id and a.istcode = @stcode1 and b.code = @artcode and a.vdate = dateadd(dd,1,@edate) and a.vtype = '00')	
		update #store_sfc set qmnumber = isnull(b.number,0),qmamount = isnull(b.amount,0) 
			from pos_st_documst a,pos_st_docudtl b 
			where a.id = b.id and a.vdate = dateadd(dd,1,@edate) and a.vtype = '00' and a.istcode = #store_sfc.stcode and b.code = #store_sfc.artcode and #store_sfc.stcode = @stcode1 and #store_sfc.artcode = @artcode
	else
		update #store_sfc set qmnumber = isnull(a.number,0),qmamount = isnull(a.amount,0) 
			from pos_store_stock a where #store_sfc.stcode = a.istcode and #store_sfc.artcode = a.code and #store_sfc.stcode = @stcode1 and #store_sfc.artcode = @artcode

	fetch qm_cur into @stcode1,@artcode
end
close qm_cur
deallocate cursor qm_cur

update #store_sfc set stname = a.descript from pos_store a where a.code = #store_sfc.stcode
update #store_sfc set artname = a.name,unit = a.unit from pos_st_article a where a.code = #store_sfc.artcode
select * from #store_sfc order by stcode,artcode
end;