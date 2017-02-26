
if exists(select * from sysobjects where name = 'p_gl_audit_rmpost_calculate')
	drop proc p_gl_audit_rmpost_calculate;
create proc p_gl_audit_rmpost_calculate
	@rmpostdate					datetime,
	@accnt						char(10), 				-- 帐号 
	@w_or_h						integer, 				-- 1.全天  2.半天 
	@rmrate						money out,				            
	@qtrate						money out,				            
	@setrate						money out,				            
	@charge1						money	out,				-- 房费 
	@charge2						money	out,				-- 优惠 
	@charge3						money	out,				-- 服务费 
	@charge4						money	out,				-- 城建费 
	@charge5						money	out,				-- 加床 
	@operation					char(58) = 'FN',		-- 仅计算房价的标志
															--	第1位：Ff：正常计算房费(缺省值)； Rr：重新计算房费； 小写：带Select返回值； 
															--	第2位：N稽核房费,D：日租
															--	第3-52位：Packages
															--	第53-57位：Gstno
															--	第58-58位：Class
	@pc_id						char(4),					-- 过房租的计算机地址 
	@mdi_id						integer					-- 过房租的Mdi 
as
-------------------------------------------------------------------------------
-- 房费计算 
--
-- 参数有三种类别
--	1. 用于稽核(加收)时计算房费, 特征： @operation like 'F%'
--
--	2. 用于结账时按新指定的优惠比例重新计算房费, 特征： @operation like 'R%'
--		substring(@operation, 3, 50) = @packages
--
--	3. 用于登记时显示实际房费和优惠比例, 特征有正常的帐号@accnt和五位@operation及@w_or_h为零
--		accnt：帐号, @w_or_h：0, @charge1：房费(传入的参数是@qtrate), @charge2：优惠(传入的参数是@discount1), 
--		@charge3：服务费, @charge4：城建费, @charge5：加床(传入的参数是@setrate), 
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
	@addbed			   		money,				-- 加床数量  
	@addbed_rate				money,				-- 加床价 
	@crib	   					money,				-- 婴儿床数量 
	@crib_rate					money,				-- 婴儿床价格 
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
	@rule_calc					char(10),			-- 计算方式选项
															--	第一位：0.费用过在Package_Detail中；1.费用过在Account中
															--	第二位：0.include；1.exclude
															--	第三位：0.按金额；1.按比例
															--	第四位：0.固定金额；1.按总人数；2.按成人；3.按儿童
															--	第五位：0.日租加收；1.日租不收 

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
-- 是否要添加还需验证 simon 20070618 
--	select @class = class from master where accnt = @accnt
--	if @class = 'F'
--		begin
--		select @msg = '' -- 'fut'
--		exec @ret = p_gds_get_accnt_rmrate @accnt, @setrate out, @msg out, @rmpostdate
--		end
end 
else
	begin
//判断是否使用了每日房价，如果使用了每日房价,package需要从rsvsrc_detail中取
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


-- 只有有房号的客人才计房费
	if @class = 'F'
		begin
		select @msg = '' -- 'fut'  simon 20070618  p_gds_get_accnt_rmrate需要修正 
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
-- 1.处理加床

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
-- 2.处理Package(目前只处理散客的package, 其他类别的暂不考虑. 如有必要修改下面的while条件)
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
			-- 第五位：0.日租不收；1.日租加收 
			if @operation like '_D%' and substring(@rule_calc, 5, 1) = '1'
				select @amount = 0, @quantity = 0
			-- 第三位：0.按金额；1.按比例 
			if substring(@rule_calc, 3, 1) = '1'
				begin
				if substring(@rule_calc, 2, 1) = '0'
					select @amount = round(@setrate * @amount / (1 + @amount), 2)
				else
					select @amount = round(@setrate * @amount, 2)
				end
			-- 第四位：0.固定金额；1.按总人数；2.按成人；3.按儿童 
			if substring(@rule_calc, 4, 1) = '1'
				select @amount = round((@gstno + @children) * @amount, 2), @quantity = round((@gstno + @children) * @quantity, 0), @credit = round((@gstno + @children) * @credit, 2)
			else if substring(@rule_calc, 4, 1) = '2'
				select @amount = round(@gstno * @amount, 2), @quantity = round(@gstno * @quantity, 0), @credit = round(@gstno * @credit, 2)
			else if substring(@rule_calc, 4, 1) = '3'
				select @amount = round(@children * @amount, 2), @quantity = round(@children * @quantity, 0), @credit = round(@children * @credit, 2)
			-- 房费合并在同一行上 
--			if @pccode like '00%'
			if @deptno1 = @rmdeptno1 and substring(@rule_calc, 1, 1) = '0'
				begin
				-- 第一位：对房费不起作用
				--	第二位：0.include；1.exclude 
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
				-- 第一位：0.费用过在Package_Detail中；1.费用过在Account中
				--	第二位：0.include；1.exclude
				--	00, 11均不影响charge1 
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
-- 3.处理Fixed Charge(只有过夜才收取)
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
