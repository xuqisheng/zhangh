IF OBJECT_ID('dbo.p_sc_getactno1') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_getactno1
    IF OBJECT_ID('dbo.p_sc_getactno1') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_getactno1 >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_getactno1 >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_getactno1
                 @actno char(10) out
as

  

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

return 0
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_getactno1') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_getactno1 >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_getactno1 >>>'
;
