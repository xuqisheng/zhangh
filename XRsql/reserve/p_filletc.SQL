
/* ----------------------------------------------------------------------
	分房
		p_gds_reserve_filltype
		p_gds_reserve_dlshare
		p_gds_reserve_fillroom
		p_gds_reserve_filldtl
		p_gds_reserve_group_filldtl
		p_gds_reserve_flrmsta

 ---------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------------------------
	p_gds_reserve_filltype
----------------------------------------------------------------------------------------------- */
if exists(select * from sysobjects where name = "p_gds_reserve_filltype")
   drop proc p_gds_reserve_filltype;
create proc p_gds_reserve_filltype
   @rm_type       char(5),      -- 房类
   @s_time        datetime,     -- 开始时间
   @e_time        datetime,     -- 终止时间
   @blockcnt      int     ,     -- 预留数(包括散客预留及团体预留)
   @blkcnt        int     ,     -- 分配数(包括散客分配及成员分配:即拥有有效master数)
   @piccnt        int           -- 排房数(不但已分配,还排了房号)
as

declare
   @begin_t   datetime,         -- 当前游标开始时间
   @end_t     datetime,         -- 当前游表终止时间
   @m_time    datetime,         -- 动态插入段起始时间
   @n_time    datetime,         -- 动态插入段终止时间
   @bbcnt     int     ,         --
   @bcnt      int     ,         --
   @pcnt      int     ,         --
   @exitmark   int

begin  tran

select   @m_time = @s_time,@n_time = @e_time,@exitmark=0
declare c_filltype cursor for
		select blockcnt,blkcnt,piccnt,begin_,end_ from rsvtype
			where (type=@rm_type and end_>@s_time and @e_time > begin_)
		    order by type,begin_
open c_filltype
fetch c_filltype into @bbcnt,@bcnt,@pcnt,@begin_t,@end_t
while (@@sqlstatus=0)
   begin
   if @n_time <= @begin_t
      begin
      insert rsvtype (type,begin_,end_,blockcnt,blkcnt,piccnt)
			  values  (@rm_type,@m_time,@n_time,@blockcnt,@blkcnt,@piccnt)
      select @exitmark = 1
      break
      end
   else if @m_time < @begin_t
      begin
      insert rsvtype (type,begin_,end_,blockcnt,blkcnt,piccnt)
			  values  (@rm_type,@m_time,@begin_t,@blockcnt,@blkcnt,@piccnt)
      select @m_time = @begin_t
      continue
      end
   else if @m_time =@begin_t
      begin
      if @n_time = @end_t
         begin
  	     if @bbcnt+@blockcnt = 0 and @bcnt+@blkcnt = 0 and @pcnt+@piccnt = 0
            delete rsvtype where type=@rm_type and begin_ = @begin_t and end_=@end_t
         else
			update rsvtype set blockcnt = @bbcnt+@blockcnt,blkcnt = @bcnt+@blkcnt,piccnt = @pcnt+@piccnt where type=@rm_type and begin_ = @begin_t and end_=@end_t
         select @exitmark =1
         break
         end
      else if @n_time < @end_t
         begin
		 if @bbcnt+@blockcnt = 0 and @bcnt+@blkcnt = 0 and @pcnt+@piccnt = 0
            delete rsvtype where type=@rm_type and begin_ = @begin_t and end_=@end_t
         else
		    update rsvtype set end_ = @n_time,blockcnt = @bbcnt+@blockcnt,blkcnt=@bcnt+@blkcnt,piccnt = @pcnt+@piccnt
                   where  type=@rm_type and begin_ = @begin_t and end_=@end_t
         insert rsvtype (type,begin_,end_,blockcnt,blkcnt,piccnt)
                values  (@rm_type,@n_time,@end_t,@bbcnt,@bcnt,@pcnt)
		 select @exitmark = 1
         break
		 end
	  else
         begin
		 if @bbcnt+@blockcnt = 0 and @bcnt+@blkcnt = 0 and @pcnt+@piccnt = 0
            delete rsvtype where type=@rm_type and begin_ = @begin_t and end_=@end_t
         else
			update rsvtype set blockcnt = @bbcnt+@blockcnt,blkcnt=@bcnt+@blkcnt,piccnt = @pcnt+@piccnt
                   where type=@rm_type and begin_ = @begin_t and end_=@end_t
         select @m_time = @end_t
         end
      end
   else if @m_time >= @end_t
      begin
      fetch c_filltype into @bbcnt,@bcnt,@pcnt,@begin_t,@end_t
      continue
      end
   else
	  begin
	  update rsvtype set end_ = @m_time
			 where type=@rm_type and begin_ = @begin_t and end_=@end_t
	  select @begin_t = @m_time
	  if @end_t = @n_time
		 begin
		 if @bbcnt+@blockcnt <> 0 or @bcnt+@blkcnt <> 0 or  @pcnt+@piccnt <> 0
		    insert rsvtype (type,begin_,end_,blockcnt,blkcnt,piccnt)
				   values  (@rm_type,@m_time,@n_time,@bbcnt+@blockcnt,@bcnt+@blkcnt,@pcnt+@piccnt)
		 select @exitmark = 1
         break
		 end
	  else if @end_t > @n_time
		 begin
		 insert rsvtype (type,begin_,end_,blockcnt,blkcnt,piccnt)
				values  (@rm_type,@n_time,@end_t,@bbcnt,@bcnt,@pcnt)
		 if @bbcnt+@blockcnt <> 0 or @bcnt+@blkcnt <> 0 or  @pcnt+@piccnt <> 0
		    insert rsvtype (type,begin_,end_,blockcnt,blkcnt,piccnt)
				   values  (@rm_type,@m_time,@n_time,@bbcnt+@blockcnt,@bcnt+@blkcnt,@pcnt+@piccnt)
		 select @exitmark = 1
         break
		 end
	  else
		 begin
		 if @bbcnt+@blockcnt <> 0 or @bcnt+@blkcnt <> 0 or  @pcnt+@piccnt <> 0
		    insert rsvtype (type,begin_,end_,blockcnt,blkcnt,piccnt)
				   values  (@rm_type,@m_time,@end_t,@bbcnt+@blockcnt,@bcnt+@blkcnt,@pcnt+@piccnt)
         select @m_time = @end_t
		 end
	  end
   fetch c_filltype into @bbcnt,@bcnt,@pcnt,@begin_t,@end_t
   end
