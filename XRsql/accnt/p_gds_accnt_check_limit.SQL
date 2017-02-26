IF OBJECT_ID('dbo.p_gds_accnt_check_limit') IS NOT NULL
    DROP PROCEDURE dbo.p_gds_accnt_check_limit
;
create proc p_gds_accnt_check_limit
	@accnt			char(10),				--帐号
	@charge			money,					--借方
	@credit			money,					--贷方
	@retmode			char(1)	= 'S',
	@ret				int	out,
   @msg				varchar(60) out		--返回信息
as
-------------------------------------------------------------------
--	综合的余额判断
-------------------------------------------------------------------
declare
	@lic_buy_1		varchar(255),
	@lic_buy_2		varchar(255),
	@nar				char(1)								-- 是否为新AR账

-- which ar system
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
if charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0
	select @nar = 'T'
else
	select @nar = 'F'

-- begin 
select @ret = 0, @msg = ''

if @nar = 'T'
	exec @ret = p_gl_ar_check_limit @accnt,@charge,@credit,@msg	out
else
	exec @ret = p_gl_accnt_check_limit @accnt,@charge,@credit,@msg	out

-- output
if @retmode = 'S'
	select @ret, @msg

return @ret
;
