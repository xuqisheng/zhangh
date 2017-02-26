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
--�������1:����Ԥ�����صĿ�ʼʱ�����Ԥ���Ŀ�ʼʱ��С������ʱ�����Ԥ���Ŀ�ʼʱ���,���Ҳ��ܹ���(share='0')��Ԥ����Ч(status='R')
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute, - setup,begindate)<@nbegindate and dateadd(minute, setdown,enddate)>@nbegindate and spaceid=@space  and (status='R' or status='W')

--�������2:����Ԥ�����صĿ�ʼʱ�����Ԥ���Ŀ�ʼʱ��󣬿�ʼʱ�����Ԥ���Ľ���ʱ��С,���Ҳ��ܹ���(share='0')��Ԥ����Ч(status='R')
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)>@nbegindate and dateadd(minute,-setup,begindate)<@nenddate  and spaceid=@space  and (status='R' or status='W')

--�������3:����Ԥ�����صĿ�ʼʱ�����Ԥ���Ľ���ʱ��С,����ʱ�����Ԥ���Ľ���ʱ���,���Ҳ��ܹ���(share='0')��Ԥ����Ч(status='R')
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)<@nenddate and dateadd(minute,setdown,enddate)>@nenddate   and spaceid=@space  and (status='R' or status='W')

--�������4:�����غ�
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)=@nbegindate and dateadd(minute,setdown,enddate)=@nenddate   and spaceid=@space  and (status='R' or status='W')

--ά�����1:����ά�޳��صĿ�ʼʱ�����Ԥ���Ŀ�ʼʱ��С������ʱ�����Ԥ���Ŀ�ʼʱ���
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate<@nbegindate and enddate>@nbegindate and spaceid=@space and status='M'

--ά�����2:����ά�޳��صĿ�ʼʱ�����Ԥ���Ŀ�ʼʱ��󣬽���ʱ�����Ԥ���Ľ���ʱ��С
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate>@nbegindate and enddate<@nenddate and spaceid=@space   and status='M'

--ά�����3:����ά�޳��صĿ�ʼʱ�����Ԥ���Ľ���ʱ��С,����ʱ�����Ԥ���Ľ���ʱ���
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate<@nenddate and enddate>@nenddate and spaceid=@space  and status='M'

--ά�����4:�����غ�
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate=@nbegindate and enddate>@nenddate and spaceid=@space  and status='M'

--�жϳ����Ƿ��г�ͻ
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
