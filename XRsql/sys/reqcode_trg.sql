//if exists (select * from sysobjects where name = 't_gds_reqcode_delete' and type = 'TR')
//   drop trigger t_gds_reqcode_delete;
//create trigger t_gds_reqcode_delete
//   on reqcode
//   for delete as
//begin
//if exists (select 1 from deleted where code in ('V1','V2','V3','N0','P0','SR','P1','P2','P3','P4','P5'))
//   begin
//   rollback trigger with raiserror 20000 "你不能删除本特殊要求码HRY_MARK"
//   end 
//end
//;
//
//

if exists (select * from sysobjects where name = 't_gds_reqcode_delete' and type = 'TR')
   drop trigger t_gds_reqcode_delete;
create trigger t_gds_reqcode_delete
   on reqcode
   for delete as
begin
if exists (select 1 from master a, deleted b where charindex(b.code, a.srqs)>0)
   rollback trigger with raiserror 20000 "master 正在使用, 你不能删除本特殊要求码HRY_MARK"
end
;

