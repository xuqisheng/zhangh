if object_id('p_gds_master_pick') is not null
drop proc p_gds_master_pick
;
create proc p_gds_master_pick
	@accnt		char(10),
	@id			int,
	@roomno		char(5),
	@sta			char(1),			-- 新产生主单的状态  R, I 
	@sep			char(1),			-- 按照人数拆分主单 ? T/F
	@reason		char(3),			-- 换房理由 (只有住店客人才需要)
	@empno		char(10),
	@retmode		char(1),			-- S, R
	@ret        int			output,
   @msg        varchar(60) output
as
----------------------------------------------------------------------------------------------
--		分房程序  : 自动联房，连包价
--
--		注意新建立主单的日期，工号，余额。。。。。。
--
--		如果主单已经存在客房,表示换房操作!  -- 是否需要独立的换房功能 ?
--
--		注意 虚拟房号
--
--		排房成功，返回帐户 @msg。  团体的时候，只能返回最后一个排房帐户 
----------------------------------------------------------------------------------------------
declare		@osta				char(1),
				@class			char(1),
				@quan				int,
				@oroomno			char(5),
				@maccnt			char(10),	-- 新主单的 - 账号
				@maccnt0			char(10),	-- 新主单的 - 主账号
				@rsv_type		char(5),		-- rsvsrc 's type
				@rm_type			char(5),		-- @roomno 's type
				@pcrec			char(10),
				@pcrec_pkg		char(10),
				@arr				datetime,
				@dep				datetime,
				@rate				money,
				@gstno			int,
				@mgstno			int,			-- 新主单的 - 人数
				@step				int,			-- 人数控制
				@remark			varchar(255),
				@rsv_ref			varchar(100),
				@mrate			money,
				@resemp			char(10),
				@resdate			datetime,
				@qtrate			money,
				@hall				char(1), 
				@rcset   		char(10),	 -- 最后设置的 ratecode 
            @exp5        	char(1)


declare   -- New for rsvsrc.  这些 _old 变量是防止出现空值。
				@rmrate		money,
				@rtreason	char(3),
				@ratecode   char(10),		@ratecode_old   	char(10),
				@src			char(3),			@src_old				char(3),
				@market		char(3),			@market_old			char(3),
				@packages	varchar(50),	@packages_old		varchar(50),
				@srqs		   varchar(30),	@srqs_old		   varchar(30),
				@amenities  varchar(30),	@amenities_old  	varchar(30)

select @ret=0, @msg='', @maccnt='', @qtrate=null 
select * into #master from master where 1=2  -- 不能放在事务里面

begin tran
save 	tran master_pick

if @sta is null or charindex(@sta, 'RI')=0
begin
	select @ret=1, @msg='请设置正确新创建的主单的状态'
	goto gout
end
select @osta=sta, @class=class, @oroomno=roomno, @pcrec=pcrec, @pcrec_pkg=pcrec_pkg,
	@src_old=src, @market_old=market, @packages_old=packages, 
	@srqs_old=srqs, @amenities_old=amenities, @ratecode_old=ratecode,@resemp=resby,@resdate=restime,@exp5=substring(extra,5,1)
 from master where accnt=@accnt
if @@rowcount = 0
begin
	select @ret=1, @msg='%1不存在^主单'
	goto gout
end

select @quan = quantity, @rsv_type=type, @rate=rate, @gstno=gstno, @arr=arr, @dep=dep, @remark=remark,
		@rmrate=rmrate,@rtreason=rtreason,@ratecode=ratecode,@src=src,@market=market,
		@packages=packages,@srqs=srqs,@amenities=amenities
	from rsvsrc where accnt=@accnt and id=@id
if @@rowcount = 0 or @quan<=0 
begin
	select @ret=1, @msg='%1错误^客房预留信息'
	goto gout
end

-- 防止空值
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

-- 人数限制
if @gstno <= 0 or @gstno >= 6
	select @gstno = 1
if @class='A'
begin
	select @ret=1, @msg='%1错误^主单类型'
	goto gout
