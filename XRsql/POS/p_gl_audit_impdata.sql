drop  proc p_gl_audit_impdata;
create proc p_gl_audit_impdata
as
declare
	@duringaudit	char(1),
	@isfstday		char(1),
	@isyfstday		char(1),
	@bdate			datetime,
	@bfdate			datetime,
	@reslt			money,
	@nreslt	          money,
	@sreslt			money,
	@reslt1			money,
	@reslt2			money,
	@nreslt1			money,
	@nreslt2			money,
	@sreslt1			money,
	@sreslt2			money,
   @mbret         money,
	@cdate			char(6),     -- 040501
   @bbnum1        char(5),
   @bbnum          money


select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
if exists ( select 1 from audit_impdata where date = @bdate )
	update audit_impdata set amount_m = amount_m - amount,amount_y = amount_y - amount
update audit_impdata set amount = 0, date = @bfdate
update audit_impdata set date = rmsalerep_new.date from rmsalerep_new where gkey='f' and hall='{' and code='{{{'
select @cdate = convert(char(6), @bdate, 12)

---------------------------------------------------------------------------------
--------凭证统计
---------------------------------------------------------------------------------
update audit_impdata set amount =  (select (credit01+credit02) from dairep where class='01998') + 
                 (select isnull(sum(a.credit),0) from gltemp a,pccode b where a.empno  not like 'FC%' and a.pccode=b.pccode and b.deptno in ('A','B'))
--                 isnull((select sum(a.credit) from gltemp a,pccode b where a.accnt in ('C000107','C000110') and a.pccode=b.pccode and b.deptno in ('A','B')),0)),0)
       where audit_impdata.class = '90001'

update audit_impdata set amount =  -- isnull(( (select credit04 from dairep where class='01010') - 
                 isnull((select sum(a.credit) from gltemp a,pccode b where a.empno  not like 'FC%' and a.pccode=b.pccode and b.deptno='D'),0)
--                 isnull((select sum(a.credit) from gltemp a,pccode b where a.accnt in ('C000107','C000110') and a.pccode=b.pccode and b.deptno='D'),0)),0)
       where audit_impdata.class = '90002'

update audit_impdata set amount =  -- isnull(((select credit03 from dairep where class='01010') - 
                 isnull((select sum(a.credit) from gltemp a,pccode b where a.empno not like 'FC%'  and a.pccode=b.pccode and b.deptno='C'),0)
--                 isnull((select sum(a.credit) from gltemp a,pccode b where a.accnt in ('C000107','C000110') and a.pccode=b.pccode and b.deptno='C'),0)),0)
       where audit_impdata.class = '90003'

update audit_impdata set amount = -- isnull(((select credit06 from dairep where class='01010') - 
                 isnull((select sum(a.credit) from gltemp a,pccode b where a.empno not like 'FC%' and a.pccode=b.pccode and b.deptno='F'),0) 
--                 isnull((select sum(a.credit) from gltemp a,pccode b where a.accnt in ('C000107','C000110') and a.pccode=b.pccode and b.deptno='F'),0)),0)
       where audit_impdata.class = '90004'

update audit_impdata set amount = isnull((select day from jourrep where class='010140'),0) where audit_impdata.class = '90011'
update audit_impdata set amount = isnull((select day from jourrep where class='010150'),0) where audit_impdata.class = '90012'
update audit_impdata set amount = isnull((select day from jourrep where class='010160'),0) where audit_impdata.class = '90013'
update audit_impdata set amount = isnull((select day from jourrep where class='010155'),0) where audit_impdata.class = '90014'
update audit_impdata set amount = isnull((select day06 from jierep where class='010'),0) where audit_impdata.class = '90015'

update audit_impdata set amount = isnull((select sum(a.charge) from gltemp a,master_till b where a.pccode in ('4020','4029') and a.accnt=b.accnt and b.roomno like '1[3-7]%' ),0) 
       where audit_impdata.class = '90020'
select @mbret = isnull((select sum(charge) from discount_detail where paycode in('ENT','DSC') and pccode in ('4020','4029') and accnt in (select accnt from master_till where roomno like '1[3-7]%')),0)
update audit_impdata set amount = amount - @mbret where class = '90020'

