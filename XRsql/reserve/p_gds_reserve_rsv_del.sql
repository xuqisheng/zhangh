if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_del")
	drop proc p_gds_reserve_rsv_del;
create proc p_gds_reserve_rsv_del
	@accnt		char(10),
	@id			int,
	@retmode		char(1),			-- S, R
	@empno		char(10),
	@ret        int			output,
   @msg        varchar(60) output
as
----------------------------------------------------------------------------------------------
--	  客房资源管理程序 - rsv del
----------------------------------------------------------------------------------------------
declare
	@saccnt		char(10),
	@count		int,
	@host_id		varchar(30)

declare
	@blkcode		char(10), 
	@sta			char(1),
	@rmtype		char(5),
	@begin		datetime,
	@end			datetime,
	@quan			int 

select @ret=0, @msg='',@host_id = host_id(),@sta='', @blkcode=''
delete linksaccnt where host_id=@host_id
delete rsvsrc_1 where host_id=@host_id
delete rsvsrc_2 where host_id=@host_id
-- delete rsvsrc_blk where host_id=@host_id

begin tran
save 	tran 	rsvsrc_del

select @saccnt=saccnt, @rmtype=type, @begin=begin_, @end=end_, @quan=quantity from rsvsrc where accnt=@accnt and id=@id
if @@rowcount = 0
begin
	select @ret=1, @msg='预留记录不存在，可能已经删除'
	goto gout
end

if @id=0 and exists(select 1 from rsvsrc where accnt=@accnt and id<>@id)
begin
	select @ret=1, @msg='主单预留记录不能删除，请先删除其他纯预留'
	goto gout
end

-- 
if @accnt not like 'B%' 
	select @blkcode=blkcode, @sta=sta from master where accnt=@accnt 
if @blkcode<>'' and @sta not in ('O', 'N') -- noshow和结账的情况不做blk恢复处理 
	exec p_gds_reserve_rsv_blkdiff @host_id, @blkcode, @rmtype, @begin, @end, 'before'

-- 
select @count = count(1) from rsvsrc where saccnt=@saccnt
-- 没有任何关联；
if @count = 1
begin
	exec p_gds_reserve_rsv_del_saccnt @saccnt
	update rsvsrc set quantity=0, cby=@empno, changed=getdate(), logmark=logmark+1  where accnt=@accnt and id=@id  -- log 
	delete rsvsrc where saccnt=@saccnt
	goto gout
end

-- saccnt 的对应日期有变化，需要重新建立；
exec p_gds_reserve_rsv_del_saccnt @saccnt
update rsvsrc set quantity=0, cby=@empno, changed=getdate(), logmark=logmark+1  where accnt=@accnt and id=@id  -- log 
delete rsvsrc where accnt=@accnt and id=@id
insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id
		from rsvsrc where saccnt = @saccnt

if @ret = 0
	exec p_gds_reserve_rsv_host_reb @host_id

-- end 
gout:
-- block 应用处理 
if @ret=0 and @blkcode<>'' and @sta not in ('O', 'N') -- noshow和结账的情况不做blk恢复处理 
begin
	exec p_gds_reserve_rsv_blkdiff @host_id, @blkcode, @rmtype, @begin, @end, 'after'
	exec @ret = p_gds_reserve_rsv_blkuse @host_id, @blkcode, @rmtype, @empno 
	if @ret<>0
		select @msg='超出Block预留范围'
--		select @msg='Block 应用错误del'		-- 这个提示用户看不懂 
end

if @ret <> 0
	rollback tran rsvsrc_del
commit tran 

delete linksaccnt where host_id=@host_id
delete rsvsrc_1 where host_id=@host_id
delete rsvsrc_2 where host_id=@host_id
-- delete rsvsrc_blk where host_id=@host_id

--纯预留房价拆分  yjw 2008-5-29
if @ret=0 and substring(@accnt,1,1)<>'F' 
begin 
	exec p_yjw_rsvsrc_detail_accnt_grp @accnt,@id
end 
--
if @retmode='S'
	select @ret, @msg
return @ret
;

