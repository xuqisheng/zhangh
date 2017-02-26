
/* ----------------------------------------------------------------------
	团体预留房

		p_gds_reserve_groupblk
		p_gds_reserve_release_block
		p_gds_reserve_build_rsvetc
		p_gds_reserve_block_adjust

 ---------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------------------------
	p_gds_reserve_groupblk: 增量预留或覆盖预留
----------------------------------------------------------------------------------------------- */
//if exists(select * from sysobjects where name = "p_gds_reserve_groupblk")
//	drop proc p_gds_reserve_groupblk;
//create proc p_gds_reserve_groupblk
//   @accnt 			char(10),
//   @rm_type			char(3),
//   @s_time			datetime,
//   @e_time			datetime,
//   @quan     		int,
//   @empno    		char(10),
//   @rsvmode  		char(1),
//   @logmark  		int,
//   @nullwithreturn varchar(60) output
//as
//--	预留方式:  A/a 增量预留方式,    O/o 覆盖预留方式
//declare
//   @ret     int,
//   @msg     varchar(60),
//   @sta     char(1),
//   @arr     datetime,
//   @dep     datetime,
//   @retmark char(1),
//   @pbeg		datetime,
//   @pend		datetime,
//   @_begin	datetime,
//   @_end  	datetime,
//   @_quan  	int,
//   @pblkno 	int 
//
//select @ret=0, @msg=""
//
//if (@quan < 0 and charindex(@rsvmode,'oO') > 0) or (@quan = 0 and charindex(@rsvmode,'aA') > 0)
//   begin
//   if @quan < 0 
//	  select @ret = 1, @msg = "通过负预留操作来进行超预订控制需要更高权限"
//   else
//	  select @ret = 1, @msg = "请重输预留数,或选择覆盖预留方式释放预留房"
//   if @nullwithreturn is null
//	  select @ret,@msg
//   else
//      select @nullwithreturn = @msg  
//   return @ret
//   end
//
//begin tran
//save  tran p_gds_reserve_groupblk_s1
//
//update master set sta = sta where accnt = @accnt
//select @sta = sta,@arr = arr,@dep = dep from master where accnt = @accnt and class<>''
//if @@rowcount = 0
//   begin
//   select @ret = 1,@msg = "主单"+@accnt+"不存在"
//   commit tran
//   if @nullwithreturn is null
//	  select @ret,@msg
//   else
//      select @nullwithreturn = @msg  
//   return @ret
//   end
//
//select @s_time= convert(datetime,convert(char(10),@s_time,111))
//select @e_time= convert(datetime,convert(char(10),@e_time,111))
//select @arr   = convert(datetime,convert(char(10),@arr,111))
//select @dep   = convert(datetime,convert(char(10),@dep,111))
//if @e_time <= @s_time		-- day use 的处理方法注意 ?
//   select @e_time = dateadd(day,1,@s_time) 
//if @dep <= @arr
//   select @dep = dateadd(day,1,@arr) 
//
//if charindex(@sta,'RCGI') = 0
//   select @ret = 1,@msg = "主单"+@accnt+"非有效预订或登记状态"
//else if not ((@s_time >= @arr and @s_time <= @dep) and (@e_time >= @arr and @e_time <= @dep)) and charindex(@rsvmode,'OA') > 0 
//   select @ret = 1,@msg = "主单"+@accnt+"预留区间超出其抵离时间"
//if @ret <> 0
//	begin
//	commit tran
//	if @nullwithreturn is null
//	  select @ret,@msg
//	else
//		select @nullwithreturn = @msg  
//	return @ret
//	end
//
//-- 插入预留房纪录
//update chktprm set code = 'A'
//
//if charindex(@rsvmode,'aA') > 0	-- 新增模式
//	exec @ret = p_gds_reserve_filldtl @accnt,@rm_type,'     ',@s_time,@e_time,@quan
//else	-- 覆盖模式
//	begin
//	declare c_groupblk_grp_cursor cursor for select begin_,end_,quantity from rsvdtl
//		where accnt = @accnt and type = @rm_type and @pend > begin_ and end_ > @pbeg order by begin_
//	
//	select @pbeg = @s_time,@pend = @e_time
//	
//	open c_groupblk_grp_cursor
//	fetch c_groupblk_grp_cursor into @_begin,@_end,@_quan
//	while @@sqlstatus = 0
//		begin
//		if @_begin <= @pbeg
//			begin
//			if @_end >= @pend
//				begin
//				if @_quan <> @quan
//					begin
//					select @_quan = @quan - @_quan 
//					exec @ret = p_gds_reserve_filldtl @accnt,@rm_type,'     ',@pbeg,@pend,@_quan
//					end
//				select @pbeg = @pend  
//				break
//				end
//			else
//				begin
//				if @_quan <> @quan
//					begin
//					select @_quan = @quan - @_quan 
//					exec @ret = p_gds_reserve_filldtl @accnt,@rm_type,'     ',@pbeg,@_end,@_quan
//					end
//				select @pbeg = @_end
//				end
//			end
//		else
//			begin
//			exec @ret = p_gds_reserve_filldtl @accnt,@rm_type,'     ',@pbeg,@_begin,@quan
//			select @pbeg = @_begin
//			continue
//			end
//		
//		fetch c_groupblk_grp_cursor into @_begin,@_end,@_quan
//		end
//	
//	if @pbeg <> @pend
//	  exec @ret = p_gds_reserve_filldtl @accnt,@rm_type,'     ',@pbeg,@pend,@quan
//	
//	close c_groupblk_grp_cursor
//	deallocate cursor c_groupblk_grp_cursor
//	end
//
//-- 判断可用房 -- 从而得出是否合理的结论；
//if exists (select 1 from rsvdtl where accnt = @accnt and @e_time > begin_ and end_ > @s_time and quantity < 0) 
//   select @ret = 1 ,@msg = "通过负预留操作来进行超预订控制需要更高权限"
//if @ret  = 0
//   exec @ret = p_grp_getavail @accnt,@rm_type,@s_time,@e_time,@rsvmode,@pblkno output,@msg out
//if @ret = 0
//   exec @ret = p_hry_maintain_group @accnt,@empno,@logmark,@msg output
//
//if @ret <> 0
//   rollback tran p_gds_reserve_groupblk_s1
//commit tran
//
//if @nullwithreturn is null
//   select @ret,@msg
//else
//   select @nullwithreturn = @msg  
//
//return @ret
//;
//


