/*统计客房主要营业指标为营业日报表准备数据，存入yaudit_impdata为做事后分析报表做准备*/
/*
  1.客房总
				ttl			总房数
				ooo			维修房
				os				锁定房
            mnt         维护房总数
				avl			可用房数
				sold			售房数
				sold%			出租率
				vac			空房数
				htl			自用房数
				free			免费房
				longstay		长包房  --???
  2.收入
				-----------------------
				income		总房费收入
				incomef		散客收入
				incomeg		团队收入
				incomec		会议收入
				incomel		长包收入
				svc			服务费收入
				incm_n		房费收入-含服务费
				incm_nn		净房费
            intotal		在店客人总收入
            total       酒店总收入
				back_income_rm	回头客房费收入
				back_income_ot	回头客其他收入
				back_rmnum		回头客房数
  3.售房数
				------------------------
				soldf			散客售房数
				soldg			团队售房数
				soldc			会议售房数
				soldl			长包售房数
				sold_ou		外宾房数
				sold_in		内宾房数
				
   4.人数
				------------------------
				gst			总过夜人数
				gstf			散客过夜人数
				gstg			团队过夜人数
				gstc			会议过夜人数
				gstl			长包过夜人数
				ch_gstf		国内过夜散客人数  
				ch_gstg		国内过夜团队人数  
				fo_gstf		国外过夜散客人数  
				fo_gstg		国外过夜团队人数  
				in_gstno		境内过夜人数
				ou_gstno		境外过夜人数
				mffrs			自用房人数
				zyfrs			免费房人数
    5.其它
				-------------------------
				exp_arr		预计抵达        
				act_arr		当日实际到达
				sdp			当日预订到达
				noshow		预订未到
				cancel		预订取消        
				walkin		上门散客
            stay_ove    上日到店过夜
            rtngst      回头客
				-------------------------
				exp_dep		预计离店        
				act_dep		当日实际离店
				extnd_rm		延住房间数
				e-co			提前离店       
				-------------------------
				d_chkin		双人房出租率
				addbed		加床数         
				crib			婴儿床数        
				bf_gst		包早餐人数
				bf_amt		包早餐金额
				all_days    总在店天数
				adv_day%		平均住店天数
				group			过夜团队数		 
				dayuse		当日抵离       
				pre_booking	当天到(提前预订)
				cur_booking	当天到(当天预订)
				
*/

IF OBJECT_ID('dbo.p_gl_audit_impdata') IS NOT NULL
    DROP PROCEDURE dbo.p_gl_audit_impdata
;
create proc p_gl_audit_impdata
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
    @date_           datetime

select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
select @badate = dateadd(day, 1, @bdate)
if exists ( select 1 from audit_impdata where date = @bdate )
	update audit_impdata set amount_m = amount_m - amount,amount_y = amount_y - amount
update audit_impdata set amount = 0, date = @bfdate
update audit_impdata set date = rmsalerep_new.date from rmsalerep_new where gkey='f' and hall='{' and code='{{{'
select @cdate = convert(char(6), @bdate, 12)

