if exists(select * from sysobjects where name = "p_gl_accnt_checkout_check")
	drop proc p_gl_accnt_checkout_check;

create proc p_gl_accnt_checkout_check
	@pc_id			char(4),						-- IP地址
	@mdi_id			integer,						-- 唯一的账务窗口ID
	@roomno			char(5),						-- 房号
	@accnt			char(10),					-- 账号
	@subaccnt		integer,						-- 子账号(如果@roomno = '99999', @subaccnt就是临时账夹的编号)
	@operation		char(10),
	@langid			integer = 0
as
---------------------------------------------------------------------------
-- 进入帐务或者结账时候的提醒信息。 提醒内容控制 @operation 
---------------------------------------------------------------------------
declare
	@city_ledger	char(15),
	@routing			char(15),
	@comsg			char(15),
	@message			char(15),
	@location		char(15),
	@rental			char(15),
	@extra_bed		char(15),
	@crib				char(15),
	@fixed_charge	char(15),
	@car1				char(15),
	@car2				char(15)

create table #accnt
(
	accnt				char(10)				default '' not null,
)
create table #pay_by
(
	accnt				char(10)				default '' not null,
	subaccnt			integer				default 0 not null,
	roomno			char(5)				default '' not null,
	name				char(50)				default '' not null,
	pccodes			varchar(255)		default '' not null,
	to_accnt			char(10)				default '' not null,
	number			integer				default 0 not null,
	charge			money					default 0 not null,
	credit			money					default 0 not null
)
create table #pay_for
(
	accnt				char(10)				default '' not null,
	roomno			char(5)				default '' not null,
	name				char(50)				default '' not null,
	pccodes			varchar(255)		default '' not null,
	to_accnt			char(10)				default '' not null
)
create table #message
(
	accnt				char(10)				default '' not null,
	roomno			char(5)				default '' not null,
	name				char(50)				default '' not null,
	msg_type			char(2)				default '' not null,
	msg_descript	char(15)				default '' not null,
	msg_content		char(255)			default '' not null
)
if @langid = 0
	select @city_ledger = '转应收账', @routing = '分账', @comsg = '结账提示', @message = '留言', @location = '去向',
		@rental = '租赁', @extra_bed = '加床', @crib = '婴儿床', @fixed_charge = '固定支出', @car1='接机服务', @car2='送机服务'
else
	select @city_ledger = 'City Ledger', @routing = 'Routing', @comsg = 'C/O Msg', @message = 'Message', @location = 'Location',
		@rental = 'Rental', @extra_bed = 'Extra Bed', @crib = 'Crib', @fixed_charge = 'Fixed Charge', @car1='Pick Up', @car2='Send Off'
-- 找出相应的账号
if @roomno = '' and @accnt = ''				-- 所有
	begin
	insert #accnt select distinct accnt from accnt_set where pc_id = @pc_id and mdi_id = @mdi_id
	-- Pay By
	insert #pay_by (accnt, subaccnt, roomno, pccodes, to_accnt)
		select b.accnt, b.subaccnt, b.roomno, b.pccodes, b.to_accnt from accnt_set a, subaccnt b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt != '' and a.accnt = b.accnt and b.type = '5'
	-- Pay For
	insert #pay_for (accnt, roomno, pccodes, to_accnt)
		select b.accnt, b.roomno, b.pccodes, b.to_accnt from accnt_set a, subaccnt b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt != '' and a.accnt = b.to_accnt and b.type = '5'
	delete #pay_for from accnt_set a
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt = #pay_for.accnt
	end
else if @accnt = ''								-- 指定房间
	begin
	insert #accnt select distinct accnt from accnt_set where pc_id = @pc_id and mdi_id = @mdi_id and roomno = @roomno
	-- Pay By
	insert #pay_by (accnt, subaccnt, roomno, pccodes, to_accnt)
		select b.accnt, b.subaccnt, b.roomno, b.pccodes, b.to_accnt from accnt_set a, subaccnt b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.accnt != '' and a.subaccnt = 0 and a.accnt = b.accnt and b.type = '5'
	-- Pay For
	insert #pay_for (accnt, roomno, pccodes, to_accnt)
		select b.accnt, b.roomno, b.pccodes, b.to_accnt from accnt_set a, subaccnt b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.accnt != '' and a.subaccnt = 0 and a.accnt = b.to_accnt and b.type = '5'
	delete #pay_for from accnt_set a
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0 and a.accnt = #pay_for.accnt
	end
else													-- 指定团体或账号
	begin
	insert #accnt select distinct accnt from accnt_set where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt
	-- Pay For
	insert #pay_by (accnt, subaccnt, roomno, pccodes, to_accnt)
		select b.accnt, b.subaccnt, b.roomno, b.pccodes, b.to_accnt from accnt_set a, subaccnt b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.accnt = @accnt and a.subaccnt = 0 and a.accnt = b.accnt and b.type = '5'
	-- Pay For
	insert #pay_for (accnt, roomno, pccodes, to_accnt)
		select b.accnt, b.roomno, b.pccodes, b.to_accnt from accnt_set a, subaccnt b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.accnt = @accnt and a.subaccnt = 0 and a.accnt = b.to_accnt and b.type = '5'
	delete #pay_for from accnt_set a
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.accnt = @accnt and a.subaccnt = 0 and a.accnt = #pay_for.accnt
	end
