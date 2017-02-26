if exists (select * from sysobjects where name = 'p_hry_phone_xbsuggest_iddcall')
	drop proc p_hry_phone_xbsuggest_iddcall
;
create proc p_hry_phone_xbsuggest_iddcall
	@pc_id		char(4), 
	@modu_id		char(2),		 
	@shift		char(1), 
	@empno		char(10), 
	@p_extno		char(8),			-- �ֻ���	 
	@phcode		char(20),		-- ���к���	
	@longcall	char(1),			-- �˹�����? 'T' Ϊ�� 
	@inputfee	money	,			-- �˹���������Ա�����ֵ 
	@start		datetime,		-- ��ͨʱ�� 
	@sndnum		integer,			-- ͨ������(��) 
	@trunk		char(3),			-- �м���
	@returnmode char(1),			-- ���ط�ʽ 
	@fee			money	out,		-- �ܻ���	
	@fee_serve	money	out,		-- �����	
	@fee_dial	money	out,		-- ���ŷ�	
	@fee_cancel money	out,		-- ���ŷ�, �����ڼ�¼���Լ��㻰���뻰��Ա������Ĳ��
	@empty_select char(1),		--©���绰�Ĵ���1,ת���������˷�1��ת
	@id			integer out, 
	@msg			varchar(60) output
as
-- -------------------------------------------------------------------------------------
--	�޸�:	1.�������ĵĺ����м��Ϸֻ��� !!!
--			2.�ж��������ķֻ� ���еط���Ҫ�� #???# !!!
--			4.������ ͳһ ��ȡ 2000/04/02	p_gds_phone_pccode
--			5.p_hry_bus_put_iddcall - phone�ֻ�
--
--	���� : 
--		���Ҫ��<ҹ����˱���>��ӳ�绰�Ļ�����[����]�ͷ����[����], 
--		��Ҫ�ڷ�����ķ������зֿ�, ����ǰ̨����̫��, 
--		���, �ڸ����� packet ��ʵ��!!!
-- -------------------------------------------------------------------------------------

declare
	@ret			integer, 
	@calltype	char(1),				-- ���
	@address		char(14),			-- ���к����Ӧ��ַ
	@fee_base	money,				-- ��������
	@mprompt		char(10),			-- ��������
	@pccode		char(5), 
	@time			char(8)

select @p_extno = ltrim(@p_extno)
exec p_hry_phone_snd_time @sndnum, @time output

-- 1. �㻰��, ���ر���Ĳ��� 
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

if exists(select 1 from bos_extno where code = @p_extno)  -- ��������
	begin
	exec @ret = p_gds_phone_pccode @p_extno, 'BS', @phcode, @calltype, @pccode output
	if @ret <> 0
		begin
		select @ret = 1, @msg = '��������ȡ���� !'
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
		select @ret = 1, @msg = '��������ȡ���� !'
		if @returnmode = 'S'
			select @ret, @msg, @fee, @fee_serve, @fee_dial, @fee_cancel, @id, @address
		return @ret
		end
	select @fee_base = @fee - @fee_serve - @fee_dial - @fee_cancel
	end
	 
-- 2. �ǿ���, ���ؼ����ʺ�, �����������ķֻ�ֻΪ�˴���mprompt 
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

-- 3. ���뵽phfolio 
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

