drop  proc p_cyj_audit_pos_vipcard_point;
create proc p_cyj_audit_pos_vipcard_point
	@empno		char(10),
	@retmode		char(1) ='S'
as
-----------------------------------------------------------------------
--	夜审时统计餐饮vip积分
-----------------------------------------------------------------------
declare
	@argcode				char(3),
	@menu					char(10),
	@cardtype			char(3),
	@flag					char(10),
	@calc					char(10),
	@cardno				char(20),
	@duringaudit		char(1),
	@bdate				datetime,
	@type					char(1),
	@starting			datetime,
	@ending				datetime,
	@rate					money,
	@birth				datetime,
	@point				money,
	@balance				money,
	@lastnumb			integer,
	@m1					money,		-- 房费
	@m2					money,		-- 餐费
	@m3					money,		-- 其他
	@m4					money,
	@m5					money,
	@m9					money,		-- 总消费
	@pts_amt				money,		-- 积分付款金额
	@pts_out				money,		-- 扣减积分
	@sendout				char(1),
	@hotelid				varchar(20),
	@log_date			datetime,
	@expiry_date		datetime,
	@ref					char(24),
	@ref1					char(10),
	@ref2					char(50),
	@ret					integer,
	@msg					varchar(60),
	@base					money,		--
	@step					money,		--
	@amount				money			--

-- bdate
select @ret = 0, @msg = '', @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead

-- 取到需要积分处理的餐单号,有vip卡号，但是结帐不是积分付款
-- 准备数据 <-- from pos_tmenu
create table #menu
(
	menu					char(10)						not null,
	cardno				char(20)						not null,
	pos_pccode			char(3)						not null,
	pccode				char(5)						not null,
	argcode				char(3)		default ''	not null,
	deptno				char(5)		default ''	not null,
	bdate					datetime						not null,
	quantity				money			default 0 	not null,
	amount				money			default 0 	not null,
	credit				money			default 0 	not null,
	base					money			default 0 	not null,
	step					money			default 0 	not null,
	rate					money			default 0 	not null,
	point		money			default 0 	not null
)
insert #menu (menu,cardno,pos_pccode,pccode,bdate,amount)
select a.menu,a.cardno,a.pccode,c.pccode,a.bdate,a.amount from pos_tmenu a, pos_pccode b, pos_int_pccode c  where a.pccode = b.pccode and a.cardno > '' and a.sta ='3' and a.pccode = c.pos_pccode and c.class='2' and c.shift ='1'


--
update #menu set argcode=a.argcode, deptno=a.deptno from pccode a where #menu.pccode = a.pccode


declare c_menu cursor for select menu,cardno,amount,argcode from #menu
open c_menu
fetch c_menu into @menu,@cardno,@amount,@argcode
while @@sqlstatus = 0
	begin
	if @argcode >= '9'
		goto loop1
	-- 取得卡类型与记分计算模式(vipcard_type.calc = vipptcode.code)
	select @cardtype=type from vipcard where no=@cardno
	if @@rowcount = 0
		goto loop1
	select @calc = calc from vipcard_type where code=@cardtype
	if @@rowcount = 0
		goto loop1

	select  @base = a.base, @step = a.step, @rate = a.rate from vipdef1 a, #menu where a.code=@calc and #menu.pccode = a.pccode and #menu.menu =@menu
	if @rate<=0 or @base > @amount
		goto loop1

	-- 计算积分
	select  @point = @amount / @step * @rate where @step <> 0
	-- 对特殊日期特殊处理
	declare c_vipdef2 cursor for select type, starting, ending, rate from vipdef2 where rate <> 1
	open  c_vipdef2
	fetch c_vipdef2 into @type, @starting, @ending, @rate
	while @@sqlstatus = 0
		begin
		if @type <> 'B' 		-- 'B'- 生日
			select @point = @point * @rate where @bdate >= @starting and @bdate <= @ending
		fetch c_vipdef2 into @type, @starting, @ending, @rate
		end
	close c_vipdef2
	deallocate cursor c_vipdef2

	-- 检查积分付款的消费 - m5
	select @pts_amt=isnull((select sum(credit) from pos_tpay a, pccode b where a.paycode = b.pccode and b.deptno2 ='PTS' and a.menu=@menu and a.crradjt='NR'), 0)
	select @pts_out=round(@pts_amt/step*rate, 0) from vipdef1 where code=@calc and pccode = (select min(a.pccode) from vipdef1 a where a.code=@calc)

	--
	select @m1 = 0
	select @m2 = @amount
	select @m3 = 0
	select @m4 = 0
	select @m5 = -1 * @pts_amt
	select @m9 = @m1 + @m2 + @m3 + @m4 + @m5
	-- 汇总 (需要扣除 pts_out)
	select @point = @point - @pts_out
	-- other
	select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
	-- Send out flag
	if exists(select 1 from sysoption where catalog = "hotel" and item = "hotelid" and ltrim(rtrim(value))='crs')
			or exists(select 1 from vipcard a, vipcard_type b where a.no=@cardno and a.type=b.code and b.center='F')
		select @sendout = 'T'
	else
		select @sendout = 'F'
	select @log_date = getdate(), @expiry_date = convert(datetime, '2018/1/1')
	select @ref1='PosAudit'
	select @ref2=substring(b.descript1, 1, 20)+'-'+@menu+'-'+convert(char(10),a.bdate,111)
			from #menu a,pos_pccode b where a.pos_pccode = b.pccode and a.menu = @menu

	begin tran
	save tran aaaa
	delete vippoint where no=@cardno and ref1='PosAudit' and  fo_accnt = @menu
	update vipcard set lastnumb = lastnumb + 1, credit = credit + @point where no = @cardno
	if @@rowcount <> 1
		select @ret=1, @msg='Update error - vippoint'
	else
	begin
		select @lastnumb = lastnumb, @balance = credit - charge from vipcard where no = @cardno  -- 注意 balance 计算
		insert vippoint (no, number, hotelid, log_date, bdate, expiry_date, quantity, charge, credit, balance,
				fo_modu_id, fo_accnt, fo_number, fo_billno, shift, empno, tag, ref, ref1, ref2,
				m1,m2,m3,m4,m5,m9,calc,sendout)
			values(@cardno, @lastnumb, @hotelid, @log_date, @bdate, @expiry_date, 0, 0, @point, @balance,
				'02', @menu, 0, '', '3', @empno, '', @ref, @ref1, @ref2,
				@m1,@m2,@m3,@m4,@m5,@m9,@calc,@sendout)
		if @@rowcount <> 1
			select @ret=1, @msg='Insert error - vippoint'
	end
	if @ret<> 0
		rollback tran aaaa
	commit tran

	loop1:
	fetch c_menu into @menu,@cardno,@amount,@argcode
	end
close c_menu
deallocate cursor c_menu
if @retmode ='R'
	select @ret, @msg
return 0
;