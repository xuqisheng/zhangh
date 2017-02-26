if exists(select * from sysobjects where name = "p_gl_ar_creditcard")
	drop proc p_gl_ar_creditcard;

create proc p_gl_ar_creditcard
	@pc_id				char(4), 
	@mdi_id				integer, 
	@selected			integer,
	@empno				char(10),
	@shift				char(1),
	@option				char(1) = 'S'
as
-----------------------------------------------
--	审核信用卡明细账
-----------------------------------------------
declare
	@bdate				datetime,
	@date					datetime,
	@accnt				char(10),
	@bankcode			char(3),
	@pccode				char(5),
	@amount				money,
	@count				integer,
	@caccnt				char(10),
	@cnumber				integer,
	@descript			char(50),
	@descript1			char(50),
	@ref2					char(50),
	@lastnumb			integer,
	@lastpnumb			integer,
	@lastinumb			integer,
	@balance				money,
	@log_date			datetime,
	@ret					integer,
	@msg					varchar(60)

if exists (select 1 from ar_detail a, ar_creditcard b where b.selected >= @selected and a.accnt = b.accnt and a.number = b.number and a.audit = '1')
	begin
	select @ret = 1, @msg = '当前信用卡账务已全部（或部分）被审核'
	goto RETURN_2
	end
select @log_date = getdate(), @ret = 0, @msg = ''
select @bdate = bdate1 from sysdata
declare c_creditcard_subtotal cursor for select accnt, bdate, waiter, mode1, sum(credit), count(1) from ar_creditcard
	where selected >= @selected group by accnt, bdate, waiter, mode1
declare c_creditcard_detail cursor for select accnt, number from ar_creditcard
	where selected >= @selected and accnt = @accnt and bdate = @date and waiter = @bankcode and mode1 = @pccode
begin tran
save tran creditcard_1
--
open c_creditcard_subtotal
fetch c_creditcard_subtotal into @accnt, @date, @bankcode, @pccode, @amount, @count
while @@sqlstatus = 0
	begin
	delete account_temp where pc_id = @pc_id and mdi_id = @mdi_id
	open c_creditcard_detail
	fetch c_creditcard_detail into @caccnt, @cnumber
	while @@sqlstatus = 0
		begin
		select @descript = convert(char(10), @date, 111) + descript, @descript1 = convert(char(10), @date, 111) + descript1
			from pccode where pccode = @pccode
		select @ref2 = descript from basecode where cat = 'bankcode' and code = @bankcode
		update ar_detail set audit = '1',empno0 = @empno, date0 = getdate(), shift0 = @shift where accnt = @caccnt and number = @cnumber
		insert account_temp (pc_id, mdi_id, accnt, number, mode1, billno, selected, charge, credit)
			select @pc_id, @mdi_id, accnt, number, mode1, billno, 1, charge + charge0 - charge9, credit + credit0 - credit9
			from ar_detail where accnt = @caccnt and number = @cnumber
		fetch c_creditcard_detail into @caccnt, @cnumber
		end
	close c_creditcard_detail
	if @count > 1
		exec @ret = p_gl_ar_compress @pc_id, @mdi_id, @shift, @empno, @accnt, 1, @descript, @descript1, @pccode, '99', @ref2, @date, 'TR', @msg out
	fetch c_creditcard_subtotal into @accnt, @date, @bankcode, @pccode, @amount, @count
	end 
close c_creditcard_subtotal
deallocate cursor c_creditcard_subtotal
deallocate cursor c_creditcard_detail
--
RETURN_1:
if @ret ! = 0
	rollback tran creditcard_1
else
	delete ar_creditcard where selected >= @selected
commit tran
RETURN_2:
if @option = 'S'
	select @ret, @msg
return @ret;
