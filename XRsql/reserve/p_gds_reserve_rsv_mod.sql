if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_mod")
	drop proc p_gds_reserve_rsv_mod;
create proc p_gds_reserve_rsv_mod
	@accnt		char(10),
	@id			int,
	@type			char(5),
	@roomno		char(5),
	@blkmark		char(1),
	@begin		datetime,
	@end			datetime,
	@quan			int,
	@gstno		int,
	@rate			money,
	@remark		varchar(50),
-- New begin
	@rmrate		money,
	@rtreason	char(3),
	@ratecode   char(10),
	@src			char(3),
	@market		char(3),
	@packages	varchar(50),
	@srqs		   varchar(30),
	@amenities  varchar(30),
	@empno		char(10),
-- New end	
	@retmode		char(1),					-- S, R
	@ret        int	output,
   @msg        varchar(60) output	-- in sc, begin with sc!
as
----------------------------------------------------------------------------------------------
--		客房资源管理程序 - rsv mod
----------------------------------------------------------------------------------------------

declare
	@saccnt		char(10),
	@count		int,
	@host_id		varchar(30),
	@sactlink	char(10),
	@over			int,
	@extend		char(1),
	@rsvchk		varchar(20) 

declare		-- 记录光标里上一次的变量，或者原来的纪录；
	@oquan		int,
	@otype		char(5),
	@oroomno		char(5),
	@obegin		datetime,
	@oend			datetime,
	@arr			datetime,
	@dep			datetime

declare		-- date for saccnt
	@sbegin		datetime,
	@send			datetime,
	@marr			datetime,
	@mdep			datetime,
	@class		char(1),
	@rmtag		char(1),
	@sc			char(1),
	@blkuse		char(1),				-- block 应用不判断资源 
	@oblkcode	char(10), 
	@blkcode		char(10)

--
select @sc='F', @blkuse='F' 
if rtrim(@msg) is null
	select @msg=''
else if substring(@msg, 1, 10) = 'sc!blkuse!'
	select @sc='T', @blkuse='T', @msg=isnull(ltrim(stuff(@msg, 1, 10, '')), '')
else if substring(@msg, 1, 3) = 'sc!'
	select @sc='T', @blkuse='F', @msg=isnull(ltrim(stuff(@msg, 1, 3, '')), '')

--
select @rsvchk='1'  -- 需要验证 
if charindex('rsvchk=0;', @msg)>0 
	select @rsvchk='0' -- 不需要验证 

-- Adjust Parms
if @rmrate is null 		select @rmrate = 0
if @rtreason is null		select @rtreason = ''
if @ratecode is null 	select @ratecode = ''	
if @src is null 			select @src = ''	
if @market is null 		select @market = ''	
if @packages is null 	select @packages = ''	
if @srqs is null 			select @srqs = ''	
if @amenities is null 	select @amenities = ''	
if @empno is null 		select @empno = ''	

select @host_id = host_id()
select @ret=0, @msg='', @extend='F'
select @otype='',@oroomno='',@obegin='1980.1.1',@oend='1980.1.2'

delete linksaccnt where host_id=@host_id
delete rsvsrc_1 where host_id=@host_id
delete rsvsrc_2 where host_id=@host_id
-- delete rsvsrc_blk where host_id=@host_id   -- 该过程可能嵌套调用，该表已经存在有意义的内容 

if @begin=@end
	select @end=dateadd(dd, 1, @begin) 
select @arr=@begin, @dep=@end
select @begin = convert(datetime,convert(char(8),@begin,1))
select @end = convert(datetime,convert(char(8),@end,1))
if @sc='F'
	select @class=class, @marr=arr, @mdep=dep, @oblkcode=oblkcode, @blkcode=blkcode from master where accnt=@accnt
else
	select @class=class, @marr=arr, @mdep=dep, @oblkcode='', @blkcode='' from sc_master where accnt=@accnt
if @blkcode<>'' or @oblkcode<>'' 
	select @blkuse='T' 
select @rmtag = tag from typim where type=@type

begin tran
save tran rsvsrc_mod

if @begin>@end 
begin
	select @ret=1, @msg = '日期大小不对'
	goto gout
end
if ((@class in ('G', 'M') and @id>0) or @class='B')  and (datediff(dd,@marr,@begin)<0 or datediff(dd,@mdep,@end)>0)
begin
	select @ret=1, @msg='客房预留区间不能超过主单的抵离日期'
	goto gout
end

select @saccnt=saccnt, @otype=type,@oroomno=roomno,@obegin=begin_,@oend=end_,@oquan=quantity
	from rsvsrc where accnt=@accnt and id=@id
if @@rowcount = 0
begin
	if @class='F'
	begin
		select @ret=1, @msg='预留记录不存在，可能已经删除'
		goto gout
	end
	else if @type='PM' and @id=0  -- 表示要新增资源 
	begin		
		exec p_gds_reserve_rsv_add @accnt,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,'',
			@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
		goto gout
	end 
	else
	begin
		select @ret=1, @msg='p_gds_reserve_rsv_mod error 1!'
		goto gout
	end
