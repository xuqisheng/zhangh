if exists(select * from sysobjects where name = 'p_gl_accnt_cancel_checkout')
	drop proc p_gl_accnt_cancel_checkout;

create proc p_gl_accnt_cancel_checkout
	@shift				char(1),
	@empno				char(10),
	@billno				char(10)
as
--  撤消某次部分结账 
declare
	@ret					integer,
	@msg					varchar(60),
	@lic_buy_1			varchar(255),
	@lic_buy_2			varchar(255),
	@log_date			datetime,
	@billbase			char(7),
	@accnt				char(10),
	@sta					char(1),
	@number				integer,
--
	@cbillno				char(10),
	@pccode				char(5),
	@argcode				char(2),
	@cshift				char(1),
	@cempno				char(10),
	@correct				char(10),
	@roomno				char(5), 
	@groupno				char(10), 
	@lastnumb			integer, 
	@lastinumb			integer, 
	@credit				money, 
	@charge				money, 
	@balance				money, 
	@catalog				char(3),
	@bdate				datetime,
	@cdate				datetime,
	@pos					integer,
	@amount				money,
	@ref					varchar(24),
	@ref1					varchar(10),
	@ref2					varchar(50),
	@cardtype			char(10), 
	@cardno		 		char(20), 
	@cardar				char(10),
	@id					char(10),
	@deptno2				char(5),
	@deptno3				char(5),
	@deptno6				char(5),
	@modu_id				char(2),
	@quantity			money,
	@hotelid		 		varchar(20),
	@pc_id				char(4),
	@arcreditcard		char(1)

select @ret = 0, @log_date = getdate(), @bdate=bdate1 from sysdata
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
select @msg = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), 'ODEX')
select @correct = value from sysoption where catalog = 'account' and item = 'cancel_partout'
select @billbase = 'B' + substring(convert(char(10), billbase), 1, 5) + '%' from sysdata
if (select count(1) from accthead where canpartout ='T') = 0
	select @ret = 1, @msg = '夜间稽核处于关键区,暂时还不能进行部分结账有关操作'
else if not @billno like @billbase
	select @ret = 1, @msg = '只能撤消当天结的账'
else if not exists(select 1 from account where billno = @billno)
	select @ret = 1, @msg = '没有单号为“%1”的结账可供撤销^' + @billno
else if @correct<>'ALL' -- simon 2008.5.30 
begin
	select @accnt = isnull((select min(accnt) from billno where billno=@billno), '')
	if @accnt<>''
	begin
		select @cempno=empno1, @cshift=shift1, @cdate=bdate from billno where billno=@billno and accnt=@accnt 
		if @correct='SELF_ALL' and @shift<>@cshift 
			select @ret = 1, @msg = '只能撤消当班的账'
		else if @correct='SELF_SHIFT' and (@shift<>@cshift or @empno<>@cempno)
			select @ret = 1, @msg = '只能撤消本人当班的账'
	end 
end 
if @ret = 1
	begin
	select @ret, @msg 
	return @ret
	end
--
begin tran
save tran p_gl_accnt_cancel_checkout_s1
-- 锁住账号, 同时检查有效性
declare c_accnt cursor for
	select distinct accnt from account where billno = @billno
open c_accnt
fetch c_accnt into @accnt
while @@sqlstatus = 0
	begin
	update master set sta = sta where accnt = @accnt
	select @sta = sta from master where accnt = @accnt
	if @sta is null
		select @ret = 1, @msg = '账号%1不存在^' + @accnt
	else if charindex(@sta, @msg) > 0
		select @ret = 1, @msg = '账号%1已结，该笔结账操作不能被撤销。除非重新入住^' + @accnt
	if @ret != 0
		goto RETURN_1
	fetch c_accnt into @accnt
	end
-- 冲销合并结账账目
exec p_GetAccnt1 @type = 'BIL', @accnt = @cbillno out
select @cbillno = 'C' + substring(@cbillno, 2, 9)
declare c_account cursor for
	select accnt, number, - credit, - charge, pccode, argcode, shift, empno, bdate from account where billno = @billno
