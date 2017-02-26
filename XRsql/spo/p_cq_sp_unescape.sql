drop proc p_cq_sp_unescape;
create proc p_cq_sp_unescape
	@menu					char(10),
	@empno				char(10)
as
declare
   @bdate			datetime

select @bdate = bdate1 from sysdata

if not exists ( select 1 from sp_hmenu where menu=@menu)
   and exists ( select 1 from sp_menu where menu=@menu)
	return 0

//delete sp_tblav where menu=@menu

begin tran
save  tran p_gl_sp_unescape
insert sp_menu select * from sp_hmenu where menu = @menu

delete sp_dish where menu = @menu
update sp_menu
	set bdate = @bdate, empno3 = @empno, lastnum = a.lastnum, amount = a.amount
	from sp_hmenu a
	where sp_menu.menu = @menu and a.menu = @menu
insert sp_pay select * from sp_hpay where menu = @menu
//insert sp_plaav select * from sp_hplaav where sp_menu = @menu

delete sp_hmenu where menu = @menu
delete sp_tmenu where menu = @menu
delete sp_hpay where menu = @menu
delete sp_tpay where menu = @menu
//delete sp_hplaav where sp_menu = @menu

insert sp_dish select * from sp_hdish where menu = @menu

delete sp_hdish where menu = @menu
delete sp_tdish where menu = @menu
commit tran
return 0;
