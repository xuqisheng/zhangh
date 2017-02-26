
// ‘§∂®µ•¥Ú”°
if exists(select 1 from sysobjects where name = 'p_cyj_gen_rsvbill' and type = 'P')
	drop proc p_cyj_gen_rsvbill;
create proc p_cyj_gen_rsvbill
	@pc_id			char(4),
	@accnt			char(10)
as

delete bill_mst where pc_id = @pc_id
insert into bill_mst(pc_id) select @pc_id
update bill_mst set char1 = b.roomno, char3 = b.type, date1 = b.arr, date2 = b.dep, mone1 = b.setrate, char4 = b.phone from bill_mst a, master b  where a.pc_id = @pc_id and b.accnt = @accnt
update bill_mst set char2 = c.name from bill_mst a, master b, guest c  where a.pc_id = @pc_id and b.accnt = @accnt and b.haccnt = c.no

;
