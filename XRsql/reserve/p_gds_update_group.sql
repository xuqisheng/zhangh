
if exists(select * from sysobjects where name = "p_gds_update_group")
	drop proc p_gds_update_group
;
create  proc p_gds_update_group
	@grpaccnt 			char(10),
	@empno    			char(10),
	@logmark  			int,
	@nullwithreturn  	varchar(60) output
as

------------------------------------------------------
--		������Ϣ�޸� ---����
--
--			�ͷ���Դ  �����ص�!!!
--			����
--			p_gds_maintain_group
--			p_gds_master_grpmid
--
------------------------------------------------------
declare
   @ret      		int,
   @msg      		varchar(60),
   @sta      		char(1),
   @exp_sta  		char(1),
   @oexp_sta 		char(1),
   @oarr     		datetime,
   @odep     		datetime,
   @arr      		datetime,
   @dep      		datetime,
   @rm_type  		char(5),
   @quantity 		int ,
   @memaccnt 		char(10)

declare
	@id				int,
	@r_type			char(5),
	@r_roomno		char(5),
	@r_blkmark		char(1),
	@r_begin			datetime,
	@r_end			datetime,
	@r_quan			int,
	@r_gstno			int,
	@r_rate			money,
	@r_remark		varchar(50),
	@ii				int

-- New begin
declare	
	@rmrate		money,
	@rtreason	char(3),
	@ratecode   char(10),
	@src			char(3),
	@market		char(3),
	@packages	varchar(50),
	@srqs		   varchar(30),
	@amenities  varchar(30)

begin tran
save  tran p_gds_update_group_s1

select @ret=0, @msg = ""
update master set sta = sta where accnt = @grpaccnt
select @sta = sta,@arr = arr,@dep = dep,@oarr = oarr,@odep = odep,@exp_sta=exp_sta
	from master where accnt = @grpaccnt and class in ('G', 'M')
if @@rowcount = 0
begin
	select @ret = 1,@msg = "��������%1������^"+@grpaccnt
	goto gout
end

select  @arr  = convert(datetime,convert(char(10),@arr,111))
select  @dep  = convert(datetime,convert(char(10),@dep,111))
select  @oarr = convert(datetime,convert(char(10),@oarr,111))
select  @odep = convert(datetime,convert(char(10),@odep,111))

-- logmark = 99999 ��ʾ��Ա/Ԥ�����ڲ����������ڸı䣻(�ͻ�������)
if not (@arr = @oarr and (@dep = @odep or datediff(day,@arr,@dep) <= 1 and datediff(day,@oarr,@odep) <= 1))
	and @logmark <> 99999
begin
	-- ���´�����Դ�ͳ�Ա�ı仯
	-- ����Դ�������������ڲ�һ�£����������������볤�ȷ����仯��ʱ��ͬ����δ����أ�����Դ�������������
	--	Ŀǰ��������
	--		1.��Դ���������������Ǻϵģ�������ȡ�Ǻϵķ�ʽ
	--		2.������Դ���������嵽�յȱ���ƽ�ƣ����Ȳ�������������������ɾ�� 
	-- 	3.�����Դ�Ѿ���ס�ˣ���Ҫ�����Ƿ��ܹ�����
	-- 	4.ע��������ں󣬱���Ԥ���ľ���ʱ�� 

	select @ii = datediff(dd, @oarr, @arr) 

	-- ���������� ��Ԥ�� ��Ϣ
	declare c_update_group cursor for 
		select id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,
				rmrate,rtreason,ratecode,src,market,packages,srqs,amenities
			from rsvsrc where accnt = @grpaccnt and id>0   -- id=0 ���������������Դ��¼
	open c_update_group
	fetch c_update_group into @id,@r_type,@r_roomno,@r_blkmark,@r_begin,@r_end,@r_quan,@r_gstno,@r_rate,@r_remark,
			@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities
	while @@sqlstatus = 0
	begin
		if datediff(dd,@r_begin,@oarr)=0 and datediff(dd,@r_end,@odep)=0   -- ���ﲻ�ÿ���ʱ��ģ����ڼ��� 
			select @r_begin=@arr, @r_end=@dep
		else
		begin
			select @r_begin=dateadd(dd, @ii, @r_begin), @r_end=dateadd(dd, @ii, @r_end)
			if datediff(dd,@dep,@r_end)>0 select @r_end=@dep 
		end 
		exec p_gds_reserve_rsv_mod @grpaccnt,@id,@r_type,@r_roomno,@r_blkmark,@r_begin,@r_end,
				@r_quan,@r_gstno,@r_rate,@r_remark,
				@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
		if @ret <> 0	goto gout
	--��Ԥ�����۲��  yjw 2008-5-29
