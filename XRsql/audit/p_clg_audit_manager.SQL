IF OBJECT_ID('dbo.p_clg_audit_manager') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_audit_manager
;
create proc p_clg_audit_manager
as
declare
	@duringaudit	char(1),
	@isfstday		char(1),
	@isyfstday		char(1),
	@bdate			datetime,
	@bfdate			datetime,
	@badate			datetime,
	@reslt			money,
	@reslt1			money,
	@reslt2			money,
  	@cdate			char(6),     -- 040501
   @date_           datetime,
   @gtype          char(3),
	@type		char(5),
	@types	varchar(250)

select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
select @badate = dateadd(day, 1, @bdate)

--清除无效gtype
delete from manager_report where gtype<>'' and gtype not in (select code from gtype where halt='F')

if exists ( select 1 from manager_report where date = @bdate )
	update manager_report set amount_m = amount_m - amount,amount_y = amount_y - amount
update manager_report set amount = 0, date = @bfdate
update manager_report set date = rmsalerep_new.date from rmsalerep_new where gkey='t' and hall='{' and code='{{{'
select @cdate = convert(char(6), @bdate, 12)

declare c_gtype cursor for select code from gtype where halt='F'
declare c_type cursor for select type from typim where gtype = @gtype
open c_gtype
fetch c_gtype into @gtype
while @@sqlstatus=0
begin
----------------------------------------------------------
--参数处理 types _t1_t2_……
----------------------------------------------------------
	select @types = '_'
	open c_type
	fetch c_type into @type
	while @@sqlstatus=0
		begin
		select @types = @types + substring(@type+space(5),1,5) + '_'
		fetch c_type into @type
		end
	close c_type

