IF OBJECT_ID('dbo.p_sc_recur_insert') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_recur_insert
    IF OBJECT_ID('dbo.p_sc_recur_insert') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_recur_insert >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_recur_insert >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_recur_insert
                        @recurid varchar(10),
                        @actid   varchar(10),
                        @begintime datetime,
                        @endtime   datetime,
                        @actidmaster varchar(10),
                        @activityto varchar(50)
as
declare 
@remind_diff money,
@rbegintime datetime

select @remind_diff=datediff(minute,rbegintime,begintime) from sc_activitydetail where activityid=@actidmaster
select @rbegintime=dateadd(minute,- @remind_diff,@begintime)

insert sc_activitydetail(recactid,activityid,descript,account,account1,contact,contact1,accnt,accnt1,
                         potential,purpose,begintime,endtime,type,amount,priority,tracecode,remind,rbegintime,
                         remindinterval,activityto,completed,todo,private,allday,cby,createdat,
                         updatedby,updatedat,logmark,recurnote,master,color) 
                   select  recactid,@actid,descript,account,account1,contact,contact1,accnt,accnt1,
                         potential,purpose,@begintime,@endtime,type,amount,priority,tracecode,remind,@rbegintime,
                         remindinterval,@activityto,completed,todo,private,allday,cby,createdat,
                         updatedby,updatedat,logmark,recurnote,@actidmaster,color from sc_activitydetail where activityid=@actidmaster
                         and activityto=@activityto
return @@rowcount
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_recur_insert') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_recur_insert >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_recur_insert >>>'
;
