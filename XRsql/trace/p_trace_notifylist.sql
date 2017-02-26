if exists (select 1 from sysobjects where name = 'p_trace_notifylist' and type = 'P')
   drop procedure p_trace_notifylist
; 
--------------------------------------------------------------------------------
-- get notify list 
--------------------------------------------------------------------------------
create procedure p_trace_notifylist
	@empno      char(10), 
	@pcid       char(4),  
	@sta        char(1) 
as	
begin 
	declare @deptno char(3) 	

	-- 清理数据
	exec p_trace_notify_check @empno,@pcid 
	-- 预备参数
	select @deptno = deptno from sys_empno where empno = @empno 	

	-- 取数据 
	SELECT a.msgdate,   
			a.msgfrom,   
			a.msgtext,   
			a.status,   
			a.msgid,   
			a.msgsort,   
			a.msgdata,   
			b.descript,   
			b.descript1,   
			b.msgwin,   
			b.msgmode, 
			a.reader   
	 FROM message_notify a,   
			message_notify_type b 
	WHERE ( a.msgsort = b.msgsort ) and  
			( a.msgto = @empno or a.msgto = '<'+@empno+'>' or a.msgto = '<D:'+@deptno+'>' or a.msgto = '') and 
			( charindex(','+@pcid+',',a.msgto1) > 0 or a.msgto1 = '') and 
			( a.status = @sta or @sta = '' )   
	
	
end
;
 
