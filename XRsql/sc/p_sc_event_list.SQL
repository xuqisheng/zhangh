IF OBJECT_ID('dbo.p_sc_event_list') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_event_list
    IF OBJECT_ID('dbo.p_sc_event_list') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_event_list >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_event_list >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_event_list
                 @accnt char(10),
                 @evtresno char(10),
                 @date datetime
as
--如果传入的帐号不为空，选择该天与该帐号相关的event
if @accnt is not null and @accnt <>''
   --如果宴会预定号不为空，选择特定的event
   if @evtresno<>'' and @evtresno is not null
		select char11=convert(char(5),a.begindate,8)+'-'+convert(char(5),a.enddate,8),char50_1=a.descript1,char50_2=b.descript1,char60=c.descript,char03=a.restype,char10=substring(convert(varchar(10),a.fattendees),1,charindex('.',convert(varchar(10),a.fattendees)) -1)+'/'+substring(convert(varchar(10),a.gattendees),1,charindex('.',convert(varchar(10),a.gattendees)) -1),num02=a.fprice 
		from sc_eventreservation a,sc_spaces b,basecode c where a.space*=b.spaceid and a.layout*=c.code and  c.cat='layoutstyle' and datediff(day,begindate,@date)=0 and a.status<>'X' and a.status<>'M'
		and a.account=@accnt and a.evtresno=@evtresno order by a.begindate,a.enddate
   --如果宴会预定号为空，选择该天与该帐号相关的event
   else
     	select char11=convert(char(5),a.begindate,8)+'-'+convert(char(5),a.enddate,8),char50_1=a.descript1,char50_2=b.descript1,char60=c.descript,char03=a.restype,char10=substring(convert(varchar(10),a.fattendees),1,charindex('.',convert(varchar(10),a.fattendees)) -1)+'/'+substring(convert(varchar(10),a.gattendees),1,charindex('.',convert(varchar(10),a.gattendees)) -1),num02=a.fprice 
	   from sc_eventreservation a,sc_spaces b,basecode c where a.space*=b.spaceid and a.layout*=c.code and  c.cat='layoutstyle' and datediff(day,begindate,@date)=0  and a.status<>'X' and a.status<>'M'
	   and a.account=@accnt order by a.begindate,a.enddate

----如果传入的帐号为空，选择该天所有的event
else
	select char11=convert(char(5),a.begindate,8)+'-'+convert(char(5),a.enddate,8),char50_1=a.descript1,char50_2=b.descript1,char60=c.descript,char03=a.restype,char10=substring(convert(varchar(10),a.fattendees),1,charindex('.',convert(varchar(10),a.fattendees)) -1)+'/'+substring(convert(varchar(10),a.gattendees),1,charindex('.',convert(varchar(10),a.gattendees)) -1),num02=a.fprice 
	from sc_eventreservation a,sc_spaces b,basecode c where a.space*=b.spaceid and a.layout*=c.code and  c.cat='layoutstyle' and datediff(day,begindate,@date)=0  and a.status<>'X' and a.status<>'M'
   order by a.account,a.begindate,a.enddate
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_event_list') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_event_list >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_event_list >>>'
;
