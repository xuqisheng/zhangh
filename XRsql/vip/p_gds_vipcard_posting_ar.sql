if exists(select * from sysobjects where name = 'p_gds_vipcard_posting_ar' and type ='P')
	drop proc p_gds_vipcard_posting_ar;
create proc p_gds_vipcard_posting_ar
	@selemark			char(27) = 'A',
	@modu_id				char(2), 
	@pc_id				char(4), 
	@mdi_id				integer, 
	@shift				char(1), 
	@empno				char(10), 
	@no					char(20), 		-- 卡号
	@arno					char(10), 		-- AR账号
	@hotelid				varchar(20),	
	@bdate				datetime,
	@amount				money,
	@fo_accnt			char(10),
	@ref					char(24),
	@ref1					char(10),
	@ref2					char(50),
	@retmode				char(1)='S',
	@ret					int				output,
	@msg					varchar(60) 	output
as

----------------------------------------------------------------
-- 中央储值卡入账
----------------------------------------------------------------
declare	@operation		char(5),
			@subaccnt		int,
			@pccode			char(5),
			@argcode			char(3),
			@to_accnt		char(10),
			@hotels			varchar(64)

select @pccode='88888'   -- 费用码固定的
-- 
if not exists(select 1 from sysoption where catalog = "hotel" and item = "hotelid" and ltrim(rtrim(value))='crs')
begin
	select @ret=1, @msg='只有中央系统才能执行该过程'
	if @retmode = 'S'
		select @ret, @msg
	return @ret
end
if not exists(select 1 from pccode where pccode=@pccode)
begin
	select @ret=1, @msg='中央系统没有定义 - 成员酒店消费记账 - 费用码'
	if @retmode = 'S'
		select @ret, @msg
	return @ret
end

--
select @ret=0, @msg=''
select @hotelid = isnull(rtrim(@hotelid), ''), @no = isnull(rtrim(@no), ''), @arno = isnull(rtrim(@arno), ''), @fo_accnt = isnull(rtrim(@fo_accnt), '')
select @ref = isnull(rtrim(@ref), ''), @ref1 = isnull(rtrim(@ref1), ''),  @ref2 = isnull(rtrim(@ref2), '')
if @bdate is null
	select @bdate = bdate1 from sysdata

--
if @no='' or not exists(select 1 from vipcard where no = @no)
begin
	select @ret=1, @msg='The Vipcard is not exists --- %1^' + @no
	if @retmode = 'S'
		select @ret, @msg
	return @ret
end
if @arno='' or not exists(select 1 from master where accnt = @arno and sta='I' and class='A')
begin
	select @ret=1, @msg='The Vipcard AR acct# is not exists --- %1^' + @arno
	if @retmode = 'S'
		select @ret, @msg
	return @ret
end
if @amount=0 
begin
	select @ret=1, @msg='The posting amout can not be zero'
	if @retmode = 'S'
		select @ret, @msg
	return @ret
end
if rtrim(@hotelid) is null
begin
	select @ret=1, @msg='The hotel ID can not be NULL'
	if @retmode = 'S'
		select @ret, @msg
	return @ret
end
select @hotels=exp_s6 from vipcard where no=@no
if @hotels<>'' and charindex(rtrim(@hotelid), @hotels)=0
begin
	select @ret=1, @msg='The Card can not posting to this hotel'
	if @retmode = 'S'
		select @ret, @msg
	return @ret
end

--
if substring(@selemark,1,1)='D' 
begin
	select @amount = @amount * -1
end

--
select @selemark = 'A' + substring(@hotelid,1,10)
-- select @modu_id = '99',@mdi_id=0
select @subaccnt=0,@operation='IRYY'
select @argcode=argcode from pccode where pccode=@pccode

begin tran
save tran aaaa

exec @ret = p_gl_accnt_posting @selemark,@modu_id,@pc_id,@mdi_id,@shift,@empno,@arno,@subaccnt,
	@pccode,@argcode,1,@amount,@amount,0,0,0,0,@ref1,@ref2,@bdate,'','',@operation,0,@to_accnt output, @msg output

if @ret<> 0
	rollback tran aaaa
commit tran 

gout:
--
if @retmode = 'S'
	select @ret, @msg
return @ret
;
