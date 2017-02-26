if exists(select * from sysobjects where name = "p_gds_master_ar_subaccnt")
	drop proc p_gds_master_ar_subaccnt;
create proc p_gds_master_ar_subaccnt
	@accnt		char(10),
   @empno      char(10)
as

-- -----------------------------------------------------------------------
-- master(AR) ���˺�ά�� -- �˳�����Ҫ���� vipcard, argst �Ĵ����������У�
-- -----------------------------------------------------------------------
--
--	���˺���Դ��	1��ǩ����	-- argst
--						2�������	-- vipcard  ---> ��ʱ������ 2004/11 gds
--
--		ע�� �� ��������պ�ָ��ĳ��ǩ����ʱ����Ҫ�ظ��������˺� ? - ��ʱ���� !
-- -----------------------------------------------------------------------

declare
	@ret			integer,
	@msg			varchar(60),
	@ref			varchar(80),
	@no			char(7),
	@name			varchar(50),
	@subaccnt	integer,
	@lic_buy_1	varchar(255),
	@lic_buy_2	varchar(255)

select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
----------------
--	�������
----------------
if charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0
	begin
	
	if not exists(select 1 from ar_master where class='A' and accnt=@accnt)
		return 1
	-- �������
	if not exists(select 1 from subaccnt where accnt=@accnt and subaccnt=1 and type='0')
		insert subaccnt (accnt,subaccnt,name,pccodes,starting_time,closing_time,cby,changed,type,tag)
			select accnt, 1, '������˷���', '*', '2000.1.1', '2030.1.1', @empno, getdate(), '0', '0'
				from ar_master where accnt = @accnt
	-- ���˻�
	if not exists(select 1 from subaccnt where accnt=@accnt and subaccnt=1 and type='5')
		insert subaccnt (accnt,subaccnt,name,pccodes,starting_time,closing_time,cby,changed,type,tag)
			select a.accnt, 1, b.name, '*', '2000.1.1', '2030.1.1', @empno, getdate(), '5', '0'
				from ar_master a, guest b where a.accnt = @accnt and a.haccnt=b.no
	end
else
	begin
	
	if not exists(select 1 from master where class='A' and accnt=@accnt)
		return 1
	-- �������
	if not exists(select 1 from subaccnt where accnt=@accnt and subaccnt=1 and type='0')
		insert subaccnt (accnt,subaccnt,name,pccodes,starting_time,closing_time,cby,changed,type,tag)
			select accnt, 1, '������˷���', '*', '2000.1.1', '2030.1.1', @empno, getdate(), '0', '0'
				from master where accnt = @accnt
	-- ���˻�
	if not exists(select 1 from subaccnt where accnt=@accnt and subaccnt=1 and type='5')
		insert subaccnt (accnt,subaccnt,name,pccodes,starting_time,closing_time,cby,changed,type,tag)
			select a.accnt, 1, b.name, '*', '2000.1.1', '2030.1.1', @empno, getdate(), '5', '0'
				from master a, guest b where a.accnt = @accnt and a.haccnt=b.no
	end

----------------
--	ǩ����
----------------
declare c_guest cursor for
	select a.no, b.name from argst a, guest b where a.no=b.no and a.accnt = @accnt and a.tag2='T' order by a.no
open  c_guest
fetch c_guest into @no, @name 
while @@sqlstatus = 0
	begin
	if not exists (select 1 from subaccnt where type = '5' and accnt = @accnt and haccnt = @no)
		begin
		select @subaccnt = max(subaccnt) from subaccnt where type = '5' and accnt = @accnt
		select @subaccnt = isnull(@subaccnt, 0) + 1
		insert subaccnt (haccnt,accnt,subaccnt,name,pccodes,starting_time,closing_time,cby,changed,type,tag)
			values(@no, @accnt, @subaccnt,@name, '*', '2000.1.1', '2030.1.1', @empno, getdate(), '5', '0')
		end
	else	-- Update Name
		update subaccnt set name=@name where type='5' and accnt=@accnt and haccnt=@no 

	fetch c_guest into @no, @name
	end
close c_guest
deallocate cursor c_guest

----------------
--	�����
----------------
--declare c_vipcard cursor for select a.no, b.name from vipcard a, guest b 
--	where a.araccnt1 = @accnt and a.kno=b.no order by a.no
--open  c_vipcard
--fetch c_vipcard into @no, @name
--while @@sqlstatus = 0
--begin
--	if not exists (select 1 from subaccnt where type = '5' and accnt = @accnt and haccnt = @no)
--	begin
--		select @subaccnt = max(subaccnt) from subaccnt where type = '5' and accnt = @accnt
--		select @subaccnt = isnull(@subaccnt, 0) + 1
--		insert subaccnt (haccnt,accnt,subaccnt,name,pccodes,starting_time,closing_time,cby,changed,type,tag)
--			values(@no, @accnt, @subaccnt,@name, '*', '2000.1.1', '2030.1.1', @empno, getdate(), '5', '0')
--	end
--	else	-- Update Name
--		update subaccnt set name=@name where type='5' and accnt=@accnt and haccnt=@no 
--
--	fetch c_vipcard into @no, @name
--end
--close c_vipcard
--deallocate cursor c_vipcard

------------------------------------------------------------------------------------------------
--	ɾ�����÷��˺� -- ����ɾ���ˣ�����ע�� type��ͬʱ�����ڲ��ֽ��˿����Ƚ��� haccnt 
------------------------------------------------------------------------------------------------
--ǩ���˷��ʻ� : û�������ֱ��ɾ��
delete subaccnt where accnt = @accnt and type='5' and haccnt<>'' 
	and substring(haccnt,1,1)<>'K'
	and haccnt not in (select a.no from argst a where a.accnt = @accnt and a.tag2='T')
	and subaccnt not in (select distinct b.subaccnt from account b where b.accnt = @accnt)
--ǩ���˷��ʻ� : ������ķ����������
update subaccnt set pccodes='.' where accnt = @accnt and type='5' and haccnt<>'' 
	and substring(haccnt,1,1)<>'K'
	and haccnt not in (select a.no from argst a where a.accnt = @accnt and a.tag2='T')

--delete subaccnt where accnt = @accnt
--	and substring(haccnt,1,1)='K'
--	and haccnt not in (select a.no from vipcard a where a.araccnt1 = @accnt)
--	and subaccnt not in (select distinct b.subaccnt from account b where b.accnt = @accnt)

return 0
;


if exists(select * from sysobjects where name = "p_gds_master_ar_subaccnt_reb")
	drop proc p_gds_master_ar_subaccnt_reb;
create proc p_gds_master_ar_subaccnt_reb
as
--------------------------------
--	Rebuild AR subaccnt 
--------------------------------

declare	@accnt		char(10)

-- for Old AR
declare c_armst cursor for select accnt from master where class='A' order by accnt
open  c_armst
fetch c_armst into @accnt
while @@sqlstatus = 0
begin
	exec p_gds_master_ar_subaccnt @accnt, 'FOX'
	fetch c_armst into @accnt
end
close c_armst
deallocate cursor c_armst

-- for New AR
declare c_armst1 cursor for select accnt from ar_master where class='A' order by accnt
open  c_armst1
fetch c_armst1 into @accnt
while @@sqlstatus = 0
begin
	exec p_gds_master_ar_subaccnt @accnt, 'FOX'
	fetch c_armst1 into @accnt
end
close c_armst1
deallocate cursor c_armst1

;
