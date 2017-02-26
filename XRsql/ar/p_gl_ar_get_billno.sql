if exists(select * from sysobjects where name = "p_gl_ar_get_billno")
	drop proc p_gl_ar_get_billno
;
create proc p_gl_ar_get_billno
	@pc_id				char(4),
	@mdi_id				integer,
	@accnt				char(10),					-- 账号
	@number				integer						-- 账次
as
---------------------------------------
-- 找出原始明细账单号
---------------------------------------
declare
	@foaccnt				char(10),					-- 前台账号
	@fohaccnt			char(7),						-- 前台客人号
	@fonumber			integer,
	@fobillno			char(10),
	@ret					integer,
	@msg					varchar(60)

create table #fo_accnt
(
	fo_accnt			char(10)			not null,					-- 账号 
	fo_number		integer			not null,					-- 账次 
	fo_billno		char(10)			default '' not null,		-- 前台结帐单号 
	fo_charge		money				default 0 not null,
	fo_credit		money				default 0 not null,
	ar_accnt			char(10)			default '' not null,
	ar_number		integer			not null,
	ar_subtotal		char(1)			not null,
	ar_billno		char(10)			default '' not null,		-- 前台结帐单号 
	ar_charge		money				default 0 not null,
	ar_credit		money				default 0 not null,
	modu_id			char(2)			not null,					-- 模块号 
	tag				char(1)			not null,					-- 标志 
)
create table #fo_billno
(
	billno			char(10)			not null,					-- 前台结帐单号 
)
delete account_temp where pc_id = @pc_id and mdi_id = - @mdi_id
delete accnt_set where pc_id = @pc_id and mdi_id = - @mdi_id
if @number = 0
	begin
	insert #fo_accnt (fo_accnt, fo_number, ar_accnt, ar_number, ar_subtotal, ar_billno, ar_charge, ar_credit, modu_id, tag)
		select a.accnt, a.number, a.ar_accnt, a.ar_number, a.ar_subtotal, a.billno, a.charge, a.credit, a.modu_id, a.ar_tag
		from ar_account a, account_temp b
		where b.pc_id = @pc_id and b.mdi_id = @mdi_id and selected = 1 and a.ar_accnt = b.accnt and a.ar_inumber = b.number
	end
else
	begin
	insert #fo_accnt (fo_accnt, fo_number, ar_accnt, ar_number, ar_subtotal, ar_billno, ar_charge, ar_credit, modu_id, tag)
		select a.accnt, a.number, a.ar_accnt, a.ar_number, a.ar_subtotal, a.billno, a.charge, a.credit, a.modu_id, a.ar_tag
		from ar_account a where a.ar_accnt = @accnt and a.ar_inumber = @number
		union select a.accnt, a.number, a.ar_accnt, a.ar_number, a.ar_subtotal, a.billno, a.charge, a.credit, a.modu_id, a.ar_tag
		from har_account a where a.ar_accnt = @accnt and a.ar_inumber = @number
	end
--
update #fo_accnt set fo_billno = a.billno, fo_charge = a.charge, fo_credit = a.credit
	from account a where #fo_accnt.fo_accnt = a.accnt and #fo_accnt.fo_number = a.number
update #fo_accnt set fo_billno = a.billno, fo_charge = a.charge, fo_credit = a.credit
	from haccount a where #fo_accnt.fo_accnt = a.accnt and #fo_accnt.fo_number = a.number
update #fo_accnt set fo_billno = ''
	where ar_billno <> fo_billno or ar_charge - ar_credit<> fo_credit - fo_charge
-- 后台直接录入的账务, 转入的账务和其他非F/O转入的账务
insert account_temp (pc_id, mdi_id, accnt, number, billno, charge, credit, selected)
	select @pc_id, - @mdi_id, a.ar_accnt, a.ar_number, a.billno, a.charge, a.credit, 1
	from ar_account a, #fo_accnt b where (b.tag in ('A', 't', 'Z') or (b.tag in ('P') and b.modu_id <> '02') or (b.tag in ('T') and b.ar_subtotal = 'F'))
	and b.ar_accnt = a.ar_accnt and b.ar_number = a.ar_number
	union select @pc_id, - @mdi_id, a.ar_accnt, a.ar_number, a.billno, a.charge, a.credit, 1
	from har_account a, #fo_accnt b where (b.tag in ('A', 't', 'Z') or (b.tag in ('P') and b.modu_id <> '02') or (b.tag in ('T') and b.ar_subtotal = 'F'))
	and b.ar_accnt = a.ar_accnt and b.ar_number = a.ar_number
-- 虽然是F/O转入的但找不到明细的账务
insert account_temp (pc_id, mdi_id, accnt, number, billno, charge, credit, selected)
	select @pc_id, - @mdi_id, a.ar_accnt, a.ar_number, a.billno, a.charge, a.credit, 1
	from ar_account a, #fo_accnt b where b.tag = 'P' and b.modu_id = '02' and b.fo_billno = '' and b.ar_accnt = a.ar_accnt and b.ar_number = a.ar_number
	union select @pc_id, - @mdi_id, a.ar_accnt, a.ar_number, a.billno, a.charge, a.credit, 1
	from har_account a, #fo_accnt b where b.tag = 'P' and b.modu_id = '02' and b.fo_billno = '' and b.ar_accnt = a.ar_accnt and b.ar_number = a.ar_number
--
insert #fo_billno select distinct fo_billno from #fo_accnt where not (tag <> 'P' or modu_id <> '02' or fo_billno = '')

--insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, charge, credit, selected)
--	select @pc_id, - @mdi_id, a.accnt, a.number, a.mode1, a.billno, a.charge, a.credit, 1
--	from account a, #fo_billno b, pccode c where a.billno = b.billno and a.pccode *= c.pccode and isnull(c.deptno2, '') <> 'TOR'
--	union select @pc_id, - @mdi_id, a.accnt, a.number, a.mode1, a.billno, a.charge, a.credit, 1
--	from haccount a, #fo_billno b, pccode c where a.billno = b.billno and a.pccode *= c.pccode and isnull(c.deptno2, '') <> 'TOR'
insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, charge, credit, selected)
	select @pc_id, - @mdi_id, a.accnt, a.number, a.mode1, a.billno, a.charge, a.credit, 1
	from account a, #fo_billno b, pccode c where a.billno = b.billno and a.pccode = c.pccode and isnull(c.deptno2, '') <> 'TOR'
	union select @pc_id, - @mdi_id, a.accnt, a.number, a.mode1, a.billno, a.charge, a.credit, 1
	from haccount a, #fo_billno b, pccode c where a.billno = b.billno and a.pccode = c.pccode and isnull(c.deptno2, '') <> 'TOR'

--
select @foaccnt = min(accnt) from account_temp where pc_id = @pc_id and mdi_id = - @mdi_id
insert accnt_set select @pc_id, - @mdi_id, '', @foaccnt, 0, '', '', '', 0, 0, 2, '1', '2', '', 1
select 0, '', @foaccnt, @fohaccnt, '所有选中账'
return 0
;
