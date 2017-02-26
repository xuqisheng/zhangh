IF OBJECT_ID('dbo.p_sc_spacecheck_sta') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_spacecheck_sta
    IF OBJECT_ID('dbo.p_sc_spacecheck_sta') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_spacecheck_sta >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_spacecheck_sta >>>'
END
;
create procedure p_sc_spacecheck_sta
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
@restrict_sta  varchar(255)

create table #spaceid
(
 spaceid char(10),
 evtresno char(10)
)

select @nbegindate=dateadd(minute,- @setup,@begindate)
select @nenddate  =dateadd(minute,  @setdown,@enddate)
--交叉情况1:已有预定场地的开始时间比新预定的开始时间小，结束时间比新预定的开始时间大,并且不能共享(share='0')和预定有效(status='R')
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute, - setup,begindate)<@nbegindate and dateadd(minute, setdown,enddate)>@nbegindate and spaceid=@space  and (status='R' or status='W')

--交叉情况2:已有预定场地的开始时间比新预定的开始时间大，开始时间比新预定的结束时间小,并且不能共享(share='0')和预定有效(status='R')
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)>@nbegindate and dateadd(minute,-setup,begindate)<@nenddate  and spaceid=@space  and (status='R' or status='W')

--交叉情况3:已有预定场地的开始时间比新预定的结束时间小,结束时间比新预定的结束时间大,并且不能共享(share='0')和预定有效(status='R')
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)<@nenddate and dateadd(minute,setdown,enddate)>@nenddate   and spaceid=@space  and (status='R' or status='W')

--交叉情况4:正好重合
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)=@nbegindate and dateadd(minute,setdown,enddate)=@nenddate   and spaceid=@space  and (status='R' or status='W')

--维修情况1:已有维修场地的开始时间比新预定的开始时间小，结束时间比新预定的开始时间大
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate<@nbegindate and enddate>@nbegindate and spaceid=@space and status='M'

--维修情况2:已有维修场地的开始时间比新预定的开始时间大，结束时间比新预定的结束时间小
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate>@nbegindate and enddate<@nenddate and spaceid=@space   and status='M'

--维修情况3:已有维修场地的开始时间比新预定的结束时间小,结束时间比新预定的结束时间大
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate<@nenddate and enddate>@nenddate and spaceid=@space  and status='M'

--维修情况4:正好重合
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate=@nbegindate and enddate>@nenddate and spaceid=@space  and status='M'

--判断场地是否有冲突
select @restrict_sta=value from sysoption where catalog='sc' and item='not_allow_sta'

if @evtresno='' or @evtresno is null
   select count(1)  from #spaceid a,sc_eventreservation b where a.evtresno=b.evtresno and  charindex(b.restype,@restrict_sta)>0
else
   select count(distinct (a.spaceid+a.evtresno)) from #spaceid a, sc_eventreservation b where a.evtresno=b.evtresno and  charindex(b.restype,@restrict_sta)>0 and a.evtresno<>@evtresno
;
IF OBJECT_ID('dbo.p_sc_spacecheck_sta') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_spacecheck_sta >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_spacecheck_sta >>>'
;
