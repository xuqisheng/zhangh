----------------------------------------------------------------------------------------------
--		�ͷ���Դ������ĳ���
--
--		
--		1.���ǵ�ɢ��, ����ͬʱ���õ����, ������һ���˺Ų���,������Ͽͷ���Դ����Ϣ (�������崿Ԥ��)
--		2.�пͷ��������, saccnt �����Զ����ɣ����Ƿ���ͬס����Ҫ����Ӧ�����������
--
--
--			�����Ͽ��������Ϊ�������
--				1����������¼û��ǣ�����Լ���������
--				2����ǣ������Ҫ��ɢ��ص� saccnt, Ȼ�����½�����
--
--		saccnt ��Ԥ�������䡢�ŷ� �������뷨����*****�������棩
--			1��quan>1 ��Ӧ�� rsvsrc �϶�ֻ��һ�С���ʱ��rsvsrc.id>0 �ͱ�ʾ�Ǵ�Ԥ����û�з������������� 1 ����������
--			2��quan=1 ��Ӧ�� rsvsrc �����ж��С�
--
--		һ�����ʣ�����������������Ҫ��Ҳ��û�з��䣬���ž��Ѿ����ˡ�
--		���磬ɢ�Ͷ�����ʱ��һ���˺�Ԥ�����ͷ�������ָ���˿ͷ�����ʱ����ͳ��˼·�����ŷ������ڷ�������
--		������⣺��ȫ�� saccnt Ϊ׼���з��ž��Ƿ�����ŷ�������ֻ��Ԥ�����ѷ���ĸ���ȥ����ֻ��Ԥ�����ŷ���
--		rsvsaccnt �ͺñ���Ԥ������ master, һ��rsvsaccnt ��¼����һ�����䡣
--
--
--		�������������ҪǶ������ʹ�ã���˲���ʹ����ʱ�����Բ��� rsvsrc_1, rsvsrc_2, linksaccnt
----------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------
--	���ǵ����� proc �ĸ����ԣ�һ��Ϊ�� 
--		p_gds_reserve_rsv_add / p_gds_reserve_rsv_del / p_gds_reserve_rsv_mod
----------------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_edit")
	drop proc p_gds_reserve_rsv_edit;
