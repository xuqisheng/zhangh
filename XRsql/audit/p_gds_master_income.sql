
IF OBJECT_ID('p_gds_master_income') IS NOT NULL
    DROP PROCEDURE p_gds_master_income
;
create proc p_gds_master_income
	@accnt		char(10),
	@mode			char(1) = ''		-- R:ǿ���Ե�Ҫ������
as
-----------------------------------------------------------------------
--	�������ѽ��ʺ�ͳ�� - �����ͻ� master_income 
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

-- �����ʡ�Ӧ���� ������ͳ��
if @class in ('C', 'A') 
	return 0

-- ���㷿��ķ�����
declare	@rm_pccodes_nt	char(255), @rm_pccodes	char(255)
select @rm_pccodes_nt = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes_nt'), '')
select @rm_pccodes    = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes'), '')

-- ���������ͳ��
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

-- ׼���������� - ����ԭʼ�����˻�����
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

delete #haccount where tofrom <> ''														-- �ų�����ת�ʸ���
							or accntof <> ''													-- �ų��Զ�ת��
							or charge=0 and charindex(pccode,@rm_pccodes_nt)=0		-- ��ѷ��ķ���Ҫ���� 
							or mode like ' pkg_%'   										-- ȥ�������͵�Ӱ�죻 

-- create summary data
select * into #master_income from master_income where 1=2
insert #master_income(accnt,master,pccode,item,amount1,amount2)
	select @accnt,@master,pccode,'',isnull(sum(charge),0),isnull(sum(quantity),0) 
		from #haccount group by pccode order by pccode
update #master_income set amount2=0                      -- �ر�ע�ⷿ����
	where pccode<>'' and charindex(pccode,@rm_pccodes)>0 and charindex(pccode,@rm_pccodes_nt)=0
delete #master_income where amount1=0 and amount2=0

-- save data 
insert master_income select * from #master_income

return 0
;


