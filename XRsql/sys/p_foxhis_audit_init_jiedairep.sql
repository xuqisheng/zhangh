IF OBJECT_ID('p_foxhis_audit_init_jiedairep') IS NOT NULL
    DROP PROCEDURE p_foxhis_audit_init_jiedairep;
create proc p_foxhis_audit_init_jiedairep
as

-------------------------------------------------------------------
--	系统主要夜审报表的初始化
-------------------------------------------------------------------

-- bdate
declare @bdate datetime
select @bdate = dateadd(day,-1,bdate1) from sysdata

-- jierep, yjierep
update jierep set date = @bdate,day01=0,day02=0,day03=0,day04=0,day05=0,day06=0,day07=0,day08=0,day09=0,day99=0
update jierep set month01=0,month02=0,month03=0,month04=0,month05=0,month06=0,month07=0,month08=0,month09=0,month99=0
truncate table yjierep

-- dairep, ydairep 
truncate table dairep
truncate table ydairep

-- jiedai, yjiedai 
truncate table jiedai
truncate table yjiedai 

-- jourrep, yjourrep
update jourrep set date = @bdate,day=0,month=0,year=0,pmonth=0,pyear=0,lmonth=0,lyear=0, 
	day_rebate=0, month_rebate=0, year_rebate=0
truncate table yjourrep

-- njourrep, ynjourrep
update njourrep set date = @bdate,day=0,month=0,year=0,pmonth=0,pyear=0,lmonth=0,lyear=0
truncate table ynjourrep

-- bjourrep, ybjourrep
truncate table bjourrep
truncate table ybjourrep

-- audit_impdata, yaudit_impdata 
update audit_impdata set date=@bdate, amount=0, amount_m=0, amount_y=0
truncate table yaudit_impdata

truncate table manager_report
truncate table ymanager_report
insert into manager_report select @bdate,a.class,b.code,0,0,0,'' from audit_impdata a,gtype b
--增加空记录用于存放非住客的费用
insert into manager_report select @bdate,'fbrev','',0,0,0,'extra'
insert into manager_report select @bdate,'otrev','',0,0,0,'extra'
insert into manager_report select @bdate,'total','',0,0,0,'extra'
insert into manager_report select @bdate,'payment','',0,0,0,'extra'

-- trial_balance, ytrial_balance 
--truncate table trial_balance
delete from trial_balance  where (type='20' and code not in (' #','{{{{{'))
                                 or (type='30' and code not in (' #','{{{{{')) 
                                 or (type='40' and code not in (' #','{{{{{'))

update trial_balance set day=0,month=0,year=0
truncate table ytrial_balance

return 0
;

