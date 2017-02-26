
if exists(select * from sysobjects where name = 'p_gl_accnt_posting' and type ='P')
	drop proc p_gl_accnt_posting;

create proc p_gl_accnt_posting			-- 输入参数确保非NULL, 包括逃账
	@selemark			char(27) = 'A',	-- A + mode1(10) + waiter(3) + accntof,ARACCNT(10)
													-- A + mode1(10) + waiter(3) + pccode(5)
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
	@operation			char(5), 			-- 第一位：'A'调整, 'I'输入
													--	第二位：'S' select, 'R' return
													--	第三位：是否使用Package。'Y' YES, 'N' NO
													--	第四位：是否使用自动转账。'Y' YES, 'N' NO
													--	第五位：暂时未用
	@a_number			integer, 			-- 调整的账次
	@to_accnt			char(10) output, 
	@msg					varchar(60) output
as
-- 费用输入处理
declare
	@ret					integer, 
	@lic_buy_1			varchar(255),
	@lic_buy_2			varchar(255),
	@bdate				datetime,			-- 营业日期
	@log_date			datetime,			-- 服务器时间
	@column				integer,				-- account的列
	@ref					char(24),			-- 费用描述
	@descript1			char(8),				-- 包价说明
	@descript2			char(16),			-- 扩展描述
	@crradjt				char(2),				-- 账务标志
	@roomno				char(5), 			-- 房号
	@to_roomno			char(5),  			-- 转账目标的房号(自动转账roomno记录原始房号)
	@groupno				char(10), 
	@lastnumb			integer,
	@lastinumb			integer, 
	@lastpnumb			integer, 
	@pnumber				integer, 			-- 上一笔的pnumber
	@charge				money, 
	@credit				money, 
	@balance				money, 
	@catalog				char(3), 
--	@locksta				char(1),
	@package_d			money, 
	@package_c			money, 
	@package_a			money, 
	@type					char(8),				-- 类型说明
	@rm_code				char(3),				-- 房价码(由master的setnumb转换为3位字符串)

	@to_subaccnt		integer,
--	@tor_str				varchar(40), 
	@traned				char(1), 
	@deptno1				char(8), 			-- %05*%
	@pccodes				char(7), 			-- %004%
	@deptno2				char(5),
	@value1				money, 
	@value0				money,
	@mode1				char(10),
	@waiter				char(3),
	@hotelid				varchar(20),		-- 成员酒店号
	@arselemark			char(27),
	@arsubaccnt			integer, 
	@artag1				char(1),
	@artag1s				char(40),
	@araudit				char(1),
	@arcreditcard		char(1),
	@arlastnumb			integer,
	@arlastinumb		integer, 
	@arbalance			money, 
	@arref2				char(50),			-- 摘要
	@vipcard				char(20), 
	@vipnumber			integer, 
	@vipbalance			money, 
	@transfer			char(1), 			-- 非总台的账务是否可以转入已退房的房间
	@sta					char(1), 
	@tor					char(1), 
	@status				char(10), 
	@aroperation		char(5),
	@araccnt				char(10), 
	@arname				varchar(50), 
	@contact				varchar(50), 
	@guestname			varchar(50), 
	@guestname2			varchar(50), 
	@modu_ids			varchar(255),
-- 以下为贵宾卡付款用
	@gref					varchar(24),
	@gref1				varchar(10),
	@gref2				varchar(50),
	@cardtype			char(10),
	@cardno				char(20),
	@exchange			money,
	@ck_operation			char(10),	--add by zk 2008-7-31
	@s_number			int

select @ck_operation = @msg
--delete selected_account where type = '3' and pc_id = @pc_id
select @arselemark = @selemark + space(40), @pnumber = 0, @araccnt = ''
select @mode1 = substring(@arselemark, 2, 10), @waiter = substring(@arselemark, 12, 3), @selemark = substring(@arselemark, 15, 20)
if @mode1 like 'P%'
	select @pnumber = convert(integer, substring(@mode1, 2, 9)), @mode1 = ''
select @ret = 0, @to_accnt = '', @traned = 'F', @log_date = getdate(), @package_d = 0, @package_c = 0, @package_a = 0
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
--
select @deptno1 = deptno1, @deptno2 = deptno2, @column = commission, @ref = descript, @argcode = isnull(rtrim(@argcode), argcode)
	from pccode where pccode = @pccode
if @argcode >= '9'
	select @charge = 0, @credit = round(@amount, 2)