-----------------------------------------------------------------------------------------
-- 客房总体指标
--除了预测的数据，都不能从rsv_index取数，因为第二天不能重建
-----------------------------------------------------------------------------------------
--ttl			总房数
select @reslt = isnull(sum(a.ttl),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='ttl' and gtype = @gtype

--ooo			维修房
select @reslt = isnull(sum(a.mnt),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='ooo' and gtype = @gtype

--oos			锁定房
select @reslt = isnull(sum(a.os),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='oos' and gtype = @gtype

--mnt         维护房总数
update manager_report set amount = (select   amount from manager_report where class='ooo' and gtype = @gtype)
+(select   amount from manager_report where class='oos' and gtype = @gtype) where class='mnt' and gtype = @gtype
--clean	干净房
select @reslt = isnull((select count(a.roomno) from rmsta_till a,typim b where charindex(a.sta,'RI')>0 and a.tag<>'P' and a.type=b.type and b.gtype = @gtype), 0)
update manager_report set amount = @reslt where class = 'clean' and gtype = @gtype
--dirty	脏房
select @reslt = isnull((select count(a.roomno) from rmsta_till a,typim b where charindex(a.sta,'DTOS')>0 and a.tag<>'P' and a.type=b.type and b.gtype = @gtype), 0)
update manager_report set amount = @reslt where class = 'dirty' and gtype = @gtype
--ttl_o
update manager_report set amount= (select isnull(amount,0) from manager_report where class='ttl' and gtype = @gtype)
 - (select isnull(amount,0) from manager_report where class='ooo' and gtype = @gtype) where class='ttl_o' and gtype = @gtype

--avl			可用房数(含os)
select @reslt = isnull(sum(a.avl),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='avl' and gtype = @gtype

--avlo         可用房(含oo，os)
update manager_report set amount = (select   amount from manager_report where class='ooo' and gtype = @gtype)
+(select   amount from manager_report where class='avl' and gtype = @gtype) where class='avlo' and gtype = @gtype

--sold			售房数
select @reslt = isnull(sum(a.soldf + a.soldg + a.soldc+ a.soldl),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='sold' and gtype = @gtype

--sold%			出租率(月的出租率应该放在最后计算。因为前面_m，_y还没有累加。)
update manager_report set amount  = 100*(select   amount from manager_report where class='sold' and gtype = @gtype)/(select   amount from audit_impdata where class='avl')
						where class = 'sold%' and gtype = @gtype and (select   amount from audit_impdata where class='avl')<>0
--       加床
select @reslt = isnull(sum(a.ext),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='ext_no' and gtype = @gtype

--vac			空房数
select @reslt = isnull(sum(a.vac),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='vac' and gtype = @gtype

--htl			自用房数
select @reslt = isnull((select count(distinct a.roomno) from master_till a, mktcode b,typim c
	where a.class='F' and a.sta='I' and datediff(dd,a.arr,@bdate)>=0 and datediff(dd,a.dep,@bdate)<0 and a.market=b.code and b.flag='HSE' and a.type=c.type and c.gtype = @gtype ), 0)
update manager_report set amount = @reslt where class='htl' and gtype = @gtype
--free			免费房
select @reslt = isnull((select count(distinct a.roomno) from master_till a, mktcode b,typim c
	where a.class='F' and a.sta='I' and datediff(dd,a.arr,@bdate)>=0 and datediff(dd,a.dep,@bdate)<0 and a.market=b.code and b.flag='COM' and a.type=c.type and c.gtype = @gtype ), 0)
update manager_report set amount = @reslt where class='free' and gtype = @gtype
--longstay		长包房

--OCC			2008-12-5取房数，不取房晚数
select @reslt = isnull((select count(distinct a.roomno) from master_till a, typim c
	where a.class='F' and a.sta='I' and datediff(dd,a.arr,@bdate)>=0 and datediff(dd,a.dep,@bdate)<0 and a.type=c.type and c.gtype = @gtype ), 0)
update manager_report set amount = @reslt where class='occ' and gtype = @gtype

--occ_ch			售房数不含免费自用
update manager_report set amount  = (select isnull(amount,0) from manager_report where class='occ' and gtype = @gtype)
 - (select isnull(amount,0) from manager_report where class='free' and gtype = @gtype) - (select isnull(amount,0) from manager_report where class='htl' and gtype = @gtype)
						where class = 'occ_ch' and gtype = @gtype
--occ_h			售房数不含自用
update manager_report set amount  = (select isnull(amount,0) from manager_report where class='occ' and gtype = @gtype)
 - (select isnull(amount,0) from manager_report where class='htl' and gtype = @gtype) where class = 'occ_h' and gtype = @gtype
--occ_c			售房数不含免费
update manager_report set amount  = (select isnull(amount,0) from manager_report where class='occ' and gtype = @gtype)
 - (select isnull(amount,0) from manager_report where class='free' and gtype = @gtype) where class = 'occ_c' and gtype = @gtype

--avl+h			可用房+自用房 --本来系统avl指标就不包括维修房，自用房
update manager_report set amount  = (select amount from manager_report where class='avl' and gtype = @gtype)
 + (select amount from manager_report where class='htl' and gtype = @gtype) where class = 'avl+h' and gtype = @gtype
--rmtosel   可卖房
update manager_report set amount = (select   amount from manager_report where class='ttl' and gtype = @gtype)
-(select   amount from manager_report where class='occ' and gtype = @gtype) where class='rmtosel' and gtype = @gtype
--rtosl_o  可卖房不含维修
update manager_report set amount = (select   amount from manager_report where class='rmtosel' and gtype = @gtype)
-(select   amount from manager_report where class='ooo' and gtype = @gtype) where class='rtosl_o' and gtype = @gtype

-----------------------------------------------------------------------------------------
--按市场码来统计出租数
-----------------------------------------------------------------------------------------
--bi

-----------------------------------------------------------------------------------------
--	客房销售 : 收入指标
-----------------------------------------------------------------------------------------
--back_income_rm		回头客房费
select @reslt = isnull(sum(a.xf_rm),0) from cus_xf a,guest b where a.sta = 'I' and accnt like 'F%' and a.haccnt = b.no and b.i_times > 0 and charindex('_'+a.type+'_',@types)>0
update manager_report set amount = @reslt where class='back_income_rm' and gtype = @gtype
--back_income_ot		回头客其他费
select @reslt = isnull(sum(a.xf_dtl - a.xf_rm),0) from cus_xf a,guest b where a.sta = 'I' and  accnt like 'F%' and a.haccnt = b.no and b.i_times > 0 and charindex('_'+a.type+'_',@types)>0
update manager_report set amount = @reslt where class='back_income_ot' and gtype = @gtype
--back_rmnum			回头客房数
select @reslt = isnull(sum(a.quantity),0) from rmuserate a,guest b,master c where b.no = c.haccnt and a.master = c.accnt and b.i_times > 0 and date = @bdate and charindex('_'+c.type+'_',@types)>0
update manager_report set amount = @reslt where class='back_rmnum' and gtype = @gtype
--back_gstno			回头客人数
select @reslt = isnull(sum(a.gstno*a.i_days),0) from cus_xf a,guest b where a.sta = 'I' and  b.no = a.haccnt and accnt like 'F%' and b.i_times > 0 and charindex('_'+a.type+'_',@types)>0
update manager_report set amount = @reslt where class='back_gstno' and gtype = @gtype
--income		总房费收入
select @reslt = isnull(sum(a.incomef + a.incomeg + a.incomec+ a.incomel),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt  where class='income' and gtype=@gtype
--select @reslt =isnull(sum(a.charge),0) from  gltemp a, pccode b
--	where a.pccode = b.pccode and b.deptno='10' and a.pccode < '9' and (a.crradjt in ('AD', '') or (a.crradjt in ('LT', 'LA') and a.tofrom= ''))
--select @reslt = sum(rincome) from mktsummaryrep where class='M'
--update manager_report set amount = @reslt where class='income'
--incomef	散客收入
select @reslt = isnull(sum(a.incomef),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt  where class='incomef' and gtype=@gtype
--incomeg	团队收入
select @reslt = isnull(sum(a.incomeg),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt  where class='incomeg' and gtype=@gtype
--incomec	会议收入
select @reslt = isnull(sum(a.incomec),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt  where class='incomec' and gtype=@gtype
--incomel	长包收入
select @reslt = isnull(sum(a.incomel),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt  where class='incomel' and gtype=@gtype

-- 早餐人数
update manager_report set amount = isnull((select sum(a.quantity) from package_detail a, package b, rmsta c
		where datediff(dd,@bdate,a.bdate)=0 and a.tag < '5' and a.code = b.code and b.type = '1' and a.roomno=c.roomno and charindex('_'+c.type+'_',@types)>0),0) where class='bf_gstno' and gtype=@gtype
--intotal	在店客人总收入
update manager_report set amount =isnull((select sum(b.charge) from gltemp b,rmsta c where b.bdate=@bdate and b.roomno=c.roomno and charindex('_'+c.type+'_',@types)>0),0)
      				where class='intotal' and gtype=@gtype
--fbrev	餐饮收入
update manager_report set amount =isnull((select sum(b.charge) from pccode a,gltemp b,rmsta c where a.pccode=b.pccode and a.deptno7='fb' and b.bdate=@bdate and b.roomno=c.roomno and charindex('_'+c.type+'_',@types)>0),0)
      				where class='fbrev' and gtype=@gtype
--otrev	其他收入
update manager_report set amount =isnull((select sum(b.charge) from pccode a,gltemp b,rmsta c where a.pccode=b.pccode and a.deptno7='ot' and b.bdate=@bdate and b.roomno=c.roomno and charindex('_'+c.type+'_',@types)>0),0)
      				where class='otrev' and gtype=@gtype
--total	酒店总收入
update manager_report set amount = (select   amount from manager_report where class='income' and gtype=@gtype)+(select   amount from manager_report where class='fbrev' and gtype=@gtype)+
                  (select   amount from manager_report where class='otrev' and gtype=@gtype)  where class='total' and gtype=@gtype
--inrev
select @reslt = isnull(sum(a.tincome),0) from mktsummaryrep_detail a,mktcode b where a.market=b.code and b.grp='IND' and a.gtype=@gtype
update manager_report set amount = @reslt where class='inrev' and gtype=@gtype
--memrev ?如何区分团体会议
select @reslt = isnull(sum(a.tincome),0) from mktsummaryrep_detail a,mktcode b where a.market=b.code and b.grp='GRP' and a.gtype=@gtype
update manager_report set amount = @reslt where class='memrev' and gtype=@gtype
select @reslt = isnull(sum(a.tincome),0) from mktsummaryrep_detail a,mktcode b where a.market=b.code and b.grp='MET' and a.gtype=@gtype
update manager_report set amount = @reslt where class='meetrev' and gtype=@gtype

-----------------------------------------------------------------------------------------
-- 客房销售 - 客房数量指标
-----------------------------------------------------------------------------------------
--soldf			散客售房数
select @reslt = isnull((select count(distinct a.roomno) from master_till a, typim c
	where a.class='F' and a.sta='I' and a.groupno='' and datediff(dd,a.arr,@bdate)>=0 and datediff(dd,a.dep,@bdate)<0 and a.type=c.type and c.gtype = @gtype ), 0)
update manager_report set amount = @reslt where class='soldf' and gtype = @gtype
--soldg			团队售房数
select @reslt = isnull((select count(distinct a.roomno) from master_till a, typim c
	where a.class='F' and a.sta='I' and a.groupno like 'G%' and datediff(dd,a.arr,@bdate)>=0 and datediff(dd,a.dep,@bdate)<0 and a.type=c.type and c.gtype = @gtype ), 0)
update manager_report set amount = @reslt where class='soldg' and gtype = @gtype
--soldc			会议售房数
select @reslt = isnull((select count(distinct a.roomno) from master_till a, typim c
	where a.class='F' and a.sta='I' and a.groupno like 'M%' and datediff(dd,a.arr,@bdate)>=0 and datediff(dd,a.dep,@bdate)<0 and a.type=c.type and c.gtype = @gtype ), 0)
update manager_report set amount = @reslt where class='soldc' and gtype = @gtype
--soldl			长包售房数
select @reslt = isnull(sum(a.soldl),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='soldl' and gtype = @gtype

--sold_ou		外宾房数
update manager_report set amount = isnull((select count(distinct a.roomno) from master_till a,guest b,countrycode c, mktcode d, typim e
       				where a.haccnt=b.no and a.class='F' and a.sta = 'I' and a.market=d.code and d.flag <> 'HSE' and b.nation = c.code and (c.flag1 is null or c.flag1 <> 'CN') and a.type=e.type and e.gtype = @gtype ), 0)
		 				where class='sold_ou' and gtype = @gtype
--sold_in		内宾房数
update manager_report set amount = isnull((select count(distinct a.roomno) from master_till a,guest b,countrycode c, mktcode d, typim e
       				where a.haccnt=b.no and a.class='F' and a.sta = 'I' and a.market=d.code and d.flag <> 'HSE' and b.nation = c.code and c.flag1 = 'CN' and a.type=e.type and e.gtype = @gtype ), 0)
		 				where class='sold_in' and gtype = @gtype

--t_soldf
select @reslt = isnull(count(distinct a.roomno),0) from master_till a,typim b where a.class='F' and a.groupno='' and a.sta='I' and a.type=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='t_soldf' and gtype = @gtype

--t_soldg
select @reslt = isnull(count(distinct a.roomno),0) from master_till a,typim b where a.class='F' and a.groupno<>'' and a.sta='I' and a.type=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='t_soldg' and gtype = @gtype

--sold_fit
update manager_report set amount= (select amount from manager_report where class='soldf' and gtype = @gtype)
 + (select amount from manager_report where class='soldl' and gtype = @gtype) where class='sold_fit' and gtype = @gtype

--sold_mem
update manager_report set amount= (select amount from manager_report where class='soldg' and gtype = @gtype)
 + (select amount from manager_report where class='soldc' and gtype = @gtype) where class='sold_mem' and gtype = @gtype

--sold_cus
select @reslt = isnull(count(distinct a.roomno),0) from master_till a,typim b where a.class='F' and a.cusno<>'' and a.sta='I' and a.type=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='sold_cus' and gtype = @gtype

--sold_agt
select @reslt = isnull(count(distinct a.roomno),0) from master_till a,typim b where a.class='F' and a.agent<>'' and a.sta='I' and a.type=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='sold_agt' and gtype = @gtype

--sold_src
select @reslt = isnull(count(distinct a.roomno),0) from master_till a,typim b where a.class='F' and a.source<>'' and a.sta='I' and a.type=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='sold_src' and gtype = @gtype

-----------------------------------------------------------------------------------------
-- 客房销售 - 客人数量指标
-----------------------------------------------------------------------------------------
--gst				总过夜人数
select @reslt = isnull(sum(a.gstf+a.gstg+a.gstc+a.gstl),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='gst' and gtype = @gtype
--gstf			散客过夜人数
select @reslt = isnull(sum(a.gstf),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='gstf' and gtype = @gtype
--gstg			团队过夜人数
select @reslt = isnull(sum(a.gstg),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='gstg' and gtype = @gtype
--gstc			会议过夜人数
select @reslt = isnull(sum(a.gstc),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='gstc' and gtype = @gtype
--gstl			长包过夜人数
select @reslt = isnull(sum(a.gstl),0) from rmsalerep_new a,typim b
						where a.gkey='t' and a.code=b.type and b.gtype = @gtype
update manager_report set amount = @reslt where class='gstl' and gtype = @gtype

--gst_fit
update manager_report set amount= (select amount from manager_report where class='gstf' and gtype = @gtype)
 + (select amount from manager_report where class='gstl' and gtype = @gtype) where class='gst_fit' and gtype = @gtype
--gst_mem
update manager_report set amount= (select amount from manager_report where class='gstg' and gtype = @gtype)
 + (select amount from manager_report where class='gstc' and gtype = @gtype) where class='gst_mem' and gtype = @gtype

--住店成人数不含自用
select @reslt=isnull(sum(a.gstno),0) from master_till a,mktcode b,typim c where a.sta = 'I' and a.class = 'F' and a.market=b.code and b.flag<>'HSE' and a.type=c.type and c.gtype=@gtype
update manager_report set amount = @reslt where class='adltih' and gtype = @gtype
--住店小孩数
select @reslt=isnull(sum(a.children),0) from master_till a,mktcode b,typim c where a.sta = 'I' and a.class = 'F' and a.market=b.code and b.flag<>'HSE' and a.type=c.type and c.gtype=@gtype
update manager_report set amount = @reslt where class='chldih' and gtype = @gtype
--gstih
update manager_report set amount= (select amount from manager_report where class='adltih' and gtype = @gtype)
 + (select amount from manager_report where class='chldih' and gtype = @gtype) where class='gstih' and gtype = @gtype
--VIP住店人数
select @reslt=isnull(sum(a.gstno),0) from master_till a,guest b,typim c where a.haccnt=b.no and b.vip<>'0' and a.sta = 'I' and a.class = 'F' and a.type=c.type and c.gtype=@gtype
update manager_report set amount = @reslt where class='vipih' and gtype = @gtype
--memih
select @reslt=isnull(count(1),0) from master_till a,typim b where a.cardno<>'' and a.sta = 'I' and a.class = 'F' and a.type=b.type and b.gtype=@gtype
update manager_report set amount = @reslt where class='memih' and gtype = @gtype
--birth
select @reslt=isnull(count(1),0) from master_till a,guest b,typim c where a.sta = 'I' and a.class = 'F' and a.haccnt=b.no and datepart(mm,b.birth)=datepart(mm,@bdate) and datepart(dd,b.birth)=datepart(dd,@bdate) and a.type=c.type and c.gtype=@gtype
update manager_report set amount = @reslt where class='birth' and gtype = @gtype

--ch_gstf		国内过夜散客人数
update manager_report set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c,typim d
	where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and rtrim(a.groupno) is null and b.code = c.nation and b.flag1 = 'CN' and a.type=d.type and d.gtype=@gtype),0 )
	where class='ch_gstf' and gtype = @gtype
--ch_gstg		国内过夜团队人数
update manager_report set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c,typim d
	where a.sta = 'I' and a.class in ('G','M') and a.haccnt= c.no and rtrim(a.groupno) is not null and b.code = c.nation and b.flag1= 'CN' and a.type=d.type and d.gtype=@gtype),0 )
	where class='ch_gstg' and gtype = @gtype
--fo_gstf		国外过夜散客人数
update manager_report set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c,typim d
	where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and rtrim(a.groupno) is null and b.code = c.nation and (b.flag1 is null or b.flag1 <> 'CN' and a.type=d.type and d.gtype=@gtype)),0 )
	where class='fo_gstf' and gtype = @gtype
--fo_gstg		国外过夜团队人数
update manager_report set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c,typim d
	where a.sta = 'I' and a.class in ('G','M') and a.haccnt= c.no and rtrim(a.groupno) is not null and b.code = c.nation and (b.flag1 is null or b.flag1 <> 'CN') and a.type=d.type and d.gtype=@gtype),0 )
	where class='fo_gstg' and gtype = @gtype

--in_gstno		境内过夜人数
update manager_report set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c,typim d
	where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and b.code = c.nation and b.flag1 = 'CN' and a.type=d.type and d.gtype=@gtype),0 )
	where class = 'in_gstno' and gtype = @gtype
--ou_gstno		境外过夜人数
update manager_report set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c,typim d
	where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and b.code = c.nation and (b.flag1 is null or b.flag1 <> 'CN') and a.type=d.type and d.gtype=@gtype),0 )
	where class = 'ou_gstno' and gtype = @gtype

--mffrs
update manager_report set amount = isnull((select sum(a.gstno) from cus_xf a,typim b where a.sta = 'I' and a.accnt like 'F%' and a.type=b.type and b.gtype=@gtype and
			rtrim(a.market) in (select rtrim(code) from mktcode where rtrim(flag) = 'COM' ) ),0 ) where rtrim(class) = 'mffrs' and gtype = @gtype
--zyfrs
update manager_report set amount = isnull((select sum(a.gstno) from cus_xf a,typim b where a.sta = 'I' and a.accnt like 'F%' and a.type=b.type and b.gtype=@gtype and
			rtrim(a.market) in (select rtrim(code) from mktcode where rtrim(flag) = 'HSE' ) ),0 ) where rtrim(class) = 'zyfrs' and gtype = @gtype

-----------------------------------------------------------------------------------------
--	其它指标
-----------------------------------------------------------------------------------------
--exp_arr	   预计抵达
select @reslt = isnull((select sum(a.quantity) from rsvsrc_last a,typim b where a.begin_=@bdate and a.begin_<>end_ and a.roomno='' and a.type=b.type and b.gtype=@gtype),0)
select @reslt = @reslt + (select count(distinct a.roomno) from rsvsrc_last a, master_last b, typim c
		where a.accnt=b.accnt and b.sta='R' and a.begin_=@bdate and a.begin_<>a.end_ and a.roomno<>'' and a.type=c.type and c.gtype=@gtype)
update manager_report set amount = @reslt	where class='exp_arr' and gtype = @gtype

--	act_arr		当日实际到达
select @reslt = isnull((select count(distinct a.roomno) from master_till a,typim b where a.class='F' and a.sta in ('I') and datediff(dd,a.arr,@bdate)=0 and a.type=b.type and b.gtype=@gtype), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a,typim c where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate and a.type=c.type and c.gtype=@gtype
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)
update manager_report set amount = @reslt where class = 'act_arr' and gtype = @gtype

--	sdp			当日预订到达
select @reslt = isnull((select count(distinct a.roomno) from master_till a,typim b
	where a.class='F' and a.sta in ('I','S','O') and a.bdate=@bdate and substring(a.extra,9,1)<>'1' and a.type=b.type and b.gtype=@gtype
		and a.resno like @cdate+'%'), 0)
update manager_report set amount = @reslt where class = 'sdp' and gtype = @gtype

--noshow		预订未到
-- select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta='N' and bdate=@bdate), 0)
select @reslt = isnull((select count(distinct a.roomno) from master a,typim b where a.class='F' and a.sta='N' and a.bdate=@bdate and a.roomno<>'' and a.type=b.type and b.gtype=@gtype), 0)
select @reslt = @reslt + isnull((select sum(a.rmnum) from master a,typim b where a.class='F' and a.sta='N' and a.bdate=@bdate and a.roomno='' and a.type=b.type and b.gtype=@gtype), 0)
update manager_report set amount= @reslt where class = 'noshow' and gtype = @gtype

--cancel		预订取消
select @reslt = isnull((select count(distinct a.roomno) from master_till a,typim b where a.class='F' and a.sta='X' and a.bdate=@bdate and a.roomno<>'' and a.type=b.type and b.gtype=@gtype), 0)
select @reslt = @reslt+isnull((select sum(a.rmnum) from master_till a,typim b where a.class='F' and a.sta='X' and a.bdate=@bdate and a.roomno='' and a.type=b.type and b.gtype=@gtype), 0)
update manager_report set amount = @reslt where class = 'cancel' and gtype = @gtype

--walkin		上门散客  -- 当日到达 !
select @reslt = isnull((select count(distinct a.roomno) from master_till a,typim b where a.class='F' and substring(a.extra,9,1)='1' and a.sta in ('I') and a.bdate=@bdate and a.type=b.type and b.gtype=@gtype), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a,typim c where a.class='F' and substring(a.extra,9,1)='1' and a.sta in ('S','O') and a.bdate=@bdate and a.type=c.type and c.gtype=@gtype
											and not exists(select 1 from master_last b where a.accnt=b.accnt)), 0)
update manager_report set amount = @reslt where class = 'walkin' and gtype = @gtype

--stay_ove  上日到店过夜
update manager_report set amount = isnull((select count(distinct a.roomno) from master_till a,typim b
						where a.class='F' and a.sta in ('I') and datediff(dd,a.bdate,@bdate) >= 1 and a.type=b.type and b.gtype=@gtype ),0 )
						where class='stay_ove' and gtype = @gtype

--rtngst    回头客
update manager_report set amount = isnull((select count(distinct a.roomno) from master_till a,guest b,typim c
						where a.class='F' and a.sta in ('I') and a.haccnt=b.no and b.i_times>0 and a.type=c.type and c.gtype=@gtype),0 )
						where class='rtngst' and gtype = @gtype
--exp_dep	预计离店
update manager_report set amount = isnull((select count(distinct a.roomno) from master_last a,typim b
						where a.class='F' and a.sta in ('I') and datediff(dd,a.dep,@bdate) = 0 and a.type=b.type and b.gtype=@gtype),0 )
						where class='exp_dep' and gtype = @gtype

--act_dep	当日实际离店
select @reslt = isnull((select count(distinct a.roomno) from master_till a,typim b
						where a.class='F' and a.sta in ('O','S') and a.bdate=@bdate and a.type=b.type and b.gtype=@gtype), 0)
update manager_report set amount = @reslt where class = 'act_dep' and gtype = @gtype

--extnd_rm	延住房间数
select @reslt=isnull((select count(distinct a.roomno) from master_till a,typim c
							where a.sta in ('I') and a.class='F' and a.type=c.type and c.gtype=@gtype and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)=0)),0)
