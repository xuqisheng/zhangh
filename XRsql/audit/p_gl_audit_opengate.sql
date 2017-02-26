if exists (select * from sysobjects where name = 'p_gl_audit_opengate' and type ='P')
	drop proc p_gl_audit_opengate;
create proc p_gl_audit_opengate
	@ret		integer		out, 
	@msg		varchar(70)	out
as

select @ret = 0, @msg = ''
update gate set idd = 'T', idump = 'F', pdump = 'F', exclpart = 'F', pos = 'F'
update accthead set exclpart = space(8), canpartout = 'T'
return @ret
;