--update audit_impdata set amount = isnull((select sum(a.charge) from gltemp a,master_till b where a.pccode in ('4020','4029') and a.accnt=b.accnt and b.roomno like '14%' ),0) 
--       where audit_impdata.class = '90021'
--select @mbret = isnull((select sum(charge) from discount_detail where paycode in('ENT','DSC') and pccode in ('4020','4029') and accnt in (select accnt from master_till where roomno like '14%')),0)
--update audit_impdata set amount = amount - @mbret where class = '90021'

--update audit_impdata set amount = isnull((select sum(a.charge) from gltemp a,master_till b where a.pccode in ('4020','4029') and a.accnt=b.accnt and b.roomno like '15%' ),0) 
--       where audit_impdata.class = '90022'
--select @mbret = isnull((select sum(charge) from discount_detail where paycode in('ENT','DSC') and pccode in ('4020','4029') and accnt in (select accnt from master_till where roomno like '15%')),0)
--update audit_impdata set amount = amount - @mbret where class = '90022'

--update audit_impdata set amount = isnull((select sum(a.charge) from gltemp a,master_till b where a.pccode in ('4020','4029') and a.accnt=b.accnt and b.roomno like '16%' ),0) 
--       where audit_impdata.class = '90023'
--select @mbret = isnull((select sum(charge) from discount_detail where paycode in('ENT','DSC') and pccode in ('4020','4029') and accnt in (select accnt from master_till where roomno like '16%')),0)
--update audit_impdata set amount = amount - @mbret where class = '90023'

--update audit_impdata set amount = isnull((select sum(a.charge) from gltemp a,master_till b where a.pccode in ('4020','4029') and a.accnt=b.accnt and b.roomno like '17%' ),0) 
--     where audit_impdata.class = '90024'
--select @mbret = isnull((select sum(charge) from discount_detail where paycode in('ENT','DSC') and pccode in ('4020','4029') and accnt in (select accnt from master_till where roomno like '17%')),0)
--update audit_impdata set amount = amount - @mbret where class = '90024'

update audit_impdata set amount = isnull((select sum(a.charge) from gltemp a,master_till b where a.pccode in ('4020','4029') and a.accnt=b.accnt and b.roomno like '2[2-8]%' ),0) 
       where audit_impdata.class = '90025'
select @mbret = isnull((select sum(charge) from discount_detail where paycode in('ENT','DSC') and pccode in ('4020','4029') and accnt in (select accnt from master_till where roomno like '2[2-8]%')),0)
update audit_impdata set amount = amount - @mbret where class = '90025'

--update audit_impdata set amount = isnull((select sum(a.charge) from gltemp a,master_till b where a.pccode in ('4020','4029') and a.accnt=b.accnt and b.roomno like '23%' ),0) 
--       where audit_impdata.class = '90026'
--select @mbret = isnull((select sum(charge) from discount_detail where paycode in('ENT','DSC') and pccode in ('4020','4029') and accnt in (select accnt from master_till where roomno like '23%')),0)
--update audit_impdata set amount = amount - @mbret where class = '90026'

--update audit_impdata set amount = isnull((select sum(a.charge) from gltemp a,master_till b where a.pccode in ('4020','4029') and a.accnt=b.accnt and b.roomno like '24%' ),0) 
--       where audit_impdata.class = '90027'
--select @mbret = isnull((select sum(charge) from discount_detail where paycode in('ENT','DSC') and pccode in ('4020','4029') and accnt in (select accnt from master_till where roomno like '24%')),0)
--update audit_impdata set amount = amount - @mbret where class = '90027'

--update audit_impdata set amount = isnull((select sum(a.charge) from gltemp a,master_till b where a.pccode in ('4020','4029') and a.accnt=b.accnt and b.roomno like '25%' ),0) 
--       where audit_impdata.class = '90028'
--select @mbret = isnull((select sum(charge) from discount_detail where paycode in('ENT','DSC') and pccode in ('4020','4029') and accnt in (select accnt from master_till where roomno like '25%')),0)
--update audit_impdata set amount = amount - @mbret where class = '90028'

--update audit_impdata set amount = isnull((select sum(a.charge) from gltemp a,master_till b where a.pccode in ('4020','4029') and a.accnt=b.accnt and b.roomno like '26%' ),0) 
--       where audit_impdata.class = '90029'
--select @mbret = isnull((select sum(charge) from discount_detail where paycode in('ENT','DSC') and pccode in ('4020','4029') and accnt in (select accnt from master_till where roomno like '26%')),0)
--update audit_impdata set amount = amount - @mbret where class = '90029'

