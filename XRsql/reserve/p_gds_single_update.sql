
if exists(select * from sysobjects where name = "p_gds_single_update")
   drop proc p_gds_single_update;
create proc  p_gds_single_update
   @accnt    char(10),      /* ɢ�ͻ��Ա�ʺ� */
   @srcstas  varchar(20),  /* ԭ״̬ */
   @newsta   char(1),      /* ��״̬ */
   @empno    char(10)       /* ����Ա */
as
declare
   @ret      int,
   @msg      varchar(60),
   @mststa   char(1),
   @arr      datetime,
   @roomno   char(5),   
   @groupno  char(10),
   @sta      char(1),
   @nrequest char(1),         /* ɢ��=0  ��Ա=4 gds */
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
	  select @ret = 1,@msg = "��ǰ������������%1������^"+@groupno
   end
if @ret = 0
   begin
   update master set sta = sta where accnt = @accnt
   select @mststa = sta,@arr = convert(datetime,convert(char(10),arr,111)),@roomno = roomno, @rmnum=rmnum from master where accnt = @accnt
   if @mststa is null
	  select @ret = 1,@msg = "����%1������^"+@accnt
   end 

if @ret = 0 and @newsta = 'X' and charindex('R',@srcstas) > 0
   /* ȡ��Ԥ�� */
   begin
   if charindex(@mststa,'I') > 0
	  select @ret = 1,@msg = "����%1�Ѿ��Ǽ�,����ȡ��^"+@accnt
   else if charindex(@mststa,'XNL') > 0
	  select @ret = 1,@msg = "����%1�Ѿ���ȡ��Ԥ��״̬,����ȡ��^"+@accnt
   else if charindex(@mststa,'RCG') = 0
	  select @ret = 1,@msg = "����%1������ЧԤ��״̬,����ȡ��^"+@accnt
   end
else if @ret = 0 and @newsta = 'R' and charindex('X',@srcstas) > 0
   /* �ָ�Ԥ�� */
   begin
   if charindex(@mststa,'I') > 0
      select @ret = 1,@msg = "����%1�Ѿ��Ǽ�,����ָ�^"+@accnt
   else if charindex(@mststa,'RCG') > 0
      select @ret = 1,@msg = "����%1�Ѿ�����ЧԤ��״̬,����ָ�^"+@accnt
   else if charindex(@mststa,'XNL') = 0
	  select @ret = 1,@msg = "����%1����ȡ��Ԥ��״̬,���ָܻ�^"+@accnt
   else if @arr < convert(datetime,convert(char(10),getdate(),111))
	  select @ret = 1,@msg = "����%1�ĵ��ղ������ڽ���"+@accnt
   end
else if @ret = 0 and @newsta = 'I' and charindex('R',@srcstas) > 0
   /* Ԥ��ת��ס */
   begin
   if charindex(@mststa,'I') > 0
      select @ret = 1,@msg = "����%1�Ѿ��Ǽ�^"+@accnt
   else if charindex(@mststa,'RCG') = 0
	  select @ret = 1,@msg = "����%1������ЧԤ��״̬,����ת�Ǽ�^"+@accnt
   else if @arr > convert(datetime,convert(char(10),getdate(),111))
	  select @ret = 1,@msg = "δ������%1�ĵ�������,�����޸ĵ���^"+@accnt
//   else if @arr < convert(datetime,convert(char(10),getdate(),111))
//	  select @ret = 1,@msg = "����%1�ĵ��ղ������ڽ���^"+@accnt
	else if @rmnum <> 1 
      select @ret = 1,@msg = "�������������� 1" // gds
   else if @roomno = space(5)
      select @ret = 1,@msg = "����%1��û���䷿��^"+@accnt
   end
else
   select @ret = 1,@msg = "Ŀǰ�ݲ����ű�����"
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
