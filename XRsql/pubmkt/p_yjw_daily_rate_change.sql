IF OBJECT_ID('dbo.p_yjw_daily_rate_change') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_yjw_daily_rate_change
    IF OBJECT_ID('dbo.p_yjw_daily_rate_change') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_yjw_daily_rate_change >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_yjw_daily_rate_change >>>'
END
;

create proc p_yjw_daily_rate_change
	@operation					char(58) = 'FN',		-- �����㷿�۵ı�־
															--	��1λ��Ff���������㷿��(ȱʡֵ)�� Rr�����¼��㷿�ѣ� Сд����Select����ֵ��
															--	��2λ��N���˷���,D������
															--	��3-52λ��Packages
															--	��53-57λ��Gstno
															--	��58-58λ��Class
	@pc_id						char(4),				-- ������ļ������ַ
	@mdi_id						integer,				-- �������Mdi
   @date_                  datetime,         --������۵�����
   @ratecode               char(10),         --������
   @rmtype                 char(5),          --����
   @packages               varchar(50),
   @rate                   money,
   @gstno						integer,
	@children					integer
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
	@package						char(4),
	--
	@roomno						char(5),
	@addbed			   		money,				-- �Ӵ�����
	@addbed_rate				money,				-- �Ӵ���
	@crib	   					money,				-- Ӥ��������
	@crib_rate					money,				-- Ӥ�����۸�
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
	@rule_calc					char(10),			-- ���㷽ʽѡ��
															--	��һλ��0.���ù���Package_Detail�У�1.���ù���Account��
															--	�ڶ�λ��0.include��1.exclude
															--	����λ��0.����1.������
															--	����λ��0.�̶���1.����������2.�����ˣ�3.����ͯ
															--	����λ��0.������գ�1.���ⲻ��

	@ret						integer,
	@msg						varchar(60),
   @sub_ratecode        char(10),         --������ϸ��
	@rmpostdate					datetime,
   @charge1						money	,				-- ����
	@charge2						money	,				-- �Ż�
	@charge3						money	,				-- �����
	@charge4						money	,				-- �ǽ���
	@charge5						money, 				-- �Ӵ�
   @multi                  money,
   @adder                  money,
   @tag                    char(1)



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
		 select @sub_ratecode=code from rmratedef where code in(select rmcode from #subcode)  and charindex(@rmtype,type)>0
       select @setrate=@rate,@rmrate=@rate,@charge1=@rate,@qrate=@rate       
                                                                                                             
                                                                                        

                              
                                                                  
                    
                 
                               
                                                                                                                                          
                                           
              

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
                                                                    
				begin
				-- ��һλ���Է��Ѳ�������
				--	�ڶ�λ��0.include��1.exclude
				if substring(@rule_calc, 2, 1) = '0'
					select @charge1 = @charge1 - @amount
            else
               select @rmrate = @rate + @amount
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
	@arr, dateadd(dd, 1, @arr), '����', 'RmRate', '', '',0

insert rmratecode_check select @pc_id, @mdi_id,'',1, @roomno, 'QRAT', '', '',@qrate, @quantity, '',
	@arr, dateadd(dd, 1, @arr),
	@arr, dateadd(dd, 1, @arr), '������', 'QRate', '', '',0
return 0

;
EXEC sp_procxmode 'dbo.p_yjw_daily_rate_change','unchained'
;
IF OBJECT_ID('dbo.p_yjw_daily_rate_change') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_yjw_daily_rate_change >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_yjw_daily_rate_change >>>'
;