--update audit_impdata set amount = isnull((select sum(a.charge) from gltemp a,master_till b where a.pccode in ('4020','4029') and a.accnt=b.accnt and b.roomno like '27%'),0) 
--       where audit_impdata.class = '90030'
--select @mbret = isnull((select sum(charge) from discount_detail where paycode in('ENT','DSC') and pccode in ('4020','4029') and accnt in (select accnt from master_till where roomno like '27%')),0)
--update audit_impdata set amount = amount - @mbret where class = '90030'

--update audit_impdata set amount = isnull((select sum(a.charge) from gltemp a,master_till b where a.pccode in ('4020','4029') and a.accnt=b.accnt and b.roomno like '28%' ),0) 
--       where audit_impdata.class = '90031'
--select @mbret = isnull((select sum(charge) from discount_detail where paycode in('ENT','DSC') and pccode in ('4020','4029') and accnt in (select accnt from master_till where roomno like '28%')),0)
--update audit_impdata set amount = amount - @mbret where class = '90031'


update audit_impdata set amount = isnull((select sum(charge) from gltemp where pccode >='2000' and pccode<='2049' and accnt <>'C000110'),0)
       where audit_impdata.class = '90040'

-----------------------------------------------------------------------------------------
-- 客房总体指标
-----------------------------------------------------------------------------------------
--写字楼房数
 select @bbnum1 = isnull(value,'0') from sysoption where catalog = 'account' and item = 'business_building_num'
 select @bbnum = convert(money,@bbnum1)
 update audit_impdata set amount = @bbnum where class = 'bbnum'



