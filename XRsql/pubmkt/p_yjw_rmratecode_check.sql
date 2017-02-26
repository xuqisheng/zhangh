IF OBJECT_ID('dbo.p_yjw_rmratecode_check') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_yjw_rmratecode_check
    IF OBJECT_ID('dbo.p_yjw_rmratecode_check') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_yjw_rmratecode_check >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_yjw_rmratecode_check >>>'
END
;
create proc p_yjw_rmratecode_check
	@operation					char(58) = 'FN',		-- 仅计算房价的标志
															--	第1位：Ff：正常计算房费(缺省值)； Rr：重新计算房费； 小写：带Select返回值；
															--	第2位：N稽核房费,D：日租
															--	第3-52位：Packages
															--	第53-57位：Gstno
															--	第58-58位：Class
	@pc_id						char(4),					-- 过房租的计算机地址
	@mdi_id						integer,					-- 过房租的Mdi
   @date_                  datetime,             --计算包价的日期
   @ratecode               char(10),              --房价码
   @rmtype                 char(5),                --房类
   @packages               varchar(50),
	@gstno						integer,
	@children					integer
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
	@package						char(4),
	--
	@roomno						char(5),
	@addbed			   		money,				-- 加床数量
	@addbed_rate				money,				-- 加床价
	@crib	   					money,				-- 婴儿床数量
	@crib_rate					money,				-- 婴儿床价格
	--
   @rmrate                 money,
   @setrate                money,
   @qrate                  money,
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
   @sub_ratecode        char(10),         --房价明细码
	@rmpostdate					datetime,
   @charge1						money	,				-- 房费
	@charge2						money	,				-- 优惠
	@charge3						money	,				-- 服务费
	@charge4						money	,				-- 城建费
	@charge5						money, 				-- 加床
   @multi                  money,
   @adder                  money,
   @tag                    char(1),
   @rmmode                 char(1)



create table #subcode
      (
         rmcode char(10)
      )

delete rmratecode_check where pc_id = @pc_id
select @bdate=@date_,@class='F',@rmtype=rtrim(@rmtype),@arr=@date_,@dep=dateadd(day,1,@date_),@rmpostdate=@date_

select @roomno=''
if @operation like '[Rr]%'
	begin
		select @roomno = ''

	end
else
	begin
		 insert #subcode select rmcode from rmratecode_link where code=@ratecode
		 select @sub_ratecode=code from rmratedef where code in(select rmcode from #subcode)  and (charindex(','+@rmtype+',',','+type+',')>0 or type is null or type='')

		 select @rmmode=ratemode from rmratedef where code=@sub_ratecode
       if @rmmode='S'
         begin
            if @gstno<=1
	       		select @rmrate=rate1 from rmratedef where code=@sub_ratecode
            else if @gstno=2
               select @rmrate=rate2 from rmratedef where code=@sub_ratecode
             else if @gstno=3
               select @rmrate=rate3 from rmratedef where code=@sub_ratecode
             else if @gstno=4
               select @rmrate=rate4 from rmratedef where code=@sub_ratecode
             else if @gstno=5
               select @rmrate=rate5 from rmratedef where code=@sub_ratecode
             else if @gstno>=6
               select @rmrate=rate6 from rmratedef where code=@sub_ratecode
          end
       else
     		begin
	         select @rmrate=rate from typim where type=@rmtype
            if @gstno<=1
	            select @rmrate=@rmrate*(1- rate1) from rmratedef where code=@sub_ratecode
         	else if @gstno=2
	            select @rmrate=@rmrate*(1- rate2) from rmratedef where code=@sub_ratecode
				else if @gstno=3
	            select @rmrate=@rmrate*(1- rate3) from rmratedef where code=@sub_ratecode
            else if @gstno=4
	            select @rmrate=@rmrate*(1- rate4) from rmratedef where code=@sub_ratecode
				else if @gstno=5
	            select @rmrate=@rmrate*(1- rate5) from rmratedef where code=@sub_ratecode
				else if @gstno>=6
	            select @rmrate=@rmrate*(1- rate6) from rmratedef where code=@sub_ratecode

         end
		exec @ret=p_yjw_rate_for_dailyrate @rmtype,@date_,@date_,1,@ratecode,@rmrate output
      select @setrate=@rmrate,@charge1=@rmrate,@qrate=@rmrate

      select @tag=calendar from rmratecode where code=@ratecode
      if @tag='T'
         begin
				select @multi=1,@adder=0
				select @multi=a.multi,@adder=a.adder from rmrate_factor a,rmrate_calendar b where datediff(day,b.date,@date_)=0 and a.code=b.factor
				select @rmrate=@rmrate*@multi+@adder
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
		@pccodes = a.pccodes, @pos_pccode = a.pos_pccode, @amount = isnull(a.amount,0), @credit = a.credit, @column = b.commission
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

				begin
				-- 第一位：对房费不起作用
				--	第二位：0.include；1.exclude
				if substring(@rule_calc, 2, 1) = '0'
					select @charge1 = @charge1 - @amount
            else
               select @rmrate =@rmrate + @amount
    			if @column = 3
					select @charge3 = @charge3 + @amount
				else if @column = 4
					select @charge4 = @charge4 + @amount
				else
					select @charge5 = @charge5 + @amount

				if not (@amount = 0 and @quantity = 0)
					begin
               select @number = isnull((select max(number) from rmratecode_check where pc_id = @pc_id), 1) + 1
					insert rmratecode_check select @pc_id, @mdi_id,'',@number, @roomno, @package, @pccode, @argcode, isnull(@amount,0), @quantity, @rule_calc,
						dateadd(dd, @starting_days, @rmpostdate), dateadd(dd, @starting_days + @closing_days, @rmpostdate),
						@starting_package, @closing_package, @descript, @descript1, @pccodes, @pos_pccode, @credit
					end

				end


















			end
		end
	end
end


select @qrate=@charge1
insert rmratecode_check select @pc_id, @mdi_id,'',0, @roomno, 'RMRA', '', '',@rmrate, @quantity, '',
@arr, dateadd(dd, 1, @arr),
	@arr, dateadd(dd, 1, @arr), '房价', 'RmRate', '', '',0

insert rmratecode_check select @pc_id, @mdi_id,'',1, @roomno, 'QRAT', '', '',@qrate, @quantity, '',
	@arr, dateadd(dd, 1, @arr),
	@arr, dateadd(dd, 1, @arr), '净房价', 'QRate', '', '',0
return 0


;
EXEC sp_procxmode 'dbo.p_yjw_rmratecode_check','unchained'
;
IF OBJECT_ID('dbo.p_yjw_rmratecode_check') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_yjw_rmratecode_check >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_yjw_rmratecode_check >>>'
;
