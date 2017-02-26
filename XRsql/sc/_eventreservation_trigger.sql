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
if update(logmark)  -- ��¼��־
   insert sc_eventreservation_log select * from deleted

---------------------------------------------------------------------------------
--	Part. 2  ���EventԤ��ȡ��������Ԥ��״̬����Դͬʱȡ�����Ҵ��ϱ�ǣ����EventԤ���ָ�����ָ�ȡ��ǰ����Ԥ��״̬����ԴԤ��
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


