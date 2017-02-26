
if exists(select * from sysobjects where name = "p_gds_single_update")
   drop proc p_gds_single_update;
create proc  p_gds_single_update
   @accnt    char(10),      /* 散客或成员帐号 */
   @srcstas  varchar(20),  /* 原状态 */
   @newsta   char(1),      /* 新状态 */
   @empno    char(10)       /* 操作员 */
as
declare
   @ret      int,
   @msg      varchar(60),
   @mststa   char(1),
   @arr      datetime,
   @roomno   char(5),   
   @groupno  char(10),
   @sta      char(1),
   @nrequest char(1),         /* 散客=0  成员=4 gds */
	@rmnum		int

begin tran
save  tran p_gds_single_update_s1

select @nrequest = '0'
select @ret = 0,@msg=''

select @groupno = groupno from master where accnt = @accnt
if @groupno <> '' and @groupno is not null 
   begin
   select @nrequest='4'
   update master set sta = sta where accnt = @groupno
   select @sta = sta from master where accnt = @groupno and class in ('G', 'M')
   if @@rowcount = 0
	  select @ret = 1,@msg = "当前客人所在团体%1不存在^"+@groupno
   end
if @ret = 0
   begin
   update master set sta = sta where accnt = @accnt
   select @mststa = sta,@arr = convert(datetime,convert(char(10),arr,111)),@roomno = roomno, @rmnum=rmnum from master where accnt = @accnt
   if @mststa is null
	  select @ret = 1,@msg = "主单%1不存在^"+@accnt
   end 

if @ret = 0 and @newsta = 'X' and charindex('R',@srcstas) > 0
   /* 取消预订 */
   begin
   if charindex(@mststa,'I') > 0
	  select @ret = 1,@msg = "主单%1已经登记,不能取消^"+@accnt
   else if charindex(@mststa,'XNL') > 0
	  select @ret = 1,@msg = "主单%1已经是取消预订状态,不需取消^"+@accnt
   else if charindex(@mststa,'RCG') = 0
	  select @ret = 1,@msg = "主单%1并非有效预订状态,不能取消^"+@accnt
   end
else if @ret = 0 and @newsta = 'R' and charindex('X',@srcstas) > 0
   /* 恢复预订 */
   begin
   if charindex(@mststa,'I') > 0
      select @ret = 1,@msg = "主单%1已经登记,不需恢复^"+@accnt
   else if charindex(@mststa,'RCG') > 0
      select @ret = 1,@msg = "主单%1已经是有效预订状态,不需恢复^"+@accnt
   else if charindex(@mststa,'XNL') = 0
	  select @ret = 1,@msg = "主单%1并非取消预订状态,不能恢复^"+@accnt
   else if @arr < convert(datetime,convert(char(10),getdate(),111))
	  select @ret = 1,@msg = "主单%1的到日不能早于今天"+@accnt
   end
else if @ret = 0 and @newsta = 'I' and charindex('R',@srcstas) > 0
   /* 预订转入住 */
   begin
   if charindex(@mststa,'I') > 0
      select @ret = 1,@msg = "主单%1已经登记^"+@accnt
   else if charindex(@mststa,'RCG') = 0
	  select @ret = 1,@msg = "主单%1不是有效预订状态,不能转登记^"+@accnt
   else if @arr > convert(datetime,convert(char(10),getdate(),111))
	  select @ret = 1,@msg = "未到主单%1的到达日期,请先修改到日^"+@accnt
//   else if @arr < convert(datetime,convert(char(10),getdate(),111))
//	  select @ret = 1,@msg = "主单%1的到日不能早于今天^"+@accnt
	else if @rmnum <> 1 
      select @ret = 1,@msg = "主单房数不等于 1" // gds
   else if @roomno = space(5)
      select @ret = 1,@msg = "主单%1还没分配房号^"+@accnt
   end
else
   select @ret = 1,@msg = "目前暂不开放本功能"
if @ret = 0
   begin
   update master set sta = @newsta where accnt = @accnt

//   if @newsta = 'I' and @mststa <> 'I'
//	  update master set arr = getdate() where accnt = @accnt

   exec @ret = p_gds_reserve_chktprm @accnt,@nrequest,'',@empno,'',0,0,@msg out
   update master set logmark=logmark+1,cby=@empno,changed = getdate() where accnt = @accnt
   end

if @ret <> 0
   rollback tran p_gds_single_update_s1
commit tran
select @ret,@msg
return @ret;