update manager_report set amount = @reslt where class = 'extnd_rm' and gtype = @gtype

--e-co		提前离店
select @reslt=isnull((select count(distinct a.roomno) from master_till a,typim c
							where a.sta in ('S','O') and a.class='F' and a.type=c.type and c.gtype=@gtype and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)<>0)),0)
update manager_report set amount = @reslt 	where class='e-co' and gtype = @gtype
-----------------------------------------------------------------------------------------
--d_chkin	多人入住
select @reslt = count(distinct a.roomno) from master_till a,typim b
	where a.roomno in (select roomno from master_till where sta='I' and class='F' group by roomno having sum(gstno)>1) and a.type=b.type and b.gtype=@gtype
if @reslt is null select @reslt = 0
update manager_report set amount = @reslt where class = 'd_chkin' and gtype = @gtype
-----------------------------------------------------------------------------------------
--addbed		加床数
update manager_report set amount = isnull((select sum(a.addbed) from master_till a,typim b where a.sta in ('I') and a.type=b.type and b.gtype=@gtype),0 )
						where class='addbed' and gtype = @gtype
--crib		婴儿床数
update manager_report set amount = isnull((select sum(a.crib) from master_till a,typim b	where a.sta in ('I') and a.type=b.type and b.gtype=@gtype),0 )
						where class='crib' and gtype = @gtype