if @@sqlstatus <> 0 and @exitmark <> 1
   insert rsvtype (type,begin_,end_,blockcnt,blkcnt,piccnt)
          values  (@rm_type,@m_time,@n_time,@blockcnt,@blkcnt,@piccnt)
close c_filltype
deallocate cursor c_filltype
commit tran
return 0
;


/* -----------------------------------------------------------------------------------------------
	p_gds_reserve_dlshare
----------------------------------------------------------------------------------------------- */
if exists(select * from sysobjects where name = "p_gds_reserve_dlshare")
   drop proc p_gds_reserve_dlshare;
create proc p_gds_reserve_dlshare
   @rm_type        char(5),        -- 房类
   @rm_no          char(5),        -- 房号
   @s_time         datetime,       -- 开始时间
   @e_time         datetime,       -- 终止时间
   @accnt          char(10),       -- 帐号
   @ac_num         int
as
declare
   @beg_sta        char(1),
   @end_sta        char(1),
   @beg_groupno    char(10),
   @end_groupno    char(10),
   @groupno        char(10),
   @pblkno         int,
   @ret            int,
   @msg            varchar(60)

select @ret=0,@msg='',@pblkno=0

//if @ac_num > 0  /* add */
//   begin
//   /*取状态*/
//   if exists (select groupno from master,rsvdtl where master.accnt=rsvdtl.accnt and rsvdtl.roomno=@rm_no and @s_time>=begin_ and @e_time <=end_ and rsvdtl.accnt <> @accnt group by groupno having rtrim(groupno) is null)
//      begin
//      select @beg_sta='T'
//      end
//   else
//      begin
//      select @beg_sta='M'
//      select @beg_groupno= groupno from master,rsvdtl where master.accnt=rsvdtl.accnt and rsvdtl.roomno=@rm_no and @s_time>=begin_ and @e_time <=end_ and rsvdtl.accnt <> @accnt group by groupno having rtrim(groupno) is not null order by groupno desc
//      end
//   if exists (select groupno from master,rsvdtl where master.accnt=rsvdtl.accnt and rsvdtl.roomno=@rm_no and @s_time>=begin_ and @e_time <=end_ group by groupno having rtrim(groupno) is null)
//      begin
//      select @end_sta='T'
//      end
//   else
//      begin
//      select @end_sta='M'
//      select @end_groupno= groupno from master,rsvdtl where master.accnt=rsvdtl.accnt and rsvdtl.roomno=@rm_no and @s_time>=begin_ and @e_time <=end_ group by groupno having rtrim(groupno) is not null order by groupno desc
//      end
//   end
//else /* Delete */
//   begin
//   /*取状态*/
//   if exists (select groupno from master,rsvdtl where master.accnt=rsvdtl.accnt and rsvdtl.roomno=@rm_no and @s_time>=begin_ and @e_time <=end_  group by groupno having rtrim(groupno) is null)
//      begin
//      select @beg_sta='T'
//      end
//   else
//      begin
//      select @beg_sta='M'
//      select @beg_groupno= groupno from master,rsvdtl where master.accnt=rsvdtl.accnt and rsvdtl.roomno=@rm_no and @s_time>=begin_ and @e_time <=end_ group by groupno having rtrim(groupno) is not null order by groupno desc
//      end
//   /* 修正原状态*/
//   select @groupno=groupno from master where accnt=@accnt
//   if @beg_sta='M'
//      begin
//      if rtrim(@groupno) is null
//         select @beg_sta='T'
//      else if @groupno < @beg_groupno
//         select  @beg_groupno=@groupno
//      end
//   if exists (select groupno from master,rsvdtl where master.accnt=rsvdtl.accnt and rsvdtl.roomno=@rm_no and @s_time>=begin_ and @e_time <=end_ group by groupno having rtrim(groupno) is null)
//      begin
//      select @end_sta='T'
//      end
//   else
//      begin
//      select @end_sta='M'
//      select @end_groupno= groupno from master,rsvdtl where master.accnt=rsvdtl.accnt and rsvdtl.roomno=@rm_no and @s_time>=begin_ and @e_time <=end_ group by groupno having rtrim(groupno) is not null order by groupno desc
//      end
//   end
//
///*分别处理*/
//if @beg_sta='M' and @end_sta='T'
//   begin /* 成员房-->散客房:加了散客*/
//   /* 团体肯定要减,因该团事先预留数>=分配数,而现在分配数少一,预留数也减一    */
//   exec p_gds_reserve_group_filldtl @beg_groupno,@rm_type,'',@s_time,@e_time,-1
//   /* 散客预留一定要加 */
//   exec p_gds_reserve_filltype @rm_type,@s_time,@e_time,1,0,0
//   end
//else if @beg_sta='M' and @end_sta='M'
//   begin /* 成员房拼进成员(也可能走了或换走一个成员)*/
//   if @beg_groupno <> @end_groupno
//      begin
//      /* 前一团肯定要减,因该团事先预留数>=分配数,而现在分配数少一,预留数也减一 */
//      exec p_gds_reserve_group_filldtl @beg_groupno,@rm_type,'',@s_time,@e_time,-1
//      /* 后一团不一定要加,可能已经事先预留,所以先测试,不够再加 */
//      exec @ret=p_grp_getavail @end_groupno,@rm_type,@s_time,@e_time,'A',@pblkno out,@msg output
//      if @pblkno < 0
//         exec p_gds_reserve_group_filldtl @end_groupno,@rm_type,'',@s_time,@e_time,1
//      end
//   /* 走了大团,加了大团及同团拼房不用处理 */
//   end
//else if @beg_sta='T' and @end_sta='M'
//   begin /* 散客房-->成员房:走了散客剩下成员 */
//   /* 散客预留一定要减 */
//   exec p_gds_reserve_filltype @rm_type,@s_time,@e_time,-1,0,0
//   /* 团体预留不一定要加,可能已经事先预留,所以先测试,不够再加 */
//   exec @ret=p_grp_getavail @end_groupno,@rm_type,@s_time,@e_time,'A',@pblkno out,@msg output
//   if @pblkno < 0
//      exec p_gds_reserve_group_filldtl @end_groupno,@rm_type,'',@s_time,@e_time,1
//   end
///* 散客之间拼房不用处理 */

