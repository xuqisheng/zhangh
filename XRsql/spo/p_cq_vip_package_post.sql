drop proc p_cq_vip_package_post;
create proc p_cq_vip_package_post
		@no				char(20),
		@packcode		char(10),
		@inumber			integer,
		@pc_id			char(4),
		@shift			char(1),
		@empno			char(10)
		
as
declare
		
		@class			char(1),
		@rate				money,
		@amount			money,
		@amount0			money,
		@posted			money,
		@arr				datetime,
		@dep				datetime,
		@bdate			datetime,
		@today			datetime,
		@menu				char(11),
		@remark			char(50),

		@accnt			char(10),
		@pccode			char(5),
		@paycode			char(5),
		@empno1			char(10),

		@ret				integer,
		@msg				char(50),
		@set				char(11),
		@value			char(1)

select @ret = 0
select @bdate = bdate from sysdata 
select @today = getdate() from sysdata
select @value = value from sysoption where catalog = 'spo' and item = 'post_detail'
if @@rowcount = 0 
	insert sysoption select 'spo','post_detail','F','会费分摊是否需要转明细账'

begin tran
save tran p_package_s

select @class = class,@rate = rate,@amount = amount,@posted = posted,@arr = arr,@dep = dep,@paycode=paycode,@empno1 = empno,
	@accnt = accnt,@pccode = pccode from sp_viptax where rtrim(no) = rtrim(@no) and rtrim(packcode) = rtrim(@packcode)
	and inumber = @inumber and bdate < @bdate and posted < amount and halt = 'F' and arr <= @bdate

if @accnt = '' or @accnt is null
	begin
	select @ret = 1 ,@msg = '账号不能为空'
	goto loop
	end
if @pccode = '' or @pccode is null
	begin
	select @ret = 1 ,@msg = '费用码不能为空'
	goto loop
	end
//--总费用先入账
//if not exists(select 1 from sp_tax where no = @no and packcode = @packcode and inumber = @inumber and audit = 'T')
//	begin
//	select @set = 'A' + @no,@msg = @no
//	exec @ret = p_gl_accnt_posting @set, '02', @pc_id,3, @shift, @empno1, @accnt,0, @paycode, '98',1, @amount,0,0,0,0,0,@no,@no, @today, '', '', 'IR', 0, '', @msg out
//	if @ret = 0 
//		insert sp_tax select @no,@packcode,@inumber,@accnt,@paycode,'T',getdate(),@empno
//	else
//		goto loop
//	end
//
//-------------

if @class = '0' 
	begin
	if datediff(dd,@bdate,@dep) > 0 and @posted + @rate <= @amount
		select @amount0	 = @rate
	if datediff(dd,@bdate,@dep) > 0 and @posted + @rate > @amount
		select @amount0  = @amount - @posted
	if datediff(dd,@bdate,@dep) <= 0 
		select @amount0  = @amount - @posted
	select @remark = rtrim(@no)+'-C'+@packcode
	end
if @class = '1'
	begin
	if datediff(dd,@bdate,@dep) > 0 and @posted + @rate <= @amount
		select @amount0	 = @rate
	if datediff(dd,@bdate,@dep) > 0 and @posted + @rate > @amount
		select @amount0  = @amount - @posted
	if datediff(dd,@bdate,@dep) <= 0 
		select @amount0  = @amount - @posted
	if exists(select 1 from sp_plaav where vipno = @no and packcode = @packcode and charindex(sta,'IHD') > 0 and bdate = @bdate)
		begin
		select @menu = min(menu+rtrim(convert(char,inumber))) from sp_plaav where vipno = @no and packcode = @packcode and charindex(sta,'IHD') > 0 and bdate=@bdate
		select @remark = rtrim(@no)+'-M'+@packcode+'-'+@menu
		end
	else
		select @amount0 = 0
	end
if @class = '2'
	begin
	select @amount0  = @amount
	select @remark = rtrim(@no)+'-D'+@packcode
	end
if @amount0 > 0
	begin
	select @amount0 = round(@amount0,2)
	if @value = 'T'
		begin
		select @set = 'A' + @no
		exec @ret = p_gl_accnt_posting @set, '02', @pc_id,3, @shift, @empno, @accnt,0, @pccode, '',1, @amount0,0,0,0,0,0,@no,@remark, @today, '', '', 'IR', 0, '', @msg out
		end

	if @ret = 0 
		begin
		update sp_viptax set bdate = @bdate,rate0 = @amount0,posted = posted + @amount0 where no = @no and packcode = @packcode and inumber = @inumber
		if @@rowcount = 0 
			select @ret = 1
		if @ret = 0 
			begin
			delete sp_hviptax where no = @no and packcode = @packcode and inumber = @inumber and bdate = @bdate
			insert sp_hviptax select * from sp_viptax where no = @no and packcode = @packcode and inumber = @inumber
			end
		end
	end

--if not exists(select 1 from sp_viptax where bdate < @bdate and posted < amount and halt = 'F' and arr <= @bdate) and @value <> 'T'
	if not exists(select 1 from sp_viptax a,vipcard b where a.bdate < @bdate and a.posted < a.amount and a.halt = 'F' 
		and a.arr <= @bdate and a.no = b.no and b.sta = 'I') and @value <> 'T'
	begin
	select @amount0 = sum(rate0) from sp_hviptax where bdate = @bdate
	select @set = 'A' + rtrim(convert(char,datepart(yy,@bdate)))+ right('00'+rtrim(convert(char,datepart(mm,@bdate))),2) + right('00'+rtrim(convert(char,datepart(dd,@bdate))),2) 
	select @remark = rtrim(convert(char,datepart(yy,@bdate)))+ right('00'+rtrim(convert(char,datepart(mm,@bdate))),2) + right('00'+rtrim(convert(char,datepart(dd,@bdate))),2) +'会费分摊合计'
	if @amount0 > 0 
		exec @ret = p_gl_accnt_posting @set, '02', @pc_id,3, @shift, @empno, @accnt,0, @pccode, '',1, @amount0,0,0,0,0,0,@no,@remark, @today, '', '', 'IR', 0, '', @msg out
	end

loop:
if @ret <> 0
   rollback tran p_package_s
commit tran

select @ret ,@msg

;