--ttl			总房数
update audit_impdata set amount = ttl from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{'  and audit_impdata.class='ttl'
update audit_impdata set amount = ttl from rmsalerep_new
						where gkey='h' and hall='A' and code='A'  and audit_impdata.class='sttl'
update audit_impdata set amount = ttl from rmsalerep_new
						where gkey='h' and hall='B' and code='B'  and audit_impdata.class='nttl'
--ooo			维修房
select @reslt1= count(1) from rmsta_till where locked='L' and futbegin<=@bdate and (futend > @bdate or futend is null)
		and (sta='O' or futsta='O') and tag='K'
update audit_impdata set amount = @reslt1 where class = 'ooo'
select @sreslt1= count(1) from rmsta_till where locked='L' and futbegin<=@bdate and (futend > @bdate or futend is null)
		and (sta='O' or futsta='O') and tag='K' and hall='A'
update audit_impdata set amount = @sreslt1 where class = 'sooo'
select @nreslt1= count(1) from rmsta_till where locked='L' and futbegin<=@bdate and (futend > @bdate or futend is null)
		and (sta='O' or futsta='O') and tag='K' and hall='B'
update audit_impdata set amount = @nreslt1 where class = 'nooo'

--os			锁定房
select @reslt2=count(1) from rmsta_till where locked='L' and futbegin<=@bdate and (futend > @bdate or futend is null)
		and (sta='S' or futsta='S') and tag='K'
update audit_impdata set amount = @reslt2 where class = 'os'
select @sreslt2=count(1) from rmsta_till where locked='L' and futbegin<=@bdate and (futend > @bdate or futend is null)
		and (sta='S' or futsta='S') and tag='K' and hall='A'
update audit_impdata set amount = @sreslt2 where class = 'sos'
select @nreslt2=count(1) from rmsta_till where locked='L' and futbegin<=@bdate and (futend > @bdate or futend is null)
		and (sta='S' or futsta='S') and tag='K' and hall='B'
update audit_impdata set amount = @reslt2 where class = 'nos'
--mnt         维护房总数
--select @reslt = @reslt1 + @reslt2
---update audit_impdata set amount = @reslt where class='mnt'
--select @sreslt = @sreslt1 + @sreslt2
--update audit_impdata set amount = @sreslt where class='smnt'
--select @nreslt = @nreslt1 + @nreslt2
--update audit_impdata set amount = @nreslt where class='nmnt'

update audit_impdata set amount = mnt from rmsalerep_new
						where gkey='h' and hall='{' and code='{{{' and audit_impdata.class='mnt'
update audit_impdata set amount = mnt from rmsalerep_new
						where gkey='h' and hall='A' and code='A' and audit_impdata.class='smnt'
update audit_impdata set amount = mnt from rmsalerep_new
						where gkey='h' and hall='B' and code='B' and audit_impdata.class='nmnt'


--avl			可用房数
update audit_impdata set amount = avl from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='avl'
    --  south avl
    update audit_impdata set amount = avl from rmsalerep_new
						where gkey='h' and hall='A' and code='A' and audit_impdata.class='savl'
    --  north avl
    update audit_impdata set amount = avl from rmsalerep_new
						where gkey='h' and hall='B' and code='B' and audit_impdata.class='navl'
--sold			售房数
update audit_impdata set amount = soldf + soldg + soldc+ soldl from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='sold'
update audit_impdata set amount = isnull((select  count(distinct roomno) from master_till where source='5000174' and sta='I'),0) where class='sold_xzl'
update audit_impdata set amount = isnull((select  count(distinct roomno) from master_till where source='5000174' and sta='I' and roomno like '1%'),0) where class='ssold_x'
update audit_impdata set amount = isnull((select  count(distinct roomno) from master_till where source='5000174' and sta='I' and roomno like '2%'),0) where class='nsold_x'
--sold%			出租率
update audit_impdata set amount  = (select   amount from audit_impdata where class='sold')/(select   amount from audit_impdata where class='avl')
						where class = 'sold%' and (select   amount from audit_impdata where class='avl')<>0
update audit_impdata set amount_m = (select amount_m from audit_impdata where class='sold')/(select amount_m from audit_impdata where class='avl')
						where class = 'sold%' and (select amount_m from audit_impdata where class='avl')<>0
update audit_impdata set amount_y = (select amount_y from audit_impdata where class='sold')/(select amount_y from audit_impdata where class='avl')
						where class = 'sold%' and (select amount_y from audit_impdata where class='avl')<>0

--vac			空房数
update audit_impdata set amount = vac from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='vac'
--htl			自用房数
select @reslt = isnull((select count(distinct a.roomno) from master_till a, mktcode b
	where a.class='F' and a.sta='I' and a.market=b.code and b.flag='HSE' ), 0)
update audit_impdata set amount = @reslt where class='htl'
    --south
    select @reslt = isnull((select count(distinct a.roomno) from master_till a, mktcode b
	     where a.class='F' and a.sta='I' and a.market=b.code and b.flag='HSE' and substring(a.roomno,1,1)='1'), 0)
    update audit_impdata set amount = @reslt where class='shtl'
    --north
    select @reslt = isnull((select count(distinct a.roomno) from master_till a, mktcode b
	     where a.class='F' and a.sta='I' and a.market=b.code and b.flag='HSE' and substring(a.roomno,1,1)='2'), 0)
    update audit_impdata set amount = @reslt where class='nhtl'
--OCC			=SOLD + HU
update audit_impdata set amount = soldf + soldg + soldc+ soldl+@reslt from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='occ'
--free			免费房
select @reslt = isnull((select count(distinct a.roomno) from master_till a, mktcode b
	where a.class='F' and a.sta='I' and a.market=b.code and b.flag='COM' ), 0)
update audit_impdata set amount = @reslt where class = 'free'
select @reslt = isnull((select count(distinct a.roomno) from master_till a, mktcode b
	where a.class='F' and a.sta='I' and a.market=b.code and b.flag='COM' and a.roomno like '1%'), 0)
update audit_impdata set amount = @reslt where class = 'sfree'
select @reslt = isnull((select count(distinct a.roomno) from master_till a, mktcode b
	where a.class='F' and a.sta='I' and a.market=b.code and b.flag='COM' and a.roomno like '@%'), 0)
update audit_impdata set amount = @reslt where class = 'nfree'

--longstay		长包房
-- ???

-----------------------------------------------------------------------------------------
--	客房销售 : 收入指标
-----------------------------------------------------------------------------------------
--income		总房费收入
update audit_impdata set amount = incomef + incomeg + incomec + incomel from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='income'
update audit_impdata set amount = incomef + incomeg + incomec + incomel from rmsalerep_new
						where gkey='f' and hall='A' and code='{{{' and audit_impdata.class='sincome'
update audit_impdata set amount = incomef + incomeg + incomec + incomel from rmsalerep_new
						where gkey='f' and hall='B' and code='{{{' and audit_impdata.class='nncome'

--房费调整
update audit_impdata set amount = incomef + incomeg + incomec + incomel from rmsalerep_new
						where gkey='f' and hall='{' and code='ZZZ' and audit_impdata.class='incometz'

--incomef	散客收入
update audit_impdata set amount = incomef from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='incomef'
update audit_impdata set amount = day99 - day06 from jierep 
						where jierep.class = '010010' and audit_impdata.class='incomef1' -- 凭证用 
-- 散客收入中减去总人数的保险费1元/人
update audit_impdata set amount = amount - (select isnull(sum(a.gstno),0) from master_till a,guest c
			where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no)  where class='incomef1'

update audit_impdata set amount = incomef from rmsalerep_new
						where gkey='h' and hall='A' and code='A' and audit_impdata.class='sincomef'
update audit_impdata set amount = incomef from rmsalerep_new
						where gkey='h' and hall='B' and code='B' and audit_impdata.class='nincomef'
--incomeg	团队收入
update audit_impdata set amount = incomeg from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='incomeg'
update audit_impdata set amount = day99 - day06 from jierep 
						where jierep.class = '010020' and audit_impdata.class='incomeg1'   -- 凭证用 

update audit_impdata set amount = incomeg from rmsalerep_new
						where gkey='h' and hall='A' and code='A' and audit_impdata.class='sincomeg'
update audit_impdata set amount = incomeg from rmsalerep_new
						where gkey='h' and hall='B' and code='B' and audit_impdata.class='nincomeg'
--incomec	会议收入
update audit_impdata set amount = incomec from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='incomec'
update audit_impdata set amount = day99 - day06 from jierep 
						where jierep.class = '010030' and audit_impdata.class='incomec1' -- 凭证用 

update audit_impdata set amount = incomec from rmsalerep_new
						where gkey='h' and hall='A' and code='A' and audit_impdata.class='sincomec'
update audit_impdata set amount = incomec from rmsalerep_new
						where gkey='h' and hall='B' and code='B' and audit_impdata.class='nincomec'
--incomel	长包收入
update audit_impdata set amount = incomel from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='incomel'
update audit_impdata set amount = day99 - day06 from jierep 
						where jierep.class = '010040' and audit_impdata.class='incomel1' -- 凭证用 

update audit_impdata set amount = incomel from rmsalerep_new
						where gkey='h' and hall='A' and code='A' and audit_impdata.class='sincomel'
update audit_impdata set amount = incomel from rmsalerep_new
						where gkey='h' and hall='B' and code='B' and audit_impdata.class='nincomel'
-- 写字楼
update audit_impdata set amount = day99 - day06 from jierep 
						where jierep.class = '010090' and audit_impdata.class='incomex1'

--adj_rm   
update audit_impdata set amount = incomef from rmsalerep_new
						where gkey='h' and hall='{' and code='ZZZ' and audit_impdata.class='adj_rm'

--svc	服务费收入
update audit_impdata set amount = isnull((select sum(a.day06) from jierep a where a.class='010'),0) where class='svc'
-- 早餐人数
update audit_impdata set amount = isnull((select sum(a.quantity) from package_detail a, package b
		where datediff(dd,@bdate,a.bdate)=0 and a.tag < '5' and a.code = b.code and b.type = '1'),0) where class='bf_gst'
-- bf_amt 早餐金额
update audit_impdata set amount = isnull((select sum(a.quantity*b.amount) from package_detail a, package b
		where datediff(dd,@bdate,a.bdate)=0 and a.tag < '5' and a.code = b.code and b.type = '1'),0) where class='bf_amt'
--incm_n	  房费收入-含服务费
select @reslt = isnull((select sum(amount) from audit_impdata where class = 'income'), 0)
select @reslt = @reslt - isnull((select sum(amount) from audit_impdata where class = 'svc'), 0)
update audit_impdata set amount = @reslt where class='incm_n'
--incm_nn	净房费
select @reslt = @reslt - isnull((select sum(amount) from audit_impdata where class = 'svc'), 0)
update audit_impdata set amount = @reslt where class='incm_nn'
--intotal	在店客人总收入
update audit_impdata set amount =isnull((select sum(b.charge) from gltemp b where b.bdate=@bdate),0)
      				where class='intotal'

--total	酒店总收入
update audit_impdata set amount =isnull((select (day+day_rebate) from yjourrep where class='000100' and date=@bdate),0)
      				where class='total'

-----------------------------------------------------------------------------------------
-- 客房销售 - 客房数量指标
-----------------------------------------------------------------------------------------
--soldf			散客售房数
update audit_impdata set amount = soldf from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='soldf'
update audit_impdata set amount = soldf from rmsalerep_new
						where gkey='h' and hall='A' and code='A' and audit_impdata.class='ssoldf'
update audit_impdata set amount = soldf from rmsalerep_new
						where gkey='h' and hall='B' and code='B' and audit_impdata.class='nsoldf'
--soldg			团队售房数
update audit_impdata set amount = soldg from rmsalerep_new 
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='soldg'
update audit_impdata set amount = soldg from rmsalerep_new 
						where gkey='h' and hall='A' and code='A' and audit_impdata.class='ssoldg'
update audit_impdata set amount = soldg from rmsalerep_new 
						where gkey='h' and hall='B' and code='B' and audit_impdata.class='nsoldg'
--soldc			会议售房数
update audit_impdata set amount = soldc from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='soldc'
update audit_impdata set amount = soldc from rmsalerep_new
						where gkey='h' and hall='A' and code='A' and audit_impdata.class='ssoldc'
update audit_impdata set amount = soldc from rmsalerep_new
						where gkey='h' and hall='B' and code='B' and audit_impdata.class='nsoldc'
--soldl			长包售房数
update audit_impdata set amount = soldl from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='soldl'
update audit_impdata set amount = soldl from rmsalerep_new
						where gkey='h' and hall='A' and code='A' and audit_impdata.class='ssoldl'
update audit_impdata set amount = soldl from rmsalerep_new
						where gkey='h' and hall='B' and code='B' and audit_impdata.class='nsoldl'
--sold_ou		外宾房数
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_till a,guest b,countrycode c, mktcode d
       				where a.haccnt=b.no and a.sta = 'I' and a.market=d.code and d.flag <> 'HSE' and b.nation = c.code and c.code <> 'CN'), 0)
		 				where class='sold_ou'
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_till a,guest b,countrycode c, mktcode d
       				where a.haccnt=b.no and a.sta = 'I' and a.market=d.code and d.flag <> 'HSE' and b.nation = c.code and c.code <> 'CN' and substring(a.roomno,1,1)='1'), 0)
		 				where class='ssold_ou'
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_till a,guest b,countrycode c, mktcode d
       				where a.haccnt=b.no and a.sta = 'I' and a.market=d.code and d.flag <> 'HSE' and b.nation = c.code and c.code <> 'CN' and substring(a.roomno,1,1)='2'), 0)
		 				where class='nsold_ou'
