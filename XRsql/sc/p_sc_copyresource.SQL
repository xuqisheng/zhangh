IF OBJECT_ID('dbo.p_sc_copyresource') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_copyresource
    IF OBJECT_ID('dbo.p_sc_copyresource') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_copyresource >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_copyresource >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_copyresource
                 @oevtresno char(10),
                 @evtresno char(10),
                 @cby      char(12),
                 @begin    datetime,
                 @end      datetime
as
declare 
    @exp_s1 varchar(10),
    @exp_s2 varchar(10),
    @rsid   varchar(10),
    @quantity money,
    @iscontrol char
    

declare c_getid cursor for select exp_s1 from sc_resourcreservation where resno=@oevtresno and status='R'
open c_getid
fetch c_getid into @exp_s1
while @@sqlstatus=0
      begin
         select @exp_s2=right('0000000000'+convert(varchar(10),convert(decimal,max(exp_s1)) +1),10) from sc_resourcreservation
         select @rsid=rsid,@quantity=quantity from sc_resourcreservation where exp_s1 =@exp_s1
         select @iscontrol=exp_s1 from sc_resourcedetails where rsid=@rsid
      	
			exec p_sc_resourcecheck @exp_s2,@evtresno,@rsid,@begin,@end,@quantity,@iscontrol,'P'
         

         insert sc_resourcreservation select rsid,account,@evtresno,appid,@begin,@end,status,price,
       		fprice,discount,reason,quantity,paymode,act,note,@cby,getdate(),null,null,null,@exp_s2,exp_s2,
       		exp_s3,exp_m1,exp_m2,exp_m3,exp_dt1,exp_dt2,exp_dt3,bignote from sc_resourcreservation
       		where exp_s1=@exp_s1
         fetch c_getid into @exp_s1
      end 

select count(1) from sc_resourcreservation where resno=@evtresno
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_copyresource') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_copyresource >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_copyresource >>>'
;
