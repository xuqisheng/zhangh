if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_add")
	drop proc p_gds_reserve_rsv_add;
create proc p_gds_reserve_rsv_add
	@accnt		char(10),
	@type			char(5),
	@roomno		char(5),
	@blkmark		char(1),
	@begin		datetime,				-- ����ʱ��
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
--		�ͷ���Դ������� - rsv add
--
--	 master - ��θ�����Ҫ��ϸ����
--		2005/2 master.master �ڲ��� master ��ʱ�����������ֱ��ȡ�����ü���
--		2007.8 .master ��������ͬס���
----------------------------------------------------------------------------------------------

declare
	@id			int,
	@class		char(1),		-- �˺���� Fit, Grp, Met, Csm, Bok
	@saccnt		char(10),
	@master		char(10),
	@rateok		char(1),
	@count		int,
	@host_id		varchar(30),
	@sactlink	char(10),
	@arr			datetime,	-- ��¼����ʱ�������
	@dep			datetime,
	@marr			datetime,	-- ����������
	@mdep			datetime,
	@over			int,
	@Grid_Rood	int,
	@logmark		int,
	@grpblk_self		char(1),		-- ��������Ԥ�����Ǵ�Ԥ��
	@rmtag		char(1),
	@sc			char(1),
	@blkuse		char(1),				-- block Ӧ�ò��ж���Դ 
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
select @rsvchk='1'  -- ��Ҫ��֤ 
if charindex('rsvchk=0;', @msg)>0 
	select @rsvchk='0' -- ����Ҫ��֤ 

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

-- ȡ���ŷ���ʱ����Ҫ�ж���Դ�������⣻
if @remark = 'Grid-Rood'  
	select @Grid_Rood = 1
else
	select @Grid_Rood = 0

select @ret=0, @host_id = host_id(), @rateok='F'
delete linksaccnt where host_id=@host_id
delete rsvsrc_1 where host_id=@host_id
delete rsvsrc_2 where host_id=@host_id
-- delete rsvsrc_blk where host_id=@host_id   -- �ù��̿���Ƕ�׵��ã��ñ��Ѿ���������������� 

begin tran
save 	tran rsvsrc_add

if @sc='F'
	select @class=class, @master=master, @marr=arr, @mdep=dep, @blkcode=blkcode from master where accnt=@accnt 
else
	select @class=class, @master=master, @marr=arr, @mdep=dep, @blkcode='' from sc_master where accnt=@accnt 
if @blkcode<>''
	select @blkuse='T' 

if @class not in ('F', 'G', 'M', 'C', 'B')  -- �����ʲ����漰�ͷ���  ����̫���� ?
begin
	select @ret=1, @msg='���ʺ����Ͳ���Ԥ���ͷ���Դ'
	goto gout
end
if charindex(@class, 'GMB')>0 and @type='PM' -- ���崿Ԥ��
	select @grpblk_self = 'T'
else
	select @grpblk_self = 'F'
if @end is null or @begin=@end
	select @end = dateadd(dd, 1, @begin)
if ((charindex(@class, 'GM')>0 and @grpblk_self='F') or @class='B') 
	 and (datediff(dd,@marr,@begin)<0 or datediff(dd,@mdep,@end)>0)
begin
	select @ret=1, @msg='�ͷ�Ԥ�����䲻�ܳ��������ĵ�������'
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

----------------------------------------------------------------------------------------------------
-- id : ע��ȡֵ
--if exists(select 1 from rsvsrc where accnt=@accnt)
--	select @id = (select max(id) from rsvsrc where accnt=@accnt) + 1
--else
--	if charindex(@class, 'GM')>0 and @grpblk_self='F'
--		select @id = 1   -- ����Ĵ�Ԥ��
--	else					
--		select @id = 0   -- �����ϵ���Դ

if charindex(@class, 'GMB')>0 and @grpblk_self='T'
	select @id = 0   -- ���������ϵ���Դ
