
if exists(select * from sysobjects where name = 'p_gl_accnt_posting' and type ='P')
	drop proc p_gl_accnt_posting;

create proc p_gl_accnt_posting			-- �������ȷ����NULL, ��������
	@selemark			char(27) = 'A',	-- A + mode1(10) + waiter(3) + accntof,ARACCNT(10)
													-- A + mode1(10) + waiter(3) + pccode(5)
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
	@operation			char(5), 			-- ��һλ��'A'����, 'I'����
													--	�ڶ�λ��'S' select, 'R' return
													--	����λ���Ƿ�ʹ��Package��'Y' YES, 'N' NO
													--	����λ���Ƿ�ʹ���Զ�ת�ˡ�'Y' YES, 'N' NO
													--	����λ����ʱδ��
	@a_number			integer, 			-- �������˴�
	@to_accnt			char(10) output, 
	@msg					varchar(60) output
as
-- �������봦��
declare
	@ret					integer, 
	@lic_buy_1			varchar(255),
	@lic_buy_2			varchar(255),
	@bdate				datetime,			-- Ӫҵ����
	@log_date			datetime,			-- ������ʱ��
	@column				integer,				-- account����
	@ref					char(24),			-- ��������
	@descript1			char(8),				-- ����˵��
	@descript2			char(16),			-- ��չ����
	@crradjt				char(2),				-- �����־
	@roomno				char(5), 			-- ����
	@to_roomno			char(5),  			-- ת��Ŀ��ķ���(�Զ�ת��roomno��¼ԭʼ����)
	@groupno				char(10), 
	@lastnumb			integer,
	@lastinumb			integer, 
	@lastpnumb			integer, 
	@pnumber				integer, 			-- ��һ�ʵ�pnumber
	@charge				money, 
	@credit				money, 
	@balance				money, 
	@catalog				char(3), 
--	@locksta				char(1),
	@package_d			money, 
	@package_c			money, 
	@package_a			money, 
	@type					char(8),				-- ����˵��
	@rm_code				char(3),				-- ������(��master��setnumbת��Ϊ3λ�ַ���)

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
	@hotelid				varchar(20),		-- ��Ա�Ƶ��
	@arselemark			char(27),
	@arsubaccnt			integer, 
	@artag1				char(1),
	@artag1s				char(40),
	@araudit				char(1),
	@arcreditcard		char(1),
	@arlastnumb			integer,
	@arlastinumb		integer, 
	@arbalance			money, 
	@arref2				char(50),			-- ժҪ
	@vipcard				char(20), 
	@vipnumber			integer, 
	@vipbalance			money, 
	@transfer			char(1), 			-- ����̨�������Ƿ����ת�����˷��ķ���
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
-- ����Ϊ�����������
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

-- ����޶�
exec @ret = p_gl_accnt_check_limit @accnt, @charge, @credit, @msg out
if @ret = 1
	goto RETURN_1
-- �������루�����룩�Ƿ����
if @ref is null
	begin
	select @ret = 1, @msg = 'ϵͳ�л�δ�������%1, �� F1 �����з������������^' + @pccode
	goto RETURN_1
	end 
-- תǰ̨������Ϊ��̨�ĸ��ʽ��@tor_str != ''ʱ��תAR�˲�����Ϊ��̨�ĸ��ʽ
-- select @tor_str = isnull((select value from sysoption where catalog = 'audit' and item = 'deptno_of_tor'), '')
if @deptno2 like '%TOA%' or (@deptno2 like '%TOR%' and not (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0))
	begin
	select @ret = 1, @msg = '����ʹ�õ�ǰ���ʽ������ת�˹���'
	goto RETURN_1
	end
--
--pccode��argcode�ж�һ��
if @ck_operation = 'CHECKOUT' or @ck_operation = 'SELECTED'
  if not exists(select 1 from pccode where pccode=@pccode and argcode>'9')
		begin
		select @ret = 1, @msg = '����������(argcode)'
	goto RETURN_1
	end

