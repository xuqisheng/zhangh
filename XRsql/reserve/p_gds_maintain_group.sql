
if exists(select * from sysobjects where name = "p_gds_maintain_group")
   drop proc p_gds_maintain_group;
create proc p_gds_maintain_group
   @grpaccnt 			char(10),
   @empno    			char(10),
   @logmark  			int,			-- >=1 表示需要记录日志. -- 放弃，日志肯定要记录。 
   @nullwithreturn 	varchar(60) output
as
-----------------------------------------------------------
-- 检查和维护团体主单的 --- 人数,房数,房价
-----------------------------------------------------------
declare
   @rate     	money,
   @orate    	money,
   @gstno   	int,
   @rooms    	int,
   @ret      	int,
   @msg      	varchar(60),
	@save			int,		-- 记录是否有更新行为发生
	@rmlimit		char(1),
	@grprms		int,
	@sta			char(1),
	@sync			char(1)

--------------------------------------------------------
-- 团体总客房限制
--------------------------------------------------------
select @rmlimit = isnull((select substring(value,1,1) from sysoption where catalog='reserve' and item='grp_rm_limit'), 'F')
if charindex(@rmlimit, 'TtYy') > 0 
	select @rmlimit = 'T'
else
	select @rmlimit = 'F'
select @grprms = rmnum, @sta=sta from master where accnt=@grpaccnt

--------------------------------------------------------
-- 团体主单信息同步: 客房\人数 -- 但是也只限于预订状态 
--------------------------------------------------------
select @sync = isnull((select substring(value,1,1) from sysoption where catalog='reserve' and item='grp_rmgst_sync'), 'F')
if charindex(@sync, 'TtYy') > 0 
	select @sync = 'T'
else
	select @sync = 'F'

-- 
select @ret = 0,@msg = "", @save=0

begin tran
save  tran p_gds_maintain_group_s1

update master set sta = sta where accnt = @grpaccnt

--------------------
-- rate	
--------------------
--select @orate = setrate from master where accnt = @grpaccnt
--select @rate = max(rate) from grprate where accnt = @grpaccnt
--if @rate is not null and @rate <> @orate
--begin
--	update master set setrate = @rate, rmrate=@rate where accnt = @grpaccnt
--	select @save = 1
--end

----------------------------------------------------------------------------------------------------
-- rooms & gstno 
-- 特别注意：不能这样处理！grid block 的时候每天一个记录，数量大幅上升 2005.12.30 
----------------------------------------------------------------------------------------------------
--select @rooms = isnull((select sum(a.quantity) from rsvsaccnt a where a.accnt=@grpaccnt),0)
--select @rooms = @rooms + isnull((select sum(a.quantity) from rsvsaccnt a, master b where a.accnt=b.accnt and b.groupno=@grpaccnt),0)
--select @gstno = isnull((select sum(gstno*quantity) from rsvsrc where accnt=@grpaccnt), 0)
--select @gstno = @gstno + isnull((select sum(gstno) from master where groupno = @grpaccnt and charindex(sta,'RCGI') > 0), 0)

select @rooms = 0  -- isnull((select sum(quantity) from rsvsrc where accnt=@grpaccnt and id>0), 0)
select @rooms = @rooms + isnull((select count(distinct saccnt) from master where groupno=@grpaccnt and charindex(sta,'RCGI') > 0), 0)
select @gstno = 0  -- isnull((select sum(gstno*quantity) from rsvsrc where accnt=@grpaccnt and id>0), 0)
select @gstno = @gstno + isnull((select sum(gstno) from master where groupno = @grpaccnt and charindex(sta,'RCGI') > 0), 0)
----------------------------------------------------------------------------------------------------


if @rooms>@grprms and @rmlimit='T'
begin
	select @ret=1, @msg='团体用房超过主单房数限制'
end
else
begin
	if @sta ='R' and @sync='T' and @rmlimit='F'  -- @sync, @rmlimit 两个选项有冲突的  
	begin
		update master set rmnum = @rooms, gstno = @gstno where accnt = @grpaccnt
		if @@rowcount>0 select @save=1
	end
	else
	begin
		update master set rmnum = @rooms where accnt = @grpaccnt and rmnum < @rooms and @rooms>0
		if @@rowcount>0 select @save=1
		update master set gstno = @gstno where accnt = @grpaccnt and gstno < @gstno and @gstno>0
		if @@rowcount>0 select @save=1
	end 	
	--------------------
	-- if saved, logmark ?
	--------------------
	if @save > 0
	begin
--		if @logmark >= 1
			update master set logmark=logmark+1,cby = @empno,changed = getdate() where accnt = @grpaccnt
--		else
--			update master set cby = @empno,changed = getdate() where accnt = @grpaccnt
	end
end

-- 
if @ret <> 0 
	rollback tran p_gds_maintain_group_s1
commit tran

if @nullwithreturn is null
   select @ret,@msg
else
   select @nullwithreturn = @msg
return @ret
;