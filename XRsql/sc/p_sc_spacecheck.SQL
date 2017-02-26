if object_id('p_sc_spacecheck') is not null
drop proc p_sc_spacecheck
;
create procedure p_sc_spacecheck
    @space     char(10),
    @begindate datetime,
    @enddate   datetime,
    @setup     money,
    @setdown   money,
    @evtresno  char(10)
as
declare
@nbegindate datetime,
@nenddate   datetime,
@spaceid    char(10),
@count      integer,
@subspaces  varchar(100)

create table #spaceid
(
 spaceid char(10),
 evtresno char(10)
)

select @subspaces=spacearound from sc_spaces where spaceid=@space

select @nbegindate=dateadd(minute,- @setup,@begindate)
select @nenddate  =dateadd(minute,  @setdown,@enddate)
--交叉情况1:已有预定场地的开始时间比新预定的开始时间小，结束时间比新预定的开始时间大,并且不能共享(share='0')和预定有效(status='R')
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute, - setup,begindate)<@nbegindate and dateadd(minute, setdown,enddate)>@nbegindate and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and (status='R' or status='W')

--交叉情况2:已有预定场地的开始时间比新预定的开始时间大，开始时间比新预定的结束时间小,并且不能共享(share='0')和预定有效(status='R')
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)>@nbegindate and dateadd(minute,-setup,begindate)<@nenddate  and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and (status='R' or status='W')

--交叉情况3:已有预定场地的开始时间比新预定的结束时间小,结束时间比新预定的结束时间大,并且不能共享(share='0')和预定有效(status='R')
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)<@nenddate and dateadd(minute,setdown,enddate)>@nenddate   and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and (status='R' or status='W')



--fgh交叉情况 5 开始时间相等,结束时间不=
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)=@nbegindate and dateadd(minute,setdown,enddate)<@nenddate   and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and (status='R' or status='W')




--交叉情况4:正好重合
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)=@nbegindate and dateadd(minute,setdown,enddate)=@nenddate   and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and (status='R' or status='W')

--维修情况1:已有维修场地的开始时间比新预定的开始时间小，结束时间比新预定的开始时间大
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate<@nbegindate and enddate>@nbegindate and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0) and status='M'

--维修情况2:已有维修场地的开始时间比新预定的开始时间大，结束时间比新预定的结束时间小
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate>@nbegindate and enddate<@nenddate and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)   and status='M'

--维修情况3:已有维修场地的开始时间比新预定的结束时间小,结束时间比新预定的结束时间大
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate<@nenddate and enddate>@nenddate and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and status='M'

--维修情况4:正好重合
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate=@nbegindate and enddate>@nenddate and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and status='M'

--判断场地是否有冲突
if @evtresno='' or @evtresno is null
   select count(1)  from #spaceid
else
   select count(distinct (spaceid+evtresno)) from #spaceid where evtresno<>@evtresno
;