
// �ͷ���ʱ̬

if exists (select * from sysobjects where name = 't_gds_rmstalist1_delete' and type = 'TR')
   drop trigger t_gds_rmstalist1_delete;
create trigger t_gds_rmstalist1_delete
   on rmstalist1
   for delete as
begin
if exists (select 1 from rmsta a, deleted b where a.tmpsta=b.code)
   rollback trigger with raiserror 20000 "��ǰ��������ʹ�ã�����ɾ��HRY_MARK"
end
;

if exists (select * from sysobjects where name = 't_gds_rmstalist1_update' and type = 'TR')
   drop trigger t_gds_rmstalist1_update;
//create trigger t_gds_rmstalist1_update
//   on rmstalist1
//   for update as
//begin
//if exists (select 1 from deleted where code = 'E')
//   rollback trigger with raiserror 20000 "�㲻���޸ı������HRY_MARK"
//end
//;
//
//