--sold_in		内宾房数
update audit_impdata set amount = isnull((select count(distinct a.roomno) from master_till a,guest b,countrycode c, mktcode d
       				where a.haccnt=b.no and a.sta = 'I' and a.market=d.code and d.flag <> 'HSE' and b.nation = c.code and c.code = 'CN'), 0)
		 				where class='sold_in'

-----------------------------------------------------------------------------------------
-- 客房销售 - 客人数量指标
-----------------------------------------------------------------------------------------
--gst				总过夜人数
update audit_impdata set amount = gstf + gstg + gstc + gstl from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gst'
--gstf			散客过夜人数
update audit_impdata set amount = gstf from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gstf'
--gstg			团队过夜人数
update audit_impdata set amount = gstg from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gstg'
--gstc			会议过夜人数
update audit_impdata set amount = gstc from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gstc'
--gstl			长包过夜人数
update audit_impdata set amount = gstl from rmsalerep_new
						where gkey='f' and hall='{' and code='{{{' and audit_impdata.class='gstl'

--ch_gstf		国内过夜散客人数
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,guest c
						where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and rtrim(a.groupno) is null and c.nation = 'CN'),0 )
						where class='ch_gstf'
--ch_gstg		国内过夜团队人数
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,guest c
						where a.sta = 'I' and a.class in ('G','M') and a.haccnt= c.no and rtrim(a.groupno) is not null and c.nation = 'CN'),0 )
  						where class='ch_gstg'
