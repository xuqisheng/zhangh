if object_id('p_gds_reserve_chktprm_son') is not null
drop proc p_gds_reserve_chktprm_son
;
create proc p_gds_reserve_chktprm_son
	@accnt           char(10),        -- 帐号 
	@request         char(20),        -- 曾经非常重要的参数，现在无用
	@idcheck         char(1),        -- 判断脏房入住 
	@empno           char(10),        -- 操作员
	@nick            char(5),        -- 假名生成序号
	@ndmaingrpmst    int,				-- 是否要维护团体主单 
	@grpmstlogmark   int,  				-- 是否要记录日志 
	@nullwithreturn  varchar(60) = null output
as
-- ------------------------------------------------------------------------------------
--由  p_gds_reserve_chktprm 调用
--		注意针对虚拟房号的处理:  roomno>='0' 表示分房了, 否则表示没有分房.
-- ------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------
-- 	分房,退房,换房,预订转入住,预订取消,预订恢复,撤消结帐退房等状态转换及提前,延期等日期更改等
-- 	当本过程更新了客人信息时,返回标志给外层应用以正确记录客人日志
-- ------------------------------------------------------------------------------------
declare
	@ret        int,
   @msg        varchar(60),
	@mststa     char(1),        -- 帐号状态   
	@omststa    char(1),        -- 帐号原状态 
	@gstno      int    ,        -- 主单人数   
	@rm_type    char(5),        -- 房类 
	@rm_no      char(5),        -- 房号 
	@s_time     datetime,       -- 开始时间 
	@e_time     datetime,       -- 终止时间 
	@eetime     datetime,       -- 经过处理的 离日
	@otype      char(5) ,       -- 原房类   
	@oroomno    char(5) ,       -- 原房号   
	@oarr       datetime,       -- 原到日   
	@odep       datetime,       -- 原离日   
	@pblkno     int,            -- 可用房类数 
	@prmtk      int,            -- 房号中帐号数 
	@number     smallint,       -- 帐单数目 
	@rmsta        char(1),        -- 客房状态 
	@skip_block int,            -- 是否可以跳过预留房判断
	@groupno    char(10),        -- 团号 
	@grpsta     char(1),        -- 团体状态 
	@grparr     datetime,       -- 团体到日 
	@grpdep     datetime,       -- 团体离日 
	@grpclass   char(1),        -- 团体类别 
	@nullwith2  varchar(60),   
	@needtotran varchar(3),  		    -- 是否要传递信息 master -> guest : arr, dep, roomno
	@bdate      datetime,
	@discount   money,
	@discount1  money,
	@percent    money,
	@rtreason   char(3),
	@qtrate     money,
	@setrate    money,
	@rmrate    money,
   @ocsta      char(1),
   @accntset   varchar(70),
	@extra		char(30),
	@saccnt		char(10),
	@master		char(10),
	@blkcode		char(10),
	@oblkcode	char(10),
	@rsvchk		varchar(20),
	@saccnt_1	char(10),
	@master_1	char(10),
	@tmp_accnt1	char(10),
	@tmp_accnt2	char(10)

--FHB added
declare	@number1		int,
			@num			int,
			@quantity	money

-- 是否要进行资源超限校验 
select @rsvchk=''  -- yes 
if @nullwithreturn is not null 
begin 
	if charindex('rsvchk=0;', @nullwithreturn) > 0 
		select @rsvchk = 'rsvchk=0;'  -- no 一般在同步处理的时候，只有最后一个进行校验 
end 

-- 
declare 	@ratecode	varchar(10),	-- 房价码
			@cusno		char(7),			-- 单位号码
			@rmnum		int,
			@ormnum		int,
			@tmpsta 		char(1),
			@class 		char(1),
			@marr			datetime,   	-- 记录含有时间信息的原始日期
			@mdep			datetime

declare   -- New for rsvsrc
			@src			char(3),
			@market		char(3),
			@packages	varchar(50),
			@srqs		   varchar(30),
			@amenities  varchar(30)

