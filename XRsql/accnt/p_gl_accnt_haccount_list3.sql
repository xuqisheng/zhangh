if exists(select * from sysobjects where name = "p_gl_accnt_haccount_list3")
	drop proc p_gl_accnt_haccount_list3;

create proc p_gl_accnt_haccount_list3
	@pc_id			char(4),						// IP地址
	@mdi_id			integer						// 唯一的账务窗口ID
as

select a.accnt, a.subaccnt, a.number, a.pccode, a.argcode, a.empno, a.shift, a.log_date, a.ref, a.ref1, a.ref2,
		a.modu_id, amount = a.charge + a.credit, amount1 = a.charge - a.credit, a.quantity, a. groupno, a.accntof, 
		crradjt, tran_accnt = a.tofrom + a.accntof, a.bdate, a.date, a.roomno, a.billno, 0, tag = ''
 from account a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
 union select a.accnt, a.subaccnt, a.number, a.pccode, a.argcode, a.empno, a.shift, a.log_date, a.ref, a.ref1, a.ref2,
		a.modu_id, amount = a.charge + a.credit, amount1 = a.charge - a.credit, a.quantity, a. groupno, a.accntof, 
		crradjt, tran_accnt = a.tofrom + a.accntof, a.bdate, a.date, a.roomno, a.billno, 0, tag = ''
 from haccount a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
 order by a.bdate, a.number
return
;
