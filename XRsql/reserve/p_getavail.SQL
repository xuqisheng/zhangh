
/* ----------------------------------------------------------------------
	判断房类房间资源状况
		p_grp_getavail
		p_getavail
		p_mem_getavail
 ---------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------------------------
	p_grp_getavail: 判断房类资源状况(团体主单)
----------------------------------------------------------------------------------------------- */
if  exists(select * from sysobjects where name = "p_grp_getavail")
	 drop proc p_grp_getavail;
create proc p_grp_getavail
   @groupno  char(7),
	@rm_type  char(5),
	@s_time   datetime,
	@e_time   datetime,
   @rsvmode  char(1),
	@pblkno   int output,
   @msg      varchar(60) output
as

declare
   @ret    int,
	@_begin datetime ,
	@_end   datetime ,
	@rend   datetime ,
	@pbeg   datetime ,
	@pend   datetime ,
	@grpblock int,
	@grppick  int,
   @picked   int, 
   @cur_usable int,
   @grppick1 int,
   @grppick2 int
declare
	@pquan			int,
	@pover			int,
	@adjquan		   int,
   @adjdate		   datetime,
	@plocked		   int,
   @pblock			int,
	@needadj		   char(1),
	@needlocked		char(1),
	@futbegin      datetime,
	@futend        datetime,
	@cntlblock     char(1),
   @cntlquan      int


select @ret=0,@msg=""
select @cntlblock = value from sysoption where catalog = "reserve" and item = "cntlblock"
if  @@rowcount = 0
	select  @cntlblock  = "T"
if @cntlblock = 'T'
   select @cntlquan = convert(int,value) from sysoption where catalog = "reserve" and item = "cntlquan"
else
   select @cntlquan = 0 
select @s_time = convert(datetime,convert(char(10),@s_time,111)),@e_time = convert(datetime,convert(char(10),@e_time,111))
if @e_time <= @s_time
   select @e_time = dateadd(day,1,@s_time)
if charindex(@rsvmode,'ao') = 0
   begin 
   select @pbeg = @s_time ,@pend = @e_time,@pblkno = 50000,@picked = 0

   /* check group itself */
    
   declare c_grp_getavail_grp cursor for
     	   select begin_,end_,quantity
    	   from rsvdtl where  accnt = @groupno and type = @rm_type and end_ > @pbeg and @pend > begin_
		   order by begin_
   declare c_grp_getavail_mem cursor for
     	   select begin_,end_,quantity
		   from rsvdtl where  type = @rm_type and end_ > @pbeg and @pend > begin_
						   and accnt in (select accnt from master where groupno= @groupno)
   while (@pbeg < @e_time)
      begin
      /* 提取团体预留数 */
	   open c_grp_getavail_grp
	   fetch  c_grp_getavail_grp into @_begin,@_end,@grpblock
	   if @@sqlstatus = 0
         begin
         if @_begin <= @pbeg
    	      begin
     	      if @_end < @pend
	    	      select @pend = @_end
			   end
		   else
			   select @pend = @_begin,@grpblock =0
		   end
	   else
		   select @grpblock =0
	   close c_grp_getavail_grp
	   /* 提取团体分配数 */
	   select @rend = @pend,@grppick = 0
	   open  c_grp_getavail_mem
	   fetch c_grp_getavail_mem into @_begin,@_end,@picked
	   while (@@sqlstatus = 0)
		  begin
		  if (@_begin <= @pbeg)
			  begin
			  if (@_end < @rend)
				  select	@rend = @_end
			  select @grppick = @grppick + @picked
			  end
		  else if (@_begin < @rend)
			  select @rend = @_begin
		  fetch c_grp_getavail_mem into @_begin, @_end,@picked
		  end
	   close  c_grp_getavail_mem
	   select @pend = @rend
      /* 算法改变:重算@grppick */
      /* begin of insertion ----Renyao He 1998/08/02*/
      select @grppick1 = count(*) from rsvdtl 
		       where  type = @rm_type and @pbeg >= begin_ and @pend <= end_ and rtrim(roomno) is null 
						  and accnt in (select accnt from master where groupno= @groupno)
      select @grppick2 = count(distinct roomno) from rsvdtl 
		       where  type = @rm_type and @pbeg >= begin_ and @pend <= end_ and rtrim(roomno) is not null 
						  and accnt in (select accnt from master where groupno= @groupno)
      select @grppick2 = @grppick2-count(distinct a.roomno) from rsvdtl a,rsvdtl b
		       where  a.type = @rm_type and @pbeg >= a.begin_ and @pend <= a.end_ and rtrim(a.roomno) is not null 
                    and b.type = @rm_type and @pbeg >= b.begin_ and @pend <= b.end_ and rtrim(b.roomno) is not null 
						  and a.accnt in (select c.accnt from master c where c.groupno = @groupno)
						  and b.accnt in (select d.accnt from master d where d.groupno < @groupno)
                    and a.roomno=b.roomno
      select @grppick = @grppick2+@grppick1
      /* end of insertion ----Renyao He 1998/08/02*/
	   select @cur_usable = @grpblock - @grppick
	   if @cur_usable < @pblkno
		  select @pblkno = @cur_usable
	   if @pblkno < 0
		  begin
		  select @ret=1,@msg = "团体预留房数不能小于其分配数"
          deallocate cursor c_grp_getavail_grp
          deallocate cursor c_grp_getavail_mem
		  return @ret
		  end

	   /* 置下一个时间段 */

	   select	@pbeg = @pend
	   select	@pend = @e_time
	   end
   deallocate cursor c_grp_getavail_grp
   deallocate cursor c_grp_getavail_mem
   end
