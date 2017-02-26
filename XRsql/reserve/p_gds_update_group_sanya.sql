IF OBJECT_ID('dbo.p_gds_update_group') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_gds_update_group
    IF OBJECT_ID('dbo.p_gds_update_group') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_gds_update_group >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_gds_update_group >>>'
END
go
SETUSER 'dbo'
go
create  proc p_gds_update_group
	@grpaccnt 			char(10),
	@empno    			char(10),
	@logmark  			int,
	@nullwithreturn  	varchar(60) output
as

------------------------------------------------------
--		主单信息修改 ---〉〉
--
--			客房资源  问题重点!!!
--			房标
--			p_gds_maintain_group
--			p_gds_master_grpmid
--
------------------------------------------------------
declare
   @ret      		int,
   @msg      		varchar(60),
   @sta      		char(1),
   @exp_sta  		char(1),
   @oexp_sta 		char(1),
   @oarr     		datetime,
   @odep     		datetime,
   @arr      		datetime,
   @dep      		datetime,
   @rm_type  		char(5),
   @quantity 		int ,
   @memaccnt 		char(10)

declare
	@id				int,
	@r_type			char(5),
	@r_roomno		char(5),
	@r_blkmark		char(1),
	@r_begin			datetime,
	@r_end			datetime,
	@r_quan			int,
	@r_gstno			int,
	@r_rate			money,
	@r_remark		varchar(50)

-- New begin
declare
	@rmrate		money,
	@rtreason	char(3),
	@ratecode   char(10),
	@src			char(3),
	@market		char(3),
	@packages	varchar(50),
	@srqs		   varchar(30),
	@amenities  varchar(30)

begin tran
save  tran p_gds_update_group_s1

select @ret=0, @msg = ""
update master set sta = sta where accnt = @grpaccnt
select @sta = sta,@arr = arr,@dep = dep,@oarr = oarr,@odep = odep,@exp_sta=exp_sta
	from master where accnt = @grpaccnt and class in ('G', 'M')
if @@rowcount = 0
begin
	select @ret = 1,@msg = "团体主单%1不存在^"+@grpaccnt
	goto gout
end

select  @arr  = convert(datetime,convert(char(10),@arr,111))
select  @dep  = convert(datetime,convert(char(10),@dep,111))
select  @oarr = convert(datetime,convert(char(10),@oarr,111))
select  @odep = convert(datetime,convert(char(10),@odep,111))

exec @ret = p_gds_master_cancel_lastrsv @grpaccnt, @empno, ''
if @ret <> 0 
begin
	select @ret = 1,@msg = "Release block error" 
	goto gout
end
-- logmark = 99999 表示成员/预留日期不随团体日期改变；(客户端设置)
if not (@arr = @oarr and (@dep = @odep or datediff(day,@arr,@dep) <= 1 and datediff(day,@oarr,@odep) <= 1))
	and @logmark <> 99999
begin
	-- 团体主单的 纯预留 信息
	declare c_update_group cursor for
		select id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,
				rmrate,rtreason,ratecode,src,market,packages,srqs,amenities
			from rsvsrc where accnt = @grpaccnt
	open c_update_group
	fetch c_update_group into @id,@r_type,@r_roomno,@r_blkmark,@r_begin,@r_end,@r_quan,@r_gstno,@r_rate,@r_remark,
			@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities
	while @@sqlstatus = 0
	begin
		if @r_begin	= @oarr select @r_begin = @arr
		if @r_end	= @odep select @r_end = @dep
		exec p_gds_reserve_rsv_mod @grpaccnt,@id,@r_type,@r_roomno,@r_blkmark,@r_begin,@r_end,
				@r_quan,@r_gstno,@r_rate,@r_remark,
				@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
		if @ret <> 0	goto gout

		fetch c_update_group into @id,@r_type,@r_roomno,@r_blkmark,@r_begin,@r_end,@r_quan,@r_gstno,@r_rate,@r_remark,
			@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities
	end
	close c_update_group
	deallocate cursor c_update_group

	-- 成员主单
	declare c_mem cursor for select accnt from master
		where groupno = @grpaccnt and charindex(sta,'IRCG') > 0
			order by roomno,accnt
	open c_mem
	fetch c_mem into @memaccnt
	while @@sqlstatus = 0
	begin
		update master set arr = @arr,dep=@dep where accnt = @memaccnt and charindex(sta,'RCG') > 0
		update master set dep = @dep where accnt = @memaccnt and charindex(sta,'RCGI') > 0
		if @@rowcount > 0
		begin
			exec @ret = p_gds_reserve_chktprm @memaccnt,'4','',@empno,'P',0,0,@msg output
			update master set logmark=logmark+1,cby=@empno,changed=getdate() where accnt = @memaccnt
			if @ret <> 0
			begin
				select @msg = "[成员帐号 - %1] ^"+@memaccnt+@msg
				goto gout
			end
		end

		fetch c_mem into @memaccnt
	end
	close c_mem
	deallocate cursor c_mem
end

-- 还原 logmark
if @logmark = 99999
	select @logmark = 0

-- 房标
if (@oexp_sta is null and @exp_sta is not null) or (@oexp_sta is not null and @exp_sta is null) or @oexp_sta <> @exp_sta
   begin
   update master set exp_sta = @exp_sta where groupno = @grpaccnt
   update rmsta  set logmark=logmark+1,empno=@empno,changed=getdate()
		where roomno in (select b.roomno from master b where b.groupno=@grpaccnt and b.roomno <> space(5) and charindex(b.sta,'RCGI') > 0)
   end

-- update group master
update master set oarr = arr,odep = dep,cby=@empno,changed=getdate() where accnt = @grpaccnt
exec @ret = p_gds_maintain_group @grpaccnt,@empno,@logmark,@msg output
if @ret = 0
	exec p_gds_master_grpmid @grpaccnt, 'R', @ret output,  @msg output

-- 调整纯预留的到达和离开日期 的 准确时间
select @arr = arr,@dep = dep from master where accnt = @grpaccnt
update rsvsrc set arr = @arr where accnt = @grpaccnt and datediff(dd,arr,@arr)=0 and arr<>@arr and id>0
update rsvsrc set dep = @dep where accnt = @grpaccnt and datediff(dd,arr,@dep)=0 and dep<>@dep and id>0


-- End ...
gout:
if @ret <> 0
   rollback tran p_gds_update_group_s1
commit tran
if @nullwithreturn is null
   select @ret,@msg
else
   select @nullwithreturn = @msg
return @ret
go
SETUSER
go
IF OBJECT_ID('dbo.p_gds_update_group') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_gds_update_group >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_gds_update_group >>>'
go
