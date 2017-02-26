IF OBJECT_ID('dbo.p_sc_grpblk_trace') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_grpblk_trace
    IF OBJECT_ID('dbo.p_sc_grpblk_trace') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_grpblk_trace >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_grpblk_trace >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_grpblk_trace
                      @from  datetime,
                      @to    datetime
as
declare
      @accnt    varchar(10),
      @count    integer

create table #tracetmp
(
  date    datetime      not null,
  rmnum   integer       not null,
  accnt   varchar(10) not null
)

insert #tracetmp(date,rmnum,accnt) select  date,rmnum,accnt from sc_grpblk_trace  where datediff(day,date,@from)<=0 and datediff(day,date,@to)>=0 

delete #tracetmp  where exists(select 1 from #tracetmp b where datediff(day,b.date,#tracetmp.date)=1 and #tracetmp.accnt=b.accnt and #tracetmp.rmnum=b.rmnum)
delete #tracetmp where accnt in(select accnt from #tracetmp group by accnt having count(accnt)=1)                                                                                                                                                                                             
                                                                                                                                                                          
select b.date,a.haccnt,a.cusno,a.agent,a.source,convert(varchar,a.arr,111),convert(varchar,a.dep,111),b.rmnum from #tracetmp b,master_des a where a.accnt=b.accnt order by b.accnt
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_grpblk_trace') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_grpblk_trace >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_grpblk_trace >>>'
;