else
	begin
	select @charge = round(@amount, 2), @credit = 0
	if @amount1 = 0 and @amount2 = 0 and @amount3 = 0 and @amount4 = 0 and @amount5 = 0
		begin
		if @column = 3
			select @amount3 = @charge
		else if @column = 4
			select @amount4 = @charge
		else if @column = 5
			select @amount5 = @charge
		else
			select @amount1 = @charge
		end
	end
select @bdate = bdate1 from sysdata
if @operation like 'I%'
	select @crradjt = ''
else
	select @crradjt = 'AD'

-- 检查限额
exec @ret = p_gl_accnt_check_limit @accnt, @charge, @credit, @msg out
if @ret = 1
	goto RETURN_1
-- 检查费用码（付款码）是否存在
if @ref is null
	begin
	select @ret = 1, @msg = '系统中还未设费用码%1, 按 F1 有现有费用码输入帮助^' + @pccode
	goto RETURN_1
	end 
-- 转前台不能作为总台的付款方式；@tor_str != ''时，转AR账不能作为总台的付款方式
-- select @tor_str = isnull((select value from sysoption where catalog = 'audit' and item = 'deptno_of_tor'), '')
if @deptno2 like '%TOA%' or (@deptno2 like '%TOR%' and not (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0))
	begin
	select @ret = 1, @msg = '不能使用当前付款方式，请用转账功能'
	goto RETURN_1
	end
--
--pccode的argcode判断一下
if @ck_operation = 'CHECKOUT' or @ck_operation = 'SELECTED'
  if not exists(select 1 from pccode where pccode=@pccode and argcode>'9')
		begin
		select @ret = 1, @msg = '付款代码错误(argcode)'
	goto RETURN_1
	end

if exists (select 1 from bankcard where pccode = @pccode) and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
	-- 用信用卡付款时，自动转到相应的应收账户
	begin
	select @arcreditcard = isnull((select value from sysoption where catalog = 'ar' and item = 'creditcard'), 'F')
	if @arcreditcard = 'T'
		begin
		select @araccnt = accnt from bankcard where pccode = @pccode and bankcode = @waiter
		if not exists (select 1 from ar_master where accnt = @araccnt and sta = 'I')
			begin
			select @ret = 1, @msg = '本付款方式的应收账户没有设置, 不能使用'
			goto RETURN_1
			end 
		select @araudit = '2', @arref2 = @ref2, @tor = 'T'
		select @guestname = b.name, @guestname2 = b.name2 from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
		select @artag1 = a.artag1, @arname = b.name from ar_master a, guest b where a.accnt = @araccnt and a.haccnt = b.no
		select @arsubaccnt = subaccnt from subaccnt where accnt = @araccnt and haccnt = @mode
		end
	end
else if not rtrim(@selemark) is null and @deptno2 like '%TOR%'
	-- 转AR账做付款方式时，取客人姓名、AR帐户名称相互做备注
	begin
	select @araccnt = @selemark, @arref2 = @ref2, @tor = 'T'
	select @guestname = b.name, @guestname2 = b.name2 from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
	select @artag1 = a.artag1, @arname = b.name from ar_master a, guest b where a.accnt = @araccnt and a.haccnt = b.no

	-- 检查是否允许记账 2006.9.19 
	--modi by zk 2008-7-31
	declare @mpccode varchar(5), @mdeptno1 varchar(8), @mpccodes varchar(7)
	--select @mpccode = isnull((select value from sysoption where catalog='audit' and item='room_charge_pccode'), '1000') 
	--select @mdeptno1 = isnull((select deptno1 from pccode where pccode = @mpccode), '??') 
	--select @mpccodes = '%' + rtrim(@mpccode) + '%'
	--select @mdeptno1 = '%' + rtrim(@mdeptno1) + '*%'
	if @ck_operation = 'CHECKOUT'
		begin
		select @s_number = count(1) from subaccnt s,pccode p,account a,account_temp b where a.accnt = b.accnt and a.number = b.number
		and b.pc_id = @pc_id and b.mdi_id = @mdi_id and s.type = '0' and s.accnt = @araccnt and p.pccode = a.pccode
		and (s.pccodes = '*' or s.pccodes like '%'+rtrim(p.pccode)+'%' or s.pccodes like '%'+rtrim(p.deptno1)+'*%') 
		and @log_date >= starting_time and @log_date <= closing_time
		if @s_number = 0
			begin
			select @ret = 1, @msg = '不允许记账,只能现金结算(CHECKOUT)'
			goto RETURN_1
			end
		if @s_number <> (select count(1) from account_temp where pc_id = @pc_id and mdi_id = @mdi_id)
			begin
			select @ret = 1, @msg = '有部分账务不允许记账,只能现金结算(CHECKOUT)'
			goto RETURN_1
			end
		end
	else if @ck_operation = 'SELECTED'
		begin
		select @s_number = count(1) from subaccnt s,pccode p,account a,account_temp b where a.accnt = b.accnt and a.number = b.number
		and b.pc_id = @pc_id and b.mdi_id = @mdi_id and s.type = '0' and s.accnt = @araccnt and p.pccode = a.pccode
		and (s.pccodes = '*' or s.pccodes like '%'+rtrim(p.pccode)+'%' or s.pccodes like '%'+rtrim(p.deptno1)+'*%') 
		and @log_date >= starting_time and @log_date <= closing_time and b.selected = 1
		if @s_number = 0
			begin
			select @ret = 1, @msg = '不允许记账,只能现金结算(SELECTED)'
			goto RETURN_1
			end
		if @s_number <> (select count(1) from account_temp where pc_id = @pc_id and mdi_id = @mdi_id and selected = 1)
			begin
			select @ret = 1, @msg = '有部分账务不允许记账,只能现金结算(SELECTED)'
			goto RETURN_1
			end
		end
	--if not exists(select 1 from subaccnt where type = '0' and accnt = @araccnt 
	--	and (pccodes = '*' or pccodes like @mdeptno1 or pccodes like @mpccodes)
	--	and @log_date >= starting_time and @log_date <= closing_time)
	--	begin
	--	select @ret = 1, @msg = '不允许记账,只能现金结算'
	--	goto RETURN_1
	--	end 

	-- 
	select @contact = name from guest where no = @mode
	select @arsubaccnt = subaccnt from subaccnt where accnt = @araccnt and haccnt = @mode
	select @ref2 = isnull(rtrim(@arname), '') + '/' + isnull(rtrim(@contact), '') + '/' + @ref2
	-- 这个判断取消，必须审核 2007.9.18 simon 