return 0;


/* -----------------------------------------------------------------------------------------------
	p_gds_reserve_fillroom
----------------------------------------------------------------------------------------------- */
if exists(select * from sysobjects where name = "p_gds_reserve_fillroom")
   drop proc p_gds_reserve_fillroom;
create proc p_gds_reserve_fillroom
   @rm_type        char(5),        -- 房类
   @rm_no          char(5),        -- 房号
   @s_time         datetime,       -- 开始时间
   @e_time         datetime,       -- 终止时间
   @ac_num         int,            -- 帐号数
   @accnt          char(10)         -- 帐号
as

declare
   @begin_t        datetime,       -- 当前游标开始时间
   @end_t          datetime,       -- 当前游表终止时间
   @m_time         datetime,       -- 动态插入段起始时间
   @n_time         datetime,       -- 动态插入段终止时间
   @groupno        char(10),        -- 团号
   @quant          int     ,       -- 帐号数量
   @exitmark       int     ,       -- 循环break退出标志
   @ret_val        int     ,       -- 子过程返回值
   @bugquan1       int     ,
   @bugquan2       int


select @groupno = groupno from master where accnt = @accnt

begin tran
save  tran p_gds_reserve_fillroom_s1
select  @m_time = @s_time,@n_time = @e_time,@exitmark=0
declare c_fillroom cursor for
		select quantity,begin_,end_  from rsvroom
		where (type=@rm_type and roomno=@rm_no and end_>@s_time and @e_time > begin_)
		order by type,roomno,begin_
