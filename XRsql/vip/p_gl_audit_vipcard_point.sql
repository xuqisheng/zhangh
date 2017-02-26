
IF OBJECT_ID('p_gl_audit_vipcard_point') IS NOT NULL
    DROP PROCEDURE p_gl_audit_vipcard_point
;
create proc p_gl_audit_vipcard_point
	@accnt		char(10),
	@empno		char(10) = 'AUDIT'
as

declare
	@en_str				varchar(40), 
	@ds_str				varchar(40), 
	@billno				char(10),
	@credit				money,
	@deduction			money,
	@haccnt				char(7),
	@cardcode			char(20),
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
	@rm		 			money,
	@fb 					money,
	@en 					money,
	@mt 					money,
	@ot 					money,
	@tl		 			money,
	@rm_pccodes_nt		char(255),
	@x_times				integer,
	@n_times				integer,
	@i_times				integer,
	@ret					integer,
	@msg					varchar(60)

-- card info
select @cardno = null
select @haccnt = haccnt, @cardcode = cardcode, @cardno = cardno,
	@ref2 = convert(char(10), arr, 111) + '-' + convert(char(10), dep, 111) + '  ' + rtrim(roomno) + '[' + rtrim(type) + '] ' + rtrim(ratecode) + convert(char(10), setrate)
		from master where accnt = @accnt
if @@rowcount = 0
	select @haccnt = haccnt, @cardcode = cardcode, @cardno = cardno,
		@ref2 = convert(char(10), arr, 111) + '-' + convert(char(10), dep, 111) + '  ' + rtrim(roomno) + '[' + rtrim(type) + '] ' + rtrim(ratecode) + convert(char(10), setrate)
			from hmaster where accnt = @accnt
if rtrim(@cardno) is null
	return 0

-- 目前只有西软发行的积分卡才进入积分计算程序，航空公司积分卡暂时不处理
select @flag = flag from guest_card_type where code=@cardcode
if @@rowcount = 0 or @flag is null or @flag != 'FOX'
	return 0

-- 取得卡类型与记分计算模式(vipcard_type.calc = vipptcode.code)
select @cardtype = type from vipcard where no = @cardno
if @@rowcount = 0
	return 0
select @calc = calc from vipcard_type where code = @cardtype
if @@rowcount = 0
	return 0

-- bdate
select @ret = 0, @msg = '', @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead

--
if not exists(select 1 from sys_empno where empno=@empno) 
	select @empno='FOX'

-- 准备帐务数据 - 按照原始发生账户计算
create table #account
(
	pccode				char(10)						null,
	argcode				char(3)		default ''	null,
	deptno				char(5)		default ''	null,
	date					datetime						null,
	quantity				money			default 0 	null,
	charge				money			default 0 	null,
	credit				money			default 0 	null,
	mode					char(10)						null,
	tofrom				char(2)		default ''	null,
	accntof				char(10)		default ''	null,
	billno				char(10)		default ''	null,
	amount				money			default 0 	null,		-- 计算积分的消费净额
	base					money			default 0 	null,
	step					money			default 0 	null,
	rate					money			default 0 	null,
	point					money			default 0 	null
)
insert #account (pccode, date, quantity, charge, credit, mode, tofrom, accntof, billno, amount, base, step, rate, point)
	select pccode, date, quantity, charge, credit, mode, tofrom, accntof, billno, 0, 0, 0, 0, 0
		from haccount where accnt = @accnt 
	union all
	select pccode, date, quantity, charge, credit, mode, tofrom, accntof, billno, 0, 0, 0, 0, 0
		from haccount where tofrom='' and accntof = @accnt 
	union all
	select pccode, date, quantity, charge, credit, mode, tofrom, accntof, billno, 0, 0, 0, 0, 0
		from account where accnt = @accnt 
	union all
	select pccode, date, quantity, charge, credit, mode, tofrom, accntof, billno, 0, 0, 0, 0, 0
		from account where tofrom='' and accntof = @accnt 
delete #account where tofrom != ''
-- 去掉房包餐的影响；
delete #account where mode like ' pkg_%'

--add by cqf 2006.07.18
update #account set amount = charge

-- 扣除用积分付款以及折扣、款待的金额
create table #outtemp
(
	pccode				char(10)						null,
	credit				money			default 0 	not null
)
select @en_str = isnull((select value from sysoption where catalog = 'audit' and item = 'en_str'), '')
select @ds_str = isnull((select value from sysoption where catalog = 'audit' and item = 'ds_str'), '')
declare c_billno cursor for
	select distinct billno from #account where billno != ''