--	select @artag1s = isnull((select value from sysoption where catalog = 'ar' and item = 'artag1_of_need_transfer'), '')
--	if charindex(@artag1, @artag1s) > 0
		select @araudit = '0'
--	else
--		select @araudit = '1'
	end
else if not rtrim(@selemark) is null and @deptno2 = 'PTS'
	begin
	select @vipcard = @selemark, @tor = 'P'
--	select @arname = b.name from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
--	select @guestname = name from guest where no = @mode
	end
-- 检查优惠理由是否存在
if not rtrim(@reason) is null and not exists (select code from reason where code = @reason)
	begin
	select @ret = 1, @msg = '系统中还未设优惠理由%1, 按 F1 有现有优惠理由输入帮助^' + @reason
	goto RETURN_1
	end 

-- AR 记账授权检查  
if @argcode >= '9' and @accnt not like 'A%' and @deptno2 like '%TOR%'
begin
	declare @authar				char(1)
	select @authar = isnull((select value from sysoption where catalog='ar' and item='auth_req_fo'), 'F')
	if @authar = 'T' 
	begin
		if not exists(select 1 from master where accnt=@accnt and substring(extra,13,1)='1') 
		begin
		select @ret = 1, @msg = '没有授权，不能记账'
		goto RETURN_1
		end 
	end
end

--
select @pccodes = '%' + rtrim(@pccode) + '%'
select @deptno1 = '%' + rtrim(@deptno1) + '*%'
--
RETURN_1:
if @ret ! = 0
	begin
	if @operation like '_S%'
		select @ret, @msg, 0, 0, @to_accnt
	return @ret
	end
------------------------------------------- End ---------------------------------------------
begin tran
save tran posting_1
-- 锁住当前账号
update master set sta = sta where accnt = @accnt
select @roomno = roomno, @sta = sta, @mode = substring(@mode + space(10), 1, 9) + substring(extra, 2, 1)
	from master where accnt = @accnt
-- 非总台的账务是否可以转入已退房的房间
select @transfer = isnull((select value from sysoption where catalog = 'account' and item = 'transfer_to_checkout'), 'F')
if @sta = 'O' and @modu_id <> '02' and @transfer = 'F'
	begin
	select @ret = 1, @msg = '账号[%1]已经结帐^' + @accnt
	goto RETURN_2
	end
if @operation like 'I_Y%' and not @argcode >= '9'
	exec @ret = p_gl_accnt_posting_package @pc_id, @mdi_id, @modu_id, @shift, @empno, @accnt, @pccode out, @charge out, @package_d out, @package_c out, @package_a out, @bdate, @log_date, @ref1, @ref2, @date, @msg out
if @ret != 0
	goto RETURN_2
