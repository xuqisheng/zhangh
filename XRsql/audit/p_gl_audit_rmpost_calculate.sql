
if exists(select * from sysobjects where name = 'p_gl_audit_rmpost_calculate')
	drop proc p_gl_audit_rmpost_calculate;
create proc p_gl_audit_rmpost_calculate
	@rmpostdate					datetime,
	@accnt						char(10), 				-- �ʺ� 
	@w_or_h						integer, 				-- 1.ȫ��  2.���� 
	@rmrate						money out,				            
	@qtrate						money out,				            
	@setrate						money out,				            
	@charge1						money	out,				-- ���� 
	@charge2						money	out,				-- �Ż� 
	@charge3						money	out,				-- ����� 
	@charge4						money	out,				-- �ǽ��� 
	@charge5						money	out,				-- �Ӵ� 
	@operation					char(58) = 'FN',		-- �����㷿�۵ı�־
															--	��1λ��Ff���������㷿��(ȱʡֵ)�� Rr�����¼��㷿�ѣ� Сд����Select����ֵ�� 
															--	��2λ��N���˷���,D������
															--	��3-52λ��Packages
															--	��53-57λ��Gstno
															--	��58-58λ��Class
	@pc_id						char(4),					-- ������ļ������ַ 
	@mdi_id						integer					-- �������Mdi 
as
-------------------------------------------------------------------------------
-- ���Ѽ��� 
--
-- �������������
--	1. ���ڻ���(����)ʱ���㷿��, ������ @operation like 'F%'
--
--	2. ���ڽ���ʱ����ָ�����Żݱ������¼��㷿��, ������ @operation like 'R%'
--		substring(@operation, 3, 50) = @packages
--
--	3. ���ڵǼ�ʱ��ʾʵ�ʷ��Ѻ��Żݱ���, �������������ʺ�@accnt����λ@operation��@w_or_hΪ��
--		accnt���ʺ�, @w_or_h��0, @charge1������(����Ĳ�����@qtrate), @charge2���Ż�(����Ĳ�����@discount1), 
--		@charge3�������, @charge4���ǽ���, @charge5���Ӵ�(����Ĳ�����@setrate), 
-- 
-------------------------------------------------------------------------------
declare
	@class						char(1),
	@packages					varchar(50),		-- Master.Packages 
	@package						char(4),
	--
	@roomno						char(5),
	@gstno						integer,
	@children					integer,
	@addbed			   		money,				-- �Ӵ�����  
	@addbed_rate				money,				-- �Ӵ��� 
	@crib	   					money,				-- Ӥ�������� 
	@crib_rate					money,				-- Ӥ�����۸� 
	--
	@column						integer,
	@li_pos						integer,
	@rmdeptno1					char(5),
	@descript					char(30),
	@descript1					char(30),
	@deptno1						char(5),
	@pccode						char(5),
	@argcode						char(3),
	@amount						money,
	@quantity					money,
	@starting_days				integer,
	@closing_days				integer,
	@starting_package			char(8),
	@closing_package			char(8),
	@starting_fixed_charge	datetime,
	@closing_fixed_charge	datetime,
	@arr							datetime,
	@dep							datetime,
	@bdate						datetime,
	@week							integer,
	@pccodes						varchar(255),
	@pos_pccode					char(5),
	@credit						money,
	@number						integer,
	@rule_post					char(3),
	@rule_parm					char(30),
	@rule_calc					char(10),			-- ���㷽ʽѡ��
															--	��һλ��0.���ù���Package_Detail�У�1.���ù���Account��
															--	�ڶ�λ��0.include��1.exclude
															--	����λ��0.����1.������
															--	����λ��0.�̶���1.����������2.�����ˣ�3.����ͯ
															--	����λ��0.������գ�1.���ⲻ�� 

	@ret						integer, 
	@msg						varchar(60),
   @count               int,
	@add_bed_switch		char(2)

select @add_bed_switch = isnull(value,'FF') from sysoption where catalog = 'audit' and item = 'room_charge_extra_NP'

