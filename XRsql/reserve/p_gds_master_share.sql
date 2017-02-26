----------------------------------------------------------------------------------------------
--		share
--			注意: 客房资源以目的账号@accnt 为准，被加进的账号@add 的资源自动释放
--					如果房号本来就相同,就只需要变化日期了.
--
--			@add -- 只能是预订状态. 否则通过换房
--			如果 @add 本身还存在 同住和共享,需要注意
--			pcrec, pcrec_pkg ?
----------------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_master_share")
	drop proc p_gds_master_share;
create proc p_gds_master_share
	@accnt		char(10),		-- 目的账号
	@add			char(10),		-- 操作账号
	@empno		char(10),
	@retmode		char(1),			-- S, R
	@ret        int			output,
   @msg        varchar(60) output
as
declare		@type			char(5),			@type1		char(5),
				@roomno		char(5),			@roomno1		char(5),
				@arr			datetime,		@arr1			datetime,
				@dep			datetime, 		@dep1			datetime, 
				@master		char(10),		@master1		char(10),
				@saccnt		char(10),		@saccnt1		char(10),
				@sta			char(1),			@sta1			char(1),
				@rmnum		int,
				@mroomno		char(5),
				@class		char(1),
				@today		datetime,
				@bdate		datetime,
				@qtrate		money,
				@rmrate		money   -- 房价码需要该吗 ?

select @ret=0, @msg='', @today = getdate()
select @bdate = bdate1 from sysdata

-- 检验目的账号
select @type=type,@roomno=roomno, @class=class, @sta=sta, @rmnum=rmnum, @arr=arr, @dep=dep, @master=master, @saccnt=saccnt,
	@qtrate=qtrate,@rmrate=rmrate from master where accnt=@accnt
if @@rowcount = 0
	select @ret=1, @msg = '宾客主单不存在'
if @ret=0 and @class<>'F'
	select @ret=1, @msg = '非散客/成员主单，不能进行该操作'
if @ret=0 and charindex(@sta, 'RI')=0
	select @ret=1, @msg = '宾客主单非有效状态'
if @ret=0 and not exists(select 1 from rsvsrc where accnt=@accnt and id=0)
	select @ret=1, @msg = '无有效预留纪录'
if @ret = 0 and @rmnum>1 
	select @ret=1, @msg = '多间客房主单不能进行该操作'
if @ret=0 and datediff(dd, @dep, getdate())>0
	select @ret=1, @msg = '请先修改当前主单的离日'
if @ret<>0 
begin
	if @retmode='S'
		select @ret, @msg
	return @ret
end

-- 检验 share 账号
select @type1=type,@roomno1=roomno, @class=class, @sta1=sta, @rmnum=rmnum, @arr1=arr, @dep1=dep, @master1=master, @saccnt1=saccnt
	from master where accnt=@add
if @@rowcount = 0
	select @ret=1, @msg = 'share 宾客主单不存在'
if @ret=0 and @class<>'F'
	select @ret=1, @msg = 'share 非散客/成员主单，不能进行该操作'
if @ret=0 and charindex(@sta1, 'R')=0
	select @ret=1, @msg = 'share 宾客主单非预订状态'
if @ret=0 and not exists(select 1 from rsvsrc where accnt=@accnt and id=0)
	select @ret=1, @msg = 'share 无有效预留纪录'
if @ret = 0 and @rmnum>1 
	select @ret=1, @msg = 'share 多间客房主单不能进行该操作'
if @ret=0 and @saccnt=@saccnt1  -- 检验两个账号是否可以 share 
	select @ret=1, @msg = '两个宾客本来就共享客房'
if @ret<>0 
begin
	if @retmode='S'
		select @ret, @msg
	return @ret
end

-- begin 

begin tran
save 	tran master_share

-- 释放原来的资源
exec p_gds_reserve_rsv_del @add, 0, 'R', @empno, @ret output, @msg output
if @ret<>0
	goto gout

-- 检查目的账号的房号
if @roomno=''
begin
	exec p_GetAccnt1 'SRM', @mroomno output
	select @mroomno = '#' + rtrim(@mroomno)
end
else
	select @mroomno = @roomno
-- 被操作账号的到日。--- 在住的时候只能用‘换房’功能；
if datediff(dd,@today,@arr)<0
	select @arr = convert(datetime, convert(char(10), @today, 111) + ' 12:00:00')

update master set type=@type,otype=@type,roomno=@mroomno,oroomno=@mroomno,master=@master,saccnt=@saccnt,
	arr=@arr,oarr=@arr,dep=@dep,odep=@dep,qtrate=@qtrate,rmrate=@rmrate,setrate=0,discount=0,discount1=0
	where accnt=@add
if @@rowcount = 0
	select @ret=1, @msg='Update error.'
else
begin
	insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,master,rateok,arr,dep,saccnt,
			rmrate,rtreason,remark,ratecode,src,market,packages,srqs,amenities)
		select accnt,0,type,roomno,'',arr,dep,rmnum,gstno,setrate,accnt,'F',arr,dep,saccnt,
			rmrate,rtreason,'',ratecode,src,market,packages,srqs,amenities
		from master where accnt=@add
	if @@rowcount = 0
		select @ret=1, @msg='Insert rsvsrc error.'
	else
	begin
		update rsvsrc set begin_=convert(datetime,convert(char(8),begin_,1)), end_=convert(datetime,convert(char(8),end_,1)) 
			where accnt=@add
		update rsvsrc set rateok='F' where saccnt=@saccnt	 -- 价格问题

		-- 虚拟房号对原来主单的影响
		if @roomno=''
		begin
			update master set roomno=@mroomno, oroomno=@mroomno,cby=@empno, changed=getdate(), logmark=logmark+1 where accnt=@accnt
			update rsvsrc set roomno=@mroomno where accnt=@accnt and id=0
		end
	end
end

--
gout:
if @ret <> 0
	rollback tran master_share
else
	update master set logmark=logmark+1 where accnt=@add
commit tran

--
if @retmode='S'
	select @ret, @msg
return @ret
;

