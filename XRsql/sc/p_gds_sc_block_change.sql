

if exists(select * from sysobjects where name = "p_gds_sc_block_change")
   drop proc p_gds_sc_block_change;

create proc p_gds_sc_block_change
   @grpaccnt 	char(10),
	@empno		char(10),
	@msg			varchar(60) output 
as
--------------------------------------------------------
-- block 主单预留房的变化 -- 必须放在 sc_chktprm 里面
--		根据sta, osta 进行预留房的资源变化 
--
--		团体转移到前台以后，就不能调用 sc_chktprm 了，否则状态的变化更多。
--		在在转移到前台之前，状态只有 W,R,X,N 
--------------------------------------------------------

declare
   @sta      	char(1),
   @osta      	char(1),
	@ret			int

declare
	@type			char(5),
	@begin		datetime,
	@end			datetime,
	@quan			int,
	@gstno		int,
	@rate			money,
	@remark		varchar(50),
	@ratecode   char(10),
	@src			char(3),
	@market		char(3),
	@packages	char(50),
	@srqs		   varchar(30),
	@amenities  varchar(30)

select @ret=0, @msg='ok'

begin tran
save  tran p_gds_sc_block_change_s1

select @sta = sta, @osta = osta, @src=src,@market=market,@packages=packages,@srqs=srqs,@amenities=amenities 
	from sc_master where accnt = @grpaccnt
if @@rowcount = 0 
begin
	select @ret = 1, @msg = '当前%1不存在^Block'
	goto gout 
end
update sc_master set sta = sta where accnt = @grpaccnt
update chktprm set code = 'A'

if @sta<>@osta 
begin
	if @sta = 'R' 
	begin
		delete rsvsrc_log where accnt=@grpaccnt 

		declare c_block cursor for select type,begin_,end_,gstno,quantity,rate,remark 
			from rsvsrc_wait where accnt=@grpaccnt and id>0  order by type,begin_
		open c_block 
		fetch c_block into @type,@begin,@end,@gstno,@quan,@rate,@remark 
		while @@sqlstatus = 0
		begin
			select @msg = 'sc!'
			exec p_gds_reserve_rsv_add @grpaccnt,@type,'','T',@begin,@end,@quan,@gstno,@rate,@remark,
				@rate,'',@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
			if @ret<>0 
			begin
				close c_block
				deallocate cursor c_block 
				goto gout 
			end
			
			fetch c_block into @type,@begin,@end,@gstno,@quan,@rate,@remark  
		end
		close c_block
		deallocate cursor c_block 

		delete rsvsrc_wait where accnt=@grpaccnt 
	end
	else if @sta = 'W'
	begin
		delete rsvsrc_wait where accnt=@grpaccnt
		insert rsvsrc_wait select * from rsvsrc where accnt=@grpaccnt and id>0 
		exec @ret = p_gds_sc_release_block @grpaccnt, @empno 
	end
	else if @sta='X' or @sta='N'
	begin
		delete rsvsrc_wait where accnt=@grpaccnt
		exec @ret = p_gds_sc_release_block @grpaccnt, @empno 
	end
end


gout:
if @ret<>0 
	rollback tran p_gds_sc_block_change_s1
commit tran 
return @ret
;