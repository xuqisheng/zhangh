drop  procedure p_cq_pos_res_cancel;
create procedure p_cq_pos_res_cancel
	@resno			char(10),
	@empno			char(10)
as
declare
	@value			char(2),
	@ret				int,
	@msg				char(64)

select @ret = 0 , @msg = ''
select @value  = rtrim(value) from sysoption where catalog = 'pos' and item = 'res_credit_use'

begin tran
save  tran t_res_cancel
if @value = '1'			--use pos_dish save credit
	begin
	if exists(select 1 from pos_dish where menu in (select menu from pos_pay where menu0=@resno and sta = '3' and charindex(crradjt, 'C CO') = 0 ) and flag19='1' and (flag19_use = ''or flag19 is null) and charindex(rtrim(code),'XYZ') = 0) or
			exists(select 1 from pos_hdish where menu in (select menu from pos_hpay where menu0=@resno and sta = '3' and charindex(crradjt, 'C CO') = 0 ) and flag19='1' and (flag19_use = ''or flag19 is null) and charindex(rtrim(code),'XYZ') = 0) 
		begin
		select @ret = 1 , @msg = '有定金,不能取消预定'
		goto loop
		end
	end
if @value = '2'			--use pos_pay save credit
	begin
	if exists(select 1 from pos_pay where menu=@resno and sta = '1' and charindex(crradjt, 'C CO') = 0 and (menu0 = '' or menu0 is null))
		begin
		select @ret = 2 , @msg = '有定金,不能取消预定'
		goto loop
		end
	end


update pos_reserve set sta = '0', empno = @empno, bdate = getdate() where resno = @resno
update pos_tblav set sta = '0' where menu = @resno

loop:
if @ret <> 0
	rollback tran t_res_cancel
commit tran

select @ret, @msg
;