if @operation = 'OPEN'
	begin
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, '10', @extra_bed, ltrim(convert(char(10), b.addbed)) + '*' + ltrim(convert(char(10), b.addbed_rate)) from #accnt a, master b
		where a.accnt = b.accnt and b.addbed > 0
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, '20', @crib, ltrim(convert(char(10), b.crib)) + '*' + ltrim(convert(char(10), b.crib_rate)) from #accnt a, master b
		where a.accnt = b.accnt and b.crib > 0
	if @langid = 0
		insert #message (accnt, msg_type, msg_descript, msg_content)
			select b.accnt, '70', @fixed_charge, convert(char(10), starting_time, 111) + '-' + convert(char(10), closing_time, 111) + 
			c.descript + ltrim(convert(char(10), b.quantity)) + '*' + ltrim(convert(char(10), b.amount))
			from #accnt a, fixed_charge b, pccode c
			where a.accnt = b.accnt and b.starting_time <= getdate() and b.closing_time >= getdate() and b.pccode = c.pccode
	else
		insert #message (accnt, msg_type, msg_descript, msg_content)
			select b.accnt, '70', @fixed_charge, convert(char(10), starting_time, 111) + '-' + convert(char(10), closing_time, 111) + 
			c.descript1 + ltrim(convert(char(10), b.quantity)) + '*' + ltrim(convert(char(10), b.amount))
			from #accnt a, fixed_charge b, pccode c
			where a.accnt = b.accnt and b.starting_time <= getdate() and b.closing_time >= getdate() and b.pccode = c.pccode
	end
else
	begin
	--
	delete #accnt where accnt = ''
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, '00', @comsg, b.comsg from #accnt a, master b
		where a.accnt = b.accnt
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, '10', @extra_bed, ltrim(convert(char(10), b.addbed)) + '*' + ltrim(convert(char(10), b.addbed_rate)) from #accnt a, master b
		where a.accnt = b.accnt and b.addbed > 0
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, '20', @crib, ltrim(convert(char(10), b.crib)) + '*' + ltrim(convert(char(10), b.crib_rate)) from #accnt a, master b
		where a.accnt = b.accnt and b.crib > 0
	if @langid = 0
		insert #message (accnt, msg_type, msg_descript, msg_content)
			select b.accnt, '70', @fixed_charge, convert(char(10), starting_time, 111) + '-' + convert(char(10), closing_time, 111) + 
			c.descript + ltrim(convert(char(10), b.quantity)) + '*' + ltrim(convert(char(10), b.amount))
			from #accnt a, fixed_charge b, pccode c
			where a.accnt = b.accnt and b.starting_time <= getdate() and b.closing_time >= getdate() and b.pccode = c.pccode
	else
		insert #message (accnt, msg_type, msg_descript, msg_content)
			select b.accnt, '70', @fixed_charge, convert(char(10), starting_time, 111) + '-' + convert(char(10), closing_time, 111) + 
			c.descript1 + ltrim(convert(char(10), b.quantity)) + '*' + ltrim(convert(char(10), b.amount))
			from #accnt a, fixed_charge b, pccode c
			where a.accnt = b.accnt and b.starting_time <= getdate() and b.closing_time >= getdate() and b.pccode = c.pccode
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, '80', @message, convert(char(255), b.content) from #accnt a, message_leaveword b
		where a.accnt = b.accnt and b.sort = 'LWD' and b.tag < '2' and b.inure < getdate() and b.abate >= getdate()
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, '90', @location, convert(char(255), b.content) from #accnt a, message_leaveword b
		where a.accnt = b.accnt and b.sort = 'LOC' and b.tag < '2' and b.inure < getdate() and b.abate >= getdate()
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, 'A0', @rental, c.name from #accnt a, res_av b, res_plu c
		where a.accnt = b.accnt and b.sta in ('I', 'R') and b.resid = c.resid
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, 'B0', @car1, ltrim(convert(char(10), b.arrrate))  from #accnt a, master b
		where a.accnt = b.accnt and b.arrrate > 0
	insert #message (accnt, msg_type, msg_descript, msg_content)
		select b.accnt, 'C0', @car2, ltrim(convert(char(10), b.deprate))  from #accnt a, master b
		where a.accnt = b.accnt and b.deprate > 0
	-- Pay By
	if @subaccnt = 0
		begin
		delete #pay_by where not to_accnt like 'A%'
		update #pay_by set number = isnull(count(1), 0), charge = isnull(sum(a.charge), 0), credit = isnull(sum(a.credit), 0)
			from account a where #pay_by.accnt = a.accnt and #pay_by.subaccnt = a.subaccnt and a.billno = ''
		update #pay_by set name = b.name from master a, guest b where #pay_by.to_accnt = a.accnt and a.haccnt = b.no
		update #pay_by set name = b.name from ar_master a, guest b where #pay_by.to_accnt = a.accnt and a.haccnt = b.no
		insert #message (accnt, msg_type, msg_descript, msg_content)
			select accnt, '60', @city_ledger,  + "[" + pccodes + "] " + "Pay By [" + rtrim(to_accnt) + "] " + rtrim(name)
			from #pay_by
		end
	end
-- Pay For
update #pay_for set roomno = a.roomno, name = b.name
	from master a, guest b where #pay_for.accnt = a.accnt and a.haccnt = b.no
update #pay_for set name = b.name
	from ar_master a, guest b where #pay_for.accnt = a.accnt and a.haccnt = b.no

insert #message (accnt, msg_type, msg_descript, msg_content)
	select to_accnt, '50', @routing, "Pay for [" + isnull(rtrim(roomno), rtrim(accnt)) + "] " + rtrim(name) + " [" + pccodes + "]"
	from #pay_for

update #message set roomno = a.roomno, name = b.name
	from master a, guest b where #message.accnt = a.accnt and a.haccnt = b.no
update #message set name = b.name
	from ar_master a, guest b where #message.accnt = a.accnt and a.haccnt = b.no
-- 返回结果
select accnt, roomno, name, msg_type, msg_descript, msg_content
	from #message where msg_content != '' order by roomno, msg_type
return
;
