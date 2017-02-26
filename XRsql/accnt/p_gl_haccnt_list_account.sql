if exists(select * from sysobjects where name = "p_gl_haccnt_list_account")
	drop proc p_gl_haccnt_list_account;

create proc p_gl_haccnt_list_account
	@pc_id				char(4),						-- IP地址
	@mdi_id				integer,						-- 唯一的账务窗口ID
	@roomno				char(5),						-- 房号
	@accnt				char(10),					-- 账号
	@subaccnt			integer,						-- 子账号(如果@roomno = '99999', @subaccnt就是临时账夹的编号)
	@operation			char(10),
	@langid				integer = 0
as
-- add output mode  2009.8.26 
declare @listout char(1)
select @listout='T'
if @mdi_id > 10000 
	select @mdi_id = @mdi_id - 10000, @listout='F'

delete account_temp where pc_id = @pc_id and mdi_id = @mdi_id
-- 团体主单
if @roomno = '' and @accnt != ''
	begin
	if @subaccnt = 0
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
			select @pc_id, @mdi_id, accnt, number, isnull(mode1,''), billno, 0 from haccount
			where accnt = @accnt
	else
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
			select @pc_id, @mdi_id, accnt, number, isnull(mode1,''), billno, 0 from haccount
			where accnt = @accnt and subaccnt = @subaccnt
	end
-- 所有
else if @roomno = ''
	insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
		select @pc_id, @mdi_id, a.accnt, a.number, isnull(a.mode1,''), a.billno, 0 from haccount a, accnt_set b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.subaccnt = @subaccnt and a.accnt = b.accnt
-- 临时账夹
else if @roomno = '99999'
	insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
		select @pc_id, @mdi_id, a.accnt, a.number, isnull(a.mode1,''), a.billno, 0 from haccount a, account_folder b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.folder = @subaccnt and a.accnt = b.accnt and a.number = b.number
-- 指定房间
else if @accnt = ''
	insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
		select @pc_id, @mdi_id, a.accnt, a.number, isnull(a.mode1,''), a.billno, 0 from haccount a, accnt_set b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.roomno = @roomno and b.subaccnt = 0 and b.accnt = a.accnt
-- 指定账号
else if @subaccnt = 0
	insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
		select @pc_id, @mdi_id, accnt, number, isnull(mode1,''), billno, 0 from haccount
		where accnt = @accnt
-- 指定账夹
else
	insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected)
		select @pc_id, @mdi_id, accnt, number, isnull(mode1,''), billno, 0 from haccount
		where accnt = @accnt and subaccnt = @subaccnt
-- 删除已被选入临时账夹的明细账务
if @roomno != '99999'
	delete account_temp from account_folder a where account_temp.pc_id = a.pc_id and account_temp.mdi_id = a.mdi_id
		and account_temp.accnt = a.accnt and account_temp.number = a.number and a.pc_id = @pc_id and a.mdi_id = @mdi_id
if @operation = 'uncheckout'
	delete account_temp where pc_id = @pc_id and mdi_id = @mdi_id and billno != ''
	
-- 返回结果
if  @listout='T'
begin 
	if @langid = 0
		select a.accnt, a.subaccnt, a.number, a.pccode, a.argcode, a.empno, a.shift, a.log_date, a.ref, a.ref1, a.ref2,
			a.modu_id, amount = a.charge + a.credit, amount1 = a.charge - a.credit, a.quantity, a. groupno, a.accntof, 
			a.crradjt, a.package, tran_accnt = a.tofrom + a.accntof, a.bdate, a.date, a.roomno, a.billno, selected = 0, tag = ''
			from haccount a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number
			order by a.log_date, a.number
	else
		select a.accnt, a.subaccnt, a.number, a.pccode, a.argcode, a.empno, a.shift, a.log_date, isnull(c.descript1, a.ref), a.ref1, a.ref2,
			a.modu_id, amount = a.charge + a.credit, amount1 = a.charge - a.credit, a.quantity, a. groupno, a.accntof, 
			a.crradjt, a.package, tran_accnt = a.tofrom + a.accntof, a.bdate, a.date, a.roomno, a.billno, selected = 0, tag = ''
			from haccount a, account_temp b, pccode c
			where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.pccode *= c.pccode
			order by a.log_date, a.number
end 

return 0

;