open c_account
fetch c_account into @accnt, @number, @credit, @charge, @pccode, @argcode, @cshift, @cempno, @cdate
while @@sqlstatus = 0
	begin
	if @argcode = '99' and (@correct = 'ALL' or (@correct = 'SELF_ALL' and @cempno = @empno) or 
		(@correct = 'SELF_SHIFT' and @cempno = @empno and @cshift = @shift and @cdate=@bdate) or (@pccode = '9'))
		begin
		update account set crradjt = 'C ', waiter = '', billno = @cbillno where current of c_account
		exec @ret = p_gl_accnt_update_balance @accnt, @pccode, @charge, @credit, @roomno out, 
			@groupno out, @lastnumb out, @lastinumb out, @balance out, @catalog out, @msg out 
		if @ret = 0
			begin
		-- 贵宾卡：积分付款 & 远程贵宾卡记账
		-- ref2 = Card = JL2-108881011-AR00018；  注意，如果ref2被修改了格式，将导致无法撤销
			select @deptno2 = deptno2, @deptno3 = deptno3, @deptno6 = deptno6 from pccode where pccode = @pccode
			if @@rowcount = 0
				select @deptno2 = '', @deptno3 = '', @deptno6 = ''
			if @deptno2 = 'PTS' or @deptno2 = 'CAR'
				begin
				select @amount = credit, @quantity = quantity, @ref2 = ref2, @modu_id = modu_id from account where accnt = @accnt and number = @number
				select @pos = charindex('=', @ref2)
				if @pos > 0 
					begin
					select @ref2 = ltrim(stuff(@ref2, 1, @pos, ''))							-- ref2 = JL2-108881011-AR00018；  
					select @pos = charindex('-', @ref2)
					if @pos > 0
						begin
						select @cardtype = substring(@ref2, 1, @pos - 1)					-- get >> cardtype 
						select @ref2 = ltrim(stuff(@ref2, 1, @pos, ''))						-- ref2 = 108881011-AR00018；  
						if @deptno2 = 'PTS'															-- 积分付款的情况
							begin
							select @pos = charindex(';', @ref2)
							if @pos > 0 
								select @cardno = substring(@ref2, 1, @pos-1)
							else
								select @cardno = substring(@ref2, 1, 20)
							select @pc_id = 'pcid'
							select @ref = rtrim(descript1) + '[' + rtrim(descript) + ']' from basecode where cat = 'moduno' and code = @modu_id
							if @@rowcount = 0	select @ref = 'Front'
							select @ref1 = @accnt, @ref2 = 'Card=' + rtrim(@cardtype) + '-' + rtrim(@cardno) + ';'
							select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
							exec @ret = p_gds_vipcard_posting 'D', @modu_id, @pc_id, 0, @shift, @empno, @cardno, @hotelid, @bdate, '-', @amount, @amount, 0, 0, 0, @quantity, '', @accnt, @ref, @ref1, @ref2, 'R', @ret output, @msg output
							end
						else if @deptno2 = 'CAR'													-- 远程贵宾卡记账的情况
							begin
							select @pos = charindex('-', @ref2)
							if @pos > 0
								begin
								select @cardno = substring(@ref2, 1, @pos - 1)				-- get >> cardno 
								select @ref2 = ltrim(stuff(@ref2, 1, @pos, ''))				-- ref2 = AR00018；  
								select @pos = charindex(';', @ref2)
								if @pos > 0 
									select @cardar = substring(@ref2, 1, @pos - 1)
								else
									select @cardar = substring(@ref2, 1, 10)
								exec p_GetAccnt1 'CAR', @id output
								insert vipcocar(id, cardno, cardtype, cardar, bdate, modu_id, acttype, accnt, number, code, amount, empno, log_date, sendout, sendby, sendtime, shift, sendshift)
									values(@id, @cardno, @cardtype, @cardar, @bdate, '02', 'F', @accnt, @number, @pccode, @amount, @empno, @log_date, 'F', '', null, @shift, '')
								if @@rowcount = 0
									select @ret = 1, @msg = '撤销远程记账错误'
								end
							end
						end
					end
				end
			if @ret = 0
				begin
				insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
					quantity, charge, charge1, charge2, charge3, charge4, charge5, credit, package_d, package_c, package_a, balance, 
					shift, empno, crradjt, tofrom, accntof, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, billno)
					select accnt, subaccnt, @lastnumb, @number, modu_id, @log_date, bdate, date, pccode, argcode, 
					- quantity, - charge, - charge1, - charge2, - charge3, - charge4, - charge5, - credit, - package_d, - package_c, - package_a, @balance, 
					@shift, @empno, 'CO', tofrom, accntof, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, @cbillno
					from account where accnt = @accnt and number = @number
				if @@rowcount = 0
					select @ret = 1, @msg = '账务表插入失败'
				else
					begin
					select @arcreditcard = isnull((select value from sysoption where catalog = 'ar' and item = 'creditcard'), 'F')
				-- 冲信用卡账务 & AR账务
					if ((@arcreditcard = 'T' and exists (select 1 from bankcard where pccode = @pccode)) or @deptno2 = 'TOR')
						and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
						exec @ret = p_gl_ar_cancel_account @accnt, @number, @shift, @empno, @msg out 
					update package_detail set tag = '5' where account_accnt = @accnt and account_number = @number
					end
				end
			end
		if @ret = 1
			goto RETURN_2
		end
	fetch c_account into @accnt, @number, @credit, @charge, @pccode, @argcode, @cshift, @cempno, @cdate 
	end
-- 将转账明细放入transfer_log,以便统计记账收回情况
update transfer_log set archarge = 0, arcredit = 0, arempno = @empno, ardate = getdate(), billno = ''
	from account a
	where a.accnt = @accnt and a.billno = @billno and a.accnt = transfer_log.araccnt and a.number = transfer_log.arnumber
--
update account set billno = '' where billno = @billno
RETURN_2:
close c_account
deallocate cursor c_account
RETURN_1:
close c_accnt
deallocate cursor c_accnt
if @ret = 0
	update billno set empno2 = @empno, shift2 = @shift, date2 = getdate() where billno = @billno
else
	rollback tran p_gl_accnt_cancel_checkout_s1
commit tran
select @ret, @msg 
return @ret
;