-----------------------------------------------------------------------------------------

--group		过夜团队数
update manager_report set amount = isnull((select count(1) from master_till a,typim c where  a.class in ('G','M') and a.type=c.type and c.gtype=@gtype
	and exists(select 1 from master_till b where b.groupno=a.accnt and b.sta='I' )),0 )
						where class='group' and gtype = @gtype
--dayuse		当日抵离
update manager_report set amount = isnull((select count(distinct a.roomno)  from master_till a,typim c where a.sta in ('O','S') and a.class in ('F')
	and a.bdate=@bdate and a.type=c.type and c.gtype=@gtype and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')),0 )
						where class='dayuse' and gtype = @gtype

--daybook		当日做的预定房数     当日预定当日到+当日预定未到
select @reslt = isnull((select count(distinct a.roomno) from master_till a,typim b
	where a.class='F' and a.sta in ('I','S','O') and a.bdate=@bdate and substring(extra,9,1)<>'1' and a.type=b.type and b.gtype=@gtype
		and a.resno like @cdate+'%'), 0)
update manager_report set amount =@reslt + isnull((select sum(a.quantity)  from rsvsrc_till a,master_till b,typim c
						where  a.accnt=b.accnt and b.sta='R' and datediff(dd,b.bdate,@bdate)=0 and a.type=c.type and c.gtype=@gtype ),0 )
						where class='daybook' and gtype = @gtype

--pre_booking	当天到(提前预订)
select @reslt = isnull((select count(distinct roomno) from master_till a,typim b where class='F' and sta in ('I','S','O') and bdate=@bdate and
							 accnt in (select accnt from master_last where class='F' and sta in ('R')) and a.type=b.type and b.gtype=@gtype), 0)
update manager_report set amount = @reslt where class = 'pre_booking' and gtype = @gtype

--cur_booking	当天到(当天预订)
select @reslt = isnull((select count(distinct roomno) from master_till a,typim b where class='F' and sta in ('I','S','O') and bdate=@bdate and
							 accnt not in (select accnt from master_last where class='F' and sta in ('R')) and a.type=b.type and b.gtype=@gtype), 0)
update manager_report set amount = @reslt where class = 'cur_booking' and gtype = @gtype
-----------------------------------------------------------------------------------------
--	manager report - clg
-----------------------------------------------------------------------------------------
--bed
update manager_report set amount =isnull((select sum(a.bedno)  from rmsta a,typim b where a.tag<>'P' and a.type=b.type and b.gtype=@gtype ),0 )
						where class='bed' and gtype = @gtype
--tarr_rms			本日到房数(本日还是夜审后的本日？？)	->act_arr



--tarr_ps			本日到人数
select @reslt = isnull((select sum(a.gstno) from master_till a,typim b where a.class='F' and a.sta in ('I') and a.bdate=@bdate and a.arr>=@bdate and a.type=b.type and b.gtype=@gtype), 0)
select @reslt = @reslt + isnull((select sum(a.gstno) from master_till a,typim c where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
						and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I') and a.type=c.type and c.gtype=@gtype), 0)
update manager_report set amount  = @reslt where class = 'tarr_ps' and gtype = @gtype

--deducted			确认预定房数（本日还是明日？？）
select @reslt = isnull((select count(distinct a.roomno) from master_till a,typim b where a.class='F' and a.sta in ('I') and a.bdate=@bdate and a.arr>=@bdate
    and a.restype in (select code from restype where definite='T') and substring(a.extra,9,1)<>'1' and a.type=b.type and b.gtype=@gtype), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a,typim c where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
    and a.restype in (select code from restype where definite='T') and substring(a.extra,9,1)<>'1' and a.type=c.type and c.gtype=@gtype
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)
--exec p_gds_reserve_rsv_index @bdate, '%', 'Definite Reservations', 'R', @reslt output
update manager_report set amount  = @reslt where class = 'deducted' and gtype = @gtype

--non_ded			非确认预定房数
select @reslt = isnull((select count(distinct a.roomno) from master_till a,typim b where a.class='F' and a.sta in ('I') and a.bdate=@bdate and a.arr>=@bdate
    and a.restype not in (select code from restype where definite='T') and substring(a.extra,9,1)<>'1' and a.type=b.type and b.gtype=@gtype), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a,typim c where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
    and a.restype not in (select code from restype where definite='T') and substring(a.extra,9,1)<>'1' and a.type=c.type and c.gtype=@gtype
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)
--exec p_gds_reserve_rsv_index @bdate, '%', 'Tentative Reservation', 'R', @reslt output
update manager_report set amount  = @reslt where class = 'non_ded' and gtype = @gtype

--wlk_rms			Walk-in房数->walkin


--wlk_ps			Walk-in人数

select @reslt = isnull((select sum(a.gstno) from master_till a,typim b where a.class='F' and substring(a.extra,9,1)='1'
			 and a.sta in ('I') and a.bdate=@bdate and a.type=b.type and b.gtype=@gtype), 0)
select @reslt = @reslt + isnull((select sum(a.gstno) from master_till a,typim c where a.class='F' and substring(a.extra,9,1)='1'
			 and a.sta in ('S','O') and a.bdate=@bdate and a.type=c.type and c.gtype=@gtype
											and not exists(select 1 from master_last b where a.accnt=b.accnt)), 0)
update manager_report set amount  = @reslt where class = 'wlk_ps' and gtype = @gtype

--ext_rms			延住房数->extnd_rm

--ext_ps			延住人数

select @reslt=isnull((select sum(a.gstno) from master_till a where a.sta in ('I') and a.class='F' and charindex('_'+a.type+'_',@types)>0
			 and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)=0)),0)
update manager_report set amount  = @reslt where class = 'ext_ps' and gtype = @gtype

--o_rms			离店房数->act_dep



--o_ps			离店人数

select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and charindex('_'+type+'_',@types)>0), 0)
update manager_report set amount  = @reslt where class = 'o_ps' and gtype = @gtype

