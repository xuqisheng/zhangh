/* 提前结账预处理 */

if  exists(select * from sysobjects where name = 'p_gl_accnt_ahead_checkout')
	drop proc p_gl_accnt_ahead_checkout;

create proc p_gl_accnt_ahead_checkout
	@modu_id				char(2), 
	@pc_id				char(4), 
	@mdi_id				integer, 
	@roomno				char(5), 
	@accnt				char(10), 
	@shift				char(1), 
	@empno				char(10), 
	@checkout			datetime,
	@operation			char(10) = 'posting'					// calculate : 仅计算房费不入账
as
declare
	@days					money,
	@selemark			char(17), 
	@rmpostdate			datetime,
	@w_or_h				integer, 
	@ratemode			char(6), 
	@half_time			char(5),
	@whole_time			char(5),
	@quantity			money,
	@charge1				money, 
	@charge2				money, 
	@charge3				money, 
	@charge4				money, 
	@charge5				money, 
	@rtreason			char(3), 
	@package				char(4),
	@pccode				char(5),
	@argcode				char(3),
	@rmpccode			char(5),
	@ratecode			char(10), 
	@column				integer,
	@amount				money, 
	@rule_calc			char(10),
	@mode					char(10),
	@ref2					char(50), 
	@caccnt				char(10), 
	@csta					char(1), 
	@class				char(1), 
	@count				money,
	//
	@srqs					char(18),
	@tranlog				char(10),
	@extrainf			char(30),
	@pos					integer,
	@posting				money, 
	@ret					money, 
	@msg					varchar(60)
//
create table #account (
	selemark		char(26)		not null,
	accnt			char(10)		not null,
	number		integer		not null,
	amount		money			default 0 not null,
	package_c	money			default 0 not null,
	ratecode		char(10)		not null,
	ref2			char(50)		not null,
	mode			char(10)		not null,
	rmpostdate	datetime		not null
)
//
select @posting = 0, @ret = 0, @msg = ''
select @days = datediff(dd, rmpostdate, @checkout) - 1 from sysdata
select @half_time = isnull((select value from sysoption where catalog = 'ratemode' and item = 'd_half_rmrate'), '12:00')
select @whole_time = isnull((select value from sysoption where catalog = 'ratemode' and item = 'd_whole_rmrate'), '18:00')
select @rmpccode = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccode'), '000')
if convert(char(8), @checkout, 108) > @whole_time
	select @days = @days + 1
else if convert(char(8), @checkout, 108) > @half_time
	select @days = @days + 0.5
-- 1. 生成预过房费
declare c_rmpostpackage cursor for
	select a.pccode, a.argcode, a.amount, a.quantity, a.rule_calc, a.code, b.commission
	from rmpostpackage a, pccode b
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.accnt = @caccnt and a.pccode = b.pccode order by a.number
if @roomno = '' and @accnt = ''				-- 所有
	declare c_accnt cursor for select a.accnt, a.sta from accnt_set a where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 order by a.accnt desc
else if @accnt = ''								-- 指定房间
	declare c_accnt cursor for select a.accnt, a.sta from accnt_set a where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0 order by a.accnt desc
else													-- 指定团体或账号
	declare c_accnt cursor for select a.accnt, a.sta from accnt_set a where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.accnt = @accnt and a.subaccnt = 0 order by a.accnt desc
begin tran
save  tran tran_ahead
open c_accnt
fetch c_accnt into @caccnt, @csta
while @@sqlstatus = 0
	begin
	select @rmpostdate = dateadd(dd, 1, rmpostdate), @count = @days from sysdata
	while @count > 0 and (@csta = 'I' or @csta = 'R')