/* check availability */     
if charindex(@cntlblock,'tT') = 0
   return 0  
select @pblkno = 50000
select @pbeg	= @s_time,@pend	= @e_time,@needadj 	= 'Y',@needlocked = 'N'

select @pquan = quantity,@pover 	 = overquan,@adjquan = adjquan,@adjdate = futdate
	   from  typim  where type = @rm_type
if @cntlblock = 'T'
   select @pover = @cntlquan   
if (@adjquan =0) or (@adjdate >= @e_time)
   select 	@needadj = 'N'
else if (@adjdate <= @s_time)
   select  @pquan = @pquan + @adjquan,@needadj = 'N'

if exists(select roomno from rmsta where
					 type = @rm_type and locked = 'L' and
					 (futend is null or futend > @s_time) and futbegin < @e_time)
   select @needlocked = 'Y'

while (@pbeg < @e_time)
	begin
	-- 判断房类调整数目
	if	(@needadj = 'Y') and (@adjdate >= @pbeg) and (@adjdate < @pend)
    	if	(@adjdate = @pbeg)
			select	@pquan 	= @pquan + @adjquan,@needadj= 'N'
		else
			select	@pend 	= @adjdate

	-- 判断房类锁定数目
	select	@plocked = 0
	if	(@needlocked = 'Y')
		begin
		select	@rend = @pend,	@plocked = 0
		declare	c_grp_getavail_1 cursor for
				select	futbegin, futend from rmsta
						where type = @rm_type and locked = 'L' and
							  (futend is null or futend > @pbeg) and futbegin < @pend
		open   c_grp_getavail_1
		fetch  c_grp_getavail_1 into @futbegin, @futend
		while (@@sqlstatus = 0)
			begin
			if	(@futbegin <= @pbeg)
				begin
				if	(@futend < @rend)
					select	@rend = @futend
				select	@plocked = @plocked + 1
				end
			else
				if	(@futbegin < @rend)
					select	@rend = @futbegin
			fetch c_grp_getavail_1 into @futbegin, @futend
			end
		close c_grp_getavail_1
		deallocate cursor c_grp_getavail_1
		select	@pend = @rend
		end

    -- get the biggest quantity already blocked 
	select @pblock = isnull(max(blockcnt),0) from rsvtype
						where	(type = @rm_type) and (begin_ < @pend) and (end_ > @pbeg)
	select @cur_usable = @pquan + @pover - @plocked - @pblock 

	if @cur_usable < @pblkno
	   select @pblkno = @cur_usable

	if @pblkno < 0
		begin 
		select @ret=1,@msg = "没有足够的房类资源可供预留"
		return @ret
		end 

	/* Reset time interval */  
    select	@pbeg = @pend
	select	@pend = @e_time

	end