--ed_rms			提前结账房数->e-co



--ed_ps			提前结账人数

select @reslt=isnull((select sum(a.gstno) from master_till a where a.sta in ('S','O') and a.class='F' and charindex('_'+a.type+'_',@types)>0
			 and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)<>0)),0)
update manager_report set amount  = @reslt where class = 'ed_ps' and gtype = @gtype

--o_soldf			今日离散客房数(应该是实际已离店的散客数，但统计指标里没有区分，而预计的分散客等)
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and groupno='' and charindex('_'+type+'_',@types)>0), 0)
update manager_report set amount = @reslt where class = 'o_soldf' and gtype = @gtype

--ot_gstf			今日离散客人数
select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and groupno='' and charindex('_'+type+'_',@types)>0), 0)
update manager_report set amount  = @reslt where class = 'ot_gstf' and gtype = @gtype

--o_soldg			今日离团队房数
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and groupno<>'' and charindex('_'+type+'_',@types)>0), 0)
update manager_report set amount = @reslt where class = 'o_soldg' and gtype = @gtype

--ot_gstg			今日离团队人数
select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and groupno<>'' and charindex('_'+type+'_',@types)>0), 0)
update manager_report set amount  = @reslt where class = 'ot_gstg' and gtype = @gtype

--o_frmem			今日离会员散客房数(应该是实际已离店的散客数，但统计指标里没有区分，而预计的分散客等)
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and cardno<>'' and sta in ('O','S') and bdate=@bdate and groupno='' and charindex('_'+type+'_',@types)>0), 0)
update manager_report set amount = @reslt where class = 'o_frmem' and gtype = @gtype

--o_fgmem			今日离会员散客人数
select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and cardno<>'' and sta in ('O','S') and bdate=@bdate and groupno='' and charindex('_'+type+'_',@types)>0), 0)
update manager_report set amount  = @reslt where class = 'o_fgmem' and gtype = @gtype

--o_rmem			今日离会员散客房数(应该是实际已离店的散客数，但统计指标里没有区分，而预计的分散客等)
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and cardno<>'' and sta in ('O','S') and bdate=@bdate and charindex('_'+type+'_',@types)>0), 0)
update manager_report set amount = @reslt where class = 'o_rmem' and gtype = @gtype

--o_gmem			今日离会员散客人数
select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and cardno<>'' and sta in ('O','S') and bdate=@bdate and charindex('_'+type+'_',@types)>0), 0)
update manager_report set amount  = @reslt where class = 'o_gmem' and gtype = @gtype

--ns_gst			noshow人数
select @reslt = isnull((select sum(gstno) from master where class='F' and sta='N' and bdate=@bdate and charindex('_'+type+'_',@types)>0), 0)
update manager_report set amount= @reslt where class = 'ns_gst' and gtype = @gtype

--tcxlt				本日取消的本日预定
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta='X' and bdate=@bdate and charindex('_'+type+'_',@types)>0
			 and datediff(dd,arr,@bdate)=0 and roomno<>''), 0)
select @reslt = @reslt+isnull((select sum(rmnum) from master_till where class='F' and sta='X' and bdate=@bdate and charindex('_'+type+'_',@types)>0
			 and datediff(dd,arr,@bdate)=0 and roomno=''), 0)
update manager_report set amount = @reslt where class = 'tcxlt' and gtype = @gtype

--cxl			    累计取消的本日预定
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta='X' and charindex('_'+type+'_',@types)>0 and datediff(dd,arr,@bdate)=0 and roomno<>''), 0)
select @reslt = @reslt+isnull((select sum(rmnum) from master_till where class='F' and sta='X' and charindex('_'+type+'_',@types)>0 and datediff(dd,arr,@bdate)=0 and roomno=''), 0)
update manager_report set amount = @reslt where class = 'cxl' and gtype = @gtype

--cxlmade		本日取消预定数--订单的数量->cancel



--rsvmade		本日新增预定->daybook



--rsv_nights	本日新增房晚--少了已到和团队预留？后面的方法同住会多算


select @reslt = isnull((select sum(rmnum*datediff(dd,arr,dep)) from master_till a
	where a.class='F' and a.sta in ('I','S','O') and a.bdate=@bdate and substring(extra,9,1)<>'1' and accnt=master
		 and charindex('_'+a.type+'_',@types)>0 and a.resno like @cdate+'%'), 0)
update manager_report set amount =@reslt + isnull((select sum(a.quantity*datediff(dd,a.begin_,a.end_))  from rsvsrc_till a,master_till b
						where  a.accnt=b.accnt and b.sta='R' and datediff(dd,b.bdate,@bdate)=0 and charindex('_'+a.type+'_',@types)>0 ),0 )
						where class='rsv_nights' and gtype = @gtype


--payment
update manager_report set amount =isnull((select sum(b.charge) from pccode a,gltemp b,rmsta c where a.pccode=b.pccode and a.argcode>'9' and b.bdate=@bdate and b.roomno=c.roomno and charindex('_'+c.type+'_',@types)>0),0)
      				where class='payment' and gtype=@gtype

