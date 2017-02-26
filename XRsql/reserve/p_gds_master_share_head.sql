if exists(select * from sysobjects where name = "p_gds_master_share_head")
   drop proc p_gds_master_share_head
;
create  proc p_gds_master_share_head
   @accnt 				char(10)
as
------------------------------------
--	Share Window : Head
------------------------------------
declare	@stay			datetime,	-- 住店日期
			@type			char(5),
			@roomno		char(5),
			@quan			int,
			@gstno		int,
			@ret			int,
			@ratecode	char(10),
			@rate			money,
			@ttl			money,		-- 总房价（包括所有同住/共享）
			@saccnt		char(10),
			@master		char(10),
			@groupno		char(10),
			@msg			varchar(60),
			@class		char(1),
			@sta			char(1),
			@arr			datetime,
			@dep			datetime

-- 
create table #gout (
	roomno			char(5)		null,
	type				char(5)		null,
	gstno				int			null,
	ratecode			char(10)		null,
	rate				money			null,
	ttl				money			null,
	saccnt			char(10)		null
)

-- Init
select @type=type, @roomno=roomno, @gstno=gstno, @ratecode=ratecode, @rate=setrate, @ttl=0, 
		@saccnt=saccnt, @master=master, @sta=sta, @groupno=groupno, @class=class, @arr=arr, @dep=dep 
	from master where accnt=@accnt
if @@rowcount > 0 and @class='F'
begin
	-- 同住、共享的客房资源
	if not exists(select 1 from rsvsaccnt where saccnt=@saccnt)
		select @saccnt=isnull((select min(saccnt) from master where sta in ('R', 'I') and master=@master), '')

	select @type=type,@roomno=roomno,@stay=begin_,@quan=quantity from rsvsaccnt where saccnt=@saccnt
	if @@rowcount > 0 
	begin
		select @gstno = isnull((select sum(gstno) from rsvsrc where saccnt=@saccnt), 1)

		-- 应该执行的价格
		exec @ret = p_gds_get_rmrate @stay,1,@type,@roomno,@quan,@gstno,@ratecode,@groupno,'R',@rate output, @msg output
		if @ret <> 0 
			select @rate = -1   -- 此时，一般是房价码无效

		-- 当前的总价格
--		select @ttl = isnull((select sum(rate) from rsvsrc where saccnt=@saccnt), 0)

		-- 当前的总价格 - 需要考虑同住的情况 and dayuse 
		if @roomno='' 
			select @ttl = isnull((select sum(rate) from rsvsrc where saccnt=@saccnt), 0)
		else if datediff(dd, @arr, @dep) = 0
			select @ttl = isnull((select sum(rate) from rsvsrc 
				where roomno=@roomno and datediff(dd,@arr,begin_)<=0 and datediff(dd,@arr,end_)>=0), 0) 
		else
			select @ttl = isnull((select sum(rate) from rsvsrc 
				where roomno=@roomno 
					and ((datediff(dd,begin_,end_)=0 and datediff(dd,@arr,begin_)>=0 and datediff(dd,@dep,begin_)>=0) 
					or (datediff(dd,begin_,end_)<>0 and datediff(dd,@arr,end_)>0 and datediff(dd,@dep,begin_)<0)
				)), 0) 
	end
	
	insert #gout(roomno,type,gstno,ratecode,rate,ttl,saccnt)
		values (@roomno,@type,@gstno,@ratecode,@rate,@ttl,@saccnt)
end

-- Output
select roomno, type, gstno, rate, ratecode, ttl, saccnt from #gout 

return 0
;