if exists (select 1 from bankcard where pccode = @pccode) and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
	-- �����ÿ�����ʱ���Զ�ת����Ӧ��Ӧ���˻�
	begin
	select @arcreditcard = isnull((select value from sysoption where catalog = 'ar' and item = 'creditcard'), 'F')
	if @arcreditcard = 'T'
		begin
		select @araccnt = accnt from bankcard where pccode = @pccode and bankcode = @waiter
		if not exists (select 1 from ar_master where accnt = @araccnt and sta = 'I')
			begin
			select @ret = 1, @msg = '�����ʽ��Ӧ���˻�û������, ����ʹ��'
			goto RETURN_1
			end 
		select @araudit = '2', @arref2 = @ref2, @tor = 'T'
		select @guestname = b.name, @guestname2 = b.name2 from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
		select @artag1 = a.artag1, @arname = b.name from ar_master a, guest b where a.accnt = @araccnt and a.haccnt = b.no
		select @arsubaccnt = subaccnt from subaccnt where accnt = @araccnt and haccnt = @mode
		end
	end
else if not rtrim(@selemark) is null and @deptno2 like '%TOR%'
	-- תAR�������ʽʱ��ȡ����������AR�ʻ������໥����ע
	begin
	select @araccnt = @selemark, @arref2 = @ref2, @tor = 'T'
	select @guestname = b.name, @guestname2 = b.name2 from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
	select @artag1 = a.artag1, @arname = b.name from ar_master a, guest b where a.accnt = @araccnt and a.haccnt = b.no

	-- ����Ƿ�������� 2006.9.19 
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
			select @ret = 1, @msg = '���������,ֻ���ֽ����(CHECKOUT)'
			goto RETURN_1
			end
		if @s_number <> (select count(1) from account_temp where pc_id = @pc_id and mdi_id = @mdi_id)
			begin
			select @ret = 1, @msg = '�в��������������,ֻ���ֽ����(CHECKOUT)'
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
			select @ret = 1, @msg = '���������,ֻ���ֽ����(SELECTED)'
			goto RETURN_1
			end
		if @s_number <> (select count(1) from account_temp where pc_id = @pc_id and mdi_id = @mdi_id and selected = 1)
			begin
			select @ret = 1, @msg = '�в��������������,ֻ���ֽ����(SELECTED)'
			goto RETURN_1
			end
		end
	--if not exists(select 1 from subaccnt where type = '0' and accnt = @araccnt 
	--	and (pccodes = '*' or pccodes like @mdeptno1 or pccodes like @mpccodes)
	--	and @log_date >= starting_time and @log_date <= closing_time)
	--	begin
	--	select @ret = 1, @msg = '���������,ֻ���ֽ����'
	--	goto RETURN_1
	--	end 

	-- 
	select @contact = name from guest where no = @mode
	select @arsubaccnt = subaccnt from subaccnt where accnt = @araccnt and haccnt = @mode
	select @ref2 = isnull(rtrim(@arname), '') + '/' + isnull(rtrim(@contact), '') + '/' + @ref2
	-- ����ж�ȡ����������� 2007.9.18 simon 
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
-- ����Ż������Ƿ����
if not rtrim(@reason) is null and not exists (select code from reason where code = @reason)
	begin
	select @ret = 1, @msg = 'ϵͳ�л�δ���Ż�����%1, �� F1 �������Ż������������^' + @reason
	goto RETURN_1
	end 

-- AR ������Ȩ���  
if @argcode >= '9' and @accnt not like 'A%' and @deptno2 like '%TOR%'
begin
	declare @authar				char(1)
	select @authar = isnull((select value from sysoption where catalog='ar' and item='auth_req_fo'), 'F')
	if @authar = 'T' 
	begin
		if not exists(select 1 from master where accnt=@accnt and substring(extra,13,1)='1') 
		begin
		select @ret = 1, @msg = 'û����Ȩ�����ܼ���'
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
-- ��ס��ǰ�˺�
update master set sta = sta where accnt = @accnt
select @roomno = roomno, @sta = sta, @mode = substring(@mode + space(10), 1, 9) + substring(extra, 2, 1)
	from master where accnt = @accnt
-- ����̨�������Ƿ����ת�����˷��ķ���
select @transfer = isnull((select value from sysoption where catalog = 'account' and item = 'transfer_to_checkout'), 'F')
if @sta = 'O' and @modu_id <> '02' and @transfer = 'F'
	begin
	select @ret = 1, @msg = '�˺�[%1]�Ѿ�����^' + @accnt
	goto RETURN_2
	end
if @operation like 'I_Y%' and not @argcode >= '9'
	exec @ret = p_gl_accnt_posting_package @pc_id, @mdi_id, @modu_id, @shift, @empno, @accnt, @pccode out, @charge out, @package_d out, @package_c out, @package_a out, @bdate, @log_date, @ref1, @ref2, @date, @msg out
if @ret != 0
	goto RETURN_2