-----------------------------------------------------------------------------------------
-- 客房总体指标
--除了预测的数据，都不能从rsv_index取数，因为第二天不能重建
-----------------------------------------------------------------------------------------
--ttl			总房数
update audit_impdata set amount = isnull(ttl,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{'  and audit_impdata.class='ttl'
--ooo			维修房
select @reslt1=isnull(mnt,0) from rmsalerep_new where gkey='f' and hall='{' and code='{{{'
update audit_impdata set amount = @reslt1 where class='ooo'
--oos			锁定房
select @reslt2=isnull(os,0) from rmsalerep_new where gkey='f' and hall='{' and code='{{{'
update audit_impdata set amount = @reslt2 where class='oos'
--mnt         维护房总数
update audit_impdata set amount = (select   amount from audit_impdata where class='ooo')+(select   amount from audit_impdata where class='oos') where class='mnt'
--clean	干净房
select @reslt = isnull((select count(roomno) from rmsta_till where charindex(sta,'RI')>0 and tag<>'P'), 0)
update audit_impdata set amount = @reslt where class = 'clean'
--dirty	脏房
select @reslt = isnull((select count(roomno) from rmsta_till where charindex(sta,'DTOS')>0 and tag<>'P'), 0)
update audit_impdata set amount = @reslt where class = 'dirty'
--ttl_o
update audit_impdata set amount= (select isnull(amount,0) from audit_impdata where class='ttl') - (select isnull(amount,0) from audit_impdata where class='ooo') where class='ttl_o'
--avl			可用房数(含os)
update audit_impdata set amount = isnull(avl,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='avl'
--avlo         可用房(含oo，os)
update audit_impdata set amount = (select   amount from audit_impdata where class='ooo')+(select   amount from audit_impdata where class='avl') where class='avlo'

--sold			售房数
update audit_impdata set amount = isnull(soldf + soldg + soldc+ soldl,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='sold'
--sold%			出租率(月的出租率应该放在最后计算。因为前面_m，_y还没有累加。)
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='sold')/(select   amount from audit_impdata where class='avl')
						where class = 'sold%' and (select   amount from audit_impdata where class='avl')<>0
--       加床
update audit_impdata set amount = isnull(ext,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='ext_no'

--vac			空房数
update audit_impdata set amount = isnull(vac,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='vac'
--htl			自用房数
select @reslt = isnull((select count(distinct a.roomno) from master_till a, mktcode b
	where a.class='F' and a.sta='I' and a.market=b.code and b.flag='HSE' ), 0)
update audit_impdata set amount = @reslt where class='htl'
--free			免费房
update audit_impdata set amount = isnull(ent,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class = 'free'
--longstay		长包房

--OCC			=SOLD + HU
update audit_impdata set amount = isnull(soldf + soldg + soldc+ soldl,0)+(select isnull(amount,0) from audit_impdata where class='htl') from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='occ'
--occ_ch			售房数不含免费自用
update audit_impdata set amount  = (select isnull(amount,0) from audit_impdata where class='occ') - (select isnull(amount,0) from audit_impdata where class='free') - (select isnull(amount,0) from audit_impdata where class='htl')
						where class = 'occ_ch'
--occ_h			售房数不含自用
update audit_impdata set amount  = (select isnull(amount,0) from audit_impdata where class='occ') - (select isnull(amount,0) from audit_impdata where class='htl')
						where class = 'occ_h'
--occ_c			售房数不含免费
update audit_impdata set amount  = (select isnull(amount,0) from audit_impdata where class='occ') - (select isnull(amount,0) from audit_impdata where class='free')
						where class = 'occ_c'
--avl+h			可用房+自用房 --本来系统avl指标就不包括维修房，自用房
update audit_impdata set amount  = (select amount from audit_impdata where class='avl') + (select amount from audit_impdata where class='htl')
						where class = 'avl+h'
--rmtosel   可卖房
update audit_impdata set amount = (select   amount from audit_impdata where class='ttl')-(select   amount from audit_impdata where class='occ') where class='rmtosel'
--rtosl_o  可卖房不含维修
update audit_impdata set amount = (select   amount from audit_impdata where class='rmtosel')-(select   amount from audit_impdata where class='ooo') where class='rtosl_o'




-----------------------------------------------------------------------------------------
--按市场码来统计出租数
-----------------------------------------------------------------------------------------
--bi

-----------------------------------------------------------------------------------------
--	客房销售 : 收入指标
-----------------------------------------------------------------------------------------
--back_income_rm		回头客房费
select @reslt = isnull(sum(a.xf_rm),0) from cus_xf a,guest b where a.sta = 'I' and accnt like 'F%' and a.haccnt = b.no and b.i_times > 0
update audit_impdata set amount = @reslt where class='back_income_rm'
--back_income_ot		回头客其他费
select @reslt = isnull(sum(a.xf_dtl - a.xf_rm),0) from cus_xf a,guest b where a.sta = 'I' and  accnt like 'F%' and a.haccnt = b.no and b.i_times > 0
update audit_impdata set amount = @reslt where class='back_income_ot'
--back_rmnum			回头客房数
select @reslt = isnull(sum(a.quantity),0) from rmuserate a,guest b,master c where b.no = c.haccnt and a.master = c.accnt and b.i_times > 0 and date = @bdate //and c.sta = 'I'
update audit_impdata set amount = @reslt where class='back_rmnum'
--back_gstno			回头客人数
select @reslt = isnull(sum(a.gstno*a.i_days),0) from cus_xf a,guest b where a.sta = 'I' and  b.no = a.haccnt and accnt like 'F%' and b.i_times > 0
update audit_impdata set amount = @reslt where class='back_gstno'
--income		总房费收入
--select @reslt =isnull(sum(a.charge),0) from  gltemp a, pccode b
--	where a.pccode = b.pccode and b.deptno='10' and a.pccode < '9' and (a.crradjt in ('AD', '') or (a.crradjt in ('LT', 'LA') and a.tofrom= ''))
update audit_impdata set amount = isnull(incomef+incomeg+incomec+incomel,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='income'
--incomef	散客收入
update audit_impdata set amount = isnull(incomef,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='incomef'
--incomeg	团队收入
update audit_impdata set amount = isnull(incomeg,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='incomeg'
--incomec	会议收入
update audit_impdata set amount = isnull(incomec,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='incomec'
--incomel	长包收入
update audit_impdata set amount = isnull(incomel,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='incomel'
--svc	服务费收入
update audit_impdata set amount = isnull((select sum(a.day06) from jierep a where a.class='010'),0) where class='svc'
-- 早餐人数
update audit_impdata set amount = isnull((select sum(a.quantity) from package_detail a, package b
		where datediff(dd,@bdate,a.bdate)=0 and a.tag < '5' and a.code = b.code and b.type = '1'),0) where class='bf_gstno'
-- bf_amt 早餐金额
update audit_impdata set amount = isnull((select sum(a.quantity*b.amount) from package_detail a, package b
		where datediff(dd,@bdate,a.bdate)=0 and a.tag < '5' and a.code = b.code and b.type = '1'),0) where class='bf_amt'
--incm_n	  房费收入-含服务费
select @reslt = isnull((select sum(amount) from audit_impdata where class = 'income'), 0)
select @reslt = @reslt - isnull((select sum(amount) from audit_impdata where class = 'svc'), 0)
update audit_impdata set amount = @reslt where class='incm_n'
--incm_nn	净房费
select @reslt = @reslt - isnull((select sum(amount) from audit_impdata where class = 'bf_amt'), 0)
update audit_impdata set amount = @reslt where class='incm_nn'
--intotal	在店客人总收入
update audit_impdata set amount =isnull((select sum(b.charge) from gltemp b where b.bdate=@bdate),0)
      				where class='intotal'
--fbrev	餐饮收入
select @reslt =isnull(day99,0) from  jierep	where class='020'
update audit_impdata set amount =@reslt where class='fbrev'
--otrev	其他收入
select @reslt =isnull(day99,0) from  jierep	where class='030'
update audit_impdata set amount =@reslt where class='otrev'
--total	酒店总收入
update audit_impdata set amount = (select   amount from audit_impdata where class='income')+(select   amount from audit_impdata where class='fbrev')+
                  (select   amount from audit_impdata where class='otrev')  where class='total'
--select @reslt = sum(tincome) from mktsummaryrep where class='M'
--update audit_impdata set amount = @reslt where class='total'
--fbgstno 用餐人数
update audit_impdata set amount = isnull((select sum(feed) from deptjie where code = '99A'  AND empno ='{{{' and  shift ='9'  and pccode like '3%' ),0)
 where class = 'fbgstno'
--inrev
--select @reslt = sum(tincome) from mktsummaryrep where class='M' and grp='IND'
select @reslt = isnull(sum(tincome),0) from mktsummaryrep where class='M' and grp='IND'
update audit_impdata set amount = @reslt where class='inrev'
--memrev ?如何区分团体会议
--select @reslt = sum(tincome) from mktsummaryrep where class='M' and grp<>'IND'
select @reslt = isnull(sum(tincome),0) from mktsummaryrep where class='M' and grp='GRP'
update audit_impdata set amount = @reslt where class='memrev'
select @reslt = isnull(sum(tincome),0) from mktsummaryrep where class='M' and grp='MET'
update audit_impdata set amount = @reslt where class='meetrev'

-----------------------------------------------------------------------------------------
-- 客房销售 - 客房数量指标
-----------------------------------------------------------------------------------------
--soldf			散客售房数
update audit_impdata set amount = isnull(soldf,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='soldf'
--soldg			团队售房数
update audit_impdata set amount = isnull(soldg,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='soldg'
--soldc			会议售房数
update audit_impdata set amount = isnull(soldc,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='soldc'
--soldl			长包售房数
update audit_impdata set amount = isnull(soldl,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='soldl'
--sold_ou		外宾房数
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_till a,guest b,countrycode c, mktcode d
       				where a.haccnt=b.no and a.class='F' and a.sta = 'I' and a.market=d.code and d.flag <> 'HSE' and b.nation = c.code and (c.flag1 is null or c.flag1 <> 'CN')), 0)
		 				where class='sold_ou'
--sold_in		内宾房数
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_till a,guest b,countrycode c, mktcode d
       				where a.haccnt=b.no and a.class='F' and a.sta = 'I' and a.market=d.code and d.flag <> 'HSE' and b.nation = c.code and c.flag1 = 'CN'), 0)
		 				where class='sold_in'

--t_soldf
select @reslt = isnull(count(distinct roomno),0) from master_till where class='F' and groupno='' and sta='I'
update audit_impdata set amount = @reslt where class='t_soldf'

--t_soldg
select @reslt = isnull(count(distinct roomno),0) from master_till where class='F' and groupno<>'' and sta='I'
update audit_impdata set amount = @reslt where class='t_soldg'

--sold_fit
update audit_impdata set amount= (select amount from audit_impdata where class='soldf') + (select amount from audit_impdata where class='soldl') where class='sold_fit'

--sold_mem
update audit_impdata set amount= (select amount from audit_impdata where class='soldg') + (select amount from audit_impdata where class='soldc') where class='sold_mem'

--sold_cus
select @reslt = isnull(count(distinct roomno),0) from master_till where class='F' and cusno<>'' and sta='I'
update audit_impdata set amount = @reslt where class='sold_cus'

--sold_agt
select @reslt = isnull(count(distinct roomno),0) from master_till where class='F' and agent<>'' and sta='I'
update audit_impdata set amount = @reslt where class='sold_agt'

--sold_src
select @reslt = isnull(count(distinct roomno),0) from master_till where class='F' and source<>'' and sta='I'
update audit_impdata set amount = @reslt where class='sold_src'

--sold_bf                门市散客促销 010010
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('RAC','RAD','PRO')),0)
update audit_impdata set amount = @reslt where class = 'sold_bf'


--sold_lf                公司散客 010011
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('NOC','COC','COR','KEY','MAJ','NON')),0)
update audit_impdata set amount = @reslt where class = 'sold_lf'

--sold_bg                政府使馆散客 010012
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('GVC','GVP','GVD','GVT','EMB')),0)
update audit_impdata set amount = @reslt where class = 'sold_bg'

--sold_lg                订房中心 010013
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('CTI','BTG','BJG')),0)
update audit_impdata set amount = @reslt where class = 'sold_lg'

--sold_gd                 GDS 010014
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('GDS')),0)
update audit_impdata set amount = @reslt where class = 'sold_gd'

--sold_sc                 旅行社散客 010015
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('WHO')),0)
update audit_impdata set amount = @reslt where class = 'sold_sc'

