
// ������Ҫ������ �޸ķ��ţ����̣��ش�ͬʱ�������Ϳ�����

if exists(select 1 from sysobjects where name = "p_gds_master_break")
	drop proc p_gds_master_break;
//create proc p_gds_master_break
//	@accnt		char(10),		-- Ŀ���˺�
//	@add			char(10),		-- �����˺�
//	@empno		char(10),
//	@retmode		char(1),			-- S, R
//	@ret        int			output,
//   @msg        varchar(60) output
//as
//----------------------------------------------------------------------------------------------
//--		ȡ��ͬס -- ��Ҫ���û�з��ŵ����
//--			�з��ŵ�ʱ��ֱ�ӵ�����������������ע�⵽���۵ı��
//----------------------------------------------------------------------------------------------
//declare		@type			char(3),			@type1		char(3),
//				@roomno		char(5),			@roomno1		char(5),
//				@arr			datetime,		@arr1			datetime,
//				@dep			datetime, 		@dep1			datetime, 
//				@master		char(10),		@master1		char(10),
//				@saccnt		char(10),		@saccnt1		char(10),
//				@sta			char(1),			@sta1			char(1),
//				@rmnum		int,
//				@mroomno		char(5),
//				@class		char(1),
//				@today		datetime,
//				@bdate		datetime,
//				@qtrate		money,
//				@rmrate		money   -- ��������Ҫ���� ?
//
//select @ret=0, @msg='', @today = getdate()
//select @bdate = bdate1 from sysdata
//
//-- ����Ŀ���˺�
//select @type=type,@roomno=roomno, @class=class, @sta=sta, @rmnum=rmnum, @arr=arr, @dep=dep, @master=master, @saccnt=saccnt,
//	@qtrate=qtrate,@rmrate=rmrate from master where accnt=@accnt
//if @@rowcount = 0
//	select @ret=1, @msg = '��������������'
//if @ret=0 and @class<>'F'
//	select @ret=1, @msg = '��ɢ��/��Ա���������ܽ��иò���'
//if @ret=0 and charindex(@sta, 'RI')=0
//	select @ret=1, @msg = '������������Ч״̬'
//if @ret=0 and not exists(select 1 from rsvsrc where accnt=@accnt and id=0)
//	select @ret=1, @msg = '����ЧԤ����¼'
//if @ret = 0 and @rmnum>1 
//	select @ret=1, @msg = '���ͷ��������ܽ��иò���'
//if @ret=0 and datediff(dd, @dep, getdate())>0
//	select @ret=1, @msg = '�����޸ĵ�ǰ����������'
//if @ret<>0 
//begin
//	if @retmode='S'
//		select @ret, @msg
//	return @ret
//end
//
//-- ���� share �˺�
//select @type1=type,@roomno1=roomno, @class=class, @sta1=sta, @rmnum=rmnum, @arr1=arr, @dep1=dep, @master1=master, @saccnt1=saccnt
//	from master where accnt=@add
//if @@rowcount = 0
//	select @ret=1, @msg = 'share ��������������'
//if @ret=0 and @class<>'F'
//	select @ret=1, @msg = 'share ��ɢ��/��Ա���������ܽ��иò���'
//if @ret=0 and charindex(@sta1, 'R')=0
//	select @ret=1, @msg = 'share ����������Ԥ��״̬'
//if @ret=0 and not exists(select 1 from rsvsrc where accnt=@accnt and id=0)
//	select @ret=1, @msg = 'share ����ЧԤ����¼'
//if @ret = 0 and @rmnum>1 
//	select @ret=1, @msg = 'share ���ͷ��������ܽ��иò���'
//if @ret=0 and @saccnt=@saccnt1  -- ���������˺��Ƿ���� share 
//	select @ret=1, @msg = '�������ͱ����͹���ͷ�'
//if @ret<>0 
//begin
//	if @retmode='S'
//		select @ret, @msg
//	return @ret
//end
//
//-- begin 
//
//begin tran
//save 	tran master_share
//
//-- �ͷ�ԭ������Դ
//exec p_gds_reserve_rsv_del @add, 0, 'R', @empno, @ret output, @msg output
//if @ret<>0
//	goto gout
//
//-- ���Ŀ���˺ŵķ���
//if @roomno=''
//begin
//	exec p_GetAccnt1 'SRM', @mroomno output
//	select @mroomno = '#' + rtrim(@mroomno)
//end
//else
//	select @mroomno = @roomno
//-- �������˺ŵĵ��ա�--- ��ס��ʱ��ֻ���á����������ܣ�
//if datediff(dd,@today,@arr)<0
//	select @arr = convert(datetime, convert(char(10), @today, 111) + ' 12:00:00')
//
//update master set type=@type,otype=@type,roomno=@mroomno,oroomno=@mroomno,master=@master,saccnt=@saccnt,
//	arr=@arr,oarr=@arr,dep=@dep,odep=@dep,qtrate=@qtrate,rmrate=@rmrate,setrate=0,discount=0,discount1=0
//	where accnt=@add
//if @@rowcount = 0
//	select @ret=1, @msg='Update error.'
//else
//begin
//	insert rsvsrc (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,master,rateok,arr,dep,saccnt,
//			rmrate,rtreason,remark,ratecode,src,market,packages,srqs,amenities)
//		select accnt,0,type,roomno,'',arr,dep,rmnum,gstno,setrate,accnt,'F',arr,dep,saccnt,
//			rmrate,rtreason,'',ratecode,src,market,packages,srqs,amenities
//		from master where accnt=@add
//	if @@rowcount = 0
//		select @ret=1, @msg='Insert rsvsrc error.'
//	else
//	begin
//		update rsvsrc set begin_=convert(datetime,convert(char(8),begin_,1)), end_=convert(datetime,convert(char(8),end_,1)) 
//			where accnt=@add
//		update rsvsrc set rateok='F' where saccnt=@saccnt	 -- �۸�����
//
//		-- ���ⷿ�Ŷ�ԭ��������Ӱ��
//		if @roomno=''
//		begin
//			update master set roomno=@mroomno, oroomno=@mroomno,cby=@empno, changed=getdate(), logmark=logmark+1 where accnt=@accnt
//			update rsvsrc set roomno=@mroomno where accnt=@accnt and id=0
//		end
//	end
//end
//
//--
//gout:
//if @ret <> 0
//	rollback tran master_share
//else
//	update master set logmark=logmark+1 where accnt=@add
//commit tran
//
//--
//if @retmode='S'
//	select @ret, @msg
//return @ret
//;
//
