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
--�������1:����Ԥ�����صĿ�ʼʱ�����Ԥ���Ŀ�ʼʱ��С������ʱ�����Ԥ���Ŀ�ʼʱ���,���Ҳ��ܹ���(share='0')��Ԥ����Ч(status='R')
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute, - setup,begindate)<@nbegindate and dateadd(minute, setdown,enddate)>@nbegindate and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and (status='R' or status='W')

--�������2:����Ԥ�����صĿ�ʼʱ�����Ԥ���Ŀ�ʼʱ��󣬿�ʼʱ�����Ԥ���Ľ���ʱ��С,���Ҳ��ܹ���(share='0')��Ԥ����Ч(status='R')
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)>@nbegindate and dateadd(minute,-setup,begindate)<@nenddate  and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and (status='R' or status='W')

--�������3:����Ԥ�����صĿ�ʼʱ�����Ԥ���Ľ���ʱ��С,����ʱ�����Ԥ���Ľ���ʱ���,���Ҳ��ܹ���(share='0')��Ԥ����Ч(status='R')
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)<@nenddate and dateadd(minute,setdown,enddate)>@nenddate   and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and (status='R' or status='W')



--fgh������� 5 ��ʼʱ�����,����ʱ�䲻=
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)=@nbegindate and dateadd(minute,setdown,enddate)<@nenddate   and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and (status='R' or status='W')




--�������4:�����غ�
insert #spaceid  select distinct spaceid,resno from sc_spacereservation where dateadd(minute,-setup,begindate)=@nbegindate and dateadd(minute,setdown,enddate)=@nenddate   and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and (status='R' or status='W')

--ά�����1:����ά�޳��صĿ�ʼʱ�����Ԥ���Ŀ�ʼʱ��С������ʱ�����Ԥ���Ŀ�ʼʱ���
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate<@nbegindate and enddate>@nbegindate and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0) and status='M'

--ά�����2:����ά�޳��صĿ�ʼʱ�����Ԥ���Ŀ�ʼʱ��󣬽���ʱ�����Ԥ���Ľ���ʱ��С
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate>@nbegindate and enddate<@nenddate and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)   and status='M'

--ά�����3:����ά�޳��صĿ�ʼʱ�����Ԥ���Ľ���ʱ��С,����ʱ�����Ԥ���Ľ���ʱ���
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate<@nenddate and enddate>@nenddate and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and status='M'

--ά�����4:�����غ�
insert #spaceid  select distinct spaceid,'##########' from sc_spacemaintain where begindate=@nbegindate and enddate>@nenddate and (spaceid=@space or charindex(rtrim(spaceid),@subspaces)>0)  and status='M'

--�жϳ����Ƿ��г�ͻ
if @evtresno='' or @evtresno is null
   select count(1)  from #spaceid
else
   select count(distinct (spaceid+evtresno)) from #spaceid where evtresno<>@evtresno
;