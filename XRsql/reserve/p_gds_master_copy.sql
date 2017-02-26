----------------------------------------------------------------------------------------------
--		宾客主单拷贝  -- 产生主单，客房预留  -- 暂时通过客户端实现
----------------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_master_copy")
	drop proc p_gds_master_copy;
//create proc p_gds_master_copy
//	@sta			char(1),   -- R, I
//	@empno		char(10),
//	@accnt		char(10),
//	@type			char(3),
//	@roomno		char(5),
//	@blkmark		char(1),
//	@begin		datetime,
//	@end			datetime,
//	@quan			int,
//	@gstno		int,
//	@rate			money,
//	@remark		varchar(50),
//	@retmode		char(1),			-- S, R
//	@ret        int	output,
//   @msg        varchar(60) output
//as
//declare		@maccnt		char(10),
//				@class		char(1),
//				@date			datetime,
//				@host_id		int
//
//select @ret=0, @msg='',@host_id = convert(int, host_id()), @date=null
//
//begin tran
//save 	tran master_copy
//
//if @class='F' 
//	exec p_GetAccnt1 'FIT', @maccnt output
//else if @class='G' or @class='M' 
//	exec p_GetAccnt1 'GRP', @maccnt output
//else if @class='H'
//	exec p_GetAccnt1 'HTL', @maccnt output
//else if @class='A'
//	exec p_GetAccnt1 'AR', @maccnt output
//else
//begin
//	select @ret=1, @msg='Accnt Class Error'
//	goto gout
//end
//
//delete master_host where host_id = @host_id
//insert master_host select @, * from master where accnt=@accnt
//if @@rowcount = 0
//begin
//	select @ret=1, @msg='Insert Error'
//	goto gout
//end
//
////update master_host set accnt=@maccnt, sta=@sta where host_id=@host_id  -- less empno info
////
////if @class='F' 
////begin
////	@type			char(3),
////	@roomno		char(5),
////	@blkmark		char(1),
////	@begin		datetime,
////	@end			datetime,
////	@quan			int,
////	@gstno		int,
////	@rate			money,
////	@remark		varchar(50),
////	update master_host set type=@type, otype='', roomno=@roomno,oroomno='',
////		arr=@begin, oarr=@date, dep=@end, odep=@date, rmnum=@quan, ormnum=0
////		where host_id=@host_id
////end
////insert master select * from master_host where host_id=@host_id
////exec @ret = p_gds_reserve_chktprm @maccnt,'0','',@empno,'',1,1,@msg output
////
//gout:
//if @ret <> 0
//	rollback tran master_copy
//commit tran 
//
//if @retmode='S'
//	select @ret, @msg
//return @ret
//;
//
//