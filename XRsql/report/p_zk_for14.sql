
if exists (select * from sysobjects where name ='p_zk_for14' and type ='P')
	drop proc p_zk_for14;
create proc p_zk_for14
	@cday			datetime,
	@type				char(100)
	
as
	
---------------------------------------------
-- 三个月预测报表
---------------------------------------------
declare
	@mon1s				datetime,
	@mon1e				datetime,
	@mon2s				datetime,
	@mon2e				datetime,
	@mon3s				datetime,
	@mon3e				datetime,
	@lmon1s				datetime,
	@lmon1e				datetime,
	@lmon2s				datetime,
	@lmon2e				datetime,
	@lmon3s				datetime,
	@lmon3e				datetime,
	@ys					datetime,
	@lys					datetime,
	@ye					datetime,
	@lye					datetime
	
select @mon1s=convert(datetime,substring(convert(char(8),dateadd(mm,-1,@cday),112),1,6)+'01')
select @mon1e=dateadd(dd,-1,dateadd(mm,1,convert(datetime,substring(convert(char(8),dateadd(mm,-1,@cday),112),1,6)+'01')))
select @mon2s=convert(datetime,substring(convert(char(8),dateadd(mm,0,@cday),112),1,6)+'01')
select @mon2e=dateadd(dd,-1,dateadd(mm,1,convert(datetime,substring(convert(char(8),dateadd(mm,0,@cday),112),1,6)+'01')))
select @mon3s=convert(datetime,substring(convert(char(8),dateadd(mm,1,@cday),112),1,6)+'01')
select @mon3e=dateadd(dd,-1,dateadd(mm,1,convert(datetime,substring(convert(char(8),dateadd(mm,1,@cday),112),1,6)+'01')))

select @lmon1s=dateadd(yy,-1,@mon1s)
select @lmon1e=dateadd(yy,-1,@mon1e)
select @lmon2s=dateadd(yy,-1,@mon2s)
select @lmon2e=dateadd(yy,-1,@mon2e)
select @lmon3s=dateadd(yy,-1,@mon3s)
select @lmon3e=dateadd(yy,-1,@mon3e)

select @ys = convert(datetime,substring(convert(char(8),@cday,112),1,4)+'0101')
select @ye = convert(datetime,substring(convert(char(8),@cday,112),1,4)+'1231')
select @lys = convert(datetime,substring(convert(char(8),dateadd(yy,-1,@cday),112),1,4)+'0101')
select @lye = convert(datetime,substring(convert(char(8),dateadd(yy,-1,@cday),112),1,4)+'1231')


--
create table #temp  ( dd  char(1),
							 mkt	char(10),
							 rm    money  not null,
							 rev   money  not null,
							 av	money  not null)


create table #for14 ( mkt  char(10)  not null,
							 type  char(10) not null,
							 lm1a   money  not null,
							 m1a	money  not null,
							 m1b		money		 not null,
							 lm2a   money  not null,
							 m2a	money  not null,
							 m2b		money		 not null,
							 lm3a   money  not null,
							 m3a	money  not null,
							 m3b		money		 not null,
							 lya   money  not null,
							 ya	money  not null,
							 yb		money		 not null,
							 seq	int	)

insert #for14 select code,'RN',0,0,0,0,0,0,0,0,0,0,0,0,0 from mktcode order by sequence ,code
insert #for14 select code,'REV',0,0,0,0,0,0,0,0,0,0,0,0,0 from mktcode order by sequence ,code
insert #for14 select code,'AVR',0,0,0,0,0,0,0,0,0,0,0,0,0 from mktcode order by sequence ,code
insert #for14 select '总计:','RN',0,0,0,0,0,0,0,0,0,0,0,0,1 
insert #for14 select '总计:','REV',0,0,0,0,0,0,0,0,0,0,0,0,1 
insert #for14 select '总计:','AVR',0,0,0,0,0,0,0,0,0,0,0,0,1 

insert #temp select '1',code,0,0,0 from mktcode order by sequence ,code
insert #temp select '2',code,0,0,0 from mktcode order by sequence ,code
insert #temp select '3',code,0,0,0 from mktcode order by sequence ,code
insert #temp select 'y',code,0,0,0 from mktcode order by sequence ,code
insert #temp select '4',code,0,0,0 from mktcode order by sequence ,code
insert #temp select '5',code,0,0,0 from mktcode order by sequence ,code
insert #temp select '6',code,0,0,0 from mktcode order by sequence ,code
insert #temp select 'z',code,0,0,0 from mktcode order by sequence ,code

