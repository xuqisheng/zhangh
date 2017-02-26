if exists(select 1 from sysobjects where name = "p_gds_master_pick_grid")
	drop proc p_gds_master_pick_grid;
create proc p_gds_master_pick_grid
	@accnt		char(10),
	@type			char(5),
	@rate			money,						-- block �ַ���ʱ�����﷿��=0����Ҫ��ȡ block���� 
	@arr			datetime,
	@dep			datetime,
	@rmnum		int,
	@gstno		int,
	@remark		varchar(255),
	@sep			char(1),						-- ��������������� ? T/F
	@empno		char(10),
	@retmode		char(1),						-- S, R
	@ret        int			output,
   @msg        varchar(60) output		-- block �ַ���ʱ�����ﴫ��ɢ�͵��� 
as
----------------------------------------------------------------------------------------------
--		Grid block �ַ�����  -- �ͷ���Դ��������� block ֮��
--
--		ע����� @accnt �����������˺ţ�Ҳ������ block �˺� 
----------------------------------------------------------------------------------------------
declare		@sta				char(1),
				@class			char(1),
				@quantity		int,
				@saccnt			char(10),
				@maccnt			char(10),	-- �������� - �˺�
				@maccnt0			char(10),	-- �������� - ���˺�
				@mgstno			int,			-- �������� - ����
				@step				int,			-- ��������
				@id				int,
				@roomno			char(5),
				@mrate			money,
				@begin			datetime,
				@end				datetime,
				@date				datetime,
				@date1			datetime,
				@bdate			datetime,
				@qtrate		money,
				@rmrate		money,
				@rtreason	char(3),
				@ratecode   char(10),
				@src			char(3),
				@market		char(3),
				@packages	varchar(50),
				@srqs		   varchar(30),
				@amenities  varchar(30),
				@hall			char(1),
				@haccnt		char(7),
				@rate1		money,
				@rate2 		money,
				@rsvfrom		char(10)			-- ��ʾ�ͷ���Դ��Դ�����������屾��Ҳ�������屾���Ӧ��block, Ҳ��ֱ����block  

select @ret=0

-- block �ַ���ʱ��@msg ����ɢ�͵���. �����������blockֱ������ɢ�Ͷ���  
if @accnt like 'B%'
begin
	select @haccnt = isnull(substring(ltrim(@msg), 1, 7), 'NULL')
	if not exists(select 1 from guest where no=@haccnt and class='F')
	begin
		select @ret=1, @msg='%1����^����'
		goto gout
	end
end
select @msg='' 

-- ������� 
select @qtrate=rate from typim where type=@type
if @@rowcount=0
begin
	select @ret=1, @msg='%1������^����'
	goto gout
end
if @arr is null or @dep is null or @arr>@dep or datediff(dd, @arr, getdate())>0 
begin
	select @ret=1, @msg='%1����^����'
	goto gout
end
select @begin = convert(datetime,convert(char(8),@arr,1)), @end = convert(datetime,convert(char(8),@dep,1))
if @accnt like '[GM]%' -- group
	select @sta=sta, @class=class, @src=src, @market=market, @packages=packages, 
		@srqs=srqs, @amenities=amenities, @ratecode=ratecode
	 from master where accnt=@accnt
else if @accnt like 'B%' -- block 
	select @sta=sta, @class=class, @src=src, @market=market, @packages=packages, 
		@srqs=srqs, @amenities=amenities, @ratecode=ratecode
	 from sc_master where accnt=@accnt
else
begin
	select @ret=1, @msg='%1����^��������'
	goto gout
end
if @@rowcount = 0
begin
	select @ret=1, @msg='%1������^����'
	goto gout
end
if @sta is null or charindex(@sta, 'RI')=0
begin
	select @ret=1, @msg='%1����Ч״̬^����'
	goto gout
end

-- remark
if rtrim(@remark) is null 
begin
	if @accnt like '[FGM]%'
		select @remark = ref from master where accnt = @accnt
	else
		select @remark = ref from sc_master where accnt = @accnt
end

-- ��������
if @gstno <= 0 or @gstno >= 6
	select @gstno = 1

--
if @accnt like 'B%'
	select @rsvfrom=@accnt 
else
begin
	if exists(select 1 from rsvsrc where accnt=@accnt and blkmark='T')
		select @rsvfrom=@accnt
	else
	begin
		select @rsvfrom=blkcode from master where accnt=@accnt 
		if rtrim(@rsvfrom) is null 
		begin
			select @ret=1, @msg='Ԥ����Դ����'
			goto gout
		end
	end
end

-- Ԥ����Դ�ж�
select @date = @begin
while @date < @end
begin
	if not exists(select 1 from rsvsrc where accnt=@rsvfrom and type=@type and begin_=@date and blkmark='T' and quantity>=@rmnum)
	begin
		select @ret=1, @msg='Ԥ����Դ����'
		goto gout
	end
	select @date = dateadd(dd, 1, @date)
end

-- rate 
select @rate1 = max(rmrate), @rate2 = max(rate) from rsvsrc where accnt=@rsvfrom and type=@type and begin_=@begin  
if @rate1>0 
	select @rmrate=@rate1
else
	select @rmrate=@rate2 
if @accnt like 'B%'
	select @rate=@rate2 

-- ��ʼ���ɵ���
if @accnt like '[GM]%' and not exists(select 1 from master_middle where accnt=@accnt)
	exec @ret = p_gds_master_grpmid @accnt,'R', @ret output, @msg output
if @ret <> 0 
	goto gout

-- Mem extra.   ��ʹ��block������ɢ�ͣ�Ҳ���������Աȱʡ�� extra ���� 
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

-- 
select @bdate=bdate1 from sysdata 
select * into #master from master where 1=2  -- ���ܷ�����������

