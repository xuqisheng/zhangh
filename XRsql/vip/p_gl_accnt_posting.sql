/* 费用输入处理 */

if exists(select * from sysobjects where name = 'p_gl_accnt_posting' and type ='P')
	drop proc p_gl_accnt_posting;

create proc p_gl_accnt_posting			/* 输入参数确保非NULL, 包括逃账 */
	@selemark			char(27) = 'A',	/* A + mode1(10) + waiter(3) + accntof,ARACCNT(10)*/
	@modu_id				char(2), 
	@pc_id				char(4), 
	@mdi_id				integer, 
	@shift				char(1), 
	@empno				char(10), 
	@accnt				char(10), 
	@subaccnt			integer, 
	@pccode				char(5),				/* 费用码 */
	@argcode				char(3),				/* 改编码(打印在账单的代码) */
	@quantity			money,				/* 数量 */
	@amount				money, 				/* 金额 */
	@amount1				money, 
	@amount2				money, 
	@amount3				money, 
	@amount4				money, 
	@amount5				money, 
	@ref1					char(10),			/* 单号 */
	@ref2					char(50),			/* 摘要 */
	@date					datetime, 
	@reason				char(3),				/* 优惠理由 */
	@mode					char(10), 			/*  */
	@operation			char(5), 			/* 第一位：'A'调整, 'I'输入
														第二位：'S' select, 'R' return
														第三位：是否使用Package。'Y' YES, 'N' NO
														第四位：是否使用自动转账。'Y' YES, 'N' NO
														第五位：暂时未用 */
	@a_number			integer, 			/* 调整的账次 */
	@to_accnt			char(10) output, 
	@msg					varchar(60) output
as
declare
	@ret					integer, 
	@bdate				datetime,			/* 营业日期 */
	@log_date			datetime,			/* 服务器时间 */
	@ref					char(24),			/* 费用描述 */
	@descript1			char(8),				/* 包价说明 */
	@descript2			char(16),			/* 扩展描述 */
	@crradjt				char(2),				/* 账务标志 */
	@roomno				char(5), 			/* 房号 */
	@to_roomno			char(5),  			/* 转账目标的房号(自动转账roomno记录原始房号) */
	@groupno				char(10), 
	@lastnumb			integer,
	@lastinumb			integer, 
	@lastpnumb			integer, 
	@pnumber				integer, 			/* 上一笔的pnumber */
	@charge				money, 
	@credit				money, 
	@balance				money, 
	@catalog				char(3), 
//	@locksta				char(1),
	@package_d			money, 
	@package_c			money, 
	@package_a			money, 
	@type					char(8),				/* 类型说明 */
	@rm_code				char(3),				/* 房价码(由master的setnumb转换为3位字符串) */
	//
	@to_subaccnt		integer,
	@tor_str				varchar(40), 
	@traned				char(1), 
	@deptno1				char(8), 			/* %05*% */
	@pccodes				char(7), 			/* %004%*/
	@deptno2				char(5),
	@value1				money, 
	@value0				money,
	@mode1				char(10),
	@waiter				char(3),
	@hotelid				varchar(20),		/* 成员酒店号 */
	@vipcard				char(20), 
	@tor					char(1), 
	@araccnt				char(10), 
	@arname				varchar(50), 
	@guestname			varchar(50), 
	@modu_ids			varchar(255)

//delete selected_account where type = '3' and pc_id = @pc_id
select @selemark = @selemark + space(40), @pnumber = 0, @araccnt = ''
select @mode1 = substring(@selemark, 2, 10), @waiter = substring(@selemark, 12, 3), @selemark = substring(@selemark, 15, 20)
if @mode1 like 'P%'
	select @pnumber = convert(integer, substring(@mode1, 2, 9)), @mode1 = ''
select @ret = 0, @to_accnt = '', @traned = 'F', @log_date = getdate(), @package_d = 0, @package_c = 0, @package_a = 0
if @argcode like '9%'
	select @charge = 0, @credit = round(@amount, 2)
