if object_id("p_trace_scrolltext") is not null
drop proc p_trace_scrolltext
;
--------------------------------------------------------------------------------
-- get notify scroll text
--------------------------------------------------------------------------------
create procedure p_trace_scrolltext
	@empno      char(10),
	@pcid       char(4)
as
begin
	declare @deptno char(3)

	-- 清理数据
	--exec p_trace_notify_check @empno,@pcid
	-- 预备参数
	select @deptno = deptno from sys_empno where empno = @empno

	-- 取数据
	SELECT a.msgtext
	 FROM message_notify a,
			message_notify_type b
	WHERE ( a.msgsort = b.msgsort ) and
			( b.msgsort <> 'FOXMAIL') and
			( b.msgroll <>'0' ) and
			( a.msgto = @empno or a.msgto = '<'+@empno+'>' or a.msgto = '<D:'+@deptno+'>' or a.msgto = '') and
			( charindex(','+@pcid+',',a.msgto1) > 0 or a.msgto1 = '') and
			( a.status = '0' )
end
;