declare
	@allow_dirty_register_in        char(1),-- 是否允许脏房入住：'Y' 允许 、'N' 禁止 
	@allow_exceed_use_room_type     char(1),-- 是否允许超额使用房类, 即在 @min_useable < 1 时也允许预留标志 ：'Y' 允许 、 'N' 禁止
	@allow_check_roomno_first       char(1),-- 是否允许以房号检验为准, 而不考虑房类检验的结果标志 ：'Y' 允许 'N' 禁止 
	@cntlblock                      char(1) -- 是否必须检查房类预留情况 ：'t','T' 必须 、 其它不必             

declare	@host_id	varchar(30)
select @host_id = host_id()

-- init the data 
select @ret = 0,@msg = "",@nullwith2=@nullwithreturn, @tmpsta=''
select @bdate = bdate1 from sysdata
select @skip_block = 0

-- sysoption values
select @allow_dirty_register_in=value from sysoption where catalog="reserve" and item="allow_dirty_register_in"
if @@rowcount = 0
	select @allow_dirty_register_in="N"

select @allow_check_roomno_first=value from sysoption where catalog="distribute" and item="allow_check_roomno_first"
if @@rowcount = 0
	select  @allow_check_roomno_first  = "N"

select @allow_exceed_use_room_type=value from sysoption where catalog="distribute" and item="allow_exceed_use_room_type"
if @@rowcount = 0
   select  @allow_exceed_use_room_type  = "N"

select  @cntlblock = value from sysoption  where   catalog = "reserve" and item = "cntlblock"
if @@rowcount = 0
   select  @cntlblock = "T"

-- 事务开始
begin tran 
save  tran p_gds_reserve_chktprm_son_s1

-- 设置排它信号 ?
update chktprm set code = 'A'  

-- 锁住团体主单 
select @groupno = groupno from master where accnt = @accnt
if @@rowcount = 1 and @groupno <> ''
   begin
   select @grparr=convert(datetime,convert(char(8),arr,1)), @grpdep=convert(datetime,convert(char(8),dep,1)),
          @grpsta=sta, @grpclass=class 
		from master where accnt = @groupno  -- convert date-> yyyy/mm/dd 00:00:00
	-- 更新团体代号<房态表-1>
--	update master set exp_sta=(select b.exp_sta from master b where b.accnt=@groupno) where accnt=@accnt
   end

-- 从master中提取数据  判断房价 
select @mststa = sta,@discount=discount,@discount1=discount1,@rtreason=isnull(rtreason,''),@rmrate=rmrate,
	    	@qtrate = qtrate,@setrate = setrate,@ratecode=rtrim(ratecode), @cusno=rtrim(cusno),@class=class,
		@extra=extra, @saccnt=saccnt, @master=master,
			@src=src, @market=market, @packages=packages, @srqs=srqs, @amenities=amenities
	from master where accnt = @accnt
-- 假房功能采用之后,这个限制取消了... 
--if @class<>'F' 
--begin
--	select @ret = 0, @msg='非宾客主单，勿需处理'
--	goto RET_P
--end

---- 宾客有优惠，注意排除长包房，自用房；
--if @groupno = '' and @rmrate<>@setrate and substring(@extra,1,1)<>'1' and substring(@extra,2,1)<>'1'
--begin
--   select @percent = p01 from reason where code = @rtreason and p01 > 0
--   if @@rowcount = 0
--   begin
--		select @ret = 1, @msg='房价优惠理由未输'
--		goto RET_P
--	end
--   if @discount <> 0 and @discount>@qtrate*@percent
--	begin
--		select @ret = 1,@msg='房价优惠超过优惠限额 - 1'
--		goto RET_P
--	end
--   if @discount1>@percent
--	begin
--		select @ret = 1,@msg='房价优惠超过优惠限额 - 2'
--		goto RET_P
--	end
--end                                          
                                                                                                       
 
select @mststa = sta ,@omststa = osta ,@gstno  = gstno,@rm_type = type,@rm_no = roomno,
	    @s_time = arr ,@e_time  = dep  ,@otype  = otype,@oroomno =oroomno,
	    @oarr   = oarr,@odep    =odep  ,@rmnum=rmnum, @ormnum=ormnum, @blkcode=blkcode, @oblkcode=oblkcode  
	from master where accnt = @accnt
if @rm_no=null  select @rm_no=''
if @omststa='' select @omststa = ''

if @mststa='I' and @rm_no<'0'
begin
	select @ret = 1,@msg = "请先分配房号"
	goto         RET_P
end

