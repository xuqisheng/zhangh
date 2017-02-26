if object_id('p_gds_master_pick') is not null
drop proc p_gds_master_pick
;
create proc p_gds_master_pick
	@accnt		char(10),
	@id			int,
	@roomno		char(5),
	@sta			char(1),			-- �²���������״̬  R, I 
	@sep			char(1),			-- ��������������� ? T/F
	@reason		char(3),			-- �������� (ֻ��ס����˲���Ҫ)
	@empno		char(10),
	@retmode		char(1),			-- S, R
	@ret        int			output,
   @msg        varchar(60) output
as
----------------------------------------------------------------------------------------------
--		�ַ�����  : �Զ�������������
--
--		ע���½������������ڣ����ţ�������������
--
--		��������Ѿ����ڿͷ�,��ʾ��������!  -- �Ƿ���Ҫ�����Ļ������� ?
--
--		ע�� ���ⷿ��
--
--		�ŷ��ɹ��������ʻ� @msg��  �����ʱ��ֻ�ܷ������һ���ŷ��ʻ� 
----------------------------------------------------------------------------------------------
declare		@osta				char(1),
				@class			char(1),
				@quan				int,
				@oroomno			char(5),
				@maccnt			char(10),	-- �������� - �˺�
				@maccnt0			char(10),	-- �������� - ���˺�
				@rsv_type		char(5),		-- rsvsrc 's type
				@rm_type			char(5),		-- @roomno 's type
				@pcrec			char(10),
				@pcrec_pkg		char(10),
				@arr				datetime,
				@dep				datetime,
				@rate				money,
				@gstno			int,
				@mgstno			int,			-- �������� - ����
				@step				int,			-- ��������
				@remark			varchar(255),
				@rsv_ref			varchar(100),
				@mrate			money,
				@resemp			char(10),
				@resdate			datetime,
				@qtrate			money,
				@hall				char(1), 
				@rcset   		char(10),	 -- ������õ� ratecode 
            @exp5        	char(1)


declare   -- New for rsvsrc.  ��Щ _old �����Ƿ�ֹ���ֿ�ֵ��
				@rmrate		money,
				@rtreason	char(3),
				@ratecode   char(10),		@ratecode_old   	char(10),
				@src			char(3),			@src_old				char(3),
				@market		char(3),			@market_old			char(3),
				@packages	varchar(50),	@packages_old		varchar(50),
				@srqs		   varchar(30),	@srqs_old		   varchar(30),
				@amenities  varchar(30),	@amenities_old  	varchar(30)

select @ret=0, @msg='', @maccnt='', @qtrate=null 
select * into #master from master where 1=2  -- ���ܷ�����������

begin tran
save 	tran master_pick

if @sta is null or charindex(@sta, 'RI')=0
begin
	select @ret=1, @msg='��������ȷ�´�����������״̬'
	goto gout
end
select @osta=sta, @class=class, @oroomno=roomno, @pcrec=pcrec, @pcrec_pkg=pcrec_pkg,
	@src_old=src, @market_old=market, @packages_old=packages, 
	@srqs_old=srqs, @amenities_old=amenities, @ratecode_old=ratecode,@resemp=resby,@resdate=restime,@exp5=substring(extra,5,1)
 from master where accnt=@accnt
if @@rowcount = 0
begin
	select @ret=1, @msg='%1������^����'
	goto gout
end

select @quan = quantity, @rsv_type=type, @rate=rate, @gstno=gstno, @arr=arr, @dep=dep, @remark=remark,
		@rmrate=rmrate,@rtreason=rtreason,@ratecode=ratecode,@src=src,@market=market,
		@packages=packages,@srqs=srqs,@amenities=amenities
	from rsvsrc where accnt=@accnt and id=@id
if @@rowcount = 0 or @quan<=0 
begin
	select @ret=1, @msg='%1����^�ͷ�Ԥ����Ϣ'
	goto gout
end

-- ��ֹ��ֵ
if rtrim(@ratecode) is null 
	select @ratecode = @ratecode_old
if rtrim(@src) is null 
	select @src = @src_old
if rtrim(@market) is null 
	select @market = @market_old
if rtrim(@packages) is null 
	select @packages = @packages_old
if rtrim(@srqs) is null 
	select @srqs = @srqs_old
if rtrim(@amenities) is null 
	select @amenities = @amenities_old

-- remark
select @rsv_ref = @remark
if rtrim(@remark) is null 
	select @remark = ref from master where accnt = @accnt

-- ��������
if @gstno <= 0 or @gstno >= 6
	select @gstno = 1
if @class='A'
begin
	select @ret=1, @msg='%1����^��������'
	goto gout
end
if charindex(@osta, 'RI')=0
begin
	select @ret=1, @msg='%1����^����״̬'
	goto gout
end