open  c_fillroom
fetch c_fillroom into @quant,@begin_t,@end_t
while (@@sqlstatus=0)
   begin
   if @n_time <= @begin_t
      begin
	   insert rsvroom (type,roomno,begin_,end_,quantity) values  (@rm_type,@rm_no,@m_time,@n_time,@ac_num)
--      if rtrim(@groupno) is not null
--		   exec @ret_val = p_gds_reserve_filltype @rm_type,@m_time,@n_time,0,1,1
--	   else
		   exec @ret_val = p_gds_reserve_filltype @rm_type,@m_time,@n_time,1,1,1
	   if @ret_val > 0
	      goto doroll
	   select @exitmark = 1
      break
      end
   else if @m_time < @begin_t
      begin
      insert rsvroom (type,roomno,begin_,end_,quantity) values  (@rm_type,@rm_no,@m_time,@begin_t,@ac_num)
--	   if rtrim(@groupno) is not null
--		   exec @ret_val = p_gds_reserve_filltype @rm_type,@m_time,@begin_t,0,1,1
--	   else
		   exec @ret_val = p_gds_reserve_filltype @rm_type,@m_time,@begin_t,1,1,1
	   if @ret_val > 0
  	      goto doroll
      select @m_time = @begin_t
      continue
      end
   else if @m_time =@begin_t
      begin
      if @n_time = @end_t
         begin
         if @quant+@ac_num = 0
            begin
			   delete rsvroom where type=@rm_type and roomno=@rm_no and begin_ = @begin_t and end_=@end_t
--            if rtrim(@groupno) is not null
--			      exec @ret_val = p_gds_reserve_filltype @rm_type,@m_time,@n_time,0,-1,-1
--			   else
			      exec @ret_val = p_gds_reserve_filltype @rm_type,@m_time,@n_time,-1,-1,-1
			   if @ret_val > 0
		         goto doroll
			   end
         else
            begin
            update rsvroom set quantity = @quant+@ac_num where type=@rm_type and roomno=@rm_no and begin_ = @begin_t and end_=@end_t
            exec p_gds_reserve_dlshare @rm_type,@rm_no,@begin_t,@end_t,@accnt,@ac_num
            end
         select @exitmark =1
         break
         end
      else if @n_time < @end_t
         begin
		   if @quant+@ac_num = 0
            begin
			   delete rsvroom where type=@rm_type and roomno=@rm_no and begin_ = @begin_t and end_=@end_t
--            if rtrim(@groupno) is not null
--			      exec @ret_val = p_gds_reserve_filltype @rm_type,@m_time,@n_time,0,-1,-1
--			   else
			      exec @ret_val = p_gds_reserve_filltype @rm_type,@m_time,@n_time,-1,-1,-1
			   if @ret_val > 0
			      goto doroll
			   end
         else
            begin
            update rsvroom set end_ = @n_time,quantity=@quant+@ac_num where  type=@rm_type and roomno=@rm_no and begin_ = @begin_t and end_=@end_t
            exec p_gds_reserve_dlshare @rm_type,@rm_no,@begin_t,@n_time,@accnt,@ac_num
            end
         insert rsvroom (type,roomno,begin_,end_,quantity)  values  (@rm_type,@rm_no,@n_time,@end_t,@quant)
         select @exitmark = 1
         break
         end
      else
         begin
         if @quant+@ac_num = 0
            begin
			   delete rsvroom where type=@rm_type and roomno=@rm_no and begin_ = @begin_t and end_=@end_t