-- 团体特殊处理
if @class='G' or @class='M'
	select @rmnum=1, @ormnum=1, @gstno=0  

-- 房号的有效性判断
if charindex(@mststa, 'RIW')>0
begin
	if @rm_no<'0' and @rm_no<>''
	begin
		if substring(@rm_no,1,1)<>'#' 
		begin
			select @ret = 1,@msg = "房号错误，请检查!"
			goto         RET_P
		end
	end
	else if @rm_no >= '0'
	begin
		if not exists(select 1 from rmsta where roomno=@rm_no)
		begin
			select @ret = 1,@msg = "房号错误，请检查!"
			goto         RET_P
		end
	end
end

if @omststa<>'I' and @mststa='I' 
	and exists(select 1 from master where sta='I' and roomno=@rm_no and master<>@master and saccnt<>@saccnt and share<>'T')		-- modi by zk share='F'->share<>'T'
--	and exists(select 1 from master where sta='I' and roomno=@rm_no and master<>@master and saccnt<>@saccnt and share='F')
begin
	select @ret = 1,@msg = "该客房已经有人入住"
	goto RET_P
end

-- 新入住，判断和更新时间
if charindex(@omststa,'ISO')=0 and @mststa='I' and @nick <> 'I'  -- nick 表示同步操作的时候，原来的状态
begin
	-- 
	if @mststa='I' and @omststa='S' and not exists(select 1 from master where bdate=@bdate)
	begin
		select @ret = 1,@msg = "挂账帐户夜审后不能使用该功能"
		goto RET_P
	end

	-- 斟酌到达时间  -- 预订客人，在预定日期的次日早上到达
--	if charindex(@omststa, 'RCG')>0 and @mststa='I' -- 预订转登记
--			and datepart(hour,getdate())<6 					-- 小于 6 点
--			and datediff(dd,@s_time,getdate()) > 0			-- 到日 < 当前日期
--		select @s_time = convert(datetime, convert(char(10), dateadd(dd,-1,getdate()), 111)+' 23:59:59')
--	else
		select @s_time = getdate()

	update master set arr=@s_time, bdate=@bdate, ciby=@empno, citime=getdate() where accnt=@accnt  -- 填入ci info 

	if datediff(dd, @e_time, getdate())>0 
	begin
		select @ret = 1,@msg = "离开日期不能小于当前实际日期"
		goto RET_P
	end

	if datediff(dd, @s_time, @e_time)<0 
	begin
		select @ret = 1,@msg = "离开日期不能小于到达日期"
		goto RET_P
	end
end



-- 关于房数的一般性校验 
if @rmnum <= 0 
begin
	select @ret = 1,@msg = "房数只能 >= 1"
	goto RET_P
end
if @mststa='I' and @rmnum <> 1 
begin
	select @ret = 1,@msg = "登记主单的房数只能 = 1"
	goto RET_P
end
if @rm_no>'0' and  @rmnum <> 1 
begin
	select @ret = 1,@msg = "分房主单只能占用一个房数 !"
	goto	RET_P
end


if @s_time <> @oarr or @oarr is null
   select @needtotran = 'A'  					-- 需要传递数据 master－》guest
if @e_time <> @odep or @odep is null
   select @needtotran = @needtotran+'D'

-- 去除日期时间中的时间部分 
select @marr = @s_time, @mdep = @e_time
select @s_time = convert(datetime,convert(char(8),@s_time,1))
select @e_time = convert(datetime,convert(char(8),@e_time,1))
if @e_time < @s_time 
   select @eetime = @s_time -- 经过处理的 离日 -- 原来 hry 版本的离日必须比到日大，相等的时候会自动+1
else
   select @eetime = @e_time
select @oarr   = convert(datetime,convert(char(8),@oarr  ,1)) 
select @odep   = convert(datetime,convert(char(8),@odep  ,1))


----------------------------------------------------------------------------
--	团体成员的相关判断
----------------------------------------------------------------------------
if @groupno <> ''
begin
	if @rmnum > 1 
	begin
		select @ret = 1,@msg = "团体成员的房数只能 = 1"
      goto RET_P
	end

	if charindex(@grpsta,'RCGI') = 0
	begin
		if charindex(@mststa,'RCG') > 0
		begin
			select @ret = 1,@msg = "团体主单非有效预订或登记状态"
			goto         RET_P
		end
		else if charindex(@mststa,'I') > 0
		begin
			select @ret = 1,@msg = "团体主单非登记状态"
			goto         RET_P
		end
	end
   else if charindex(@grpsta,'RCG') > 0
	begin
		if charindex(@mststa,'I') > 0
		begin
			select @ret = 1,@msg = "团体主单非登记状态,请先做主单登记"
         goto         RET_P
		end
	end

