
if exists(select * from sysobjects where name = "p_gl_audit_notice" and type = "P")
	drop proc p_gl_audit_notice;
create proc p_gl_audit_notice
	@paymth			char(6), 							-- 1.�������
																-- 2-6λ�� limit amount
	@class			char(5), 							-- ����ӡ�Ŀ�������ZL
	@member			char(1), 							-- �Ƿ��ӡ�����Ա
	@days				money									-- ������
as
-- ���ʱ���
declare
	@limit			money

declare 	-- for calulate package 
   @bdate1        datetime,
	@accnt			char(10)	,
	@package       char(255),
	@tmp_package   char(255),
	@rule_calc     char(1),
	@package_fee   money,
	@rule_4	 		char(1)   ,                    -- ���㱨�۷�ʽ
	@gstno         int,
	@children      int,
	@rule_post     char(2)  ,
	@setrate       money,
	@rule_3        char(1),
	@rule_5        char(1),
	@arr           datetime,
	@dep           datetime,
	@quantity      int

create table #notice
(
	accnt			char(10)			null, 							--�ʺ�
	roomno		char(5)			null, 							--����
	groupno		char(10)			null, 							--�����
	name			char(50)			null, 							--����
	paycode		char(5)			null, 							--���ʽ
	paydept		char(5)			null, 							--���ʽ���
	arr			datetime			null, 							--����
	dep			datetime			null, 							--�뿪
	setrate		money				null, 							--����
	package_rate money			null, 		 					--���۶������
	fix_charge  money				null, 							--�̶�֧��
	credit		money				null, 							--�跽��
	accredit		money				null, 							--������
	charge		money				null, 							--������
	balance		money				null, 							--ƽ����
	master		char(10)			null, 							--����
	pcrec			char(20)			null, 							--����
	transfer		char(20)			null, 							--�Զ�ת��
	vip			char(3)			null, 							--
	srqs			char(30)			null, 							--
	ref			varchar(255)	null, 							--
	position		char(4)			null, 							--
	limit1		money				null, 							--���ʺ��µ�ƽ�������۷��Ѻ����ã�
	limit2		money				null, 							--�������ƽ����
	limit3		money				null, 							--������ƽ����
	limit			money				null, 							--
)

-- 
select @bdate1 = bdate1 from sysdata
select @limit = convert(money, substring(@paymth, 2, 5)), @paymth = substring(@paymth, 1, 1)
select @class = isnull(rtrim(@class), '') 

-- ֻ���ס�����
insert #notice
	select a.accnt, a.roomno, a.groupno, b.name, a.paycode, '', b.arr, b.dep, a.setrate,0,0, 
		credit, accredit, charge, charge - credit, a.master, 
		(Select g.roomno+'--'+g.accnt From master g Where  g.accnt=a.pcrec), 
		(Select f.roomno+'--'+f.accnt From master f Where f.sta='I' and f.accnt=(Select min(e.to_accnt) From subaccnt e Where e.type='5' and a.accnt=e.accnt)), 
		b.vip, a.srqs, a.ref, j.hall+j.flr, a.limit, 0, 0, 0
	from master a, guest b, rmsta j
	where a.accnt like '[FGM]%' and a.sta ='I' and a.haccnt *= b.no and a.roomno = j.roomno

-- ��ɢ�� 
if @member = 'F'
	delete #notice where rtrim(groupno)  is not null or accnt not like 'F%'

-- NC=����� ND=��Ѻ����ס 
delete #notice where charindex('NC',srqs) > 0 or charindex('ND',srqs) > 0

-- ȥ�������� 
if charindex('L', @class)>0 
	delete #notice from master a, mktcode b where #notice.accnt=a.accnt and a.market=b.code and b.flag='LON'

-- ���ʽ����
update #notice set paydept=a.deptno from pccode a where #notice.paycode=a.pccode 
if @paymth='R'			-- �ֽ� 
	delete #notice where paydept<>'A' 
else if @paymth='C'	-- ���ÿ�
	delete #notice where paydept<>'C' and paydept<>'D'
else if @paymth='A'	-- ����
	delete #notice where paydept<>'J'
