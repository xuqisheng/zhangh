drop  procedure p_cyj_pos_res_cancel;
create procedure p_cyj_pos_res_cancel
	@resno			char(10),
	@empno			char(10)
as
declare
	@ret				int,
	@msg				char(64)

select @ret = 0 , @msg = ''

begin tran
save  tran t_res_cancel
if exists(select 1 from pos_pay where menu=@resno and sta = '1' and charindex(crradjt, 'C CO') = 0)
	begin
	select @ret = 1 , @msg = '有定金,不能取消预定'
	end

	update pos_reserve set sta = '0', empno = @empno, bdate = getdate() where resno = @resno
	update pos_tblav set sta = '0' where menu = @resno

if @ret <> 0
	rollback tran t_res_cancel
commit tran

select @ret, @msg
;