/* -----------------------------------------------------------------------------------------------
	p_gds_reserve_release_block: 释放某团体所有预留房
----------------------------------------------------------------------------------------------- */
//if exists(select * from sysobjects where name = "p_gds_reserve_release_block")
//   drop proc p_gds_reserve_release_block;
//create proc p_gds_reserve_release_block
//   @accnt	char(10)
//as
//declare
//	@rm_type  char(3),
//	@pbeg     datetime,
//	@pend     datetime,
//	@_quan    int,
//	@ret      int,
//	@sta      char(1)
//
//select @ret=0 
//
//begin tran
//save  tran p_gds_reserve_release_block_s1
//
//update master set sta = sta where accnt = @accnt
//select @sta = sta from master where accnt = @accnt
//update chktprm set code = 'A'
//
//declare c_release_block_cursor cursor for
//	select type,begin_,end_,quantity from rsvdtl where accnt = @accnt order by type,begin_
//open  c_release_block_cursor
//fetch c_release_block_cursor into @rm_type,@pbeg,@pend,@_quan
//while @@sqlstatus = 0
//   begin
//   select @_quan = @_quan * -1 
//   exec @ret = p_gds_reserve_filldtl @accnt,@rm_type,'     ',@pbeg,@pend,@_quan
//   fetch c_release_block_cursor into @rm_type,@pbeg,@pend,@_quan
//   end
//close c_release_block_cursor
//deallocate cursor c_release_block_cursor
//
//commit tran 
//return @ret
//;


///* -----------------------------------------------------------------------------------------------
//	p_gds_reserve_build_rsvetc: 重建所有预留房
//----------------------------------------------------------------------------------------------- */
//if exists(select * from sysobjects where name = "p_gds_reserve_build_rsvetc")
//   drop proc p_gds_reserve_build_rsvetc;
//create proc p_gds_reserve_build_rsvetc
//   @pc_id   char(4) = 'PCID',
//   @modu_id char(2) = '01'
//as
//declare
//   @ret     int,
//   @msg     varchar(60),
//   @accnt   char(7),
//   @rmtype  char(3),
//   @roomno  char(5),
//   @pbeg   	datetime,
//   @pend  	datetime,
//   @groupno char(7)
//
//select @ret = 0,@msg=''
//begin tran
//save  tran p_gds_reserve_build_rsvetc_s1
//update chktprm set code = 'A'
//delete rsvtype
//delete rsvroom
//delete rsvdtl
//declare c_grpmst cursor for select accnt 
//        from grpmst where charindex(sta,'RCGI') >  0 
//        order by accnt 
//declare c_master cursor for select accnt,type,roomno,arr,dep,groupno
//        from master where charindex(sta,'RCGI') >  0 
//        order by accnt 
//open c_master
//fetch c_master into @accnt,@rmtype,@roomno,@pbeg,@pend,@groupno
//while @@sqlstatus = 0 
//   begin
//   select @pbeg = convert(datetime,convert(char(10),@pbeg,111)),@pend = convert(datetime,convert(char(10),@pend,111))
//   if @pbeg >= @pend 
//      select @pend = dateadd(day,1,@pbeg)
//   exec p_gds_reserve_filldtl @accnt,@rmtype,@roomno,@pbeg,@pend,1
//   fetch c_master into @accnt,@rmtype,@roomno,@pbeg,@pend,@groupno
//   end 
//close c_master
//deallocate cursor c_master
///* grpmst */
//open c_grpmst
//fetch c_grpmst into @accnt
//while @@sqlstatus = 0 
//   begin
//   exec @ret=p_gds_reserve_block_adjust @accnt,@pc_id,@modu_id,'R',@msg output 
//   fetch c_grpmst into @accnt
//   end 
//close c_grpmst
//deallocate cursor c_grpmst
//commit tran
//select @ret,@msg
//return @ret
//;
//

