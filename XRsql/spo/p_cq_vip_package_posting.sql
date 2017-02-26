drop proc p_cq_vip_package_posting;
create proc p_cq_vip_package_posting
		@no				char(40),
		@paycode			char(5),
		@accnt			char(10),  --分摊帐号
		@accnt1			char(10),  --结帐帐号
		@pccode			char(5),
		@amount			money,
		@pc_id			char(4),
		@shift			char(1),
		@empno			char(10),
		@type			char(1)
		
as
declare
		@packcode		char(10),
		@inumber			integer,
		@class			char(1),
		@rate				money,
		@amount0			money,
		@posted			money,
		@arr				datetime,
		@dep				datetime,
		@bdate			datetime,
		@today			datetime,
		@menu				char(11),
		@remark			char(200),
		@remark1			char(200),
		@toaccnt			char(10),
		@lic_buy_1		char(255),
		@lic_buy_2		char(255),

		@ret				integer,
		@msg				char(50),
		@set				char(11)

select @bdate = bdate from sysdata 
select @today = getdate() from sysdata
select @lic_buy_1 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.1'
select @lic_buy_2 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.2'
begin tran
save tran p_package_s
select @accnt = rtrim(@accnt)
select @accnt1 = rtrim(@accnt1)
select @remark = rtrim(@no) + '('+@accnt1+')'
select @remark1 = rtrim(@no) + '('+@accnt+')'
select @set = 'A' + rtrim(@no),@msg = rtrim(@no)

	--new ar
if (select value from sysoption where catalog = 'ar' and item = 'creditcard') = 'T'
	begin
	if exists(select 1 from bankcard where pccode = @paycode)        -- 付款码判断是否自动转ar
		and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
		begin
		select @toaccnt = min(accnt) from bankcard where pccode = @paycode
		if rtrim(@toaccnt) is null
			begin
			select @ret = 1, @msg = @paycode + ' 没有转账账号'
			goto gout
			end
		select @remark = 'sport transfer'
		end
	end
	--------------------
if @type = 'T'			--会费结算
	select @amount0 = -1.0 * @amount
else						--当日撤销结算
	select @amount0 = @amount,@amount = -1*@amount

if exists(select 1 from pccode where pccode = @paycode and deptno2 like 'TO%') or rtrim(@toaccnt) is not null
	begin
	if rtrim(@toaccnt) is not null
		begin
		select @accnt1 = @toaccnt
		select @remark = rtrim(@no) + '('+@accnt1+')'
		end
	exec @ret = p_gl_accnt_posting @set, '02', @pc_id,3, @shift, @empno, @accnt,0, @pccode, '',1, @amount0,0,0,0,0,0,@remark,@remark, @today, '', '', 'IRYY', 0, '', @msg out
	if @ret = 0 
		begin
		exec @ret = p_gl_accnt_posting @set, '02', @pc_id,3, @shift, @empno, @accnt1,0, @pccode, '',1, @amount,0,0,0,0,0,@remark1,@remark1, @today, '', '', 'IR', 0, '', @msg out
		end
	end
else
	exec @ret = p_gl_accnt_posting @set, '02', @pc_id,3, @shift, @empno, @accnt,0, @paycode, '98',1, @amount,0,0,0,0,0,@no,@no, @today, '', '', 'IR', 0, '', @msg out
	

gout:
if @ret <> 0
   rollback tran p_package_s
commit tran

select @ret ,@msg

;
