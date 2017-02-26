
if exists(select * from sysobjects where name = 'p_gl_accnt_update_balance' and type='P')
	drop proc p_gl_accnt_update_balance;

create proc p_gl_accnt_update_balance
	@accnt				char(10),					-- 帐号 
	@pccode				char(5),						-- 费用码 
	@charge				money,						-- 借方 
	@credit				money,						-- 贷方 
	@roomno				char(5)		out,			-- 房号跟踪 
	@groupno				char(10)		out,			-- 团号跟踪 
	@lastnumb			integer		out,			
	@lastinumb			integer		out,
	@balance				money			out,
	@class				char(3)		out,			-- 类别跟踪 
	@msg					varchar(60)	out			-- 返回信息 
as
-- 记帐时的主单相应数据的更新 
-- 记帐过程:先更新主单记总帐,返回一部分参数记录明细帐 
-- Master.Lastinumb转为Package_detail.Number指针 

declare
	@statype				char(1),
	@sta					char(1),
	@status				char(10),				-- 不允许入账的状态 
	@step1				integer,
	@step2				integer,
	@ret					integer

select @status = isnull((select value from sysoption where catalog = 'account' and item = 'invalid_sta'), '-ODEX')
select @ret = 0, @statype = substring(@status, 1, 1)
--
if @pccode = '' and @charge = 0 and @credit = 0
	select @step1 = 0, @step2 = 1
else
	select @step1 = 1, @step2 = 0
begin tran
save tran p_gl_accnt_update_balance_s1
update master set charge = charge + @charge, credit = credit + @credit, lastnumb = lastnumb + @step1, lastinumb = lastinumb + @step2
	where accnt = @accnt
if @@rowcount = 0 
	select @ret = 1, @msg = '帐号['+rtrim(@accnt)+']不存在^' 
else
	begin
	select @class = market, @sta = sta from master where accnt = @accnt
	if (@statype = '-' and charindex(@sta, @status) = 0 or @statype != '-' and charindex(@sta, @status) > 0)
		select @msg = sta, @lastnumb = lastnumb, @lastinumb = lastinumb, @balance = charge - credit, @roomno = roomno, @groupno = groupno
			from master where accnt = @accnt
	else if charindex(@sta, "ODE") > 0
		select @ret = 1, @msg = '帐号['+rtrim(@accnt)+']已经结帐^' 
	else 
		select @ret = 1, @msg = '帐号['+rtrim(@accnt)+']相应状态不允许本交易发生,请检查^'
	end
if @ret != 0
   rollback tran p_gl_accnt_update_balance_s1
commit tran 
return @ret
;