/* -----------------------------------------------------------------------------------------------
	p_gds_reserve_block_adjust: 团体预留房调整
											调整预留数等于其分配数(成员房数)
----------------------------------------------------------------------------------------------- */
//if exists(select * from sysobjects where name = "p_gds_reserve_block_adjust")
//   drop proc p_gds_reserve_block_adjust;
//create proc p_gds_reserve_block_adjust
//	@accnt		char(10),
//	@pc_id		char(4) = 'PCID',
//	@modu_id		char(2) = '01',
//	@retmode		char(1) = 'S',
//	@msg			varchar(60) = '' output
//as
//declare
//   @ret      	int,
//   @sta      	char(1),
//   @rm_type  	char(3),
//   @pbeg   	 	datetime,
//   @pend  	 	datetime,
//   @_quan    	int,
//   @pblkno   	int,
//   @rm_type2 	char(3) 
//
//select @ret = 0,@msg=''
//
//begin tran
//save  tran p_gds_reserve_block_adjust_s1
//
//update master set sta = sta where accnt = @accnt
//select @sta = sta from master where accnt = @accnt and class<>''
//if @@rowcount = 0
//   begin
//   select @ret = 1,@msg = "主单"+@accnt+"不存在"
//   commit tran
//   select @ret,@msg
//   return @ret 
//   end
//if charindex(@sta,'RCGI') = 0
//   begin
//   select @ret = 1,@msg = "主单"+@accnt+"非有效预订或登记状态"
//   commit tran
//   select @ret,@msg
//   return @ret
//   end
//
//update chktprm set code = 'A'
//
//--	release original blockings
//exec p_gds_reserve_release_block @accnt  
//
//-- scan rsvdtl for member pickup information
//delete rsvdtl_segment where pc_id = @pc_id and modu_id = @modu_id
//insert rsvdtl_segment select distinct @pc_id,@modu_id,type,begin_
//	from rsvdtl where accnt in (select accnt from master where groupno= @accnt)
//insert rsvdtl_segment select distinct @pc_id,@modu_id,rsvdtl.type,end_
//	from rsvdtl where accnt in (select accnt from master where groupno= @accnt)
//		and not exists ( select 1 from rsvdtl_segment b where b.pc_id = @pc_id and b.modu_id = @modu_id 
//								and b.type=rsvdtl.type and b.begin_=rsvdtl.end_)
//
//-- filldtl 
//declare c_rsvdtl_segment_type cursor for
//	select distinct type from rsvdtl_segment where pc_id = @pc_id and modu_id = @modu_id order by type 
//declare c_rsvdtl_segment_beg cursor for
//	select begin_ from rsvdtl_segment where pc_id = @pc_id and modu_id = @modu_id and type = @rm_type order by begin_
//open  c_rsvdtl_segment_type
//fetch c_rsvdtl_segment_type into @rm_type
//while (@@sqlstatus = 0)
//   begin
//   open  c_rsvdtl_segment_beg
//   fetch c_rsvdtl_segment_beg into @pend
//   while (@@sqlstatus = 0)
//      begin
//      select @pbeg = @pend 
//      fetch c_rsvdtl_segment_beg into @pend
//      if @@sqlstatus <> 0 
//         break 
//      select @_quan = count(roomno) from rsvdtl where accnt in (select accnt from master where groupno= @accnt)
//                      and type = @rm_type and @pbeg >= begin_ and @pend <= end_ 
//                      and rtrim(roomno) is null 
//      select @_quan = @_quan+count(distinct roomno) from rsvdtl where
//                      type = @rm_type and @pbeg >= begin_ and @pend <= end_ and rtrim(roomno) is not null 
//                      and accnt in (select c.accnt from master c where c.groupno= @accnt) 
//      select @_quan = @_quan-count(distinct a.roomno) from rsvdtl a,rsvdtl b where
//                      a.type = @rm_type and @pbeg >= a.begin_ and @pend <= a.end_ and rtrim(a.roomno) is not null 
//                      and b.type = @rm_type and @pbeg >= b.begin_ and @pend <= b.end_ and rtrim(b.roomno) is not null 
//                      and a.accnt in (select c.accnt from master c where c.groupno = @accnt)
//                      and b.accnt in (select d.accnt from master d where d.groupno < @accnt)
//                      and a.roomno=b.roomno
//      if @_quan <> 0
//         exec @ret = p_gds_reserve_filldtl @accnt,@rm_type,'     ',@pbeg,@pend,@_quan
//      end 
//   close  c_rsvdtl_segment_beg
//   fetch c_rsvdtl_segment_type into @rm_type
//   end 
//close c_rsvdtl_segment_type 
//deallocate cursor c_rsvdtl_segment_type 
//deallocate cursor c_rsvdtl_segment_beg 
//
//delete rsvdtl_segment where pc_id = @pc_id and modu_id = @modu_id
//commit tran
//
//if @retmode = 'S'
//   select @ret,@msg
//
//return @ret
//;
//