end
else if  @type=''
begin
	if @class in ('G', 'M', 'C', 'B') and @id=0  -- 表示要删除资源 
	begin		
		exec p_gds_reserve_rsv_del_saccnt @saccnt
		delete rsvsrc where saccnt=@saccnt 
		goto gout
	end 
	else
	begin
		select @ret=1, @msg='p_gds_reserve_rsv_mod error 2!'
		goto gout
	end
end

if @quan=0 
begin
	select @ret=1, @msg='房数 = 0'
	goto gout
end
if @roomno<>'' and @quan>1 
begin
	select @ret=1, @msg='有房号的情况下,房数必须 = 1'
	goto gout
end

-- 修改与预留无关；
if @otype=@type and @oroomno=@roomno and @obegin=@begin and @oend=@end and @oquan=@quan and @blkcode=@oblkcode 
begin
	update rsvsrc set blkmark=@blkmark,gstno=@gstno,rate=@rate,remark=@remark,arr=@arr,dep=@dep,
			rmrate=@rmrate,rtreason=@rtreason,ratecode=@ratecode,src=@src,market=@market,blkcode=@blkcode, 
			packages=@packages,srqs=@srqs,amenities=@amenities,cby=@empno,changed=getdate(),logmark=logmark+1
		where accnt=@accnt and id=@id
	goto gout
end

--
if @oblkcode<>'' 
	exec p_gds_reserve_rsv_blkdiff @host_id, @oblkcode, @otype, @obegin, @oend, 'before'
if @blkcode<>'' 
begin 
	if @oblkcode=@blkcode and @type=@otype  -- 追加情况 
		exec p_gds_reserve_rsv_blkdiff @host_id, @blkcode, @type, @begin, @end, 'before+'
	else 
		exec p_gds_reserve_rsv_blkdiff @host_id, @blkcode, @type, @begin, @end, 'before'
end


-- 只有一行，没有同住关系，而且日期包含于以前的区间，直接处理；
select @count = count(1) from rsvsrc where saccnt=@saccnt 
if @count=1 and @otype=@type and @oroomno=@roomno and @obegin<=@begin and @oend>=@end and @oquan=@quan
begin
	exec p_gds_reserve_rsv_del_saccnt @saccnt
	update rsvsrc set begin_=@begin,end_=@end,gstno=@gstno,rate=@rate,remark=@remark,arr=@arr,dep=@dep,
			rmrate=@rmrate,rtreason=@rtreason,ratecode=@ratecode,src=@src,market=@market,blkcode=@blkcode, 
			packages=@packages,srqs=@srqs,amenities=@amenities,cby=@empno,changed=getdate(),logmark=logmark+1
		where accnt=@accnt and id=@id
	insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
		values(@saccnt,@type,@roomno,'',@begin,@end,@quan,@accnt)
	if @sc='F'
		update master set saccnt=@saccnt where accnt = @accnt and @id = 0
	else
		update sc_master set saccnt=@saccnt where accnt = @accnt and @id = 0
	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@begin,@end,@quan
	goto gout
end 

-----------------------------------------------------
-- 改变了客房信息，或者导致saccnt日期变化，需要重建；
-----------------------------------------------------
select @extend = 'T'

-- 先删除原来的预留
exec p_gds_reserve_rsv_del_saccnt @saccnt

-- 更新 新的预留记录
--update rsvsrc set type=@type,roomno=@roomno,begin_=@begin,end_=@end, -- master=@accnt,
--		rateok='F',arr=@arr,dep=@dep,
--		blkmark=@blkmark,gstno=@gstno,rate=@rate,remark=@remark,quantity=@quan,
--			rmrate=@rmrate,rtreason=@rtreason,ratecode=@ratecode,src=@src,market=@market,
--			packages=@packages,srqs=@srqs,amenities=@amenities,cby=@empno,changed=getdate(),logmark=logmark+1
--	where accnt=@accnt and id=@id
-- 以下三句话其实就是上面的一个语句。 因为在 linux 环境下，对 update 长度有限制 
-- 2007.9.12 simon 
update rsvsrc set type=@type,roomno=@roomno,begin_=@begin,end_=@end,blkcode=@blkcode, -- master=@accnt,
		rateok='F',arr=@arr,dep=@dep
	where accnt=@accnt and id=@id
update rsvsrc set 
		blkmark=@blkmark,gstno=@gstno,rate=@rate,remark=@remark,quantity=@quan,
			rmrate=@rmrate,rtreason=@rtreason,ratecode=@ratecode,src=@src,market=@market
	where accnt=@accnt and id=@id