--fo_gstf		国外过夜散客人数
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,guest c
						where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and rtrim(a.groupno) is null and c.nation <> 'CN'),0 )
						where class='fo_gstf'
--fo_gstg		国外过夜团队人数
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,guest c
						where a.sta = 'I' and a.class in ('G','M') and a.haccnt= c.no and rtrim(a.groupno) is not null and c.nation <> 'CN'),0 )
						where class='fo_gstg'

--in_gstno		境内过夜人数
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,guest c
			where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and c.nation = 'CN'),0 ) where class = 'in_gstno'
   --south
   update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,guest c
			where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and c.nation = 'CN' and substring(a.roomno,1,1)='1'),0 ) where class = 'sin_gstn'
   --north
   update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,guest c
			where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and c.nation = 'CN' and substring(a.roomno,1,1)='2'),0 ) where class = 'nin_gstn'

--ou_gstno		境外过夜人数
update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,guest c
			where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and c.nation <>'CN'),0 ) where class = 'ou_gstno'
   --south
   update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,guest c
			where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and c.nation <>'CN' and substring(a.roomno,1,1)='1'),0 ) where class = 'sou_gstn'
   --north
   update audit_impdata set amount = isnull((select sum(a.gstno) from master_till a,guest c
			where a.sta = 'I' and a.class = 'F' and a.haccnt= c.no and c.nation <>'CN' and substring(a.roomno,1,1)='2'),0 ) where class = 'nou_gstn'

 -- update audit_impdata set amount = (select sum(amount) from audit_impdata where class in('ou_gstno','in_gstno') ) where class = 'gstno' 