--            if rtrim(@groupno) is not null
--			      exec @ret_val = p_gds_reserve_filltype @rm_type,@m_time,@end_t,0,-1,-1
--			   else
			      exec @ret_val = p_gds_reserve_filltype @rm_type,@m_time,@end_t,-1,-1,-1
			   if @ret_val > 0
			      goto doroll
			   end
         else
            begin
            update rsvroom set quantity = @quant + @ac_num where type=@rm_type and roomno=@rm_no and begin_ = @begin_t and end_=@end_t
            exec p_gds_reserve_dlshare @rm_type,@rm_no,@begin_t,@end_t,@accnt,@ac_num
            end
         select @m_time = @end_t
         end
      end
   else if @m_time >= @end_t
      begin
      fetch c_fillroom into @quant,@begin_t,@end_t
      continue
      end
   else
      begin
	   update rsvroom set end_ = @m_time  where type=@rm_type and roomno=@rm_no and begin_ = @begin_t and end_=@end_t
	   select @begin_t = @m_time
	   if @end_t = @n_time
		   begin
		   if @quant+@ac_num <> 0
            begin
			   insert rsvroom (type,roomno,begin_,end_,quantity) values  (@rm_type,@rm_no,@m_time,@n_time,@quant+@ac_num)
            exec p_gds_reserve_dlshare @rm_type,@rm_no,@m_time,@n_time,@accnt,@ac_num
            end
		   select @exitmark = 1
         break
		   end
	   else if @end_t > @n_time
		   begin
		   insert rsvroom (type,roomno,begin_,end_,quantity) values  (@rm_type,@rm_no,@n_time,@end_t,@quant)
		   if @quant+@ac_num <> 0
            begin
			   insert rsvroom (type,roomno,begin_,end_,quantity) values  (@rm_type,@rm_no,@m_time,@n_time,@quant+@ac_num)
            exec p_gds_reserve_dlshare @rm_type,@rm_no,@m_time,@n_time,@accnt,@ac_num
            end
		   select @exitmark = 1
         break
		   end
	   else
		   begin
		   if @quant+@ac_num <> 0
            begin
			   insert rsvroom (type,roomno,begin_,end_,quantity) values  (@rm_type,@rm_no,@m_time,@end_t,@quant+@ac_num)
            exec p_gds_reserve_dlshare @rm_type,@rm_no,@m_time,@end_t,@accnt,@ac_num
            end
         select @m_time = @end_t
		   end
	   end
   fetch c_fillroom into @quant,@begin_t,@end_t
   end
if @@sqlstatus <> 0 and @exitmark <> 1
   begin
   insert rsvroom (type,roomno,begin_,end_,quantity) values  (@rm_type,@rm_no,@m_time,@n_time,@ac_num)
--   if rtrim(@groupno) is not null
--	   exec @ret_val = p_gds_reserve_filltype @rm_type,@m_time,@n_time,0,1,1
--   else
	   exec @ret_val = p_gds_reserve_filltype @rm_type,@m_time,@n_time,1,1,1
   if @ret_val > 0
      goto doroll
   end
close c_fillroom
deallocate cursor c_fillroom
commit tran
return 0
doroll:
close c_fillroom
deallocate cursor c_fillroom
rollback tran p_gds_reserve_fillroom_s1
commit tran
return 1
;



/* -----------------------------------------------------------------------------------------------
	p_gds_reserve_filldtl
----------------------------------------------------------------------------------------------- */
if exists(select * from sysobjects where name = "p_gds_reserve_filldtl")
   drop proc p_gds_reserve_filldtl;
create proc p_gds_reserve_filldtl
   @accnt         char(10),      -- 帐号
   @rm_type       char(5),      -- 房类
   @rm_no         char(5),      -- 房号
   @s_time        datetime,     -- 开始时间
   @e_time        datetime,     -- 终止时间
   @ac_num        int           -- 对于团体主单预留数 或者散客预留的房数 gds
as

-- insert gdsmsg select @rm_type+' '+@rm_no+' '+convert(char(14),@s_time,111)+' '+convert(char(14),@e_time,111)+' '+convert(char(2),@ac_num)

declare
   @begin_t   datetime,         -- 当前游标开始时间
   @end_t     datetime,         -- 当前游表终止时间
   @m_time    datetime,         -- 动态插入段起始时间
   @n_time    datetime,         -- 动态插入段终止时间
   @tmpac     int     ,
   @exitmark  int     ,
   @ret_val   int,
   @groupno   char(10)

if @s_time=@e_time 		-- 不占用资源；
	return 0

begin  tran
save   tran p_gds_reserve_filldtl_s1

if @rm_no<'0'
	select @rm_no = ''

update chktprm set code = 'A'
select @s_time = convert(datetime,convert(char(10),@s_time,111)),@e_time = convert(datetime,convert(char(10),@e_time,111))
if @e_time <= @s_time
	select @e_time = dateadd(day,1,@s_time)
