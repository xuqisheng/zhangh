if exists (select * from sysobjects where name ='p_gl_audit_begin_report' and type ='P')
	drop proc p_gl_audit_begin_report;
create proc p_gl_audit_begin_report
	@ret		integer		out, 
	@msg		varchar(70)	out
as
declare
	@bdate			datetime, 
	@duringaudit	char(1)

select @ret = 0, @msg = ''
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
if exists (select 1 from firstdays where firstday = @bdate and month = 1)
	update accthead set isfstday = 'T', isyfstday = 'T'
else if exists (select 1 from firstdays where firstday = @bdate)
	update accthead set isfstday = 'T', isyfstday = 'F'
else
	update accthead set isfstday = 'F', isyfstday = 'F'
return @ret
;
