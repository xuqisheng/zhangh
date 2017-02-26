IF OBJECT_ID('dbo.p_sc_getactno') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_getactno
    IF OBJECT_ID('dbo.p_sc_getactno') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_getactno >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_getactno >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_getactno

as
declare
  @actno char(10)

select  @actno=max(right(activityid,9)) from sc_activitydetail

if @actno is null
   begin
   	select @actno='000000001'
      select @actno='A'+@actno
   end 
else
   begin
     select @actno=right('0000000000'+convert(varchar,convert(integer,@actno)+1),9)
     select @actno='A'+@actno
   end 

select @actno
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_getactno') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_getactno >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_getactno >>>'
;
