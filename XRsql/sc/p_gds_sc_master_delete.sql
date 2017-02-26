
IF OBJECT_ID('p_gds_sc_master_delete') IS NOT NULL
    DROP PROCEDURE p_gds_sc_master_delete
;
create proc p_gds_sc_master_delete
   @accnt  char(10),
   @empno  char(10),
	@turnaway	char(1) = ''		-- �Ƿ���Ҫ���� turnaway 
as

--------------------------------------------------------------------
--	sc_master delete.
--------------------------------------------------------------------
declare
   @sta       	char(1),
   @lastinumb 	int,
   @ret       	int,
   @msg       	varchar(60),
	@bal			money,
	@foact		char(10),
	@groupno		char(10),
	@hour			int,
	@bdate		datetime,
	@cond_hour	int,
	@cond_act	char(1)

begin tran
save  tran p_gds_sc_master_delete_s1

select @bdate = bdate1 from sysdata
select @ret = 0,@msg = ""
update sc_master set sta = sta where accnt = @accnt

-- delete cond ...
select @cond_act=substring(value,1,1) from sysoption where catalog='reserve' and item='master_del_cond_act'
if @cond_act is null select @cond_act='1'  -- ɾ���������ϸ��ԡ�1=�ȫ
select @cond_hour=convert(int, value) from sysoption where catalog='reserve' and item='master_del_cond_hour'
if @cond_hour is null select @cond_hour=2  -- ��סʱ�䲻�ܳ�����Сʱ

select @foact=foact, @sta = sta, @bal = charge-credit , @lastinumb = lastinumb from sc_master where accnt = @accnt
if @@rowcount = 0
begin
   select @ret=1,@msg = "�������ʺ� - %1 - ��Ӧ������"+@accnt
	goto gout
end
if isnull(substring(@foact,1,1),'') <> isnull(substring(@foact,2,1),'')
begin
   select @ret=1,@msg = "���˻��Ѿ�����λ��ת��, ����ɾ��"
	goto gout
end
if @lastinumb>0 and @cond_act = '1'
begin
   select @ret=1,@msg = "���˻��Ѿ���������, ����ɾ��"
	goto gout
end
if @bal<>0
begin
   select @ret=1,@msg = "���˻����<>0, ���� Ԥ��ȡ��/���� ���ܴ���"
	goto gout
end
if charindex(@sta,'WRCGI') = 0
begin
   select @ret=1,@msg = "ֻ��ȷ�ϴ����Ԥ������ס����ɾ��"
	goto gout
end
if exists(select 1 from sc_master_till where accnt=@accnt)
begin
   select @ret=1,@msg = "���ʻ��Ѿ�����ҹ����,����ɾ��"
	goto gout
end
if exists(select 1 from master where blkcode=@accnt)
begin
   select @ret=1,@msg = "��BLOCKǰ̨�Ѿ�ʹ��,����ɾ��"
	goto gout
end
if exists(select 1 from hmaster where blkcode=@accnt)
begin
   select @ret=1,@msg = "��BLOCKǰ̨�Ѿ�ʹ��,����ɾ��"
	goto gout
end
if exists(select 1 from account where accnt=@accnt and billno not like 'C%')
begin
   select @ret=1,@msg = "���ڷǳ������񣬲���ɾ��"
	goto gout
end

-- ���壺�ͷſͷ���Դ
if @ret=0 
	exec p_gds_reserve_release_block @accnt, @empno

-- delete record 
if @ret = 0
begin
	-- Turnaway 
	if @turnaway <> ''
	begin
		declare	@tid		int, @sid		char(10)
		exec p_GetAccnt1 'TUN', @sid output
		select @tid = convert(int, @sid)

		insert turnaway (id,sta,arr,days,type,rmnum,gstno,market,phone,reason,
				remark,haccnt,name,accnt,crtby,crttime,cby,changed) 
			select @tid,'T',a.arr,datediff(dd,a.arr,a.dep),a.type,a.rmnum,a.gstno,a.market,'',@turnaway,
				'Front Office Delete .',a.haccnt,b.haccnt,a.accnt,a.resby,isnull(a.restime,getdate()),a.cby,a.changed 
				from sc_master a, master_des b where a.accnt=b.accnt and a.accnt=@accnt
	end
	insert sc_master_del select * from sc_master where accnt=@accnt
   delete sc_master where accnt = @accnt
   delete account where accnt = @accnt
   delete subaccnt where accnt = @accnt
end

gout:
if @ret<>0 
   rollback tran p_gds_sc_master_delete_s1
commit tran

select @ret,@msg

return @ret
;