return @ret
;


/* -----------------------------------------------------------------------------------------------
	p_getavail: 判断房类及房号资源状况(散客)
----------------------------------------------------------------------------------------------- */
if exists(select * from sysobjects where name = "p_getavail")
	drop proc p_getavail;
create proc p_getavail
	@accnt				char(10),        	-- 帐号,用于补偿计算
   @omststa				char(1),        	-- osta in table master
	@rm_type				char(5),		     -- 房类
	@rm_no				char(5),		     -- 房号
	@s_time				datetime,        -- 开始时间
	@e_time				datetime,        -- 终止时间
	@otype				char(5),        --
	@oroomno				char(5),        --
	@oarr					datetime,       --
   @odep					datetime,       --
	@pblkno				int output,     -- 可用房类数。是否大于0为判断；
   @prmtk				int output      -- 房号中帐号数，判断共享的时候用；
as

declare
	@pquan			int,
	@pover			int,
	@adjquan		   int,
   @adjdate		   datetime,
	@plocked		   int,
	@pblock			int,
	@needadj		   char(1),
	@needlocked		char(1),		-- 有客房在未来需要维修（锁定）
	@pbeg			   datetime,
	@pend			   datetime,
	@futbegin		datetime,
	@futend			datetime,
	@rbeg			   datetime,   -- save begin_ 
	@rend			   datetime,   -- save end_ 
	@rquan         int,        -- save quantity where current of cursor
	@cur_useable	int,
	@needexcl1     char(1),
	@needexcl2     char(1),
	@pexcl1        int    ,
   @pexcl2        int    ,
	@allow_check_roomno_first char(1),
  	@cntlblock     char(1),
   @cntlquan      int

-- 系统预留控制参数 : 必须检查房类预留情况
select @cntlblock = value from sysoption where catalog = "reserve" and item = "cntlblock"
if  @@rowcount = 0
	select  @cntlblock  = "T"
if @cntlblock = 'T'
	begin
   select @cntlquan = convert(int,value) from sysoption where catalog = "reserve" and item = "cntlquan"
	if @@rowcount=0 or @cntlquan is null or @cntlquan<0 
		select @cntlquan = 0
	end
else
   select @cntlquan = 0 

select @s_time = convert(datetime,convert(char(10),@s_time,111)),@e_time = convert(datetime,convert(char(10),@e_time,111))
if @e_time <= @s_time
   select @e_time = dateadd(day,1,@s_time)

-- 系统预留控制参数 : 允许以房号检验为准, 而不考虑房类检验的结果标志
select @allow_check_roomno_first=value from sysoption where catalog="distribute" and item="allow_check_roomno_first"
if	@@rowcount = 0
	select @allow_check_roomno_first  = "N"

--assign initialization values to ...
select	@pbeg			= @s_time,
			@pend			= @e_time,
			@needadj 	= 'Y',
			@needlocked = 'N',
			@needexcl1  = 'N',
			@needexcl2  = 'N',
			@pblkno     = 50000,
			@prmtk      = 0

if @rm_no <> space(5)
   begin
   select @prmtk = count(1) from rsvdtl where @rm_type=type and @rm_no = roomno
		  and accnt<> @accnt and @e_time > begin_ and end_>@s_time and quantity > 0
   if @allow_check_roomno_first='Y' or charindex(@cntlblock,'tT') = 0
	  return 0
   end
else if charindex(@cntlblock,'tT') = 0
   return 0

select 	@pquan		= quantity, -- 客房数量
			@pover		= overquan,	-- 超额数量
			@adjquan 	= adjquan,	-- 调整数量
			@adjdate 	= futdate 
	from typim where type = @rm_type

if @cntlblock = 'T'
   select @pover = @cntlquan

if (@adjquan =0) or (@adjdate >= @e_time)
   select 	@needadj = 'N'
else
   if (@adjdate <= @s_time)
		select @pquan = @pquan + @adjquan, @needadj = 'N'

if @rm_no <> space(5)
   begin 
   if exists ( select 1 from rsvroom where @rm_type=type and @rm_no =roomno and end_ > @s_time and @e_time > begin_ )
	   select @needexcl2 = 'Y'
   end

