-------------
-- isnert
-------------
IF OBJECT_ID('t_sc_eventreservation_insert') IS NOT NULL
    DROP TRIGGER t_sc_eventreservation_insert
;
create trigger t_sc_eventreservation_insert
   on sc_eventreservation for insert
	as
insert lgfl(columnname,accnt,old,new,empno,date) 
	select 'm_evtresno', evtresno, '', evtresno, cby, createat from inserted
;


-------------
-- update 
-------------
IF OBJECT_ID('t_sc_eventres_update') IS NOT NULL
    DROP TRIGGER t_sc_eventres_update
;
create trigger t_sc_eventres_update
   on sc_eventreservation
   for update
as
declare @status char(3),
        @resno  char(10),
        @exp_s1 varchar(10)
---------------------------------------------------------------------------------
--	Part. 1  Log
---------------------------------------------------------------------------------
if update(logmark)  -- 记录日志
   insert sc_eventreservation_log select * from deleted

---------------------------------------------------------------------------------
--	Part. 2  如果Event预定取消，则在预定状态的资源同时取消并且打上标记，如果Event预定恢复，则恢复取消前处于预定状态的资源预定
---------------------------------------------------------------------------------
if update(status)
   begin
     select @status=status from inserted
     select @resno=evtresno from inserted
     select @exp_s1=exp_s1 from inserted
     if @status='R'
        update sc_resourcreservation set status='R' where exp_s1=@exp_s1 and exp_s2='0'
     else
        update sc_resourcreservation set status='X',exp_s2='0' where exp_s1=@exp_s1 and status='R'
  end
;


