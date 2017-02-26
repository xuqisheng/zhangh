----------------------------------------------------------------------
--	报表：ar 账户历史月份余额平衡表
-- 我们以前的区间平衡表只能打印 40 天之内的，因为 yact_bal 只是保留了40天

-- 这个报表仅仅临时使用，嘱咐用户打印好了之后，需要删除，不能作为系统报表使用
----------------------------------------------------------------------

-----------------------------------
// 1. 
-----------------------------------
//if exists (select 1 from sysobjects where name = 'actbal_data' and type = 'U' )
//	drop table actbal_data;
//create table actbal_data
//(
//	id			char(6)			default ''		not null,
//	accnt		char(10)								not null,
//	bdate		datetime								not null,
//	charge	money				default 0		not null,
//	credit	money				default 0		not null
//);
//create index index1 on actbal_data(accnt, id, bdate);
//
-----------------------------------
// 2. 
-----------------------------------
//truncate table actbal_data;
//insert actbal_data select '', accnt, bdate, charge, credit from account where accnt like 'A%';
//insert actbal_data select '', accnt, bdate, charge, credit from haccount where accnt like 'A%';
//update actbal_data set actbal_data.id = convert(char(4),a.year) + right('00'+rtrim(ltrim(convert(char(2),a.month))), 2)
//	from firstdays a 
//	where actbal_data.bdate>=a.firstday and actbal_data.bdate<=a.lastday
//;
//
//select * from actbal_data order by id, accnt, bdate;
//


-----------------------------------
// 3. 
-----------------------------------
//if exists (select 1 from sysobjects where name = 'actbal_output' and type = 'U' )
//	drop table actbal_output;
//create table actbal_output
//(
//	id			char(6)			default ''		not null,
//	accnt		char(10)								not null,
//	artag1	char(1)			default ''		null,
//	name		varchar(50)		default ''		null,
//	name2		varchar(50)		default ''		null,
//	lbal		money				default 0		not null,
//	charge	money				default 0		not null,
//	credit	money				default 0		not null,
//	bal		money				default 0		not null
//);
//create unique index index1 on actbal_output(id, accnt);
//

-----------------------------------
// 4. 
-----------------------------------
//if object_id("p_gds_actbal_report_temp") is not null
//   drop proc p_gds_actbal_report_temp;
//create  proc p_gds_actbal_report_temp
//as
//
//truncate table actbal_output
//
//insert actbal_output(id, accnt, charge, credit) 
//	select id, accnt, isnull(sum(charge),0), isnull(sum(credit),0) from actbal_data
//			group by id, accnt
//
//-- id & accnt  -->>> 这部特别注意，小心漏掉; 
//-- 比如：一个帐务6月、8月都有帐务，7月没有，此时也要注意插入；
//create table #id (id	char(6) not null)
//insert #id select distinct id from actbal_output
//create table #accnt (accnt	char(10) not null)
//insert #accnt select distinct accnt from actbal_output
//insert actbal_output(id, accnt) 
//	select a.id, b.accnt from #id a, #accnt b 
//		where not exists(select 1 from actbal_output c where c.id=a.id and c.accnt=b.accnt)
//
//-- bal
//update actbal_output set bal = isnull((select sum(a.charge-a.credit) from actbal_output a 
//		where actbal_output.accnt=a.accnt and a.id<=actbal_output.id), 0)
//update actbal_output set lbal  = bal - (charge - credit)
//
//-- name, artag1
//update actbal_output set name=b.name, name2=b.name2, artag1=a.artag1 from master a, guest b 
//	where actbal_output.accnt=a.accnt and a.haccnt=b.no
//update actbal_output set name=b.name, name2=b.name2, artag1=a.artag1 from hmaster a, guest b 
//	where actbal_output.accnt=a.accnt and a.haccnt=b.no
//
//-- delete useless data 
//delete actbal_output where charge=0 and credit=0 and lbal=0 and bal=0
//
//
//return
//;
//
-----------------------------------
// 4. 
-----------------------------------
//exec p_gds_actbal_report_temp;

//select * from actbal_output order by accnt,  id ;
