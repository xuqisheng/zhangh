if exists (select * from sysobjects where name ='p_gds_nar_check_bal' and type ='P')
	drop proc p_gds_nar_check_bal;
create proc p_gds_nar_check_bal
	@accnt	char(10) 
as
declare	@number1 int, @number2 int, @amount1 money, @amount2 money 
create table #tor
(
	accnt					char(10),
	number				integer
)
select * into #account from ar_account where 1 = 2

-- 余额表统计 
delete #account 
insert #account select * from ar_account where ar_accnt = @accnt
insert #tor select distinct ar_accnt, ar_pnumber from #account where ar_pnumber <> 0
delete #account from #tor a where #account.ar_accnt = a.accnt and #account.ar_number = a.number
delete #account where (charge = charge9 and credit = credit9) or ar_subtotal = 'T'
update #account set date = a.date from ar_detail a where #account.ar_accnt = a.accnt and #account.ar_number = a.number
select @number1=count(1), @amount1=sum((charge-charge9)-(credit-credit9)) from #account // 不包含核销部分 

//select sum(charge-credit) from #account where (charge = charge9 and credit = credit9) //or ar_subtotal = 'T'
//select charge,credit,charge9,credit9 from  #account where (charge = charge9 and credit = credit9) 
//select charge,credit,charge9,credit9 from  #account where ar_subtotal = 'T'
//delete #account where ar_subtotal = 'T'
//select @number1=count(1), @amount1=sum(charge-credit) from #account // 包含核销部分 

-- 往来业务统计 
delete #account 
insert #account select * from ar_account where ar_accnt = @accnt
	union all select * from har_account where ar_accnt = @accnt
delete #account where ar_subtotal = 'T' or ar_tag in ('Z', 'z')
select @number2=count(1), @amount2=sum(charge-credit) from #account 

drop table #account 
select @number1, aging=@amount1, @number2, inout=@amount2, error=@amount1-@amount2 
return 0
;


//exec p_gds_nar_check_bal 'AR00000'; 
exec p_gds_nar_check_bal 'AR00002'; 