-- about roomno
if rtrim(@roomno) is not null  -- �����µķ���
begin
	select @rm_type = type, @qtrate=rate from rmsta where roomno=@roomno
	if @@rowcount = 0
	begin
		select @ret=1, @msg='%1������^����'
		goto gout
	end
	if @rm_type <> @rsv_type 
	begin
		select @ret=1, @msg='%1��ƥ��^����'
		goto gout
	end
	if @class in ('G', 'M', 'C') and @rm_type<>'PM' and @id=0
	begin
		select @ret=1, @msg='%1��ƥ��^����'
		goto gout
	end
end
else
begin
	if @id=0 and @osta = 'I' 
	begin
		select @ret=1, @msg='��ָ��%1^����'
		goto gout
	end
	if @id=0 and @quan <= 1 
	begin
		select @ret=1, @msg='����=1����ֱ��ʹ�÷ַ�����'
		goto gout
	end
	select @rm_type = @rsv_type  -- ���� Split ����
	select @qtrate=rate from typim where type=@rm_type
end

-----------------------------
-- begin pick
-----------------------------
--- ɢ�ʹ��� ? -- ���ں����ؿ� - for �ٷ� 
-----------------------------
if @class='F' or @id=0  
begin
	if @id = 0 and @quan = 1	-- ��ʾ����ֱ�������������
	begin								-- ��ʵ���ǻ���������Ϊ�˷�ֹ�۸��ϵ����⣬����Ϊͬ������У�
		if @roomno = @oroomno 
			select @ret=1, @msg='%1û�иı�^����'
		else
		begin
			update master set roomno=@roomno,cby=@empno,changed=getdate(),logmark=logmark+1 where accnt=@accnt
			if @@rowcount = 1 
				exec @ret = p_gds_reserve_chktprm @accnt,'0','',@empno,'',1,1,@msg output
			else
				select @ret=1, @msg='update master error '
			if @ret=0 
				select @msg = @accnt 
		end
	end
	else		-- ��Ҫ�����µ�����
	begin
		-- �� �ۼ�ԭ���ļ�¼
		if @id = 0
		begin
			update master set rmnum=rmnum-1 where accnt=@accnt
			exec @ret = p_gds_reserve_chktprm @accnt,'0','',@empno,'',1,1,@msg output
			if @ret = 0
				update master set cby=@empno, changed=getdate(), logmark=logmark+1 where accnt=@maccnt
			else
				goto gout
		end
		else
		begin
			if @quan > 1 
			begin
				select @quan = @quan - 1
				exec p_gds_reserve_rsv_mod @accnt,@id,@rsv_type,'','',@arr,@dep,@quan,@gstno,@rate,@rsv_ref,
					@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
			end
			else
				exec p_gds_reserve_rsv_del @accnt,@id,'R',@empno,@ret output, @msg output
			if @ret <> 0 
			begin
				select @ret=1, @msg='p_gds_reserve_rsv_del error'
				goto gout
			end
		end

		if @pcrec = '' 
			select @pcrec = @accnt
		if @pcrec_pkg = '' 
			select @pcrec_pkg = @accnt

		-- �����µı�������
		insert #master select * from master where accnt=@accnt
		exec p_GetAccnt1 'FIT', @maccnt output
		update #master set sta=@sta, osta='', accnt=@maccnt, master=@maccnt, type=@rsv_type,otype='',
			roomno=@roomno,oroomno='',rmnum=1, ormnum=0, pcrec=@pcrec, pcrec_pkg=@pcrec_pkg, 
			cby=@empno,changed=getdate(),logmark=0,lastnumb=0,lastinumb=0,charge=0,credit=0,accredit=0,
			discount=0, discount1=0, gstno=@gstno, children=0, 
			arr=@arr, dep=@dep, ref=@remark, qtrate=@qtrate, rmrate=@rmrate, setrate=@rate, 
			rtreason=@rtreason,ratecode=@ratecode,src=@src,market=@market,packages=@packages,srqs=@srqs,amenities=@amenities,paycode='',limit=0,credcode=''

		if @sta='R'  -- ״̬��ͬ, ���Ų��ֵĸ����б仯
			update #master set resby=@resemp,restime=@resdate,ciby='',citime=null
		else
			update #master set resby=@resemp,restime=@resdate,ciby=@empno,citime=getdate()

		insert master select * from #master
		if @@rowcount = 0
			select @ret=1, @msg = 'Insert Error '
		else
		begin
			exec @ret = p_gds_reserve_chktprm @maccnt,'0','',@empno,'',1,1,@msg output
			if @ret = 0
			begin
				update master set logmark=logmark+1 where accnt=@maccnt
				update master set pcrec=@pcrec, pcrec_pkg=@pcrec_pkg where accnt=@accnt
				exec p_gds_master_des_maint @maccnt
				select @msg = @maccnt 
			end
		end
	end