--sold_hw                 网络订房 010016
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('WEB')),0)
update audit_impdata set amount = @reslt where class = 'sold_hw'

--sold_ls                 长包房/办公 010017
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('LTR','LTO')),0)
update audit_impdata set amount = @reslt where class = 'sold_ls'


--sold_io                 其他散客 010018
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('MEM','HTL','MGR','AIR','INI','PER')),0)
update audit_impdata set amount = @reslt where class = 'sold_io'

--sold_be                 公司会议团 010019
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('EXH','GPM','GPC')),0)
update audit_impdata set amount = @reslt where class = 'sold_be'

--sold_se                 系列团 010021
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('GPS')),0)
update audit_impdata set amount = @reslt where class = 'sold_se'

--sold_ot                 零散团 010022
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('GPO','GPD')),0)
update audit_impdata set amount = @reslt where class = 'sold_ot'

--sold_go                团队其他 010023
select @reslt = isnull((select sum(rquan) from ymktsummaryrep where date = @bdate and class ='M' and code in ('GPE','GPA','GPL','GPG','GPB','GPJ','GPH')),0)
update audit_impdata set amount = @reslt where class = 'sold_go'


-----------------------------------------------------------------------------------------
-- 客房销售 - 客人数量指标
-----------------------------------------------------------------------------------------
--gst				总过夜人数
update audit_impdata set amount = isnull(gstf + gstg + gstc + gstl,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gst'
--gstf			散客过夜人数
update audit_impdata set amount = isnull(gstf,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gstf'
--gstg			团队过夜人数
update audit_impdata set amount = isnull(gstg,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gstg'
--gstc			会议过夜人数
update audit_impdata set amount = isnull(gstc,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gstc'
--gstl			长包过夜人数
update audit_impdata set amount = isnull(gstl,0) from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gstl'

--gst_fit
update audit_impdata set amount= (select amount from audit_impdata where class='gstf') + (select amount from audit_impdata where class='gstl') where class='gst_fit'
--gst_mem
update audit_impdata set amount= (select amount from audit_impdata where class='gstg') + (select amount from audit_impdata where class='gstc') where class='gst_mem'

--住店成人数不含自用
select @reslt=isnull(sum(a.gstno),0) from master_till a,mktcode b where a.sta = 'I' and a.class = 'F' and a.market=b.code and b.flag<>'HSE'
update audit_impdata set amount = @reslt where class='adltih'
--住店小孩数
select @reslt=isnull(sum(a.children),0) from master_till a,mktcode b where a.sta = 'I' and a.class = 'F' and a.market=b.code and b.flag<>'HSE'
update audit_impdata set amount = @reslt where class='chldih'
--gstih
update audit_impdata set amount= (select amount from audit_impdata where class='adltih') + (select amount from audit_impdata where class='chldih') where class='gstih'
--VIP住店人数
select @reslt=isnull(sum(a.gstno),0) from master_till a,guest b where a.haccnt=b.no and b.vip<>'0' and a.sta = 'I' and a.class = 'F'
update audit_impdata set amount = @reslt where class='vipih'
--memih
select @reslt=isnull(count(1),0) from master_till where cardno<>'' and sta = 'I' and class = 'F'
update audit_impdata set amount = @reslt where class='memih'
--birth
select @reslt=isnull(count(1),0) from master_till a,guest b where a.sta = 'I' and a.class = 'F' and a.haccnt=b.no and datepart(mm,b.birth)=datepart(mm,@bdate) and datepart(dd,b.birth)=datepart(dd,@bdate)
update audit_impdata set amount = @reslt where class='birth'

--ch_gstf		国内过夜散客人数
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c
						where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and rtrim(a.groupno) is null and b.code = c.nation and b.flag1 = 'CN'),0 )
						where class='ch_gstf'
--ch_gstg		国内过夜团队人数
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c
						where a.sta = 'I' and a.class in ('G','M') and a.haccnt= c.no and rtrim(a.groupno) is not null and b.code = c.nation and b.flag1= 'CN'),0 )
  						where class='ch_gstg'
--fo_gstf		国外过夜散客人数
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c
						where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and rtrim(a.groupno) is null and b.code = c.nation and (b.flag1 is null or b.flag1 <> 'CN')),0 )
						where class='fo_gstf'