--预测指标第二天默认不重建
if @duringaudit='T'
	begin
	--tm_arr			明日将到房数(含自用)
	exec p_gds_reserve_rsv_index @badate, @types, 'Arrival Rooms', 'R', @reslt output
	update manager_report set amount  = @reslt where class = 'tm_arr' and gtype = @gtype
	
	--tm_arr_ps			明日将到人数
	exec p_gds_reserve_rsv_index @badate, @types, 'Arrival Persons', 'R', @reslt output
	update manager_report set amount  = @reslt where class = 'tm_arr_ps' and gtype = @gtype
	
	--tm_dep			明日将到房数
	exec p_gds_reserve_rsv_index @badate, @types, 'Departure Rooms', 'R', @reslt output
	update manager_report set amount  = @reslt where class = 'tm_dep' and gtype = @gtype
	
	--tm_dep_ps			明日将到人数
	exec p_gds_reserve_rsv_index @badate, @types, 'Departure Persons', 'R', @reslt output
	update manager_report set amount  = @reslt where class = 'tm_dep_ps' and gtype = @gtype
	exec p_gds_reserve_rsv_index @badate, @types, 'Room to Rent', 'R', @reslt output
	update manager_report set amount=@reslt where class='avl_tm' and gtype = @gtype
	exec p_gds_reserve_rsv_index @badate, @types, 'Occupied Tonight-HU', 'R', @reslt output
	update manager_report set amount=@reslt where class='sold_tm' and gtype = @gtype
	--以下预测不含自用维修
	select @date_ = @badate,@reslt1 = 0,@reslt2=0
	while datediff(dd,@date_,@badate)>-7
	begin
		 exec p_gds_reserve_rsv_index @date_, @types, 'Occupied Tonight-HU', 'R', @reslt output
		 select @reslt1 = @reslt1 + @reslt
		 exec p_gds_reserve_rsv_index @date_, @types, 'Room to Rent', 'R', @reslt output
		 select @reslt2 = @reslt2 + @reslt
		 select @date_=dateadd(dd,1,@date_)
	end
	update manager_report set amount=@reslt1 where class='sold_w' and gtype = @gtype
	update manager_report set amount=@reslt2 where class='avl_w' and gtype = @gtype
	select @date_ = @badate,@reslt1 = 0,@reslt2=0
	while datediff(dd,@date_,@badate)>-31
	begin
		 exec p_gds_reserve_rsv_index @date_, @types, 'Occupied Tonight-HU', 'R', @reslt output
		 select @reslt1 = @reslt1 + @reslt
		 exec p_gds_reserve_rsv_index @date_, @types, 'Room to Rent', 'R', @reslt output
		 select @reslt2 = @reslt2 + @reslt
		 select @date_=dateadd(dd,1,@date_)
	end
	update manager_report set amount=isnull(@reslt1,0) where class='sold_m' and gtype = @gtype
	update manager_report set amount=isnull(@reslt2,0) where class='avl_m' and gtype = @gtype
	select @date_ = @badate,@reslt1 = 0,@reslt2=0
	while datediff(dd,@date_,@badate)>-365
	begin
		 exec p_gds_reserve_rsv_index @date_, @types, 'Occupied Tonight-HU', 'R', @reslt output
		 select @reslt1 = @reslt1 + @reslt
		 exec p_gds_reserve_rsv_index @date_, @types, 'Room to Rent', 'R', @reslt output
		 select @reslt2 = @reslt2 + @reslt
		 select @date_=dateadd(dd,1,@date_)
	end
	update manager_report set amount=isnull(@reslt1,0) where class='sold_y' and gtype = @gtype
	update manager_report set amount=isnull(@reslt2,0) where class='avl_y' and gtype = @gtype
	end


--餐饮就餐人数
--update audit_impdata set amount = isnull((select sum(guest) from pos_tmenu where pccode in ('210','260') and sta='3' ),0)
-- where class = 'pos_z'
--update audit_impdata set amount = isnull((select sum(guest) from pos_tmenu where pccode  not in ('210','260') and sta='3'),0)
-- where class = 'pos_x'



------------

fetch c_gtype into @gtype
end
close c_gtype

select @reslt =day99 from  jierep	where class='020'
update manager_report set amount =@reslt - isnull((select sum(amount) from manager_report where class='fbrev'),0) where class='fbrev' and gtype=''
select @reslt =day99 from  jierep	where class='030'
update manager_report set amount =@reslt - isnull((select sum(amount) from manager_report where class='otrev'),0) where class='otrev' and gtype=''
update manager_report set amount = (select amount from manager_report where class='fbrev' and gtype='')+(select amount from manager_report where class='otrev' and gtype='') where class='total' and gtype=''
select @reslt =sumcre from dairep where class='01010'
update manager_report set amount =@reslt - isnull((select sum(amount) from manager_report where class='payment'),0) where class='payment' and gtype=''

if @duringaudit<>'T'
	begin
   update manager_report set amount=a.amount from ymanager_report a where a.class=manager_report.class and a.gtype=manager_report.gtype
     and a.class in ('tm_arr','tm_arr_ps','tm_dep','tm_dep_ps','sold_tm','avl_tm','sold_w','avl_w','sold_m','avl_m','sold_y','avl_y') and a.date=@bdate
	end

exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday ='T'
	update manager_report set amount_m = 0	where charindex('%', class) = 0
if @isyfstday ='T'
	update manager_report set amount_m = 0,amount_y=0	where charindex('%', class) = 0

update manager_report set amount_m = amount_m  +  amount,amount_y = amount_y  +  amount
	where charindex('%', class) = 0
-----------------------------------------------------------------------------------------
--	%计算
-----------------------------------------------------------------------------------------

update manager_report set amount_m = 100*(select a.amount_m from manager_report a where a.class='sold' and a.gtype=manager_report.gtype)/(select amount_m from audit_impdata where class='avl')
						where class = 'sold%' and (select amount_m from audit_impdata where class='avl')<>0
update manager_report set amount_y = 100*(select a.amount_y from manager_report a where a.class='sold' and a.gtype=manager_report.gtype)/(select amount_y from audit_impdata where class='avl')
						where class = 'sold%' and (select amount_y from audit_impdata where class='avl')<>0

--income%
update manager_report set amount  = (select a.amount from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount from audit_impdata where class='occ')
						where class = 'income%' and (select amount from audit_impdata where class='occ')<>0
update manager_report set amount_m  = (select a.amount_m from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount_m from audit_impdata where class='occ')
						where class = 'income%' and (select amount_m from audit_impdata where class='occ')<>0
update manager_report set amount_y  = (select a.amount_y from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount_y from audit_impdata where class='occ')
						where class = 'income%' and (select amount_y from audit_impdata where class='occ')<>0

--income_h%
update manager_report set amount  = (select a.amount from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount from audit_impdata where class='occ_h')
						where class = 'income_h%' and (select amount from audit_impdata where class='occ_h')<>0
update manager_report set amount_m  = (select a.amount_m from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount_m from audit_impdata where class='occ_h')
						where class = 'income_h%' and (select amount_m from audit_impdata where class='occ_h')<>0
update manager_report set amount_y  = (select a.amount_y from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount_y from audit_impdata where class='occ_h')
						where class = 'income_h%' and (select amount_y from audit_impdata where class='occ_h')<>0

--income_c%
update manager_report set amount  = (select a.amount from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount from audit_impdata where class='occ_c')
						where class = 'income_c%' and (select amount from audit_impdata where class='occ_c')<>0
update manager_report set amount_m  = (select a.amount_m from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount_m from audit_impdata where class='occ_c')
						where class = 'income_c%' and (select amount_m from audit_impdata where class='occ_c')<>0
update manager_report set amount_y  = (select a.amount_y from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount_y from audit_impdata where class='occ_c')
						where class = 'income_c%' and (select amount_y from audit_impdata where class='occ_c')<>0

--income_ch%
update manager_report set amount  = (select a.amount from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount from audit_impdata where class='occ_ch')
						where class = 'income_ch%' and (select amount from audit_impdata where class='occ_ch')<>0
update manager_report set amount_m  = (select a.amount_m from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount_m from audit_impdata where class='occ_ch')
						where class = 'income_ch%' and (select amount_m from audit_impdata where class='occ_ch')<>0
update manager_report set amount_y  = (select a.amount_y from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount_y from audit_impdata where class='occ_ch')
						where class = 'income_ch%' and (select amount_y from audit_impdata where class='occ_ch')<>0

--total_per
update manager_report set amount  = (select a.amount from manager_report a where a.class='total' and a.gtype=manager_report.gtype) / (select amount from audit_impdata where class='gst')
						where class = 'total_per' and (select amount from audit_impdata where class='gst')<>0
update manager_report set amount_m  = (select a.amount_m from manager_report a where a.class='total' and a.gtype=manager_report.gtype) / (select amount_m from audit_impdata where class='gst')
						where class = 'total_per' and (select amount_m from audit_impdata where class='gst')<>0
