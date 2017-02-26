
drop  proc p_gl_pos_unescape;
create proc p_gl_pos_unescape
	@menu					char(10),
	@empno				char(10)
as
declare
   @bdate			datetime

select @bdate = bdate1 from sysdata

if not exists ( select 1 from pos_hmenu where menu=@menu)
   and exists ( select 1 from pos_menu where menu=@menu)
	return 0

delete pos_tblav where menu=@menu

begin tran
save  tran p_gl_pos_unescape
insert pos_menu select * from pos_hmenu where menu = @menu

delete pos_dish where menu = @menu
update pos_menu
	set bdate = @bdate, empno3 = @empno, lastnum = a.lastnum, amount = a.amount
	from pos_hmenu a
	where pos_menu.menu = @menu and a.menu = @menu
insert pos_pay select * from pos_hpay where menu = @menu

delete pos_hmenu where menu = @menu
delete pos_tmenu where menu = @menu
delete pos_hpay where menu = @menu
delete pos_tpay where menu = @menu

insert pos_dish select * from pos_hdish where menu = @menu

delete pos_hdish where menu = @menu
delete pos_tdish where menu = @menu
commit tran
return 0

;