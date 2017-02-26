
if exists(select * from sysobjects where name = "p_gds_sc_chktprm")
	drop proc p_gds_sc_chktprm
;
create proc p_gds_sc_chktprm
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
--	block 主单 处理过程 
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
	@otype      char(5) ,       -- 原房类   
	@oroomno    char(5) ,       -- 原房号   
	@oarr       datetime,       -- 原到日   
	@odep       datetime,       -- 原离日   
	@bdate      datetime,
	@setrate    money,
   @ocsta      char(1),
   @accntset   varchar(70),
	@extra		char(30),
	@def			char(1),
	@starsv		char(1),
	@status		char(10) 

declare 	@ratecode	varchar(10),	-- 房价码
			@rmnum		int,
			@class 		char(1),
			@marr			datetime,   	-- 记录含有时间信息的原始日期
			@mdep			datetime

declare   -- New for rsvsrc
			@src			char(3),
			@market		char(3),
			@packages	varchar(50),
			@srqs		   varchar(30),
			@amenities  varchar(30)

-- init the data 
select @ret = 0, @msg = ""
select @bdate = bdate1 from sysdata

-- 事务开始
begin tran 
save  tran p_gds_sc_chktprm_s1

-- 设置排它信号 ?
update chktprm set code = 'A'  

-- 从master中提取数据
select @mststa = sta,@setrate = setrate,@ratecode=ratecode, @class=class, @extra=extra, 
		@src=src, @market=market, @packages=packages, @srqs=srqs, @amenities=amenities,
		@mststa = sta ,@omststa = osta ,@gstno  = gstno,@rm_type = type,@rm_no = roomno,
		@s_time = arr ,@e_time  = dep  ,@otype  = otype,@oroomno =oroomno,
		@oarr   = oarr,@odep    =odep  ,@rmnum=rmnum, @status=status 
	from sc_master where accnt = @accnt

if @rm_no=null  select @rm_no=''
if @omststa='' select @omststa = ''

-- 
if @mststa <> @omststa 
begin 
	if @mststa in ('W', 'X', 'N') 
	begin 
		if exists(select 1 from rsvsrc where blkcode=@accnt) 
		begin 
			select @ret = 1,@msg = "该BLOCK已经在使用, 不能进行当前操作!"
			goto RET_P
		end 
		if exists(select 1 from master where blkcode=@accnt and sta in ('R', 'O', 'D')) 
		begin 
			select @ret = 1,@msg = "该BLOCK已经在使用, 不能进行当前操作!"
			goto RET_P
		end 
		if exists(select 1 from hmaster where blkcode=@accnt and sta in ('R', 'O', 'D')) 
		begin 
			select @ret = 1,@msg = "该BLOCK已经在使用, 不能进行当前操作!"
			goto RET_P
		end 
	end 
end 

-- 关于房数的一般性校验 
if @rmnum <= 0 
begin
	select @ret = 1,@msg = "房数只能 >= 1"
	goto RET_P
end

--
if @rm_type<>'' or @otype<>''
begin
	select @ret = 1,@msg = "Block主单禁止填写客房信息"
	goto RET_P
end

-- 去除日期时间中的时间部分 
select @marr = @s_time, @mdep = @e_time  -- 原始时间
select @s_time = convert(datetime,convert(char(8),@s_time,1))
select @e_time = convert(datetime,convert(char(8),@e_time,1))
select @oarr   = convert(datetime,convert(char(8),@oarr  ,1)) 
select @odep   = convert(datetime,convert(char(8),@odep  ,1))

if exists(select 1 from rsvsrc where accnt=@accnt and (begin_<@s_time or end_>@e_time))
begin
	select @ret = 1,@msg = "抵离日期与客房占用矛盾,请先调整客房占用!"
	goto RET_P
end
if exists(select 1 from rsvsrc where blkcode=@accnt and (begin_<@s_time or end_>@e_time))
begin
	select @ret = 1,@msg = "抵离日期与订单占用矛盾,不能处理!"
	goto RET_P
end

--
select @def=definite, @starsv=starsv from sc_ressta where code=@status 

--------------------------------------------------------
-- block 主单预留房的变化 -- 必须放在 sc_chktprm 里面
--		根据sta, osta 进行预留房的资源变化 
exec @ret = p_gds_sc_block_change @accnt, @empno, @msg output 
if @ret<>0 
	goto RET_P
--------------------------------------------------------