--	-- 房价
--   if exists (select 1 from grprate where accnt = @groupno and type =@rm_type)
--	begin
--      if @rm_type <> @otype  -- 拖动换房
--		begin
--         select @qtrate = rate from grprate where accnt = @groupno and type = @rm_type
--         select @setrate = @qtrate 
--         update master set qtrate = @setrate,rmrate=@setrate, setrate=@setrate  where accnt = @accnt 
--		end 
--	end 
--   else
--	begin
--	   select @ret = 1,@msg ="还未设置团体 "+@groupno+" 的房类房价:"+@rm_type
--      goto   RET_P
--	end

   if not (@s_time >=@grparr and @s_time <= @grpdep and @e_time >=@grparr and @e_time <= @grpdep) 
		and charindex(@mststa,'RCG')>0  -- 预订状态，到日离日都要判断 !
	begin
		select @ret = 1,@msg ="proc : 团体成员抵离日期不能超出团体主单抵离日期"
      goto   RET_P
	end
   if not (@e_time >=@grparr and @e_time <= @grpdep)  -- 已经在住了，只判断离日
		and charindex(@mststa,'I')>0
	begin
		select @ret = 1,@msg ="proc : 团体成员抵离日期不能超出团体主单抵离日期"
      goto   RET_P
	end
end

----------------------------------------------------------------------------
--	取消信用 070918 simon 
----------------------------------------------------------------------------
declare @pc_id char(4), @shift char(1), @count int 
select @count = count(1) from auth_runsta where host_id=@host_id and status='R' and empno=@empno 
if @count=1 
begin
	select @pc_id=pc_id, @shift=shift from auth_runsta where host_id=@host_id and status='R' and empno=@empno 
	if rtrim(@shift) is null or charindex(@shift, '12345')=0 select @shift='3' 
end
else
	select @pc_id='pcid', @shift='1'

if charindex(@mststa,'OXND')>0 and charindex(@omststa,'RI')>0
begin
	update accredit set tag='5', empno2=@empno, bdate2=@bdate, shift2=@shift, log_date2=getdate() 
		where accnt=@accnt and tag='0' 
	update master set accredit=0, limit=0 where accnt=@accnt 
end

----------------------------------------------------------------------------
--	是否可以跳过预留房判断 
----------------------------------------------------------------------------
if @mststa = @omststa and @s_time = @oarr and @e_time = @odep and @rm_no = @oroomno and @rm_no>='0' and @rmnum=@ormnum and @blkcode=@oblkcode 
   select @skip_block = 1
if @mststa <> @omststa or @rm_no <> @oroomno or (@rm_type <> @otype and @rm_no<'0' and @oroomno<'0')
   select @needtotran = @needtotran+'R'