//create proc p_gds_reserve_rsv_edit
//	@accnt		char(10),
//	@id			int,
//	@type			char(5),
//	@roomno		char(5),
//	@blkmark		char(1),
//	@begin		datetime,
//	@end			datetime,
//	@quan			int,
//	@gstno		int,
//	@rate			money,
//	@remark		varchar(50),
//	@mode			char(3),			-- DEL, ADD, MOD
//	@retmode		char(1),			-- S, R
//	@ret        int	output,
//   @msg        varchar(60) output
//as
//
//declare
//	@out			int,			-- ��ʾ�Ƿ����ɨ�裬�˳�����
//	@class		char(1),		-- �˺���� Fit, Grp, Met, Csm
//	@saccnt		char(10),
//	@count		int,
//	@host_id		int,
//	@sactlink	char(10)
//
//
//declare		-- ��¼�������һ�εı���������ԭ���ļ�¼��
//	@oid			int,
//	@oblkmark	char(1),
//	@oquan		int,
//	@ogstno		int,
//	@orate		money,
//	@oremark		varchar(50),
//	@otype		char(5),
//	@oroomno		char(5),
//	@obegin		datetime,
//	@oend			datetime
//
//declare		-- date for saccnt
//	@sbegin		datetime,
//	@send			datetime
//
//
//select @host_id = convert(int, host_id())
//select @ret=0, @msg='', @out=0
//select @otype='',@oroomno='',@obegin='1980.1.1',@oend='1980.1.2'
//
//delete linksaccnt where host_id=@host_id
//delete rsvsrc_1 where host_id=@host_id
//delete rsvsrc_2 where host_id=@host_id
//
//select @class=class from master where accnt=@accnt 
//if @class not in ('F', 'G', 'M')  -- �����ʲ����漰�ͷ���  ����̫���� ?
//begin
//	select @ret=1, @msg='���ʺ����Ͳ���Ԥ���ͷ���Դ ! ---- ' + @accnt
//	if @retmode='S'
//		select @ret, @msg
//	return @ret
//end
//
//
//begin tran
//save tran rsvsrc_edit
//-------------------------------------------------------------------
//-- ��� @begin=@end, p_gds_reserve_filldtl ��������һ���Ĳ��� - day use 
//-------------------------------------------------------------------
//--	ADD: ������Чֵ--�ͷ�Ԥ����Ϣ
//--		  id ��Ҫ�ɳ����Զ����ɣ�
//-------------------------------------------------------------------
//if @mode = 'ADD' 
//begin
//	select @begin = convert(datetime,convert(char(8),@begin,1))
//	select @end = convert(datetime,convert(char(8),@end,1))
//	if @begin>@end 
//	begin
//		select @ret=1, @msg = '���ڴ�С����'
//		goto gout
//	end
//
//	if exists(select 1 from rsvsrc where accnt=@accnt and type=@type and roomno=@roomno 
//		and blkmark=@blkmark and begin_=@begin and end_=@end and quantity=@quan and gstno=@gstno 
//		and rate=@rate and remark=@remark and saccnt<>'')
//	begin
//		select @ret=1, @msg = '�ü�¼�Ѿ����̣������ٴμ���'
//		goto gout
//	end
//	if @quan=0 
//	begin
//		select @ret=1, @msg='���� = 0'
//		goto gout
//	end
//	if @roomno<>'' and @quan>1
//	begin
//		select @ret=1, @msg='�з��ŵ������,�������� = 1'
//		goto gout
//	end
//
//	-- id : ע��ȡֵ
//	if exists(select 1 from rsvsrc where accnt=@accnt)
//		select @id = (select max(id) from rsvsrc where accnt=@accnt) + 1
//	else
//		if @class = 'F'  	-- fit
//			select @id = 0   -- ���������ϵ���Դ
//		else					-- grp, meet
//			select @id = 1
//	
//	if @roomno<>'' -- ��Ҫ�ж� share
//	begin
//		exec p_gds_reserve_rsv_get_saccnt @roomno, @begin, @end
//		-- �� saccnt ��û��ǣ����ֱ�����ӣ�(ע���ж�ǣ��������)
//		if not exists(select 1 from linksaccnt where host_id=@host_id)
//		begin
//			exec p_GetAccnt1 'SAT', @saccnt output
//			select @sactlink=@accnt,@sbegin=@begin,@send=@end
//			insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//				values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt)
//			insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
//				values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan,@sactlink)
//			update master set saccnt=@saccnt where accnt = @accnt and @id = 0
//			exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
//			goto gout
//		end
//		
//		-- �ոհ�����ĳ�� saccnt �ķ�Χ����ֻ��ֱ�Ӳ��� rsvsrc��@begin=@end ������ض���������
//		select @saccnt = isnull((select min(saccnt) from rsvsaccnt where roomno=@roomno and @begin>=begin_ and @end<=end_), '')
//		if @saccnt <> ''
//		begin
//			insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//				values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt)
//			update master set saccnt=@saccnt where accnt = @accnt and @id = 0
//			goto gout
//		end
//		
//		-- �н��棺�ҳ���Ӧ�� saccnt,����ȡ����صĶ�����
//		declare c_del cursor for select saccnt from linksaccnt where host_id=@host_id order by saccnt
//		open c_del
//		fetch c_del into @saccnt
//		while @@sqlstatus = 0
//		begin
//			exec p_gds_reserve_rsv_del_saccnt @saccnt  -- ͬʱɾ�� rsvsaccnt �еļ�¼
//			fetch c_del into @saccnt
//		end
//		close c_del
//		deallocate cursor c_del
//		
//		-- ����������� rsvsrc
//		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,'')
//		insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id from rsvsrc 
//			where saccnt in (select saccnt from linksaccnt where host_id=@host_id) or (accnt=@accnt and id=@id)
//	end
//	else	-- û�з���,����ٶ�û�� share��ֱ�����ӣ�
//	begin
//		exec p_GetAccnt1 'SAT', @saccnt output
//		select @sactlink=@accnt,@sbegin=@begin,@send=@end
//		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt)
//		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
//			values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan,@sactlink)
//		update master set saccnt=@saccnt where accnt = @accnt and @id = 0  -- @id=0 !
//   	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
//		goto gout
//	end
//end
//------------------------------------------------------
//--	DEL: ������Чֵ -- accnt + id
//------------------------------------------------------
//else if @mode = 'DEL'
//begin
//	select @saccnt=saccnt from rsvsrc where accnt=@accnt and id=@id
//	if @@rowcount = 0
//	begin
//		select @ret=1, @msg='Ԥ����¼�����ڣ������Ѿ�ɾ��'
//		goto gout
//	end
//
//	if @id=0 and exists(select 1 from rsvsrc where accnt=@accnt and id<>@id)
//	begin
//		select @ret=1, @msg='����Ԥ����¼����ɾ��������ɾ��������Ԥ��'
//		goto gout
//	end
//
//	select @count = count(1) from rsvsrc where saccnt=@saccnt
//	-- û���κι�����
//	if @count = 1
//	begin
//		exec p_gds_reserve_rsv_del_saccnt @saccnt
//		delete rsvsrc where saccnt=@saccnt
//		goto gout
//	end
//	
//	select @sbegin = min(begin_) from rsvsrc where saccnt=@saccnt and not (accnt=@accnt and id=@id)
//	select @send = min(end_) from rsvsrc where saccnt=@saccnt and not (accnt=@accnt and id=@id)
//	--��ȥ�ü�¼���� saccnt �����ڷ�Χû��Ӱ�죻
//	if exists(select 1 from rsvsaccnt where saccnt=@saccnt and begin_=@sbegin and end_=@send)
//	begin
//		delete rsvsrc where accnt=@accnt and id=@id
//		goto gout
//	end
//
//	-- saccnt �Ķ�Ӧ�����б仯����Ҫ���½�����
//	exec p_gds_reserve_rsv_del_saccnt @saccnt
//	delete rsvsrc where accnt=@accnt and id=@id
//	insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id
//			from rsvsrc where saccnt = @saccnt
//end
//------------------------------------------------------
//--	MOD: ������Чֵ -- accnt + id + type + .....
//--			�¾ɲ����ĶԱȣ�����Ҫ����ķ���
//-- 		��¼���޸��ж�����ʽ���ͷ������ڡ�������������Ϣ�ȵȣ�
//------------------------------------------------------
//else if @mode = 'MOD'
//begin
//	select @saccnt=saccnt, @otype=type,@oroomno=roomno,@oblkmark=blkmark,@obegin=begin_,@oend=end_,
//		@oquan=quantity,@ogstno=gstno,@orate=rate,@oremark=remark
//		from rsvsrc where accnt=@accnt and id=@id
//	if @@rowcount = 0
//	begin
//		select @ret=1, @msg='Ԥ����¼�����ڣ������Ѿ�ɾ��'
//		goto gout
//	end
//	if @quan=0 
//	begin
//		select @ret=1, @msg='���� = 0'
//		goto gout
//	end
//	if @roomno<>'' and @quan>1 
//	begin
//		select @ret=1, @msg='�з��ŵ������,�������� = 1'
//		goto gout
//	end
//
//	-- �޸���Ԥ���޹أ�
//	if @otype=@type and @oroomno=@roomno and @obegin=@begin and @oend=@end and @oquan=@quan
//	begin
//		update rsvsrc set blkmark=@blkmark,gstno=@gstno,rate=@rate,remark=@remark 
//			where accnt=@accnt and id=@id
//		goto gout
//	end
//
//	select @count = count(1) from rsvsrc where saccnt=@saccnt 
//	if @count=1 and @otype=@type and @oroomno=@roomno and @obegin<=@begin and @oend>=@end and @oquan=@quan
//	begin
//		-- ֻ��һ�У�û��ͬס��ϵ���������ڰ�������ǰ�����䣬ֱ�Ӵ���
//		exec p_gds_reserve_rsv_del_saccnt @saccnt
//		delete rsvsrc where accnt=@accnt and id=@id
//		select @sbegin=@begin,@send=@end  -- ��ʱ, @saccnt ������������
//		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt)
//		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
//			values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan,@accnt)
//		update master set saccnt=@saccnt where accnt = @accnt and @id = 0
//   	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
//		goto gout
//	end 
//	elseif @count>1
//		select @sbegin = min(begin_) from rsvsrc where saccnt=@saccnt and not (accnt=@accnt and id=@id)
//		select @send = min(end_) from rsvsrc where saccnt=@saccnt and not (accnt=@accnt and id=@id)
//		--��ȥ�ü�¼���� saccnt �����ڷ�Χû��Ӱ�죻
//		if exists(select 1 from rsvsaccnt where saccnt=@saccnt and type=@type and roomno=@roomno and begin_=@sbegin and end_=@send)
//		begin
//			update rsvsrc set begin_=@begin,end_=@end,blkmark=@blkmark,gstno=@gstno,rate=@rate,remark=@remark
//				where accnt=@accnt and id=@id
//			goto gout
//		end
//	end
//
//	-- �ı��˿ͷ���Ϣ�����ߵ���saccnt���ڱ仯����Ҫ�ؽ���
//	exec p_gds_reserve_rsv_del_saccnt @saccnt
//	update rsvsrc set type=@type,roomno=@roomno,begin_=@begin,end_=@end,blkmark=@blkmark,
//		gstno=@gstno,rate=@rate,remark=@remark where accnt=@accnt and id=@id
//	if @roomno<>'' 
//	begin
//	end
//	else
//	begin
//	end
//	
//	exec p_gds_reserve_rsv_get_saccnt @roomno, @begin, @end
//	-- �� saccnt ��û��ǣ����ֱ�����ӣ�(ע���ж�ǣ��������)
//	if not exists(select 1 from linksaccnt where host_id=@host_id)
//	begin
//		exec p_GetAccnt1 'SAT', @saccnt output
//		select @sactlink=@accnt,@sbegin=@begin,@send=@end
//		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt)
//		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
//			values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan,@sactlink)
//		update master set saccnt=@saccnt where accnt = @accnt and @id = 0
//		exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
//		goto gout
//	end
//	
//	-- �ոհ�����ĳ�� saccnt �ķ�Χ����ֻ��ֱ�Ӳ��� rsvsrc��@begin=@end ������ض���������
//	select @saccnt = isnull((select min(saccnt) from rsvsaccnt where roomno=@roomno and @begin>=begin_ and @end<=end_), '')
//	if @saccnt <> ''
//	begin
//		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt)
//		update master set saccnt=@saccnt where accnt = @accnt and @id = 0
//		goto gout
//	end
//	
//	-- �н��棺�ҳ���Ӧ�� saccnt,����ȡ����صĶ�����
//	declare c_del cursor for select saccnt from linksaccnt where host_id=@host_id order by saccnt
//	open c_del
//	fetch c_del into @saccnt
//	while @@sqlstatus = 0
//	begin
//		exec p_gds_reserve_rsv_del_saccnt @saccnt  -- ͬʱɾ�� rsvsaccnt �еļ�¼
//		fetch c_del into @saccnt
//	end
//	close c_del
//	deallocate cursor c_del
//	
//	-- ����������� rsvsrc
//	insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt)
//		values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,'')
//	insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id from rsvsrc 
//		where saccnt in (select saccnt from linksaccnt where host_id=@host_id) or (accnt=@accnt and id=@id)
//	goto gout
//end
//
//gout:
//
////-- ��� rsvsrc_1 ������¼����ʾ����Ҫ�ؽ��Ĳ��֣�
////declare c_src cursor for select accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark
////	from rsvsrc_1 where @ret=0 and host_id=@host_id order by type,roomno,begin_,end_,quantity
////open c_src
////fetch c_src into @accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark
////while 1 = 1
////begin
////	if @@sqlstatus <> 0 	-- @out=1 : ��ʾ����ɨ��
////		select @out = 1, @begin='1980.1.1',@end='1980.1.2'
////	
////	-- û�з��ŵ�����£�ԭ���� share ��Ϣ�����ȡ��
////
////	if (@type<>@otype or @roomno<>@oroomno or @begin>=@oend or @quan<>1 or @out=1) and exists(select 1 from rsvsrc_2 where host_id=@host_id)
////	begin																				-- saccnt ƴ��
////		select @sbegin = min(begin_) from rsvsrc_2  where host_id=@host_id
////		select @send = max(end_) from rsvsrc_2 where host_id=@host_id
////		select @saccnt = min(accnt) from rsvsrc_2 where host_id=@host_id
////
////		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity)
////			values(@saccnt,@type,@roomno,'',@sbegin,@send,@quan)
////		update master set saccnt=@saccnt where accnt in (select accnt from rsvsrc_2 where host_id=@host_id)
////		update rsvsrc set saccnt=@saccnt where accnt in (select accnt from rsvsrc_2 where host_id=@host_id)
////
////		-- ��Դ����
////   	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
////		delete rsvsrc_2  where host_id=@host_id
////	end
////
////	if @out = 1
////		break
////
////	if @quan > 1 or @roomno=''   	-- ��������1���϶�û�� share��
////											--û�з��ŵ�Ԥ����������ʱ���ж�ԭ����share 
////	begin
////		insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity)
////			values(@accnt,@type,@roomno,'',@begin,@end,@quan)
////		update master set saccnt=@accnt where accnt=@accnt and @id=0
////		update rsvsrc set saccnt=@accnt where accnt=@accnt and id=@id
////
////		-- ��Դ����
////   	exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@sbegin,@send,@quan
////
////	end
////	else
////		insert rsvsrc_2 values(@host_id,@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,'')
////
////	select @otype=@type,@oroomno=@roomno,@obegin=@begin,@oend=@end
////
////	fetch c_src into @accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark
////end
////close c_src
////deallocate cursor c_src
//
//-- end 
//if @ret <> 0
//	rollback tran rsvsrc_edit
//commit tran 
//if @retmode='S'
//	select @ret, @msg
//return @ret
//;
//

