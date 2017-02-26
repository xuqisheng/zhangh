if exists (select 1 from sysobjects where name = 'p_trace_notify_check' and type = 'P')
   drop procedure p_trace_notify_check
; 
--------------------------------------------------------------------------------
-- get notify check
--------------------------------------------------------------------------------
create procedure p_trace_notify_check
	@empno      char(10), 
	@pcid       char(4) 
as	
begin 
	-- ��������
	-- 1������Ѿ������mail
	delete message_notify 
		where status = '0' and msgsort = 'FOXMAIL' 
			and msgdata in(select rtrim(convert(varchar(254),id))+'@'+receiver from message_mailrecv where tag <>'0' )
	-- 2������Ѿ������¼
	delete message_notify where status <> '0'
	-- 3������Ѿ����ڼ�¼
	delete message_notify 
		from message_notify a,message_notify_type b 
		where a.msgsort = b.msgsort and a.status = '0' and b.usefullife <> '1' 
				and 
				(
					b.usefullife like 'M[0-9][0-9]' and datediff(mi,msgdate,getdate())>convert(int,substring(b.usefullife,2,2)) or 
					b.usefullife like 'H[0-9][0-9]' and datediff(hh,msgdate,getdate())>convert(int,substring(b.usefullife,2,2)) or 
					b.usefullife like 'D[0-9][0-9]' and datediff(dd,msgdate,getdate())>convert(int,substring(b.usefullife,2,2)) 
				)
end
;
 