-- block 禁止使用客房信息，下方代码可以取消  simon 2006/9
-----------------------------------------
---- 预留房更新------先更新再判断
-----------------------------------------
---- 1. 取消客房资源
-----------------------------------------
--if charindex(@mststa,'RI') = 0       -- ------> not reserve sta 
--begin
--	-- 减少预留房
--   if charindex(@omststa,'RI') <> 0  -- Cancel a reservation etc...... 
--	begin
--		-- 可能有多个记录
--		declare	@id		int
--		while exists(select 1 from rsvsrc where accnt=@accnt)
--		begin
--			select @id=max(id) from rsvsrc where accnt=@accnt
--			select @msg = 'sc!'
--			exec p_gds_reserve_rsv_del @accnt,@id,'R',@empno,@ret output, @msg output
--		end
--	end
--   goto RET_S 
--end
-----------------------------------------
---- 2. 取得,或者更新 客房资源
-----------------------------------------
--else     -----> reserve sta 
--begin
--
--	-- 资源处理
--	if charindex(@omststa,'RI') <> 0 and @omststa<>''
--	begin
--		select @msg = 'sc!'
--		exec p_gds_reserve_rsv_mod @accnt,0,@rm_type,@rm_no,'',@marr,@mdep,@rmnum,@gstno,@setrate,'',
--			@setrate,'',@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
--		if @ret<>0 
--		begin
--			select @msg = @msg + '---' + @omststa
--			goto RET_P
--		end
--	end
--	else
--	begin
--		select @msg='sc!grp'  -- 表示是团体主单自己的资源
--		exec p_gds_reserve_rsv_add @accnt,@rm_type,@rm_no,'',@marr,@mdep,@rmnum,@gstno,@setrate,'',
--			@setrate,'',@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
--	end 
--end 
--
--------------------------------------
-- 事务顺利完成,保存更新结果 
--------------------------------------
RET_S:
if @ret=0
begin
	exec @ret = p_gds_sc_update_group @accnt, @empno, @grpmstlogmark,@msg output
	if @ret = 0
	begin
		if @mststa = @omststa   -- sta 发生变化的时候，bdate 变化
			update sc_master set osta = sta ,otype = @rm_type,type = @rm_type,oroomno = roomno,
				oarr = arr, odep = dep where accnt = @accnt
		else
		begin
			if exists(select 1 from gate where audit = 'T') and @mststa='N'  -- 正在稽核, No-Show
				select @bdate = dateadd(dd, -1, @bdate)
			update sc_master set osta = sta ,otype = @rm_type,type = @rm_type,oroomno = roomno,
				oarr = arr, odep = dep, bdate=@bdate  where accnt = @accnt
		end

	end 
end

if @ret <> 0
   rollback tran p_gds_sc_chktprm_s1
commit tran

if @ret = 0
begin 
	-- 以下处理放到事务外边 
	-- 房价码修改，则更新价格 
	if exists(select 1 from rsvsrc where accnt=@accnt and ratecode<>@ratecode)
	begin 
		declare @date datetime, @type char(5), @rate money, @id int 
		declare c_rate cursor for select id, begin_, type, quantity from rsvsrc where accnt=@accnt and ratecode<>@ratecode  
		open c_rate 
		fetch c_rate into @id, @date, @type, @rmnum 
		while @@sqlstatus = 0
		begin
			exec p_gds_get_rmrate @date, 1, @type, '', @rmnum, 1, @ratecode, '', 'R', @rate output, @msg output -- 这里不再获取 @ret, 避免影响过程返回值  
			if @rate is null 
				select @rate = 0 
			update rsvsrc set ratecode=@ratecode, rate=@rate where accnt=@accnt and id=@id 
			fetch c_rate into @id, @date, @type, @rmnum 
		end
		close c_rate
		deallocate cursor c_rate 
	end 

	-- backup the rsv info 
	if (@def='T' and @starsv='R') or @starsv in ('I', 'X', 'N', 'O') 
		insert rsvsrc_blkinit 
			select a.* from rsvsrc a 
				where a.accnt=@accnt 
					and a.accnt+a.type+convert(char(10),a.begin_,111) 
						not in (select b.accnt+b.type+convert(char(10),b.begin_,111) from rsvsrc_blkinit b where a.accnt=b.accnt)
end

if @nullwithreturn is null
   select @ret,@msg
else
   select @nullwithreturn = @msg
return @ret


--------------------------------------
-- 错误发生，回滚退出
--------------------------------------
RET_P:
rollback tran p_gds_sc_chktprm_s1
commit   tran 

if @nullwithreturn is null
   select @ret,@msg 
else
   select @nullwithreturn = @msg
return @ret
;