if exists(select 1 from rmsta where	(type = @rm_type) and (locked = 'L') and
						  (futend is null or futend > @s_time) and futbegin < @e_time)
   select @needlocked = 'Y'

if @accnt <> space(10) and charindex(@omststa,'RCGI') <> 0 and @otype = @rm_type
                      and @e_time>@oarr and @odep>@s_time
   select @needexcl1 = 'Y'

while (@pbeg < @e_time)
	begin
	-- 判断房类调整数目
	if	(@needadj = 'Y') and (@adjdate >= @pbeg) and (@adjdate < @pend)
    	if	(@adjdate = @pbeg)
			select	@pquan 	= @pquan + @adjquan, @needadj= 'N'
		else
			select	@pend 	= @adjdate

	-- 判断房类锁定数目
	select @plocked = 0
	if	(@needlocked = 'Y')
		begin
		select	@rend = @pend,	@plocked = 0
		declare	c_getavail_1 cursor for
				select	futbegin, futend from rmsta
						where type = @rm_type and locked = 'L' and
							  (futend is null or futend > @pbeg) and futbegin < @pend
		open 	c_getavail_1
		fetch	c_getavail_1 into @futbegin, @futend
		while	(@@sqlstatus = 0)
			begin
			if	(@futbegin <= @pbeg)
				begin
				if	(@futend < @rend)
					select	@rend = @futend
				select	@plocked = @plocked + 1
				end
			else
				if	(@futbegin < @rend)
					select	@rend = @futbegin
			fetch c_getavail_1 into @futbegin, @futend
			end
		close 	c_getavail_1
		deallocate cursor c_getavail_1
		select	@pend = @rend
		end
	select @pexcl1 = 0,@pexcl2 = 0

   -- get the biggest quantity already blocked 
	select @pblock = max(blockcnt) from rsvtype where type=@rm_type and begin_<@pend and end_>@pbeg
	if @pblock is null
	   select @pblock = 0
	select @cur_useable = @pquan + @pover - @plocked - @pblock + @pexcl1 + @pexcl2

	if	@cur_useable < @pblkno
		select	@pblkno = @cur_useable

	if @pblkno < 0
		return 0

	-- Reset time interval
	select	@pbeg = @pend
	select	@pend = @e_time
	end

return 0
;

/* -----------------------------------------------------------------------------------------------
	p_mem_getavail: 判断房类及房号资源状况(团体成员)
----------------------------------------------------------------------------------------------- */
if exists(select * from sysobjects where name = "p_mem_getavail")
	drop proc p_mem_getavail;
create proc p_mem_getavail
	@accnt          char(7),        -- 帐号,用于补偿计算
   @omststa        char(1),        -- osta in table master
	@rm_type    	 char(5),		     -- 房类
	@rm_no			 char(5),		     -- 房号
	@s_time			 datetime,        -- 开始时间
	@e_time			 datetime,        -- 终止时间
	@otype          char(5),        --
	@oroomno        char(5),        --
	@oarr           datetime,       --
   @odep           datetime,       --
	@pblkno         int output,     --
   @prmtk          int output,     --
   @ignmark        char(1) = 'F'
as

declare
   	@pquan			int,
		@pbeg			datetime,
		@pend			datetime,
		@_begin			datetime,
		@_end			datetime,
		@rbeg			datetime,   -- save begin_ 
		@rend			datetime,   -- save end_ 
		@rquan          int,        -- save quantity where current of cursor
		@cur_usable	    int,
		@needexcl1      char(1),
		@needexcl2      char(1),
		@pexcl1         int    ,
      @pexcl2         int    ,
		@allow_check_roomno_first     char(1),
		@groupno        char(7),
		@grpblock       int,
		@grppick        int,
		@grppick1       int,
		@grppick2       int,
		@grppick3       int,
		@picked         int

select @s_time = convert(datetime,convert(char(10),@s_time,111)),@e_time = convert(datetime,convert(char(10),@e_time,111))
if @e_time <= @s_time
   select @e_time = dateadd(day,1,@s_time)
