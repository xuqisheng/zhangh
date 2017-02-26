
if exists(select * from sysobjects where name='p_gds_master_master_maint' and type ='P')
   drop proc p_gds_master_master_maint;
create proc p_gds_master_master_maint
as
-- ------------------------------------------------------------------------
-- ϵͳά������֮ 1 
--		master.master �����⣬���µ�λ��ҵ��������� 
-- ά���������ĳ����ͬס�ʺ�master��Ӧ�Ķ����ķ��Ų����ڸö������ţ�
--           ��Ѹö���ͬס�ʺ�master����Ϊ�Լ��� 
-- ------------------------------------------------------------------------
create table #master (
	accnt		char(10)		not null,	-- �˺�
	roomno1	char(5)		null,			-- ����
	master	char(10)		null,			-- ͬס��Ϣ
	roomno2	char(5)		null			-- ���˺ŷ��� 
)
-- get data -- ɢ��,�з���,master�в��� 
insert #master 
	select accnt,roomno,master,'' from master where class='F' and roomno<>'' and accnt<>master
-- get data -- ��ȡ���˺ŷ��� 
update #master set roomno2=a.roomno from master a where #master.master=a.accnt
if @@rowcount = 0 -- ����ͬס���Ѿ�������ʷ�� 
	update #master set roomno2=a.roomno from hmaster a where #master.master=a.accnt
-- filter -- ɾ����ȷ��Ч�ļ�¼ 
delete #master where roomno1=roomno2
-- adjust data
update master set master=master.accnt from #master a where master.accnt=a.accnt
--
drop table #master

-- ------------------------------------------------------------------------
-- ϵͳά������֮ 2
--			¥�ž���
-- ------------------------------------------------------------------------
create table #master1 (
	accnt		char(10)		not null,	-- �˺�
	master	char(10)		not null,
	saccnt	char(10)		not null,
	hall1		char(1)		default ''	not null,
	hall2		char(1)		default ''	not null,
	hall3		char(1)		default ''	not null,
	extra		char(15)		default ''	not null,
	chg		char(1)		default 'F'	not null
)
declare	@hall 	char(1)
select @hall = min(substring(code,1,1)) from basecode where cat='hall'	-- ȡ��ȱʡ��¥�� 
insert #master1 select accnt,master,saccnt,substring(extra,2,1),'','',extra,'F' from master
-- ���� ��ȷ�ļ�¼ 
delete #master1 where hall1 in (select code from basecode where cat='hall') 
-- ���� saccnt='' �ļ�¼ 
update #master1 set extra=stuff(extra,2,1,@hall), chg='T' where saccnt='' 
update master set extra=a.extra from #master1 a where master.accnt=a.accnt and a.chg='T' 
delete #master1 where chg='T'
-- ���� accnt=master �ļ�¼ 
update #master1 set extra=stuff(extra,2,1,@hall), chg='T' where accnt=master
update master set extra=a.extra from #master1 a where master.accnt=a.accnt and a.chg='T' 
delete #master1 where chg='T'
-- ���� accnt<>master �ļ�¼ 
update #master1 set hall2=substring(a.extra,2,1) from master a where #master1.master=a.accnt 
update #master1 set extra=stuff(extra,2,1,hall2), chg='T' 
	where hall2<>'' and hall2 in (select code from basecode where cat='hall')
update master set extra=a.extra from #master1 a where master.accnt=a.accnt and a.chg='T' 
delete #master1 where chg='T'
-- ���� ʣ���¼
if exists(select 1 from #master1)
begin
	update #master1 set extra=stuff(extra,2,1,@hall)
	update master set extra=a.extra from #master1 a where master.accnt=a.accnt
end
drop table #master1 

return 
;


