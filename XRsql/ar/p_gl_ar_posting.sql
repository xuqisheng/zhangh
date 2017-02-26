
if exists(select * from sysobjects where name = 'p_gl_ar_posting' and type ='P')
	drop proc p_gl_ar_posting;

create proc p_gl_ar_posting				-- �������ȷ����NULL, ��������
	@selemark			char(27) = 'A',	-- A + mode1(10) + waiter(3)
	@modu_id				char(2), 
	@pc_id				char(4), 
	@mdi_id				integer, 
	@shift				char(1), 
	@empno				char(10), 
	@accnt				char(10), 
	@subaccnt			integer, 
	@pccode				char(5),				-- ������
	@argcode				char(3),				-- �ı���(��ӡ���˵��Ĵ���)
	@quantity			money,				-- ����
	@amount				money, 				-- ���
	@amount1				money, 
	@amount2				money, 
	@amount3				money, 
	@amount4				money, 
	@amount5				money, 
	@ref1					char(10),			-- ����
	@ref2					char(50),			-- ժҪ
	@date					datetime, 
	@reason				char(3),				-- �Ż�����
	@mode					char(10), 			-- 
	@operation			char(5), 			-- ��һλ��'A'����, 'I'����, 'P'ת��
													--	�ڶ�λ��'S' select, 'R' return
													--	����λ���Ƿ�ʹ��Package��'Y' YES, 'N' NO
													--	����λ���Ƿ�ʹ���Զ�ת�ˡ�'Y' YES, 'N' NO
													--	����λ����ʱδ��
	@a_number			integer, 			-- �������˴�
	@to_accnt			char(10) output, 
	@msg					char(100) output	-- ��������
as
-- �������봦��

declare
	@ret					integer, 
	@bdate				datetime,			-- Ӫҵ����
	@log_date			datetime,			-- ������ʱ��
	@ref					char(24),			-- ��������
	@descript1			char(8),				-- ����˵��
	@descript2			char(16),			-- ��չ����
	@crradjt				char(2),				-- �����־
	@roomno				char(5), 			-- ����
	@to_roomno			char(5),  			-- ת��Ŀ��ķ���(�Զ�ת��roomno��¼ԭʼ����)
	@groupno				char(10), 
	@lastnumb			integer,
	@lastinumb			integer, 
	@balance				money, 
	@detail_number		integer, 
	@pnumber				integer, 			-- ��һ�ʵ�pnumber
	@charge				money, 
	@credit				money, 
	@catalog				char(3), 
	@package_d			money, 
	@package_c			money, 
	@package_a			money, 
	@type					char(8),				-- ����˵��
	@rm_code				char(3),				-- ������(��master��setnumbת��Ϊ3λ�ַ���)
	@option				char(2),
	-- ���ÿ�����ר��
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
	@hotelid				varchar(20),		-- ��Ա�Ƶ��
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

-- ����ж�ȡ����������� 2007.9.18 simon  
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
-- ����޶�
exec @ret = p_gl_ar_check_limit @accnt, @charge, @credit, @msg out
if @ret = 1
	goto RETURN_1
-- �������루�����룩�Ƿ����
select @deptno1 = deptno1, @deptno2 = deptno2, @ref = descript, @argcode = isnull(rtrim(@argcode), argcode) from pccode where pccode = @pccode
if @ref is null
	begin
	select @ret = 1, @msg = 'ϵͳ�л�δ�������' + @pccode + ', �� F1 �����з������������'
	goto RETURN_1
	end 
-- תǰ̨��תAR�˲�����ΪAR�˵ĸ��ʽ
if @deptno2 in ('PTS', 'TOA', 'TOR')
	begin
	select @ret = 1, @msg = '����ʹ�õ�ǰ���ʽ������ת�˹���'
	goto RETURN_1
	end
-- ����Ż������Ƿ����
if not rtrim(@reason) is null and not exists (select code from reason where code = @reason)
	begin
	select @ret = 1, @msg = 'ϵͳ�л�δ���Ż�����' + @reason + ', �� F1 �������Ż������������'
	goto RETURN_1
	end 

-- �����ÿ�����ʱ���Զ�ת����Ӧ��Ӧ���˻�
select @arcreditcard = isnull((select value from sysoption where catalog = 'ar' and item = 'creditcard'), 'F')
if @arcreditcard = 'T' and exists (select 1 from bankcard where pccode = @pccode)
	begin
	select @araccnt = accnt from bankcard where pccode = @pccode and bankcode = @waiter
	if not exists (select 1 from ar_master where accnt = @accnt and sta = 'I')
		begin
		select @ret = 1, @msg = '�����ʽ��Ӧ���˻�û������, ����ʹ��'
		goto RETURN_2
		end 
	end

--
select @pccodes = '%' + rtrim(@pccode) + '%'
select @deptno1 = '%' + rtrim(@deptno1) + '*%'
-- ����Ƿ��������
select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#03#05#15#')
if charindex(@modu_id, @modu_ids) = 0
	begin
	if not exists(select 1 from subaccnt where type = '0' and accnt = @accnt
		and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
		and @log_date >= starting_time and @log_date <= closing_time)
		begin
		select @ret = 1, @msg = '���˻����������,ֻ���ֽ����'
		goto RETURN_1
		end 
	end
--
if @a_number > 0
	begin
	select @crradjt = 'AD', @option = 'NY'
	if not exists (select 1 from ar_detail where accnt = @accnt and number = @a_number)
		select @ret = 1, @msg = 'Ҫ��������Ŀ������'
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
-- ��ס��ǰ�˺�
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
		select @ret = 1, @msg = 'AR��������ʧ��'
	else
		begin
		select @ret = 0, @msg = '�ɹ�'
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
					select @ret = 1, @msg = 'AR��������ʧ��'
				else
					begin
					select @ret = 0, @msg = '�ɹ�'
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