else
	begin
	select @charge = round(@amount, 2), @credit = 0
	if @amount1 = 0 and @amount2 = 0 and @amount3 = 0 and @amount4 = 0 and @amount5 = 0
		select @amount1 = @charge
	end
select @bdate = bdate1 from sysdata
if @operation like 'I%'
	select @crradjt = ''
else
	select @crradjt = 'AD'

// 检查限额
exec @ret = p_gl_accnt_check_limit @accnt, @charge, @credit, @msg out
if @ret = 1
	goto RETURN_1
// 检查费用码（付款码）是否存在
select @deptno1 = deptno1, @deptno2 = deptno2, @ref = descript, @argcode = isnull(rtrim(@argcode), argcode) from pccode where pccode = @pccode
if @ref is null
	begin
	select @ret = 1, @msg = '系统中还未设费用码' + @pccode + ', 按 F1 有现有费用码输入帮助'
	goto RETURN_1
	end 
// 转前台不能作为总台的付款方式；@tor_str != ''时，转AR账不能作为总台的付款方式
select @tor_str = isnull((select value from sysoption where catalog = 'audit' and item = 'deptno_of_tor'), '')
if @deptno2 = 'TOA' or (@deptno2 = 'TOR' and @tor_str != '')
	begin
	select @ret = 1, @msg = '不能使用当前付款方式，请用转账功能'
	goto RETURN_1
	end
// 转AR账做付款方式时，取客人姓名、AR帐户名称相互做备注
if not rtrim(@selemark) is null
	begin
	if @deptno2 = 'TOR'
		begin
		select @araccnt = @selemark, @tor = 'T'
		select @arname = b.name from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
		select @guestname = name from guest where no = @mode
		end
	else if @deptno2 = 'PTS'
		begin
		select @vipcard = @selemark, @tor = 'P'
//		select @arname = b.name from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
//		select @guestname = name from guest where no = @mode
		end
	end
// 检查优惠理由是否存在
if not rtrim(@reason) is null and not exists (select code from reason where code = @reason)
	begin
	select @ret = 1, @msg = '系统中还未设优惠理由' + @reason + ', 按 F1 有现有优惠理由输入帮助'
	goto RETURN_1
	end 
//
select @pccodes = '%' + @pccode + '%'
select @deptno1 = '%' + rtrim(@deptno1) + '*%'
// 检查是否允许记账
select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#03#05#15#')
if charindex(@modu_id, @modu_ids) = 0
	begin
	if not exists(select 1 from subaccnt where type = '0' and accnt = @accnt
		and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
		and @log_date >= starting_time and @log_date <= closing_time)
		begin
		select @ret = 1, @msg = '账号(' + @accnt + ')不允许记账,只能现金结算'
		goto RETURN_1
		end 
	end
//
RETURN_1:
if @ret ! = 0
	begin
	if @operation like '_S%'
		select @ret, @msg, 0, 0, @to_accnt
	return @ret
	end
//----------------------------------------- End -------------------------------------------//
begin tran
save tran posting_1
// 锁住当前账号
update master set sta = sta where accnt = @accnt
select @roomno = roomno from master where accnt = @accnt
if @operation like 'I_Y%' and not @argcode like '9%'
	exec @ret = p_gl_accnt_posting_package @pc_id, @mdi_id, @modu_id, @shift, @empno, @accnt, @pccode out, @charge out, @package_d out, @package_c out, @package_a out, @bdate, @log_date, @ref1, @ref2, @date, @msg out
if @ret != 0
	goto RETURN_2
/* 即使全部金额都由Package支付, 还是要在Account中记一笔金额为零的明细 */
/* 没有指定账户的账, 需要根据subaccnt生成账户编号 */
if not exists (select name from subaccnt where accnt = @accnt and subaccnt = @subaccnt)
	select @subaccnt = isnull((select max(subaccnt) from subaccnt where type = '5' and accnt = @accnt
		and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
		and @log_date >= starting_time and @log_date <= closing_time), 1)
