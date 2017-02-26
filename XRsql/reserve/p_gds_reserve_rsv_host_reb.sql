if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_host_reb")
	drop proc p_gds_reserve_rsv_host_reb;
create proc p_gds_reserve_rsv_host_reb
	@host_id			varchar(30)
as
-----------------------------------------------------------------------------------
--		��� rsvsrc_1 ������¼����ʾ����Ҫ�ؽ��Ĳ��֣�
--		ע�����ⷿ��
--		master, rateok ����ȷ�� -- ?
-----------------------------------------------------------------------------------
declare
	@accnt		char(10),
	@id			int,
	@type			char(5),
	@roomno		char(5),
	@begin		datetime,
	@end			datetime,
	@quan			int,
	@out			int,			-- ��ʾ�Ƿ����ɨ�裬�˳�����
	@saccnt		char(10),
	@sactlink	char(10),
	@maxend		datetime,	-- ��¼��ǰ�ε� max end date
	@master		char(10),
	@rateok		char(1),
	@i				int 		

declare		-- ��¼�������һ�εı���������ԭ���ļ�¼��
	@otype		char(5),
	@oroomno		char(5),
	@sroomno		char(5),		-- in saccnt
	@mroomno		char(5),		-- ������ⷿ��ȡ����ʱ��,����
	@count		int,
	@sc			char(1)

declare		-- date for saccnt
	@sbegin		datetime,
	@send			datetime

delete rsvsrc_2 where host_id = @host_id
select @out=0,@otype='',@oroomno='',@maxend='1980.1.2', @rateok='F'

declare c_src cursor for 
	select a.accnt,a.id,b.type,b.roomno,b.begin_,b.end_,b.quantity
		from rsvsrc_1 a, rsvsrc b where a.host_id=@host_id and a.accnt=b.accnt and a.id=b.id
		order by type,roomno,begin_,end_,quantity
open c_src
fetch c_src into @accnt,@id,@type,@roomno,@begin,@end,@quan
while 1 = 1
begin
	if @@sqlstatus <> 0 	-- @out=1 : ��ʾ����ɨ��
		select @out = 1, @begin='1980.1.1',@end='1980.1.2'
	
	-- 
	if exists(select 1 from sc_master where accnt=@accnt and substring(foact,2,1)='S') 
		select @sc='T'
	else
		select @sc='F'

	-- û�з��ŵ�����£�ԭ���� share ��Ϣ�����ȡ��
	select @count = count(1) from rsvsrc_2 where host_id=@host_id
	if (@type<>@otype or @roomno<>@oroomno or @begin>=@maxend or @quan<>1 or @out=1) and @count>0
	begin																				-- saccnt ƴ��
		select @sbegin = min(b.begin_) from rsvsrc_2 a, rsvsrc b where a.host_id=@host_id and a.accnt=b.accnt and a.id=b.id
		select @send = max(b.end_) from rsvsrc_2 a, rsvsrc b where a.host_id=@host_id and a.accnt=b.accnt and a.id=b.id
		exec p_GetAccnt1 'SAT', @saccnt output
		select @sactlink = min(accnt) from rsvsrc_2 where host_id=@host_id  -- Ԥ������

		-- @sroom -- ���뵽 rsvsaccnt �е� roomno 
		if @oroomno like '#%'
			select @sroomno = ''
		else
			select @sroomno = @oroomno

		-- @mroom
		if @oroomno like '#%' and @count = 1
			select @mroomno = ''    -- ����ȡ���ˣ�Ϊʲô���ſ�Ϊ���޸����ڲ�ͬ������� 2008.10.6
		else
			select @mroomno = @oroomno

		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
			values(@saccnt,@otype,@sroomno,'',@sbegin,@send,1,@sactlink)

	-- ע�� col = master �ĸ���.  ���ﲻ��Ҫ���� sc_master 
		update master set roomno=@mroomno,oroomno=@mroomno,saccnt=@saccnt
			where accnt in (select accnt from rsvsrc_2 where host_id=@host_id and id=0)

		-- ���� master.master 
--		if @count = 1 
--			update master set master=accnt
--				where accnt in (select accnt from rsvsrc_2 where host_id=@host_id and id=0)
//		else
//		begin
//			select @i = count(distinct master) from master  
//				where accnt in (select accnt from rsvsrc_2 where host_id=@host_id and id=0)
//			if @i = 1 
//			begin
//				select @master = min(accnt) from rsvsrc_2 where host_id=@host_id and id=0
//				update master set master=@master 
//					where accnt in (select accnt from rsvsrc_2 where host_id=@host_id and id=0)
//			end
//			else
//				update master set master=accnt 
//					where accnt in (select accnt from rsvsrc_2 where host_id=@host_id and id=0)
//		end

		update rsvsrc set roomno=@mroomno,saccnt=@saccnt,rateok='F'  -- ,master=b.master
			from rsvsrc_2 a, master b where a.host_id=@host_id and a.accnt=rsvsrc.accnt and a.id=rsvsrc.id and a.accnt=b.accnt

		-- ��Դ����
   	exec p_gds_reserve_filldtl @saccnt,@otype,@sroomno,@sbegin,@send,1 -- @quan ����������϶�=1
		delete rsvsrc_2  where host_id=@host_id
		select @otype='',@oroomno='',@maxend='1980.1.2'
	end

	if @out = 1
		break

	if @quan > 1 or @roomno=''   	-- ��������1���϶�û�� share��û�з��ŵ�Ԥ����������ʱ���ж�ԭ����share 
	begin
		exec p_GetAccnt1 'SAT', @saccnt output
		select @sactlink = @accnt
		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
			values(@accnt,@type,@roomno,'',@begin,@end,@quan,@sactlink)
		if @sc='F'
			update master set saccnt=@accnt  -- , master=@accnt 
				where accnt=@accnt and @id=0
		else
			update sc_master set saccnt=@accnt  -- , master=@accnt 
				where accnt=@accnt and @id=0
		update rsvsrc set saccnt=@accnt,rateok='T' where accnt=@accnt and id=@id   -- ,master=@accnt

		-- ��Դ����
   	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
		select @otype='',@oroomno='',@maxend='1980.1.2'
	end
	else
	begin
		insert rsvsrc_2 values(@host_id,@accnt,@id)
		select @otype=@type,@oroomno=@roomno
		if @end > @maxend 
			select @maxend = @end
	end

	fetch c_src into @accnt,@id,@type,@roomno,@begin,@end,@quan
end
close c_src
deallocate cursor c_src

return 0
;
