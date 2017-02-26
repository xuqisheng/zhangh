IF OBJECT_ID('dbo.p_sc_event_listbyds_mt') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_event_listbyds_mt
    IF OBJECT_ID('dbo.p_sc_event_listbyds_mt') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_event_listbyds_mt >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_event_listbyds_mt >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_event_listbyds_mt
                 @accnt char(10),
                 @evtresno char(10),
                 @date datetime,
                 @enddate datetime
as
--如果传入的帐号不为空，选择该天与该帐号相关的event
if @accnt is not null and @accnt <>''
   --如果宴会预定号不为空，选择特定的event
   if @evtresno<>'' and @evtresno is not null
		select char10=convert(char(10),a.begindate,112),char11=convert(char(5),a.begindate,8)+'-'+convert(char(5),a.enddate,8),char50_1=a.descript1,char50_2=b.descript1,char60=c.descript,char03=a.restype,char10_1=substring(convert(varchar(10),a.fattendees),1,charindex('.',convert(varchar(10),a.fattendees)) -1)+'/'+substring(convert(varchar(10),a.gattendees),1,charindex('.',convert(varchar(10),a.gattendees)) -1),num02=a.fprice 
		from sc_eventreservation a,sc_spaces b,basecode c where a.space*=b.spaceid and a.layout*=c.code and  c.cat='layoutstyle' and (datediff(day,begindate,@date)<=0 and datediff(day,begindate,@enddate)>=0) and a.status<>'X' and a.status<>'M'
		and a.account=@accnt and a.evtresno=@evtresno  and a.eventtype='MT' order by a.begindate,a.enddate
   --如果宴会预定号为空，选择该天与该帐号相关的event
   else
     	select char10=convert(char(10),a.begindate,112),char11=convert(char(5),a.begindate,8)+'-'+convert(char(5),a.enddate,8),char50_1=a.descript1,char50_2=b.descript1,char60=c.descript,char03=a.restype,char10_1=substring(convert(varchar(10),a.fattendees),1,charindex('.',convert(varchar(10),a.fattendees)) -1)+'/'+substring(convert(varchar(10),a.gattendees),1,charindex('.',convert(varchar(10),a.gattendees)) -1),num02=a.fprice 
	   from sc_eventreservation a,sc_spaces b,basecode c where a.space*=b.spaceid and a.layout*=c.code and  c.cat='layoutstyle' and (datediff(day,begindate,@date)<=0 and datediff(day,begindate,@enddate)>=0) and a.status<>'X' and a.status<>'M'
	   and a.account=@accnt and a.eventtype='MT' order by a.begindate,a.enddate

----如果传入的帐号为空，选择该天所有的event
else
	select char10=convert(char(10),a.begindate,112),char11=convert(char(5),a.begindate,8)+'-'+convert(char(5),a.enddate,8),char50_1=a.descript1,char50_2=b.descript1,char60=c.descript,char03=a.restype,char10_1=substring(convert(varchar(10),a.fattendees),1,charindex('.',convert(varchar(10),a.fattendees)) -1)+'/'+substring(convert(varchar(10),a.gattendees),1,charindex('.',convert(varchar(10),a.gattendees)) -1),num02=a.fprice 
	from sc_eventreservation a,sc_spaces b,basecode c where a.space*=b.spaceid and a.layout*=c.code and  c.cat='layoutstyle' and (datediff(day,begindate,@date)<=0 and datediff(day,begindate,@enddate)>=0) and a.status<>'X' and a.status<>'M'
    and a.eventtype='MT' order by a.account,a.begindate,a.enddate
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_event_listbyds_mt') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_event_listbyds_mt >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_event_listbyds_mt >>>'
;
