drop procedure p_cq_sp_recheck_rent;
create proc p_cq_sp_recheck_rent
	@code		char(5),
	@menu		char(10),
	@empno	char(10),
	@shift	char(1)

as
declare
	@ret	integer,
	@msg	char(20)
	
begin tran
save tran p_cq_sp_recheck_rent

exec @ret = p_cq_sp_recheck @menu, @msg output

if @ret = 0 
	begin
	update sp_menu set sta = '7' ,empno3 = @empno,shift = @shift where menu = @menu and sta = '5'
	delete sp_rent where code = @code and menu = @menu
	end 

if @ret <> 0 
	begin
	rollback tran p_cq_sp_recheck_rent
	select @msg = 'É¾³ý³ö´í!'
	end 

commit tran
select @ret, @msg

;
