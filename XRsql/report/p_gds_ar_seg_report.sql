
if object_id("p_gds_ar_seg_report") is not null
   drop proc p_gds_ar_seg_report
;
create  proc p_gds_ar_seg_report
	@begin			datetime,
	@end				datetime
as
-----------------------------------------------------------------------------
-- 区间 ar 账户分析
-----------------------------------------------------------------------------

-- temp table
create table #accnt(accnt char(10) not null)
create table #gout (
	accnt		char(10)					not null,
	name 		varchar(60)				null,
	name2 	varchar(60)				null,
	charge	money		default 0	not null,		-- 转账的借方
	credit	money		default 0	not null,		-- 转账的贷方
	ar1		money		default 0	not null,		-- 总转账
	co			money		default 0	not null,	 	-- co
	deposit	money		default 0	not null,	 	-- ar人员输入的定金
	ar2		money		default 0	not null			-- 余额
)
select * into #account from account where 1=2

-- get accnt# 
insert #accnt
	select distinct accnt from account where accnt like 'AR%' and bdate>=@begin and bdate<=@end
	union all 
	select distinct accnt from haccount where bdate>=@begin and bdate<=@end
insert #gout(accnt) select distinct accnt from #accnt

-- get account data 
insert #account 
	select * from  account where accnt like 'AR%' and bdate>=@begin and bdate<=@end
	union all 
	select * from  haccount where accnt like 'AR%' and bdate>=@begin and bdate<=@end

-- charge
update #gout set charge = isnull((select sum(a.charge) from #account a where #gout.accnt=a.accnt), 0)
update #gout set credit = isnull((select sum(a.credit) from #account a where #gout.accnt=a.accnt and a.accntof<>''), 0)
update #gout set co = isnull((select sum(a.credit) from #account a where #gout.accnt=a.accnt and a.accntof='' and a.billno<>''), 0)
update #gout set deposit = isnull((select sum(a.credit) from #account a where #gout.accnt=a.accnt and a.accntof='' and a.billno=''), 0)

-- name, bal 
update #gout set name=b.name, name2=b.name2 from master a, guest b 
	where #gout.accnt=a.accnt and a.haccnt=b.no
update #gout set name=b.name, name2=b.name2 from hmaster a, guest b 
	where #gout.accnt=a.accnt and a.haccnt=b.no
update #gout set ar1=charge - credit
update #gout set ar2=charge - credit - co - deposit

-- delete useless data 
delete #gout where charge=0 and credit=0 and co=0 and deposit=0

-- output
select * from #gout order by accnt

return
;