else if @paymth='O'	-- ���� 
	delete #notice where paydept='A' or paydept='C' or paydept='D' or paydept='J'

-- fix charge 
update #notice set #notice.fix_charge=isnull((select b.amount*b.quantity from fixed_charge b where @bdate1>=b.starting_time and @bdate1<=b.closing_time and b.accnt=#notice.groupno),0)

-- package rate -- ������������ͨ�õĹ��� !? 
declare c1 cursor  for select accnt from #notice order by accnt
open c1
fetch c1 into @accnt
while @@sqlstatus = 0
	begin
	select @arr=arr,@dep=dep,@package = rtrim(packages),@gstno=gstno,@children=children,@setrate=setrate from master where accnt=@accnt
	if right(@package,1)<>','
		select @package=rtrim(@package)+','
	while datalength(@package)>1 and charindex(',',@package)>0 and @package<>null and @package<>''
		begin
		select @tmp_package=substring(@package,1,charindex(',',@package) -1)
		select @package= rtrim(substring(@package,charindex(',',@package)+1,datalength(rtrim(@package))))
		select @quantity=quantity,@rule_calc=substring(rule_calc,2,1),@rule_3=substring(rule_calc,3,1),@rule_5=substring(rule_calc,5,1),@rule_4=substring(rule_calc,4,1),@package_fee=amount,@rule_post=rule_post from package where code=@tmp_package

		if @rule_calc='1' and @rule_post = '*' or
			(@rule_post like 'B%' and convert(char(10), @arr, 101) = convert(char(10), @bdate1, 101)) or
			(@rule_post like 'E%' and convert(char(10), dateadd(day, -1, @dep), 101) = convert(char(10), @bdate1, 101)) or
			(@rule_post like 'W%' and charindex(convert(char(1), datepart(dw, @dep)), @rule_post) > 0) or
			(@rule_post like '-B%' and convert(char(10), @arr, 101) != convert(char(10), @bdate1, 101)) or
			(@rule_post like '-E%' and convert(char(10), dateadd(day, -1, @dep), 101) != convert(char(10), @bdate1, 101)) or
			(@rule_post like 'M%' and convert(char(10), @arr, 101) != convert(char(10), @bdate1, 101) and convert(char(10), dateadd(day, -1, @dep), 101) != convert(char(10), @bdate1, 101))
			begin
				if @rule_3='1'
				begin
				if @rule_calc = '0'
					select @package_fee = round(@setrate * @package_fee / (1 + @package_fee), 2)
				else
					select @package_fee = round(@setrate * @package_fee, 2)
				end

				if @rule_4 = '1'
					select @package_fee = round((@gstno + @children) * @package_fee, 2), @quantity = round((@gstno + @children) * @quantity, 0)
				else if @rule_4 = '2'
					select @package_fee = round(@gstno * @package_fee, 2), @quantity = round(@gstno * @quantity, 0)
				else if @rule_4 = '3'
					select @package_fee = round(@children * @package_fee, 2), @quantity = round(@children * @quantity, 0)
			update #notice set package_rate=package_rate+@package_fee where accnt=@accnt
			end
		end
	fetch c1 into @accnt
	end

-- 
update #notice set  balance=charge - credit

-- limit1 ÿ���ʻ���ƽ�������۳����Ѻ�����  
update #notice set limit1 = balance + setrate * @days - accredit

-- limit2 ÿ�������ƽ����
update #notice set limit2 = (select sum(a.limit1) from #notice a where a.master = #notice.master)

-- limit3 ������ƽ����. ����������ʱ��ȡ��ͬס��ƽ���� 
update #notice set limit3 = (select sum(a.limit1) from #notice a where a.pcrec = #notice.pcrec), limit2 = 0
	where not rtrim(pcrec) is null

-- limit ÿ���ʻ���ʵ��ƽ����������ͬס������  
update #notice set limit = limit2 + limit3

-- ������¼ 
delete #notice where limit - @limit <= 0

-- output 
select roomno, groupno, name, paycode, arr, dep, setrate, package_rate,fix_charge,
		credit, accredit, charge, balance, limit, substring(pcrec, 1, 5), vip, srqs, ref, position
	from #notice order by roomno
;
