IF OBJECT_ID('dbo.p_sc_getdatetime') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_getdatetime
    IF OBJECT_ID('dbo.p_sc_getdatetime') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_getdatetime >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_getdatetime >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_getdatetime
       @indatetime datetime,
       @interval   decimal
as
declare
       @outdatetime datetime

select @outdatetime=dateadd(minute,@interval,@indatetime)
select @outdatetime
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_getdatetime') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_getdatetime >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_getdatetime >>>'
;
