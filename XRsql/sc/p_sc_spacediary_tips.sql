IF OBJECT_ID('dbo.p_sc_spacediary_tips') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_spacediary_tips
    IF OBJECT_ID('dbo.p_sc_spacediary_tips') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_spacediary_tips >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_spacediary_tips >>>'
END
;
create procedure p_sc_spacediary_tips
    @begindate datetime,
    @enddate   datetime,
    @spaceid   char(10)
as
declare
@nbegindate datetime,
@nenddate   datetime


create table #spaceid
(
 sno     char(10) null,
 spaceid char(10) null,
 begindate datetime null,
 enddate   datetime null,
 setup     money null,
 setdown   money null,
 status    char(3) null,
 cat      datetime null,
 restype   varchar(5) null,
 descript  varchar(255)

)

select @nbegindate=@begindate
select @nenddate  =@enddate

insert #spaceid  select  resno,spaceid,begindate,enddate,setup,setdown,status,createdat,restype,'descript' from sc_spacereservation where dateadd(minute, - setup,begindate)<=@nbegindate and dateadd(minute, setdown,enddate)>=@nbegindate and (status='R' or status='W') and spaceid=@spaceid


insert #spaceid  select  resno,spaceid,begindate,enddate,setup,setdown,status,createdat,restype,'descript' from sc_spacereservation where dateadd(minute,-setup,begindate)>=@nbegindate and dateadd(minute,-setup,begindate)<=@nenddate  and  (status='R' or status='W')  and spaceid=@spaceid


insert #spaceid  select  resno,spaceid,begindate,enddate,setup,setdown,status,createdat,restype,'descript' from sc_spacereservation where dateadd(minute,-setup,begindate)<=@nenddate and dateadd(minute,setdown,enddate)>=@nenddate  and (status='R' or status='W')  and spaceid=@spaceid


insert #spaceid (sno,spaceid,begindate,enddate,status,descript) select  folio,spaceid,begindate,enddate,status,'Î¬ÐÞ' from sc_spacemaintain where begindate<=@nbegindate and enddate>=@nbegindate and  status='M'  and spaceid=@spaceid


insert #spaceid (sno,spaceid,begindate,enddate,status,descript) select  folio,spaceid,begindate,enddate,status,'Î¬ÐÞ' from sc_spacemaintain where begindate>=@nbegindate and enddate<=@nenddate   and status='M'  and spaceid=@spaceid



insert #spaceid (sno,spaceid,begindate,enddate,status,descript) select  folio,spaceid,begindate,enddate,status,'Î¬ÐÞ' from sc_spacemaintain where begindate<=@nenddate and enddate>=@nenddate  and status='M'  and spaceid=@spaceid

//update #spaceid a set a.descript=b.descript1 from sc_eventreservation b where a.sno=b.evtresno;
update #spaceid set a.descript=(select descript1 from sc_eventreservation where #spaceid.sno=sc_eventreservation.evtresno)

select distinct sno,spaceid,begindate,enddate,setup,setdown,status,cat,restype,descript  from #spaceid order by cat desc
;
IF OBJECT_ID('dbo.p_sc_spacediary_tips') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_spacediary_tips >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_spacediary_tips >>>'
;
