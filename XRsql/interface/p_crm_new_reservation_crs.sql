
if exists(select * from sysobjects where name = "p_crm_new_reservation_crs")
   drop proc p_crm_new_reservation_crs
;
create proc p_crm_new_reservation_crs
	@cardno			varchar(20),		-- 会员卡号
	@hotelid			varchar(20),		-- 酒店
	@arr				datetime,			-- 入住日期
	@night			int,					-- 入住天数
	@type				char(3),				-- 房型
	@rmnum			int,					-- 房间数
	@caccnt			char(10),			-- 成员饭店预订帐号
	@retmode			char(1) = 'S',
	@ret				int				output,				
	@msg				varchar(60)		output	-- 
as
------------------------------------------------------------------------------
--	金陵集团预订中心 - 呼叫中心接口
--
-- 	新建预订
--名称		：p_crm_new_reservation_crs
--输入参数	：会员卡号，入住日期，入住天数，房间数，酒店，房型
--输出参数	：成功标志(0-成功，1-失败), 预订帐号（=网络预订号）
------------------------------------------------------------------------------
declare 	@accnt			char(10),
			@empno			char(10),
			@resno			char(10),
			@dep 				datetime, 
			@changed 		datetime,
			@ratecode		char(10),
			@package			char(30),
			@src				char(3),
			@mkt				char(3),
			@qtrate			money,
			@rate				money,
			@card_type		char(3),
			@guestcard		char(10),
			@hno				char(7),
			@cno				char(7),
			@bdate			datetime


select @ret=0, @msg='', @changed=getdate(), @bdate=bdate1 from sysdata

---------------------------------------------------
--	条件处理，同时取得 mkt,src,ratecode......
---------------------------------------------------
-- 条件 - cardno
select @card_type=type, @hno=hno, @cno=cno from vipcard where no=@cardno
if @@rowcount = 0
begin
	select @ret=1, @msg='Cardno error'
	goto gout
end
else 
begin
	if rtrim(@hno) is null -- Only for guest card, not for company card !
	begin
		select @ret=1, @msg='Please use guest card'
		goto gout
	end

	select @guestcard = guestcard from vipcard_type where code=@card_type
	if not exists(select 1 from guest_card_type a where a.code=@guestcard and (a.flag='POINT' or a.flag='FOX'))
	begin
		select @ret=1, @msg='Card type error'
		goto gout
	end

	select @mkt=market, @src=src from guest where no=@hno
	if @@rowcount = 0
	begin
		select @ret=1, @msg='Profile is not exists.'
		goto gout
	end
	if rtrim(@cno) is not null
		select @ratecode = isnull((select min(value) from guest_extra where no=@cno and item='ratecode'), '')
	if rtrim(@ratecode) is null
		select @ratecode = isnull((select min(value) from guest_extra where no=@hno and item='ratecode'), '')
	if rtrim(@ratecode) is null
		select @ratecode = isnull((select min(code) from rmratecode where halt='F' and private='F'), '')
	select @package = packages from rmratecode where code=@ratecode 
	if rtrim(@mkt) is null
		select @mkt=market, @src=src from rmratecode where code=@ratecode
end

-- 条件 - hotelid
if rtrim(@hotelid) is null or not exists(select 1 from hotelinfo where hotelid=@hotelid)
begin
	select @ret=1, @msg='Hotelid error'
	goto gout
end

-- 条件 - arr
if @arr is null or datediff(dd,getdate(),@arr)<0
begin
	select @ret=1, @msg='Arr error'
	goto gout
end

-- 条件 - night
if @night < 1 
begin
	select @ret=1, @msg='Nights error'
	goto gout
end
select @dep=dateadd(dd, @night, @arr) 
select @dep=convert(datetime,convert(char(8),@dep,1))

-- 条件 - type
//if rtrim(@type) is null or not exists(select 1 from typim where type=@type)
//begin
//	select @ret=1, @msg='Room type error'
//	goto gout
//end
//else
//	select @qtrate = rate from typim where type=@type
	select @qtrate = 0


-- 条件 - rmnum
if @rmnum<=0 and @rmnum>1000
	select @rmnum = 1

--------------------------------------
--	房价
--------------------------------------
//exec @ret = p_gds_get_rmrate @arr, @night, @type, '', @rmnum, 1, @ratecode, '', 'R', @rate output, @msg output
//if @ret <> 0
//begin
//	select @ret=1, @msg='Get rate error'
//	goto gout
//end
select @rate = 0

--------------------------------------
--	一些缺省参数
--------------------------------------
select @empno = isnull((select value from sysoption where catalog='' and item=''), 'FOX')  -- 网上预订工号

begin tran 
save tran p_mst_s1 

----------------------------------------------------------------------------
--	帐号/预订号 生成  -- 这里的预订号可以考虑做一些变化，用来区别
----------------------------------------------------------------------------
exec p_GetAccnt1 'FIT', @accnt output
exec p_GetAccnt1 'RES', @resno output

--------------------------------------
--	预订单生成
--------------------------------------
INSERT master (accnt, haccnt, type, rmnum, ormnum, roomno, bdate, sta, arr, dep, class, src, market, restype, channel, 
		share, gstno, children, ratecode, packages, rmrate, qtrate, setrate, rtreason, discount, discount1,  
		extra, resno, resby, restime, cby, changed, cardcode, cardno ) 
	VALUES ( @accnt, @hno, @type, @rmnum, 0, '', @bdate, 'R', @arr, @dep, 'F', @src, @mkt, '', '', 
		'F', 1, 0, @ratecode, @package, @rate, @qtrate, @rate, '', 0, 0,  
		'000001000100000', @resno, @empno, @changed, @empno, @changed, @guestcard, @cardno )
if @@rowcount = 0 
	select @ret = 1, @msg = '主单信息插入失败' 

-- 
if @ret = 0 
   begin    
	insert master_hotel(accnt,hotelid,accnt0,sync,empno,lastdate)
		select @accnt, @hotelid, @caccnt, 'F', @empno, getdate()
   if @ret = 0 
      update master set logmark = logmark + 1 where accnt = @accnt 
   end     
else
   rollback tran p_mst_s1 
commit tran 

--------------------------------------
--	输出
--------------------------------------
gout:
if @ret = 0
	select @msg = @accnt
if @retmode = 'S'
	select @ret, @msg
return @ret
;
