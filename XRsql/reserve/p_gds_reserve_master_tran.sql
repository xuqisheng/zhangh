if exists(select 1 from sysobjects where name = "p_gds_reserve_master_tran")
	drop proc p_gds_reserve_master_tran;
create  proc p_gds_reserve_master_tran
	@accnt   	char(10),
   @grpno  		char(10),	-- ���źű�ʾ����,�����ʾ����
   @empno   	char(10)
as
----------------------------------------------------------------------------------------------
--		ɢ��,��Ա ת������
--
--			ע��: ����, ����
----------------------------------------------------------------------------------------------
declare
   @ret      	int,
   @msg      	varchar(60),
   @sta   		char(1),
	@nrequest	char(1),
   @grpsta   	char(1),
	@class		char(1),
	@roomno		char(5),
	@arr			datetime,
	@dep			datetime,
	@grparr		datetime,
	@grpdep		datetime,
	@setrate		money,
	@type			char(5),
	@subaccnt 	int,
	@count		int,
	@ogrpno		char(10)

begin tran
save  tran p_gds_reserve_master_tran_s1

select @nrequest = '0',@ret = 0,@msg=''
select @sta = sta, @class=class, @setrate=setrate, @type=type, @ogrpno=groupno, @arr=arr, @dep=dep  
	from master where accnt = @accnt and charindex(sta, 'RCGIS') > 0
if @@error<>0 or @@rowcount = 0
begin
	select @ret = 1,@msg = "��ǰ���˲����ڻ����Ч״̬"
	goto gout
end
if @class<>'F' 
begin
	select @ret=1, @msg = "�Ǳ����˻�"
	goto gout
end

-- Begin ...
if rtrim(@grpno) is not null  -- ����
begin
	select @grpsta = sta, @grparr=arr, @grpdep=dep from master 
		where accnt = @grpno and class in ('G', 'M') and charindex(sta, 'RCGI') > 0
	if @@error <> 0 or @@rowcount = 0
		select @ret = 1,@msg = "��ǰ���岻���ڻ����Ч״̬"
--	else if exists(select 1 from master where accnt = @accnt and groupno <> '')
--			select @ret = 1,@msg = "��ǰ�����Ѿ���ĳ�����Ա, ����ת��Ϊɢ��"
	else if exists(select 1 from master where accnt = @accnt and groupno = @grpno)
		select @ret = 1,@msg = "��ǰ�����Ѿ��Ǹ������Ա"
	else if @grpsta<>'I' and @sta='I'
		select @ret = 1,@msg = "����������δ�Ǽ�"
	else if exists(select 1 from master where accnt = @accnt and rmnum > 1)
		or (select count(1) from rsvsrc where accnt=@accnt)>1
		select @ret = 1,@msg = "��ǰ�����ж�䶩�������ܽ��и������ !"
	else if datediff(dd,@grpdep,@dep)>0 or (@grpsta='R' and datediff(dd,@grparr,@arr)<0) 
		select @ret = 1,@msg = "���͵������ڱ�������������������"
	if @ret<>0 goto gout

	update master set groupno=@grpno,rmrate=@setrate,setrate=@setrate,cby=@empno,changed=getdate(),logmark=logmark+1 where accnt=@accnt
	if @@rowcount=0
		select @ret = 1,@msg = "ת��ʧ��"
	else 
	begin
		-- ά�����巿��  grprate
		if not exists(select 1 from grprate where accnt=@grpno and type=@type)
			insert grprate(accnt,type,rate,oldrate,cby,changed)
				values(@grpno,@type,@setrate,@setrate,@empno,getdate())
		-- ά�����ʺ�  -- ���帶��  subaccnt
		if not exists(select 1 from subaccnt where accnt=@accnt and to_accnt=@grpno and type='5')
		begin
			select @subaccnt=isnull((select max(subaccnt) from subaccnt where accnt=@accnt and type='5')+1,2)
			insert subaccnt select a.roomno, '', a.accnt, @subaccnt, '', a.groupno, '���帶��', b.pccodes, '2000.1.1', '2030.1.1', a.cby, a.changed, '5', '0', '', '', 1
				from master a, subaccnt b where a.groupno = b.accnt and b.type = '2' and a.accnt=@accnt
		end

		-- ȥ��ԭ����������Ϣ
		if @ogrpno <> ''
		begin
			select @count = count(1) from subaccnt where accnt=@accnt and to_accnt=@ogrpno and type='5'
			if @count = 1   -- ֻ��һ�����˻�
			begin
				select @subaccnt = subaccnt from subaccnt where accnt=@accnt and to_accnt=@ogrpno and type='5'
				if exists(select 1 from account where accnt=@accnt and subaccnt=@subaccnt)
					update subaccnt set pccodes='.', tag='2' where accnt=@accnt and to_accnt=@ogrpno and type='5'
				else
				begin
					delete subaccnt where accnt=@accnt and to_accnt=@ogrpno and type='5'
				end
			end
			else
			begin
				update subaccnt set pccodes='.', tag='2' where accnt=@accnt and to_accnt=@ogrpno and type='5'
			end
			
		end
	end
end
else								-- ����
begin
	select @grpno=groupno from master where accnt=@accnt
	if @grpno=''
		select @ret = 1,@msg = "����������ɢ��, ����Ҫ���� !"
	else
	begin
		update master set groupno='', cby=@empno, changed=getdate(),logmark=logmark+1 where accnt=@accnt
		if @@rowcount=0
			select @ret = 1,@msg = "ת��ʧ��"
		else  -- ���帶�ѷ��˻�(�Զ���������� ������Ŀ)
		begin
			select @count = count(1) from subaccnt where accnt=@accnt and to_accnt=@grpno and type='5'
			if @count = 1   -- ֻ��һ�����˻�
			begin
				select @subaccnt = subaccnt from subaccnt where accnt=@accnt and to_accnt=@grpno and type='5'
				if exists(select 1 from account where accnt=@accnt and subaccnt=@subaccnt)
					update subaccnt set pccodes='.', tag='2' where accnt=@accnt and to_accnt=@grpno and type='5'
				else
				begin
					delete subaccnt where accnt=@accnt and to_accnt=@grpno and type='5'
				end
			end
			else
			begin
				update subaccnt set pccodes='.', tag='2' where accnt=@accnt and to_accnt=@grpno and type='5'
			end
		end
	end
end

if @ret=0   -- ά����������
	exec @ret = p_gds_maintain_group @grpno, @empno, 1, @msg output

-- End ...
gout:
if @ret <> 0
   rollback tran p_gds_reserve_master_tran_s1
commit tran

exec p_gds_master_des_maint @accnt   -- master_des  ������������

select @ret,@msg

return @ret
;
