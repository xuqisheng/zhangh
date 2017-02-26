if exists(select * from sysobjects where name = 'p_gds_vipcard_point_transfer' and type ='P')
	drop proc p_gds_vipcard_point_transfer;
create proc p_gds_vipcard_point_transfer
	@no1					char(20), 
	@no2					char(20), 
	@point				money,
	@ref					char(50),
	@shift				char(1),
	@empno				char(10),
	@retmode				char(1)='S',
	@ret					int		output,
	@msg					varchar(60) output
as

----------------------------------------------------------------
-- 积分转移
----------------------------------------------------------------

declare
	@log_date			datetime,
	@bdate				datetime,
	@vipnumber			int,
	@vipbalance			money,
	@expiry_date		datetime,		-- 积分有效期
	@charge				money,
	@credit				money,
	@viplimit			money,
	@sta					char(1)

--
select @ret=0, @msg='', @point=isnull(@point, 0), @log_date=getdate()
select @no1 = isnull(rtrim(@no1), ''), @no2 = isnull(rtrim(@no2), ''), @ref = isnull(rtrim(@ref), ''), @empno = isnull(rtrim(@empno), '')
if @no1='' or @no2='' or @point<=0 
begin
	select @ret=1, @msg='Parms error'
	return @ret 
end

-- 
if @no1 = @no2
begin
	select @ret=1, @msg='Point can not transfer to itself.'
	if @retmode = 'S'
		select @ret, @msg
	return @ret 
end

---- no1 
select @sta=sta, @charge=charge, @credit=credit, @viplimit=limit from vipcard where no = @no1
if @@rowcount=0 
begin
	select @ret=1, @msg='Card1 is not exists'
	if @retmode = 'S'
		select @ret, @msg
	return @ret 
end
else if @sta <> 'I' 
begin
	select @ret=1, @msg='Card1 is not in use, status error.'
	if @retmode = 'S'
		select @ret, @msg
	return @ret 
end
else if @credit-@charge-@point < 0 
begin
	select @ret=1, @msg='Point is not enough'
	if @retmode = 'S'
		select @ret, @msg
	return @ret 
end

-- no2
select @sta=sta from vipcard where no = @no2
if @@rowcount=0 
begin
	select @ret=1, @msg='Card2 is not exists'
	if @retmode = 'S'
		select @ret, @msg
	return @ret 
end
else if @sta <> 'I' 
begin
	select @ret=1, @msg='Card2 is not in use, status error.'
	if @retmode = 'S'
		select @ret, @msg
	return @ret 
end

select @expiry_date = dateadd(year, 10, convert(datetime, convert(char(10), getdate(), 111)))
--
begin tran 
save tran aaaa

select @bdate = bdate1 from sysdata
select @point = @point * -1
update vipcard set lastnumb = lastnumb + 1, credit = credit + @point where no = @no1
if @@rowcount <> 1 
begin
	select @ret=1, @msg='Update error - vippoint'
	goto gout
end
select @vipnumber = lastnumb, @viplimit=limit, @vipbalance = credit - charge from vipcard where no = @no1
begin
	insert vippoint (no, number, hotelid, log_date, bdate, expiry_date, quantity, charge, credit, balance,
			fo_modu_id, fo_accnt, fo_number, fo_billno, shift, empno, tag, ref, ref1, ref2,
			m1,m2,m3,m4,m5,m9,calc,sendout)
		values(@no1, @vipnumber, 'crs', @log_date, @bdate, @expiry_date, 0, 0, @point, @vipbalance,
			'00', '', 0, '', @shift, @empno, '', @no2, 'PTS-TRAN', @ref,
			@point,0,0,0,0,@point,'-->','T')
	if @@rowcount <> 1
	begin
		select @ret=1, @msg='Insert error - vippoint'
		goto gout
	end
end

select @point = @point * -1
update vipcard set lastnumb = lastnumb + 1, credit = credit + @point where no = @no2
if @@rowcount <> 1 
begin
	select @ret=1, @msg='Update error - vippoint'
	goto gout
end
select @vipnumber = lastnumb, @viplimit=limit, @vipbalance = credit - charge from vipcard where no = @no2
begin
	insert vippoint (no, number, hotelid, log_date, bdate, expiry_date, quantity, charge, credit, balance,
			fo_modu_id, fo_accnt, fo_number, fo_billno, shift, empno, tag, ref, ref1, ref2,
			m1,m2,m3,m4,m5,m9,calc,sendout)
		values(@no2, @vipnumber, 'crs', @log_date, @bdate, @expiry_date, 0, 0, @point, @vipbalance,
			'00', '', 0, '', @shift, @empno, '', @no1,'PTS-TRAN', @ref,
			@point,0,0,0,0,@point,'<--','T')
	if @@rowcount <> 1
	begin
		select @ret=1, @msg='Insert error - vippoint'
		goto gout
	end
end

gout:
if @ret <> 0 
	rollback tran aaaa
commit tran aaaa

--
if @retmode = 'S'
	select @ret, @msg
return @ret
;