-- ����Ƿ��������
select @modu_ids = isnull((select value from sysoption where catalog = 'audit' and item = 'modu_id'), '02#03#05#15#')
if charindex(@modu_id, @modu_ids) = 0 and @charge != 0
	begin
	if not exists(select 1 from subaccnt where type = '0' and accnt = @accnt
		and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
		and @log_date >= starting_time and @log_date <= closing_time)
		begin
--		select @ret = 1, @msg = '�˺�[' + @accnt + ']����' + ltrim(convert(char(10), @charge)) + 'Ԫ���������,ֻ���ֽ����'
		select @ret = 1, @msg = '���ʻ����������,ֻ���ֽ����'
		goto RETURN_2
		end 
	end
-- ��ʹȫ������Package֧��, ����Ҫ��Account�м�һ�ʽ��Ϊ�����ϸ
-- û��ָ���˻�����, ��Ҫ����subaccnt�����˻����
if not exists (select name from subaccnt where type = '5' and accnt = @accnt and subaccnt = @subaccnt)
	select @subaccnt = isnull((select max(subaccnt) from subaccnt where type = '5' and accnt = @accnt
		and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
		and @log_date >= starting_time and @log_date <= closing_time), 1)
select @to_accnt = to_accnt from subaccnt where type = '5' and accnt = @accnt and subaccnt = @subaccnt
-- ֻ��������òŴ����Զ�ת�ˣ����ǵ������ò�����������̣����Զ�ת�ˣ����帶�ѣ����ڱ����˻���˳�����
-- �Զ�ת�ˡ����帶��
-- �Զ�ת�˵�AR�˲�ִ��(�ֲ������ѣ��绰�ѡ�VOD���Զ����˵�©��) 2004/01/02
-- if @operation like 'I__Y%' and not rtrim(@to_accnt) is null and not (@to_accnt like 'A%' and @tor_str != '')
if @operation like 'I__Y%' and not rtrim(@to_accnt) is null and not @to_accnt like 'A%'
	begin
	begin tran
	save tran posting_2
	exec @ret = p_gl_accnt_update_balance @to_accnt, @pccode, @charge, @credit, @to_roomno out, 
		@groupno out, @lastnumb out, 0, @balance out, @catalog out, @msg out 
	-- ת���˺����˲��ɹ�
	select @status = isnull((select value from sysoption where catalog = 'account' and item = 'auto_transfer_status'), 'IR')
	if @ret != 0 or charindex(@msg, @status) = 0
		begin
		rollback tran posting_2
		commit tran
		end
	else
		begin
		-- ����@to_subaccnt
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
-- ���û���Զ�ת�ˡ����帶�ѻ򲻳ɹ�
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
			-- ����ת����Ŀ
		--	if exists(select 1 from pccode a ,account b,account_temp c where b.accnt = c.accnt and b.number=c.number and c.selected = 1
		--			and a.pccode = b.pccode and b.accnt = @accnt and a.argcode = '98')
		--		select @ret = 1, @msg = '����ܽ�ת��AR��'
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
				select @ret = 1, @msg = '��������ʧ��'
			else
				begin
				select @ret = 0, @msg = '�ɹ�'
				update package_detail set account_accnt = @accnt, account_number = @lastnumb, account_date = @log_date
					where posted_accnt = @accnt and account_accnt = ''
				-- ��TOR����, ar_account�е�number����Ӧ��armast.lastnumb, inumber��account.number
				--            ar_detail�е�number, inumber�����Ӧ��armast.lastnumb, account.number
				if @tor = 'T'
					begin
						update ar_master set sta = sta where accnt = @araccnt
						-- ����޶�
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
									select @ret = 1, @msg = 'AR��������ʧ��'
								else
									begin
									select @ret = 0, @msg = '�ɹ�'
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
-- ʹ�ù�������ָ���
if @ret = 0 and @deptno2 = 'PTS'
	begin
	select @cardno = @vipcard
	select @cardtype = isnull((select b.guestcard from vipcard a, vipcard_type b where a.no = @cardno and a.type = b.code), '')
	select @gref = rtrim(descript1) + '[' + rtrim(descript) + ']' from basecode where cat = 'moduno' and code = @modu_id
	if @@rowcount = 0	select @gref = 'Front Office'
	select @gref1 = @accnt, @gref2 = 'Card=' + rtrim(@cardtype) + '-' + rtrim(@cardno) + ';'
	if @amount <> 0  -- �һ�����
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
