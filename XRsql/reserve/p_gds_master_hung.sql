
if exists(select 1 from sysobjects where name = "p_gds_master_hung")
	drop proc p_gds_master_hung;
create proc p_gds_master_hung
	@accnt		char(10),
	@mode			char(20),		-- ����ģʽ W, X
	@phone		varchar(20),
   @priority	char(1),			-- ���ȼ� 	basecode(priority)
	@reason		char(3),			-- ���� 		basecode(rescancel), basecode(waitlist)
	@remark		varchar(100),	-- ˵��
	@empno		char(10),
	@retmode		char(1),			-- S, R
	@ret        int	output,
   @msg        varchar(60) output
as
----------------------------------------------------------------------------------------------
--		������������ -> X, W
----------------------------------------------------------------------------------------------
declare		@sta		char(1),
				@class	char(1)

select @ret=0, @msg=''

begin tran
save 	tran master_hung

select @sta=sta,@class=class from master where accnt=@accnt
if @@rowcount <> 1 
begin
	select @ret=1, @msg='����������'
	goto gout
end

update master set sta=sta where accnt=@accnt

-------------------------
--	X
-------------------------
if @mode='X' 
begin
	if charindex(@class,'FGM')=0 
	begin
		select @ret=1, @msg='������������ܽ���ȡ������'
		goto gout
	end
	if charindex(@sta,'RW')=0 
	begin
		select @ret=1, @msg='��״̬�������ܽ���ȡ������'
		goto gout
	end
	if @reason is null or not exists(select 1 from basecode where cat='rescancel' and code=@reason)
	begin
		select @ret=1, @msg='��������ȷ��ȡ������'
		goto gout
	end
	if @priority is null select @priority=''
	if @phone is null select @phone=''
	if @remark is null select @remark=''

	update master_hung set sta='X' where accnt=@accnt and status='I'  -- not record cby, changed
	insert master_hung(accnt,sta,status,phone,priority,reason,remark,crtby,crttime)
		values(@accnt,'X','I',@phone,@priority,@reason,@remark,@empno,getdate())
	if @@rowcount<>1 
	begin
		select @ret=1, @msg='insert master_hung error'
		goto gout
	end
	else
		exec @ret = p_gds_master_sta @accnt,'hungX',@empno,'R',@ret output, @msg output  -- @ret ��������! :) ?
end
-------------------------
--	W
-------------------------
else if @mode='W' 
begin
	if charindex(@class,'F')=0 
	begin
		select @ret=1, @msg='ֻ�б����������ܽ��� Waitlist ����'
		goto gout
	end
	if charindex(@sta,'RW')=0 
	begin
		select @ret=1, @msg='ֻ��Ԥ���������ܽ��� Waitlist ����'
		goto gout
	end
	if @reason is null or not exists(select 1 from basecode where cat='waitlist' and code=@reason)
	begin
		select @ret=1, @msg='��������ȷ�� Waitlist ����'
		goto gout
	end
	if @priority is null or not exists(select 1 from basecode where cat='priority' and code=@priority)
	begin
		select @ret=1, @msg='��������ȷ��priority'
		goto gout
	end
	if @phone is null select @phone=''
	if @remark is null select @remark=''

	delete master_hung where accnt=@accnt and status='I'  -- ����
	insert master_hung(accnt,sta,status,phone,priority,reason,remark,crtby,crttime)
		values(@accnt,'W','I',@phone,@priority,@reason,@remark,@empno,getdate())
	if @@rowcount<>1 
	begin
		select @ret=1, @msg='insert master_hung error'
		goto gout
	end
	else
	begin
		if @sta = 'R'
			exec @ret = p_gds_master_sta @accnt,'hungW',@empno,'R',@ret output, @msg output  -- @ret ��������! :) ?
	end
end
else
begin
	select @ret=1, @msg='����ģʽδ֪ - %1^' + @mode
	goto gout
end

gout:
if @ret <> 0
	rollback tran master_hung
commit tran 

if @retmode='S'
	select @ret, @msg
return @ret
;

