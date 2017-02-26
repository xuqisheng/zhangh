----------------------------------------------------------------------------------------------
--		客房资源管理程序 - share  同住,共享
--
--		好像已经不用了 ? 6.18
----------------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_share")
	drop proc p_gds_reserve_rsv_share;
create proc p_gds_reserve_rsv_share
	@accnt		char(10),
	@type			char(5),
	@roomno		char(5),
	@blkmark		char(1),
	@begin		datetime,
	@end			datetime,
	@quan			int,
	@gstno		int,
	@rate			money,
	@remark		varchar(50),
	@retmode		char(1),			-- S, R
	@ret        int	output,
   @msg        varchar(60) output
as

declare
	@id			int,
	@class		char(1),		-- 账号类别 Fit, Grp, Met, Csm
	@saccnt		char(10),
	@master		char(10),
	@rateok		char(1),
	@count		int,
	@host_id		varchar(30),
	@sactlink	char(10),
	@arr			datetime,	-- 记录包含时间的日期
	@dep			datetime

declare		-- date for saccnt
	@sbegin		datetime,
	@send			datetime

select @ret=0, @msg='',@host_id = host_id(), @rateok='F'
delete linksaccnt where host_id=@host_id
delete rsvsrc_1 where host_id=@host_id
delete rsvsrc_2 where host_id=@host_id

begin tran
save 	tran rsvsrc_add

select @class=class from master where accnt=@accnt 
if @class not in ('F', 'G', 'M', 'C', 'B' )  -- 消费帐不能涉及客房。  好像不太合理 ?
begin
	select @ret=1, @msg='该帐号类型不能预留客房资源 ! ---- %1^' + @class + ' - ' + @accnt
	goto gout
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

-- id : 注意取值
if exists(select 1 from rsvsrc where accnt=@accnt)
	select @id = (select max(id) from rsvsrc where accnt=@accnt) + 1
else
	if @class = 'F'  	-- fit
		select @id = 0   -- 宾客主单上的资源
	else					-- grp, meet
		select @id = 1

if @roomno<>'' -- 需要判断 share
begin
	exec p_gds_reserve_rsv_get_saccnt @roomno, @begin, @end
	-- 在 saccnt 中没有牵连，直接增加；(注意判断牵连的条件)
	if not exists(select 1 from linksaccnt where host_id=@host_id)
	begin
		exec p_GetAccnt1 'SAT', @saccnt output
		select @sactlink=@accnt,@sbegin=@begin,@send=@end, @master=@accnt, @rateok='T'
		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt,master,rateok,arr,dep)
			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt,@master,@rateok,@arr,@dep)
		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
			values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan,@sactlink)
		update master set saccnt=@saccnt where accnt = @accnt and @id = 0  -- master=@master, 
		exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
		goto gout
	end
	
	-- 刚刚包含于某个 saccnt 的范围，则只需直接插入 rsvsrc。@begin=@end 的情况必定包含其中
	select @saccnt = isnull((select min(saccnt) from rsvsaccnt where roomno=@roomno and @begin>=begin_ and @end<=end_), '')
	if @saccnt <> ''
	begin
		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt,master,rateok,arr,dep)
			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt,@accnt,'F',@arr,@dep)
		update master set saccnt=@saccnt where accnt = @accnt and @id = 0  -- master=@master, 
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
	insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt,master,rateok,arr,dep)
		values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,'',@accnt,'F',@arr,@dep)
	insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id from rsvsrc 
		where saccnt in (select saccnt from linksaccnt where host_id=@host_id) or (accnt=@accnt and id=@id)
end
else	-- 没有房号,这里假定没有 share，直接增加；
begin
	exec p_GetAccnt1 'SAT', @saccnt output
	select @sactlink=@accnt,@sbegin=@begin,@send=@end,@master=@accnt,@rateok='T'
	insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt,master,rateok,arr,dep)
		values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt,@master,@rateok,@arr,@dep)
	insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
		values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan,@sactlink)
	update master set saccnt=@saccnt where accnt = @accnt and @id = 0  -- @id=0 !  -- master=@master, 
	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
	goto gout
end

gout:
if @ret = 0
	exec p_gds_reserve_rsv_host_reb @host_id

-- end 
if @ret <> 0
	rollback tran rsvsrc_add
commit tran 

delete linksaccnt where host_id=@host_id
delete rsvsrc_1 where host_id=@host_id
delete rsvsrc_2 where host_id=@host_id

-- grprate
if @ret = 0 and charindex(@class,'GM')>0 
begin
	if not exists(select 1 from grprate where accnt=@accnt and type=@type)
		insert grprate(accnt,type,rate,oldrate,cby,changed)
		values(@accnt,@type,@rate,@rate,'',getdate())
	else
		update grprate set rate=@rate where type=@type
end

if @retmode='S'
	select @ret, @msg
return @ret
;