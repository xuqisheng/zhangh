
/* 接待单据打印：预定单，登记单，信封 等 */

if exists(select * from sysobjects where name = "p_cyj_front_bill" and type = "P")
	drop proc p_cyj_front_bill;

create proc  p_cyj_front_bill
	@accnt			char(10),
	@pc_id			char(4),
	@code				char(3)
as
declare 
	@charge			money, 
	@amount			money, 
	@mode				char(10)

delete bill_dtl where pc_id = @pc_id
delete bill_mst where pc_id = @pc_id

insert bill_mst(pc_id,char1,char2,char3, char4, date1,date2,mone1)
select @pc_id, a.roomno,b.name,a.type,b.phone,a.arr,a.dep,setrate from master a, guest b where a.haccnt = b.no and a.accnt = @accnt
;