update manager_report set amount_y  = (select a.amount_y from manager_report a where a.class='total' and a.gtype=manager_report.gtype) / (select amount_y from audit_impdata where class='gst')
						where class = 'total_per' and (select amount_y from audit_impdata where class='gst')<>0

--income_per
update manager_report set amount  = (select a.amount from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount from audit_impdata where class='gst')
						where class = 'income_per' and (select amount from audit_impdata where class='gst')<>0
update manager_report set amount_m  = (select a.amount_m from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount_m from audit_impdata where class='gst')
						where class = 'income_per' and (select amount_m from audit_impdata where class='gst')<>0
update manager_report set amount_y  = (select a.amount_y from manager_report a where a.class='income' and a.gtype=manager_report.gtype) / (select amount_y from audit_impdata where class='gst')
						where class = 'income_per' and (select amount_y from audit_impdata where class='gst')<>0

--beduse%
update manager_report set amount  = 100*(select a.amount from manager_report a where a.class='gst' and a.gtype=manager_report.gtype) / (select amount from audit_impdata where class='bed')
						where class = 'beduse%' and (select amount from audit_impdata where class='bed')<>0
update manager_report set amount_m  = 100*(select a.amount_m from manager_report a where a.class='gst' and a.gtype=manager_report.gtype) / (select amount_m from audit_impdata where class='bed')
						where class = 'beduse%' and (select amount_m from audit_impdata where class='bed')<>0
update manager_report set amount_y  = 100*(select a.amount_y from manager_report a where a.class='gst' and a.gtype=manager_report.gtype) / (select amount_y from audit_impdata where class='bed')
						where class = 'beduse%' and (select amount_y from audit_impdata where class='bed')<>0

--group_per
update manager_report set amount  = (select a.amount from manager_report a where a.class='gst_mem' and a.gtype=manager_report.gtype) / (select amount from audit_impdata where class='t_soldg')
						where class = 'group_per' and (select amount from audit_impdata where class='t_soldg')<>0
update manager_report set amount_m  = (select a.amount_m from manager_report a where a.class='gst_mem' and a.gtype=manager_report.gtype) / (select amount_m from audit_impdata where class='t_soldg')
						where class = 'group_per' and (select amount_m from audit_impdata where class='t_soldg')<>0
update manager_report set amount_y  = (select a.amount_y from manager_report a where a.class='gst_mem' and a.gtype=manager_report.gtype) / (select amount_y from audit_impdata where class='t_soldg')
						where class = 'group_per' and (select amount_y from audit_impdata where class='t_soldg')<>0

--memrev_per
update manager_report set amount  = ((select a.amount from manager_report a where a.class='memrev' and a.gtype=manager_report.gtype)+(select b.amount from manager_report b where b.class='meetrev' and b.gtype=manager_report.gtype)) / (select amount from audit_impdata where class='t_soldg')
						where class = 'memrev_per' and (select amount from audit_impdata where class='t_soldg')<>0
update manager_report set amount_m  = ((select a.amount_m from manager_report a where a.class='memrev' and a.gtype=manager_report.gtype)+(select b.amount_m from manager_report b where b.class='meetrev' and b.gtype=manager_report.gtype)) / (select amount_m from audit_impdata where class='t_soldg')
						where class = 'memrev_per' and (select amount_m from audit_impdata where class='t_soldg')<>0
update manager_report set amount_y  = ((select a.amount_y from manager_report a where a.class='memrev' and a.gtype=manager_report.gtype)+(select b.amount_y from manager_report b where b.class='meetrev' and b.gtype=manager_report.gtype)) / (select amount_y from audit_impdata where class='t_soldg')
						where class = 'memrev_per' and (select amount_y from audit_impdata where class='t_soldg')<>0

--incomeg_per
update manager_report set amount  = ((select a.amount from manager_report a where a.class='incomeg' and a.gtype=manager_report.gtype)+(select b.amount from manager_report b where b.class='incomec' and b.gtype=manager_report.gtype)) / (select amount from audit_impdata where class='t_soldg')
						where class = 'incomeg_per' and (select amount from audit_impdata where class='t_soldg')<>0
update manager_report set amount_m  = ((select a.amount_m from manager_report a where a.class='incomeg' and a.gtype=manager_report.gtype)+(select b.amount_m from manager_report b where b.class='incomec' and b.gtype=manager_report.gtype)) / (select amount_m from audit_impdata where class='t_soldg')
						where class = 'incomeg_per' and (select amount_m from audit_impdata where class='t_soldg')<>0
update manager_report set amount_y  = ((select a.amount_y from manager_report a where a.class='incomeg' and a.gtype=manager_report.gtype)+(select b.amount_y from manager_report b where b.class='incomec' and b.gtype=manager_report.gtype)) / (select amount_y from audit_impdata where class='t_soldg')
						where class = 'incomeg_per' and (select amount_y from audit_impdata where class='t_soldg')<>0

--occ%			出租率
update manager_report set amount  = 100*(select   a.amount from manager_report a where a.class='occ' and a.gtype=manager_report.gtype)/(select   amount from audit_impdata where class='ttl')
						where class = 'occ%' and (select   amount from audit_impdata where class='ttl')<>0
update manager_report set amount_m = 100*(select a.amount_m from manager_report a where a.class='occ' and a.gtype=manager_report.gtype)/(select amount_m from audit_impdata where class='ttl')
						where class = 'occ%' and (select amount_m from audit_impdata where class='ttl')<>0
update manager_report set amount_y = 100*(select a.amount_y from manager_report a where a.class='occ' and a.gtype=manager_report.gtype)/(select amount_y from audit_impdata where class='ttl')
						where class = 'occ%' and (select amount_y from audit_impdata where class='ttl')<>0

--occ_ch%			出租率不含免费自用房
update manager_report set amount  = 100*(select   a.amount from manager_report a where a.class='occ_ch' and a.gtype=manager_report.gtype)/(select   amount from audit_impdata where class='ttl')
						where class = 'occ_ch%' and (select   amount from audit_impdata where class='ttl')<>0
update manager_report set amount_m = 100*(select a.amount_m from manager_report a where a.class='occ_ch' and a.gtype=manager_report.gtype)/(select amount_m from audit_impdata where class='ttl')
						where class = 'occ_ch%' and (select amount_m from audit_impdata where class='ttl')<>0
update manager_report set amount_y = 100*(select a.amount_y from manager_report a where a.class='occ_ch' and a.gtype=manager_report.gtype)/(select amount_y from audit_impdata where class='ttl')
						where class = 'occ_ch%' and (select amount_y from audit_impdata where class='ttl')<>0

--occ_cho%			出租率不含免费自用维修房
update manager_report set amount  = 100*(select   a.amount from manager_report a where a.class='occ_ch' and a.gtype=manager_report.gtype)/(select   amount from audit_impdata where class='ttl_o')
						where class = 'occ_cho%' and (select   amount from audit_impdata where class='ttl_o')<>0
update manager_report set amount_m = 100*(select a.amount_m from manager_report a where a.class='occ_ch' and a.gtype=manager_report.gtype)/(select amount_m from audit_impdata where class='ttl_o')
						where class = 'occ_cho%' and (select amount_m from audit_impdata where class='ttl_o')<>0
update manager_report set amount_y = 100*(select a.amount_y from manager_report a where a.class='occ_ch' and a.gtype=manager_report.gtype)/(select amount_y from audit_impdata where class='ttl_o')
						where class = 'occ_cho%' and (select amount_y from audit_impdata where class='ttl_o')<>0

--occ_h%			出租率不含自用房
update manager_report set amount  = 100*(select   a.amount from manager_report a where a.class='occ_h' and a.gtype=manager_report.gtype)/(select   amount from audit_impdata where class='ttl')
						where class = 'occ_h%' and (select   amount from audit_impdata where class='ttl')<>0
update manager_report set amount_m = 100*(select a.amount_m from manager_report a where a.class='occ_h' and a.gtype=manager_report.gtype)/(select amount_m from audit_impdata where class='ttl')
						where class = 'occ_h%' and (select amount_m from audit_impdata where class='ttl')<>0
