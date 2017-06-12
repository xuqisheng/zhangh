drop proc p_hui_audit_act_bal;
create proc p_hui_audit_act_bal
	@bdate		datetime
as
-----------------------------------------------------------------------------
--	   每日AR账发生额(分类显示)
--		需AR账审核后才能准确统计

-----------------------------------------------------------------------------
truncate table act_bal
/*
create table #act_bal
(
    date       datetime    NOT NULL,
    accnt      char(7)     NOT NULL,
    name       varchar(50) DEFAULT '' NULL,
    rm         money       DEFAULT 0 NOT NULL,	--房费
    fb         money       DEFAULT 0 NOT NULL,	--餐饮
    mt         money       DEFAULT 0 NOT NULL,	--会议
    en         money       DEFAULT 0 NOT NULL,	--康乐
    sp         money       DEFAULT 0 NOT NULL,	--商场
    dot        money       DEFAULT 0 NOT NULL,	--其它
    dtl        money       DEFAULT 0 NOT NULL,	--总和
    lastbl     money       DEFAULT 0 NOT NULL,	--上日余额
    tillbl     money       DEFAULT 0 NOT NULL	--本日余额
)
CREATE UNIQUE NONCLUSTERED INDEX index1 ON #act_bal(accnt)
*/
-- 插入帐户
insert act_bal
	select date,accnt,name,rm,fb,mt,en,sp,dot,dtl,lastbl,tillbl from ycus_xf
		where date = @bdate and accnt like 'AR%'

-- 临时帐务表
create table #account(
	accnt 		char(10)					not null,
	pccode		char(5)					not null,
	deptno		char(5)	default ''	not null,
	charge		money		default 0	not null
)

insert #account
	select a.ar_accnt,a.pccode,'',a.charge from ar_account a,pccode b where a.pccode=b.pccode and a.bdate = @bdate and a.pccode<'9'

update #account set deptno=a.deptno7 from pccode a where #account.pccode=a.pccode

-- 采集数据
update act_bal set rm = 	isnull((select sum(a.charge) from #account a where act_bal.accnt = a.accnt and a.deptno like 'rm%'),0)
update act_bal set fb = 	isnull((select sum(a.charge) from #account a where act_bal.accnt = a.accnt and a.deptno = 'fb'),0)
update act_bal set mt = 	isnull((select sum(a.charge) from #account a where act_bal.accnt = a.accnt and a.deptno = 'mt'),0)
update act_bal set en = 	isnull((select sum(a.charge) from #account a where act_bal.accnt = a.accnt and a.deptno = 'en'),0)
update act_bal set sp = 	isnull((select sum(a.charge) from #account a where act_bal.accnt = a.accnt and a.deptno = 'sp'),0)
update act_bal set dot = 	isnull((select sum(a.charge) from #account a where act_bal.accnt = a.accnt and a.deptno not like 'rm%' and a.deptno not in ('fb','mt','en','sp')),0)

select accnt,name,rm,fb,mt,en,dot,dtl,lastbl,tillbl from act_bal where dtl<>0 order by accnt
;
/*
declare c_accnt cursor for select a.bdate,a.ar_accnt,a.charge,b.deptno7 from ar_account a,pccode b where a.pccode=b.pccode order by a.ar_accnt
open c_accnt
fetch c_accnt into @bdate,@ar_accnt,@charge,@deptno7
while @@sqlstatus = 0
	begin


		fetch c_accnt into @bdate,@ar_accnt,@charge,@deptno7
	end
close c_accnt
deallocate cursor c_accnt
*/