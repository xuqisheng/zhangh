
// 营业点删除
create trigger t_pos_pccode_delete
on pos_pccode for delete
as
if exists(select 1 from pos_menu a,deleted b where a.pccode = b.pccode and a.sta<>'7' )
	or exists(select 1 from pos_tmenu a,deleted b where a.pccode = b.pccode and a.sta<>'7' )
	begin
	rollback trigger with raiserror 20000 "该餐厅已经有餐单使用，不能删除"
	return
	end
if exists(select 1 from pos_tblsta a,deleted b where a.pccode = b.pccode)
	begin
	rollback trigger with raiserror 20000 "该餐厅已经有桌号输入，不能删除"
	return
	end


delete pos_int_pccode where pos_pccode in (select pccode from deleted)
delete pos_itemdef where pccode in (select pccode from deleted)

;