----------------------------------------------------------------------------
-- 针对 rmsta的判断： @rm_no 是否存在、 rmsta accntset
--	注意排除虚拟房号
----------------------------------------------------------------------------
if @rm_no>'0'
begin
   select @ocsta=ocsta, @rmsta=sta, @number=number,@rm_type=type,@tmpsta=tmpsta from rmsta where roomno = @rm_no
   if @@rowcount = 0
	begin
		select @ret = 1,@msg = "系统中还未设此房号 - %1^" + @rm_no
      goto         RET_P
	end
	-- 判断[@s_time, @e_time)期间该房是否被锁定 ----by yjw   以前从rmsta中取,现在从rm_ooo中取
	if exists(select 1 from rm_ooo where roomno = @rm_no and status = 'I' --and sta = 'O'
		and (dend is null or datediff(dd,dend, @s_time)<0) and datediff(dd,dbegin,@eetime)>0)
	begin
		select @ret = 1,@msg = "该房在抵离期间将维修, 请与房务中心联系"
      goto         RET_P
	end

	-- 脏房入住的判断
	if @mststa='I' and @omststa <> @mststa and @ocsta='V' and @rmsta = 'D' 
		and @allow_dirty_register_in = 'N'   --- and charindex(@idcheck,'T')=0
	begin
		select @ret = 1,@msg ="该房未清洁,不能入住"
		goto        RET_P
	end
	-- 不能预订的临时态；
	if @mststa in ('R','C','G') and (@rm_no <> @oroomno or @mststa<>@omststa)
		and @tmpsta<>'' and datediff(dd,@s_time,getdate())=0
		and exists(select 1 from rmstalist1 where code=@tmpsta and rlock='T')
	begin
		select @ret = 1,@msg ="该房正在处于临时限制状态, 请检查 !"
		goto        RET_P
	end
	
	-- 不能入住的临时态；
	if @mststa='I' and (@oroomno <> @rm_no or @mststa<>@omststa) and @tmpsta<>''
		and exists(select 1 from rmstalist1 where code=@tmpsta and ilock='T')
	begin
		select @ret = 1,@msg ="该房正在处于临时限制状态, 请检查 !"
		goto        RET_P
	end

   if @oroomno <> @rm_no
	begin
      if @oroomno>'0' and charindex(@omststa,'RCGI') > 0  -- 换房
		begin
			update rmsta set logmark=logmark+1,empno=@empno,changed=getdate() where roomno = @oroomno
			if charindex(@mststa,'RCGI') > 0  -- 这个 if...else...的后面不是包含在前面吗 ?
				update rmsta set logmark=logmark+1,empno=@empno,changed=getdate() where roomno = @rm_no 
			else
				update rmsta set sta = sta where roomno = @rm_no and @mststa = 'I' 
		end
      else		-- 分房
		begin
         if charindex(@mststa,'RCGI') > 0
            update rmsta set sta = sta,logmark=logmark+1,empno=@empno,changed=getdate() where roomno = @rm_no 
         else
            update rmsta set sta = sta where roomno = @rm_no and @mststa = 'I' 
		end 
	end 
   else if @mststa <> @omststa or charindex('A',@needtotran) > 0 or charindex('D',@needtotran) > 0 
      update rmsta set sta = sta,logmark=logmark+1,empno=@empno,changed=getdate() where roomno = @rm_no 

   if @skip_block <> 0
      goto RET_S		-- 跳过 预留房判断
end 
else if @oroomno>'0' and charindex(@omststa,'RCGI') > 0  -- 取消分房
	update rmsta set logmark=logmark+1,empno=@empno,changed=getdate() where roomno = @oroomno

-- 
select @msg = @msg + @rsvchk 

---------------------------------------
-- 预留房更新------先更新再判断
---------------------------------------
-- 1. 取消客房资源
---------------------------------------
if charindex(@mststa,'RCGI') = 0    -- ------> not reserve sta 
begin
	-- 减少预留房
   if charindex(@omststa,'RCGI') <> 0  -- Cancel a reservation etc...... 
	begin
		-- 可能有多个记录
		declare	@id		int
		while exists(select 1 from rsvsrc where accnt=@accnt)
		begin
			select @id=max(id) from rsvsrc where accnt=@accnt
			exec p_gds_reserve_rsv_del @accnt,@id,'R',@empno,@ret output, @msg output
		end
	   if charindex(@omststa,'I') <> 0  -- checkout etc ...... 
		   exec p_gds_reserve_flrmsta @oroomno,@accnt,'DELE',@empno
	end
   goto RET_S 
