
if exists(select * from sysobjects where name = "p_crm_modify_reservation_crs")
   drop proc p_crm_modify_reservation_crs
;
create proc p_crm_modify_reservation_crs
	@cardno			varchar(20),		-- 会员卡号
	@hotelid			varchar(20),		-- 酒店
	@accnt			char(10),			-- 预订号
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
--4.	修改预订：根据会员卡号和预订号取消预订；根据会员卡号取消所有预订
-- 	修改预订SP：
--名称：p_crm_modify_reservation_crs
--输入参数：会员卡号，预订号，入住日期，入住天数，房间数，酒店，房型
--输出参数：成功标志(0-成功，1-失败)
------------------------------------------------------------------------------
declare 	@cardno0			varchar(20),
			@hotelid0		varchar(20),
			@arr0				datetime,
			@dep0				datetime,
			@type0			char(3),
			@rmnum0			int,

			@sta				char(1),
			@empno			char(10),
			@dep 				datetime, 
			@changed 		datetime,
			@ratecode		char(10),
			@package			char(30),
			@src				char(3),
			@mkt				char(3),
			@qtrate			money,
			@rate				money,
			@bdate			datetime


select @ret=0, @msg='', @changed=getdate(), @bdate=bdate1 from sysdata

---------------------------------------------------
--	条件处理
---------------------------------------------------
if not exists(select 1 from master_hotel where accnt=@accnt and accnt0=@caccnt )
begin
	select @ret=1, @msg='Parameters Error'
	goto gout
end
-- 条件 - accnt, cardno
select @cardno0 = cardno, @sta=sta, @qtrate=qtrate, @rate=setrate,
	@arr0=arr, @dep0=dep, @type0=type, @rmnum0=rmnum from master where accnt=@accnt and class='F'
if @@rowcount = 0
begin
	select @ret=1, @msg='No record'
	goto gout
end
if @cardno <> @cardno0 
if @@rowcount = 0
begin
	select @ret=1, @msg='Error !  Reservation has a different cardno'
	goto gout
end
if @sta <> 'R'
begin
	select @ret = 1
	if @sta = 'O' or @sta = 'D'
		select @msg = 'The reservation has been checked out'
	else if @sta = 'X'
		select @msg = 'The reservation has been canceled'
	else if @sta = 'N'
		select @msg = 'The reservation has been No-showed'
	else
		select @msg = 'The reservation is not a valid one'
	goto gout
end

-- 条件 - hotelid
//if rtrim(@hotelid) is not null
//begin
//	if not exists(select 1 from sysoption where catalog='hotel' and item='hotelid' and value=@hotelid)
//	begin
//		select @ret=1, @msg='Hotelid error'
//		goto gout
//	end
//end

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

//-- 条件 - type
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
select @dep=dateadd(dd, @rmnum, @arr) 

--------------------------------------
--	变化比较
--------------------------------------
if @arr=@arr0 and @dep=@dep0 and @type=@type0 and @rmnum=@rmnum0
begin
	select @ret=1, @msg='Not change anything'
	goto gout
end

--------------------------------------
--	房价
--------------------------------------
//if @arr<>@arr0 or @type<>@type0
//begin
//	exec @ret = p_gds_get_rmrate @arr, @night, @type, '', @rmnum, 1, @ratecode, '', 'R', @rate output, @msg output
//	if @ret <> 0
//	begin
//		select @ret=1, @msg='Get rate error'
//		goto gout
//	end
//end

--------------------------------------
--	一些缺省参数
--------------------------------------
select @empno = isnull((select value from sysoption where catalog='' and item=''), 'FOX')  -- 网上预订工号

begin tran 
save tran p_mst_s1 

--------------------------------------
--	预订单修改
--------------------------------------
update master set arr=@arr, dep=@dep, type=@type, rmnum=@rmnum, qtrate=@qtrate, rmrate=@rate, setrate=@rate,
		cby=@empno, changed=@changed where accnt=@accnt
if @@rowcount = 0 
	select @ret = 1, @msg = '主单信息更新失败' 

-- 
if @ret = 0 
   begin    
//   exec @ret = p_gds_reserve_chktprm @accnt,'0','',@empno,'U',1,1,@msg output 
//   if @ret = 0 
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