--fo_gstg		国外过夜团队人数
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c
						where a.sta = 'I' and a.class in ('G','M') and a.haccnt= c.no and rtrim(a.groupno) is not null and b.code = c.nation and (b.flag1 is null or b.flag1 <> 'CN')),0 )
						where class='fo_gstg'

--in_gstno		境内过夜人数
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c
			where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and b.code = c.nation and b.flag1 = 'CN'),0 ) where class = 'in_gstno'
--ou_gstno		境外过夜人数
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,countrycode b,guest c
			where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and b.code = c.nation and (b.flag1 is null or b.flag1 <> 'CN')),0 ) where class = 'ou_gstno'

--mffrs
update audit_impdata set amount = isnull((select sum(gstno) from cus_xf where sta = 'I' and accnt like 'F%' and
			rtrim(market) in (select rtrim(code) from mktcode where rtrim(flag) = 'COM' ) ),0 ) where rtrim(class) = 'mffrs'
--zyfrs
update audit_impdata set amount = isnull((select sum(gstno) from cus_xf where sta = 'I' and accnt like 'F%' and
			rtrim(market) in (select rtrim(code) from mktcode where rtrim(flag) = 'HSE' ) ),0 ) where rtrim(class) = 'zyfrs'

-----------------------------------------------------------------------------------------
--	其它指标
-----------------------------------------------------------------------------------------
--exp_arr	   预计抵达
select @reslt = isnull((select sum(quantity) from rsvsrc_last where begin_=@bdate and begin_<>end_ and roomno=''),0)
select @reslt = @reslt + (select count(distinct a.roomno) from rsvsrc_last a, master_last b
		where a.accnt=b.accnt and b.sta='R' and a.begin_=@bdate and a.begin_<>a.end_ and a.roomno<>'')
update audit_impdata set amount = @reslt	where class='exp_arr'

--	act_arr		当日实际到达
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta in ('I') and bdate=@bdate and arr>=@bdate), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)
update audit_impdata set amount = @reslt where class = 'act_arr'

--	sdp			当日预订到达
select @reslt = isnull((select count(distinct a.roomno) from master_till a
	where a.class='F' and a.sta in ('I','S','O') and a.bdate=@bdate and substring(extra,9,1)<>'1'
		and a.resno like @cdate+'%'), 0)
update audit_impdata set amount = @reslt where class = 'sdp'

--noshow		预订未到
-- select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta='N' and bdate=@bdate), 0)
select @reslt = isnull((select count(distinct roomno) from master where class='F' and sta='N' and bdate=@bdate and roomno<>''), 0)
select @reslt = @reslt + isnull((select sum(rmnum) from master where class='F' and sta='N' and bdate=@bdate and roomno=''), 0)
update audit_impdata set amount= @reslt where class = 'noshow'

--cancel		预订取消
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta='X' and bdate=@bdate and roomno<>''), 0)
select @reslt = @reslt+isnull((select sum(rmnum) from master_till where class='F' and sta='X' and bdate=@bdate and roomno=''), 0)
update audit_impdata set amount = @reslt where class = 'cancel'

--walkin		上门散客  -- 当日到达 !
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and substring(extra,9,1)='1' and sta in ('I') and bdate=@bdate), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and substring(extra,9,1)='1' and a.sta in ('S','O') and a.bdate=@bdate
											and not exists(select 1 from master_last b where a.accnt=b.accnt)), 0)
update audit_impdata set amount = @reslt where class = 'walkin'

--stay_ove  上日到店过夜
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_till a
						where a.class='F' and a.sta in ('I') and datediff(dd,a.bdate,@bdate) >= 1 ),0 )
						where class='stay_ove'

--rtngst    回头客
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_till a,guest b
						where a.class='F' and a.sta in ('I') and a.haccnt=b.no and b.i_times>0),0 )
						where class='rtngst'
--exp_dep	预计离店
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_last a
						where a.class='F' and a.sta in ('I') and datediff(dd,a.dep,@bdate) = 0),0 )
						where class='exp_dep'

--act_dep	当日实际离店
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate), 0)
update audit_impdata set amount = @reslt where class = 'act_dep'

--extnd_rm	延住房间数
select @reslt=isnull((select count(distinct a.roomno) from master_till a
							where a.sta in ('I') and a.class='F' and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)=0)),0)
update audit_impdata set amount = @reslt where class = 'extnd_rm'

--e-co		提前离店
select @reslt=isnull((select count(distinct a.roomno) from master_till a
							where a.sta in ('S','O') and a.class='F' and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)<>0)),0)
update audit_impdata set amount = @reslt 	where class='e-co'
-----------------------------------------------------------------------------------------
--d_chkin	多人入住
select @reslt = count(distinct roomno) from master_till
	where roomno in (select roomno from master_till where sta='I' and class='F' group by roomno having sum(gstno)>1)
if @reslt is null select @reslt = 0
update audit_impdata set amount = @reslt where class = 'd_chkin'
-----------------------------------------------------------------------------------------
--addbed		加床数
update audit_impdata set amount = isnull((select sum(a.addbed) from master_till a where a.sta in ('I')),0 )
						where class='addbed'
--crib		婴儿床数
update audit_impdata set amount = isnull((select sum(a.crib) from master_till a	where a.sta in ('I')),0 )
						where class='crib'

-----------------------------------------------------------------------------------------
--all_days  总在店天数  ???
exec p_wz_audit_impt_data 'All days in hotel',@bdate,@reslt out
update audit_impdata set amount = isnull(@reslt,0) where class = 'all_days'
--exec p_wz_audit_impt_data 'Adv days in hotel',@bdate,@reslt out
--update audit_impdata set amount = @reslt where class = 'adv_days'
--adv_day%	平均住店天数  ???
update audit_impdata set amount  = (select   amount from audit_impdata where class='all_days')/(select    amount from audit_impdata where class='gst')
						where class = 'adv_day%' and (select   amount from audit_impdata where class='gst')<>0
update audit_impdata set amount_m = (select amount_m from audit_impdata where class='all_days')/(select amount_m from audit_impdata where class='gst')
						where class = 'adv_day%' and (select amount_m from audit_impdata where class='gst')<>0
update audit_impdata set amount_y = (select amount_y from audit_impdata where class='all_days')/(select amount_y from audit_impdata where class='gst')
						where class = 'adv_day%' and (select amount_y from audit_impdata where class='gst')<>0
-----------------------------------------------------------------------------------------

--group		过夜团队数
update audit_impdata set amount = isnull((select count(1) from master_till a where  a.class in ('G','M')
								and exists(select 1 from master_till b where b.groupno=a.accnt and b.sta='I' )),0 )
						where class='group'
