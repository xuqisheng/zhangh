/* 

删除一个团体 (必须先要把该团体取消) 

---> 已经删除，不再使用
*/

if exists(select * from sysobjects where name = "p_gds_delete_group")
   drop proc p_gds_delete_group
;
//create  proc p_gds_delete_group
//   @grpaccnt char(10),
//   @empno    char(10)
//as
//
//declare
//	@ret     		int,
//	@msg     		varchar(60),
//	@sta     		char(1),
//	@accnt   		char(10),
//	@lastinumb 		int 
//
//select @ret=0, @msg =""
//
//begin tran
//save  tran p_gds_delete_group_s1
//
//update master set sta = sta where accnt = @grpaccnt
//select @sta = sta,@lastinumb = lastinumb from master where accnt = @grpaccnt and class in ('G', 'M')
//if @@rowcount = 0
//   select @ret = 1,@msg = "团体主单"+@grpaccnt+"不存在"
//else if @lastinumb > 0
//   select @ret = 1,@msg = "团体主单"+@grpaccnt+"已有帐务发生,不能删除"
//else if charindex(@sta,'I') > 0
//   select @ret = 1,@msg = "团体主单"+@grpaccnt+"已经登记,不能删除"
//else if charindex(@sta,'XNL') = 0
//   select @ret = 1,@msg = "团体主单["+@grpaccnt+"]不是取消预订状态,请先取消本团体"
//if @ret = 1
//	goto gout
//
//-- begin : delete mem master
//declare c_delete_group_mem cursor for
//		select accnt from master where groupno = @grpaccnt
//		order by groupno,accnt
//open  c_delete_group_mem
//fetch c_delete_group_mem into @accnt
//while @@sqlstatus = 0
//begin
//	select @sta = sta,@lastinumb = lastinumb from master holdlock where accnt = @accnt
//	if @lastinumb > 0
//	begin
//		select @ret = 1,@msg = "团体成员["+@accnt+"]已有帐务发生,不能删除团体"+@grpaccnt
//		goto gout
//	end
//	else
//		delete master where accnt = @accnt
//
//	fetch c_delete_group_mem into @accnt
//end
//close  c_delete_group_mem
//deallocate cursor c_delete_group_mem
//
//-- delete group master
//delete master where accnt = @grpaccnt
//
//-- End ...
//gout:
//if @ret <> 0
//	rollback tran p_gds_delete_group_s1
//commit tran
//
//select @ret,@msg
//return @ret
//;
//