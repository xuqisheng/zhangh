
// ------------------------------------------------------------------------------------
//		fec_folio 更新触发器
// ------------------------------------------------------------------------------------
create trigger t_gl_fec_folio_update
   on fec_folio for update
	as

begin

if update(logmark)   -- 注意，这里插入的是 deleted
	insert fec_folio_log select deleted.* from deleted

end
;