--dayuse		当日抵离
update audit_impdata set amount = isnull((select count(distinct a.roomno)  from master_till a
						where a.sta in ('O','S') and a.class in ('F') and a.bdate=@bdate and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta in ('I','S'))),0 )
						where class='dayuse'


--daybook		当日做的预定房数     当日预定当日到+当日预定未到
select @reslt = isnull((select count(distinct a.roomno) from master_till a
	where a.class='F' and a.sta in ('I','S','O') and a.bdate=@bdate and substring(extra,9,1)<>'1'
		and a.resno like @cdate+'%'), 0)
update audit_impdata set amount =@reslt + isnull((select sum(a.quantity)  from rsvsrc_till a,master_till b
						where  a.accnt=b.accnt and b.sta='R' and datediff(dd,b.bdate,@bdate)=0 ),0 )
						where class='daybook'

--pre_booking	当天到(提前预订)
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta in ('I','S','O') and bdate=@bdate and
							 accnt in (select accnt from master_last where class='F' and sta in ('R'))), 0)

update audit_impdata set amount = @reslt where class = 'pre_booking'

--cur_booking	当天到(当天预订)
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta in ('I','S','O') and bdate=@bdate and
							 accnt not in (select accnt from master_last where class='F' and sta in ('R'))), 0)

update audit_impdata set amount = @reslt where class = 'cur_booking'
-----------------------------------------------------------------------------------------
--	manager report - clg
-----------------------------------------------------------------------------------------
--bed
update audit_impdata set amount =isnull((select sum(bedno)  from rmsta	where  tag<>'P' ),0 )
						where class='bed'
--tarr_rms			本日到房数(本日还是夜审后的本日？？)	->act_arr



--tarr_ps			本日到人数
select @reslt = isnull((select sum(gstno) from master_till where class='F' and sta in ('I') and bdate=@bdate and arr>=@bdate), 0)
select @reslt = @reslt + isnull((select sum(gstno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)

update audit_impdata set amount  = @reslt where class = 'tarr_ps'

--deducted			确认预定房数（本日还是明日？？）
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta in ('I') and bdate=@bdate and arr>=@bdate
    and restype in (select code from restype where definite='T') and substring(extra,9,1)<>'1'), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
    and restype in (select code from restype where definite='T') and substring(extra,9,1)<>'1'
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)
--exec p_gds_reserve_rsv_index @bdate, '%', 'Definite Reservations', 'R', @reslt output
update audit_impdata set amount  = @reslt where class = 'deducted'

--non_ded			非确认预定房数
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta in ('I') and bdate=@bdate and arr>=@bdate
    and restype not in (select code from restype where definite='T') and substring(extra,9,1)<>'1'), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
    and restype not in (select code from restype where definite='T') and substring(extra,9,1)<>'1'
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)
--exec p_gds_reserve_rsv_index @bdate, '%', 'Tentative Reservation', 'R', @reslt output
update audit_impdata set amount  = @reslt where class = 'non_ded'

--wlk_rms			Walk-in房数->walkin


--wlk_ps			Walk-in人数

select @reslt = isnull((select sum(gstno) from master_till where class='F' and substring(extra,9,1)='1' and sta in ('I') and bdate=@bdate), 0)
select @reslt = @reslt + isnull((select sum(gstno) from master_till a where a.class='F' and substring(extra,9,1)='1' and a.sta in ('S','O') and a.bdate=@bdate
											and not exists(select 1 from master_last b where a.accnt=b.accnt)), 0)
update audit_impdata set amount  = @reslt where class = 'wlk_ps'

--ext_rms			延住房数->extnd_rm



--ext_ps			延住人数

select @reslt=isnull((select sum(a.gstno) from master_till a
							where a.sta in ('I') and a.class='F' and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)=0)),0)
update audit_impdata set amount  = @reslt where class = 'ext_ps'

--o_rms			离店房数->act_dep



--o_ps			离店人数

select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate), 0)
update audit_impdata set amount  = @reslt where class = 'o_ps'

--ed_rms			提前结账房数->e-co



--ed_ps			提前结账人数

select @reslt=isnull((select sum(a.gstno) from master_till a
							where a.sta in ('S','O') and a.class='F' and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)<>0)),0)
update audit_impdata set amount  = @reslt where class = 'ed_ps'

--o_soldf			今日离散客房数(应该是实际已离店的散客数，但统计指标里没有区分，而预计的分散客等)
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and groupno=''), 0)
update audit_impdata set amount = @reslt where class = 'o_soldf'

--ot_gstf			今日离散客人数
select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and groupno=''), 0)
update audit_impdata set amount  = @reslt where class = 'ot_gstf'

--o_soldg			今日离团队房数
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and groupno<>''), 0)
update audit_impdata set amount = @reslt where class = 'o_soldg'

--ot_gstg			今日离团队人数
select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and groupno<>''), 0)
update audit_impdata set amount  = @reslt where class = 'ot_gstg'

--o_frmem			今日离会员散客房数(应该是实际已离店的散客数，但统计指标里没有区分，而预计的分散客等)
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and cardno<>'' and sta in ('O','S') and bdate=@bdate and groupno=''), 0)
update audit_impdata set amount = @reslt where class = 'o_frmem'

--o_fgmem			今日离会员散客人数
select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and cardno<>'' and sta in ('O','S') and bdate=@bdate and groupno=''), 0)
update audit_impdata set amount  = @reslt where class = 'o_fgmem'

--o_rmem			今日离会员散客房数(应该是实际已离店的散客数，但统计指标里没有区分，而预计的分散客等)
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and cardno<>'' and sta in ('O','S') and bdate=@bdate), 0)
update audit_impdata set amount = @reslt where class = 'o_rmem'

--o_gmem			今日离会员散客人数
select @reslt = isnull((select sum(gstno) from master_till
						where class='F' and cardno<>'' and sta in ('O','S') and bdate=@bdate), 0)
update audit_impdata set amount  = @reslt where class = 'o_gmem'

--ns_gst			noshow人数
select @reslt = isnull((select sum(gstno) from master where class='F' and sta='N' and bdate=@bdate), 0)
update audit_impdata set amount= @reslt where class = 'ns_gst'

--tcxlt				本日取消的本日预定
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta='X' and bdate=@bdate and datediff(dd,arr,@bdate)=0 and roomno<>''), 0)
select @reslt = @reslt+isnull((select sum(rmnum) from master_till where class='F' and sta='X' and bdate=@bdate and datediff(dd,arr,@bdate)=0 and roomno=''), 0)
update audit_impdata set amount = @reslt where class = 'tcxlt'

