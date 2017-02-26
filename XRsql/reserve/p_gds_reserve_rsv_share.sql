----------------------------------------------------------------------------------------------
--		�ͷ���Դ������� - share  ͬס,����
--
--		�����Ѿ������� ? 6.18
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
	@class		char(1),		-- �˺���� Fit, Grp, Met, Csm
	@saccnt		char(10),
	@master		char(10),
	@rateok		char(1),
	@count		int,
	@host_id		varchar(30),
	@sactlink	char(10),
	@arr			datetime,	-- ��¼����ʱ�������
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
if @class not in ('F', 'G', 'M', 'C', 'B' )  -- �����ʲ����漰�ͷ���  ����̫���� ?
begin
	select @ret=1, @msg='���ʺ����Ͳ���Ԥ���ͷ���Դ ! ---- %1^' + @class + ' - ' + @accnt
	goto gout
end

select @arr=@begin, @dep=@end
select @begin = convert(datetime,convert(char(8),@begin,1))
select @end = convert(datetime,convert(char(8),@end,1))

if @begin>@end 
begin
	select @ret=1, @msg = '���ڴ�С����'
	goto gout
end

if exists(select 1 from rsvsrc where accnt=@accnt and type=@type and roomno=@roomno 
	and blkmark=@blkmark and begin_=@begin and end_=@end and quantity=@quan and gstno=@gstno 
	and rate=@rate and remark=@remark and saccnt<>'')
begin
	select @ret=1, @msg = '�ü�¼�Ѿ����̣������ٴμ���'
	goto gout
end
if @quan=0 
begin
	select @ret=1, @msg='���� = 0'
	goto gout
end
if @roomno<>'' and @quan>1
begin
	select @ret=1, @msg='�з��ŵ������,�������� = 1'
	goto gout
end

-- id : ע��ȡֵ
if exists(select 1 from rsvsrc where accnt=@accnt)
	select @id = (select max(id) from rsvsrc where accnt=@accnt) + 1
else
	if @class = 'F'  	-- fit
		select @id = 0   -- ���������ϵ���Դ
	else					-- grp, meet
		select @id = 1

if @roomno<>'' -- ��Ҫ�ж� share
begin
	exec p_gds_reserve_rsv_get_saccnt @roomno, @begin, @end
	-- �� saccnt ��û��ǣ����ֱ�����ӣ�(ע���ж�ǣ��������)
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
	
	-- �ոհ�����ĳ�� saccnt �ķ�Χ����ֻ��ֱ�Ӳ��� rsvsrc��@begin=@end ������ض���������
	select @saccnt = isnull((select min(saccnt) from rsvsaccnt where roomno=@roomno and @begin>=begin_ and @end<=end_), '')
	if @saccnt <> ''
	begin
		insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt,master,rateok,arr,dep)
			values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,@saccnt,@accnt,'F',@arr,@dep)
		update master set saccnt=@saccnt where accnt = @accnt and @id = 0  -- master=@master, 
		update rsvsrc set rateok='F' where saccnt=@saccnt
		goto gout
	end
	
	-- �н��棺�ҳ���Ӧ�� saccnt,����ȡ����صĶ�����
	declare c_del cursor for select saccnt from linksaccnt where host_id=@host_id order by saccnt
	open c_del
	fetch c_del into @saccnt
	while @@sqlstatus = 0
	begin
		exec p_gds_reserve_rsv_del_saccnt @saccnt  -- ͬʱɾ�� rsvsaccnt �еļ�¼
		fetch c_del into @saccnt
	end
	close c_del
	deallocate cursor c_del
	
	-- ����������� rsvsrc
	insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt,master,rateok,arr,dep)
		values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,'',@accnt,'F',@arr,@dep)
	insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id from rsvsrc 
		where saccnt in (select saccnt from linksaccnt where host_id=@host_id) or (accnt=@accnt and id=@id)
end
else	-- û�з���,����ٶ�û�� share��ֱ�����ӣ�
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