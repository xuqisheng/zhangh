
if exists(select * from sysobjects where name = 'p_gl_ar_posting' and type ='P')
	drop proc p_gl_ar_posting;

create proc p_gl_ar_posting				-- 输入参数确保非NULL, 包括逃账
	@selemark			char(27) = 'A',	-- A + mode1(10) + waiter(3)
	@modu_id				char(2), 
	@pc_id				char(4), 
	@mdi_id				integer, 
	@shift				char(1), 
	@empno				char(10), 
	@accnt				char(10), 
	@subaccnt			integer, 
	@pccode				char(5),				-- 费用码
	@argcode				char(3),				-- 改编码(打印在账单的代码)
	@quantity			money,				-- 数量
	@amount				money, 				-- 金额
	@amount1				money, 
	@amount2				money, 
	@amount3				money, 
	@amount4				money, 
	@amount5				money, 
	@ref1					char(10),			-- 单号
	@ref2					char(50),			-- 摘要
	@date					datetime, 
	@reason				char(3),				-- 优惠理由
	@mode					char(10), 			-- 
	@operation			char(5), 			-- 第一位：'A'调整, 'I'输入, 'P'转帐
													--	第二位：'S' select, 'R' return
													--	第三位：是否使用Package。'Y' YES, 'N' NO
													--	第四位：是否使用自动转账。'Y' YES, 'N' NO
													--	第五位：暂时未用
	@a_number			integer, 			-- 调整的账次
	@to_accnt			char(10) output, 
	@msg					char(100) output	-- 客人姓名
as
-- 费用输入处理

declare
	@ret					integer, 
	@bdate				datetime,			-- 营业日期
	@log_date			datetime,			-- 服务器时间
	@ref					char(24),			-- 费用描述
	@descript1			char(8),				-- 包价说明
	@descript2			char(16),			-- 扩展描述
	@crradjt				char(2),				-- 账务标志
	@roomno				char(5), 			-- 房号
	@to_roomno			char(5),  			-- 转账目标的房号(自动转账roomno记录原始房号)
	@groupno				char(10), 
	@lastnumb			integer,
	@lastinumb			integer, 
	@balance				money, 
	@detail_number		integer, 
	@pnumber				integer, 			-- 上一笔的pnumber
	@charge				money, 
	@credit				money, 
	@catalog				char(3), 
	@package_d			money, 
	@package_c			money, 
	@package_a			money, 
	@type					char(8),				-- 类型说明
	@rm_code				char(3),				-- 房价码(由master的setnumb转换为3位字符串)
	@option				char(2),
	-- 信用卡付款专用
	@arlastnumb			integer,
	@arlastinumb		integer, 
	@arbalance			money, 
	--
	@to_subaccnt		integer,
	@tor_str				varchar(40), 
	@traned				char(1), 
	@deptno1				char(8), 			-- %05*%
	@pccodes				char(7), 			-- %004%
	@deptno2				char(5),
	@value1				money, 
	@value0				money,
	@mode1				char(10),
	@waiter				char(3),
	@hotelid				varchar(20),		-- 成员酒店号
	@vipcard				char(20), 
	@vipnumber			integer, 
	@vipbalance			money, 
	@tor					char(1), 
	@artag				char(1), 
	@artag1				char(1),
	@artag1s				char(40),
	@araudit				char(1), 
	@arsubtotal			char(1), 
	@arcreditcard		char(1),
	@araccnt				char(10), 
	@arname				varchar(50), 
	@guestname			varchar(50), 
	@guestname2			varchar(50), 
	@modu_ids			varchar(255)

--
select @selemark = @selemark + space(40), @pnumber = 0, @araccnt = '', @roomno = '', @groupno = '', @guestname = substring(@msg, 1, 50), @guestname2 = substring(@msg, 51, 50)
select @mode1 = substring(@selemark, 2, 10), @waiter = substring(@selemark, 12, 3), @selemark = substring(@selemark, 15, 20)
if @operation like 'P%'
	begin
	if @modu_id != '02'
		select @guestname = descript, @guestname2 = descript1 from pccode where pccode = @pccode
	select @artag = 'P', @operation = 'I' + substring(@operation, 2, 4)
	select @artag1 = artag1 from ar_master where accnt = @accnt

-- 这个判断取消，必须审核 2007.9.18 simon  
--	select @artag1s = isnull((select value from sysoption where catalog = 'ar' and item = 'artag1_of_need_transfer'), '')
	if exists (select 1 from bankcard where accnt = @accnt)
		select @araudit = '2'
