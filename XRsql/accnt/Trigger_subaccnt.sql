// ------------------------------------------------------------------------------------
//		subaccnt ¸üÐÂ´¥·¢Æ÷
// ------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_gds_subaccnt_insert' and type = 'TR')
	drop trigger t_gds_subaccnt_insert
;
create trigger t_gds_subaccnt_insert
   on subaccnt for insert
	as

begin

insert lgfl (columnname, accnt, old, new, empno, date)
	select 'sa_new     ' + convert(char(4), subaccnt), accnt, '', 'No:' + convert(char(4), subaccnt) + 
	isnull(rtrim(name),'') + ' Dept:' + pccodes + ' To:'+ isnull(to_roomno, to_accnt), cby, changed
	from inserted where type = "5"

end
;


if exists (select * from sysobjects where name = 't_gds_subaccnt_update' and type = 'TR')
	drop trigger t_gds_subaccnt_update
;
create trigger t_gds_subaccnt_update
   on subaccnt for update
	as

begin

if update(logmark)
	insert subaccnt_log select * from deleted

end
;