select  @groupno = groupno from master where accnt = @accnt
select	@pbeg	= @s_time,@pend	= @e_time,@needexcl1  = 'N',@needexcl2  = 'N',
		@pblkno     = 50000,@prmtk      =0,@grpblock   =0,@grppick    =0,@picked     =0
if @rm_no <> space(5)
   begin
   select @prmtk = count(*) from rsvdtl where @rm_type=type and @rm_no = roomno
		  and accnt<> @accnt and @e_time > begin_ and end_>@s_time
   if @ignmark = 'T'
      select @prmtk = count(*) from rsvdtl where @rm_type=type and @rm_no = roomno and @e_time > begin_ and end_>@s_time 
		       and accnt not in (select accnt from master where groupno=@groupno)
      
   end  
declare c_mem_getavail_grp cursor for
		select begin_,end_,quantity
		from rsvdtl where  accnt = @groupno and type = @rm_type
					and    end_ > @pbeg and @pend > begin_
		order by begin_
declare c_mem_getavail_mem cursor for
		select begin_,end_,quantity
		from rsvdtl where  type = @rm_type and end_ > @pbeg and @pend > begin_
						   and accnt in (select accnt from master where groupno= @groupno)
						   and accnt <> @accnt     
while (@pbeg < @e_time)
	begin

   /* 提取团体预留数 */
	open c_mem_getavail_grp
	fetch  c_mem_getavail_grp into @_begin,@_end,@grpblock
	if @@sqlstatus = 0
	   begin
	   if @_begin <= @pbeg
		   begin
		   if @_end < @pend
			   select @pend = @_end
		   end
	   else
		   select @pend = @_begin,@grpblock =0
	   end
	else
	   select @grpblock =0
	close c_mem_getavail_grp
   /* Deleted by Renyao He 1998/08/05 */
   /*
	if @grpblock = 0
	   begin
	   select @pblkno = 0
      break 
	   end
   */
	/* 提取团体分配数 */
   select @rend = @pend,@grppick = 0  
	open  c_mem_getavail_mem
	fetch c_mem_getavail_mem into @_begin, @_end,@picked
	while (@@sqlstatus = 0)
	   begin
	   if (@_begin <= @pbeg)
		   begin
		   if (@_end < @rend)
			   select	@rend = @_end
		   select @grppick = @grppick + @picked
		   end
	   else if (@_begin < @rend)
		   select @rend = @_begin
	   fetch c_mem_getavail_mem into @_begin, @_end,@picked
	   end
	close  c_mem_getavail_mem
	select @pend = @rend
   /* begin of insertion ----Renyao He 1998/08/02*/
   select @grppick1 = count(*) from rsvdtl 
	       where  type = @rm_type and @pbeg >= begin_ and @pend <= end_ and rtrim(roomno) is null 
					  and accnt in (select accnt from master where groupno= @groupno)  
   select @grppick2 = count(distinct roomno) from rsvdtl 
	       where  type = @rm_type and @pbeg >= begin_ and @pend <= end_ and rtrim(roomno) is not null 
					  and accnt in (select accnt from master where groupno= @groupno)  
   select @grppick2 = @grppick2-count(distinct a.roomno) from rsvdtl a,rsvdtl b
	       where  a.type = @rm_type and @pbeg >= a.begin_ and @pend <= a.end_ and rtrim(a.roomno) is not null 
                 and b.type = @rm_type and @pbeg >= b.begin_ and @pend <= b.end_ and rtrim(b.roomno) is not null 
					  and a.accnt in (select c.accnt from master c where c.groupno = @groupno) 
					  and b.accnt in (select d.accnt from master d where d.groupno < @groupno) 
                 and a.roomno=b.roomno
   select @grppick = @grppick1+@grppick2
   /* end of insertion ----Renyao He 1998/08/02*/
	select @cur_usable = @grpblock - @grppick
	if @cur_usable < @pblkno
	   select @pblkno = @cur_usable
	if (@pblkno < 0)
       break 

	/* 置下一个时间段 */


    select	@pbeg = @pend
	select	@pend = @e_time
	end
deallocate cursor c_mem_getavail_mem
deallocate cursor c_mem_getavail_grp
return 0
;