--cxl			    累计取消的本日预定
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta='X' and datediff(dd,arr,@bdate)=0 and roomno<>''), 0)
select @reslt = @reslt+isnull((select sum(rmnum) from master_till where class='F' and sta='X' and datediff(dd,arr,@bdate)=0 and roomno=''), 0)
update audit_impdata set amount = @reslt where class = 'cxl'

--cxlmade		本日取消预定数--订单的数量->cancel



--rsvmade		本日新增预定->daybook



--rsv_nights	本日新增房晚--少了已到和团队预留？后面的方法同住会多算


select @reslt = isnull((select sum(rmnum*datediff(dd,arr,dep)) from master_till a
	where a.class='F' and a.sta in ('I','S','O') and a.bdate=@bdate and substring(extra,9,1)<>'1' and accnt=master
		and a.resno like @cdate+'%'), 0)
update audit_impdata set amount =@reslt + isnull((select sum(a.quantity*datediff(dd,a.begin_,a.end_))  from rsvsrc_till a,master_till b
						where  a.accnt=b.accnt and b.sta='R' and datediff(dd,b.bdate,@bdate)=0 ),0 )
						where class='rsv_nights'


--payment
update audit_impdata set amount  = isnull((select sumcre from dairep where class='01010'),0)	where class = 'payment'

--预测指标第二天默认不重建
if @duringaudit='T'
begin
--tm_arr			明日将到房数(含自用)
exec p_gds_reserve_rsv_index @badate, '%', 'Arrival Rooms', 'R', @reslt output
update audit_impdata set amount  = @reslt where class = 'tm_arr'

--tm_arr_ps			明日将到人数
exec p_gds_reserve_rsv_index @badate, '%', 'Arrival Persons', 'R', @reslt output
update audit_impdata set amount  = @reslt where class = 'tm_arr_ps'

--tm_dep			明日将到房数
exec p_gds_reserve_rsv_index @badate, '%', 'Departure Rooms', 'R', @reslt output
update audit_impdata set amount  = @reslt where class = 'tm_dep'

--tm_dep_ps			明日将到人数
exec p_gds_reserve_rsv_index @badate, '%', 'Departure Persons', 'R', @reslt output
update audit_impdata set amount  = @reslt where class = 'tm_dep_ps'
exec p_gds_reserve_rsv_index @badate, '%', 'Room to Rent', 'R', @reslt output
update audit_impdata set amount=@reslt where class='avl_tm'
exec p_gds_reserve_rsv_index @badate, '%', 'Occupied Tonight-HU', 'R', @reslt output
update audit_impdata set amount=@reslt where class='sold_tm'
--以下预测不含自用维修
select @date_ = @badate,@reslt1 = 0,@reslt2=0
while datediff(dd,@date_,@badate)>-7
begin
    exec p_gds_reserve_rsv_index @date_, '%', 'Occupied Tonight-HU', 'R', @reslt output
    select @reslt1 = @reslt1 + @reslt
    exec p_gds_reserve_rsv_index @date_, '%', 'Room to Rent', 'R', @reslt output
    select @reslt2 = @reslt2 + @reslt
    select @date_=dateadd(dd,1,@date_)
end
update audit_impdata set amount=@reslt1 where class='sold_w'
update audit_impdata set amount=@reslt2 where class='avl_w'
select @date_ = @badate,@reslt1 = 0,@reslt2=0
while datediff(dd,@date_,@badate)>-31
begin
    exec p_gds_reserve_rsv_index @date_, '%', 'Occupied Tonight-HU', 'R', @reslt output
    select @reslt1 = @reslt1 + @reslt
    exec p_gds_reserve_rsv_index @date_, '%', 'Room to Rent', 'R', @reslt output
    select @reslt2 = @reslt2 + @reslt
    select @date_=dateadd(dd,1,@date_)
end
update audit_impdata set amount=@reslt1 where class='sold_m'
update audit_impdata set amount=@reslt2 where class='avl_m'
select @date_ = @badate,@reslt1 = 0,@reslt2=0
while datediff(dd,@date_,@badate)>-365
begin
    exec p_gds_reserve_rsv_index @date_, '%', 'Occupied Tonight-HU', 'R', @reslt output
    select @reslt1 = @reslt1 + @reslt
    exec p_gds_reserve_rsv_index @date_, '%', 'Room to Rent', 'R', @reslt output
    select @reslt2 = @reslt2 + @reslt
    select @date_=dateadd(dd,1,@date_)
end
update audit_impdata set amount=@reslt1 where class='sold_y'
update audit_impdata set amount=@reslt2 where class='avl_y'
end
else
begin
    update audit_impdata set amount=a.amount from yaudit_impdata a where a.class=audit_impdata.class
        and a.class in ('tm_arr','tm_arr_ps','tm_dep','tm_dep_ps','sold_tm','avl_tm','sold_w','avl_w','sold_m','avl_m','sold_y','avl_y') and a.date=@bdate
end

--餐饮就餐人数

update audit_impdata set amount = isnull((select sum(guest) from pos_tmenu where pccode in ('210','260') and sta='3' ),0)
 where class = 'pos_z'

update audit_impdata set amount = isnull((select sum(guest) from pos_tmenu where pccode  not in ('210','260') and sta='3'),0)
 where class = 'pos_x'

exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday ='T'
	update audit_impdata set amount_m = 0
if @isyfstday ='T'
	update audit_impdata set amount_m = 0,amount_y=0

update audit_impdata set amount_m = amount_m  +  amount,amount_y = amount_y  +  amount, date = @bdate
	where charindex('%', class) = 0

-----------------------------------------------------------------------------------------
--	%计算
-----------------------------------------------------------------------------------------
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='sold')/(select amount_m from audit_impdata where class='avl')
						where class = 'sold%' and (select amount_m from audit_impdata where class='avl')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='sold')/(select amount_y from audit_impdata where class='avl')
						where class = 'sold%' and (select amount_y from audit_impdata where class='avl')<>0

--income%
update audit_impdata set amount  = (select amount from audit_impdata where class='income') / (select amount from audit_impdata where class='occ')
						where class = 'income%' and (select amount from audit_impdata where class='occ')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='income') / (select amount_m from audit_impdata where class='occ')
						where class = 'income%' and (select amount_m from audit_impdata where class='occ')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='income') / (select amount_y from audit_impdata where class='occ')
						where class = 'income%' and (select amount_y from audit_impdata where class='occ')<>0

