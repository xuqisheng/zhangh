if exists (select * from sysobjects where name = 'p_hry_phone_xbsuggest_iddcall')
	drop proc p_hry_phone_xbsuggest_iddcall
;
create proc p_hry_phone_xbsuggest_iddcall
	@pc_id		char(4), 
	@modu_id		char(2),		 
	@shift		char(1), 
	@empno		char(10), 
	@p_extno		char(8),			-- 分机号	 
	@phcode		char(20),		-- 呼叫号码	
	@longcall	char(1),			-- 人工长话? 'T' 为是 
	@inputfee	money	,			-- 人工长话话务员输入的值 
	@start		datetime,		-- 拨通时间 
	@sndnum		integer,			-- 通话长度(秒) 
	@trunk		char(3),			-- 中继线
	@returnmode char(1),			-- 返回方式 
	@fee			money	out,		-- 总话价	
	@fee_serve	money	out,		-- 服务费	
	@fee_dial	money	out,		-- 拨号费	
	@fee_cancel money	out,		-- 销号费, 现用于记录电脑计算话价与话务员输入金额的差价
	@empty_select char(1),		--漏单电话的处理1,转如入消费账非1则不转
	@id			integer out, 
	@msg			varchar(60) output
as
-- -------------------------------------------------------------------------------------
--	修改:	1.商务中心的号码中加上分机号 !!!
--			2.判断商务中心分机 所有地方都要加 #???# !!!
--			4.费用码 统一 提取 2000/04/02	p_gds_phone_pccode
--			5.p_hry_bus_put_iddcall - phone分机
--
--	考虑 : 
--		如果要在<夜间稽核报表>反映电话的基本费[代收]和服务费[收入], 
--		就要在费用码的服务马中分开, 这样前台帐务太多, 
--		因此, 在高亮的 packet 中实现!!!
-- -------------------------------------------------------------------------------------

declare
	@ret			integer, 
	@calltype	char(1),				-- 类别
	@address		char(14),			-- 呼叫号码对应地址
	@fee_base	money,				-- 基本话价
	@mprompt		char(10),			-- 记帐索引
	@pccode		char(5), 
	@time			char(8)

select @p_extno = ltrim(@p_extno)
exec p_hry_phone_snd_time @sndnum, @time output

-- 1. 算话价, 传回必需的参数 
exec @ret = p_hry_phone_calculate_fee
	@pc_id, @modu_id, @p_extno, @phcode, @start, @sndnum, 'R', 
	@calltype output, @address output, @fee output, 
	@fee_serve output, @fee_dial output, @msg output
if @longcall = 'T'
	select @fee_cancel = @inputfee - @fee, @fee = @inputfee 
else
	select @fee_cancel = 0
	
if @ret <> 0
	begin
	if @returnmode = 'S'
		select @ret, @msg, @fee, @fee_serve, @fee_dial, @fee_cancel, @id, @address
	return @ret	
	end

if exists(select 1 from bos_extno where code = @p_extno)  -- 商务中心
	begin
	exec @ret = p_gds_phone_pccode @p_extno, 'BS', @phcode, @calltype, @pccode output
	if @ret <> 0
		begin
		select @ret = 1, @msg = '费用码提取错误 !'
		if @returnmode = 'S'
			select @ret, @msg, @fee, @fee_serve, @fee_dial, @fee_cancel, @id, @address
		return @ret
		end
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
			select @ret, @msg, @fee, @fee_serve, @fee_dial, @fee_cancel, @id, @address
		return @ret
		end
	select @fee_base = @fee - @fee_serve - @fee_dial - @fee_cancel
	end
	 
-- 2. 记客帐, 传回记帐帐号, 如是商务中心分机只为了传回mprompt 
if substring(@msg, 1, 4) <> 'FREE' and substring(@msg, 1, 7) <> 'NO CODE' and substring(@msg, 1, 7) <> 'NOCLASS' 
begin
	select @msg = @time
	exec @ret = p_hry_phone_postcharge
		@modu_id, @pc_id, @shift, @empno, @p_extno, @phcode, @fee, @pccode, 
		'R', @mprompt output, @msg output, @start,@empty_select
end
else
	select @mprompt = @msg 
if @ret <> 0
	begin
	if @returnmode = 'S'
		select @ret, @msg, @fee, @fee_serve, @fee_dial, @fee_cancel, @id, @address
	return @ret
	end

-- 3. 记入到phfolio 
select @id = isnull((select max(inumber) from phfolio), 0)
select @id = @id + 1
insert phfolio(inumber, date, room, length, empno, shift, phcode, calltype, 
		fee, fee_base, fee_dial, fee_serve, fee_cancel, trunk, refer, address)
	values (@id, @start, @p_extno, @time, @empno, @shift, @phcode, @calltype, 
		@fee, @fee_base, @fee_dial, @fee_serve, @fee_cancel, @trunk, @mprompt, @address)

-- 4. business
if exists(select 1 from bos_extno where code = @p_extno) and substring(@msg, 1, 7) <> 'NO CODE' 
	and substring(@msg, 1, 7) <> 'NOCLASS' and substring(@msg, 1, 4) <> 'FREE'
	begin
	exec @ret = p_hry_bus_put_iddcall
		@modu_id, @pc_id, @shift, @empno, @p_extno, @pccode, @phcode, @address, @start, 
		@time, @fee_base, @fee_serve, @phcode, 'R', @msg output
	end

-- 
if exists (select 1 from phinumber where pc_id = @pc_id)
	update phinumber set inumber = @id where pc_id = @pc_id
else
	insert phinumber values (@pc_id, @id)

if @ret = 0
	select @msg = @mprompt + @msg
if @returnmode  = 'S'
	select @ret, @msg, @fee, @fee_serve, @fee_dial, @fee_cancel, @id, @address

return @ret
;

