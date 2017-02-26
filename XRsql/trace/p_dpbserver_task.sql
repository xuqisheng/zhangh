if exists (select 1 from sysobjects where name = 'p_dpbserver_task' and type = 'P')
   drop procedure p_dpbserver_task
; 
--------------------------------------------------------------------------------
-- p_dpbserver_task
--------------------------------------------------------------------------------
create procedure p_dpbserver_task
as	
begin 
    -- 执行相关任务
    declare @roomno char(8)
    declare @type char(4)
    declare @wktime datetime
    
    create table #tmp (
        roomno 		char(8)  not null, 
        wktime 		datetime default getdate() 	null 
    )
    
    
    delete phteleclos_task where wktime <= getdate() 
    
    insert into #tmp(roomno,wktime)
        select roomno,min(wktime) from phteleclos_task group by roomno,type 
    
    update phteleclos 
        set wktime = b.wktime
        from phteleclos  a,#tmp b 
        where a.roomno = b.roomno and a.type='wake' and (a.changed = 'T' or a.wktime < getdate() ) 
            
	return 
end
;
 
