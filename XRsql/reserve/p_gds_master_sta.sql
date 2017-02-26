IF OBJECT_ID('p_gds_master_sta') IS NOT NULL
    DROP PROCEDURE p_gds_master_sta
;
create proc p_gds_master_sta
	@accnt		char(10),
	@mode			char(20),		-- ����ģʽ
	@empno		char(10),
	@retmode		char(1),			-- S, R
	@ret        int	output,
   @msg        varchar(60) output,
   @nick    char(1) = ''    --ͬס�Ƿ�ͬ������ p��ͬ��
as
----------------------------------------------------------------------------------------------
--		��������״̬ά��
----------------------------------------------------------------------------------------------
declare		@sta		char(1),
				@osta		char(1),
				@ressta	char(1),
				@class	char(1),
				@arr		datetime,
				@dep		datetime,
				@type		char(5),
				@roomno	char(5),
				@bdate	datetime,
				@sysvalue	varchar(255),
				@master	char(10) 

select @ret=0, @msg='ok', @bdate=bdate1 from sysdata

begin tran
save 	tran master_sta

select @osta=sta,@ressta=ressta,@class=class,@arr=arr,@dep=dep,@type=type,@roomno=roomno, @master=master from master where accnt=@accnt
if @@rowcount <> 1
begin
	select @ret=1, @msg='%1������^����'
	goto gout
end
if @class in ('G', 'M', 'C') and @type<>'' and @type<>'PM'
begin
	select @ret=1, @msg='%1��ƥ��^����'
	goto gout
end

update master set sta=sta where accnt=@accnt

----------------------------------
--	�Ǽ�
----------------------------------
if @mode='checkin'
begin
	if charindex(@class, 'FGM')=0
	begin
		select @ret=1, @msg='%1����^�������'
		goto gout
	end
	if @osta='I'
	begin
		select @ret=0, @msg='�ò����Ѿ�����'
		goto gout
	end
	if charindex(@osta,'RS')=0
	begin
		select @ret=1, @msg='%1����^����״̬'
		goto gout
	end
	if datediff(dd,@dep,getdate())>0
	begin
		select @ret=1, @msg='���մ���'
		goto gout
	end
	if datediff(dd,@arr,getdate())<>0
	begin
		select @ret=1, @msg='���ȵ�������'
		goto gout
	end

	if @class='F' or (@type<>'' and charindex(@class, 'GMC')>0)
	begin
		if @roomno<'0'  -- ע�����ⷿ��
		begin
			select @ret=1, @msg='���ȷ��䷿��'
			goto gout
		end
		update master set sta='I',arr=getdate(),cby=@empno,changed=getdate(),logmark=logmark+1,
			ciby=@empno,citime=getdate() where accnt=@accnt
		exec @ret = p_gds_reserve_chktprm @accnt,'0','',@empno,@nick,1,1,@msg output
	end if @class='G' or @class='M'
		exec p_gds_reserve_register_group @accnt, @empno, 'R', @ret output, @msg output
	else
		update master set sta='I', osta='I', arr=getdate(),oarr=getdate(),cby=@empno,changed=getdate(),logmark=logmark+1,
			ciby=@empno,citime=getdate() where accnt=@accnt

end
----------------------------------
--	ȡ���Ǽ�
----------------------------------
else if @mode='cancel_checkin'
begin
	if charindex(@class, 'FGM')=0
	begin
		select @ret=0, @msg='��ǰ�˻����ܽ��иò���'
		goto gout
	end
	if @osta='R'
	begin
		select @ret=0, @msg='�ò����Ѿ�����'
		goto gout
	end
	if @osta<>'I'
	begin
		select @ret=1, @msg='ֻ���Ѿ��Ǽ�״̬���ܽ�����˲���'
		goto gout
	end
