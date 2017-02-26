if exists (select * from sysobjects where name = 'p_hry_phone_postcharge') 
	drop proc p_hry_phone_postcharge;

create proc p_hry_phone_postcharge
	@modu_id			char(2) , 
	@pc_id			char(4) , 
	@shift			char(1) , 
	@empno			char(10) , 
	@p_extno			char(8) ,		 -- 分机号	
	@phcode			char(15),		 -- 呼叫号	
	@charge			money	,	 		 -- 金额	  
	@pccode			char(5) ,		 -- 营业点	
	@returnmode		char(1) ,		 -- 返回方式 
	@mprompt			char(10) output, 
	@msg				varchar(60) output, 
	@dialtime		datetime,
	@empty_select	char(1) --漏单处理方式的选择,1 为转入固定的消费账然后前台提醒,非1则不转,只是颜色提醒
as
---------------------------------------------------------------------------
-- 电话登帐 
--				新的帐务入账    缺少服务费数据 !!!
---------------------------------------------------------------------------

declare
	@ret				integer, 
	@p_roomnos		varchar(10),	 -- 房号串  
	@tp_extno		char(8),			 -- 临时分机
	@tp_roomno		char(5),			 -- 临时房号
	@rm_ac_type		char(1), 
	@r_a_number		char(10), 
	@accnt			char(10), 
	@sta				char(1), 
	@selemark		char(13), 
	@lastnumb		integer, 
	@inbalance		money, 
	@bdate			datetime, 
	@sucmark			char(1), 
	@tostas			varchar, 
	@market			char(3),
	@today			datetime,
	@len				char(10),
	@ref				varchar(50)		 -- 帐务备注

-- 漏单电话入账帐号
declare 	@empty_accnt	char(10)

select @empty_accnt = value from sysoption where catalog='phone' and item='empty_accnt'
if @@rowcount <> 0
begin
	if not exists(select 1 from master where accnt=@empty_accnt and sta in ('I', 'S'))
		select @empty_accnt = ''
end
else
	select @empty_accnt = ''

--
select @len = substring(@msg, 1, 10)  -- 00:00:00
select @ret = 0, @msg = '', @mprompt = '', @today=getdate()
select @selemark = 'a' + substring(@phcode+space(10),1,10), @bdate = bdate1 from sysdata
exec p_hry_phone_extno_roomno @p_extno, @p_roomnos output
select @rm_ac_type = rm_ac_type, @r_a_number = r_a_number from phspclis where room = @p_extno
if @@rowcount > 0
	begin  
	if @rm_ac_type = 'R'   -- posting to corresponding extension 
		begin  
		select @tp_extno = @r_a_number
		exec p_hry_phone_extno_roomno @tp_extno, @tp_roomno output
		select @p_roomnos = @tp_roomno+@p_roomnos
		end 
	else
		select @accnt = @r_a_number	 
	end

if @accnt is not null  --转帐帐号不空
	begin 
	begin tran
	save  tran p_hry_phone_postcharge_s1
	select @ref = '['+@p_extno+']' + @phcode
	exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id,0,@shift, @empno, @accnt,0, @pccode, '',1, @charge,@charge,0,0,0,0,@len,@ref, @today, '', '', 'IRYY', 0, '', @msg out
	if @ret <> 0
	  rollback tran p_hry_phone_postcharge_s1
	else
	  select @sucmark = 'T', @mprompt = @accnt
	commit tran
	end

if @sucmark is null 
	begin
	while datalength(@p_roomnos) > 0
		begin 
		select @tp_roomno = substring(@p_roomnos, 1, 5)
		select @p_roomnos = stuff(@p_roomnos, 1, 5, null), @sta = null
		select @sta = sta, @accnt = substring(accntset, 1, 10) from rmsta where roomno = @tp_roomno

		if rtrim(@accnt) is null and @empty_accnt <> ''  -- empty accnt
			select @accnt = @empty_accnt
		if @sta is null or rtrim(@accnt) is null 
			begin
			if @sta is null
				select @mprompt = 'NO ROOM'
			else if rtrim(@accnt) is null
				select @mprompt = 'EMPTY  '
			continue
			end
		declare @arrtime datetime

		-- 注意日期和自用房
		if @accnt <> @empty_accnt
			begin
			select @arrtime = arr, @market=market from master where accnt = @accnt
			if datediff(second, @arrtime, @dialtime)< 0 
				begin
				select @mprompt = 'EMPTY  '
				continue
				end
			else if exists(select 1 from mktcode where code=@market and flag='HSE') 
					and exists(select 1 from sysoption where catalog='phone' and item='hu_free' and rtrim(value)='T')
				begin
				select @mprompt = 'HU ROOM'
				continue
				end
			end
		
		select @ref = '['+@p_extno+']' + @phcode  -- gds

		begin tran
		save  tran p_hry_phone_postcharge_s2
		if @charge<>0
			begin
			if @accnt <> @empty_accnt
				exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id,0,@shift, @empno, @accnt,0, @pccode, '',1, @charge,@charge,0,0,0,0,@len,@ref, @today, '', '', 'IRYY', 0, '', @msg out
			else
				if @empty_select = '1' 
					exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id,0,@shift, @empno, @accnt,0, @pccode, '',1, @charge,@charge,0,0,0,0,@len,@ref, @today, '', '', 'IRYY', 0, '', @msg out
				else
					begin
					select @mprompt = 'EMPTY  '
					rollback tran p_hry_phone_postcharge_s2	-- 这里不能漏掉,否则容易死锁.--- 任何事务必须提交 simon 2005.3.11
					commit tran
					continue
					end
			end
		if @ret <> 0
			rollback tran p_hry_phone_postcharge_s2
		else
			select @sucmark = 'T', @mprompt = @accnt
		commit tran
		if @sucmark = 'T'
			break
		end
	if charindex(@sucmark, 'T') = 0
		select @mprompt = dept from phdeptroom where room = @p_extno
	end

if @returnmode = 'S'
	select @ret, @msg
return @ret
;
