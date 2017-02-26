IF OBJECT_ID('p_cqf_master_income_reb') IS NOT NULL
    DROP PROCEDURE p_cqf_master_income_reb
;
create proc p_cqf_master_income_reb
as
-----------------------------------------------------------------------
--	宾客消费结帐后统计
-----------------------------------------------------------------------
declare
	@class		char(1),
	@sta			char(1),
	@gstno		integer,
	@master		char(10),
	@rmpccode	char(5)

-- Begin ...
truncate table master_income

-- 计算房晚的费用码
declare	@rm_pccodes_nt	char(255), @rm_pccodes	char(255)
select @rm_pccodes_nt = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes_nt'), '')
select @rm_pccodes    = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes'), '')
select @rmpccode = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccode'), '000')

-- 数量方面的统计
insert master_income(accnt,master,item,amount2) select accnt,master,'I_TIMES',1 from hmaster where sta = 'O' and class not in ('C','A')
insert master_income(accnt,master,item,amount2) select accnt,master,'I_GUESTS',gstno from hmaster where sta = 'O' and gstno > 0 and class not in ('C','A')
insert master_income(accnt,master,item,amount2) select accnt,master,'X_TIMES',1 from hmaster where sta = 'X' and class not in ('C','A')
insert master_income(accnt,master,item,amount2) select accnt,master,'N_TIMES',1 from hmaster where sta = 'N' and class not in ('C','A')

-- 准备帐务数据 - 按照原始发生账户计算
create table #haccount
(
   accnt       char(10)                not null,
	master		char(10)                not null,
	pccode		char(10)						not null,
	quantity		money			default 0 	not null,
	charge		money			default 0 	not null,
	mode			char(10)						null,
	tofrom		char(2)		default ''	null,
	accntof		char(10)		default ''	null,
	chg			char(1)		default 'F' not null
)


insert #haccount
	select a.accnt,b.master, a.pccode, a.quantity, a.charge, a.mode, a.tofrom, a.accntof, 'F' from haccount a, hmaster b
		where a.accnt=b.accnt and a.tofrom=''
	union all
	select a.accnt, b.master, a.pccode, a.quantity, a.charge, a.mode, a.tofrom, a.accntof, 'F' from account a, hmaster b
		where a.accnt=b.accnt and a.tofrom=''




update #haccount set accnt = accntof, chg='T' where tofrom = '' and accntof<>''
update #haccount set master = a.master from hmaster a where #haccount.chg='T' and #haccount.accnt=a.accnt


delete #haccount where charge=0 and charindex(pccode,@rm_pccodes_nt)=0  -- 免费房的房晚要保留
delete #haccount where mode like ' pkg_%'   -- 去掉房包餐的影响

-- create summary data
insert master_income(accnt,master,pccode,item,amount1,amount2)
	select accnt,master,pccode,'',isnull(sum(charge),0),isnull(sum(quantity),0)
		from #haccount
			group by accnt,master,pccode
			order by accnt,master,pccode

update master_income set amount2=0                      -- 特别注意房晚数
	where pccode<>'' and charindex(pccode,@rm_pccodes)>0 and charindex(pccode,@rm_pccodes_nt)=0
delete master_income where amount1=0 and amount2=0

return 0
;