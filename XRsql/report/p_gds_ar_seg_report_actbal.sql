
if object_id("p_gds_ar_seg_report_actbal") is not null
   drop proc p_gds_ar_seg_report_actbal
;
create  proc p_gds_ar_seg_report_actbal
	@begin			datetime,
	@end				datetime
as
-----------------------------------------------------------------------------
-- 区间 ar 账户分析 -- from act_bal
-----------------------------------------------------------------------------

-- temp table
create table #gout (
	accnt		char(10)					not null,
	name 		varchar(60)				null,
	name2 	varchar(60)				null,
	artag1	varchar(3)				null,
	bal0		money		default 0	null,		-- 上期余额
	charge	money		default 0	null,		-- 转账的借方
	credit	money		default 0	null,		-- 转账的贷方
	bal		money		default 0	null,	 	-- 净额
	bal1		money		default 0	null		-- 本期余额
)

insert #gout(accnt, charge, credit) 
	select accnt, sum(day99), sum(cred99) from yact_bal 
		where accnt like 'A%' and date>=@begin and date<=@end 
			group by accnt

-- bal0, bal1, bal 
update #gout set bal0 = a.lastbl from yact_bal a where #gout.accnt=a.accnt and a.date=@begin
update #gout set bal1 = a.tillbl from yact_bal a where #gout.accnt=a.accnt and a.date=@end
update #gout set bal  = charge - credit

-- name, bal 
update #gout set name=b.name, name2=b.name2, artag1=a.artag1 from master a, guest b 
	where #gout.accnt=a.accnt and a.haccnt=b.no
update #gout set name=b.name, name2=b.name2, artag1=a.artag1 from hmaster a, guest b 
	where #gout.accnt=a.accnt and a.haccnt=b.no

-- delete useless data 
delete #gout where charge=0 and credit=0 and bal0=0 and bal1=0

-- output
select b.descript1, a.accnt, a.name, a.name2, a.bal0, a.charge, a.credit, a.bal, a.bal1 from #gout a, basecode b 
	where b.cat='artag1' and a.artag1*=b.code 
		order by b.sequence, b.code, a.accnt

return
;