-- 检查是否允许记账
select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#03#05#15#')
if charindex(@modu_id, @modu_ids) = 0 and @charge != 0
	begin
	if not exists(select 1 from subaccnt where type = '0' and accnt = @accnt
		and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
		and @log_date >= starting_time and @log_date <= closing_time)
		begin
--		select @ret = 1, @msg = '账号[' + @accnt + ']还有' + ltrim(convert(char(10), @charge)) + '元不允许记账,只能现金结算'
		select @ret = 1, @msg = '该帐户不允许记账,只能现金结算'
		goto RETURN_2
		end 
	end
-- 即使全部金额都由Package支付, 还是要在Account中记一笔金额为零的明细
-- 没有指定账户的账, 需要根据subaccnt生成账户编号
if not exists (select name from subaccnt where type = '5' and accnt = @accnt and subaccnt = @subaccnt)
	select @subaccnt = isnull((select max(subaccnt) from subaccnt where type = '5' and accnt = @accnt
		and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
		and @log_date >= starting_time and @log_date <= closing_time), 1)
select @to_accnt = to_accnt from subaccnt where type = '5' and accnt = @accnt and subaccnt = @subaccnt
-- 只有输入费用才存在自动转账；如是调整费用不进入下面过程；按自动转账，团体付费，记在本地账户的顺序记账
-- 自动转账、团体付费
-- 自动转账到AR账不执行(弥补过房费，电话费、VOD等自动入账的漏洞) 2004/01/02
-- if @operation like 'I__Y%' and not rtrim(@to_accnt) is null and not (@to_accnt like 'A%' and @tor_str != '')
if @operation like 'I__Y%' and not rtrim(@to_accnt) is null and not @to_accnt like 'A%'
	begin
	begin tran
	save tran posting_2
	exec @ret = p_gl_accnt_update_balance @to_accnt, @pccode, @charge, @credit, @to_roomno out, 
		@groupno out, @lastnumb out, 0, @balance out, @catalog out, @msg out 
	-- 转账账号入账不成功
	select @status = isnull((select value from sysoption where catalog = 'account' and item = 'auto_transfer_status'), 'IR')
	if @ret != 0 or charindex(@msg, @status) = 0
		begin
		rollback tran posting_2
		commit tran
		end
	else
		begin
		-- 生成@to_subaccnt
		select @to_subaccnt = isnull((select max(subaccnt) from subaccnt where type = '5' and accnt = @to_accnt
			and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
			and @bdate >= starting_time and @bdate <= closing_time), 1)
		insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
			quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
			crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber)
			values(@to_accnt, @to_subaccnt, @lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
			@quantity, @charge, @amount1, @amount2, @amount3, @amount4, @amount5, @package_d, @package_c, @package_a, @credit, @balance, @shift, @empno,
			@crradjt, @waiter, @catalog, @reason, '', @accnt, @subaccnt, @ref, @ref1, @ref2, @roomno, @groupno, @mode, @mode1, @pnumber)
		if @@rowcount = 0
			begin
			rollback tran posting_2
			commit tran 
			end
	  else
			begin
			commit tran
			update package_detail set account_accnt = @to_accnt, account_number = @lastnumb, account_date = @log_date
				where posted_accnt = @accnt and account_accnt = ''
			select @traned = 'T'
			end
		end
	end