open c_billno
fetch c_billno into @billno
while @@sqlstatus = 0
	begin
	delete #outtemp
	insert #outtemp select pccode, credit from haccount where billno = @billno
	select @credit = isnull((select sum(credit) from #outtemp), 0) 
	select @deduction = isnull((select sum(credit) from #outtemp a, pccode b
		where a.pccode = b.pccode and (charindex(b.deptno2 , @en_str) > 0 or charindex(b.deptno2 , @ds_str) > 0 or b.deptno2 = 'PTS')), 0) 
	if @deduction != 0 and @credit != 0
		update #account set amount = isnull(charge * (@credit - @deduction) / @credit, 0) 
	fetch c_billno into @billno
	end
close c_billno
deallocate cursor c_billno

-- 去除无效消费，比如电话费等；在 vipdef1 中定义
update #account set argcode=a.argcode, deptno=a.deptno from pccode a where #account.pccode = a.pccode
update #account set base = a.base, step = a.step, rate = a.rate from vipdef1 a where a.code=@calc and #account.pccode = a.pccode
delete #account where abs(amount) < base or argcode >= '9' or rate <= 0

-- 计算积分
update #account set point = amount / step * rate where step != 0 and rate != 0

-- 对特殊日期特殊处理
declare c_vipdef2 cursor for select type, starting, ending, rate from vipdef2 where rate != 1
open  c_vipdef2
fetch c_vipdef2 into @type, @starting, @ending, @rate
while @@sqlstatus = 0
	begin
	if @type = 'B'
		begin
		select @birth = b.birth from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
		update #account set point = isnull(point * @rate,0)
			where convert(char(5), date, 101) = convert(char(5), @birth, 101)
		end
	else
		update #account set point = isnull(point * @rate,0) 
			where date >= @starting and date <= @ending
	fetch c_vipdef2 into @type, @starting, @ending, @rate
	end
close c_vipdef2
deallocate cursor c_vipdef2
--
select @m1 = isnull((select sum(charge) from #account where deptno = '10'), 0)
select @m2 = isnull((select sum(charge) from #account where deptno = '20'), 0)
select @m3 = isnull((select sum(charge) from #account where deptno != '10' and deptno != '20'), 0)
select @m4 = 0
select @m5 = sum(amount - charge), @m9 = sum(amount), @point = floor(sum(point)) from #account
select @m5 = isnull(@m5, 0), @m9 = isnull(@m9, 0), @point = isnull(@point, 0)
-- other 
select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
-- Send out flag
if exists(select 1 from sysoption where catalog = "hotel" and item = "hotelid" and ltrim(rtrim(value))='crs')
	or exists(select 1 from vipcard a, vipcard_type b where a.no=@cardno and a.type=b.code and b.center='F')
	select @sendout = 'T'
else
	select @sendout = 'F'
select @log_date = getdate(), @expiry_date = convert(datetime, '2030/1/1')
select @ref = substring(name, 1, 24) from guest where no = @haccnt
select @ref1 = 'NightAudit'
select * into #income from master_income where accnt = @accnt
-- 累加
select @rm = isnull((select sum(amount1) from #income a, pccode b where  a.pccode = b.pccode and b.deptno7 = 'rm'), 0)
select @fb = isnull((select sum(amount1) from #income a, pccode b where  a.pccode = b.pccode and b.deptno7 = 'fb'), 0)
select @en = isnull((select sum(amount1) from #income a, pccode b where  a.pccode = b.pccode and b.deptno7 = 'en'), 0)
select @mt = isnull((select sum(amount1) from #income a, pccode b where  a.pccode = b.pccode and b.deptno7 = 'mt'), 0)
select @ot = isnull((select sum(amount1) from #income a, pccode b where  a.pccode = b.pccode and b.deptno7 = 'ot'), 0)
select @tl = @rm + @fb + @en + @mt + @ot

select @x_times = isnull((select sum(amount2) from #income a where  a.item = 'X_TIMES'), 0)
select @n_times = isnull((select sum(amount2) from #income a where  a.item = 'N_TIMES'), 0)
select @i_times = isnull((select sum(amount2) from #income a where  a.item = 'I_TIMES'), 0)

begin tran
save tran tran_vip

if exists(select 1 from #income)
	begin
	update vipcard set rm = rm + @rm, fb = fb + @fb, en = en + @en, mt = mt + @mt, ot = ot + @ot, tl = tl + @tl,
		x_times = x_times + @x_times, n_times = n_times + @n_times, i_times = i_times + @i_times
		where no = @cardno
	-- 房晚
	select @rm_pccodes_nt = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes_nt'), '')
	update vipcard set i_days = i_days + isnull((select sum(amount2) from #income a where a.pccode != '' and charindex(a.pccode, @rm_pccodes_nt) > 0 ), 0)
		where no = @cardno
	-- fv_date (首次入住)
	update vipcard set fv_date = a.arr, fv_room = a.roomno, fv_rate = a.setrate 
		from hmaster a where a.accnt = @accnt and a.sta = 'O' and vipcard.i_times = 1 and vipcard.no=@cardno 
	-- lv_date (最近入住)
	update vipcard set lv_date = a.arr, lv_room = a.roomno, lv_rate = a.setrate 
		from hmaster a where a.accnt = @accnt and a.sta = 'O' and vipcard.no=@cardno and lv_date<a.arr 
	end

-- 积分
-- delete vippoint where no = @cardno and ref1 = 'NightAudit'   -- 调试语句
update vipcard set lastnumb = lastnumb + 1, credit = credit + @point where no = @cardno
if @@rowcount = 0
	select @ret = 1, @msg = 'Update error - vippoint'
else
	begin
	select @lastnumb = lastnumb, @balance = credit - charge from vipcard where no = @cardno  -- 注意 balance 计算
	insert vippoint (no, number, hotelid, log_date, bdate, expiry_date, quantity, charge, credit, balance,
			fo_modu_id, fo_accnt, fo_number, fo_billno, shift, empno, tag, ref, ref1, ref2,
			m1, m2, m3, m4, m5, m9, calc, sendout)
		values(@cardno, @lastnumb, @hotelid, @log_date, @bdate, @expiry_date, 0, 0, @point, @balance,
			'02', @accnt, 0, '', '3', @empno, '', @ref, @ref1, @ref2,
			@m1, @m2, @m3, @m4, @m5, @m9, @calc, @sendout)
	if @@rowcount = 0
		select @ret = 1, @msg = 'Insert error - vippoint'
	end

if @ret != 0
	rollback tran tran_vip
commit tran 

return @ret
;


