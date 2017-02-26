IF OBJECT_ID('dbo.p_hry_phone_iddcall') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_hry_phone_iddcall
END;
create proc p_hry_phone_iddcall
	@modu_id			char(2),
	@pc_id			char(4),
	@shift			char(1),
	@empno			char(3),
	@p_extno			char(8),
	@phcode			char(20),
	@longcall		char(1),
	@inputfee		money,
	@start			datetime,
	@sndnum			integer,
	@trunk			char(3),
	@returnmode		char(1),
	@msg				varchar(60) output

as

declare
	@ret				integer,
	@calltype		char(1),
	@address			char(14),
	@fee_base		money,
	@fee				money,
	@fee_serve		money,
	@fee_dial		money,
	@fee_cancel		money,
	@mprompt			char(7),
   @zid       int,
	@pccode			varchar(3),
	@id				integer,
	@time				char(8),
   @feebase    money

select @p_extno = ltrim(@p_extno)


--exec @ret = p_hry_phone_calculate_fee
	--@pc_id, @modu_id, @p_extno, @phcode, @start, @sndnum, 'R',
	--@calltype output, @address output, @fee output,
	--@fee_serve output, @fee_dial output, @msg output
select @zid=max(inumber) from phfolio
select @calltype=calltype,@address=address,@fee=fee,@feebase=fee_serve -fee_base from phfolio where inumber=@zid
select @msg=''
select @fee_dial=0
if @longcall = 'T'
	begin
	select @fee_cancel = @inputfee - @fee
	select @fee			 =  @fee_cancel + @fee
	end
else
	select @fee_cancel = 0

if @ret <> 0
	begin
	if @returnmode = 'S'
		select @ret, @msg
	return @ret
	end

if exists(select 1 from bos_extno where code = @p_extno)
	begin
	exec @ret = p_gds_phone_pccode @p_extno, 'BS', @phcode, @calltype, @pccode output
	if @ret <> 0
		begin
		select @ret = 1, @msg = '费用码提取错误 !'
		if @returnmode = 'S'
			select @ret, @msg
		return @ret
		end
	select @pccode = @pccode + 'A'
	select @modu_id = '06', @fee_base = @fee - @fee_serve - @fee_dial - @fee_cancel
	select @fee_serve = @fee_serve + @fee_dial + @fee_cancel
	end
else
	begin
	exec @ret = p_gds_phone_pccode @p_extno, 'RM', @phcode, @calltype, @pccode output
	if @ret <> 0
		begin
		select @ret = 1, @msg = '费用码提取错误 !'
		if @returnmode = 'S'
			select @ret, @msg
		return @ret
		end
	select @pccode = @pccode + 'A'
	select @fee_base = @fee - @fee_serve - @fee_dial - @fee_cancel
	end


if substring(@msg, 1, 4) <> 'FREE' and substring(@msg, 1, 7) <> 'NO CODE' and substring(@msg, 1, 7) <> 'NOCLASS'
	exec @ret = p_hry_phone_postcharge
		@modu_id, @pc_id, @shift, @empno, @p_extno, @phcode, @fee, @pccode,
		'R', @mprompt output, @msg output, @start
else
	select @mprompt = @msg
if @ret <> 0
	begin
	if @returnmode = 'S'
		select @ret, @msg
	return @ret
	end

select @id = isnull(max(inumber), 0) from phfolio
select @id = @id + 1
--exec p_hry_phone_snd_time @sndnum, @time output
insert phfolio
	(inumber, date, room, length, empno, phcode, calltype,
	fee, fee_base,  fee_serve,  refer, address)
	values (@id, @start, @p_extno, @sndnum, @empno, @phcode, @calltype,
	@fee, @fee_base,  @fee_serve, @mprompt, @address)

if exists(select 1 from bos_extno where code = @p_extno) and (substring(@msg, 1, 7) <> 'NO CODE' and substring(@msg, 1, 7) <> 'NOCLASS')
	begin
	exec @ret = p_hry_bus_put_iddcall
		@modu_id, @pc_id, @shift, @empno, @p_extno, @pccode, @phcode, @address, @start,
		@time, @fee_base, @fee_serve, @phcode, 'R', @msg output
	end
if @ret = 0
	select @msg = @mprompt + @msg
if @returnmode  = 'S'
	select @ret, @msg
return @ret
;