----------------------------------------------------------------------------------------------
--		saccnt delete 
--		�Զ���� srcsaccnt, rsvsrc �еļ�¼��Ҫ�ֹ�������������ã�
----------------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_del_saccnt")
	drop proc p_gds_reserve_rsv_del_saccnt;
create proc p_gds_reserve_rsv_del_saccnt
	@saccnt		char(10)
as
declare	
	@type			char(5),
	@roomno		char(5),
	@begin		datetime,
	@blkmark   	char(1),
	@end      	datetime,
	@quan  		int

select @type=type,@roomno=roomno,@begin=begin_,@blkmark=blkmark,@end=end_,@quan=quantity 
	from rsvsaccnt where saccnt=@saccnt
if @@rowcount <> 1
	return 0

select @quan = @quan * -1
if @roomno < '0'
	select @roomno = ''

exec p_gds_reserve_filldtl @saccnt,@type,@roomno,@begin,@end,@quan
delete rsvsaccnt where saccnt=@saccnt

return 0
;


----------------------------------------------------------------------------------------------
--		Ѱ��ʱ��ǣ���� saccnt (���ǵ� dayuse, ��ϸ�ж�)
--		������� linksaccnt (host_id)
--
--		��ͬס��ϵ��ʱ�򣬱ض��з��ţ�Ҳ��������ģ������ԣ�û�з��������
----------------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_get_saccnt")
	drop proc p_gds_reserve_rsv_get_saccnt;