end
if charindex(@osta, 'RI')=0
begin
	select @ret=1, @msg='%1错误^主单状态'
	goto gout
end

-- about roomno
if rtrim(@roomno) is not null  -- 分配新的房号
begin
	select @rm_type = type, @qtrate=rate from rmsta where roomno=@roomno
	if @@rowcount = 0
	begin
		select @ret=1, @msg='%1不存在^房号'
		goto gout
	end
	if @rm_type <> @rsv_type 
	begin
		select @ret=1, @msg='%1不匹配^房类'
		goto gout
	end
	if @class in ('G', 'M', 'C') and @rm_type<>'PM' and @id=0
	begin
		select @ret=1, @msg='%1不匹配^房类'
		goto gout
	end
end
else
begin
	if @id=0 and @osta = 'I' 
	begin
		select @ret=1, @msg='请指定%1^房号'
		goto gout
	end
	if @id=0 and @quan <= 1 
	begin
		select @ret=1, @msg='房数=1，请直接使用分房功能'
		goto gout
	end
	select @rm_type = @rsv_type  -- 代表 Split 功能
	select @qtrate=rate from typim where type=@rm_type
end

-----------------------------
-- begin pick
-----------------------------
--- 散客处理 ? -- 现在含义拓宽 - for 假房 
-----------------------------
if @class='F' or @id=0  
begin
	if @id = 0 and @quan = 1	-- 表示可以直接针对主单操作
	begin								-- 其实就是换房操作。为了防止价格上的问题，限制为同房类进行；
		if @roomno = @oroomno 
			select @ret=1, @msg='%1没有改变^房号'
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
	else		-- 需要产生新的主单
	begin
		-- 先 扣减原来的记录
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

		-- 创建新的宾客主单
		insert #master select * from master where accnt=@accnt
		exec p_GetAccnt1 'FIT', @maccnt output
		update #master set sta=@sta, osta='', accnt=@maccnt, master=@maccnt, type=@rsv_type,otype='',
			roomno=@roomno,oroomno='',rmnum=1, ormnum=0, pcrec=@pcrec, pcrec_pkg=@pcrec_pkg, 
			cby=@empno,changed=getdate(),logmark=0,lastnumb=0,lastinumb=0,charge=0,credit=0,accredit=0,
			discount=0, discount1=0, gstno=@gstno, children=0, 
			arr=@arr, dep=@dep, ref=@remark, qtrate=@qtrate, rmrate=@rmrate, setrate=@rate, 
			rtreason=@rtreason,ratecode=@ratecode,src=@src,market=@market,packages=@packages,srqs=@srqs,amenities=@amenities,paycode='',limit=0,credcode=''

		if @sta='R'  -- 状态不同, 工号部分的更新有变化
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
--- 团体会议处理
-----------------------------
else
begin
	if not exists(select 1 from master_middle where accnt=@accnt)
		exec @ret = p_gds_master_grpmid @accnt,'R', @ret output, @msg output
	if @ret <> 0 
		goto gout

	-- 先 扣减原来的记录
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
	
	-- 虚拟房号
	if @gstno > 1 and @sep='T' and @roomno=''
	begin
		exec p_GetAccnt1 'SRM', @roomno output
		select @roomno = '#' + rtrim(@roomno)
	end

	declare @gstmode	char(1) -- 按照人数拆分的时候，是每个主单=1，还是原单不变，分单=0 ？ 
	if exists(select 1 from sysoption where catalog='reserve' and item='grppick_gst' and value='0')
		select @gstmode='0'	-- 分单=0
	else
		select @gstmode='1'	-- 每单=1
	select @step = 1
	while @step <= @gstno
	begin
		-- 创建新的宾客主单  -- pcrec = '' 
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

				if exists(select 1 from sysoption where catalog='hotel' and item='hotelid' and value='BJGBJD') -- 北京国宾
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
			select @msg=@maccnt -- 团体的时候，只能返回最后一个排房帐户
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