-- 如果没有自动转账、团体付费或不成功
if @traned = 'F'
	begin
	if @accnt like 'A%' and exists (select 1 from pccode where deptno2 like '%TOR%' and (deptno3 != '' or deptno6 != ''))
		begin
		select @aroperation = 'P' + substring(@operation, 2, 4)
		exec @ret = p_gl_ar_posting @arselemark, @modu_id, @pc_id, @mdi_id, @shift, @empno, @accnt, @subaccnt, @pccode, @argcode, @quantity, @amount, 
			@amount1, @amount2, @amount3, @amount4, @amount5, @ref1, @ref2, @date, @reason, @mode, @aroperation, 0, '', @msg out
		end
	else
		begin
		select @to_accnt = null
		exec @ret = p_gl_accnt_update_balance @accnt, @pccode, @charge, @credit, @roomno out, @groupno out, 
			@lastnumb out, 0, @balance out, @catalog out, @msg out
		--if @tor = 'T'
		--	begin
			-- 检查结转的项目
		--	if exists(select 1 from pccode a ,account b,account_temp c where b.accnt = c.accnt and b.number=c.number and c.selected = 1
		--			and a.pccode = b.pccode and b.accnt = @accnt and a.argcode = '98')
		--		select @ret = 1, @msg = '付款不能结转到AR账'
		--	end
		if @ret = 0 
			begin
			if @operation like 'A%'
				select @lastinumb = @a_number
			insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
				quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
				crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof)
				values(@accnt, @subaccnt, @lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
				@quantity, @charge, @amount1, @amount2, @amount3, @amount4, @amount5, @package_d, @package_c, @package_a, @credit, @balance, @shift, @empno,
				@crradjt, @waiter, @catalog, @reason, @ref, @ref1, @ref2, @roomno, @groupno, @mode, @mode1, @pnumber, @araccnt)
			if @@rowcount = 0
				select @ret = 1, @msg = '账务表插入失败'
			else
				begin
				select @ret = 0, @msg = '成功'
				update package_detail set account_accnt = @accnt, account_number = @lastnumb, account_date = @log_date
					where posted_accnt = @accnt and account_accnt = ''
				-- 用TOR付款, ar_account中的number记相应的armast.lastnumb, inumber记account.number
				--            ar_detail中的number, inumber则记相应的armast.lastnumb, account.number
				if @tor = 'T'
					begin
						update ar_master set sta = sta where accnt = @araccnt
						-- 检查限额
						exec @ret = p_gl_ar_check_limit @araccnt, @credit, 0, @msg out
						if @ret = 0
							begin
							exec @ret = p_gl_ar_update_balance @araccnt, @credit, 0, @arlastnumb out, @arlastinumb out, @arbalance out, 'YY', @msg out
							if @ret = 0 
								begin
								insert ar_account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
									quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
									crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof,
									ar_accnt, ar_subaccnt, ar_number, ar_inumber, ar_tag, charge9, credit9)
									select accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, '', argcode, 
									quantity, credit, credit, charge2, charge3, charge4, charge5, package_d, package_c, package_a, charge, balance, shift, empno,
									crradjt, waiter, tag, reason, ref, ref1, @arref2, roomno, groupno, mode, pccode, pnumber, accntof,
									@araccnt, isnull(@arsubaccnt, 1), @arlastinumb, @arlastnumb, 'P', 0, 0
									from account where accnt = @accnt and number = @lastnumb
								if @@rowcount = 0
									select @ret = 1, @msg = 'AR账务表插入失败'
								else
									begin
									select @ret = 0, @msg = '成功'
									insert ar_detail(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode,
										accntof, subaccntof, quantity, charge, credit, balance, shift, empno, crradjt, roomno, tag, reason,
										guestname, guestname2, ref, ref1, ref2, mode1, audit)
										select @araccnt, isnull(@arsubaccnt, 1), @arlastnumb, @lastnumb, @modu_id, @log_date, @bdate, @date, '', '',
										@accnt, @subaccnt, @quantity, @credit, @charge, @arbalance, @shift, @empno, @crradjt, @roomno, 'P', @reason,
										@guestname, @guestname2, @ref, @ref1, @arref2, @pccode, @araudit
									update ar_master set chargeby = @empno, chargetime = @log_date where accnt = @araccnt
									end
								end
							end
						end
--				if exists (select 1 from selected_account where type = '2' and accnt = @to_accnt)
--					select @ret = 0, @msg = 'CHECKING;' + @to_accnt + ';' + @roomno + ';' + min(pc_id)
--						from selected_account where type = '2' and accnt = @to_accnt
--				else if exists (select 1 from selected_account where type = '2' and accnt = @accnt)
--					select @ret = 0, @msg = 'CHECKING;' + @accnt + ';' + @roomno + ';' + min(pc_id)
--						from selected_account where type = '2' and accnt = @accnt
				end
			end
		end
	end
-- 使用贵宾卡积分付款
if @ret = 0 and @deptno2 = 'PTS'
	begin
	select @cardno = @vipcard
	select @cardtype = isnull((select b.guestcard from vipcard a, vipcard_type b where a.no = @cardno and a.type = b.code), '')
	select @gref = rtrim(descript1) + '[' + rtrim(descript) + ']' from basecode where cat = 'moduno' and code = @modu_id
	if @@rowcount = 0	select @gref = 'Front Office'
	select @gref1 = @accnt, @gref2 = 'Card=' + rtrim(@cardtype) + '-' + rtrim(@cardno) + ';'
	if @amount <> 0  -- 兑换比率
		select @exchange = round(@quantity / @amount, 2)
	else 
		select @exchange = 0
	if not exists(select 1 from vipcard_type where center='T' and guestcard=@cardtype)
      begin
		select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
		exec @ret = p_gds_vipcard_posting '', @modu_id, @pc_id, @mdi_id, @shift, @empno, @cardno, @hotelid, @bdate, '-', @amount, @amount, @exchange, 0, 0, @quantity, '', @accnt, @gref, @gref1, @gref2,'R', @ret output, @msg output
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