--income_h%
update audit_impdata set amount  = (select amount from audit_impdata where class='income') / (select amount from audit_impdata where class='occ_h')
						where class = 'income_h%' and (select amount from audit_impdata where class='occ_h')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='income') / (select amount_m from audit_impdata where class='occ_h')
						where class = 'income_h%' and (select amount_m from audit_impdata where class='occ_h')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='income') / (select amount_y from audit_impdata where class='occ_h')
						where class = 'income_h%' and (select amount_y from audit_impdata where class='occ_h')<>0

--income_c%
update audit_impdata set amount  = (select amount from audit_impdata where class='income') / (select amount from audit_impdata where class='occ_c')
						where class = 'income_c%' and (select amount from audit_impdata where class='occ_c')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='income') / (select amount_m from audit_impdata where class='occ_c')
						where class = 'income_c%' and (select amount_m from audit_impdata where class='occ_c')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='income') / (select amount_y from audit_impdata where class='occ_c')
						where class = 'income_c%' and (select amount_y from audit_impdata where class='occ_c')<>0

--income_ch%
update audit_impdata set amount  = (select amount from audit_impdata where class='income') / (select amount from audit_impdata where class='occ_ch')
						where class = 'income_ch%' and (select amount from audit_impdata where class='occ_ch')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='income') / (select amount_m from audit_impdata where class='occ_ch')
						where class = 'income_ch%' and (select amount_m from audit_impdata where class='occ_ch')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='income') / (select amount_y from audit_impdata where class='occ_ch')
						where class = 'income_ch%' and (select amount_y from audit_impdata where class='occ_ch')<>0

--total_per
update audit_impdata set amount  = (select amount from audit_impdata where class='total') / (select amount from audit_impdata where class='gst')
						where class = 'total_per' and (select amount from audit_impdata where class='gst')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='total') / (select amount_m from audit_impdata where class='gst')
						where class = 'total_per' and (select amount_m from audit_impdata where class='gst')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='total') / (select amount_y from audit_impdata where class='gst')
						where class = 'total_per' and (select amount_y from audit_impdata where class='gst')<>0

--income_per
update audit_impdata set amount  = (select amount from audit_impdata where class='income') / (select amount from audit_impdata where class='gst')
						where class = 'income_per' and (select amount from audit_impdata where class='gst')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='income') / (select amount_m from audit_impdata where class='gst')
						where class = 'income_per' and (select amount_m from audit_impdata where class='gst')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='income') / (select amount_y from audit_impdata where class='gst')
						where class = 'income_per' and (select amount_y from audit_impdata where class='gst')<>0

--beduse%
update audit_impdata set amount  = 100*(select amount from audit_impdata where class='gst') / (select amount from audit_impdata where class='bed')
						where class = 'beduse%' and (select amount from audit_impdata where class='bed')<>0
update audit_impdata set amount_m  = 100*(select amount_m from audit_impdata where class='gst') / (select amount_m from audit_impdata where class='bed')
						where class = 'beduse%' and (select amount_m from audit_impdata where class='bed')<>0
update audit_impdata set amount_y  = 100*(select amount_y from audit_impdata where class='gst') / (select amount_y from audit_impdata where class='bed')
						where class = 'beduse%' and (select amount_y from audit_impdata where class='bed')<>0

--group_per
update audit_impdata set amount  = (select amount from audit_impdata where class='gst_mem') / (select amount from audit_impdata where class='t_soldg')
						where class = 'group_per' and (select amount from audit_impdata where class='t_soldg')<>0
update audit_impdata set amount_m  = (select amount_m from audit_impdata where class='gst_mem') / (select amount_m from audit_impdata where class='t_soldg')
						where class = 'group_per' and (select amount_m from audit_impdata where class='t_soldg')<>0
update audit_impdata set amount_y  = (select amount_y from audit_impdata where class='gst_mem') / (select amount_y from audit_impdata where class='t_soldg')
						where class = 'group_per' and (select amount_y from audit_impdata where class='t_soldg')<>0

--memrev_per
update audit_impdata set amount  = ((select amount from audit_impdata where class='memrev')+(select amount from audit_impdata where class='meetrev')) / (select amount from audit_impdata where class='t_soldg')
						where class = 'memrev_per' and (select amount from audit_impdata where class='t_soldg')<>0
update audit_impdata set amount_m  = ((select amount_m from audit_impdata where class='memrev')+(select amount from audit_impdata where class='meetrev')) / (select amount_m from audit_impdata where class='t_soldg')
						where class = 'memrev_per' and (select amount_m from audit_impdata where class='t_soldg')<>0
update audit_impdata set amount_y  = ((select amount_y from audit_impdata where class='memrev')+(select amount from audit_impdata where class='meetrev')) / (select amount_y from audit_impdata where class='t_soldg')
						where class = 'memrev_per' and (select amount_y from audit_impdata where class='t_soldg')<>0

--incomeg_per
update audit_impdata set amount  = ((select amount from audit_impdata where class='incomeg')+(select amount from audit_impdata where class='incomec')) / (select amount from audit_impdata where class='t_soldg')
						where class = 'incomeg_per' and (select amount from audit_impdata where class='t_soldg')<>0
update audit_impdata set amount_m  = ((select amount_m from audit_impdata where class='incomeg')+(select amount from audit_impdata where class='incomec')) / (select amount_m from audit_impdata where class='t_soldg')
						where class = 'incomeg_per' and (select amount_m from audit_impdata where class='t_soldg')<>0
update audit_impdata set amount_y  = ((select amount_y from audit_impdata where class='incomeg')+(select amount from audit_impdata where class='incomec')) / (select amount_y from audit_impdata where class='t_soldg')
						where class = 'incomeg_per' and (select amount_y from audit_impdata where class='t_soldg')<>0

--occ%			出租率
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ')/(select   amount from audit_impdata where class='ttl')
						where class = 'occ%' and (select   amount from audit_impdata where class='ttl')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ')/(select amount_m from audit_impdata where class='ttl')
						where class = 'occ%' and (select amount_m from audit_impdata where class='ttl')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ')/(select amount_y from audit_impdata where class='ttl')
						where class = 'occ%' and (select amount_y from audit_impdata where class='ttl')<>0

--occ_ch%			出租率不含免费自用房
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ_ch')/(select   amount from audit_impdata where class='ttl')
						where class = 'occ_ch%' and (select   amount from audit_impdata where class='ttl')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ_ch')/(select amount_m from audit_impdata where class='ttl')
						where class = 'occ_ch%' and (select amount_m from audit_impdata where class='ttl')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ_ch')/(select amount_y from audit_impdata where class='ttl')
						where class = 'occ_ch%' and (select amount_y from audit_impdata where class='ttl')<>0

