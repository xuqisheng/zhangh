if exists(select 1 from sysobjects where name = 'p_cyj_pos_audittotal' and type ='P')
	drop  proc p_cyj_pos_audittotal;
create proc p_cyj_pos_audittotal
	@empno			char(30),
	@shift			char(1)
as
------------------------------------------------------------------------------------------------
--
-- ������ˣ��������ݻ��ܱ�
-- ���������ᵥ������������������Ʒ���������ۿۡ������ȫ�⡢�������������տ�������ӡ�˵�����
--
------------------------------------------------------------------------------------------------
declare
	@amount				money,
	@code					char(5),
	@codes				char(60),
	@ccode				char(5),
	@sta					char(1),
	@vpos					int,
	@descript			char(30),
	@bdate				datetime
	
create table #list(
	menus			int default 0,        --������
	checks		int default 0,        --�ᵥ��
	cancels		int default 0,        --������
	d_cancels	int default 0,        --������Ʒ��
	d_dscs		int default 0,        --�����ۿ���
	d_ents		int default 0,        --���˿����
	d_nofees		int default 0,        --ȫ����
	d_rewards	int default 0,        --������
	menud			money default 0,      --�������
	checkd		money default 0,      --�ᵥ���
	canceld		money default 0,      --�������
	d_canceld	money default 0,      --������Ʒ���
	d_dscd		money default 0,      --�����ۿ۽��
	d_entd		money default 0,      --���˿�����
	d_nofeed		money default 0,      --ȫ����
	d_rewardd	money default 0,      --���ͽ��
	bills			money default 0,      --��ӡ�˵���
	pay1s			char(30) default '',	-- ��������1
	pay1d			money default 0,		-- ������1
	pay2s			char(30) default '',	-- ��������2
	pay2d			money default 0,		-- ������2
	pay3s			char(30) default '',	-- ��������3
	pay3d			money default 0,		-- ������3
	pay4s			char(30) default '',	-- ��������4
	pay4d			money default 0,		-- ������4
	pay5s			char(30) default '',	-- ��������5
	pay5d			money default 0,		-- ������5
	pay6s			char(30) default '',	-- ��������6
	pay6d			money default 0,		-- ������6
	pay7s			char(30) default '',	-- ��������7
	pay7d			money default 0,		-- ������7
	pay8s			char(30) default '',	-- ��������8
	pay8d			money default 0,		-- ������8
	pay9s			char(30) default '',	-- ��������9
	pay9d			money default 0		-- ������9
)
create table #pay(
	paycode		char(5),
	descript		char(30),
	sta			char(1),
	amount		money
)
select @bdate = bdate from sysdata
insert into #pay select a.paycode,b.descript,a.sta,sum(a.amount) from pos_pay a, pccode b 
where a.paycode=b.pccode and a.crradjt ='NR' and empno=@empno and (shift=@shift or @shift='') and bdate=@bdate
group by paycode,b.descript,sta
order by paycode,b.descript,sta