delete rmpostpackage where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt
delete rmpostvip where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt
select @bdate = dateadd(ss, -1, dateadd(dd, 2, bdate1)) from sysdata
--select @groupno = groupno, @ratecode = ratecode, @packages = packages, @type = type, @roomno = roomno, 
--	@qtrate = qtrate, @setrate = setrate, @rtreason = rtreason, @market = market, @gstno = gstno, @children = children,
--	@srqs = srqs, @arr = arr, @dep = dep, @week = datepart(dw, @rmpostdate)
--	from master where accnt = @accnt
if @operation like '[Rr]%'
begin
	select @packages = substring(@operation, 3, 50), @gstno = convert(integer, substring(@operation, 53, 5)),
		@class = substring(@operation, 58, 58), @roomno = ''
-- �Ƿ�Ҫ��ӻ�����֤ simon 20070618 
--	select @class = class from master where accnt = @accnt
--	if @class = 'F'
--		begin
--		select @msg = '' -- 'fut'
--		exec @ret = p_gds_get_accnt_rmrate @accnt, @setrate out, @msg out, @rmpostdate
--		end
end 
else
	begin
//�ж��Ƿ�ʹ����ÿ�շ��ۣ����ʹ����ÿ�շ���,package��Ҫ��rsvsrc_detail��ȡ
   select @count=count(1) from rsvsrc_detail where accnt=@accnt and datediff(day,date_,@rmpostdate)=0 and mode='M'
   if @count>0
      begin
				select @class = class, @packages = packages, @roomno = roomno, @arr = arr, @dep = dep, @week = datepart(dw, @rmpostdate),
			@rmrate = isnull(rmrate,0), @qtrate = qtrate, @setrate = setrate, @gstno = gstno, @children = children,
			@addbed = isnull(addbed,0), @addbed_rate = isnull(addbed_rate,0), @crib = crib, @crib_rate = crib_rate
			from master where accnt = @accnt
         select @packages=packages from rsvsrc_detail where accnt=@accnt and date_=@rmpostdate
       end
    else
				select @class = class, @packages = packages, @roomno = roomno, @arr = arr, @dep = dep, @week = datepart(dw, @rmpostdate),
			@rmrate = isnull(rmrate,0), @qtrate = qtrate, @setrate = setrate, @gstno = gstno, @children = children,
			@addbed = isnull(addbed,0), @addbed_rate = isnull(addbed_rate,0), @crib = crib, @crib_rate = crib_rate
			from master where accnt = @accnt


-- ֻ���з��ŵĿ��˲żƷ���
	if @class = 'F'
		begin
		select @msg = '' -- 'fut'  simon 20070618  p_gds_get_accnt_rmrate��Ҫ���� 
		exec @ret = p_gds_get_accnt_rmrate @accnt, @setrate out, @msg out, @rmpostdate
		end
	else if @@rowcount = 0
		select @class = class, @packages = '', @roomno = '', @arr = arr, @dep = dep, @week = datepart(dw, @rmpostdate),
			@rmrate = 0.00, @qtrate = 0.00, @setrate = 0.00, @gstno = 0, @children = 0,
			@addbed = 0, @addbed_rate = 0, @crib = 0, @crib_rate = 0
			from ar_master where accnt = @accnt
	else
		select @packages = '', @rmrate = 0.00, @qtrate = 0.00, @setrate = 0.00, @gstno = 0, @children = 0,
			@addbed = 0, @addbed_rate = 0, @crib = 0, @crib_rate = 0
	end
--
select @rmrate = round(@rmrate / @w_or_h, 2), @qtrate = round(@qtrate / @w_or_h, 2), @setrate = round(isnull(@setrate, 0) / @w_or_h, 2),
	@addbed = round(@addbed / @w_or_h, 2), @crib = round(@crib / @w_or_h, 2)
--select @charge1 = @qtrate, @charge2 = @qtrate - @setrate, @charge3 = 0, @charge4 = 0, @charge5 = round(@addbed * @addbed_rate + @crib * @crib_rate, 2)
select @charge1 = @qtrate, @charge2 = @qtrate - @setrate, @charge3 = 0, @charge4 = 0, @charge5 = 0
-- 1.����Ӵ�

