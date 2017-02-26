if exists(select 1 from sysobjects where name = 'p_cyj_audit_build_act_remark' and type = 'P')
	drop proc p_cyj_audit_build_act_remark;
create proc p_cyj_audit_build_act_remark
	@date					datetime,
	@accnt				char(10)
as
--------------------------------------------------------------------------------------------------
--
--		准备前台帐务查询数据以备审核
--																												2003/10/24 cyj				
--------------------------------------------------------------------------------------------------

declare
	@bdate				datetime

select @bdate = bdate from sysdata

select * into #account_temp from account where 1=2
insert into #account_temp

select distinct * from account where bdate = @date
union 
select  * from account where accnt = @accnt
union
select  * from haccount where bdate = @date
union 
select  * from haccount where accnt = @accnt

-- // 2 日前的审核备注已经倒入ah_hremark
if datediff(day, @date, @bdate) > 1
	select auaccnt,aunumber, nempno,ndate,ncheck,nremark,dempno,ddate,dcheck,dremark,roomno, accnt, number, inumber, empno, shift, log_date, date, char32  =  ref+ref1+ref2, char10  =  isnull(rtrim(tofrom),  '--')+accntof, crradjt, waiter, charge, credit, billno, ref, ref1, ref2, pccode, bdate, accntof
		from #account_temp ,au_hremark 
		where accnt = auaccnt and number=aunumber and au_hremark.type ='act'
else
	select auaccnt,aunumber, nempno,ndate,ncheck,nremark,dempno,ddate,dcheck,dremark,roomno, accnt, number, inumber, empno, shift, log_date, date, char32  =  ref+ref1+ref2, char10  =  isnull(rtrim(tofrom),  '--')+accntof, crradjt, waiter, charge, credit, billno, ref, ref1, ref2, pccode, bdate, accntof
		from #account_temp ,au_remark 
		where accnt = auaccnt and number=aunumber and au_remark.type ='act'
;