-----------------------------------------------------------------------------------------
--	其它指标
-----------------------------------------------------------------------------------------
--exp_arr	   预计抵达
select @reslt = isnull((select sum(quantity) from rsvsrc_last where begin_=@bdate and begin_<>end_ and roomno=''),0)
select @reslt = @reslt + (select count(distinct a.roomno) from rsvsrc_last a, master_last b
		where a.accnt=b.accnt and b.sta='R' and a.begin_=@bdate and a.begin_<>a.end_ and a.roomno<>'')
update audit_impdata set amount = @reslt	where class='exp_arr'

--	act_arr		当日实际到达
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta in ('I') and bdate=@bdate), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)
update audit_impdata set amount = @reslt where class = 'act_arr'
--   south act_arr
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta in ('I') and bdate=@bdate and substring(roomno,1,1)='1' ), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate and substring(roomno,1,1)='1'
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)
update audit_impdata set amount = @reslt where class = 'sact_arr'
--   north act_arr
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta in ('I') and bdate=@bdate and substring(roomno,1,1)='2' ), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate and substring(roomno,1,1)='2'
											and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')), 0)
update audit_impdata set amount = @reslt where class = 'nact_arr'

--	sdp			当日预订到达
select @reslt = isnull((select count(distinct a.roomno) from master_till a
	where a.class='F' and a.sta in ('I','S','O') and a.bdate=@bdate and substring(extra,9,1)<>'1'
		and a.resno like @cdate+'%'), 0)
update audit_impdata set amount = @reslt where class = 'sdp'

--noshow		预订未到
-- select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta='N' and bdate=@bdate), 0)
select @reslt = isnull((select sum(rmnum) from master where sta='N' and datediff(dd,arr,(select bdate from accthead))=0 and accnt like 'F%'), 0)
update audit_impdata set amount= @reslt where class = 'noshow'
select @reslt = isnull((select sum(rmnum) from master where sta='N' and datediff(dd,arr,(select bdate from accthead))=0 and accnt like 'F%' and type like 'N%'), 0)
update audit_impdata set amount= @reslt where class = 'nnoshow'
select @reslt = isnull((select sum(rmnum) from master where sta='N' and datediff(dd,arr,(select bdate from accthead))=0 and accnt like 'F%' and type like 'S%'), 0)
update audit_impdata set amount= @reslt where class = 'snoshow'

--cancel		预订取消
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and sta='X' and bdate=@bdate), 0)
update audit_impdata set amount = @reslt where class = 'cancel'

--walkin		上门散客  -- 当日到达 !
select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and substring(extra,9,1)='1' and sta in ('I') and bdate=@bdate), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
											and not exists(select 1 from master_last b where a.accnt=b.accnt)), 0)
update audit_impdata set amount = @reslt where class = 'walkin'

select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and roomno like '1%' and substring(extra,9,1)='1' and sta in ('I') and bdate=@bdate), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
					and a.roomno like '1%' and not exists(select 1 from master_last b where a.accnt=b.accnt)), 0)
update audit_impdata set amount = @reslt where class = 'swalkin'