--	else if charindex(@artag1, @artag1s) > 0
--		select @araudit = '0'
	else
--		select @araudit = '1'
		select @araudit = '0'
	end
else
	select @artag = 'A', @araudit = '1'
if @a_number > 0
	select @arsubtotal = 'F'
else
	select @arsubtotal = 'F'
--
select @ret = 0, @msg = '', @to_accnt = '', @traned = 'F', @log_date = getdate(), @package_d = 0, @package_c = 0, @package_a = 0
if @argcode like '9%'
	select @charge = 0, @credit = round(@amount, 2)
else
	begin
	select @charge = round(@amount, 2), @credit = 0
	if @amount1 = 0 and @amount2 = 0 and @amount3 = 0 and @amount4 = 0 and @amount5 = 0
		select @amount1 = @charge
	end
select @bdate = bdate1 from sysdata
-- 检查限额
exec @ret = p_gl_ar_check_limit @accnt, @charge, @credit, @msg out
if @ret = 1
	goto RETURN_1
-- 检查费用码（付款码）是否存在
select @deptno1 = deptno1, @deptno2 = deptno2, @ref = descript, @argcode = isnull(rtrim(@argcode), argcode) from pccode where pccode = @pccode
if @ref is null
	begin
	select @ret = 1, @msg = '系统中还未设费用码' + @pccode + ', 按 F1 有现有费用码输入帮助'
	goto RETURN_1
	end 
-- 转前台、转AR账不能作为AR账的付款方式
if @deptno2 in ('PTS', 'TOA', 'TOR')
	begin
	select @ret = 1, @msg = '不能使用当前付款方式，请用转账功能'
	goto RETURN_1
	end
-- 检查优惠理由是否存在
if not rtrim(@reason) is null and not exists (select code from reason where code = @reason)
	begin
	select @ret = 1, @msg = '系统中还未设优惠理由' + @reason + ', 按 F1 有现有优惠理由输入帮助'
	goto RETURN_1
	end 

-- 用信用卡付款时，自动转到相应的应收账户
select @arcreditcard = isnull((select value from sysoption where catalog = 'ar' and item = 'creditcard'), 'F')
if @arcreditcard = 'T' and exists (select 1 from bankcard where pccode = @pccode)
	begin
	select @araccnt = accnt from bankcard where pccode = @pccode and bankcode = @waiter
	if not exists (select 1 from ar_master where accnt = @accnt and sta = 'I')
		begin
		select @ret = 1, @msg = '本付款方式的应收账户没有设置, 不能使用'
		goto RETURN_2
		end 
	end

--
select @pccodes = '%' + rtrim(@pccode) + '%'
select @deptno1 = '%' + rtrim(@deptno1) + '*%'
-- 检查是否允许记账
select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#03#05#15#')
if charindex(@modu_id, @modu_ids) = 0
	begin
	if not exists(select 1 from subaccnt where type = '0' and accnt = @accnt
		and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
		and @log_date >= starting_time and @log_date <= closing_time)
		begin
		select @ret = 1, @msg = '本账户不允许记账,只能现金结算'
		goto RETURN_1
		end 
	end
--
if @a_number > 0
	begin
	select @crradjt = 'AD', @option = 'NY'
	if not exists (select 1 from ar_detail where accnt = @accnt and number = @a_number)
		select @ret = 1, @msg = '要调整的账目不存在'
	end
else
	select @crradjt = '', @option = 'YY'
--
RETURN_1:
if @ret ! = 0
	begin
	if @operation like '_S%'
		select @ret, @msg, 0, 0, @to_accnt
	return @ret
	end
