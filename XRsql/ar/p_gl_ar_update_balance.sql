if exists(select * from sysobjects where name = 'p_gl_ar_update_balance' and type='P')
	drop proc p_gl_ar_update_balance;

create proc p_gl_ar_update_balance
	@accnt				char(10),					-- 账号
	@charge				money,						-- 借方
	@credit				money,						-- 贷方
	@lastnumb			integer		out,			
	@lastinumb			integer		out,
	@balance				money			out,
	@option				char(2),						-- Lastnumb选项
	@msg					varchar(60)	out			-- 返回信息
as
-- 记账时的主单相应数据的更新 
-- 记账过程:先更新主单记总账,返回一部分参数记录明细账 
-- ar_master.Lastinumb转为Package_detail.Number指针 
declare
	@statype				char(1),
	@sta					char(1),
	@status				char(10),					-- 不允许入账的状态
	@step1				integer,
	@step2				integer,
	@ret					integer

select @status = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), '-ODEX')
select @ret = 0, @statype = substring(@status, 1, 1), @step1 = 0, @step2 = 0
--
if substring(@option, 1, 1) = 'Y'
	select @step1 = 1
if substring(@option, 2, 1) = 'Y'
	select @step2 = 1
begin tran
save tran p_gl_ar_update_balance_s1
update ar_master set charge = charge + @charge, credit = credit + @credit, lastnumb = lastnumb + @step1, lastinumb = lastinumb + @step2
	where accnt = @accnt
--
if @@rowcount = 0 
	select @ret = 1, @msg = '账号%1不存在^' + @accnt
else
	begin
	select @sta = sta from ar_master where accnt = @accnt
	if (@statype = '-' and charindex(@sta, @status) = 0 or @statype != '-' and charindex(@sta, @status) > 0)
		select @lastnumb = lastnumb, @lastinumb = lastinumb, @balance = charge - credit from ar_master where accnt = @accnt
	else if charindex(@sta, "ODE") > 0
		select @ret = 1, @msg = '账号%1已经结账^' + @accnt
	else 
		select @ret = 1, @msg = '账号%1相应状态不允许本交易发生,请检查^' + @accnt
	end
if @ret != 0
   rollback tran p_gl_ar_update_balance_s1
commit tran 
return @ret
;
