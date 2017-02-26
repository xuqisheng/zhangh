
if exists(select 1 from sysobjects where name = "p_gds_update_room_status" and type = 'P')
   drop proc p_gds_update_room_status;
create proc p_gds_update_room_status
   @rm_no   char(5),     	-- 房号 
   @lockop  char(1),     	-- 操作类别:'L',为加锁定操作,'l',为解锁定操作,
									--	 其它为一般操作
                         
   @sta     char(1),     -- 新状态 
   @s_time  datetime,    -- 锁定起始日期,或未来房启用日期 
   @e_time  datetime,    -- 锁定结束日期 
   @empno   char(10),     -- 操作员工号 
   @retmode char(1),     -- 返回方式   
   @msg     varchar(60)  output 

as

-- ---------------------------------------------------------------------------
--		修改房态
--
--			状态种类－1: R, D, I, T  -- 没有时间性，立即修改，与客房是否占用、预订无关。
--											其中，I, T 这两种房态有的用户可能不需要
--
--			状态种类－2: O, S        -- 有时间性，不一定立即修改
--											目前，系统针对某客房的有效维修记录只能为 1 条。
--											因为，状态和时间需要放在 rmsta 表中
-- ---------------------------------------------------------------------------

declare
   @t_time   	datetime,
   @ret      	int,
   @cgetdate 	datetime,
   @ocsta    	char(1),
   @osta     	char(1),
	@rmtype		char(5),
	@over			int,
	@locked char(1), @futbegin datetime, @futend datetime

select @ret=0,@msg='',@cgetdate = convert(datetime,convert(char(10),getdate(),111))
select @rmtype = type from rmsta where roomno = @rm_no
if @@rowcount = 0
begin
	select @ret=1,@msg= '%1 - 房号不存在^'+@rm_no 
	if @retmode ='S'
		select @ret,@msg
	return @ret
end

begin tran
save  tran p_gds_update_room_status_s1

update rmsta set sta = sta where roomno = @rm_no
select @ocsta = ocsta,@osta = sta from rmsta where roomno = @rm_no

-- 维修 、维护房处理
if charindex(@lockop,'lL') > 0
	begin
   if @lockop ='l'  -- 解锁
	   begin
	   if exists(select 1 from rmstalist where sta = @osta and maintnmark='T')
		   begin
		   if exists(select 1 from rmstalist where sta = @sta and charindex(maintnmark,'T') = 0)
			   update rmsta set logmark=logmark+1,sta = @sta,empno = @empno,changed = getdate(),locked = 'N',futbegin = null,futend = null,fempno = @empno,fcdate = getdate(),osno='' where roomno = @rm_no
         else
			   select @ret = 1,@msg = '解除当前维护房状态后,新设房态无效'
         end 
	   else
		   update rmsta set logmark=logmark+1,locked = 'N',futbegin = null,futend = null,fempno = @empno,fcdate = getdate() where roomno = @rm_no
	   end
   else				-- 加锁
	   begin
	   select @s_time = convert(datetime,convert(char(10),@s_time,111))
	   select @e_time = convert(datetime,convert(char(10),@e_time,111))
	   if @s_time is not null and @e_time is not null
		   begin
		   if @s_time > @e_time
            begin
			   select @t_time = @s_time
			   select @s_time = @e_time
			   select @e_time = @t_time  
			   end
		   if @s_time = @e_time
		      select @e_time = dateadd(day,1,@s_time) 
		   end
	   else if @s_time is null
		   select @ret=1,@msg='请指定锁定起始日期'
	   if @ret = 0 and @s_time <  @cgetdate
		   select @ret=1,@msg='锁定起始日期不能小于今天'

	   if @ret = 0 and @sta<>'S'  -- 锁定房设置不判断 
         begin
			-- 是否需要判断资源呢？ - 如果只是修改维修记录，可以不判断了
			select @locked=locked, @futbegin=futbegin, @futend=futend from rmsta where roomno=@rm_no 
			if not (@locked='L' and datediff(dd, @futbegin, @s_time)>=0 and datediff(dd, @futend, @e_time)<=0 )
			begin
				-- 资源判断
				exec @ret = p_gds_reserve_type_avail @rmtype,@s_time,@e_time,'1','R',@over output
				if @ret<>0 or @over<0
					select @ret=1, @msg='客房超预留'
				else
					begin
					exec p_gds_reserve_ctrltype_check @rmtype, @s_time, @e_time, 'R', @over output
					if @over > 0
						select @ret=1, @msg='大客房超预留'
					else
						begin 
						exec p_gds_reserve_ctrlblock_check @s_time, @e_time, 'R', @over output
						if @over > 0
							select @ret=1, @msg='客房总量控制超界'
						else
							begin
							if exists (select roomno from rsvroom where roomno = @rm_no and quantity > 0
											 and ((@e_time is null and @s_time < end_) or (@e_time > begin_ and end_ > @s_time)))
								select @ret=1,@msg='指定的锁定区间该房已有预订,请检查'
							end
						end 
					end
				end 
         end 
		else if @ret = 0 and @sta='S'
			begin
			select @locked=locked, @futbegin=futbegin, @futend=futend from rmsta where roomno=@rm_no 
			if not (@locked='L' and datediff(dd, @futbegin, @s_time)>=0 and datediff(dd, @futend, @e_time)<=0 )
				begin
				if exists (select roomno from rsvroom where roomno = @rm_no and quantity > 0
						 and ((@e_time is null and @s_time < end_) or (@e_time > begin_ and end_ > @s_time)))
				select @ret=1,@msg='指定的锁定区间该房已有预订,请检查'
				end
			end

	  if @ret = 0
		  begin
		  if exists(select 1 from rmstalist where sta = @sta and maintnmark='T')
			  begin
  		     update rmsta set  logmark=logmark+1,locked='L',futsta=@sta,futbegin = @s_time,futend = @e_time,
	                          fempno = @empno,fcdate = getdate()
						      where roomno = @rm_no
		     if @@rowcount > 0 and @s_time = @cgetdate
				  update rmsta set sta = @sta,empno = @empno,changed = getdate()
                     where roomno = @rm_no -- and ocsta = 'V'
			  end
		  else
			  select @ret=1,@msg='维护房锁定时,需指明具体的维护状态'
		  end
	  end
	end

-- 一般处理
else
   begin
   if exists(select 1 from rmstalist where sta = @sta and charindex(maintnmark,'T') > 0 )
	   select @ret=1,@msg='要改成维护房,请使用维护房加锁功能'
   else if not exists(select 1 from rmstalist where sta = @sta and charindex(maintnmark,'T') = 0 )
	   select @ret=1,@msg='请使用系统设定的房态'
   else if exists(select 1 from rmstalist where sta = @osta and charindex(maintnmark,'T') > 0 )
	   select @ret=1,@msg='要解除维护房,请使用维护房解锁功能'
   else if @sta = @osta 
  	   select @ret=1,@msg='该房状态已经是您想要设置的状态, 无需更改为'
   else 
	   update rmsta set logmark=logmark+1,sta = @sta,empno = @empno,changed = getdate() where roomno = @rm_no
   end

if @ret <> 0
   rollback tran p_gds_update_room_status_s1
commit tran

if @retmode ='S'
   select @ret,@msg
return @ret
;

