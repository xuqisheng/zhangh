IF OBJECT_ID('p_wz_house_rmadm_print') IS NOT NULL
    DROP PROCEDURE p_wz_house_rmadm_print
;
create proc p_wz_house_rmadm_print
	@modu_id		char(2),
	@pc_id		char(4)
as

select a.roomno, c.eccocode, a.tmpsta,a.empno,a.changed,a.ref 
	from rmsta a, hsmap_term_end b, rmstamap c 
	where b.modu_id=@modu_id and b.pc_id=@pc_id and b.cat='3' and a.roomno=b.roomno
		and a.ocsta+a.sta=c.code
	order by a.roomno

return 0
;