--occ_cho%			出租率不含免费自用维修房
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ_ch')/(select   amount from audit_impdata where class='ttl_o')
						where class = 'occ_cho%' and (select   amount from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ_ch')/(select amount_m from audit_impdata where class='ttl_o')
						where class = 'occ_cho%' and (select amount_m from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ_ch')/(select amount_y from audit_impdata where class='ttl_o')
						where class = 'occ_cho%' and (select amount_y from audit_impdata where class='ttl_o')<>0

--occ_h%			出租率不含自用房
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ_h')/(select   amount from audit_impdata where class='ttl')
						where class = 'occ_h%' and (select   amount from audit_impdata where class='ttl')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ_h')/(select amount_m from audit_impdata where class='ttl')
						where class = 'occ_h%' and (select amount_m from audit_impdata where class='ttl')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ_h')/(select amount_y from audit_impdata where class='ttl')
						where class = 'occ_h%' and (select amount_y from audit_impdata where class='ttl')<>0

--occ_c%			出租率不含免费房
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ_c')/(select   amount from audit_impdata where class='ttl')
						where class = 'occ_c%' and (select   amount from audit_impdata where class='ttl')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ_c')/(select amount_m from audit_impdata where class='ttl')
						where class = 'occ_c%' and (select amount_m from audit_impdata where class='ttl')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ_c')/(select amount_y from audit_impdata where class='ttl')
						where class = 'occ_c%' and (select amount_y from audit_impdata where class='ttl')<>0

--occ_co%			出租率不含免费维修房
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ_c')/(select   amount from audit_impdata where class='ttl_o')
						where class = 'occ_co%' and (select   amount from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ_c')/(select amount_m from audit_impdata where class='ttl_o')
						where class = 'occ_co%' and (select amount_m from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ_c')/(select amount_y from audit_impdata where class='ttl_o')
						where class = 'occ_co%' and (select amount_y from audit_impdata where class='ttl_o')<>0

--occ_ho%			出租率不含自用维修房
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ_h')/(select   amount from audit_impdata where class='ttl_o')
						where class = 'occ_ho%' and (select   amount from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ_h')/(select amount_m from audit_impdata where class='ttl_o')
						where class = 'occ_ho%' and (select amount_m from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ_h')/(select amount_y from audit_impdata where class='ttl_o')
						where class = 'occ_ho%' and (select amount_y from audit_impdata where class='ttl_o')<>0

--occ_o%			出租率不含维修房
update audit_impdata set amount  = 100*(select   amount from audit_impdata where class='occ')/(select   amount from audit_impdata where class='ttl_o')
						where class = 'occ_o%' and (select   amount from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_m = 100*(select amount_m from audit_impdata where class='occ')/(select amount_m from audit_impdata where class='ttl_o')
						where class = 'occ_o%' and (select amount_m from audit_impdata where class='ttl_o')<>0
update audit_impdata set amount_y = 100*(select amount_y from audit_impdata where class='occ')/(select amount_y from audit_impdata where class='ttl_o')
						where class = 'occ_o%' and (select amount_y from audit_impdata where class='ttl_o')<>0

--tm_sold%			明日出租率
update audit_impdata set amount  = 100*((select amount from audit_impdata where class='sold_tm'))/(select   amount from audit_impdata where class='avl_tm')
						where class = 'tm_sold%' and (select   amount from audit_impdata where class='avl_tm')<>0
update audit_impdata set amount_m  = 100*((select amount_m from audit_impdata where class='sold_tm'))/(select   amount_m from audit_impdata where class='avl_tm')
						where class = 'tm_sold%' and (select   amount_m from audit_impdata where class='avl_tm')<>0
update audit_impdata set amount_y  = 100*((select amount_y from audit_impdata where class='sold_tm'))/(select   amount_y from audit_impdata where class='avl_tm')
						where class = 'tm_sold%' and (select   amount_y from audit_impdata where class='avl_tm')<>0

--nw_sold%			下7天出租率<>7预定房晚数-7离店房晚数=((((sold+tm_arr-tm_dep)*2+n2arr-n2dep)*2+n3arr-n3dep)*2……
update audit_impdata set amount  = 100*(select amount from audit_impdata where class='sold_w') / (select amount from audit_impdata where class='avl_w')
						where class = 'nw_sold%' and (select   amount from audit_impdata where class='avl_w')<>0
update audit_impdata set amount_m  = 100*(select amount_m from audit_impdata where class='sold_w') / (select amount_m from audit_impdata where class='avl_w')
						where class = 'nw_sold%' and (select   amount_m from audit_impdata where class='avl_w')<>0
update audit_impdata set amount_y  = 100*(select amount_y from audit_impdata where class='sold_w') / (select amount_y from audit_impdata where class='avl_w')
						where class = 'nw_sold%' and (select   amount_y from audit_impdata where class='avl_w')<>0

--nm_sold%			下7天出租率<>7预定房晚数-7离店房晚数=((((sold+tm_arr-tm_dep)*2+n2arr-n2dep)*2+n3arr-n3dep)*2……
update audit_impdata set amount  = 100*(select amount from audit_impdata where class='sold_m') / (select amount from audit_impdata where class='avl_m')
						where class = 'nm_sold%' and (select   amount from audit_impdata where class='avl_m')<>0
update audit_impdata set amount_m  = 100*(select amount_m from audit_impdata where class='sold_m') / (select amount_m from audit_impdata where class='avl_m')
						where class = 'nm_sold%' and (select   amount_m from audit_impdata where class='avl_m')<>0
update audit_impdata set amount_y  = 100*(select amount_y from audit_impdata where class='sold_m') / (select amount_y from audit_impdata where class='avl_m')
						where class = 'nm_sold%' and (select   amount_y from audit_impdata where class='avl_m')<>0


--ny_sold%			下7天出租率<>7预定房晚数-7离店房晚数=((((sold+tm_arr-tm_dep)*2+n2arr-n2dep)*2+n3arr-n3dep)*2……
update audit_impdata set amount  = 100*(select amount from audit_impdata where class='sold_y') / (select amount from audit_impdata where class='avl_y')
						where class = 'ny_sold%' and (select   amount from audit_impdata where class='avl_y')<>0
update audit_impdata set amount_m  = 100*(select amount_m from audit_impdata where class='sold_y') / (select amount_m from audit_impdata where class='avl_y')
						where class = 'ny_sold%' and (select   amount_m from audit_impdata where class='avl_y')<>0
update audit_impdata set amount_y  = 100*(select amount_y from audit_impdata where class='sold_y') / (select amount_y from audit_impdata where class='avl_y')
						where class = 'ny_sold%' and (select   amount_y from audit_impdata where class='avl_y')<>0


delete yaudit_impdata where date = @bdate
insert yaudit_impdata select * from audit_impdata
return 0
;
