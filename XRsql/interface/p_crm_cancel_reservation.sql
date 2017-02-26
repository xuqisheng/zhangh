
if exists(select * from sysobjects where name = "p_crm_cancel_reservation")
   drop proc p_crm_cancel_reservation
;
create proc p_crm_cancel_reservation
	@cardno			varchar(20),		-- ��Ա����
	@accnt			char(10),			-- Ԥ����
	@retmode			char(1) = 'S',
	@ret				int				output,				
	@msg				varchar(60)		output	-- 
as
------------------------------------------------------------------------------
--	���꼯��Ԥ������ - �������Ľӿ�
--
--3.	ȡ��Ԥ�������ݻ�Ա���ź�Ԥ����ȡ��Ԥ�������ݻ�Ա����ȡ������Ԥ��
-- 	ȡ��Ԥ��SP��
--���ƣ�p_crm_cancel_reservation
--�����������Ա���ţ�Ԥ����
--����������ɹ���־(0-�ɹ���1-ʧ��)
------------------------------------------------------------------------------
declare 	@empno			char(10),
			@cardno0			varchar(20),
			@sta				char(1),
			@changed 		datetime,
			@bdate			datetime


select @ret=0, @msg='', @changed=getdate(), @bdate=bdate1 from sysdata

---------------------------------------------------
--	�����ж�
---------------------------------------------------
select @cardno0 = cardno, @sta=sta from master where accnt=@accnt and class='F'
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

--------------------------------------
--	һЩȱʡ����
--------------------------------------
select @empno = isnull((select value from sysoption where catalog='' and item=''), 'FOX')  -- ����Ԥ������


--------------------------------------
--	����
--------------------------------------
begin tran 
save tran p_mst_s1 

update master set sta='X', cby=@empno, changed=@changed, bdate=@bdate where accnt=@accnt
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
