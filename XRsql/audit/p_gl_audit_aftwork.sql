if exists (select * from sysobjects where name ='p_gl_audit_aftwork' and type ='P')
	drop proc p_gl_audit_aftwork;

create proc p_gl_audit_aftwork
	@ret			integer		out, 
	@msg			varchar(70)	out

as

/*update blklst set remark3 = remark2 where blkkind='ESC'*/
begin  tran
update gate set audit = 'F'
update sysdata set bdate = bdate1, rmposted = 'F'
update accthead set audit = '',  redotime = 0 , stopauto = 'F', bdate = dateadd(day, -1, sysdata.bdate) from sysdata
commit tran
select @ret = 0, @msg = ''
return @ret
;
