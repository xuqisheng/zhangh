IF OBJECT_ID('dbo.p_sc_plan_diary') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_plan_diary
    IF OBJECT_ID('dbo.p_sc_plan_diary') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_plan_diary >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_plan_diary >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_plan_diary
                      @date  datetime

as
declare
@int1 varchar(10),
@int2 varchar(10),
@int3 varchar(10),
@int4 varchar(10),
@int5 varchar(10),
@int6 varchar(10),
@int7 varchar(10),
@int8 varchar(10),
@int9 varchar(10),
@int10 varchar(10),
@int11 varchar(10),
@int12 varchar(10),
@int13 varchar(10),
@int14 varchar(10),
@int15 varchar(10),
@int16 varchar(10),
@int17 varchar(10),
@int18 varchar(10),
@int19 varchar(10),
@int20 varchar(10),
@int21 varchar(10),
@int22 varchar(10),
@int23 varchar(10),
@int24 varchar(10)


SELECT empno,int1=space(10),int2=space(10),int3=space(10),int4=space(10),
         int5=space(10),int6=space(10),int7=space(10),int8=space(10),
         int9=space(10),int10=space(10),int11=space(10),int12=space(10),
         int13=space(10),int14=space(10),int15=space(10),int16=space(10),
         int17=space(10),int18=space(10),int19=space(10),int20=space(10),
         int21=space(10),int22=space(10),int23=space(10),int24=space(10),
         @date
    FROM sys_empno
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_plan_diary') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_plan_diary >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_plan_diary >>>'
;
