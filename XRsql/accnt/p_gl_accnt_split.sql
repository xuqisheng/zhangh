-- 拆分某笔帐目 
if exists(select * from sysobjects where name = 'p_gl_accnt_split')
	drop proc p_gl_accnt_split;

create proc p_gl_accnt_split
	@accnt				char(10),
	@number				integer,
	@amount				money, 
	@shift				char(1),
	@empno				char(10)
as
declare
	@ret					integer,
	@msg					varchar(60),
	@billno				char(10),
	@log_date			datetime,
	@argcode				char(3), 
	@ref					char(24), 
	@oamount				money, 
	@credit				money, 
	@charge				money, 
	@balance				money, 
	@roomno				char(5), 
	@groupno				char(10), 
	@catalog				char(3), 
	@lastnumb			integer

select @ret = 0, @log_date = getdate()
select @ref = ref, @argcode = argcode, @oamount = charge + credit, @billno = billno
	from account where accnt = @accnt and number = @number
if @@rowcount = 0
	begin
	select @ret = 1, @msg = '没有发现需要拆分的账目'
	goto RETURN_1
	end
if @billno != ''
	begin
	select @ret = 1, @msg = '当前账目不能被拆分'
	goto RETURN_1
	end
--
if @argcode like '9%'
	select @charge = 0, @credit = @amount
else
	select @charge = @amount, @credit = 0
begin tran
save tran p_gl_accnt_split_s1
-- 1.取新的的账次
exec @ret = p_gl_accnt_update_balance @accnt, '9', 0, 0, @roomno out, @groupno out, 
	@lastnumb out, 0, @balance out, @catalog out, @msg out
if @ret = 0 
	begin
	-- 2.新增一行账
	insert account (accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
		quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, 
		shift, empno, crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno, 
		empno0, date0, shift0, mode1, pnumber, package)
		select accnt, subaccnt, @lastnumb, number, modu_id, log_date, bdate, date, pccode, argcode, 
		0, charge - @charge, charge - @charge, 0, 0, 0, 0, 0, 0, 0, credit - @credit, balance, 
		shift, empno, crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, billno, 
		@empno, @log_date, @shift, mode1, pnumber, 'SP'
		from account where accnt = @accnt and number = @number
	-- 3.修改原来的账
	if @@rowcount = 0
		select @ret = 1, @msg = '账务表插入失败'
	else
		begin
		update account set charge = @charge, charge1 = charge1 - (charge - @charge), credit = @credit, balance = balance - (charge - credit) + (@charge - @credit), package = 'S'
			where accnt = @accnt and number = @number
		if @@rowcount <> 1
			select @ret = 1, @msg = '账务表修改失败'
		else
			insert lgfl (columnname, accnt, old, new, empno, date)
				select 'a_split', @accnt, '[' + ltrim(convert(char(10), @number)) + ']' + ltrim(@ref) + ltrim(convert(char(10), @oamount)),
				'[' + ltrim(convert(char(10), @number)) + ']' + ltrim(convert(char(10), @amount)) + ' + [' + ltrim(convert(char(10), @lastnumb)) + 
				']' + ltrim(convert(char(10), @oamount - @amount)), @empno, @log_date
		end
	end
if @ret != 0
	rollback tran p_gl_accnt_split_s1
commit tran
RETURN_1:
select @ret, @msg 
return @ret
;