update manager_report set amount_y = 100*(select a.amount_y from manager_report a where a.class='occ_h' and a.gtype=manager_report.gtype)/(select amount_y from audit_impdata where class='ttl')
						where class = 'occ_h%' and (select amount_y from audit_impdata where class='ttl')<>0

--occ_c%			出租率不含免费房
update manager_report set amount  = 100*(select   a.amount from manager_report a where a.class='occ_c' and a.gtype=manager_report.gtype)/(select   amount from audit_impdata where class='ttl')
						where class = 'occ_c%' and (select   amount from audit_impdata where class='ttl')<>0
update manager_report set amount_m = 100*(select a.amount_m from manager_report a where a.class='occ_c' and a.gtype=manager_report.gtype)/(select amount_m from audit_impdata where class='ttl')
						where class = 'occ_c%' and (select amount_m from audit_impdata where class='ttl')<>0
update manager_report set amount_y = 100*(select a.amount_y from manager_report a where a.class='occ_c' and a.gtype=manager_report.gtype)/(select amount_y from audit_impdata where class='ttl')
						where class = 'occ_c%' and (select amount_y from audit_impdata where class='ttl')<>0

--occ_co%			出租率不含免费维修房
update manager_report set amount  = 100*(select   a.amount from manager_report a where a.class='occ_c' and a.gtype=manager_report.gtype)/(select   amount from audit_impdata where class='ttl_o')
						where class = 'occ_co%' and (select   amount from audit_impdata where class='ttl_o')<>0
update manager_report set amount_m = 100*(select a.amount_m from manager_report a where a.class='occ_c' and a.gtype=manager_report.gtype)/(select amount_m from audit_impdata where class='ttl_o')
						where class = 'occ_co%' and (select amount_m from audit_impdata where class='ttl_o')<>0
update manager_report set amount_y = 100*(select a.amount_y from manager_report a where a.class='occ_c' and a.gtype=manager_report.gtype)/(select amount_y from audit_impdata where class='ttl_o')
						where class = 'occ_co%' and (select amount_y from audit_impdata where class='ttl_o')<>0

--occ_ho%			出租率不含自用维修房
update manager_report set amount  = 100*(select   a.amount from manager_report a where a.class='occ_h' and a.gtype=manager_report.gtype)/(select   amount from audit_impdata where class='ttl_o')
						where class = 'occ_ho%' and (select   amount from audit_impdata where class='ttl_o')<>0
update manager_report set amount_m = 100*(select a.amount_m from manager_report a where a.class='occ_h' and a.gtype=manager_report.gtype)/(select amount_m from audit_impdata where class='ttl_o')
						where class = 'occ_ho%' and (select amount_m from audit_impdata where class='ttl_o')<>0
update manager_report set amount_y = 100*(select a.amount_y from manager_report a where a.class='occ_h' and a.gtype=manager_report.gtype)/(select amount_y from audit_impdata where class='ttl_o')
						where class = 'occ_ho%' and (select amount_y from audit_impdata where class='ttl_o')<>0

--occ_o%			出租率不含维修房
update manager_report set amount  = 100*(select   a.amount from manager_report a where a.class='occ' and a.gtype=manager_report.gtype)/(select   amount from audit_impdata where class='ttl_o')
						where class = 'occ_o%' and (select   amount from audit_impdata where class='ttl_o')<>0
update manager_report set amount_m = 100*(select a.amount_m from manager_report a where a.class='occ' and a.gtype=manager_report.gtype)/(select amount_m from audit_impdata where class='ttl_o')
						where class = 'occ_o%' and (select amount_m from audit_impdata where class='ttl_o')<>0
update manager_report set amount_y = 100*(select a.amount_y from manager_report a where a.class='occ' and a.gtype=manager_report.gtype)/(select amount_y from audit_impdata where class='ttl_o')
						where class = 'occ_o%' and (select amount_y from audit_impdata where class='ttl_o')<>0

--tm_sold%			明日出租率
update manager_report set amount  = 100*((select a.amount from manager_report a where a.class='sold_tm' and a.gtype=manager_report.gtype))/(select   amount from audit_impdata where class='avl_tm')
						where class = 'tm_sold%' and (select   amount from audit_impdata where class='avl_tm')<>0
update manager_report set amount_m  = 100*((select a.amount_m from manager_report a where a.class='sold_tm' and a.gtype=manager_report.gtype))/(select   amount_m from audit_impdata where class='avl_tm')
						where class = 'tm_sold%' and (select   amount_m from audit_impdata where class='avl_tm')<>0
update manager_report set amount_y  = 100*((select a.amount_y from manager_report a where a.class='sold_tm' and a.gtype=manager_report.gtype))/(select   amount_y from audit_impdata where class='avl_tm')
						where class = 'tm_sold%' and (select   amount_y from audit_impdata where class='avl_tm')<>0

--nw_sold%			下7天出租率<>7预定房晚数-7离店房晚数=((((sold+tm_arr-tm_dep)*2+n2arr-n2dep)*2+n3arr-n3dep)*2……
update manager_report set amount  = 100*(select a.amount from manager_report a where a.class='sold_w' and a.gtype=manager_report.gtype) / (select amount from audit_impdata where class='avl_w')
						where class = 'nw_sold%' and (select   amount from audit_impdata where class='avl_w')<>0
update manager_report set amount_m  = 100*(select a.amount_m from manager_report a where a.class='sold_w' and a.gtype=manager_report.gtype) / (select amount_m from audit_impdata where class='avl_w')
						where class = 'nw_sold%' and (select   amount_m from audit_impdata where class='avl_w')<>0
update manager_report set amount_y  = 100*(select a.amount_y from manager_report a where a.class='sold_w' and a.gtype=manager_report.gtype) / (select amount_y from audit_impdata where class='avl_w')
						where class = 'nw_sold%' and (select   amount_y from audit_impdata where class='avl_w')<>0

--nm_sold%			下7天出租率<>7预定房晚数-7离店房晚数=((((sold+tm_arr-tm_dep)*2+n2arr-n2dep)*2+n3arr-n3dep)*2……
update manager_report set amount  = 100*(select a.amount from manager_report a where a.class='sold_m' and a.gtype=manager_report.gtype) / (select amount from audit_impdata where class='avl_m')
						where class = 'nm_sold%' and (select   amount from audit_impdata where class='avl_m')<>0
update manager_report set amount_m  = 100*(select a.amount_m from manager_report a where a.class='sold_m' and a.gtype=manager_report.gtype) / (select amount_m from audit_impdata where class='avl_m')
						where class = 'nm_sold%' and (select   amount_m from audit_impdata where class='avl_m')<>0
update manager_report set amount_y  = 100*(select a.amount_y from manager_report a where a.class='sold_m' and a.gtype=manager_report.gtype) / (select amount_y from audit_impdata where class='avl_m')
						where class = 'nm_sold%' and (select   amount_y from audit_impdata where class='avl_m')<>0


--ny_sold%			下7天出租率<>7预定房晚数-7离店房晚数=((((sold+tm_arr-tm_dep)*2+n2arr-n2dep)*2+n3arr-n3dep)*2……
update manager_report set amount  = 100*(select a.amount from manager_report a where a.class='sold_y' and a.gtype=manager_report.gtype) / (select amount from audit_impdata where class='avl_y')
						where class = 'ny_sold%' and (select   amount from audit_impdata where class='avl_y')<>0
update manager_report set amount_m  = 100*(select a.amount_m from manager_report a where a.class='sold_y' and a.gtype=manager_report.gtype) / (select amount_m from audit_impdata where class='avl_y')
						where class = 'ny_sold%' and (select   amount_m from audit_impdata where class='avl_y')<>0
update manager_report set amount_y  = 100*(select a.amount_y from manager_report a where a.class='sold_y' and a.gtype=manager_report.gtype) / (select amount_y from audit_impdata where class='avl_y')
						where class = 'ny_sold%' and (select   amount_y from audit_impdata where class='avl_y')<>0


deallocate cursor c_gtype
deallocate cursor c_type
delete ymanager_report where date = @bdate
insert ymanager_report select * from manager_report
return 0
;