if substring(@add_bed_switch,1,1) = 'F' and @operation not like '_N%' 
	select @addbed = 0
if substring(@add_bed_switch,2,1) = 'F' and @operation not like '_N%' 
	select @crib = 0
if isnull(round(@addbed * @addbed_rate + @crib * @crib_rate, 2),0) <> 0
	begin
	select @pccode = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccode_extra'), '007')
	select @number = isnull((select max(number) from rmpostpackage where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt), 0) + 1
	insert rmpostpackage select @pc_id, @mdi_id, isnull(@accnt,''), @number, isnull(@roomno,''), '', pccode, argcode,
		isnull(round(@addbed * @addbed_rate + @crib * @crib_rate, 2),0), isnull(round(@addbed + @crib, 2),0), '1100000000', 
		getdate(), getdate(), '00:00:00', '23:59:59', descript, descript1, '', pccode, 0
		from pccode where pccode = @pccode
	end
-- 2.����Package(Ŀǰֻ����ɢ�͵�package, ���������ݲ�����. ���б�Ҫ�޸������while����)
select @rmdeptno1 = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_deptno'), '10')
while @class = 'F' and @packages != ''
	begin
	select @li_pos = charindex(',', @packages)
	if @li_pos > 0
		select @package = substring(@packages, 1, @li_pos - 1), @packages = substring(@packages, @li_pos + 1, 50)
	else
		select @package = @packages, @packages = ''
	--
	select @deptno1 = b.deptno1, @pccode = a.pccode, @argcode = b.argcode, @quantity = a.quantity, @descript1 = a.descript1, @descript = a.descript, 
		@rule_calc = a.rule_calc, @rule_post = rule_post, @rule_parm = rule_parm, 
		@starting_days = a.starting_days, @closing_days = a.closing_days, @starting_package = a.starting_time, @closing_package = a.closing_time, 
		@pccodes = a.pccodes, @pos_pccode = a.pos_pccode, @amount = a.amount, @credit = a.credit, @column = b.commission
		from package a, pccode b where a.code = @package and a.pccode = b.pccode

	if @@rowcount = 1
		begin
		if @rule_post = '*' or 
			(@rule_post like 'B%' and convert(char(10), @arr, 101) = convert(char(10), @rmpostdate, 101)) or
			(@rule_post like 'E%' and convert(char(10), dateadd(day, -1, @dep), 101) = convert(char(10), @rmpostdate, 101)) or
			(@rule_post like 'W%' and charindex(convert(char(1), datepart(dw, @dep)), @rule_post) > 0) or
			(@rule_post like '-B%' and convert(char(10), @arr, 101) != convert(char(10), @rmpostdate, 101)) or
			(@rule_post like '-E%' and convert(char(10), dateadd(day, -1, @dep), 101) != convert(char(10), @rmpostdate, 101)) or
			(@rule_post like 'M%' and convert(char(10), @arr, 101) != convert(char(10), @rmpostdate, 101) and convert(char(10), dateadd(day, -1, @dep), 101) != convert(char(10), @rmpostdate, 101))
			begin
			-- ����λ��0.���ⲻ�գ�1.������� 
			if @operation like '_D%' and substring(@rule_calc, 5, 1) = '1'
				select @amount = 0, @quantity = 0
			-- ����λ��0.����1.������ 
			if substring(@rule_calc, 3, 1) = '1'
				begin
				if substring(@rule_calc, 2, 1) = '0'
					select @amount = round(@setrate * @amount / (1 + @amount), 2)
				else
					select @amount = round(@setrate * @amount, 2)
				end
			-- ����λ��0.�̶���1.����������2.�����ˣ�3.����ͯ 
			if substring(@rule_calc, 4, 1) = '1'
				select @amount = round((@gstno + @children) * @amount, 2), @quantity = round((@gstno + @children) * @quantity, 0), @credit = round((@gstno + @children) * @credit, 2)
			else if substring(@rule_calc, 4, 1) = '2'
				select @amount = round(@gstno * @amount, 2), @quantity = round(@gstno * @quantity, 0), @credit = round(@gstno * @credit, 2)
			else if substring(@rule_calc, 4, 1) = '3'
				select @amount = round(@children * @amount, 2), @quantity = round(@children * @quantity, 0), @credit = round(@children * @credit, 2)
			-- ���Ѻϲ���ͬһ���� 