insert into #list(menus) select 0
update #list set menus = (select count(1) from pos_menu where empno3=@empno and sta<>'7' and (shift=@shift or @shift=''))
update #list set checks = (select count(1) from pos_menu where empno3=@empno and sta='3' and (shift=@shift or @shift=''))
update #list set cancels = (select count(1) from pos_menu where empno3=@empno and sta='7' and (shift=@shift or @shift=''))
update #list set d_cancels = (select count(1) from pos_dish a, pos_menu b where a.menu=b.menu and a.empno3=@empno and a.sta='2' and (b.shift=@shift or @shift=''))
update #list set d_dscs = (select count(1) from pos_dish a, pos_menu b where a.menu=b.menu and a.empno3=@empno and a.sta='7' and (b.shift=@shift or @shift=''))
update #list set d_ents = (select count(1) from pos_dish a, pos_menu b where a.menu=b.menu and a.empno3=@empno and a.special='E' and (b.shift=@shift or @shift='')) 
update #list set d_rewards = (select count(1) from pos_dish a, pos_menu b where a.menu=b.menu and a.empno3=@empno and a.sta='3' and (b.shift=@shift or @shift=''))
update #list set d_nofees = (select count(1) from pos_dish a, pos_menu b where a.menu=b.menu and a.empno3=@empno and a.sta='5' and (b.shift=@shift or @shift=''))
update #list set menud = (select sum(amount) from pos_menu where empno3=@empno and (shift=@shift or @shift=''))
update #list set checkd = (select sum(amount) from pos_menu where empno3=@empno and (shift=@shift or @shift='') and sta='3' )
update #list set d_canceld = isnull((select sum(a.amount - a.dsc + a.srv + a.tax) from pos_dish a, pos_menu b where a.menu=b.menu and a.empno3=@empno and a.sta='2' and (b.shift=@shift or @shift='')), 0)
update #list set d_dscd =  isnull((select sum(a.dsc) from pos_dish a, pos_menu b where a.menu=b.menu and a.empno3=@empno and a.sta='7' and (b.shift=@shift or @shift='')), 0)
update #list set d_entd =  isnull((select sum(a.amount - a.dsc + a.srv + a.tax) from pos_dish a, pos_menu b where a.menu=b.menu and a.empno3=@empno and a.special='E' and (b.shift=@shift or @shift='')) , 0)
update #list set d_rewardd =  isnull((select sum(a.dsc) from pos_dish a, pos_menu b where a.menu=b.menu and a.empno3=@empno and a.sta='3' and (b.shift=@shift or @shift='')), 0)
update #list set d_nofeed =  isnull((select sum(a.dsc) from pos_dish a, pos_menu b where a.menu=b.menu and a.empno3=@empno and a.sta='5' and (b.shift=@shift or @shift='')), 0)
update #list set bills =  isnull((select count(1) from in_allprint where (printtype ='pbill' or printtype ='pcheck') and empno=@empno and (shift=@shift or @shift='')), 0)

declare c_code cursor for select paycode from #pay order by sta,descript,paycode
open c_code
fetch c_code into @code
while @@sqlstatus = 0
	begin
	select @codes = substring(@code+space(5), 1, 5)+ '#' + @codes
	fetch c_code into @code
	end
close c_code
deallocate cursor c_code
declare c_paycode cursor for select a.paycode, a.descript,a.sta, a.amount from #pay a where sta='3' order by a.sta,a.descript,a.paycode
select @ccode = ''
open c_paycode
fetch c_paycode into @code,@descript,@sta,@amount
while @@sqlstatus = 0
	begin
	if @ccode <> @code
		select @ccode = @code, @vpos = convert(int, (charindex(@code, @codes) + 5) / 6)
	if @vpos = 1
		update #list set pay1s = @descript, pay1d = @amount
	else if @vpos = 2
		update #list set pay2s = @descript, pay2d = @amount
	else if @vpos = 3
		update #list set pay3s = @descript, pay3d = @amount
	else if @vpos = 4
		update #list set pay4s = @descript, pay4d = @amount
	else if @vpos = 5
		update #list set pay5s = @descript, pay5d = @amount
	else if @vpos = 6
		update #list set pay6s = @descript, pay6d = @amount
	else if @vpos = 0 or @vpos >= 7
		update #list set pay7s = @descript, pay7d = @amount
	fetch c_paycode into @code,@descript,@sta,@amount
	end
close c_paycode
deallocate cursor c_paycode

update #list set pay8s = '����', pay8d = isnull((select sum(amount) from #pay where sta='1'), 0)
update #list set pay9s = 'ʹ��-����', pay9d = isnull((select sum(amount) from #pay where sta='2'), 0)

select menus,checks,cancels,d_cancels,d_dscs,d_ents,d_nofees,d_rewards,
		 menud,checkd,canceld,d_canceld,d_dscd,d_entd,d_nofeed,d_rewardd,bills,
		 pay1s,pay1d,pay2s,pay2d,pay3s,pay3d,pay4s,pay4d,pay5s,pay5d,pay6s,pay6d,pay7s,pay7d,pay8s,pay8d,pay9s,pay9d from #list
;

