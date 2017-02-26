
--------------------------------------------------------------------
--	vipcard delete.
--
--------------------------------------------------------------------

IF OBJECT_ID('p_gds_vipcard_delete') IS NOT NULL
    DROP PROCEDURE p_gds_vipcard_delete
;
create proc p_gds_vipcard_delete
   @no  		char(20),
   @empno  	char(10)
as
declare
   @sta       	char(1),
   @lastinumb 	int,
   @ret       	int,
   @msg       	varchar(60),
	@bal			money,
	@bdate		datetime,
	@class		char(1)

select @ret = 1,  @msg = "目前系统禁止删除贵宾卡"

//begin tran
//save  tran p_gds_vipcard_delete_s1
//
//select @bdate = bdate1 from sysdata
//select @ret = 0,@msg = ""
//update master set sta = sta where accnt = @accnt
//
//-- delete cond ...
//select @cond_act=substring(value,1,1) from sysoption where catalog='reserve' and item='master_del_cond_act'
//if @cond_act is null select @cond_act='1'  -- 删除条件的严格性。1=最安全
//select @cond_hour=convert(int, value) from sysoption where catalog='reserve' and item='master_del_cond_hour'
//if @cond_hour is null select @cond_hour=2  -- 入住时间不能超过？小时
//
//select @class=class, @sta = sta, @bal = charge-credit , @lastinumb = lastinumb from master where accnt = @accnt
//if @@rowcount = 0
//   select @ret=1,@msg = "不存在帐号 - %1 - 对应的主单"+@accnt
//if @ret=0 and @lastinumb>0 and @cond_act = '1'
//   select @ret=1,@msg = "该账户已经发生帐务, 不能删除"
//if @ret = 0 and @bal<>0
//   select @ret=1,@msg = "该账户余额<>0, 请用 预订取消/结帐 功能处理"
//if @ret = 0 and charindex(@sta,'RCGI') = 0
//   select @ret=1,@msg = "只有确认错误的预订和入住才能删除"
//if @ret = 0 and exists(select 1 from master_till where accnt=@accnt)
//   select @ret=1,@msg = "该帐户已经经过夜审处理,不能删除"
//if @ret = 0 and exists(select 1 from account where accnt=@accnt and billno not like 'C%')
//   select @ret=1,@msg = "存在非冲销帐务，不能删除"
//if @ret=0 and @class in ('F', 'M', 'G')
//	begin
//	select @hour = datediff(hh, arr, getdate()) from  master where accnt = @accnt and sta='I'
//	if @hour >= @cond_hour
//	   select @ret=1,@msg = "宾客入住时间过长, 不能删除"
//	end
//if @ret=0 and @class in ('M', 'G') and exists(select 1 from master where groupno=@accnt)
//   select @ret=1,@msg = "请先处理成员"
//
//-- 散客：释放客房资源
//if @ret = 0 and @class='F'
//begin
//	select @groupno = groupno from master where accnt = @accnt
//	if @groupno<>''
//		update master set sta = sta where accnt = @groupno  -- LOCK 
//	update master set sta = sta where accnt = @accnt
//	if @sta = 'I'
//		update master set sta ='O',dep=getdate() where  accnt = @accnt
//	else
//		update master set sta ='X' where  accnt = @accnt
//	exec @ret = p_gds_reserve_chktprm @accnt,'2','',@empno,'',1,1,@msg output
//	if @ret = 0
//	begin
//		update master set logmark=logmark+1,cby = @empno,changed = getdate() where  accnt = @accnt
//		if @groupno<>''
//			exec @ret = p_gds_maintain_group  @groupno,@empno,1,@msg output
//	end
//end
//
//-- 团体：释放客房资源
//if @ret=0 and @class in ('M', 'G')
//	exec p_gds_reserve_release_block @accnt
//
//-- delete record 
//if @ret = 0
//begin
//	-- Turnaway 
//	if @class in ('F', 'M', 'G') and @turnaway <> ''
//	begin
//		declare	@tid		int, @sid		char(10)
//		exec p_GetAccnt1 'TUN', @sid output
//		select @tid = convert(int, @sid)
//
//		insert turnaway (id,sta,arr,days,type,rmnum,gstno,market,phone,reason,
//				remark,haccnt,name,accnt,crtby,crttime,cby,changed) 
//			select @tid,'T',a.arr,datediff(dd,a.arr,a.dep),a.type,a.rmnum,a.gstno,a.market,isnull(a.phone,''),@turnaway,
//				'Front Office Delete .',a.haccnt,b.haccnt,a.accnt,a.resby,isnull(a.restime,getdate()),a.cby,a.changed 
//				from master a, master_des b where a.accnt=b.accnt and a.accnt=@accnt
//	end
//	insert master_del select * from master where accnt=@accnt
//   delete master where accnt = @accnt
//   delete account where accnt = @accnt
//   delete subaccnt where accnt = @accnt
//end
//else
//   rollback tran p_gds_vipcard_delete_s1
//commit tran

select @ret, @msg

return @ret
;

