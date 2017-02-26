
if exists(select * from sysobjects where name = "p_gds_maintain_group")
   drop proc p_gds_maintain_group;
create proc p_gds_maintain_group
   @grpaccnt 			char(10),
   @empno    			char(10),
   @logmark  			int,			-- >=1 ��ʾ��Ҫ��¼��־. -- ��������־�϶�Ҫ��¼�� 
   @nullwithreturn 	varchar(60) output
as
-----------------------------------------------------------
-- ����ά������������ --- ����,����,����
-----------------------------------------------------------
declare
   @rate     	money,
   @orate    	money,
   @gstno   	int,
   @rooms    	int,
   @ret      	int,
   @msg      	varchar(60),
	@save			int,		-- ��¼�Ƿ��и�����Ϊ����
	@rmlimit		char(1),
	@grprms		int,
	@sta			char(1),
	@sync			char(1)

--------------------------------------------------------
-- �����ܿͷ�����
--------------------------------------------------------
select @rmlimit = isnull((select substring(value,1,1) from sysoption where catalog='reserve' and item='grp_rm_limit'), 'F')
if charindex(@rmlimit, 'TtYy') > 0 
	select @rmlimit = 'T'
else
	select @rmlimit = 'F'
select @grprms = rmnum, @sta=sta from master where accnt=@grpaccnt

--------------------------------------------------------
-- ����������Ϣͬ��: �ͷ�\���� -- ����Ҳֻ����Ԥ��״̬ 
--------------------------------------------------------
select @sync = isnull((select substring(value,1,1) from sysoption where catalog='reserve' and item='grp_rmgst_sync'), 'F')
if charindex(@sync, 'TtYy') > 0 
	select @sync = 'T'
else
	select @sync = 'F'

-- 
select @ret = 0,@msg = "", @save=0

begin tran
save  tran p_gds_maintain_group_s1

update master set sta = sta where accnt = @grpaccnt

--------------------
-- rate	
--------------------
--select @orate = setrate from master where accnt = @grpaccnt
--select @rate = max(rate) from grprate where accnt = @grpaccnt
--if @rate is not null and @rate <> @orate
--begin
--	update master set setrate = @rate, rmrate=@rate where accnt = @grpaccnt
--	select @save = 1
--end

----------------------------------------------------------------------------------------------------
-- rooms & gstno 
-- �ر�ע�⣺������������grid block ��ʱ��ÿ��һ����¼������������� 2005.12.30 
----------------------------------------------------------------------------------------------------
--select @rooms = isnull((select sum(a.quantity) from rsvsaccnt a where a.accnt=@grpaccnt),0)
--select @rooms = @rooms + isnull((select sum(a.quantity) from rsvsaccnt a, master b where a.accnt=b.accnt and b.groupno=@grpaccnt),0)
--select @gstno = isnull((select sum(gstno*quantity) from rsvsrc where accnt=@grpaccnt), 0)
--select @gstno = @gstno + isnull((select sum(gstno) from master where groupno = @grpaccnt and charindex(sta,'RCGI') > 0), 0)

select @rooms = 0  -- isnull((select sum(quantity) from rsvsrc where accnt=@grpaccnt and id>0), 0)
select @rooms = @rooms + isnull((select count(distinct saccnt) from master where groupno=@grpaccnt and charindex(sta,'RCGI') > 0), 0)
select @gstno = 0  -- isnull((select sum(gstno*quantity) from rsvsrc where accnt=@grpaccnt and id>0), 0)
select @gstno = @gstno + isnull((select sum(gstno) from master where groupno = @grpaccnt and charindex(sta,'RCGI') > 0), 0)
----------------------------------------------------------------------------------------------------


if @rooms>@grprms and @rmlimit='T'
begin
	select @ret=1, @msg='�����÷�����������������'
end
else
begin
	if @sta ='R' and @sync='T' and @rmlimit='F'  -- @sync, @rmlimit ����ѡ���г�ͻ��  
	begin
		update master set rmnum = @rooms, gstno = @gstno where accnt = @grpaccnt
		if @@rowcount>0 select @save=1
	end
	else
	begin
		update master set rmnum = @rooms where accnt = @grpaccnt and rmnum < @rooms and @rooms>0
		if @@rowcount>0 select @save=1
		update master set gstno = @gstno where accnt = @grpaccnt and gstno < @gstno and @gstno>0
		if @@rowcount>0 select @save=1
	end 	
	--------------------
	-- if saved, logmark ?
	--------------------
	if @save > 0
	begin
--		if @logmark >= 1
			update master set logmark=logmark+1,cby = @empno,changed = getdate() where accnt = @grpaccnt
--		else
--			update master set cby = @empno,changed = getdate() where accnt = @grpaccnt
	end
end

-- 
if @ret <> 0 
	rollback tran p_gds_maintain_group_s1
commit tran

if @nullwithreturn is null
   select @ret,@msg
else
   select @nullwithreturn = @msg
return @ret
;