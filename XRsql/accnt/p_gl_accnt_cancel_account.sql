if exists(select * from sysobjects where name = 'p_gl_accnt_cancel_account')
	drop proc p_gl_accnt_cancel_account
;
create proc p_gl_accnt_cancel_account		
	@pc_id				char(4),
	@mdi_id				integer, 
	@shift				char(1), 
	@empno				char(10)
as
-- 冲销指定账目, 输入参数确保非NULL, 包括费用和款项 
declare
	@ret					integer, 
	@msg					char(60), 
	@lic_buy_1			varchar(255),
	@lic_buy_2			varchar(255),
	@bdate				datetime, 					--营业日期
	@log_date			datetime,
	@package_date		datetime,
	@accnt				char(10), 
	@number				integer, 
	@crradjt				char(2), 					--账务标志
	@pccode				char(5), 
	@argcode				char(3), 
	@credit				money, 
	@charge				money, 
	@package_d			money, 
	@roomno				char(5), 
	@groupno				char(10), 
	@lastnumb			integer, 
	@lastinumb			integer, 
	@balance				money, 
	@catalog				char(3), 
	@billno				char(10),
	@pos					integer,
	@amount				money,
	@ref					varchar(24),
	@ref1					varchar(10),
	@ref2					varchar(50),
	@cardtype			char(10), 
	@cardno 				char(20), 
	@cardar				char(10),
	@id					char(10),
	@deptno2				char(5),
	@deptno3				char(5),
	@deptno6				char(5),
	@modu_id				char(2),
	@quantity			money,
	@hotelid 			varchar(20),
	@arcreditcard		char(1)

select @ret = 0, @bdate = bdate1, @log_date = getdate() from sysdata
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
begin tran
save tran cancel
exec p_GetAccnt1 @type = 'BIL', @accnt = @billno out
select @billno = 'C' + substring(@billno, 2, 9)
declare c_cancel cursor for 
	select a.accnt, a.number, - a.credit, - a.charge, - a.package_d, a.pccode, a.argcode, a.log_date from account a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.accnt = b.accnt and a.number = b.number
open c_cancel
fetch c_cancel into @accnt, @number, @credit, @charge, @package_d, @pccode, @argcode, @package_date
while @@sqlstatus = 0
	begin
	exec @ret = p_gl_accnt_crradjt @accnt, @number, 'CL', @shift, @empno, @msg out
	if	@ret = 0
		begin
		select @crradjt = substring(@msg, 1, 2)
		update account set crradjt = @crradjt, billno = @billno where current of c_cancel
		exec @ret = p_gl_accnt_update_balance @accnt, @pccode, @charge, @credit, @roomno out, 
			@groupno out, @lastnumb out, @lastinumb out, @balance out, @catalog out, @msg out 
		if @ret = 0
			begin
		-- add by tcr for cms 2004.6.28
			if exists (select 1 from cms_rec where to_accnt = @accnt and number=@number and back='F')	
				begin  -- simon 200605 
				update cms_rec set sta='X',cby=@empno,changed=getdate(),logmark=logmark+1 where to_accnt=@accnt and number=@number and back='F' 

				-- 因为需要按照明细入账，因此为了减少混乱帐次，取消插入负的帐次  simon 2006.5 
