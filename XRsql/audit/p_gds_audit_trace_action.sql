
// 0204 取消了 trace 的房价码功能 

IF OBJECT_ID('p_gds_audit_trace_action') IS NOT NULL
	drop proc p_gds_audit_trace_action;
//create proc p_gds_audit_trace_action
//	@empno 		varchar(10),
//	@ret			integer			out,
//	@msg			varchar(70)		out
//as
//-- ----------------------------------------------------------------------------
//--		Trace Action 目前只支持房价码
//--			----- 放在夜审中处理
//--			
//--			注意变价参数 sysoption(reserve, rmrate_autochg_mode, ?)   
//--									1=严格按照协议价格 2=差价 3=比率 
//-- ----------------------------------------------------------------------------
//
//-- 提取计算模式 - 1=严格按照协议价格 2=差价 3=比率 
//declare		@mode				char(1)
//select @mode = isnull((select substring(value,1,1) from sysoption where catalog = 'reserve' and item = 'rmrate_autochg_mode'), '0')
//if charindex(@mode, '123') = 0 
//	return 0
//
//-- 
//declare		@duringaudit	char(1),
//				@bdate			datetime,
//				@bfdate			datetime,
//				@accnt			char(10),
//				@rmrate0			money,	-- 上日协议价格
//				@rmrate1			money,	-- 本日协议价格
//				@setrate0		money,
//				@setrate1		money,
//				@id				int,
//				@ratecode		char(10)
//
//				
//select @ret=0, @msg=''
//
//--夜审时取夜审后的营业日期和夜审前的日期
//select @duringaudit= audit from gate
//if @duringaudit = 'T'
//   select @bfdate = bdate from sysdata
//else
//	select @bfdate = bdate from accthead
//select @bdate = dateadd(day,1,@bfdate)
//                   
//-- 重新计算协议价格, 同时删除协议价格没有变化的
//declare c_action cursor for select id,accnt,substring(extdata,1,10) FROM message_trace 
//	where sort='AFF' and tag='1' and datediff(dd, inure, @bdate)=0 and action='RC'
//open c_action
//fetch c_action into @id, @accnt, @ratecode
//while @@sqlstatus=0
//begin
//	select @ratecode = isnull(rtrim(@ratecode), '')
//	if exists(select 1 from master where accnt=@accnt and ratecode=@ratecode) 
//		or not exists(select 1 from master where accnt=@accnt and sta='I' and class='F')
//		or not exists(select 1 from rmratecode where code=@ratecode)
//	begin
//		fetch c_action into @id, @accnt, @ratecode
//		continue 
//	end
//
//	select @rmrate0=rmrate, @setrate0=setrate from master where accnt=@accnt 
//	if @mode = '1' and @rmrate0=@setrate0 				-- 1=严格按照协议价格
//	begin
//		fetch c_action into @id, @accnt, @ratecode
//		continue 
//	end
//
//	begin tran 
//	save tran s_action 
//
//	update master set ratecode=@ratecode where accnt=@accnt 
//	-- 本日协议价
//	exec @ret = p_gds_get_accnt_rmrate @accnt,@rmrate1 output,@msg output, @bdate
//	if @ret <> 0
//		rollback tran s_action
//	else
//	begin
//		-- 根据选项计算价格 
//		if @mode = '1'				-- 1=严格按照协议价格
//		begin
//			select @setrate1 = @rmrate1
//		end
//		else if @mode = '2'		-- 2=差价
//		begin
//			select @setrate1 = @setrate0 - @rmrate0 + @rmrate1
//		end
//		else							-- 3=比率 
//		begin
//			if @rmrate0 <>0 
//				select @setrate1 = round(@rmrate1 * @setrate0 / @rmrate0, 2)
//			else
//				select @setrate1 = @rmrate1
//		end
//		update master set rmrate=@rmrate1, setrate=@setrate1, cby=@empno, changed=getdate(), logmark=logmark+1 where accnt=@accnt 
//		update message_trace set tag='2', resolver=@empno, resolvedate=getdate() where id=@id 
//	end
//	commit tran 
//
//	fetch c_action into @id, @accnt, @ratecode
//end
//close c_action
//deallocate cursor c_action
//
//
//return @ret;
//