else
begin					
	if exists(select 1 from rsvsrc where accnt=@accnt)
		select @id = (select max(id) from rsvsrc where accnt=@accnt) + 1
	else if charindex(@class, 'GMB')>0 
		select @id = 1   -- ����Ĵ�Ԥ��
	else
		select @id = 0   -- �����ϵ���Դ
end

----------------------------------------------------------------------------------------------------

select @rmtag = tag from typim where type=@type 
if @id > 0 and @rmtag='P'
begin
	select @ret=1, @msg='��Ԥ������ʹ�üٷ�'
	goto gout
end

--
if @blkcode<>'' 
	exec p_gds_reserve_rsv_blkdiff @host_id, @blkcode, @type, @begin, @end, 'before'

-- 
if @roomno<>'' -- ��Ҫ�ж� share
begin
	exec p_gds_reserve_rsv_get_saccnt @roomno, @begin, @end

	-- �� saccnt ��û��ǣ����ֱ�����ӣ�(ע���ж�ǣ��������)
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
	
	-- �ոհ�����ĳ�� saccnt �ķ�Χ����ֻ��ֱ�Ӳ��� rsvsrc��@begin=@end ������ض���������
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
	select @logmark = isnull((select max(logmark) from rsvsrc_log where accnt=@accnt and id=@id), 0) + 1
	insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt,master,rateok,arr,dep,
					rmrate,rtreason,ratecode,src,market,packages,srqs,amenities,cby,changed,logmark,blkcode)
		values(@accnt,@id,@type,@roomno,@blkmark,@begin,@end,@quan,@gstno,@rate,@remark,'',@master,'F',@arr,@dep,
					@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,getdate(),@logmark,@blkcode)
	insert rsvsrc_1(host_id,accnt,id) select @host_id,accnt,id from rsvsrc 
		where saccnt in (select saccnt from linksaccnt where host_id=@host_id) or (accnt=@accnt and id=@id)
end
else	-- û�з���,����ٶ�û�� share��ֱ�����ӣ�
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
-- block Ӧ�ô��� 
if @ret=0 and @blkcode<>'' -- and @rsvchk='1' 
begin
	exec p_gds_reserve_rsv_blkdiff @host_id, @blkcode, @type, @begin, @end, 'after'
	if exists(select 1 from rsvsrc_blk where host_id=@host_id and blkcode=@blkcode and type=@type and 2*rmnum1-rmnum2<0) 
	begin
		select @ret=1, @msg='����BlockԤ����Χ'
--		select * from rsvsrc_blk where host_id=@host_id 
	end 	
	else
	begin 
		exec @ret = p_gds_reserve_rsv_blkuse @host_id, @blkcode, @type, @empno 
		if @ret<>0
			select @msg='����BlockԤ����Χ'
--			select @msg='Block Ӧ�ô���add'		-- �����ʾ�û������� 
	end 
end

if @ret = 0
begin
	exec p_gds_reserve_rsv_host_reb @host_id

	-- ��Դ�ж�
--	if @begin<>@end and @roomno='' and @Grid_Rood <> 1
	if @begin<>@end and @Grid_Rood <> 1 and @rmtag='K' and @blkuse='F' and @rsvchk='1' 
	begin
		exec @ret = p_gds_reserve_type_avail @type,@begin,@end,'1','R',@over output
		if @ret<>0 or @over<0
			select @ret=1, @msg='�ͷ���Ԥ��'
		else
		begin
			exec p_gds_reserve_ctrltype_check @type, @begin, @end, 'R', @over output
			if @over > 0
				select @ret=1, @msg='�ͷ��������Ƴ���1'
			else
			begin 
				exec p_gds_reserve_ctrlblock_check @begin, @end, 'R', @over output
				if @over > 0
					select @ret=1, @msg='�ͷ��������Ƴ���2'
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
	--��Ԥ�����۲��  yjw 2008-5-29
	exec p_yjw_rsvsrc_detail_accnt_grp @accnt,@id
end

--
if @retmode='S'
	select @ret, @msg
return @ret
;