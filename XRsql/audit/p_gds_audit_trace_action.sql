
// 0204 ȡ���� trace �ķ����빦�� 

IF OBJECT_ID('p_gds_audit_trace_action') IS NOT NULL
	drop proc p_gds_audit_trace_action;
//create proc p_gds_audit_trace_action
//	@empno 		varchar(10),
//	@ret			integer			out,
//	@msg			varchar(70)		out
//as
//-- ----------------------------------------------------------------------------
//--		Trace Action Ŀǰֻ֧�ַ�����
//--			----- ����ҹ���д���
//--			
//--			ע���۲��� sysoption(reserve, rmrate_autochg_mode, ?)   
//--									1=�ϸ���Э��۸� 2=��� 3=���� 
//-- ----------------------------------------------------------------------------
//
//-- ��ȡ����ģʽ - 1=�ϸ���Э��۸� 2=��� 3=���� 
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
//				@rmrate0			money,	-- ����Э��۸�
//				@rmrate1			money,	-- ����Э��۸�
//				@setrate0		money,
//				@setrate1		money,
//				@id				int,
//				@ratecode		char(10)
//
//				
//select @ret=0, @msg=''
//
//--ҹ��ʱȡҹ����Ӫҵ���ں�ҹ��ǰ������
//select @duringaudit= audit from gate
//if @duringaudit = 'T'
//   select @bfdate = bdate from sysdata
//else
//	select @bfdate = bdate from accthead
//select @bdate = dateadd(day,1,@bfdate)
//                   
//-- ���¼���Э��۸�, ͬʱɾ��Э��۸�û�б仯��
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
//	if @mode = '1' and @rmrate0=@setrate0 				-- 1=�ϸ���Э��۸�
//	begin
//		fetch c_action into @id, @accnt, @ratecode
//		continue 
//	end
//
//	begin tran 
//	save tran s_action 
//
//	update master set ratecode=@ratecode where accnt=@accnt 
//	-- ����Э���
//	exec @ret = p_gds_get_accnt_rmrate @accnt,@rmrate1 output,@msg output, @bdate
//	if @ret <> 0
//		rollback tran s_action
//	else
//	begin
//		-- ����ѡ�����۸� 
//		if @mode = '1'				-- 1=�ϸ���Э��۸�
//		begin
//			select @setrate1 = @rmrate1
//		end
//		else if @mode = '2'		-- 2=���
//		begin
//			select @setrate1 = @setrate0 - @rmrate0 + @rmrate1
//		end
//		else							-- 3=���� 
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