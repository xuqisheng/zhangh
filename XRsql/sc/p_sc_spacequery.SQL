if object_id('p_sc_spacequery') is not null
drop proc p_sc_spacequery
;
create procedure p_sc_spacequery
    @begindate datetime,
    @enddate    datetime,
    @noisy     char(3),
    @setup     money,
    @setdown   money

as
declare
@nbegindate datetime,
@nenddate   datetime,
@spaceid    char(10),
@count     money

create table #spaceid
(
 spaceid char(10),
 status  char(3)
)

select @nbegindate=dateadd(hour,- @setup,@begindate)
select @nenddate  =dateadd(hour,  @setdown,@enddate)
--交叉情况1:已有预定场地的开始时间比新预定的开始时间小，结束时间比新预定的开始时间大，并且不能共享(share='0')和预定有效(status='R')
insert #spaceid  select distinct spaceid,status from sc_spacereservation where dateadd(minute, - setup,begindate)<@nbegindate and dateadd(minute, setdown,enddate)>@nbegindate and  (status='R' or status='W')

--交叉情况2:已有预定场地的开始时间比新预定的开始时间大，开始时间比新预定的结束时间小，并且不能共享(share='0')和预定有效(status='R')
insert #spaceid  select distinct spaceid,status from sc_spacereservation where dateadd(minute,-setup,begindate)>@nbegindate and dateadd(minute,-setup,begindate)<@nenddate and  (status='R' or status='W')

--交叉情况3:已有预定场地的开始时间比新预定的结束时间小,结束时间比新预定的结束时间大，并且不能共享(share='0')和预定有效(status='R')
insert #spaceid  select distinct spaceid,status from sc_spacereservation where dateadd(minute,-setup,begindate)<@nenddate and dateadd(minute,setdown,enddate)>@nenddate and  (status='R' or status='W')

--交叉情况4:正好重合
insert #spaceid  select distinct spaceid,status from sc_spacereservation where dateadd(minute,-setup,begindate)=@nbegindate and dateadd(minute,setdown,enddate)=@nenddate   and  (status='R' or status='W')
--fgh交叉情况 5 开始时间相等,结束时间不=
insert #spaceid  select distinct spaceid,status from sc_spacereservation where dateadd(minute,-setup,begindate)=@nbegindate and dateadd(minute,setdown,enddate)<@nenddate     and (status='R' or status='W')

--维修情况1:已有维修场地的开始时间比新预定的开始时间小，结束时间比新预定的开始时间大
insert #spaceid  select distinct spaceid,status from sc_spacemaintain where begindate<@nbegindate and enddate>@nbegindate and status='M'

--维修情况2:已有维修场地的开始时间比新预定的开始时间大，结束时间比新预定的结束时间小
insert #spaceid  select distinct spaceid,status from sc_spacemaintain where begindate>@nbegindate and enddate<@nenddate   and status='M'

--维修情况3:已有维修场地的开始时间比新预定的结束时间小,结束时间比新预定的结束时间大
insert #spaceid  select distinct spaceid,status from sc_spacemaintain where begindate<@nenddate and enddate>@nenddate  and status='M'

--维修情况4:正好重合
insert #spaceid  select distinct spaceid,status from sc_spacemaintain where begindate=@nbegindate and enddate>@nenddate and status='M'

--满足条件的场地
update sc_spaces set status='F'

update sc_spaces set status='R' where spaceid in (select spaceid from #spaceid where status='R')
update sc_spaces set status='W' where spaceid in (select spaceid from #spaceid where status='W')
update sc_spaces set status='M' where spaceid in (select spaceid from #spaceid where status='M')

--select @count=count(1) from #spaceid

--if @count is null
--	select spaceid,descript1,descript2 from sc_spaces where  halt<>'1' and noisy<=@noisy
--else
--	select spaceid,descript1,descript2 from sc_spaces where spaceid not in (select distinct spaceid from #spaceid) and halt<>'1' and noisy<=@noisy
select a.spaceid,a.descript1,a.descript2,a.status,max(b.recommendation) from sc_spaces a,sc_spaceproperty b where  a.halt<>'1' and b.spaceid=a.spaceid group by all a.spaceid order by a.sequence,max(b.recommendation) desc
;