select  @m_time = @s_time,@n_time = @e_time,@exitmark=0
declare c_filldtl cursor for
		select quantity,begin_,end_ from rsvdtl
		where (accnt = @accnt and type=@rm_type and roomno = @rm_no and end_>@s_time and @e_time > begin_)
        order by accnt,type,roomno,begin_
open c_filldtl
fetch c_filldtl into @tmpac,@begin_t,@end_t
while (@@sqlstatus=0)
   begin
   if @n_time <= @begin_t
      begin
      insert rsvdtl  (accnt,type,roomno,begin_,end_,quantity)
			 values  (@accnt,@rm_type,@rm_no,@m_time,@n_time,@ac_num)
      select @exitmark = 1
      break
      end
   else if @m_time < @begin_t
      begin
	  insert rsvdtl  (accnt,type,roomno,begin_,end_,quantity)
			 values  (@accnt,@rm_type,@rm_no,@m_time,@begin_t,@ac_num)
      select @m_time = @begin_t
      continue
      end
   else if @m_time =@begin_t
      begin
      if @n_time = @end_t
         begin
		 if @tmpac + @ac_num = 0
			delete rsvdtl where accnt  = @accnt and type = @rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
		 else
			update rsvdtl set quantity = @tmpac + @ac_num
                   where accnt  = @accnt and type = @rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
		 select @exitmark =1
         break
         end
      else if @n_time < @end_t
         begin
		 if @tmpac + @ac_num = 0
			delete rsvdtl where accnt  = @accnt and type = @rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
		 else
			update rsvdtl set end_ = @n_time,quantity = @tmpac + @ac_num
                   where accnt  = @accnt and type = @rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
         insert rsvdtl  (accnt,type,roomno,begin_,end_,quantity)
                values  (@accnt,@rm_type,@rm_no,@n_time,@end_t,@tmpac)
         select @exitmark = 1
         break
         end
	  else
         begin
		 if @tmpac + @ac_num = 0
			delete rsvdtl where accnt  = @accnt and type = @rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
         else
			update rsvdtl set quantity = @tmpac + @ac_num
				   where accnt  = @accnt and type = @rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
         select @m_time = @end_t
         end
      end
   else if @m_time >= @end_t
      begin
      fetch c_filldtl into @tmpac,@begin_t,@end_t
      continue
      end
   else
      begin
	   update rsvdtl set end_ = @m_time
			 where accnt = @accnt and type=@rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
	   select @begin_t = @m_time
	   if @end_t = @n_time
		 begin
		 if @tmpac + @ac_num <> 0
			insert rsvdtl (accnt,type,roomno,begin_,end_,quantity)
				   values  (@accnt,@rm_type,@rm_no,@m_time,@n_time,@tmpac + @ac_num)
		 select @exitmark = 1
         break
		 end
	  else if @end_t > @n_time
		 begin
		 insert rsvdtl (accnt,type,roomno,begin_,end_,quantity)
				values  (@accnt,@rm_type,@rm_no,@n_time,@end_t,@tmpac)
		 if @tmpac + @ac_num  <> 0
			insert rsvdtl (accnt,type,roomno,begin_,end_,quantity)
				   values  (@accnt,@rm_type,@rm_no,@m_time,@n_time,@tmpac + @ac_num)
		 select @exitmark = 1
         break
		 end
	  else
		 begin
		 if @tmpac + @ac_num  <> 0
			insert rsvdtl (accnt,type,roomno,begin_,end_,quantity)
				   values  (@accnt,@rm_type,@rm_no,@m_time,@end_t,@tmpac + @ac_num)
         select @m_time = @end_t
		 end
	  end
   fetch c_filldtl into @tmpac,@begin_t,@end_t
   end
if @@sqlstatus <> 0 and @exitmark <> 1
   insert rsvdtl  (accnt,type,roomno,begin_,end_,quantity)
		  values  (@accnt,@rm_type,@rm_no,@m_time,@n_time,@ac_num)
close c_filldtl
deallocate cursor c_filldtl

-- 没有房号的预留，插入 rsvtype
--		否则，插入 rsvroom
//if substring(@accnt,2,2) >='80' and substring(@accnt,2,2) < '95'   -- 团体
//   exec @ret_val = p_gds_reserve_filltype @rm_type,@s_time,@e_time,@ac_num,0,0
//else
//   begin
   if @rm_no <> space(5)  -- 客人，此时 @ac_num = 1
		exec @ret_val = p_gds_reserve_fillroom @rm_type,@rm_no, @s_time,@e_time,@ac_num,@accnt
   else
      begin