--      exec p_yjw_rsvsrc_detail_accnt_grp @grpaccnt,@id
	--
		fetch c_update_group into @id,@r_type,@r_roomno,@r_blkmark,@r_begin,@r_end,@r_quan,@r_gstno,@r_rate,@r_remark,
			@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities
	end
	close c_update_group
	deallocate cursor c_update_group
	
	-- ��Ա���� - ע�Ᵽ�����ڵ�ʱ�� 
	declare c_mem cursor for select accnt,arr,dep,sta from master 
		where groupno = @grpaccnt and charindex(sta,'IRCG') > 0 
			order by roomno,accnt
	open c_mem
	fetch c_mem into @memaccnt,@r_begin,@r_end,@sta
	while @@sqlstatus = 0
	begin
		if datediff(dd,@r_begin,@oarr)=0 and datediff(dd,@r_end,@odep)=0 
		begin
			if @sta <> 'I'
				select @r_begin=convert(datetime, convert(char(10), @arr, 111) + ' ' + convert(char(8), @r_begin, 8))
			select @r_end=convert(datetime, convert(char(10), @dep, 111) + ' ' + convert(char(8), @r_end, 8))
		end 
		else
		begin
			select @r_begin=dateadd(dd, @ii, @r_begin), @r_end=dateadd(dd, @ii, @r_end)
			if datediff(dd,@dep,@r_end)>0 select @r_end=convert(datetime, convert(char(10), @dep, 111) + ' ' + convert(char(8), @r_end, 8))
		end 
		update master set arr = @r_begin,dep=@r_end where accnt = @memaccnt
		if @@rowcount > 0
		begin
			exec @ret = p_gds_reserve_chktprm @memaccnt,'4','',@empno,'P',0,0,@msg output
			update master set logmark=logmark+1,cby=@empno,changed=getdate() where accnt = @memaccnt
			if @ret <> 0
			begin
				select @msg = "[��Ա�ʺ� - %1] ^"+@memaccnt+@msg
				goto gout
			end
		end

		fetch c_mem into @memaccnt,@r_begin,@r_end,@sta
	end
	close c_mem
	deallocate cursor c_mem
end

-- ��ԭ logmark
if @logmark = 99999
	select @logmark = 0

-- ����
if (@oexp_sta is null and @exp_sta is not null) or (@oexp_sta is not null and @exp_sta is null) or @oexp_sta <> @exp_sta
   begin
   update master set exp_sta = @exp_sta where groupno = @grpaccnt
   update rmsta  set logmark=logmark+1,empno=@empno,changed=getdate()
		where roomno in (select b.roomno from master b where b.groupno=@grpaccnt and b.roomno <> space(5) and charindex(b.sta,'RCGI') > 0)
   end

-- update group master 
update master set oarr = arr,odep = dep,cby=@empno,changed=getdate() where accnt = @grpaccnt
exec @ret = p_gds_maintain_group @grpaccnt,@empno,@logmark,@msg output
if @ret = 0
	exec p_gds_master_grpmid @grpaccnt, 'R', @ret output,  @msg output

-- ������Ԥ���ĵ�����뿪���� �� ׼ȷʱ��
select @arr = arr,@dep = dep from master where accnt = @grpaccnt
update rsvsrc set arr = @arr where accnt = @grpaccnt and datediff(dd,arr,@arr)=0 and arr<>@arr and id>0
update rsvsrc set dep = @dep where accnt = @grpaccnt and datediff(dd,arr,@dep)=0 and dep<>@dep and id>0

-- End ...
gout:
if @ret <> 0
   rollback tran p_gds_update_group_s1
commit tran
if @nullwithreturn is null
   select @ret,@msg
else
   select @nullwithreturn = @msg
return @ret
;
