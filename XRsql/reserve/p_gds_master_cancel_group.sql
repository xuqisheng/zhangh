
if exists(select * from sysobjects where name = "p_gds_master_cancel_group")
   drop proc p_gds_master_cancel_group
;
create  proc p_gds_master_cancel_group
   @grpaccnt 				char(10),
   @tosta    				char(1),
   @empno    				char(10),
   @nullwithreturn 		varchar(70) output

as

-- ----------------------------------------------------------------------
--
--取消团体预订(主单或成员可以有帐务) 
--	取消预订团体或客人可能要求付损失费,或扣留一部分定金 
--
--no-show 的时候，采用物理时间
--注意：团体noshow的分段处理
--
--------------------------------------------------------------------------
declare
   @ret     int,
   @msg     varchar(70),
   @sta     char(1),
   @accnt   char(10),
	@bdate	datetime,
	@newarr	datetime,		-- 判断noshow 的日期标准，特别注意；
	@curdate	datetime,		-- 当前物理时间
	@id		int,
	@type		char(5)

select @ret=0, @msg ="", @bdate=bdate1, @curdate=getdate() from sysdata

begin tran
save  tran p_gds_master_cancel_group_s1

update master set sta = sta where accnt = @grpaccnt and class in ('M', 'G')
select @sta = sta, @type=type from master where accnt = @grpaccnt and class in ('M', 'G')
if @@rowcount = 0
begin
	select @ret = 1,@msg = "团体主单%1不存在^"+@grpaccnt
	goto gout
end

update chktprm set code = 'A'
if charindex(@tosta,'XN') = 0
   select @ret = 1,@msg = "请设置正确的取消状态"
else if charindex(@sta,'I') > 0
   select @ret = 1,@msg = "团体主单%1已经登记,不能取消^"+@grpaccnt
else if charindex(@sta,'XN') > 0
   select @ret = 1,@msg = "团体主单%1已经不是有效预订状态^"+@grpaccnt
else if charindex(@sta,'RCG') = 0
   select @ret = 1,@msg = "团体主单%1非有效预订状态,不必取消^"+@grpaccnt
if @ret <> 0
	goto gout

-- new arr
if datediff(dd, @bdate, @curdate) > 0
	select @newarr = convert(datetime,convert(char(8),@curdate,1))
else
	select @newarr = dateadd(dd, 1, @bdate)

-- cancel all member 
declare c_cancel_group_mem cursor for
	select accnt from master where groupno = @grpaccnt and charindex(sta,'RCG') > 0
			and (@tosta<>'N' or (@tosta='N' and datediff(dd,arr,@newarr)>0))
		order by groupno,accnt
open  c_cancel_group_mem
fetch c_cancel_group_mem into @accnt
while @@sqlstatus = 0
begin
	select @sta = sta from master holdlock where accnt = @accnt
	if charindex(@sta,'RCG') > 0
	begin
		update master set sta = @tosta,master=accnt where accnt = @accnt
		exec @ret = p_gds_reserve_chktprm @accnt,'0','',@empno,'',1,0,@msg out
		if @ret<>0 
			goto gout
		update master set bdate=@bdate, logmark=logmark+1,cby=@empno,changed = getdate() where accnt = @accnt
	end

	fetch c_cancel_group_mem into @accnt
end
close  c_cancel_group_mem
deallocate cursor c_cancel_group_mem

-- release group block
if @tosta <> 'N'
	exec p_gds_reserve_release_block @grpaccnt, @empno
else
begin
	declare c_rsvsrc cursor for select id from rsvsrc where accnt = @grpaccnt and datediff(dd,begin_,@newarr)>0
	open c_rsvsrc
	fetch c_rsvsrc into @id
	while @@sqlstatus = 0
	begin
		delete rsvsrc_cxl where accnt=@grpaccnt and id=@id 
		insert rsvsrc_cxl select * from rsvsrc where accnt=@grpaccnt and id=@id 

		exec p_gds_reserve_rsv_del @grpaccnt,@id,'R',@empno,@ret output, @msg output
		fetch c_rsvsrc into @id
	end
	close c_rsvsrc
	deallocate cursor c_rsvsrc
end

-- update group
if exists(select 1 from master where class='F' and groupno=@grpaccnt and charindex(sta,'RCG')>0)
	or exists(select 1 from rsvsrc where accnt=@grpaccnt and id>0)
	update master set arr=@newarr, logmark=logmark+1,cby=@empno, changed = getdate() where accnt = @grpaccnt
else
begin 
	if exists(select 1 from gate where audit = 'T') and @tosta='N'  -- 正在稽核, No-Show
		update master set sta = @tosta, bdate=dateadd(dd, -1, @bdate), logmark=logmark+1,cby=@empno, changed = getdate() where accnt = @grpaccnt
	else
		update master set sta = @tosta, bdate=@bdate, logmark=logmark+1,cby=@empno, changed = getdate() where accnt = @grpaccnt
end 

-- release res_av
if exists(select 1 from master where accnt = @grpaccnt and sta in ('X', 'N')) 
	update res_av set sta='X' where accnt = @grpaccnt

if @type<>''
	exec @ret = p_gds_reserve_chktprm @grpaccnt,'0','',@empno,'',1,1,@msg output

gout:
if @ret <> 0 
	rollback tran p_gds_master_cancel_group_s1
commit tran
if @nullwithreturn is null
   select @ret,@msg
else
   select @nullwithreturn = @msg 

return @ret 
;
