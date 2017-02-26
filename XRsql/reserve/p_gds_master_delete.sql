if not exists(select 1 from sysoption where catalog='reserve' and item='master_del_cond_act')
	insert sysoption(catalog,item,value) values('reserve','master_del_cond_act','1')
;	-- 1 = �ϸ�����   0 = ����

if not exists(select 1 from sysoption where catalog='reserve' and item='master_del_cond_hour')
	insert sysoption(catalog,item,value) values('reserve','master_del_cond_hour','2')
;


IF OBJECT_ID('p_gds_master_delete') IS NOT NULL
    DROP PROCEDURE p_gds_master_delete
;
create proc p_gds_master_delete
   @accnt  char(10),
   @empno  char(10),
	@turnaway	char(1) = ''		-- �Ƿ���Ҫ���� turnaway 
as

--------------------------------------------------------------------
--	master delete.
--
--		���������������ʵ�ϸ���˵����ɾ�� account�����������δ���
--		��һ��˼·��ɾ����master ��һ��״̬��ʾ��Σ�����ҹ��������ʷ��
--------------------------------------------------------------------
declare
   @sta       	char(1),
   @lastinumb 	int,
   @ret       	int,
   @msg       	varchar(60),
	@bal			money,
	@groupno		char(10),
	@hour			int,
	@bdate		datetime,
	@class		char(1),
	@cond_hour	int,
	@cond_act	char(1),
	@extra		char(30) 

declare
	@lic_buy_1		varchar(255),
	@lic_buy_2		varchar(255),
	@nar				char(1)								-- �Ƿ�Ϊ��AR��

-- which ar system
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
if charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0
	select @nar = 'T'
else
	select @nar = 'F'

begin tran
save  tran p_gds_master_delete_s1

select @bdate = bdate1 from sysdata
select @ret = 0,@msg = ""
if @accnt like 'A%' and @nar='T' 
	update ar_master set sta = sta where accnt = @accnt
else
	update master set sta = sta where accnt = @accnt

-- delete cond ...
select @cond_act=substring(value,1,1) from sysoption where catalog='reserve' and item='master_del_cond_act'
if @cond_act is null select @cond_act='1'  -- ɾ���������ϸ��ԡ�1=�ȫ
select @cond_hour=convert(int, value) from sysoption where catalog='reserve' and item='master_del_cond_hour'
if @cond_hour is null select @cond_hour=2  -- ��סʱ�䲻�ܳ�����Сʱ

if @accnt like 'A%' and @nar='T' 
	select @class=class, @sta = sta, @bal = charge-credit , @lastinumb = lastinumb, @extra=extra from ar_master where accnt = @accnt
else
	select @class=class, @sta = sta, @bal = charge-credit , @lastinumb = lastinumb, @extra=extra from master where accnt = @accnt

if @@rowcount = 0
   select @ret=1,@msg = "�������ʺ� - %1 - ��Ӧ������"+@accnt
if @ret=0 and substring(@extra,1,1)='1' 
	select @ret=1,@msg = "�����ʻ�, ����ɾ��"
if @ret=0 and @lastinumb>0 and @cond_act = '1'
   select @ret=1,@msg = "���˻��Ѿ���������, ����ɾ��"
if @ret = 0 and @bal<>0
   select @ret=1,@msg = "���˻����<>0, ���� Ԥ��ȡ��/���� ���ܴ���"
if @ret = 0 and charindex(@sta,'RCGI') = 0
   select @ret=1,@msg = "ֻ��ȷ�ϴ����Ԥ������ס����ɾ��"
if @ret = 0 
begin
	if @accnt like 'A%' and @nar='T' 
	begin
		if exists(select 1 from ar_master_till where accnt=@accnt)
   		select @ret=1,@msg = "���ʻ��Ѿ�����ҹ����,����ɾ��"
	end
	else
	begin
		if exists(select 1 from master_till where accnt=@accnt)
   		select @ret=1,@msg = "���ʻ��Ѿ�����ҹ����,����ɾ��"
	end
end
if @ret = 0 and exists(select 1 from account where accnt=@accnt and billno not like 'C%')
   select @ret=1,@msg = "���ڷǳ������񣬲���ɾ��"
if @ret=0 and @class in ('F', 'M', 'G')
	begin
	select @hour = datediff(hh, arr, getdate()) from  master where accnt = @accnt and sta='I'
	if @hour >= @cond_hour
	   select @ret=1,@msg = "������סʱ�����, ����ɾ��"
	end
if @ret=0 and @class in ('M', 'G') and exists(select 1 from master where groupno=@accnt)
   select @ret=1,@msg = "���ȴ����Ա"

-- ɢ�ͣ��ͷſͷ���Դ
if @ret = 0 and @class='F'
begin
	select @groupno = groupno from master where accnt = @accnt
	if @groupno<>''
		update master set sta = sta where accnt = @groupno  -- LOCK 
	update master set sta = sta where accnt = @accnt
	if @sta = 'I'
		update master set sta ='O',dep=getdate() where  accnt = @accnt
	else
		update master set sta ='X' where  accnt = @accnt
	exec @ret = p_gds_reserve_chktprm @accnt,'2','',@empno,'',1,1,@msg output
	if @ret = 0
	begin
		update master set logmark=logmark+1,cby = @empno,changed = getdate() where  accnt = @accnt
		if @groupno<>''
			exec @ret = p_gds_maintain_group  @groupno,@empno,1,@msg output
	end
end

-- ���壺�ͷſͷ���Դ
if @ret=0 and @class in ('M', 'G')
	exec p_gds_reserve_release_block @accnt, @empno

-- delete record 
if @ret = 0
begin
	-- Turnaway 
	if @class in ('F', 'M', 'G') and @turnaway <> ''
	begin
		declare	@tid		int, @sid		char(10)
		exec p_GetAccnt1 'TUN', @sid output
		select @tid = convert(int, @sid)

		insert turnaway (id,sta,arr,days,type,rmnum,gstno,market,phone,reason,
				remark,haccnt,name,accnt,crtby,crttime,cby,changed) 
			select @tid,'T',a.arr,datediff(dd,a.arr,a.dep),a.type,a.rmnum,a.gstno,a.market,isnull(a.phone,''),@turnaway,
				'Front Office Delete .',a.haccnt,b.haccnt,a.accnt,a.resby,isnull(a.restime,getdate()),a.cby,a.changed 
				from master a, master_des b where a.accnt=b.accnt and a.accnt=@accnt
	end
	if @accnt like 'A%' and @nar='T' 
	begin
		insert ar_master_del select * from ar_master where accnt=@accnt
		delete ar_master where accnt = @accnt
	end 
	else
	begin
		insert master_del select * from master where accnt=@accnt
		delete master where accnt = @accnt
	end 

   delete account where accnt = @accnt
   delete subaccnt where accnt = @accnt
end
else
   rollback tran p_gds_master_delete_s1
commit tran

select @ret,@msg

return @ret
;

