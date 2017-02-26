
// ------------------------------------------------------------------------------------
//
// 换房操作 
//
//		换房之后,房价就会随新的形势变化 ! 
//
// ------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_change_roomno")
   drop proc p_gds_change_roomno;

create proc  p_gds_change_roomno
   @accnt    char(10),
   @roomno   char(5),
   @request  char(1), 
   @empno    char(10),
   @nullwithreturn varchar(60) output

as

declare
   @ret      		int,
   @msg      		varchar(60),
   @groupno  		char(10),
   @empname  		char(20),
	@sta				char(1),
   @nrequest 		char(9)

declare 
	@type_old		char(5),
	@roomno_old		char(5),
	@rtype_old		char(1),
	@rvalue_old		money,
	@rmmode_old		char(3),
	@type 			char(5),
	@rtype			char(1),
	@rvalue			money,
	@rmmode			char(3)

declare
	@typerate		money,
	@qtrate			money,
	@setrate			money,
	@discount		money,
	@discount1		money,
	@tag				char(3)

select @ret = 0,@msg =  "",@nrequest=@request+space(7)+'D'
//select @empname = name from auth_login where empno = @empno
//
//select @sta = sta, @type_old=type, @roomno_old=roomno, @groupno=groupno,
//		@qtrate=qtrate, @setrate=setrate, @discount=discount, @discount1=discount1
//	 from master where accnt = @accnt
//if @@rowcount = 0
//	select @ret = 1,@msg = "帐号不存在 !"
//else if charindex(@sta, 'RICG') = 0 
//	select @ret = 1,@msg = "只有有效预定或在住状态才能操作 !"
//else if @roomno = @roomno_old
//	select @ret = 1,@msg = "房号没有改变 !"
//else
//	begin
//   exec p_hry_accnt_class @accnt,@tag output
//	select @type = type from rmsta where roomno = @roomno			// new type
//	end
//
//// 取得原来的房价情况
//if @ret = 0 
//	exec @ret = p_gds_get_accnt_rmrate @accnt, @rtype_old output, @rvalue_old output, @rmmode_old output, @msg output
//
//begin  tran
//save   tran p_gds_change_roomno_s1
//
//if @ret = 0
//	begin
//	update master set type=@type, roomno = @roomno where accnt = @accnt   // 换房
//	if @@rowcount = 0
//		select @ret = 1,@msg = "数据更新失败!"
//	end
//
//if @ret = 0		
//   exec @ret = p_hry_reserve_chktprm @accnt,@nrequest,'',@empno,'',0,0,@msg out
//
//// 调整房价
//if @ret = 0
//	begin
//	// 新的情况 
//	exec @ret = p_gds_get_accnt_rmrate @accnt, @rtype output, @rvalue output, @rmmode output, @msg output
//	if @ret = 0 
//		begin
//		if @type = @type_old 		// 房类相同，房价不修改
//			update master set setrate=setrate where accnt = @accnt  // 不变
//		else								// 房类不相同，房价修改
//			begin
//			// 取得原价
//			if rtrim(@groupno) is not null  // 团体成员
//				select @typerate = rate from grprate where accnt=@groupno and type=@type
//			else									// 散客
//				select @typerate = rate from rmsta where roomno=@roomno
//			
//			if rtrim(@groupno) is not null  // 团体成员
//				select @qtrate=@typerate, @setrate=@rvalue, @discount1=0, @discount=0
//
//			else if (@rtype = 'T' and @rvalue=1.0) or (@rtype='F' and @rvalue=@typerate) // 原价
//				select @qtrate=@typerate, @setrate=@typerate, @discount1=0, @discount=0
//
//			else if @rtype = 'T'  // 折扣模式
//				select @qtrate=@typerate, @setrate=@typerate, @discount1=@rvalue, @discount=0
//
//			else					// 实价模式
//				select @qtrate=@typerate, @setrate=@rvalue, @discount1=0, @discount=@typerate-@rvalue
//
//			update master set qtrate=@qtrate,setrate=@setrate,discount=@discount,discount1=@discount1 where accnt=@accnt
//			end
//
//		if @@rowcount = 0
//			select @ret=1, @msg='更新房价失败 !'
//		else
//			begin
//	      update master set logmark=logmark+1,cby=@empno,cbyname=@empname,changed = getdate() where accnt = @accnt
//		   update guest  set logmark=logmark+1,cby=@empno,cbyname=@empname,changed = getdate() where accnt = @accnt
//			end
//		end
//	end
//
//if @ret <> 0
//   rollback tran p_gds_change_roomno_s1
//commit tran

select @ret = 1, @msg = '此功能暂时不开放'

if @nullwithreturn is null 
   select @ret,@msg
else
   select @nullwithreturn = @msg

return @ret
;
