
if exists(select * from sysobjects where name='p_gds_master_master_maint' and type ='P')
   drop proc p_gds_master_master_maint;
create proc p_gds_master_master_maint
as
-- ------------------------------------------------------------------------
-- 系统维护程序之 1 
--		master.master 有问题，导致单位的业绩计算错误 
-- 维护规则：如果某订单同住帐号master对应的订单的房号不等于该订单房号，
--           则把该订单同住帐号master设置为自己。 
-- ------------------------------------------------------------------------
create table #master (
	accnt		char(10)		not null,	-- 账号
	roomno1	char(5)		null,			-- 房号
	master	char(10)		null,			-- 同住信息
	roomno2	char(5)		null			-- 主账号房号 
)
-- get data -- 散客,有房号,master有差异 
insert #master 
	select accnt,roomno,master,'' from master where class='F' and roomno<>'' and accnt<>master
-- get data -- 获取主账号房号 
update #master set roomno2=a.roomno from master a where #master.master=a.accnt
if @@rowcount = 0 -- 可能同住的已经进入历史了 
	update #master set roomno2=a.roomno from hmaster a where #master.master=a.accnt
-- filter -- 删除正确有效的记录 
delete #master where roomno1=roomno2
-- adjust data
update master set master=master.accnt from #master a where master.accnt=a.accnt
--
drop table #master

-- ------------------------------------------------------------------------
-- 系统维护程序之 2
--			楼号纠正
-- ------------------------------------------------------------------------
create table #master1 (
	accnt		char(10)		not null,	-- 账号
	master	char(10)		not null,
	saccnt	char(10)		not null,
	hall1		char(1)		default ''	not null,
	hall2		char(1)		default ''	not null,
	hall3		char(1)		default ''	not null,
	extra		char(15)		default ''	not null,
	chg		char(1)		default 'F'	not null
)
declare	@hall 	char(1)
select @hall = min(substring(code,1,1)) from basecode where cat='hall'	-- 取得缺省的楼号 
insert #master1 select accnt,master,saccnt,substring(extra,2,1),'','',extra,'F' from master
-- 过滤 正确的记录 
delete #master1 where hall1 in (select code from basecode where cat='hall') 
-- 处理 saccnt='' 的记录 
update #master1 set extra=stuff(extra,2,1,@hall), chg='T' where saccnt='' 
update master set extra=a.extra from #master1 a where master.accnt=a.accnt and a.chg='T' 
delete #master1 where chg='T'
-- 处理 accnt=master 的记录 
update #master1 set extra=stuff(extra,2,1,@hall), chg='T' where accnt=master
update master set extra=a.extra from #master1 a where master.accnt=a.accnt and a.chg='T' 
delete #master1 where chg='T'
-- 处理 accnt<>master 的记录 
update #master1 set hall2=substring(a.extra,2,1) from master a where #master1.master=a.accnt 
update #master1 set extra=stuff(extra,2,1,hall2), chg='T' 
	where hall2<>'' and hall2 in (select code from basecode where cat='hall')
update master set extra=a.extra from #master1 a where master.accnt=a.accnt and a.chg='T' 
delete #master1 where chg='T'
-- 处理 剩余记录
if exists(select 1 from #master1)
begin
	update #master1 set extra=stuff(extra,2,1,@hall)
	update master set extra=a.extra from #master1 a where master.accnt=a.accnt
end
drop table #master1 

return 
;


