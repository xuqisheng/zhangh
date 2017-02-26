
if exists(select * from sysobjects where name = "p_crm_modify_reservation")
   drop proc p_crm_modify_reservation
;
create proc p_crm_modify_reservation
	@cardno			varchar(20),		-- ��Ա����
	@hotelid			varchar(20),		-- �Ƶ�
	@accnt			char(10),			-- Ԥ����
	@arr				datetime,			-- ��ס����
	@night			int,					-- ��ס����
	@type				char(3),				-- ����
	@rmnum			int,					-- ������
	@retmode			char(1) = 'S',
	@ret				int				output,				
	@msg				varchar(60)		output	-- 
as
------------------------------------------------------------------------------
--	���꼯��Ԥ������ - �������Ľӿ�
--
--4.	�޸�Ԥ�������ݻ�Ա���ź�Ԥ����ȡ��Ԥ�������ݻ�Ա����ȡ������Ԥ��
-- 	�޸�Ԥ��SP��
--���ƣ�p_crm_modify_reservation
--�����������Ա���ţ�Ԥ���ţ���ס���ڣ���ס���������������Ƶ꣬����
--����������ɹ���־(0-�ɹ���1-ʧ��)
------------------------------------------------------------------------------
declare 	@cardno0			varchar(20),
			@hotelid0		varchar(20),
			@arr0				datetime,
			@dep0				datetime,
			@type0			char(3),
			@rmnum0			int,

			@sta				char(1),
			@empno			char(10),
			@dep 				datetime, 
			@changed 		datetime,
			@ratecode		char(10),
			@package			char(30),
			@src				char(3),
			@mkt				char(3),
			@qtrate			money,
			@rate				money,
			@bdate			datetime


select @ret=0, @msg='', @changed=getdate(), @bdate=bdate1 from sysdata

---------------------------------------------------
--	��������
---------------------------------------------------
-- ���� - accnt, cardno
select @cardno0 = cardno, @sta=sta, @qtrate=qtrate, @rate=setrate,
	@arr0=arr, @dep0=dep, @type0=type, @rmnum0=rmnum from master where accnt=@accnt and class='F'
if @@rowcount = 0
begin
	select @ret=1, @msg='No record'
	goto gout
end
if @cardno <> @cardno0 
if @@rowcount = 0
begin
	select @ret=1, @msg='Error !  Reservation has a different cardno'
	goto gout
end
if @sta <> 'R'
begin
	select @ret = 1
	if @sta = 'O' or @sta = 'D'
		select @msg = 'The reservation has been checked out'
	else if @sta = 'X'
		select @msg = 'The reservation has been canceled'
	else if @sta = 'N'
		select @msg = 'The reservation has been No-showed'
	else
		select @msg = 'The reservation is not a valid one'
	goto gout
end

-- ���� - hotelid
if rtrim(@hotelid) is not null
begin
	if not exists(select 1 from sysoption where catalog='hotel' and item='hotelid' and value=@hotelid)
	begin
		select @ret=1, @msg='Hotelid error'
		goto gout
	end
end

-- ���� - arr
if @arr is null or datediff(dd,getdate(),@arr)<0
begin
	select @ret=1, @msg='Arr error'
	goto gout
end

-- ���� - night
if @night < 1 
begin
	select @ret=1, @msg='Nights error'
	goto gout
end
select @dep=dateadd(dd, @night, @arr) 
select @dep=convert(datetime,convert(char(8),@dep,1))

-- ���� - type
if rtrim(@type) is null or not exists(select 1 from typim where type=@type)
begin
	select @ret=1, @msg='Room type error'
	goto gout
end
else
	select @qtrate = rate from typim where type=@type

-- ���� - rmnum
if @rmnum<=0 and @rmnum>1000
	select @rmnum = 1
select @dep=dateadd(dd, @rmnum, @arr) 

--------------------------------------
--	�仯�Ƚ�
--------------------------------------
if @arr=@arr0 and @dep=@dep0 and @type=@type0 and @rmnum=@rmnum0
begin
	select @ret=1, @msg='Not change anything'
	goto gout
end

--------------------------------------
--	����
--------------------------------------
if @arr<>@arr0 or @type<>@type0
begin
	exec @ret = p_gds_get_rmrate @arr, @night, @type, '', @rmnum, 1, @ratecode, '', 'R', @rate output, @msg output
	if @ret <> 0
	begin
		select @ret=1, @msg='Get rate error'
		goto gout
	end
end

--------------------------------------
--	һЩȱʡ����
--------------------------------------
select @empno = isnull((select value from sysoption where catalog='' and item=''), 'FOX')  -- ����Ԥ������

begin tran 
save tran p_mst_s1 

--------------------------------------
--	Ԥ�����޸�
--------------------------------------
update master set arr=@arr, dep=@dep, type=@type, rmnum=@rmnum, qtrate=@qtrate, rmrate=@rate, setrate=@rate,
		cby=@empno, changed=@changed where accnt=@accnt
if @@rowcount = 0 
	select @ret = 1, @msg = '������Ϣ����ʧ��' 

-- 
if @ret = 0 
   begin    
   exec @ret = p_gds_reserve_chktprm @accnt,'0','',@empno,'U',1,1,@msg output 
   if @ret = 0 
      update master set logmark = logmark + 1 where accnt = @accnt 
   end     
else
   rollback tran p_mst_s1 
commit tran 

--------------------------------------
--	���
--------------------------------------
gout:
if @ret = 0
	select @msg = @accnt
if @retmode = 'S'
	select @ret, @msg
return @ret
;