select @to_accnt = to_accnt from subaccnt where type = '5' and accnt = @accnt and subaccnt = @subaccnt
/* 只有输入费用才存在自动转账;如是调整费用不进入下面过程;按自动转账, 团体付费, 记在本地账户的顺序记账 */
/* 自动转账、团体付费 */
/* 自动转账到AR账不执行(弥补过房费，电话费、VOD等自动入账的漏洞) 2004/01/02 */
if @operation like 'I__Y%' and not rtrim(@to_accnt) is null and not (@to_accnt like 'A%' and @tor_str != '')
	begin
	begin tran
	save tran posting_2
	exec @ret = p_gl_accnt_update_balance @to_accnt, @pccode, @charge, @credit, @to_roomno out, 
		@groupno out, @lastnumb out, 0, @balance out, @catalog out, @msg out 
	/* 转账账号入账不成功 */
	if @ret != 0
		begin
		rollback tran posting_2
		commit tran
		end
	else
		begin
		/* 生成@to_subaccnt */
		select @to_subaccnt = isnull((select max(subaccnt) from subaccnt where type = '5' and accnt = @to_accnt
			and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
			and @bdate >= starting_time and @bdate <= closing_time), 1)
		insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
			quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
			crradjt, waiter, tag, reason, tofrom, accntof, subaccntof, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber)
			values(@to_accnt, @to_subaccnt, @lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
			@quantity, @charge, @amount1, @amount2, @amount3, @amount4, @amount5, @package_d, @package_c, @package_a, @credit, @balance, @shift, @empno,
			@crradjt, @waiter, @catalog, @reason, '', @accnt, @subaccnt, @ref, @ref1, @ref2, @roomno, @groupno, @mode, @mode1, @pnumber)
//			@crradjt, @catalog, @reason, '', @accnt, @subaccnt, @ref, @ref1, @ref2, @to_roomno, @groupno, @mode, @mode1)
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
/* 如果没有自动转账、团体付费或不成功 */
if @traned = 'F'
	begin
	select @to_accnt = null
	exec @ret = p_gl_accnt_update_balance @accnt, @pccode, @charge, @credit, @roomno out, @groupno out, 
		@lastnumb out, 0, @balance out, @catalog out, @msg out
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
			// 转AR账记一笔总数
			if @tor = 'T'
				begin
				select @charge = @credit, @credit = 0, @pccode = '', @argcode='', 
					@ref = '客房费用', @ref2 = isnull(@arname, '') + '(' + isnull(@guestname, '') + ')'
				exec @ret = p_gl_accnt_update_balance @araccnt, @pccode, @charge, @credit, '', '', 
					@lastinumb out, 0, @balance out, @catalog out, @msg out
				insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
					quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
					crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof)
					values(@araccnt, @subaccnt, @lastinumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
					1, @charge, @amount1, @amount2, @amount3, @amount4, @amount5, @package_d, @package_c, @package_a, @credit, @balance, @shift, @empno,
					@crradjt, @waiter, @catalog, @reason, @ref, @ref1, @ref2, @roomno, @groupno, @mode, @mode1, @pnumber, @accnt)
				end
//			if exists (select 1 from selected_account where type = '2' and accnt = @to_accnt)
//				select @ret = 0, @msg = 'CHECKING;' + @to_accnt + ';' + @roomno + ';' + min(pc_id)
//					from selected_account where type = '2' and accnt = @to_accnt
//			else if exists (select 1 from selected_account where type = '2' and accnt = @accnt)
//				select @ret = 0, @msg = 'CHECKING;' + @accnt + ';' + @roomno + ';' + min(pc_id)
//					from selected_account where type = '2' and accnt = @accnt
			end
		end
	end

-- 使用贵宾卡积分付款
if @deptno2 = 'PTS'
	begin
	select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
 	exec @ret = p_gds_vipcard_posting '', @modu_id, @pc_id, @mdi_id, @shift, @empno, @vipcard, @hotelid, @bdate, '-', @amount, @amount, 0, 0, 0, @quantity, '', @accnt, '','','','R', @ret output, @msg output
	end
//
RETURN_2:
if @ret ! = 0
	rollback tran posting_1
commit tran
if @operation like '_S%'
	select @ret, @msg, @lastnumb, @balance, isnull(@to_accnt, @accnt)
return @ret
;
