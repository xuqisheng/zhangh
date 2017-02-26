
IF OBJECT_ID('p_gds_master_income') IS NOT NULL
    DROP PROCEDURE p_gds_master_income
;
create proc p_gds_master_income
	@accnt		char(10),
	@mode			char(1) = ''		-- R:强制性的要重新作
as
-----------------------------------------------------------------------
--	宾客消费结帐后统计 - 单个客户 master_income 
-----------------------------------------------------------------------
declare
	@class		char(1),
	@sta			char(1),
	@gstno		integer,
	@master		char(10),
	@rmpccode	char(5)

select @rmpccode = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccode'), '000')

-- Begin ...
if @mode = 'R'
	delete master_income where accnt=@accnt

if exists(select 1 from master_income where accnt=@accnt)
	return 0

select @master=master, @sta=sta, @class=class, @gstno=gstno from hmaster where accnt = @accnt
if @@rowcount = 0
	return 0

-- 消费帐、应收帐 不参与统计
if @class in ('C', 'A') 
	return 0

-- 计算房晚的费用码
declare	@rm_pccodes_nt	char(255), @rm_pccodes	char(255)
select @rm_pccodes_nt = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes_nt'), '')
select @rm_pccodes    = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes'), '')

-- 数量方面的统计
if @sta='O'
begin
	insert master_income(accnt,master,item,amount2) values (@accnt,@master,'I_TIMES',1)
	if @gstno>0
		insert master_income(accnt,master,item,amount2) values (@accnt,@master,'I_GUESTS',@gstno)
end
else if @sta='X'
	insert master_income(accnt,master,item,amount2) values (@accnt,@master,'X_TIMES',1)
else if @sta='N'
	insert master_income(accnt,master,item,amount2) values (@accnt,@master,'N_TIMES',1)

-- 准备帐务数据 - 按照原始发生账户计算
create table #haccount
(
	pccode		char(5)						not null,
	quantity		money			default 0 	not null,
	charge		money			default 0 	not null,
	mode			char(10)						null,
	tofrom		char(2)		default ''	null,
	accntof		char(10)		default ''	null,
	accnt			char(10)		default ''	null
)
insert #haccount 
	select pccode, quantity, charge, mode, tofrom, accntof, accnt 
		from haccount where accnt = @accnt 
	union all
	select pccode, quantity, charge, mode, tofrom, '', accntof 
		from haccount where tofrom='' and accntof = @accnt 
	union all
	select pccode, quantity, charge, mode, tofrom, accntof, accnt 
		from account where accnt = @accnt 
	union all
	select pccode, quantity, charge, mode, tofrom, '', accntof 
		from account where tofrom='' and accntof = @accnt 

delete #haccount where tofrom <> ''														-- 排除按行转帐干扰
							or accntof <> ''													-- 排除自动转帐
							or charge=0 and charindex(pccode,@rm_pccodes_nt)=0		-- 免费房的房晚要保留 
							or mode like ' pkg_%'   										-- 去掉房包餐的影响； 

-- create summary data
select * into #master_income from master_income where 1=2
insert #master_income(accnt,master,pccode,item,amount1,amount2)
	select @accnt,@master,pccode,'',isnull(sum(charge),0),isnull(sum(quantity),0) 
		from #haccount group by pccode order by pccode
update #master_income set amount2=0                      -- 特别注意房晚数
	where pccode<>'' and charindex(pccode,@rm_pccodes)>0 and charindex(pccode,@rm_pccodes_nt)=0
delete #master_income where amount1=0 and amount2=0

-- save data 
insert master_income select * from #master_income

return 0
;


