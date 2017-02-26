
if exists(select * from sysobjects where name = "p_crm_new_reservation_crs")
   drop proc p_crm_new_reservation_crs
;
create proc p_crm_new_reservation_crs
	@cardno			varchar(20),		-- ��Ա����
	@hotelid			varchar(20),		-- �Ƶ�
	@arr				datetime,			-- ��ס����
	@night			int,					-- ��ס����
	@type				char(3),				-- ����
	@rmnum			int,					-- ������
	@caccnt			char(10),			-- ��Ա����Ԥ���ʺ�
	@retmode			char(1) = 'S',
	@ret				int				output,				
	@msg				varchar(60)		output	-- 
as
------------------------------------------------------------------------------
--	���꼯��Ԥ������ - �������Ľӿ�
--
-- 	�½�Ԥ��
--����		��p_crm_new_reservation_crs
--�������	����Ա���ţ���ס���ڣ���ס���������������Ƶ꣬����
--�������	���ɹ���־(0-�ɹ���1-ʧ��), Ԥ���ʺţ�=����Ԥ���ţ�
------------------------------------------------------------------------------
declare 	@accnt			char(10),
			@empno			char(10),
			@resno			char(10),
			@dep 				datetime, 
			@changed 		datetime,
			@ratecode		char(10),
			@package			char(30),
			@src				char(3),
			@mkt				char(3),
			@qtrate			money,
			@rate				money,
			@card_type		char(3),
			@guestcard		char(10),
			@hno				char(7),
			@cno				char(7),
			@bdate			datetime


select @ret=0, @msg='', @changed=getdate(), @bdate=bdate1 from sysdata

---------------------------------------------------
--	��������ͬʱȡ�� mkt,src,ratecode......
---------------------------------------------------
-- ���� - cardno
select @card_type=type, @hno=hno, @cno=cno from vipcard where no=@cardno
if @@rowcount = 0
begin
	select @ret=1, @msg='Cardno error'
	goto gout
end
else 
begin
	if rtrim(@hno) is null -- Only for guest card, not for company card !
	begin
		select @ret=1, @msg='Please use guest card'
		goto gout
	end

	select @guestcard = guestcard from vipcard_type where code=@card_type
	if not exists(select 1 from guest_card_type a where a.code=@guestcard and (a.flag='POINT' or a.flag='FOX'))
	begin
		select @ret=1, @msg='Card type error'
		goto gout
	end

	select @mkt=market, @src=src from guest where no=@hno
	if @@rowcount = 0
	begin
		select @ret=1, @msg='Profile is not exists.'
		goto gout
	end
	if rtrim(@cno) is not null
		select @ratecode = isnull((select min(value) from guest_extra where no=@cno and item='ratecode'), '')
	if rtrim(@ratecode) is null
		select @ratecode = isnull((select min(value) from guest_extra where no=@hno and item='ratecode'), '')
	if rtrim(@ratecode) is null
		select @ratecode = isnull((select min(code) from rmratecode where halt='F' and private='F'), '')
	select @package = packages from rmratecode where code=@ratecode 
	if rtrim(@mkt) is null
		select @mkt=market, @src=src from rmratecode where code=@ratecode
end

-- ���� - hotelid
if rtrim(@hotelid) is null or not exists(select 1 from hotelinfo where hotelid=@hotelid)
begin
	select @ret=1, @msg='Hotelid error'
	goto gout
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
//if rtrim(@type) is null or not exists(select 1 from typim where type=@type)
//begin
//	select @ret=1, @msg='Room type error'
//	goto gout
//end
//else
//	select @qtrate = rate from typim where type=@type
	select @qtrate = 0


-- ���� - rmnum
if @rmnum<=0 and @rmnum>1000
	select @rmnum = 1

--------------------------------------
--	����
--------------------------------------
//exec @ret = p_gds_get_rmrate @arr, @night, @type, '', @rmnum, 1, @ratecode, '', 'R', @rate output, @msg output
//if @ret <> 0
//begin
//	select @ret=1, @msg='Get rate error'
//	goto gout
//end
select @rate = 0

--------------------------------------
--	һЩȱʡ����
--------------------------------------
select @empno = isnull((select value from sysoption where catalog='' and item=''), 'FOX')  -- ����Ԥ������

begin tran 
save tran p_mst_s1 

----------------------------------------------------------------------------
--	�ʺ�/Ԥ���� ����  -- �����Ԥ���ſ��Կ�����һЩ�仯����������
----------------------------------------------------------------------------
exec p_GetAccnt1 'FIT', @accnt output
exec p_GetAccnt1 'RES', @resno output

--------------------------------------
--	Ԥ��������
--------------------------------------
INSERT master (accnt, haccnt, type, rmnum, ormnum, roomno, bdate, sta, arr, dep, class, src, market, restype, channel, 
		share, gstno, children, ratecode, packages, rmrate, qtrate, setrate, rtreason, discount, discount1,  
		extra, resno, resby, restime, cby, changed, cardcode, cardno ) 
	VALUES ( @accnt, @hno, @type, @rmnum, 0, '', @bdate, 'R', @arr, @dep, 'F', @src, @mkt, '', '', 
		'F', 1, 0, @ratecode, @package, @rate, @qtrate, @rate, '', 0, 0,  
		'000001000100000', @resno, @empno, @changed, @empno, @changed, @guestcard, @cardno )
if @@rowcount = 0 
	select @ret = 1, @msg = '������Ϣ����ʧ��' 

-- 
if @ret = 0 
   begin    
	insert master_hotel(accnt,hotelid,accnt0,sync,empno,lastdate)
		select @accnt, @hotelid, @caccnt, 'F', @empno, getdate()
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
