
if exists(select * from sysobjects where name = "p_gl_public_roomlink_list")
	drop proc p_gl_public_roomlink_list;

create proc p_gl_public_roomlink_list
	@accnt		char(10)
as
-- Ä³ÕÊºÅÁª·¿²éÑ¯
declare 
	@pcrec1		char(10),
	@pcrec2		char(10)

select @pcrec1 = isnull(rtrim(pcrec), '#') from master where accnt = @accnt 
select @pcrec2 = isnull(rtrim(pcrec), '#') from ar_master where accnt = @accnt 
select a.arr, a.dep, a.type, a.roomno, a.accnt, a.master, a.pcrec, a.sta, b.name, a.setrate, 
			a.charge, a.credit, a.accredit, a.ref, a.resno, @accnt,b.name2
		from master a, guest b where pcrec = @pcrec1 and a.haccnt = b.no
	union select a.arr, a.dep, '', '', a.accnt, a.master, a.pcrec, a.sta, b.name, 0, 
			a.charge, a.credit, a.accredit, a.ref, '', @accnt,b.name2
		from ar_master a, guest b where pcrec = @pcrec2 and a.haccnt = b.no
	order by a.roomno, a.accnt
;

