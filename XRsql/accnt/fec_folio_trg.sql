
// ------------------------------------------------------------------------------------
//		fec_folio ���´�����
// ------------------------------------------------------------------------------------
create trigger t_gl_fec_folio_update
   on fec_folio for update
	as

begin

if update(logmark)   -- ע�⣬���������� deleted
	insert fec_folio_log select deleted.* from deleted

end
;