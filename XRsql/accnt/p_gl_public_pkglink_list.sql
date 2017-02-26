
if exists(select * from sysobjects where name = "p_gl_public_pkglink_list")
	drop proc p_gl_public_pkglink_list;

create proc p_gl_public_pkglink_list
	@accnt		char(10)
as
-- Ä³ÕÊºÅÁª·¿²éÑ¯
declare 
	@pcrec_pkg1		char(10),
	@pcrec_pkg2		char(10)

select @pcrec_pkg1 = isnull(rtrim(pcrec_pkg), '#') from master where accnt = @accnt 
select @pcrec_pkg2 = isnull(rtrim(pcrec_pkg), '#') from ar_master where accnt = @accnt 
select a.arr, a.dep, a.type, a.roomno, a.accnt, a.master, a.pcrec_pkg, a.sta, b.name, a.setrate, 
			a.charge, a.credit, a.accredit, a.packages, a.resno, @accnt,b.name2
		from master a, guest b where a.pcrec_pkg = @pcrec_pkg1 and a.haccnt = b.no
	union select a.arr, a.dep, '', '', a.accnt, a.master, a.pcrec_pkg, a.sta, b.name, 0, 
			a.charge, a.credit, a.accredit, '', '', @accnt,b.name2 
		from ar_master a, guest b where a.pcrec_pkg = @pcrec_pkg2 and a.haccnt = b.no
	order by a.roomno, a.accnt
;

