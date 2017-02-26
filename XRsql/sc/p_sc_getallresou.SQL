IF OBJECT_ID('dbo.p_sc_getallresou') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_sc_getallresou
    IF OBJECT_ID('dbo.p_sc_getallresou') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_sc_getallresou >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_sc_getallresou >>>'
END
;
SETUSER 'dbo'
;
create procedure p_sc_getallresou
                 @evtresno  char(10)
as

create table #resource
(
  id      varchar(10),    --资源预定的id
  resouid char(10),       --资源的id
  resouname varchar(100), --资源名称
  quantity money,         --资源数量
  overbooking  money,     --资源超额预定数量
  class   char(3)        
)

insert #resource select '',a.spaceid,b.descript1,1,0,'spa' from sc_spacereservation a,sc_spaces b where a.spaceid=b.spaceid and a.resno=@evtresno and a.status<>'X'
insert #resource select a.exp_s1,a.rsid,b.descript1,a.quantity,0,'res' from sc_resourcreservation a,sc_resourcedetails b where a.rsid=b.rsid and a.resno=@evtresno and a.status<>'X'
update #resource set #resource.overbooking=abs(sc_resourceconflict.quantity) from sc_resourceconflict where evtresno=@evtresno and sc_resourceconflict.id=#resource.id
select * from #resource
;
SETUSER
;
IF OBJECT_ID('dbo.p_sc_getallresou') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_sc_getallresou >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_sc_getallresou >>>'
;