end
---------------------------------------
-- 2. 取得,或者更新 客房资源
---------------------------------------
else     -----> reserve sta 
begin
	-- 判断冲突
	if @rm_no >= '0' 
	begin
		declare	@conflict	int
		select @conflict = isnull((select count(1) from master a
												where a.sta in ('R', 'I') and a.roomno=@rm_no 
													and a.share<>'T'
													and a.accnt<>@accnt 																			-- 排除自己
													and a.master<>@master 																		-- 排除同住
													and a.accnt not in (select accnt from host_accnt where host_id=@host_id) 	-- 排除同步处理
													and datediff(dd, @s_time, a.dep)>0 and datediff(dd, @e_time, a.arr)<0
													--and not (@groupno<>'' and a.groupno=@groupno) --团队为何排除？先去掉(因为导致批量处理没有提醒)
										), 0)
		if @conflict > 0 
		begin
		select @saccnt = isnull((select max(a.accnt) from master a
												where a.sta in ('R', 'I') and a.roomno=@rm_no 
													and a.share<>'T'
													and a.accnt<>@accnt 																			-- 排除自己
													and a.master<>@master 																		-- 排除同住
													and a.accnt not in (select accnt from host_accnt where host_id=@host_id) 	-- 排除同步处理
													and datediff(dd, @s_time, a.dep)>0 and datediff(dd, @e_time, a.arr)<0
													--and not (@groupno<>'' and a.groupno=@groupno)
										), '')
			select @ret = 1,@msg = "客房 %1 已经被占用^" + @rm_no + "("+ @saccnt +")"
			goto RET_P
		end
	end

	-- 资源处理
	if charindex(@omststa,'RCGI') <> 0 and @omststa<>''	-- 资源变化 
	begin
		exec p_gds_reserve_rsv_mod @accnt,0,@rm_type,@rm_no,'',@marr,@mdep,@rmnum,@gstno,@setrate,'',
			@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
		if @ret<>0 
		begin
			select @msg = @msg + '---' + @omststa
			goto RET_P
		end
      if charindex(@omststa,'I') <> 0  
		begin
			if @oroomno<>@rm_no or @mststa<>'I'
				exec p_gds_reserve_flrmsta @oroomno,@accnt,'DELE',@empno
			else --if @nick = 'I' and @mststa='I' and @oroomno=@rm_no
				exec p_gds_reserve_flrmsta @oroomno,@accnt,'DELE!',@empno
--			else
--				exec p_gds_reserve_flrmsta @oroomno,@accnt,'DELE',@empno
		end
	end
	else																	-- 新增资源 
	begin
		if @oroomno<>'' and @rm_no=''
			exec p_gds_reserve_rsv_add @accnt,@rm_type,@rm_no,'Grid-Rood',@marr,@mdep,@rmnum,@gstno,@setrate,'',
				@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
		else
			exec p_gds_reserve_rsv_add @accnt,@rm_type,@rm_no,'',@marr,@mdep,@rmnum,@gstno,@setrate,'',
				@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
		-- 这里的  flrmsta 在下面进行 !
	end
end 

----------------------------------------------------------------------------
-- 新入住时，此时rmsta里的sccntset还没有更新。控制每间房人数 和 fill rmsta
----------------------------------------------------------------------------
if @mststa = 'I'
begin
   select @accntset=accntset,@number = number from rmsta where @rm_no = roomno and charindex(@accnt,accntset) = 0
	if @@rowcount > 0
	begin 
		if @number>=6
		begin
			select @ret = 1,@msg = "该房已有六张帐单, 不可再加"
			goto        RET_P
		end
		exec p_gds_reserve_flrmsta @rm_no,@accnt,'ADD',@empno
	end
end 


---------------------------------------------------------
-- 此时，资源处理已经完成，现在判断资源可否被占用 
---------------------------------------------------------
-- 散客的情况：已分房 或 需要预留控制  (团体成员的情况不需要处理 ?)
---------------------------------------------------------
select @pblkno = 0, @prmtk = 0
if @groupno<>'' and ( @rm_no>='0' or charindex(@cntlblock,'tT') > 0 )
begin		-- 这里，针对散客订多间房，房数如何传递 ? gds
   exec p_getavail @accnt,@omststa,@rm_type,@rm_no,@s_time,@e_time,@otype,@oroomno,@oarr,@odep,@pblkno output,@prmtk output
   if @pblkno < 0 and charindex(@cntlblock,'tT') > 0 and ( @rm_no<'0' or @allow_check_roomno_first <> 'Y')
	begin
      select @ret = 1,@msg = "没有足够的房类资源,请换房类或请有关人员调整预留控制参数"
      goto         RET_P
	end
end

--------------------------------------
-- 事务顺利完成,保存更新结果 
--------------------------------------
RET_S:
if @ret=0
begin
	-- 凌晨房费入账 2007.5 
	if @class='F' and (@omststa='' or @omststa='R' or @omststa='C' or @omststa='G') and @mststa='I' 
	begin
		if exists(select 1 from sysoption where catalog='ratemode' and item='new_morning_post' and (value='T' or value='t'))
			begin
			exec @ret = p_gl_audit_rmpost_added '02', @pc_id, 0, @shift, @empno, @accnt, 'RN'
			if @ret<>0 
				select @msg='凌晨房费入账错误'