-- and @caccnt like 'F%'		有Fixed_Charge的消费账和应收账提前结帐
		begin
		delete rmpostpackage where pc_id = @pc_id and mdi_id = @mdi_id
		delete rmpostvip where pc_id = @pc_id and mdi_id = @mdi_id
		//
		if @count >= 1
			begin
			select @w_or_h = 1, @quantity = 1
			exec @ret = p_gl_audit_rmpost_calculate @rmpostdate, @caccnt, @w_or_h, 0, 0, 0, 
				@charge1 out, @charge2 out, @charge3 out, @charge4 out, @charge5 out, 'FN', @pc_id, @mdi_id
			end
		else
			begin
			select @w_or_h = 2, @quantity = 0.5
			exec @ret = p_gl_audit_rmpost_calculate @rmpostdate, @caccnt, @w_or_h, 0, 0, 0, 
				@charge1 out, @charge2 out, @charge3 out, @charge4 out, @charge5 out, 'FD', @pc_id, @mdi_id
			end
		//
		if @ret = 0
			begin
			select @ratecode = ratecode, @rtreason = rtreason, @class = class from master where accnt = @caccnt 
			select @amount = @charge1 - @charge2 + @charge3 + @charge4 + @charge5, @selemark = 'A' + convert(char(10), @rmpostdate, 111)
			select @mode = 'T' + @roomno, @ref2 = substring(@roomno + space(5), 1, 5) + '(' + convert(char(10), @rmpostdate, 111) + ') 预收'
			-- 有Fixed_Charge的消费账和应收账提前结帐
			if @operation = 'calculate' and @class = 'F'
				insert #account select @selemark, accnt, lastnumb, @amount, 0, ratecode, @ref2, @mode, @rmpostdate from master where accnt = @caccnt
			else if @operation = 'calculate'
				insert #account select @selemark, accnt, lastnumb, 0, 0, ratecode, @ref2, @mode, @rmpostdate from master where accnt = @caccnt
			else if @class = 'F'
				begin
				exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id, @mdi_id, @shift, @empno, @caccnt, 0, @rmpccode, '', 
					@quantity, @amount, @charge1, @charge2, @charge3, @charge4, @charge5, @ratecode, @ref2, @rmpostdate, @rtreason, @mode, 'ARNY', 0, null, @msg out
				insert #account select @selemark, accnt, lastnumb, @amount, 0, ratecode, @ref2, @mode, @rmpostdate from master where accnt = @caccnt
				end
			-- 房租包价(将早餐, 娱乐等费用入帐)
			if @ret = 0
				begin
				-- 将Package需要反映在Account中的费用入帐
				open c_rmpostpackage
				fetch c_rmpostpackage into @pccode, @argcode, @amount, @quantity, @rule_calc, @package, @column
				while @@sqlstatus = 0
					begin
					if @rule_calc like '1%'
						begin
						select @msg = '', @charge1 = 0, @charge2 = 0, @charge3 = 0, @charge4 = 0, @charge5 = 0
						if @column = 2
							select @charge2 = - @amount
						else if @column = 3
							select @charge3 = @amount
						else if @column = 4
							select @charge4 = @amount
						else if @column = 5
							select @charge5 = @amount
						else
							select @charge1 = @amount
						if rtrim(@package) is null
							select @package = @mode
						//
						if @operation = 'calculate'
							begin
							select @posting = @posting + @amount
							update #account set package_c = package_c + @amount where accnt = @caccnt and rmpostdate = @rmpostdate
							end
						else
							begin
							exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id, @mdi_id, @shift, @empno, @caccnt, 0, @pccode, @argcode, 
								@quantity, @amount, @charge1, @charge2, @charge3, @charge4, @charge5, @ratecode, @ref2, @rmpostdate, @rtreason, @package, 'ARNN', 0, null, @msg out
							insert #account select @selemark, accnt, lastnumb, 0, @amount, ratecode, @ref2, @package, @rmpostdate from master where accnt = @caccnt
							end
						end
					if @ret != 0
						break
					fetch c_rmpostpackage into @pccode, @argcode, @amount, @quantity, @rule_calc, @package, @column
					end
				close c_rmpostpackage
				/* HZDS GaoLiang 1999/10/21 */
