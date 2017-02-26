/* 获得指定账单所涉及的所有账号 */

if exists(select * from sysobjects where name = "p_gl_accnt_bill_accnt" and type = "P")
	drop proc p_gl_accnt_bill_accnt;

create proc p_gl_accnt_bill_accnt
	@pc_id				char(4), 
	@mdi_id				integer, 
	@roomno				char(5), 
	@accnt				char(10), 
	@billno				char(10)
as

create table #accnt
(
	accnt			char(10)			null,
	roomno		char(10)			null,
	name			varchar(50)		null
)
if @billno = '所有选中账'
	insert into #accnt (accnt) select distinct accnt from account_temp
		where pc_id = @pc_id and mdi_id = @mdi_id and selected = 1
else if @billno = '所有未结账'
	begin
//	insert into #accnt (accnt) select distinct accnt from account_temp
//		where pc_id = @pc_id and mdi_id = @mdi_id and billno = ''
	if @roomno = '' and @accnt = ''
		insert into #accnt select accnt, roomno, name from accnt_set
			where pc_id = @pc_id and mdi_id = @mdi_id and subaccnt = 0
	// 指定房间
	else if @accnt = ''
		insert into #accnt select accnt, roomno, name from accnt_set
			where pc_id = @pc_id and mdi_id = @mdi_id and roomno = @roomno and subaccnt = 0
	// 指定团体或账号
	else
		insert into #accnt select accnt, roomno, name from accnt_set
			where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt and subaccnt = 0
	end
else if @billno like 'T%'
	begin
	insert into #accnt (accnt, roomno) select distinct accnt, tofrom from account where billno = @billno
		union select distinct accnt, tofrom from haccount where billno = @billno
	delete #accnt where roomno = 'FM'
	end
else
	insert into #accnt (accnt) select distinct accnt from account where billno = @billno
		union select distinct accnt from haccount where billno = @billno
update #accnt set roomno = a.roomno, name = b.name from master a, guest b
	where #accnt.name is null and #accnt.accnt = a.accnt and a.haccnt = b.no
update #accnt set roomno = a.roomno, name = b.name from hmaster a, guest b
	where #accnt.name is null and #accnt.accnt = a.accnt and a.haccnt = b.no
update #accnt set name = b.name from ar_master a, guest b
	where #accnt.name is null and #accnt.accnt = a.accnt and a.haccnt = b.no
update #accnt set name = b.name from har_master a, guest b
	where #accnt.name is null and #accnt.accnt = a.accnt and a.haccnt = b.no
//
select accnt, roomno, name from #accnt where accnt <> '' order by roomno, accnt
;
