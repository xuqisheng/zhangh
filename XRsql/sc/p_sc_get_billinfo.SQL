IF OBJECT_ID('dbo.p_sc_get_billinfo') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_get_billinfo
    IF OBJECT_ID('dbo.p_sc_get_billinfo') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_get_billinfo >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_get_billinfo >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_get_billinfo
                     @accnt char(10)
as
declare 
     @count int,
     @id    varchar(10),
     @total money

select @count=count(1) from sc_billinfo where substring(book_lnk,1,10)=@accnt

select @total=sum(fprice) from sc_eventreservation where account=@accnt and status<>'X'
select @total=@total+sum(fprice*quantity) from sc_resourcreservation where account=@accnt and status<>'X'

select @total
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_get_billinfo') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_get_billinfo >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_get_billinfo >>>'
;