select @reslt = isnull((select count(distinct roomno) from master_till where class='F' and roomno like '2%' and substring(extra,9,1)='1' and sta in ('I') and bdate=@bdate), 0)
select @reslt = @reslt + isnull((select count(distinct a.roomno) from master_till a where a.class='F' and a.sta in ('S','O') and a.bdate=@bdate
					and a.roomno like '2%' and not exists(select 1 from master_last b where a.accnt=b.accnt)), 0)
update audit_impdata set amount = @reslt where class = 'nwalkin'

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
						where a.sta in ('I') and datediff(dd,a.dep,@bdate) = 0),0 )
						where class='exp_dep'

--act_dep	当日实际离店
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate), 0)
update audit_impdata set amount = @reslt where class = 'act_dep'   
   --  south at_dep
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and substring(roomno,1,1)='1'), 0)
update audit_impdata set amount = @reslt where class = 'sact_dep' 
   --  north act_dep
select @reslt = isnull((select count(distinct roomno) from master_till
						where class='F' and sta in ('O','S') and bdate=@bdate and substring(roomno,1,1)='2'), 0)
update audit_impdata set amount = @reslt where class = 'nact_dep'

--extnd_rm	延住房间数
select @reslt=isnull((select count(distinct a.roomno) from master_till a
							where a.sta in ('I') and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)=0)),0)
update audit_impdata set amount = @reslt where class = 'extnd_rm'

--e-co		提前离店
select @reslt=isnull((select count(distinct a.roomno) from master_till a
							where a.sta in ('S','O') and exists(select 1 from master_last b where a.accnt=b.accnt and datediff(dd,b.dep,@bdate)<>0)),0)
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
update audit_impdata set amount = @reslt where class = 'all_days'
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
						where a.sta in ('O','S') and a.class in ('F') and not exists(select 1 from master_last b where a.accnt=b.accnt and b.sta='I')),0 )
						where class='dayuse'


--daybook		当日做的预定房数     当日预定当日到+当日预定未到
select @reslt = isnull((select count(distinct a.roomno) from master_till a
	where a.class='F' and a.sta in ('I','S','O') and a.bdate=@bdate and substring(extra,9,1)<>'1'
		and a.resno like @cdate+'%'), 0)
update audit_impdata set amount =@reslt + isnull((select sum(a.quantity)  from rsvsrc_till a,master_till b
						where  a.accnt=b.accnt and b.sta='R' and datediff(dd,b.bdate,@bdate)=0 ),0 )
						where class='daybook'
-----------------------------------------------------------------------------------------
--- 从gststa1统计境外境内人数----
--update audit_impdata set amount = dtt + dgt from gststa1
--        where class='zougstno'  and gclass='20'
--update audit_impdata set amount = dtt + dgt from gststa1
--       where class='zingstno'  and gclass='30'
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- 餐饮收款分类合计 
-- 人民币
update audit_impdata set amount = isnull((select sum(a.creditd) from deptdai a, basecode b where charindex(rtrim(a.paycode),b.descript1)>0 and b.cat ='pos_pay_sort' and b.code='001' and a.shift='9' and a.empno='{{{'), 0)
	where class='pospay01'
-- 支票
update audit_impdata set amount = isnull((select sum(a.creditd) from deptdai a, basecode b where charindex(rtrim(a.paycode),b.descript1)>0 and b.cat ='pos_pay_sort' and b.code='003' and a.shift='9' and a.empno='{{{'), 0)
	where class='pospay03'
-- 人民币卡
update audit_impdata set amount = isnull((select sum(a.creditd) from deptdai a, basecode b where charindex(rtrim(a.paycode),b.descript1)>0 and b.cat ='pos_pay_sort' and b.code='004' and a.shift='9' and a.empno='{{{'), 0)
	where class='pospay04'
-- 外汇卡
update audit_impdata set amount = isnull((select sum(a.creditd) from deptdai a, basecode b where charindex(rtrim(a.paycode),b.descript1)>0 and b.cat ='pos_pay_sort' and b.code='005' and a.shift='9' and a.empno='{{{'), 0)
	where class='pospay05'
-----------------------------------------------------------------------------------------

exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday ='T'
	update audit_impdata set amount_m = 0
if @isyfstday ='T'
	update audit_impdata set amount_m = 0,amount_y=0

update audit_impdata set amount_m = amount_m  +  amount,amount_y = amount_y  +  amount, date = @bdate
	where charindex('%', class) = 0
delete yaudit_impdata where date = @bdate
insert yaudit_impdata select * from audit_impdata
return 0
;