//      select @groupno = groupno from master where accnt = @accnt
//      if @groupno = ''
//			begin
			declare @itmp int
			select @itmp = sign(@ac_num)
		   exec @ret_val = p_gds_reserve_filltype @rm_type,@s_time,@e_time,@ac_num,@itmp,0
			-- 说明：散客订 n 间房表示, 预留 n, 分配 1， 排房 0 - gds
//			end
//      else  -- 团体 @ac_num = 1 分配账号
//		   exec @ret_val = p_gds_reserve_filltype @rm_type,@s_time,@e_time,0,@ac_num,0
      end
//   end

if @ret_val > 0
   rollback tran p_gds_reserve_filldtl_s1
commit tran

return @ret_val
;


/* -----------------------------------------------------------------------------------------------
	p_gds_reserve_group_filldtl
----------------------------------------------------------------------------------------------- */
if exists(select * from sysobjects where name = "p_gds_reserve_group_filldtl")
   drop proc p_gds_reserve_group_filldtl;
create proc p_gds_reserve_group_filldtl
   @accnt         char(10),      -- 帐号
   @rm_type       char(5),      -- 房类
   @rm_no         char(5),      -- 房号
   @s_time        datetime,     -- 开始时间
   @e_time        datetime,     -- 终止时间
   @ac_num        int           -- 预留数
as

declare
   @begin_t   datetime,         -- 当前游标开始时间
   @end_t     datetime,         -- 当前游表终止时间
   @m_time    datetime,         -- 动态插入段起始时间
   @n_time    datetime,         -- 动态插入段终止时间
   @tmpac     int     ,
   @exitmark  int     ,
   @ret_val   int

begin  tran
save   tran p_gds_reserve_group_filldtl_s1

update chktprm set code = 'A'
select @s_time = convert(datetime,convert(char(10),@s_time,111)),@e_time = convert(datetime,convert(char(10),@e_time,111))
if @e_time <= @s_time
   select @e_time = dateadd(day,1,@s_time)
select  @m_time = @s_time,@n_time = @e_time,@exitmark=0
declare c_filldtl cursor for
		select quantity,begin_,end_ from rsvdtl
		where (accnt = @accnt and type=@rm_type and roomno = @rm_no and end_>@s_time and @e_time > begin_)
        order by accnt,type,roomno,begin_
open c_filldtl
fetch c_filldtl into @tmpac,@begin_t,@end_t
while (@@sqlstatus=0)
   begin
   if @n_time <= @begin_t
      begin
      insert rsvdtl  (accnt,type,roomno,begin_,end_,quantity)
			 values  (@accnt,@rm_type,@rm_no,@m_time,@n_time,@ac_num)
      select @exitmark = 1
      break
      end
   else if @m_time < @begin_t
      begin
	  insert rsvdtl  (accnt,type,roomno,begin_,end_,quantity)
			 values  (@accnt,@rm_type,@rm_no,@m_time,@begin_t,@ac_num)
      select @m_time = @begin_t
      continue
      end
   else if @m_time =@begin_t
      begin
      if @n_time = @end_t
         begin
		 if @tmpac + @ac_num = 0
			delete rsvdtl where accnt  = @accnt and type = @rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
		 else
			update rsvdtl set quantity = @tmpac + @ac_num
                   where accnt  = @accnt and type = @rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
		 select @exitmark =1
         break
         end
      else if @n_time < @end_t
         begin
		 if @tmpac + @ac_num = 0
			delete rsvdtl where accnt  = @accnt and type = @rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
		 else
			update rsvdtl set end_ = @n_time,quantity = @tmpac + @ac_num
                   where accnt  = @accnt and type = @rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
         insert rsvdtl  (accnt,type,roomno,begin_,end_,quantity)
                values  (@accnt,@rm_type,@rm_no,@n_time,@end_t,@tmpac)
         select @exitmark = 1
         break
         end
	  else
         begin
		 if @tmpac + @ac_num = 0
			delete rsvdtl where accnt  = @accnt and type = @rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
         else
			update rsvdtl set quantity = @tmpac + @ac_num
				   where accnt  = @accnt and type = @rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
         select @m_time = @end_t
         end
      end
   else if @m_time >= @end_t
      begin
      fetch c_filldtl into @tmpac,@begin_t,@end_t
      continue
      end
   else
      begin
	   update rsvdtl set end_ = @m_time
			 where accnt = @accnt and type=@rm_type and roomno = @rm_no and begin_ = @begin_t and end_=@end_t
	   select @begin_t = @m_time
	   if @end_t = @n_time
		 begin
		 if @tmpac + @ac_num <> 0
			insert rsvdtl (accnt,type,roomno,begin_,end_,quantity)
				   values  (@accnt,@rm_type,@rm_no,@m_time,@n_time,@tmpac + @ac_num)
		 select @exitmark = 1
         break
		 end
	  else if @end_t > @n_time
		 begin
		 insert rsvdtl (accnt,type,roomno,begin_,end_,quantity)
				values  (@accnt,@rm_type,@rm_no,@n_time,@end_t,@tmpac)
		 if @tmpac + @ac_num  <> 0
			insert rsvdtl (accnt,type,roomno,begin_,end_,quantity)
				   values  (@accnt,@rm_type,@rm_no,@m_time,@n_time,@tmpac + @ac_num)
		 select @exitmark = 1
         break
		 end
	  else
		 begin
		 if @tmpac + @ac_num  <> 0
			insert rsvdtl (accnt,type,roomno,begin_,end_,quantity)
				   values  (@accnt,@rm_type,@rm_no,@m_time,@end_t,@tmpac + @ac_num)
         select @m_time = @end_t
		 end
	  end
   fetch c_filldtl into @tmpac,@begin_t,@end_t
   end
