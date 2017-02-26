if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_add")
	drop proc p_gds_reserve_rsv_add;
create proc p_gds_reserve_rsv_add
	@accnt		char(10),
	@type			char(5),
	@roomno		char(5),
	@blkmark		char(1),
	@begin		datetime,				-- 包含时间
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
   @msg        varchar(60) output
as
----------------------------------------------------------------------------------------------
--		客房资源管理程序 - rsv add
--
--	 master - 如何更新需要仔细考虑
--		2005/2 master.master 在插入 master 的时候决定，这里直接取出来用即可
--		2007.8 .master 仅仅用作同住标号
----------------------------------------------------------------------------------------------

declare
	@id			int,
	@class		char(1),		-- 账号类别 Fit, Grp, Met, Csm, Bok
	@saccnt		char(10),
	@master		char(10),
	@rateok		char(1),
	@count		int,
	@host_id		varchar(30),
	@sactlink	char(10),
	@arr			datetime,	-- 记录包含时间的日期
	@dep			datetime,
	@marr			datetime,	-- 主单的日期
	@mdep			datetime,
	@over			int,
	@Grid_Rood	int,
	@logmark		int,
	@grpblk_self		char(1),		-- 团体主单预留，非纯预留
	@rmtag		char(1),
	@sc			char(1),
	@blkuse		char(1),				-- block 应用不判断资源 
	@blkcode		char(10),
	@rsvchk		varchar(20)  

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

--
declare		-- date for saccnt
	@sbegin		datetime,
	@send			datetime

-- 取消排房的时候不需要判断资源超界问题；
if @remark = 'Grid-Rood'  
	select @Grid_Rood = 1
else
	select @Grid_Rood = 0

select @ret=0, @host_id = host_id(), @rateok='F'
delete linksaccnt where host_id=@host_id
delete rsvsrc_1 where host_id=@host_id
delete rsvsrc_2 where host_id=@host_id
-- delete rsvsrc_blk where host_id=@host_id   -- 该过程可能嵌套调用，该表已经存在有意义的内容 

begin tran
save 	tran rsvsrc_add

if @sc='F'
	select @class=class, @master=master, @marr=arr, @mdep=dep, @blkcode=blkcode from master where accnt=@accnt 
else
	select @class=class, @master=master, @marr=arr, @mdep=dep, @blkcode='' from sc_master where accnt=@accnt 
if @blkcode<>''
	select @blkuse='T' 

if @class not in ('F', 'G', 'M', 'C', 'B')  -- 消费帐不能涉及客房。  好像不太合理 ?
begin
	select @ret=1, @msg='该帐号类型不能预留客房资源'
	goto gout
end
if charindex(@class, 'GMB')>0 and @type='PM' -- 团体纯预留
	select @grpblk_self = 'T'
else
	select @grpblk_self = 'F'
if @end is null or @begin=@end
	select @end = dateadd(dd, 1, @begin)
if ((charindex(@class, 'GM')>0 and @grpblk_self='F') or @class='B') 
	 and (datediff(dd,@marr,@begin)<0 or datediff(dd,@mdep,@end)>0)
begin
	select @ret=1, @msg='客房预留区间不能超过主单的抵离日期'
	goto gout
end

if @master=''
begin
	select @master = @accnt
	if @sc='F'
		update master set master=@master where accnt=@accnt
	else
		update sc_master set master=@master where accnt=@accnt
end

select @arr=@begin, @dep=@end
select @begin = convert(datetime,convert(char(8),@begin,1))
select @end = convert(datetime,convert(char(8),@end,1))

if @begin>@end 
begin
	select @ret=1, @msg = '日期大小不对'
	goto gout
end

if exists(select 1 from rsvsrc where accnt=@accnt and type=@type and roomno=@roomno 
	and blkmark=@blkmark and begin_=@begin and end_=@end and quantity=@quan and gstno=@gstno 
	and rate=@rate and remark=@remark and saccnt<>'')
begin
	select @ret=1, @msg = '该记录已经存盘，不必再次加入'
	goto gout
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

----------------------------------------------------------------------------------------------------
-- id : 注意取值
--if exists(select 1 from rsvsrc where accnt=@accnt)
--	select @id = (select max(id) from rsvsrc where accnt=@accnt) + 1
--else
--	if charindex(@class, 'GM')>0 and @grpblk_self='F'
--		select @id = 1   -- 团体的纯预留
--	else					
--		select @id = 0   -- 主单上的资源

if charindex(@class, 'GMB')>0 and @grpblk_self='T'
	select @id = 0   -- 团体主单上的资源
else
begin					
	if exists(select 1 from rsvsrc where accnt=@accnt)
		select @id = (select max(id) from rsvsrc where accnt=@accnt) + 1
	else if charindex(@class, 'GMB')>0 
		select @id = 1   -- 团体的纯预留
	else
		select @id = 0   -- 主单上的资源
end

----------------------------------------------------------------------------------------------------

select @rmtag = tag from typim where type=@type 
if @id > 0 and @rmtag='P'
begin
	select @ret=1, @msg='纯预留不能使用假房'
	goto gout
end

--
if @blkcode<>'' 
	exec p_gds_reserve_rsv_blkdiff @host_id, @blkcode, @type, @begin, @end, 'before'

