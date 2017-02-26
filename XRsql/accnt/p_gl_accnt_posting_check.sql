
if  exists(select * from sysobjects where name = 'p_gl_accnt_posting_check')
	drop proc p_gl_accnt_posting_check;

create proc p_gl_accnt_posting_check	--输入参数确保非NULL
	@accnt				char(10), 
	@subaccnt			integer,
	@pccode				char(5),
	@amount				money

as
-- 判断是否有有效的包；是否有定义转账 
declare
	@bdate				datetime,
	@log_date			datetime,
	@log_time			char(8), 
	@argcode				char(3),
	@deptno1				char(8), 			-- %05*% 
	@pccodes				char(7), 			-- %004%
	@to_accnt			char(10), 
	@to_roomno			char(5), 
	@to_name				char(50), 
	@to_sta				char(1), 
	@status				char(10),
	@statype				char(1),
	@pcrec_pkg			char(10), 
	@tor_str				varchar(40), 
	@package				char(255), 
	@transfer			char(255)

select @log_date = getdate(), @bdate = bdate1 from sysdata
select @package = '', @transfer = '', @log_time = convert(char(8), @log_date, 108)
select @tor_str = isnull((select value from sysoption where catalog = 'audit' and item = 'deptno_of_tor'), '')
select @pcrec_pkg = rtrim(pcrec_pkg) from master where accnt = @accnt
select @deptno1 = deptno1, @argcode = argcode from pccode where pccode = @pccode
select @pccodes = '%' + rtrim(@pccode) + '%'
select @deptno1 = '%' + rtrim(@deptno1) + '*%'
if @argcode < '9'
	begin
	-- 检查Package
	if @amount > 0
		begin
		if exists(select 1 from package_detail a, master b where (b.accnt = @accnt or b.pcrec_pkg = @pcrec_pkg) 
			and a.accnt = b.accnt and a.tag < '2' and @log_date >= a.starting_date 
			and @log_date <= a.closing_date and @log_time >= a.starting_time and @log_time <= a.closing_time
			and (a.pccodes = '*' or a.pccodes like @deptno1 or a.pccodes like @pccodes))
			select @package = '是否确信要使用Package'
		end
	else if @amount < 0
		begin
		if exists(select 1 from package_detail a, master b where (b.accnt = @accnt or b.pcrec_pkg = @pcrec_pkg) 
			and a.accnt = b.accnt and a.tag in ('1', '2') and @log_date >= a.starting_date 
			and @log_date <= a.closing_date and @log_time >= a.starting_time and @log_time <= a.closing_time
			and (a.pccodes = '*' or a.pccodes like @deptno1 or a.pccodes like @pccodes))
			select @package = '是否确信要冲回Package'
		end
	--
	-- 检查自动转账
	if not exists (select name from subaccnt where type = '5' and accnt = @accnt and subaccnt = @subaccnt)
		select @subaccnt = isnull((select max(subaccnt) from subaccnt where type = '5' and accnt = @accnt
			and (pccodes = '*' or pccodes like @deptno1 or pccodes like @pccodes)
			and @log_date >= starting_time and @log_date <= closing_time), 1)
	select @to_accnt = a.to_accnt, @to_roomno = b.roomno, @to_sta = b.sta, @to_name = c.name
		from subaccnt a, master b, guest c
		where a.type = '5' and a.accnt = @accnt and a.subaccnt = @subaccnt and a.to_accnt = b.accnt and b.haccnt = c.no
	select @status = isnull((select value from sysoption where catalog = 'account' and item = 'auto_transfer_status'), 'IR')
	if not rtrim(@to_accnt) is null and not (@to_accnt like 'A%' and @tor_str != '') and charindex(@to_sta, @status) > 0
		select @transfer = '是否确信要转入[%1]%2^' + isnull(rtrim(@to_roomno), rtrim(@to_accnt)) + '^' + @to_name
	end
select @package, @transfer
;
