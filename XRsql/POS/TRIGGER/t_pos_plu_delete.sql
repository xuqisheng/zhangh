create trigger t_pos_plu_delete
on pos_plu_all for delete
as
if exists(select 1 from pos_dish a,deleted b where a.id = b.id )
	rollback trigger with raiserror 20000 "�ò˽����Ѿ����㣬����ɾ��"
else
	begin
	delete pos_plu where id in (select id from deleted)
	delete pos_price where id in (select id from deleted)
	delete pos_plu_record where id in (select id from deleted)
	end;