
if exists(select * from sysobjects where name = "p_crm_cancel_reservation_crs")
   drop proc p_crm_cancel_reservation_crs
;
create proc p_crm_cancel_reservation_crs
	@cardno			varchar(20),		-- 会员卡号
	@accnt			char(10),			-- 预订号
	@caccnt			char(10),			-- 成员饭店的预订号
	@retmode			char(1) = 'S',
	@ret				int				output,				
	@msg				varchar(60)		output	-- 
as
------------------------------------------------------------------------------
--	金陵集团预订中心 - 呼叫中心接口
--
--3.	取消预订：根据会员卡号和预订号取消预订；根据会员卡号取消所有预订
-- 	取消预订SP：
--名称：p_crm_cancel_reservation_crs
--输入参数：会员卡号，预订号
--输出参数：成功标志(0-成功，1-失败)
------------------------------------------------------------------------------
declare 	@empno			char(10),
			@cardno0			varchar(20),
			@sta				char(1),
			@changed 		datetime,
			@bdate			datetime


select @ret=0, @msg='', @changed=getdate(), @bdate=bdate1 from sysdata

---------------------------------------------------
--	初步判断
---------------------------------------------------
if not exists(select 1 from master_hotel where accnt=@accnt and accnt0=@caccnt )
begin
	select @ret=1, @msg='Parameters Error'
	goto gout
end

select @cardno0 = cardno, @sta=sta from master where accnt=@accnt and class='F'
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

--------------------------------------
--	一些缺省参数
--------------------------------------
select @empno = isnull((select value from sysoption where catalog='' and item=''), 'FOX')  -- 网上预订工号


--------------------------------------
--	事务
--------------------------------------
begin tran 
save tran p_mst_s1 

update master set sta='X', cby=@empno, changed=@changed, bdate=@bdate where accnt=@accnt
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