//				select @srqs = srqs, @tranlog = tranlog from master where accnt = @caccnt
//				if charindex('VV', @srqs) > 0
//					begin
//					if exists(select 1 from rmpostvip where pc_id = @pc_id and cusid = @tranlog and charindex(@caccnt, accnts) > 0)
//						begin
//						select @pos = charindex('VV', @srqs)
//						update master set srqs = substring(@srqs, 1, @pos - 1) + substring(@srqs, @pos + 4, 18), logmark = logmark + 1 where accnt = @caccnt
//						select @ent1 = number1, @ent2 = number2 from rmpostvip where pc_id = @pc_id and cusid = @tranlog
//						select @extrainf = extrainf from cusdef where cusid = @tranlog
//						select @pos = charindex('|', @extrainf)
////						if @pos = 0
////						select @pos = 1
//						update cusdef set extrainf = rtrim(convert(char(5), @ent1)) + '/' + rtrim(convert(char(5), @ent2)) + substring(@extrainf, @pos, 30)
//							where cusid = @tranlog
//						end
//					end
				end
			end
		select @count = @count - 1, @rmpostdate = dateadd(dd, 1, @rmpostdate)
		end
	fetch c_accnt into @caccnt, @csta
	end
deallocate cursor c_rmpostpackage
close c_accnt
deallocate cursor c_accnt
if @operation = 'calculate'
	begin
	commit tran 
	create table #ahead (
		tag			char(1)		default '0' not null,
		roomno		char(5)		default '' not null,
		accnt			char(10)		default '' not null,
		name			char(50)		default '' not null,
		charge		money			default 0 not null,
		credit		money			default 0 not null,
		amount		money			default 0 not null,
		package_c	money			default 0 not null,
		ratecode		char(10)		default '' not null,
		ref2			char(50)		default '' not null,
		mode			char(10)		default '' not null,
		rmpostdate	datetime		null
	)
	insert #ahead (accnt, amount, package_c) select accnt, sum(amount), sum(package_c) from #account group by accnt
	update #ahead set charge = a.charge, credit = a.credit from master a where #ahead.accnt = a.accnt
	insert #ahead (tag, accnt, amount, package_c, ratecode, ref2, mode, rmpostdate)
		select '1', accnt, amount, package_c, ratecode, ref2, mode, rmpostdate from #account
	update #ahead set roomno = a.roomno, name = b.name from master a, guest b where #ahead.accnt = a.accnt and a.haccnt = b.no
	select tag, roomno, accnt, name, charge, credit, amount, package_c, ratecode, ref2, mode, rmpostdate
		from #ahead order by roomno, accnt, tag, rmpostdate
--	select @ret, convert(char(12), @posting)
	return @ret
	end
-- 2. 生成预过房费
declare c_account cursor for
	select b.selemark, a.accnt, a.pccode, a.argcode, - a.quantity, - a.charge, - a.charge1, - a.charge2, - a.charge3, - a.charge4, - a.charge5, b.ratecode, b.ref2, b.mode, b.rmpostdate, a.reason, a.package
	from account a, #account b where a.accnt = b.accnt and a.number = b.number
	order by a.accnt, a.number
open c_account
fetch c_account into @selemark, @caccnt, @pccode, @argcode, @quantity, @amount, @charge1, @charge2, @charge3, @charge4, @charge5, @ratecode, @ref2, @mode, @rmpostdate, @rtreason, @package
while @@sqlstatus = 0
	begin
	exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id, @mdi_id, @shift, @empno, @caccnt, 0, @pccode, @argcode, 
		@quantity, @amount, @charge1, @charge2, @charge3, @charge4, @charge5, @ratecode, @ref2, @rmpostdate, @rtreason, @mode, 'ARNN', 0, null, @msg out
	fetch c_account into @selemark, @caccnt, @pccode, @argcode, @quantity, @amount, @charge1, @charge2, @charge3, @charge4, @charge5, @ratecode, @ref2, @mode, @rmpostdate, @rtreason, @package
	end
close c_account
deallocate cursor c_account
//
if @ret != 0
	rollback tran tran_ahead
commit tran 
-- 3. 选中所有费用(本来可以第二步做，为防止死锁改在事务以外)
insert account_temp (pc_id, mdi_id, accnt, number)
	select @pc_id, @mdi_id, accnt, number from #account
update account_temp set selected = 1 where pc_id = @pc_id and mdi_id = @mdi_id
//
select @ret, @msg
return @ret
;

