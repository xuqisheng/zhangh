
// ------------------------------------------------------------------------------------
//
// �������� 
//
//		����֮��,���۾ͻ����µ����Ʊ仯 ! 
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
//	select @ret = 1,@msg = "�ʺŲ����� !"
//else if charindex(@sta, 'RICG') = 0 
//	select @ret = 1,@msg = "ֻ����ЧԤ������ס״̬���ܲ��� !"
//else if @roomno = @roomno_old
//	select @ret = 1,@msg = "����û�иı� !"
//else
//	begin
//   exec p_hry_accnt_class @accnt,@tag output
//	select @type = type from rmsta where roomno = @roomno			// new type
//	end
//
//// ȡ��ԭ���ķ������
//if @ret = 0 
//	exec @ret = p_gds_get_accnt_rmrate @accnt, @rtype_old output, @rvalue_old output, @rmmode_old output, @msg output
//
//begin  tran
//save   tran p_gds_change_roomno_s1
//
//if @ret = 0
//	begin
//	update master set type=@type, roomno = @roomno where accnt = @accnt   // ����
//	if @@rowcount = 0
//		select @ret = 1,@msg = "���ݸ���ʧ��!"
//	end
//
//if @ret = 0		
//   exec @ret = p_hry_reserve_chktprm @accnt,@nrequest,'',@empno,'',0,0,@msg out
//
//// ��������
//if @ret = 0
//	begin
//	// �µ���� 
//	exec @ret = p_gds_get_accnt_rmrate @accnt, @rtype output, @rvalue output, @rmmode output, @msg output
//	if @ret = 0 
//		begin
//		if @type = @type_old 		// ������ͬ�����۲��޸�
//			update master set setrate=setrate where accnt = @accnt  // ����
//		else								// ���಻��ͬ�������޸�
//			begin
//			// ȡ��ԭ��
//			if rtrim(@groupno) is not null  // �����Ա
//				select @typerate = rate from grprate where accnt=@groupno and type=@type
//			else									// ɢ��
//				select @typerate = rate from rmsta where roomno=@roomno
//			
//			if rtrim(@groupno) is not null  // �����Ա
//				select @qtrate=@typerate, @setrate=@rvalue, @discount1=0, @discount=0
//
//			else if (@rtype = 'T' and @rvalue=1.0) or (@rtype='F' and @rvalue=@typerate) // ԭ��
//				select @qtrate=@typerate, @setrate=@typerate, @discount1=0, @discount=0
//
//			else if @rtype = 'T'  // �ۿ�ģʽ
//				select @qtrate=@typerate, @setrate=@typerate, @discount1=@rvalue, @discount=0
//
//			else					// ʵ��ģʽ
//				select @qtrate=@typerate, @setrate=@rvalue, @discount1=0, @discount=@typerate-@rvalue
//
//			update master set qtrate=@qtrate,setrate=@setrate,discount=@discount,discount1=@discount1 where accnt=@accnt
//			end
//
//		if @@rowcount = 0
//			select @ret=1, @msg='���·���ʧ�� !'
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

select @ret = 1, @msg = '�˹�����ʱ������'

if @nullwithreturn is null 
   select @ret,@msg
else
   select @nullwithreturn = @msg

return @ret
;