//去年统计
update #temp set rm = (select isnull(sum(quantity),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lmon1s and bdate <=@lmon1e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%'))
					, rev=(select isnull(sum(charge),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lmon1s and bdate <=@lmon1e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='1'
update #temp set rm = rm +(select isnull(sum(quantity),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lmon1s and bdate <=@lmon1e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%'))
					, rev = rev +(select isnull(sum(charge),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lmon1s and bdate <=@lmon1e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='1'
update #temp set rm = (select isnull(sum(quantity),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lmon2s and bdate <=@lmon2e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%'))
					, rev = (select isnull(sum(charge),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lmon2s and bdate <=@lmon2e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='2'
update #temp set rm = rm +(select isnull(sum(quantity),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lmon2s and bdate <=@lmon2e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%'))
					, rev = rev +(select isnull(sum(charge),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lmon2s and bdate <=@lmon2e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='2'
update #temp set rm = (select isnull(sum(quantity),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lmon3s and bdate <=@lmon3e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) 
					, rev = (select isnull(sum(charge),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lmon3s and bdate <=@lmon3e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='3'
update #temp set rm = rm+(select isnull(sum(quantity),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lmon3s and bdate <=@lmon3e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) 
					, rev = rev+(select isnull(sum(charge),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lmon3s and bdate <=@lmon3e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='3'
update #temp set rm = rm+(select isnull(sum(quantity),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lys and bdate <=@lye and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) 
					, rev = rev+(select isnull(sum(charge),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lys and bdate <=@lye and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='y'
update #temp set rm = rm+(select isnull(sum(quantity),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lys and bdate <=@lye and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) 
					, rev = rev+(select isnull(sum(charge),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@lys and bdate <=@lye and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='y'
//今年统计
update #temp set rm = (select isnull(sum(quantity),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@mon1s and bdate <=@mon1e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%'))
					, rev=(select isnull(sum(charge),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@mon1s and bdate <=@mon1e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='4'
update #temp set rm = rm +(select isnull(sum(quantity),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@mon1s and bdate <=@mon1e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%'))
					, rev = rev +(select isnull(sum(charge),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@mon1s and bdate <=@mon1e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='4'
update #temp set rm = (select isnull(sum(quantity),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@mon2s and bdate <=@mon2e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%'))
					, rev = (select isnull(sum(charge),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@mon2s and bdate <=@mon2e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='5'
update #temp set rm = rm +(select isnull(sum(quantity),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@mon2s and bdate <=@mon2e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%'))
					, rev = rev +(select isnull(sum(charge),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@mon2s and bdate <=@mon2e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='5'
update #temp set rm = (select isnull(sum(quantity),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@mon3s and bdate <=@mon3e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) 
					, rev = (select isnull(sum(charge),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@mon3s and bdate <=@mon3e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='6'
update #temp set rm = rm+(select isnull(sum(quantity),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@mon3s and bdate <=@mon3e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) 
					, rev = rev+(select isnull(sum(charge),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@mon3s and bdate <=@mon3e and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='6'
update #temp set rm = rm+(select isnull(sum(quantity),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@ys and bdate <=@ye and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) 
					, rev = rev+(select isnull(sum(charge),0) from account where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@ys and bdate <=@ye and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='z'
update #temp set rm = rm+(select isnull(sum(quantity),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@ys and bdate <=@ye and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) 
					, rev = rev+(select isnull(sum(charge),0) from haccount where (substring(mode,1,1) in ('J','j','P','N','B','b')) and substring(mode,2,1)>='0' and  substring(mode,2,1)<='9'  and bdate >=@ys and bdate <=@ye and billno<>'' and tag=#temp.mkt and roomno in (select roomno from rmsta where charindex(rtrim(type),@type)>0 or @type='%')) where dd='z'



update #temp set av = rev / rm where rm >0

update #for14 set lm1a = #temp.rm from #temp where #for14.type='RN' and #temp.mkt=#for14.mkt and #temp.dd='1'
update #for14 set lm1a = #temp.rev from #temp where #for14.type='REV' and #temp.mkt=#for14.mkt and #temp.dd='1'
update #for14 set lm1a = #temp.av from #temp where #for14.type='AVR' and #temp.mkt=#for14.mkt and #temp.dd='1'
update #for14 set lm2a = #temp.rm from #temp where #for14.type='RN' and #temp.mkt=#for14.mkt and #temp.dd='2'
update #for14 set lm2a = #temp.rev from #temp where #for14.type='REV' and #temp.mkt=#for14.mkt and #temp.dd='2'
update #for14 set lm2a = #temp.av from #temp where #for14.type='AVR' and #temp.mkt=#for14.mkt and #temp.dd='2'
update #for14 set lm3a = #temp.rm from #temp where #for14.type='RN' and #temp.mkt=#for14.mkt and #temp.dd='3'
update #for14 set lm3a = #temp.rev from #temp where #for14.type='REV' and #temp.mkt=#for14.mkt and #temp.dd='3'
update #for14 set lm3a = #temp.av from #temp where #for14.type='AVR' and #temp.mkt=#for14.mkt and #temp.dd='3'
update #for14 set lya = #temp.rm from #temp where #for14.type='RN' and #temp.mkt=#for14.mkt and #temp.dd='y'
update #for14 set lya = #temp.rev from #temp where #for14.type='REV' and #temp.mkt=#for14.mkt and #temp.dd='y'
update #for14 set lya = #temp.av from #temp where #for14.type='AVR' and #temp.mkt=#for14.mkt and #temp.dd='y'

update #for14 set lm1a = isnull((select sum(rm) from #temp where dd='1'),0) where #for14.type='RN' and #for14.mkt = '总计:'
update #for14 set lm1a = isnull((select sum(rev) from #temp where dd='1'),0) where #for14.type='REV' and #for14.mkt = '总计:'
update #for14 set lm2a = isnull((select sum(rm) from #temp where dd='2'),0) where #for14.type='RN' and #for14.mkt = '总计:'
update #for14 set lm2a = isnull((select sum(rev) from #temp where dd='2'),0) where #for14.type='REV' and #for14.mkt = '总计:'
update #for14 set lm3a = isnull((select sum(rm) from #temp where dd='3'),0) where #for14.type='RN' and #for14.mkt = '总计:'
update #for14 set lm3a = isnull((select sum(rev) from #temp where dd='3'),0) where #for14.type='REV' and #for14.mkt = '总计:'
update #for14 set lya = isnull((select sum(rm) from #temp where dd='y'),0) where #for14.type='RN' and #for14.mkt = '总计:'
update #for14 set lya = isnull((select sum(rev) from #temp where dd='y'),0) where #for14.type='REV' and #for14.mkt = '总计:'

update #for14 set lm1a = (select lm1a from #for14 where mkt='总计:' and type='REV')/isnull((select lm1a from #for14 where mkt='总计:' and type='RN' and lm1a<>0),1)
		where mkt='总计:' and type='AVR' 
update #for14 set lm2a = (select lm2a from #for14 where mkt='总计:' and type='REV')/isnull((select lm2a from #for14 where mkt='总计:' and type='RN' and lm2a<>0),1)
		where mkt='总计:' and type='AVR' 
update #for14 set lm3a = (select lm3a from #for14 where mkt='总计:' and type='REV')/isnull((select lm3a from #for14 where mkt='总计:' and type='RN' and lm3a<>0),1)
		where mkt='总计:' and type='AVR' 
update #for14 set lya = (select lya from #for14 where mkt='总计:' and type='REV')/isnull((select lya from #for14 where mkt='总计:' and type='RN' and lya<>0),1)
		where mkt='总计:' and type='AVR' 

update #for14 set m1a = #temp.rm from #temp where #for14.type='RN' and #temp.mkt=#for14.mkt and #temp.dd='4'
update #for14 set m1a = #temp.rev from #temp where #for14.type='REV' and #temp.mkt=#for14.mkt and #temp.dd='4'
update #for14 set m1a = #temp.av from #temp where #for14.type='AVR' and #temp.mkt=#for14.mkt and #temp.dd='4'
update #for14 set m1b = plan_def.amount1 from plan_def where plan_def.cat='market' and plan_def.item='RM' and #for14.type='RN' and rtrim(#for14.mkt)=rtrim(plan_def.clskey) and substring(period,2,6)=substring(convert(char(8),@mon1s,112),1,6)
update #for14 set m1b = plan_def.amount1 from plan_def where plan_def.cat='market' and plan_def.item='REV' and #for14.type='REV' and rtrim(#for14.mkt)=rtrim(plan_def.clskey) and substring(period,2,6)=substring(convert(char(8),@mon1s,112),1,6)
//update #for14 set m1b = plan_def.amount1 from plan_def where plan_def.cat='market' and plan_def.item='RM' and #for14.type='AVR' and rtrim(#for14.mkt)=rtrim(plan_def.clskey) and substring(period,2,6)=substring(convert(char(8),@mon1s,112),1,6)
update #for14 set m2a = #temp.rm from #temp where #for14.type='RN' and #temp.mkt=#for14.mkt and #temp.dd='5'
update #for14 set m2a = #temp.rev from #temp where #for14.type='REV' and #temp.mkt=#for14.mkt and #temp.dd='5'
update #for14 set m2a = #temp.av from #temp where #for14.type='AVR' and #temp.mkt=#for14.mkt and #temp.dd='5'
update #for14 set m2b = plan_def.amount1 from plan_def where plan_def.cat='market' and plan_def.item='RM' and #for14.type='RN' and rtrim(#for14.mkt)=rtrim(plan_def.clskey) and substring(period,2,6)=substring(convert(char(8),@mon2s,112),1,6)
update #for14 set m2b = plan_def.amount1 from plan_def where plan_def.cat='market' and plan_def.item='REV' and #for14.type='REV' and rtrim(#for14.mkt)=rtrim(plan_def.clskey) and substring(period,2,6)=substring(convert(char(8),@mon2s,112),1,6)
//update #for14 set m2b = plan_def.amount1 from plan_def where plan_def.cat='market' and plan_def.item='RM' and #for14.type='AVR' and rtrim(#for14.mkt)=rtrim(plan_def.clskey) and substring(period,2,6)=substring(convert(char(8),@mon2s,112),1,6)
update #for14 set m3a = #temp.rm from #temp where #for14.type='RN' and #temp.mkt=#for14.mkt and #temp.dd='6'
update #for14 set m3a = #temp.rev from #temp where #for14.type='REV' and #temp.mkt=#for14.mkt and #temp.dd='6'
update #for14 set m3a = #temp.av from #temp where #for14.type='AVR' and #temp.mkt=#for14.mkt and #temp.dd='6'
update #for14 set m3b = plan_def.amount1 from plan_def where plan_def.cat='market' and plan_def.item='RM' and #for14.type='RN' and rtrim(#for14.mkt)=rtrim(plan_def.clskey) and substring(period,2,6)=substring(convert(char(8),@mon3s,112),1,6)
update #for14 set m3b = plan_def.amount1 from plan_def where plan_def.cat='market' and plan_def.item='REV' and #for14.type='REV' and rtrim(#for14.mkt)=rtrim(plan_def.clskey) and substring(period,2,6)=substring(convert(char(8),@mon3s,112),1,6)
//update #for14 set m3b = plan_def.amount1 from plan_def where plan_def.cat='market' and plan_def.item='RM' and #for14.type='AVR' and rtrim(#for14.mkt)=rtrim(plan_def.clskey) and substring(period,2,6)=substring(convert(char(8),@mon3s,112),1,6)
update #for14 set ya = #temp.rm from #temp where #for14.type='RN' and #temp.mkt=#for14.mkt and #temp.dd='z'
update #for14 set ya = #temp.rev from #temp where #for14.type='REV' and #temp.mkt=#for14.mkt and #temp.dd='z'
update #for14 set ya = #temp.av from #temp where #for14.type='AVR' and #temp.mkt=#for14.mkt and #temp.dd='z'
//update #for14 set yb = plan_def.amount1 from plan_def where plan_def.cat='market' and plan_def.item='RM' and #for14.type='RN' and rtrim(#for14.mkt)=rtrim(plan_def.clskey) and substring(period,2,6)=substring(convert(char(8),@mon1s,112),1,6)
//update #for14 set yb = plan_def.amount1 from plan_def where plan_def.cat='market' and plan_def.item='REV' and #for14.type='REV' and rtrim(#for14.mkt)=rtrim(plan_def.clskey) and substring(period,2,6)=substring(convert(char(8),@mon1s,112),1,6)
//update #for14 set yb = plan_def.amount1 from plan_def where plan_def.cat='market' and plan_def.item='RM' and #for14.type='AVR' and rtrim(#for14.mkt)=rtrim(plan_def.clskey) and substring(period,2,6)=substring(convert(char(8),@mon1s,112),1,6)

update #for14 set m1a = isnull((select sum(rm) from #temp where dd='4'),0) where #for14.type='RN' and #for14.mkt = '总计:'
update #for14 set m1a = isnull((select sum(rev) from #temp where dd='4'),0) where #for14.type='REV' and #for14.mkt = '总计:'
update #for14 set m1b = isnull((select sum(amount1) from plan_def where plan_def.cat='market' and plan_def.item='RM' and substring(period,2,6)=substring(convert(char(8),@mon1s,112),1,6) ),0) where #for14.type='RN' and #for14.mkt = '总计:'
update #for14 set m1b = isnull((select sum(amount1) from plan_def where plan_def.cat='market' and plan_def.item='REV' and substring(period,2,6)=substring(convert(char(8),@mon1s,112),1,6) ),0) where #for14.type='REV' and #for14.mkt = '总计:'

update #for14 set m2a = isnull((select sum(rm) from #temp where dd='5'),0) where #for14.type='RN' and #for14.mkt = '总计:'
update #for14 set m2a = isnull((select sum(rev) from #temp where dd='5'),0) where #for14.type='REV' and #for14.mkt = '总计:'
update #for14 set m2b = isnull((select sum(amount1) from plan_def where plan_def.cat='market' and plan_def.item='RM' and substring(period,2,6)=substring(convert(char(8),@mon2s,112),1,6) ),0) where #for14.type='RN' and #for14.mkt = '总计:'
update #for14 set m2b = isnull((select sum(amount1) from plan_def where plan_def.cat='market' and plan_def.item='REV' and substring(period,2,6)=substring(convert(char(8),@mon2s,112),1,6) ),0) where #for14.type='REV' and #for14.mkt = '总计:'
update #for14 set m3a = isnull((select sum(rm) from #temp where dd='6'),0) where #for14.type='RN' and #for14.mkt = '总计:'
update #for14 set m3a = isnull((select sum(rev) from #temp where dd='6'),0) where #for14.type='REV' and #for14.mkt = '总计:'
update #for14 set m3b = isnull((select sum(amount1) from plan_def where plan_def.cat='market' and plan_def.item='RM' and substring(period,2,6)=substring(convert(char(8),@mon3s,112),1,6) ),0) where #for14.type='RN' and #for14.mkt = '总计:'
update #for14 set m3b = isnull((select sum(amount1) from plan_def where plan_def.cat='market' and plan_def.item='REV' and substring(period,2,6)=substring(convert(char(8),@mon3s,112),1,6) ),0) where #for14.type='REV' and #for14.mkt = '总计:'
update #for14 set ya = isnull((select sum(rm) from #temp where dd='z'),0) where #for14.type='RN' and #for14.mkt = '总计:'
update #for14 set ya = isnull((select sum(rev) from #temp where dd='z'),0) where #for14.type='REV' and #for14.mkt = '总计:'

update #for14 set m1a = (select m1a from #for14 where mkt='总计:' and type='REV')/isnull((select m1a from #for14 where mkt='总计:' and type='RN' and m1a<>0),1)
		where mkt='总计:' and type='AVR' 
update #for14 set m2a = (select m2a from #for14 where mkt='总计:' and type='REV')/isnull((select m2a from #for14 where mkt='总计:' and type='RN' and m2a<>0),1)
		where mkt='总计:' and type='AVR' 
update #for14 set m3a = (select m3a from #for14 where mkt='总计:' and type='REV')/isnull((select m3a from #for14 where mkt='总计:' and type='RN' and m3a<>0),1)
		where mkt='总计:' and type='AVR' 
update #for14 set ya = (select ya from #for14 where mkt='总计:' and type='REV')/isnull((select ya from #for14 where mkt='总计:' and type='RN' and ya<>0),1)
		where mkt='总计:' and type='AVR' 



select * from #for14 order by seq,mkt,type
;