--	if @ressta<>'R'
--	begin
--		select @ret=1, @msg='ֻ��Ԥ��ת�Ǽǵı��Ͳ��ܽ�����˲���'
--		goto gout
--	end
	if exists(select 1 from master_till where accnt=@accnt and sta='I')
	begin
		select @ret=1, @msg='�Ѿ�����ҹ��,����ȡ����ס'
		goto gout
	end
	-- ����,����
	if @class in ('G','M') and exists(select 1 from master where groupno=@accnt and sta='I')
	begin
		select @ret=1, @msg='���г�Ա��ס,����ȡ����ס'
		goto gout
	end
	-- Ҳ��Ҫ����ʱ�������������ʡ������Ա�ȷ�����жϣ�
	update master set sta='R',cby=@empno,changed=getdate(),logmark=logmark+1 where accnt=@accnt
	if @@rowcount = 0
	begin
		select @ret=1, @msg='����ʧ��'
		goto gout
	end
	else if @class='F' or (@type<>'' and charindex(@class, 'GM')>0)
		exec @ret = p_gds_reserve_chktprm @accnt,'0','',@empno,@nick,1,1,@msg output
end
----------------------------------
--	����(cancel(rw->x), waitlist(r->w), no-show)
----------------------------------
else if substring(@mode,1,4)='hung'
begin
	if charindex(@class, 'FGM')=0
	begin
		select @ret=1, @msg='������𲻶�'
		goto gout
	end
	select @sta=substring(@mode,5,1)
	if @sta='X' and charindex(@osta,'RW')=0
	begin
		select @ret=1, @msg='ֻ��Ԥ��״̬���ܽ�����˲���'
		goto gout
	end
	if @sta='W' and @class<>'F'
	begin
		select @ret=1, @msg='ֻ�б����������ܽ��� waitlist ����'
		goto gout
	end
	if @sta='N' and @osta<>'R'
	begin
		select @ret=1, @msg='Ԥ��״̬���� No-Show'
		goto gout
	end
	if @osta=@sta
	begin
		select @ret=0, @msg='�ò����Ѿ����'
		goto gout
	end
	if @sta='X' and @osta='R'
	begin
		select @sysvalue = isnull((select value from sysoption where catalog='reserve' and item='cancel_rsv_limit'), '0')
		if @sysvalue = '1'
		begin
			if exists(select 1 from account where accnt=@accnt and billno='')
			begin
				select @ret=1, @msg='Ԥ��ȡ��ǰ�����ȴ�������'
				goto gout
			end
		end
	end

	if @class='F'
	begin
		update master set sta=@sta,bdate=@bdate,cby=@empno,changed=getdate(),logmark=logmark+1 where accnt=@accnt
		exec @ret = p_gds_reserve_chktprm @accnt,'0','',@empno,@nick,1,1,@msg output
	end
	else
		exec p_gds_master_cancel_group @accnt, @sta, @empno, @msg output
end
----------------------------------
--	�ָ� w,x->r
----------------------------------
else if @mode='restore'
begin
	if charindex(@class, 'FGM')=0
	begin
		select @ret=1, @msg='%1����^�������'
		goto gout
	end
	if @osta='R'
	begin
		select @ret=0, @msg='�ò����Ѿ�����'
		goto gout
	end
	if @osta<>'X' and @osta<>'W' and @osta<>'N'
	begin
		select @ret=1, @msg='��ǰ����״̬���ܽ��лָ�����'
		goto gout
	end
	if @class='F'
	begin
		select @arr=arr, @dep=dep from master where accnt=@accnt
		if datediff(dd,getdate(),@arr)<0
			select @arr = getdate()
		if datediff(dd,getdate(),@dep)<0
			select @dep = getdate()
		if @roomno>='0' and datediff(dd, @arr, @dep)=0 
		begin 
			if exists(select 1 from master where accnt<>@accnt and master<>@master and roomno=@roomno and datediff(dd,arr,@arr)>=0 and datediff(dd,dep,@arr)<=0) 
			begin 
				select @ret=1, @msg='�ͷ��Ѿ���ռ�ã���򿪶����������Ż����ں��ٻָ�'
				goto gout
			end 
		end 
		update master_hung set status='X' where accnt=@accnt and status='I'
		update master set sta='R',arr=@arr,dep=@dep,cby=@empno,changed=getdate(),logmark=logmark+1 where accnt=@accnt
		exec @ret = p_gds_reserve_chktprm @accnt,'0','',@empno,@nick,1,1,@msg output
	end
	else
		exec p_gds_restore_group @accnt, @arr, @dep, @empno, 'R', @ret output, @msg output
end
else
begin
	select @ret=1, @msg='��ǰ����ģʽδ֪'
	goto gout
end


gout:
if @ret <> 0
	rollback tran master_sta

commit tran

if @retmode='S'
	select @ret, @msg
return @ret
;