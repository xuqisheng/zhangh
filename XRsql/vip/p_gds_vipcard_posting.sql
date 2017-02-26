if exists(select * from sysobjects where name = 'p_gds_vipcard_posting' and type ='P')
	drop proc p_gds_vipcard_posting;
create proc p_gds_vipcard_posting
	@selemark			char(27) = 'A',
	@modu_id				char(2),
	@pc_id				char(4),
	@mdi_id				integer,
	@shift				char(1),
	@empno				char(10),
	@no					char(20),
	@hotelid				varchar(20),
	@bdate				datetime,
	@mode					char(1),
	@m1					money,	-- 房费 / 消费金额
	@m2					money,	-- 餐费 / 成本价
	@m3					money,	-- 其他 / 兑换比率
	@m4					money,
	@m5					money,
	@m9					money,	-- 累加积分 / 消费积分
	@calc					char(10),
	@fo_accnt			char(10),
	@ref					char(24),
	@ref1					char(10),
	@ref2					char(50),
	@retmode				char(1)='S',
	@ret					int				output,
	@msg					varchar(60) 	output
as

----------------------------------------------------------------
-- 积分入账 - 包括累计与消耗
--
--		@mode = + 累计  --> 累加到 credit
--		@mode = - 消耗  --> 消耗在 charge
----------------------------------------------------------------

declare
	@log_date			datetime,
	@lastnumb			int,
	@balance				money,
	@expiry_date		datetime,		-- 积分有效期
	@charge				money,
	@credit				money,
	@value				money,
	@viplimit			money,
	@sendout				char(1),
	@fo_number			integer,  	-- 含义改变了 - 中央的帐次
	@fo_billno			char(10),	-- 含义改变了 - 本地入帐的 pcid
	@sta					char(1)

--
select @ret=0, @msg=''
select @no = isnull(rtrim(@no), ''), @calc = isnull(rtrim(@calc), ''), @mode = isnull(rtrim(@mode), '+')
select @m1=isnull(@m1, 0), @m2=isnull(@m2, 0), @m3=isnull(@m3, 0), @m4=isnull(@m4, 0), @m5=isnull(@m5, 0), @m9=isnull(@m9, 0)
select @fo_number = 0, @fo_billno=@pc_id
--
select @log_date = getdate()
if @bdate is null
	select @bdate = bdate1 from sysdata
if rtrim(@hotelid) is null
	select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
select @expiry_date = convert(datetime, '2018/1/1')
select @ref = isnull(rtrim(@ref), '')
select @ref1 = isnull(rtrim(@ref1), '')
select @ref2 = isnull(rtrim(@ref2), '')

--如果该卡挂失并重新发行新卡，则积分应算到新卡上 yb 2005.12.21
declare @new_no char(20)
if exists(select 1 from vipcard where no=@no and charindex('>>',exp_s8) > 0)
begin
select @new_no=substring(exp_s8,charindex('>>',exp_s8)+2,20) from vipcard where no=@no
if exists(select 1 from vipcard where no=@no)
	select @no=@new_no
end


-- Send out flag  --- 由于系统总是先扣除中央，然后扣除本地，因此，这个过程执行的时候，
--                    如果是首次入账操作，sendout一定为T,撤销结账的时候，才需要判断；
if rtrim(@selemark) is null select @selemark=''
if @selemark = 'D'   -- 表示撤销反扣
begin
	if @mode = '+'
		select @m1=-1*@m1,@m2=-1*@m2,@m3=-1*@m3,@m4=-1*@m4,@m5=-1*@m5,@m9=-1*@m9
	else
		select @m1=-1*@m1,@m2=-1*@m2,@m3=+1*@m3,@m4=-1*@m4,@m5=-1*@m5,@m9=-1*@m9

	--
	if exists(select 1 from sysoption where catalog = "hotel" and item = "hotelid" and ltrim(rtrim(value))='crs')
			or exists(select 1 from vipcard a, vipcard_type b where a.no=@no and a.type=b.code and b.center='F') or @modu_id= '04' --add by yb 2005.12.21
		select @sendout = 'T'
	else
		select @sendout = 'F'
end
else
begin
	select @sendout = 'T'
end

--
if @m9 <> 0 -- 积分不用重新计算
	select @value = @m9
else
begin
	exec @ret = p_gds_vipcard_calc @mode, @no, @calc, @m1, @m2, @m3, @m4, @m5, 'R', @msg output, @value output
	if @ret <> 0
		goto gout
end

--
if @mode = '+'
	select @charge=0, @credit=@value, @m9=@m1+@m2+@m3+@m4+@m5
else
	select @charge=round(@value,1), @credit=0, @m9=@value  -- 这里的 m9 表示消耗的积分

--
select @sta=sta from vipcard where no = @no
if @@rowcount=0
begin
	select @lastnumb = - count(1) from vippoint where no = @no
	select @balance = 0
	select @ret=1, @msg='The Vipcard is not exists --- %1^' + @no
end
else if charindex(@sta, 'TDX')>0
begin
	select @lastnumb = - count(1) from vippoint where no = @no
	select @balance = 0
	select @ret=1, @msg='The Vipcard is not in valid status'
end
else
begin
	begin tran
	save tran aaaa

	update vipcard set lastnumb = lastnumb + 1, credit = credit + @credit, charge = charge + @charge where no = @no
	if @@rowcount <> 1
		select @ret=1, @msg='Update error - vippoint'
	else
	begin
		select @lastnumb = lastnumb, @viplimit=limit, @balance = credit - charge from vipcard where no = @no  -- 注意 balance 计算
		if @viplimit+@balance < 0 and @modu_id <> '00' and @ref1<>'Audit'   --夜审上传积分允许为负     yb 2005.12.21
			select @ret = 1, @msg = '贵宾卡号积分不足'
		else
		begin
			insert vippoint (no, number, hotelid, log_date, bdate, expiry_date, quantity, charge, credit, balance,
					fo_modu_id, fo_accnt, fo_number, fo_billno, shift, empno, tag, ref, ref1, ref2,
					m1,m2,m3,m4,m5,m9,calc,sendout,exp_dt1,mode1)    -- xia add mode1 值必须赋值@mode ,+ 累加，- 冲减  20080702
				values(@no, @lastnumb, @hotelid, @log_date, @bdate, @expiry_date, 0, @charge, @credit, @balance,
					@modu_id, @fo_accnt, @fo_number, @fo_billno, @shift, @empno, '', @ref, @ref1, @ref2,
					@m1,@m2,@m3,@m4,@m5,@m9,@calc,@sendout,@bdate,@mode) -- add by yb 2005.12.21
			if @@rowcount <> 1
				select @ret=1, @msg='Insert error - vippoint'
		end
	end

	if @ret<> 0
		rollback tran aaaa
	commit tran

end

gout:
if @ret = 0
	select @msg = convert(char(10), @lastnumb)
--
if @retmode = 'S'
	select @ret, @msg
return @ret
;