create proc p_gds_reserve_rsv_get_saccnt
	@roomno		char(5),
	@begin		datetime,
	@end			datetime
as
-------------------------------------------------------------------
--	ʱ��ǣ��������, saccnt:[begin_,end_],   rsvsrc:[@begin,@end]
--		�������ӵ��յ�ԭ��
--				if begin_ =end_ and @begin =@end and @begin=begin_ then true
--				if begin_ =end_ and @begin<>@end and @begin<=begin_ and @end>begin_ then true
--				if begin_<>end_ and @begin =@end and @begin>=begin_ and @end<end_ then true
--				if begin_<>end_ and @begin<>@end and @begin <end_ and @end>begin_ then true
-------------------------------------------------------------------
declare	@host_id		varchar(30)
select @host_id = host_id()
delete linksaccnt where host_id=@host_id

insert linksaccnt select @host_id, saccnt from rsvsaccnt where roomno=@roomno
	and ( (begin_ =end_ and @begin =@end and @begin =begin_)
		or (begin_ =end_ and @begin<>@end and @begin<=begin_ and @end>begin_)
		or (begin_<>end_ and @begin =@end and @begin>=begin_ and @end<end_)
		or (begin_<>end_ and @begin<>@end and @begin <end_   and @end>begin_)
	)

return 0
;

----------------------------------------------------------------------------------------------
-- SACCNT  pointer 
----------------------------------------------------------------------------------------------
if not exists(select 1 from sys_extraid where cat='SAT')
	insert sys_extraid (cat, descript, id) 
	values('SAT', 'saccnt for room share', 0)
;