--				insert cms_rec(accnt, name, number, type, roomno, cusno, agent, source, arr, dep, rmrate, exrate, dsrate, rmsur, rmtax, 
--					w_or_h, mode, cmscode, cmsunit, cmstype, cmsvalue, cms0, cms, ref, bdate, post, postdate, cby, changed, market, to_accnt, sta, back)
--					select accnt, name, @lastnumb, type, roomno, cusno, agent, source, arr, dep, rmrate, exrate, dsrate, rmsur, rmtax, 
--					-1 * w_or_h, mode, cmscode, cmsunit, cmstype, -1 * cmsvalue, -1 * cms0, -1 * cms, ref, bdate, @empno, getdate(), @empno, getdate(), market, @accnt, sta, back
--					from cms_rec where to_accnt = @accnt and number = @number
				end

		-- 贵宾卡：积分付款 & 远程贵宾卡记账
		-- ref2 = Card=JL2-108881011-AR00018；  注意，如果ref2被修改了格式，将导致无法撤销
			select @deptno2 = deptno2, @deptno3 = deptno3, @deptno6 = deptno6 from pccode where pccode = @pccode
			if @deptno2 = 'PTS' or @deptno2 = 'CAR'
				begin
				select @amount = credit, @quantity = quantity, @ref2 = ref2, @modu_id = modu_id from account where accnt = @accnt and number = @number
				select @pos = charindex('=', @ref2)
				if @pos > 0 
					begin
					select @ref2 = ltrim(stuff(@ref2, 1, @pos, ''))								-- ref2 = JL2-108881011-AR00018；  
					select @pos = charindex('-', @ref2)
					if @pos > 0
						begin
						select @cardtype = substring(@ref2, 1, @pos - 1)						-- get >> cardtype 
						select @ref2 = ltrim(stuff(@ref2, 1, @pos, ''))							-- ref2 = 108881011-AR00018；  
					-- 积分付款的情况
						if @deptno2 = 'PTS'
							begin
							select @pos = charindex(';', @ref2)
							if @pos > 0 
								select @cardno = substring(@ref2, 1, @pos-1)
							else
								select @cardno = substring(@ref2, 1, 20)
							select @ref = rtrim(descript1) + '[' + rtrim(descript) + ']' from basecode where cat = 'moduno' and code = @modu_id
							if @@rowcount = 0	select @ref = 'Front'
							select @ref1 = @accnt, @ref2 = 'Card=' + rtrim(@cardtype) + '-' + rtrim(@cardno) + ';'
							select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
							exec @ret = p_gds_vipcard_posting 'D', @modu_id, @pc_id, 0, @shift, @empno, @cardno, @hotelid, @bdate, '-', @amount, @amount, 0, 0, 0, @quantity, '', @accnt, @ref, @ref1, @ref2, 'R', @ret output, @msg output
							end
					-- 远程贵宾卡记账的情况
						else if @deptno2 = 'CAR'
							begin
							select @pos = charindex('-', @ref2)
							if @pos > 0
								begin
								select @cardno = substring(@ref2, 1, @pos - 1)					-- get >> cardno 
								select @ref2 = ltrim(stuff(@ref2, 1, @pos, ''))					-- ref2 = AR00018；  
								select @pos = charindex(';', @ref2)
								if @pos > 0 
									select @cardar = substring(@ref2, 1, @pos-1)
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
					@shift, @empno, 'CO', tofrom, accntof, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, @billno
					from account where accnt = @accnt and number = @number
				if @@rowcount = 0
					select @ret = 1, @msg = '帐务表插入失败'
				else
					begin
					select @arcreditcard = isnull((select value from sysoption where catalog = 'ar' and item = 'creditcard'), 'F')
				-- 冲信用卡账务 & AR账务
					if ((@arcreditcard = 'T' and exists (select 1 from bankcard where pccode = @pccode)) or @deptno2 = 'TOR')
						and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
						exec @ret = p_gl_ar_cancel_account @accnt, @number, @shift, @empno, @msg out 
				-- 冲销已吃的早餐
					if @package_d != 0 and not @argcode like '9%'
						begin
						exec @ret = p_gl_accnt_posting_package @pc_id, @mdi_id, @accnt, @pccode out, @package_d out, 0, 0, 0, @bdate, @package_date, @msg out
						if @ret = 0
						update package_detail set account_accnt = @accnt, account_number = @lastnumb, account_date = @log_date
							where posted_accnt = @accnt and account_accnt = ''
						end
				-- 冲销可吃的早餐
					else
						update package_detail set tag = '5' where account_accnt = @accnt and account_number = @number
					end
				end
			end
		end
	if @ret != 0
		goto RETURN_1
	fetch c_cancel into @accnt, @number, @credit, @charge, @package_d, @pccode, @argcode, @package_date
	end
close c_cancel
deallocate cursor c_cancel
RETURN_1:
if @ret != 0
	rollback tran cancel
else
	insert billno (billno, accnt, bdate, empno1, shift1) select @billno, @accnt, @bdate, @empno, @shift
commit tran
select @ret, @msg
return @ret
;
