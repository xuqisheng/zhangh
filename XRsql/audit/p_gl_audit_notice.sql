
if exists(select * from sysobjects where name = "p_gl_audit_notice" and type = "P")
	drop proc p_gl_audit_notice;
create proc p_gl_audit_notice
	@paymth			char(6), 							-- 1.付款类别
																-- 2-6位是 limit amount
	@class			char(5), 							-- 不打印的客人类型ZL
	@member			char(1), 							-- 是否打印团体成员
	@days				money									-- 房天数
as
-- 催帐报表
declare
	@limit			money

declare 	-- for calulate package 
   @bdate1        datetime,
	@accnt			char(10)	,
	@package       char(255),
	@tmp_package   char(255),
	@rule_calc     char(1),
	@package_fee   money,
	@rule_4	 		char(1)   ,                    -- 计算报价方式
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
	accnt			char(10)			null, 							--帐号
	roomno		char(5)			null, 							--房号
	groupno		char(10)			null, 							--团体号
	name			char(50)			null, 							--名称
	paycode		char(5)			null, 							--付款方式
	paydept		char(5)			null, 							--付款方式类别
	arr			datetime			null, 							--到达
	dep			datetime			null, 							--离开
	setrate		money				null, 							--房价
	package_rate money			null, 		 					--包价额外费用
	fix_charge  money				null, 							--固定支出
	credit		money				null, 							--借方数
	accredit		money				null, 							--信用数
	charge		money				null, 							--贷方数
	balance		money				null, 							--平衡数
	master		char(10)			null, 							--联房
	pcrec			char(20)			null, 							--联房
	transfer		char(20)			null, 							--自动转帐
	vip			char(3)			null, 							--
	srqs			char(30)			null, 							--
	ref			varchar(255)	null, 							--
	position		char(4)			null, 							--
	limit1		money				null, 							--本帐号新的平衡数（扣房费和信用）
	limit2		money				null, 							--本房间的平衡数
	limit3		money				null, 							--联房的平衡数
	limit			money				null, 							--
)

-- 
select @bdate1 = bdate1 from sysdata
select @limit = convert(money, substring(@paymth, 2, 5)), @paymth = substring(@paymth, 1, 1)
select @class = isnull(rtrim(@class), '') 

-- 只针对住店客人
insert #notice
	select a.accnt, a.roomno, a.groupno, b.name, a.paycode, '', b.arr, b.dep, a.setrate,0,0, 
		credit, accredit, charge, charge - credit, a.master, 
		(Select g.roomno+'--'+g.accnt From master g Where  g.accnt=a.pcrec), 
		(Select f.roomno+'--'+f.accnt From master f Where f.sta='I' and f.accnt=(Select min(e.to_accnt) From subaccnt e Where e.type='5' and a.accnt=e.accnt)), 
		b.vip, a.srqs, a.ref, j.hall+j.flr, a.limit, 0, 0, 0
	from master a, guest b, rmsta j
	where a.accnt like '[FGM]%' and a.sta ='I' and a.haccnt *= b.no and a.roomno = j.roomno

-- 仅散客 
if @member = 'F'
	delete #notice where rtrim(groupno)  is not null or accnt not like 'F%'

-- NC=免催帐 ND=免押金入住 
delete #notice where charindex('NC',srqs) > 0 or charindex('ND',srqs) > 0

-- 去掉长包房 
if charindex('L', @class)>0 
	delete #notice from master a, mktcode b where #notice.accnt=a.accnt and a.market=b.code and b.flag='LON'

-- 付款方式过滤
update #notice set paydept=a.deptno from pccode a where #notice.paycode=a.pccode 
if @paymth='R'			-- 现金 
	delete #notice where paydept<>'A' 
else if @paymth='C'	-- 信用卡
	delete #notice where paydept<>'C' and paydept<>'D'
else if @paymth='A'	-- 记账
	delete #notice where paydept<>'J'
else if @paymth='O'	-- 其他 
	delete #notice where paydept='A' or paydept='C' or paydept='D' or paydept='J'

-- fix charge 
update #notice set #notice.fix_charge=isnull((select b.amount*b.quantity from fixed_charge b where @bdate1>=b.starting_time and @bdate1<=b.closing_time and b.accnt=#notice.groupno),0)

-- package rate -- 这个部分最好有通用的过程 !? 
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

-- limit1 每个帐户的平衡数，扣除房费和信用  
update #notice set limit1 = balance + setrate * @days - accredit

-- limit2 每个房间的平衡数
update #notice set limit2 = (select sum(a.limit1) from #notice a where a.master = #notice.master)

-- limit3 联房的平衡数. 存在联房的时候，取消同住的平衡数 
update #notice set limit3 = (select sum(a.limit1) from #notice a where a.pcrec = #notice.pcrec), limit2 = 0
	where not rtrim(pcrec) is null

-- limit 每个帐户的实际平衡数，考虑同住和联房  
update #notice set limit = limit2 + limit3

-- 产生记录 
delete #notice where limit - @limit <= 0

-- output 
select roomno, groupno, name, paycode, arr, dep, setrate, package_rate,fix_charge,
		credit, accredit, charge, balance, limit, substring(pcrec, 1, 5), vip, srqs, ref, position
	from #notice order by roomno
;