-- 
if @roomno<>'' -- 需要判断 share
begin
	exec p_gds_reserve_rsv_get_saccnt @roomno, @begin, @end

	-- 在 saccnt 中没有牵连，直接增加；(注意判断牵连的条件)
	if not exists(select 1 from linksaccnt where host_id=@host_id)
	begin
		exec p_GetAccnt1 'SAT', @saccnt output
		select @sactlink=@accnt,@sbegin=@begin,@send=@end, @rateok='T'
		select @logmark = isnull((select max(logmark) from rsvsrc_log where accnt=@accnt and id=@id), 0) + 1
		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt,master,rateok,arr,dep,
					rmrate,rtreason,ratecode,src,market,packages,srqs,amenities,cby,changed,logmark,blkcode)
			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt,@master,@rateok,@arr,@dep,
					@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,getdate(),@logmark,@blkcode)
		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
			values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan,@sactlink)
		if @sc='F'
			update master set saccnt=@saccnt where accnt = @accnt and @id = 0  -- master=@master, 
		else
			update sc_master set saccnt=@saccnt where accnt = @accnt and @id = 0  -- master=@master, 
		exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
		goto gout
	end
	
	-- 刚刚包含于某个 saccnt 的范围，则只需直接插入 rsvsrc。@begin=@end 的情况必定包含其中
	select @saccnt = isnull((select min(saccnt) from rsvsaccnt where roomno=@roomno and @begin>=begin_ and @end<=end_), '')
	if @saccnt <> ''
	begin
		select @logmark = isnull((select max(logmark) from rsvsrc_log where accnt=@accnt and id=@id), 0) + 1
--		select @master = min(master) from rsvsrc where saccnt=@saccnt
		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt,master,rateok,arr,dep,
					rmrate,rtreason,ratecode,src,market,packages,srqs,amenities,cby,changed,logmark,blkcode)
			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt,@master,'F',@arr,@dep,
					@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,getdate(),@logmark,@blkcode)
		if @sc='F'
			update master set saccnt=@saccnt where accnt = @accnt and @id = 0   -- master=@master, 
		else
			update sc_master set saccnt=@saccnt where accnt = @accnt and @id = 0   -- master=@master, 
		update rsvsrc set rateok='F' where saccnt=@saccnt
		goto gout
	end
	
	-- 有交叉：找出相应的 saccnt,并且取消相关的订房；
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
	
	-- 重新整理相关 rsvsrc
	select @logmark = isnull((select max(logmark) from rsvsrc_log where accnt=@accnt and id=@id), 0) + 1
	insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt,master,rateok,arr,dep,
					rmrate,rtreason,ratecode,src,market,packages,srqs,amenities,cby,changed,logmark,blkcode)
		values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,'',@master,'F',@arr,@dep,
					@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,getdate(),@logmark,@blkcode)
	insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id from rsvsrc 
		where saccnt in (select saccnt from linksaccnt where host_id=@host_id) or (accnt=@accnt and id=@id)
end
else	-- 没有房号,这里假定没有 share，直接增加；
begin
	exec p_GetAccnt1 'SAT', @saccnt output
	select @sactlink=@accnt,@sbegin=@begin,@send=@end,@rateok='T'
	select @logmark = isnull((select max(logmark) from rsvsrc_log where accnt=@accnt and id=@id), 0) + 1
	insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt,master,rateok,arr,dep,
					rmrate,rtreason,ratecode,src,market,packages,srqs,amenities,cby,changed,logmark,blkcode)
		values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt,@master,@rateok,@arr,@dep,
					@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,getdate(),@logmark,@blkcode)
	insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
		values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan,@sactlink)
	if @sc='F'
		update master set saccnt=@saccnt where accnt = @accnt and @id = 0  -- @id=0 !    -- master=@master, 
	else
		update sc_master set saccnt=@saccnt where accnt = @accnt and @id = 0  -- @id=0 !    -- master=@master, 
	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
	goto gout
end

gout:
-- block 应用处理 
if @ret=0 and @blkcode<>'' -- and @rsvchk='1' 
begin
	exec p_gds_reserve_rsv_blkdiff @host_id, @blkcode, @type, @begin, @end, 'after'
	if exists(select 1 from rsvsrc_blk where host_id=@host_id and blkcode=@blkcode and type=@type and 2*rmnum1-rmnum2<0) 
	begin
		select @ret=1, @msg='超出Block预留范围'
--		select * from rsvsrc_blk where host_id=@host_id 
	end 	
	else
	begin 
		exec @ret = p_gds_reserve_rsv_blkuse @host_id, @blkcode, @type, @empno 
		if @ret<>0
			select @msg='超出Block预留范围'
--			select @msg='Block 应用错误add'		-- 这个提示用户看不懂 
	end 
end

if @ret = 0
begin
	exec p_gds_reserve_rsv_host_reb @host_id

	-- 资源判断
--	if @begin<>@end and @roomno='' and @Grid_Rood <> 1
	if @begin<>@end and @Grid_Rood <> 1 and @rmtag='K' and @blkuse='F' and @rsvchk='1' 
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
	rollback tran rsvsrc_add
commit tran 

delete linksaccnt where host_id=@host_id
delete rsvsrc_1 where host_id=@host_id
delete rsvsrc_2 where host_id=@host_id
if @blkcode<>'' 
	delete rsvsrc_blk where host_id=@host_id
update rsvsrc set logmark=logmark+1 where accnt=@accnt and id=@id   -- log

-- grprate
if @ret = 0 and charindex(@class,'GM')>0 
begin
	if not exists(select 1 from grprate where accnt=@accnt and type=@type)
		insert grprate(accnt,type,rate,oldrate,cby,changed)
			values(@accnt,@type,@rate,@rate,'',getdate())
	else
		update grprate set rate=@rate where accnt=@accnt and type=@type
	--纯预留房价拆分  yjw 2008-5-29
	exec p_yjw_rsvsrc_detail_accnt_grp @accnt,@id
end

--
if @retmode='S'
	select @ret, @msg
return @ret
;