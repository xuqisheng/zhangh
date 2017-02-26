// ------------------------------------------------------------------------------------
//		fixed_charge ¸üÐÂ´¥·¢Æ÷
// ------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_gds_fixed_charge_insert' and type = 'TR')
	drop trigger t_gds_fixed_charge_insert
;
create trigger t_gds_fixed_charge_insert
   on fixed_charge for insert
	as

begin

insert lgfl (columnname, accnt, old, new, empno, date)
	select 'fc_new     ' + convert(char(4), number), accnt, '', 'No:' + convert(char(4), number) + 
	' Code:' + pccode + ' Amt:'+ ltrim(convert(char(10),amount)) + ' Qty:'+ ltrim(convert(char(10),quantity)) + 
	' From:' + convert(char(5),starting_time,101) + ' To:' + convert(char(5),closing_time,101), cby, changed
	from inserted

end
;


if exists (select * from sysobjects where name = 't_gds_fixed_charge_update' and type = 'TR')
	drop trigger t_gds_fixed_charge_update
;
create trigger t_gds_fixed_charge_update
   on fixed_charge for update
	as

begin

if update(logmark)
	insert fixed_charge_log select * from deleted

end
;