update rsvsrc set 
			packages=@packages,srqs=@srqs,amenities=@amenities,cby=@empno,changed=getdate(),logmark=logmark+1
	where accnt=@accnt and id=@id


if @roomno <> '' 
begin
	-- 重新整理相关 rsvsrc (1.原来saccnt包含的 2.相关涉及的 )
	insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id from rsvsrc 
		where saccnt=@saccnt

	-- 有交叉：找出相应的 saccnt,并且取消相关的订房；
	exec p_gds_reserve_rsv_get_saccnt @roomno, @begin, @end
	if exists(select 1 from linksaccnt where  host_id=@host_id)
	begin
		declare c_del cursor for select saccnt from linksaccnt where host_id=@host_id order by saccnt
		open c_del
		fetch c_del into @saccnt
		while @@sqlstatus = 0
		begin
			exec p_gds_reserve_rsv_del_saccnt @saccnt  -- 同时删除 rsvsaccnt 中的记录
			fetch c_del into @saccnt
		end
		close c_del
		deallocate cursor c_del
	end
	insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id from rsvsrc 
		where saccnt in (select saccnt from linksaccnt where host_id=@host_id) 

end
else	-- 没有房号,这里假定没有 share，直接增加；
begin
	-- 首先处理 saccnt 相关的记录
	insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id 
		from rsvsrc where saccnt = @saccnt and not (accnt=@accnt and id=@id)

	-- 然后处理修改后的部分 (已经包含在 rsvsrc 里面)
	exec p_GetAccnt1 'SAT', @saccnt output
	select @sactlink=@accnt,@sbegin=@begin,@send=@end
	insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
		values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan,@sactlink)
	update rsvsrc set saccnt=@saccnt,rateok='T' where accnt = @accnt and id = @id --,master=@accnt
	if @sc='F'
		update master set saccnt=@saccnt  -- , master=@accnt 
			where accnt = @accnt and @id = 0
	else
		update sc_master set saccnt=@saccnt  -- , master=@accnt 
			where accnt = @accnt and @id = 0
	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
	goto gout
end

gout:
-- block 应用处理 
if @ret=0 and (@oblkcode<>'' or @blkcode<>'') -- and @rsvchk='1'
begin
	if @oblkcode<>'' 
		exec p_gds_reserve_rsv_blkdiff @host_id, @oblkcode, @otype, @obegin, @oend, 'after'
	if @blkcode<>'' 
	begin 
		if @oblkcode=@blkcode and @type=@otype  -- 追加情况 
			exec p_gds_reserve_rsv_blkdiff @host_id, @blkcode, @type, @begin, @end, 'after+'
		else 
			exec p_gds_reserve_rsv_blkdiff @host_id, @blkcode, @type, @begin, @end, 'after'
	end

	if @oblkcode<>'' 
	begin 
		exec @ret = p_gds_reserve_rsv_blkuse @host_id, @oblkcode, @otype, @empno 
		if @ret<>0
			select @msg='超出Block预留范围'
--			select @msg='Block 应用错误mod1'		-- 这个提示用户看不懂 
	end 
	if @ret=0 and @blkcode<>'' and (@oblkcode<>@blkcode or @type<>@otype)
	begin
		exec @ret = p_gds_reserve_rsv_blkuse @host_id, @blkcode, @type, @empno 
		if @ret<>0
			select @msg='超出Block预留范围'
--			select @msg='Block 应用错误mod2'		-- 这个提示用户看不懂 
	end
end

-- 
if @ret = 0
begin
	exec p_gds_reserve_rsv_host_reb @host_id
	-- 资源判断
	if @begin<>@end and @extend='T' and @blkuse='F'  and @rsvchk='1' 
	begin
		exec @ret = p_gds_reserve_type_avail @type,@begin,@end,'1','R',@over output
		if @ret<>0 or @over<0
			select @ret=1, @msg='客房超预留'
		else
		begin
			exec p_gds_reserve_ctrltype_check @type, @begin, @end, 'R', @over output
			if @over > 0
				select @ret=1, @msg='客房总量控制超界1'
			else
			begin
				exec p_gds_reserve_ctrlblock_check @begin, @end, 'R', @over output
				if @over > 0
					select @ret=1, @msg='客房总量控制超界2'
			end 
		end
	end
end

-- end 
if @ret <> 0
	rollback tran rsvsrc_mod
commit tran 

--纯预留房价拆分  yjw 2008-5-29
if @ret=0 and @accnt not like 'F%' 
	exec p_yjw_rsvsrc_detail_accnt_grp @accnt,@id

--
delete linksaccnt where host_id=@host_id
delete rsvsrc_1 where host_id=@host_id
delete rsvsrc_2 where host_id=@host_id
if @blkcode<>'' or @oblkcode<>'' 
	delete rsvsrc_blk where host_id=@host_id

if @retmode='S'
	select @ret, @msg
return @ret
;