--
begin tran
save tran posting_1
-- 锁住当前账号
update ar_master set sta = sta where accnt = @accnt
select @mode = substring(@mode + space(10), 1, 9) + substring(extra, 2, 1) from ar_master where accnt = @accnt
exec @ret = p_gl_ar_update_balance @accnt, @charge, @credit, @lastnumb out, @lastinumb out, @balance out, @option, @msg out
if @ret = 0 
	begin
	if @a_number > 0
		select @detail_number = @a_number
	else
		select @detail_number = @lastnumb
	insert ar_account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
		quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
		crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof, subaccntof,
		ar_accnt, ar_subaccnt, ar_number, ar_inumber, ar_tag, ar_subtotal)
		values(@accnt, @subaccnt, @lastinumb, @lastinumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
		@quantity, @charge, @amount1, @amount2, @amount3, @amount4, @amount5, @package_d, @package_c, @package_a, @credit, @balance, @shift, @empno,
		@crradjt, @waiter, @catalog, @reason, @ref, @ref1, @ref2, @roomno, @groupno, @mode, @mode1, @pnumber, @araccnt, 1,
		@accnt, @subaccnt, @lastinumb, @detail_number, @artag, @arsubtotal)
	if @@rowcount = 0
		select @ret = 1, @msg = 'AR账务表插入失败'
	else
		begin
		select @ret = 0, @msg = '成功'
		if @a_number > 0
			update ar_detail set charge0 = charge0 + @charge, credit0 = credit0 + @credit
				where accnt = @accnt and number = @a_number
		else if @artag = 'A'
			insert ar_detail(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, accntof, subaccntof,
				quantity, charge0, credit0, balance, shift, empno, crradjt, tag, reason, guestname, guestname2, ref, ref1, ref2, mode1, audit)
				values(@accnt, @subaccnt, @lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, @araccnt, 1,
				@quantity, @charge, @credit, @balance, @shift, @empno, @crradjt, @artag, @reason, @guestname, @guestname2, @ref, @ref1, @ref2, @mode1, @araudit)
		else
			insert ar_detail(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, accntof, subaccntof,
				quantity, charge, credit, balance, shift, empno, crradjt, tag, reason, guestname, guestname2, ref, ref1, ref2, mode1, audit)
				values(@accnt, @subaccnt, @lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, @araccnt, 1,
				@quantity, @charge, @credit, @balance, @shift, @empno, @crradjt, @artag, @reason, @guestname, @guestname2, @ref, @ref1, @ref2, @mode1, @araudit)
		--
		if @charge != 0
			begin
			update ar_master set chargeby = @empno, chargetime = @log_date where accnt = @accnt
			insert lgfl select 'archarge',@accnt,'',ltrim(convert(char(20),@charge)),@empno,@log_date,''
			end
		if @credit != 0
			begin
			update ar_master set creditby = @empno, credittime = @log_date where accnt = @accnt
			insert lgfl select 'arcredit',@accnt,'',ltrim(convert(char(20),@credit)),@empno,@log_date,''
			end
		if @arcreditcard = 'T' and exists (select 1 from bankcard where pccode = @pccode)
			begin
			select @charge = @credit, @credit = 0, @araudit = '2'
			exec @ret = p_gl_ar_update_balance @araccnt, @charge, @credit, @arlastnumb out, @arlastinumb out, @arbalance out, 'YY', @msg out
			if @ret = 0 
				begin
				insert ar_account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
					quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
					crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof, subaccntof,
					ar_accnt, ar_subaccnt, ar_number, ar_inumber, ar_tag, ar_subtotal)
					values(@araccnt, @subaccnt, @arlastinumb, @arlastinumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
					@quantity, @charge, @amount1, @amount2, @amount3, @amount4, @amount5, @package_d, @package_c, @package_a, @credit, @arbalance, @shift, @empno,
					@crradjt, @waiter, @catalog, @reason, @ref, @ref1, @ref2, @roomno, @groupno, @mode, @mode1, @pnumber, @accnt, @subaccnt,
					@araccnt, 1, @arlastinumb, @arlastnumb, 'P', 'F')
				if @@rowcount = 0
					select @ret = 1, @msg = 'AR账务表插入失败'
				else
					begin
					select @ret = 0, @msg = '成功'
					insert ar_detail(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, accntof, subaccntof,
						quantity, charge, credit, balance, shift, empno, crradjt, tag, reason, guestname, guestname2, ref, ref1, ref2, mode1, audit)
						values(@araccnt, 1, @arlastnumb, @arlastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, @accnt, @subaccnt,
						@quantity, @charge, @credit, @arbalance, @shift, @empno, @crradjt, 'P', @reason, @guestname, @guestname2, @ref, @ref1, @ref2, @mode1, @araudit)
					end
				end
			end
		end
	end
--
RETURN_2:
if @ret ! = 0
	rollback tran posting_1
else
	select @msg = isnull(@to_accnt, @accnt) + convert(char(10), @lastnumb)
commit tran
if @operation like '_S%'
	select @ret, @msg, @lastnumb, @balance, isnull(@to_accnt, @accnt)
return @ret
;