if @@sqlstatus <> 0 and @exitmark <> 1
   insert rsvdtl  (accnt,type,roomno,begin_,end_,quantity) values  (@accnt,@rm_type,@rm_no,@m_time,@n_time,@ac_num)
close c_filldtl
deallocate cursor c_filldtl
exec @ret_val = p_gds_reserve_filltype @rm_type,@s_time,@e_time,@ac_num,0,0
if @ret_val > 0
   rollback tran p_gds_reserve_group_filldtl_s1
commit tran
return @ret_val
;


if exists(select * from sysobjects where name = "p_gds_reserve_flrmsta" and type = 'P')
   drop proc p_gds_reserve_flrmsta;
create proc p_gds_reserve_flrmsta
	@rm_no		char(5),		-- 房号
	@accnt		char(10),	-- 帐号
	@mode		   char(5),		-- 模式: 'ADD'表示增加,  'DELE'表示删除 ,'LOG' 仅记日志
	@empno      char(10)
as
-----------------------------------------------------------------------------------------------
--	p_gds_reserve_flrmsta:	住客信息在 rmsta 中的反应；
--									未来房态的修改；
--									结账后，客房状态自动转为 --- D ?  或许需要参数灵活处理
--
--		mode = DELE or DELE! -- 房态相关
--
--		PM 房类，不用变脏房 
-----------------------------------------------------------------------------------------------

declare		@number		int,
				@accntpos	int,
         	@s_time		datetime,
				@accntset	varchar(70),
				@type			char(5),
				@sta			char(1)

select @s_time = getdate()

begin tran
save  tran p_gds_reserve_flrmsta_s1

update rmsta set sta = sta where roomno = @rm_no
select @number = isnull(number,0), @accntset=accntset, @type=type, @sta=sta from rmsta where roomno = @rm_no
if	@@rowcount = 0
	begin
   commit tran
	return 1
	end

if	@mode = 'ADD'
begin
	if charindex(@accnt, @accntset) = 0 
		update rmsta set logmark=logmark+1,accntset = rtrim(accntset)+@accnt+'#',number = isnull(number,0)+1,ocsta = 'O',empno=@empno,changed = getdate() where roomno = @rm_no
end
else if  @mode = 'LOG'
	update rmsta set logmark=logmark+1,empno=@empno,changed = getdate() where roomno = @rm_no
else if @number > 0  -- DELE
	begin
	select @accntpos = charindex(@accnt,rtrim(accntset)) from rmsta where roomno = @rm_no
	if @accntpos > 0
	   begin
	   update rmsta set accntset = stuff(accntset,@accntpos,11,null),number = isnull(number,1) - 1 where roomno = @rm_no

		-- 修改房态：正常情况下，变脏。share处理/PM 房 - 不变 
		if @type = 'PM' 
			select @sta='R'
		else if substring(@mode,5,1) <> '!'
			select @sta='D'

		update rmsta set ocsta = 'V',sta = @sta, empno=@empno,changed = getdate() where roomno = @rm_no and number = 0

		-- 未来房态的设定
      update rmsta set sta = futsta
             where roomno = @rm_no and ocsta = 'V' and locked='L' 
                   and futbegin <= @s_time and (futend > @s_time or futend is null)
	   update rmsta set logmark=logmark+1 where roomno = @rm_no
	   end
	else
	   begin
      commit tran
	   return 2
	   end
	end

commit tran 

return 0
;
