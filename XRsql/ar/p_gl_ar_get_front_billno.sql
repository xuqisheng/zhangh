// 找出原始明细账单号
if exists(select * from sysobjects where name = "p_gl_ar_get_front_billno")
	drop proc p_gl_ar_get_front_billno;

create proc p_gl_ar_get_front_billno
	@pc_id				char(4),
	@mdi_id				integer,
	@accnt				char(10),					// 账号
	@number				integer						// 账次
as
declare
	@foaccnt				char(10),					// 前台账号
	@foroomno			char(5),						// 前台房号
	@fonumber			integer,
	@fobillno			char(10),
	@ret					integer,
	@msg					varchar(60)

select @foaccnt = accnt, @foroomno = roomno, @fonumber = number
	from ar_account where ar_accnt = @accnt and ar_number = @number and ar_tag = 'P'
select @fobillno = billno from account where accnt = @foaccnt and number = @fonumber
if @fobillno is null
	select @fobillno = billno from haccount where accnt = @foaccnt and number = @fonumber
//if @fobillno like 'B%'
//	begin
//	end
//else
//	begin
//	end
if rtrim(@foaccnt) is null
	select @ret = 1, @msg = '没有账单可供显示'
else
	begin
	-- 插入slected_account
	delete selected_account where type = "2" and pc_id = @pc_id and (mdi_id = @mdi_id or mdi_id = -@mdi_id)
	insert selected_account values ("2", @pc_id, @mdi_id, @foaccnt, 0)
	select @ret = 0, @msg = ''
	end
select @ret, @msg, @foaccnt, @foroomno, @fobillno
return 0
;
