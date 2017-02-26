if	exists(select * from sysobjects where name = 'p_gl_accnt_reinstate')
	drop proc p_gl_accnt_reinstate;

create proc p_gl_accnt_reinstate
	@accnt				char(10), 
	@request				char(1), 
	@shift				char(1), 
	@empno				char(10)
as
---------------------------------------------------
--		³·Ïû½áÕÊ
---------------------------------------------------
declare
	@class				char(1), 
	@ret					integer, 
	@msg					char(60)

select @ret = 0, @msg = ''
if @request = 'S'
	update master set sta = 'S', cby = @empno, changed = getdate(), logmark = logmark + 1 where accnt = @accnt
else
	begin
	begin tran
	save tran p_gl_accnt_reinstate
	update master set sta = ressta, cby = @empno, changed = getdate(), logmark = logmark + 1 where accnt = @accnt
	select @class = class from master where accnt = @accnt
	if @class in ('F','G', 'M', 'C') 
		exec @ret = p_gds_reserve_chktprm @accnt, @request, 'T', @empno, '', 1, 1, @msg out
	if @ret != 0
		rollback tran p_gl_accnt_reinstate
	commit tran
	end
select @ret, @msg
return @ret
;
