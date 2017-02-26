IF OBJECT_ID('dbo.p_sc_spacenwtlist') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_spacenwtlist
    IF OBJECT_ID('dbo.p_sc_spacenwtlist') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_spacenwtlist >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_spacenwtlist >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_spacenwtlist
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
@count      integer

create table #spaceid
(
 spaceid char(10) null,
 evtresno char(10) null,
 accnt    char(10) null,
 evttype  varchar(10) null,
 begindate datetime null,
 enddate   datetime null,
 fatten    money      null,
 gatten   money      null,
 layout    char(10) null,
 cby       varchar(12) null,
 cat       datetime    null
)

select @nbegindate=dateadd(minute,- @setup,@begindate)
select @nenddate  =dateadd(minute,  @setdown,@enddate)
--�������1:����Ԥ�����صĿ�ʼʱ�����Ԥ���Ŀ�ʼʱ��С������ʱ�����Ԥ���Ŀ�ʼʱ���,���Ҳ��ܹ���(share='0')��Ԥ����Ч(status='R')
insert #spaceid  select  a.spaceid,a.resno,a.account,b.eventtype,a.begindate,a.enddate,b.fattendees,b.gattendees,a.layout,a.cby,a.createdat from sc_spacereservation a,sc_eventreservation b where dateadd(minute, - a.setup,a.begindate)<@nbegindate and dateadd(minute, a.setdown,a.enddate)>@nbegindate and a.spaceid=@space  and (a.status='R' or a.status='W') and a.resno=b.evtresno

--�������2:����Ԥ�����صĿ�ʼʱ�����Ԥ���Ŀ�ʼʱ��󣬿�ʼʱ�����Ԥ���Ľ���ʱ��С,���Ҳ��ܹ���(share='0')��Ԥ����Ч(status='R')
insert #spaceid  select  a.spaceid,a.resno,a.account,b.eventtype,a.begindate,a.enddate,b.fattendees,b.gattendees,a.layout,a.cby,a.createdat from sc_spacereservation a,sc_eventreservation b where dateadd(minute, - a.setup,a.begindate)>@nbegindate and dateadd(minute,-a.setup,a.begindate)<@nenddate  and a.spaceid=@space  and (a.status='R' or a.status='W') and a.resno=b.evtresno

--�������3:����Ԥ�����صĿ�ʼʱ�����Ԥ���Ľ���ʱ��С,����ʱ�����Ԥ���Ľ���ʱ���,���Ҳ��ܹ���(share='0')��Ԥ����Ч(status='R')
insert #spaceid  select  a.spaceid,a.resno,a.account,b.eventtype,a.begindate,a.enddate,b.fattendees,b.gattendees,a.layout,a.cby,a.createdat from sc_spacereservation a,sc_eventreservation b where dateadd(minute,- a.setup,a.begindate)<@nenddate and dateadd(minute,a.setdown,a.enddate)>@nenddate   and a.spaceid=@space  and (a.status='R' or a.status='W') and a.resno=b.evtresno

--�������4:�����غ�
insert #spaceid  select  a.spaceid,a.resno,a.account,b.eventtype,a.begindate,a.enddate,b.fattendees,b.gattendees,a.layout,a.cby,a.createdat from sc_spacereservation a,sc_eventreservation b where dateadd(minute,-a.setup,a.begindate)=@nbegindate and dateadd(minute,a.setdown,a.enddate)=@nenddate   and a.spaceid=@space  and (a.status='R' or a.status='W') and a.resno=b.evtresno

--ά�����1:����ά�޳��صĿ�ʼʱ�����Ԥ���Ŀ�ʼʱ��С������ʱ�����Ԥ���Ŀ�ʼʱ���
insert #spaceid(spaceid,evtresno)  select distinct spaceid,'##########' from sc_spacemaintain where begindate<@nbegindate and enddate>@nbegindate and spaceid=@space and status='M'

--ά�����2:����ά�޳��صĿ�ʼʱ�����Ԥ���Ŀ�ʼʱ��󣬽���ʱ�����Ԥ���Ľ���ʱ��С
insert #spaceid(spaceid,evtresno)  select distinct spaceid,'##########' from sc_spacemaintain where begindate>@nbegindate and enddate<@nenddate and spaceid=@space   and status='M'

--ά�����3:����ά�޳��صĿ�ʼʱ�����Ԥ���Ľ���ʱ��С,����ʱ�����Ԥ���Ľ���ʱ���
insert #spaceid(spaceid,evtresno)  select distinct spaceid,'##########' from sc_spacemaintain where begindate<@nenddate and enddate>@nenddate and spaceid=@space  and status='M'

--ά�����4:�����غ�
insert #spaceid(spaceid,evtresno)  select distinct spaceid,'##########' from sc_spacemaintain where begindate=@nbegindate and enddate>@nenddate and spaceid=@space  and status='M'

--�жϳ����Ƿ��г�ͻ
                                       
                                           
       
                                                                    

select min(cat),evtresno from #spaceid  where evtresno<>@evtresno
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_spacenwtlist') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_spacenwtlist >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_spacenwtlist >>>'
;