//			else
//				begin
//				--夜审后到店的客人，凌晨加收房费的时候如果有包价，则包价的使用时间要调整
//				update package_detail set starting_date = bdate,closing_date = dateadd(dd,1,bdate) where accnt = @accnt
//				--FHB Added At 20091104 For package_detail To pos_package_detail
//				declare c_package cursor for select number,quantity from package_detail where accnt = @accnt
//				open c_package
//				fetch c_package into @number1,@quantity
//				while @@sqlstatus = 0
//				begin
//					while @quantity>0
//					begin
//						select @num = isnull(max(number),0) + 1 from pos_package_detail where accnt = @accnt
//						insert pos_package_detail  (accnt,number,roomno,name1,fname,name2,name4,username,arr,dep,groupno,groupname,pcrec,code,descript,
//										descript1,price,pccode,pos_pccode,pos_shift,pos_menu,pos_number,bdate,pos_sta,pda_date,sta,pc_id,empno,shift,bdate1,remark,quantity )
//						select a.accnt,@num,a.roomno,b.name,isnull(rtrim(b.fname),'')+isnull(rtrim(b.lname),''),b.name2,b.name4,b.name,c.arr,
//								 c.dep,c.groupno,e.name,c.pcrec,a.code,a.descript,a.descript1,f.amount,f.pccode,f.pos_pccode,f.type,'',1,a.starting_date,
//									'N',null,'N','','','',null,'',1
//						from package_detail a,guest b,master c,guest e,package f
//								where a.accnt = @accnt and a.number = @number1 and a.accnt = c.accnt and c.haccnt = b.no and c.haccnt *= e.no and  a.code = f.code
//						select @quantity = @quantity - 1
//					end
//					fetch c_package into @number1,@quantity
//				end
//	
//				close c_package
//				deallocate cursor c_package
//				end
				
			end 
	end

	if @ret=0 and charindex(@class, 'GM')>0 
		exec @ret = p_gds_update_group @accnt, @empno, @grpmstlogmark,@msg output
	if @ret=0
	begin
		if @mststa=@omststa or @mststa=@nick  --sta 发生变化的时候，bdate 变化
			update master set osta = sta ,otype = @rm_type,type = @rm_type,oroomno = roomno,
				oarr = arr, odep = dep, ormnum=rmnum, oblkcode=blkcode  where accnt = @accnt
		else
		begin
			if exists(select 1 from gate where audit = 'T') and @mststa='N'  -- 正在稽核, No-Show
				select @bdate = dateadd(dd, -1, @bdate)
			update master set osta = sta ,otype = @rm_type,type = @rm_type,oroomno = roomno,
				oarr = arr, odep = dep, ormnum=rmnum, bdate=@bdate, oblkcode=blkcode  where accnt = @accnt
		end
		 
		--modi by zk 2009-5-21 处理资源变更后master字段的变动
		select @master = master from master where accnt = @accnt
		if @master = '' 
			update master set master = accnt where accnt = @accnt
  
		if @groupno <> ''  -- and @ndmaingrpmst = 1 
			exec @ret = p_gds_maintain_group @groupno,@empno,@grpmstlogmark,@msg output
	end 
end
if @ret <> 0
   rollback tran p_gds_reserve_chktprm_son_s1
else
begin
	if datalength(@needtotran) > 0 and @nullwithreturn is not null
   	select @msg = 'guestmodified'
	if @mststa<>@omststa and (@mststa='I' or @omststa='I') 
	begin
		if @rm_no>='0' 
			exec p_gds_lgfl_rmsta @rm_no 
		if @rm_no<>@oroomno and @oroomno>='0' 
			exec p_gds_lgfl_rmsta @oroomno 
	end 
	exec p_yjw_rsvsrc_detail_accnt @accnt
end 
commit tran

if @nullwithreturn is null
   select @ret,@msg
else
   select @nullwithreturn = @msg
return @ret


--------------------------------------
-- 错误发生，回滚退出
--------------------------------------
RET_P:
rollback tran p_gds_reserve_chktprm_son_s1
commit   tran 

if @nullwithreturn is null
   select @ret,@msg 
else
   select @nullwithreturn = @msg
return @ret
;