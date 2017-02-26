IF OBJECT_ID('dbo.p_sc_spacediary') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_spacediary
    IF OBJECT_ID('dbo.p_sc_spacediary') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_spacediary >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_spacediary >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_spacediary
    @begindate datetime,
    @enddate   datetime
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
 sshare     char(1) null,                           
 slock      char(1) null,
 cat      datetime null,
 restype   varchar(5) null
 
)

select @nbegindate=@begindate
select @nenddate  =@enddate
                                                                                                                                   
insert #spaceid  select  resno,spaceid,begindate,enddate,setup,setdown,status,sshare,slock,createdat,restype from sc_spacereservation where dateadd(minute, - setup,begindate)<=@nbegindate and dateadd(minute, setdown,enddate)>=@nbegindate and (status='R' or status='W')

                                                                                                                                   
insert #spaceid  select  resno,spaceid,begindate,enddate,setup,setdown,status,sshare,slock,createdat,restype from sc_spacereservation where dateadd(minute,-setup,begindate)>=@nbegindate and dateadd(minute,-setup,begindate)<=@nenddate  and  (status='R' or status='W')

                                                                                                                                  
insert #spaceid  select  resno,spaceid,begindate,enddate,setup,setdown,status,sshare,slock,createdat,restype from sc_spacereservation where dateadd(minute,-setup,begindate)<=@nenddate and dateadd(minute,setdown,enddate)>=@nenddate  and (status='R' or status='W')

                                                                                     
insert #spaceid (sno,spaceid,begindate,enddate,status) select  folio,spaceid,begindate,enddate,status from sc_spacemaintain where begindate<=@nbegindate and enddate>=@nbegindate and  status='M'

                                                                                     
insert #spaceid (sno,spaceid,begindate,enddate,status) select  folio,spaceid,begindate,enddate,status from sc_spacemaintain where begindate>=@nbegindate and enddate<=@nenddate   and status='M'

                                                                                    

insert #spaceid (sno,spaceid,begindate,enddate,status) select  folio,spaceid,begindate,enddate,status from sc_spacemaintain where begindate<=@nenddate and enddate>=@nenddate  and status='M'
                     
select  sno,spaceid,begindate,enddate,setup,setdown,status,sshare,slock,cat,restype  from #spaceid order by cat desc
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_spacediary') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_spacediary >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_spacediary >>>'
;
