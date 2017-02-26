
if exists(select * from sysobjects where name = "p_gds_sc_update_group")
	drop proc p_gds_sc_update_group
;
create  proc p_gds_sc_update_group
	@grpaccnt 			char(10),
	@empno    			char(10),
	@logmark  			int,
	@nullwithreturn  	varchar(60) output
as
------------------------------------------------------
--		主单信息修改 ---〉〉
--
--			客房资源  问题重点!
--			房标
--			p_gds_maintain_group
--			p_gds_master_grpmid
--
------------------------------------------------------
declare
   @ret      		int,
   @msg      		varchar(60),
   @sta      		char(1),
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
	@packages	char(50),
	@srqs		   varchar(30),
	@amenities  varchar(30)

begin tran
save  tran p_gds_sc_update_group_s1

select @ret=0, @msg = ""
update sc_master set sta = sta where accnt = @grpaccnt
select @sta = sta,@arr = arr,@dep = dep,@oarr = oarr,@odep = odep
	from sc_master where accnt = @grpaccnt
if @@rowcount = 0
begin
	select @ret = 1,@msg = "Block主单%1不存在^"+@grpaccnt
	goto gout
end

select  @arr  = convert(datetime,convert(char(10),@arr,111))
select  @dep  = convert(datetime,convert(char(10),@dep,111))
select  @oarr = convert(datetime,convert(char(10),@oarr,111))
select  @odep = convert(datetime,convert(char(10),@odep,111))

-- logmark = 99999 表示成员/预留日期不随团体日期改变；(客户端设置)
-- if not (@arr = @oarr and (@dep = @odep or datediff(day,@arr,@dep) <= 1 and datediff(day,@oarr,@odep) <= 1))  -- 为什么这样写？看不懂了
//if not (@arr = @oarr and @dep = @odep )
//	and @logmark <> 99999
//begin
//	-- 团体主单的 纯预留 信息
//	declare c_update_group cursor for 
//		select id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,
//				rmrate,rtreason,ratecode,src,market,packages,srqs,amenities
//			from rsvsrc where accnt = @grpaccnt and id>0 
//	open c_update_group
//	fetch c_update_group into @id,@r_type,@r_roomno,@r_blkmark,@r_begin,@r_end,@r_quan,@r_gstno,@r_rate,@r_remark,
//			@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities
//	while @@sqlstatus = 0
//	begin
//		if @r_begin	= @oarr select @r_begin = @arr 
//		if @r_end	= @odep select @r_end = @dep 
//		exec p_gds_reserve_rsv_mod @grpaccnt,@id,@r_type,@r_roomno,@r_blkmark,@r_begin,@r_end,
//				@r_quan,@r_gstno,@r_rate,@r_remark,
//				@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
//		if @ret <> 0	goto gout
//
//		fetch c_update_group into @id,@r_type,@r_roomno,@r_blkmark,@r_begin,@r_end,@r_quan,@r_gstno,@r_rate,@r_remark,
//			@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities
//	end
//	close c_update_group
//	deallocate cursor c_update_group
//	
//	-- 成员主单
//	-- 没有，不用处理...... 
//end

-- 还原 logmark
if @logmark = 99999
	select @logmark = 0

-- update group sc_master 
update sc_master set oarr = arr,odep = dep,cby=@empno,changed=getdate() where accnt = @grpaccnt
--exec @ret = p_gds_maintain_group @grpaccnt,@empno,@logmark,@msg output
--if @ret = 0  -- 没有成员，不需要哦。。 
--	exec p_gds_master_grpmid @grpaccnt, 'R', @ret output,  @msg output

-- 调整纯预留的到达和离开日期 的 准确时间
select @arr = arr,@dep = dep from sc_master where accnt = @grpaccnt
update rsvsrc set arr = @arr where accnt = @grpaccnt and datediff(dd,arr,@arr)=0 and arr<>@arr and id>0
update rsvsrc set dep = @dep where accnt = @grpaccnt and datediff(dd,arr,@dep)=0 and dep<>@dep and id>0

-- End ...
gout:
if @ret <> 0
   rollback tran p_gds_sc_update_group_s1
commit tran
if @nullwithreturn is null
   select @ret,@msg
else
   select @nullwithreturn = @msg

return @ret
;
