if exists(select 1 from sysobjects where name = "p_gds_master_add_guest")
	drop proc p_gds_master_add_guest;
create proc p_gds_master_add_guest
	@accnt		char(10),
	@id			int,				-- �϶� = 0  -- ������Ϊ����
	@add			char(7),			-- �����Ŀ��˵�����, Ϊ�յ�ʱ����Ҫ�Զ���ȡ 
	@empno		char(10),
	@retmode		char(1),			-- S, R
	@ret        int			output,
   @msg        varchar(60) output,
	@ckin			char(1)='R'		 -- ������ס ?
as
----------------------------------------------------------------------------------------------
--		ͬ������: �������ͷ����ӿ���		
--				ע��:	���˺� master �Ĺ�ϵ�������Զ�Ϊ 0��
--					������Ϣ
--
--			û�пͷ��������,ϵͳ�Զ��������ⷿ�� -- 
--
--		�����ǰ����Ϊ��ס״̬�������Ŀ���״̬����ѡ��Ԥ��������ס��
--
--		ע�� : �ù���ʹ���� ��ʱ�����ܱ������������� !
----------------------------------------------------------------------------------------------

declare		@roomno		char(5),
				@mroomno		char(5),
				@sta			char(1),
				@msta			char(1),
				@class		char(1),
				@rmnum		int,
				@maccnt		char(10),
				@master		char(10),
				@saccnt		char(10),
				@pcrec		char(10),
				@pcrec_pkg	char(10),
				@arr			datetime,
				@dep			datetime, 
				@today		datetime,
				@bdate		datetime,
				@gstno		int,
				@groupno		char(10),
				@haccnt		char(7)  

select @ret=0, @msg='', @today = getdate()
select @bdate = bdate1 from sysdata

-- ����
if @id is null or @id<0 or @id>5
	select @gstno = 1
else
	select @gstno = @id
select @id = 0

-- ���ݼ��
select @roomno=roomno, @class=class, @sta=sta, @rmnum=rmnum, @arr=arr, @dep=dep, 
		@master=master, @saccnt=saccnt, @groupno=groupno, @haccnt=haccnt 
	from master where accnt=@accnt
if @@rowcount = 0
	select @ret=1, @msg = '��������������'
if @ret=0 and @id<>0 
	select @ret=1, @msg = 'id <> 0'
if @class<>'F'
	select @ret=1, @msg = '��ɢ��/��Ա���������ܽ��иò���'
if @ret=0 and charindex(@sta, 'RI')=0
	select @ret=1, @msg = '������������Ч״̬'
if @ret=0 and not exists(select 1 from rsvsrc where accnt=@accnt and id=@id)
	select @ret=1, @msg = '����ЧԤ����¼'
if @ret = 0 and @rmnum>1 
	select @ret=1, @msg = '���ͷ��������ܽ��иò���'
if @ret=0 and datediff(dd, @dep, getdate())>0
	select @ret=1, @msg = '�����޸ĵ�ǰ����������'
if @ret=0
begin
	if rtrim(@add) is null 
	begin
		if @class='F' 
			select @add = @haccnt 
		else
			select @add = exp_s1 from master where accnt=@groupno 
	end

	select @class=class from guest where no=@add
	if @@rowcount = 0
		select @ret=1, @msg = 'û�иÿ��˵���'
	else
		if @class<>'F' 
			select @ret=1, @msg = '�ǿ��˵���'
end

if @ret<>0 
begin
	if @retmode='S'
		select @ret, @msg
	return @ret
end
if @arr < getdate()	
	select @arr = getdate()
if @dep < getdate()	
	select @dep = getdate()

-- begin 
update master set sta=sta where accnt=@accnt
select * into #master from master where accnt=@accnt   -- ��ʱ����������ⲿ����

begin tran
save 	tran master_add

-- û�з��ŵ�����£���Ҫ�������ⷿ��
if @roomno='' 
begin
	exec p_GetAccnt1 'SRM', @mroomno output
	select @mroomno = '#' + rtrim(@mroomno)
end
else
	select @mroomno = @roomno

-- ׼���µ���������
exec p_GetAccnt1 'FIT', @maccnt output   -- ע�����������Ϣ, ����, ���ʽ
update #master set accnt=@maccnt, master=@master, haccnt=@add, cby=@empno, changed=@today, bdate=@bdate,
	roomno=@mroomno, oroomno=@mroomno,setrate=0, discount=0, discount1=0, gstno=@gstno,
	arr=@arr, oarr=null, dep=@dep, odep=null, addbed=0, addbed_rate=0, crib=0, crib_rate=0, 
	charge=0, credit=0, accredit=0,lastnumb=0, lastinumb=0, logmark=0, limit=0, credcode='', paycode='',
	resby='', restime=null, ciby='', citime=null, coby='', cotime=null, depby='', deptime=null,
	osta=''  -- ʹ��ִ�� chktprm 

if @sta='R'
	update #master set resby=@empno, restime=@today   -- Ԥ��ʱ��
else if @sta='I'
begin
	if @ckin = 'I'
		update #master set arr=@today, ciby=@empno, citime=@today	-- �Ǽ�ʱ��
	else
	begin	
		select @arr = convert(datetime, convert(char(10), @today, 111) + ' 12:00:00')
		update #master set sta='R', arr=@today, resby=@empno, restime=@today	-- Ԥ��ʱ��
	end
end

-- �����µ�����
insert master select * from #master
if @@rowcount = 0
	select @ret=1, @msg='Insert rsvsrc error.'
else
begin
	-- ���ⷿ�Ŷ�ԭ��������Ӱ��
	if @roomno=''
	begin
		update master set roomno=@mroomno, oroomno=@mroomno,cby=@empno, changed=getdate(), logmark=logmark+1 where accnt=@accnt
		update rsvsaccnt set roomno=@mroomno where saccnt=@saccnt
		update rsvsrc set roomno=@mroomno where accnt=@accnt and id=0
	end

	exec @ret = p_gds_reserve_chktprm @maccnt, '0', '', @empno, 'p', 1, 1, @msg output 	
	if @ret = 0 
		update rsvsrc set rateok='F' where saccnt=@saccnt	 -- �۸�����
end
--
gout:
if @ret <> 0
	rollback tran master_add
else
begin
	update master set logmark=logmark+1 where accnt=@maccnt
	exec p_gds_master_des_maint @maccnt
	select @msg = @maccnt		-- �����˺�
end
commit tran

--
if @retmode='S'
	select @ret, @msg
return @ret
;

