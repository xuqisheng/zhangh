if exists(select 1 from sysobjects where name = 't_pos_tblsta_delete')
	drop trigger t_pos_tblsta_delete
;

create trigger t_pos_tblsta_delete
on pos_tblsta for delete
as
if exists(select 1 from pos_tblav a,deleted b where a.tableno = b.tableno and (a.sta = '7' or a.sta ='1'))
	rollback trigger with raiserror 20000 "该台号正在使用，不能删除!"


;