--			if @pccode like '00%'
			if @deptno1 = @rmdeptno1 and substring(@rule_calc, 1, 1) = '0'
				begin
				-- ��һλ���Է��Ѳ�������
				--	�ڶ�λ��0.include��1.exclude 
				if substring(@rule_calc, 2, 1) = '0'
					select @charge1 = @charge1 - @amount
				if @column = 3
					select @charge3 = @charge3 + @amount
				else if @column = 4
					select @charge4 = @charge4 + @amount
				else
					select @charge5 = @charge5 + @amount
				end
			else
				begin
				-- ��һλ��0.���ù���Package_Detail�У�1.���ù���Account��
				--	�ڶ�λ��0.include��1.exclude
				--	00, 11����Ӱ��charge1 
				if substring(@rule_calc, 1, 2) = '10'
					select @charge1 = @charge1 - @amount
				else if substring(@rule_calc, 1, 2) = '01'
					select @charge1 = @charge1 + @amount
				--
//				if not (@amount = 0 and @quantity = 0)
//					begin
//					select @number = isnull((select max(number) from rmpostpackage where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt), 0) + 1
//					insert rmpostpackage select @pc_id, @mdi_id, @accnt, @number, @roomno, @package, @pccode, @argcode, @amount, @quantity, @rule_calc, 
//						dateadd(dd, @starting_days, @rmpostdate), dateadd(dd, @starting_days + @closing_days, @rmpostdate), 
//						@starting_package, @closing_package, @descript, @descript1, @pccodes, @pos_pccode, @credit
//					end
//				end
				end
			if not (@amount = 0 and @quantity = 0)
				begin
				select @number = isnull((select max(number) from rmpostpackage where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt), 0) + 1
				insert rmpostpackage select @pc_id, @mdi_id, @accnt, @number, @roomno, @package, @pccode, @argcode, @amount, @quantity, @rule_calc, 
					dateadd(dd, @starting_days, @rmpostdate), dateadd(dd, @starting_days + @closing_days, @rmpostdate), 
					@starting_package, @closing_package, @descript, @descript1, @pccodes, @pos_pccode, @credit
				end
			end
		end
	end
-- 3.����Fixed Charge(ֻ�й�ҹ����ȡ)
if @operation like '_N%'
	begin
	declare c_fixed_charge cursor for
		select pccode, argcode, amount, quantity, starting_time, closing_time from fixed_charge where accnt = @accnt order by number
	open c_fixed_charge
	fetch c_fixed_charge into @pccode, @argcode, @amount, @quantity, @starting_fixed_charge, @closing_fixed_charge
	while @@sqlstatus = 0
		begin
		if @rmpostdate >= @starting_fixed_charge and @rmpostdate <= @closing_fixed_charge
			begin
			select @number = isnull((select max(number) from rmpostpackage where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt), 0) + 1
			insert rmpostpackage select @pc_id, @mdi_id, @accnt, @number, @roomno, '', @pccode, @argcode, @amount,
				1, '1100000000', getdate(), getdate(), @starting_fixed_charge, @closing_fixed_charge, '', '', '', '', 0
			end
		fetch c_fixed_charge into @pccode, @argcode, @amount, @quantity, @starting_fixed_charge, @closing_fixed_charge
		end
	close c_fixed_charge
	deallocate cursor c_fixed_charge
	end
--
if upper(substring(@operation, 1, 1)) <> substring(@operation, 1, 1)
	select @charge1, @charge2, @charge3, @charge4, @charge5
return 0
;