while @rmnum > 0
begin
	select @rmnum = @rmnum - 1

	begin tran
	save 	tran grid_pick

	-- �� �ۼ�ԭ���ļ�¼ -- ����Ҫ������ۼ��ˣ��������ɵ�ʱ�򣬻��Զ��ۼ� 
--	select @date = @begin
--	while @date < @end
--	begin
--		select @date1 = dateadd(dd, 1, @date)
--		select @saccnt=saccnt,@id=id,@quantity=quantity from rsvsrc where accnt=@rsvfrom and type=@type and begin_=@date and blkmark='T'
--		if @@rowcount = 1
--		begin
--			exec p_gds_reserve_rsv_del_saccnt @saccnt
--			if @quantity > 1
--			begin
--				select @quantity = @quantity - 1
--				update rsvsrc set quantity=@quantity where accnt=@rsvfrom and id=@id
--				insert rsvsaccnt(saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt)
--					select saccnt,type,roomno,blkmark,begin_,end_,quantity,accnt 
--						from rsvsrc where accnt=@rsvfrom and id=@id
--				exec p_gds_reserve_filldtl @saccnt,@type,'',@date,@date1,@quantity
--			end
--			else
--			begin
--				delete rsvsrc where accnt=@rsvfrom and id=@id
--			end
--		end 
--		else
--		begin
--			select @ret=1, @msg='Ԥ����Դ����'
--			goto pout
--		end
--
--		select @date = dateadd(dd, 1, @date)
--	end
	
	-- ���ⷿ��
	if @gstno > 1 and @sep='T'
	begin
		exec p_GetAccnt1 'SRM', @roomno output
		select @roomno = '#' + rtrim(@roomno)
	end
	else
		select @roomno = ''
	
	select @step = 1
	while @step <= @gstno
	begin
		-- �����µı�������  -- pcrec = '' 
		delete #master
		if @accnt like '[GM]%' 
			insert #master select * from master_middle where accnt=@accnt
		else
			insert #master(accnt,haccnt,groupno,type,otype,up_type,up_reason,rmnum,ormnum,roomno,oroomno,bdate,
				sta,osta,ressta,exp_sta,sta_tm,rmpoststa,rmposted,tag0,arr,dep,resdep,oarr,odep,agent,cusno,
				source,class,src,market,restype,channel,artag1,artag2,share,gstno,children,rmreason,ratecode,
				packages,fixrate,rmrate,qtrate,setrate,rtreason,discount,discount1,addbed,addbed_rate,crib,crib_rate,
				paycode,limit,credcode,credman,credunit,applname,applicant,araccnt,phone,fax,email,
				wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,
				charge,credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,blkcode,oblkcode,pcrec,pcrec_pkg,resno,
				crsno,ref,comsg,card,saleid,cmscode,cardcode,cardno,resby,restime,ciby,citime,coby,cotime,depby,
				deptime,cby,changed,exp_m1,exp_m2,exp_dt1,exp_dt2,exp_s1,exp_s2,exp_s3,logmark)
			SELECT accnt,@haccnt,'',@type,'','','',1,0,'','',@bdate,
				'R','','','','','','F','',arr,dep,null,oarr,odep,agent,cusno,
				source,'F',src,market,restype,channel,'','','F',gstno,children,'',ratecode,
				packages,'F',setrate,setrate,setrate,'',0,0,0,0,0,0,
				paycode,limit,credcode,credman,credunit,'','',araccnt,'','','',
				wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,@extra,
				charge,credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,@accnt,'',pcrec,pcrec_pkg,resno,
				crsno,ref,comsg,'',saleid,cmscode,cardcode,cardno,resby,restime,'',null,coby,cotime,depby,
				deptime,cby,changed,exp_m1,exp_m2,cutoff,exp_dt2,exp_s1,contact,exp_s3,logmark
		   FROM sc_master where accnt=@accnt
		if @@rowcount = 0
		begin
			select @ret=1, @msg='Insert master error'
			break 
		end

		exec p_GetAccnt1 'FIT', @maccnt output
	
		if @step = 1 
			select @maccnt0 = @maccnt, @mrate = @rate
		else
			select @mrate = 0
		if @sep = 'T'
			select @mgstno = 1, @step = @step + 1
		else
			select @mgstno = @gstno, @step = @gstno + 1
	
		update #master set sta='R', osta=' ', accnt=@maccnt, master=@maccnt0, type=@type,otype='',
			roomno=@roomno,oroomno='',rmnum=1, ormnum=0,pcrec='',pcrec_pkg='',
			cby=@empno,changed=getdate(),logmark=0, 
			lastnumb=0,lastinumb=0,charge=0,credit=0,accredit=0,extra=@extra,
			discount=0, discount1=0, gstno=@mgstno, children=0,
			arr=@arr, dep=@dep, ref=@remark, qtrate=@rmrate, rmrate=@rmrate, setrate=@rate, 
			rtreason='',ratecode=@ratecode,src=@src,market=@market,packages=@packages,srqs=@srqs,amenities=@amenities
	
		update #master set resby=@empno,restime=getdate(),ciby='',citime=null

		insert master select * from #master
		exec @ret = p_gds_reserve_chktprm @maccnt,'0','',@empno,'',1,1,@msg output
		if @ret = 0
		begin
			exec p_gds_master_des_maint @maccnt
			update master set logmark=logmark+1 where accnt=@maccnt
		end
		else
			break
	end 

pout:	
	if @ret <> 0
	begin
		rollback tran grid_pick
		commit tran
		goto gout
	end
	else
		commit tran
end

--
gout:
-- drop table #master
--
if @retmode='S'
	select @ret, @msg
return @ret
;

