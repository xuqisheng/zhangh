
if exists(select * from sysobjects where name='p_gds_hmaster_master_maint' and type ='P')
   drop proc p_gds_hmaster_master_maint;
create proc p_gds_hmaster_master_maint
as
-- ------------------------------------------------------------------------
-- 系统维护程序之 hmaster.master 有问题，导致单位的业绩计算错误 
-- ------------------------------------------------------------------------
create table #hmaster (
	accnt		char(10)		not null,
	roomno1	char(5)		null,
	master	char(10)		null,
	roomno2	char(5)		null
)
create index index1 on #hmaster(accnt)

-- get data
insert #hmaster 
	select accnt,roomno,master,'' from hmaster where class='F' and sta='O' and accnt<>master
update #hmaster set roomno2=a.roomno from hmaster a where #hmaster.master=a.accnt

-- filter
delete #hmaster where roomno1=roomno2

-- adjust data
update master_income set master=master_income.accnt from #hmaster a where master_income.accnt=a.accnt
update hmaster set master=hmaster.accnt from #hmaster a where hmaster.accnt=a.accnt

-- get profile  -- 只需要得到单位档案，个人的业绩不受影响
create table #profile (no   char(7) )
insert #profile 
	select a.cusno from hmaster a, #hmaster b where a.accnt=b.accnt and cusno <> ''
	union select a.agent from hmaster a, #hmaster b where a.accnt=b.accnt and agent <> ''
	union select a.source from hmaster a, #hmaster b where a.accnt=b.accnt and source <> ''

-- profile income reb
declare @no  char(7)
declare	c_guest cursor for select distinct no from #profile
open c_guest
fetch c_guest into @no
while @@sqlstatus = 0
begin
	exec p_gds_guest_income_reb @no
	fetch c_guest into @no
end
close c_guest
deallocate cursor c_guest
--
--
drop table #hmaster
drop table #profile

return 
;