end
-----------------------------
--- ������鴦��
-----------------------------
else
begin
	if not exists(select 1 from master_middle where accnt=@accnt)
		exec @ret = p_gds_master_grpmid @accnt,'R', @ret output, @msg output
	if @ret <> 0 
		goto gout

	-- �� �ۼ�ԭ���ļ�¼
	if @quan > 1 
	begin
		select @quan = @quan - 1
		exec p_gds_reserve_rsv_mod @accnt,@id,@rsv_type,'','',@arr,@dep,@quan,@gstno,@rate,@rsv_ref,
			@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
	end
	else
		exec p_gds_reserve_rsv_del @accnt,@id,'R',@empno, @ret output, @msg output
	if @ret <> 0 
	begin
		select @ret=1, @msg='p_gds_reserve_rsv_del error'
		goto gout
	end

	-- Mem extra
	declare	@extra		char(30)
	select @extra = substring(value,1,30) from sysoption where catalog='reserve' and item='mem_extra'
	if @@rowcount=0 or rtrim(@extra) is null
		select @extra = '000000000000000000000000000000'
	select @extra = substring(rtrim(@extra) + '000000000000000000000000000000', 1, 30)
	-- hall adjustment 
	select @hall = substring(@extra, 2, 1)
	if not exists(select 1 from basecode where cat='hall' and code=@hall)
	begin
		select @hall = min(code) from basecode where cat='hall'
		select @extra = stuff(@extra, 2, 1, @hall)
	end
	
	-- ���ⷿ��
	if @gstno > 1 and @sep='T' and @roomno=''
	begin
		exec p_GetAccnt1 'SRM', @roomno output
		select @roomno = '#' + rtrim(@roomno)
	end

	declare @gstmode	char(1) -- ����������ֵ�ʱ����ÿ������=1������ԭ�����䣬�ֵ�=0 �� 
	if exists(select 1 from sysoption where catalog='reserve' and item='grppick_gst' and value='0')
		select @gstmode='0'	-- �ֵ�=0
	else
		select @gstmode='1'	-- ÿ��=1
	select @step = 1
	while @step <= @gstno
	begin
		-- �����µı�������  -- pcrec = '' 
		delete #master
		insert #master select * from master_middle where accnt=@accnt
		exec p_GetAccnt1 'FIT', @maccnt output
	
		if @sep = 'T'
		begin
			if @step = 1 
			begin
				select @maccnt0 = @maccnt, @mrate = @rate, @rcset=@ratecode
				if @gstmode='0'
					select @mgstno = @gstno  
				else
					select @mgstno = 1
			end
			else
			begin
				select @mrate = 0
				if @gstmode='0'
					select @mgstno = 0
				else 
					select @mgstno = 1
--yjw
declare @long int
declare @value money
select @long=datediff(dd,@arr,@dep)
exec @ret =p_gds_get_rmrate @arr,@long,@rsv_type,null,1,@mgstno,@rcset,'','R',@value out,@msg out
select @rmrate=@value
--yjw

				if exists(select 1 from sysoption where catalog='hotel' and item='hotelid' and value='BJGBJD') -- ��������
					and exists(select 1 from rmratecode where code='SHARE')
					select @rcset = 'SHARE'
			end
			select @step = @step + 1
		end
		else
			select @step = @gstno + 1, @maccnt0 = @maccnt, @mrate = @rate, @rcset=@ratecode, @mgstno = @gstno  

		update #master set sta=@sta, osta=' ', accnt=@maccnt, master=@maccnt0, type=@rsv_type,otype='',haccnt=exp_s1,
			roomno=@roomno,oroomno='',rmnum=1, ormnum=0,pcrec='',pcrec_pkg='',
			cby=@empno,changed=getdate(),logmark=0, groupno=@accnt,
			lastnumb=0,lastinumb=0,charge=0,credit=0,accredit=0,extra=stuff(@extra,5,1,@exp5),
			discount=0, discount1=0, gstno=@mgstno, children=0,
			arr=@arr, dep=@dep, ref=@remark, qtrate=@qtrate, rmrate=@rmrate, setrate=@mrate, 
			rtreason=@rtreason,ratecode=@rcset,src=@src,market=@market,packages=@packages,srqs=@srqs,amenities=@amenities
	
		if @sta='R'
			update #master set resby=@resemp,restime=@resdate,ciby='',citime=null
		else
			update #master set resby=@resemp,restime=@resdate,ciby=@empno,citime=getdate()
	
		insert master select * from #master
		exec @ret = p_gds_reserve_chktprm @maccnt,'0','',@empno,'',1,1,@msg output
		if @ret = 0
		begin
			exec p_gds_master_des_maint @maccnt
			update master set logmark=logmark+1 where accnt=@maccnt
			select @msg=@maccnt -- �����ʱ��ֻ�ܷ������һ���ŷ��ʻ�
		end
		else
			break
	end 
end

--
gout:
if @ret <> 0
	rollback tran master_pick
commit tran
drop table #master
--
if @retmode='S'
	select @ret, @msg
return @ret
;