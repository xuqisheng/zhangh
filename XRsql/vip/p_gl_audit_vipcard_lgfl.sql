
IF OBJECT_ID('p_gl_audit_vipcard_lgfl') IS NOT NULL
    DROP PROCEDURE p_gl_audit_vipcard_lgfl
;
create proc p_gl_audit_vipcard_lgfl
	@accnt		char(10),
	@empno		char(10)
as
-----------------------------------------------------------------------
--	宾客消费结帐后积分统计 - 建立在 master_income 基础上
-----------------------------------------------------------------------
declare
	@haccnt				char(7),
	@cardcode			char(10),
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
	@msg					varchar(60)

-- card info
select @cardno = null
select @haccnt = haccnt, @cardcode = cardcode, @cardno = cardno,
	@ref2=convert(char(10),arr,111)+'-'+convert(char(10),dep,111)+'  '+rtrim(roomno)+'['+rtrim(type)+'] ' + rtrim(ratecode) + convert(char(10),setrate)
		from master where accnt = @accnt
if @@rowcount = 0
	select @haccnt = haccnt, @cardcode = cardcode, @cardno = cardno,
		@ref2=convert(char(10),arr,111)+'-'+convert(char(10),dep,111)+'  '+rtrim(roomno)+'['+rtrim(type)+'] ' + rtrim(ratecode) + convert(char(10),setrate)
			from hmaster where accnt = @accnt
if rtrim(@cardno) is null
	return 0

-- 目前只有西软发行的积分卡才进入积分计算程序，航空公司积分卡暂时不处理
select @flag = flag from guest_card_type where code=@cardcode
if @@rowcount=0 or @flag is null or @flag<>'FOX'
	return 0

-- 取得卡类型与记分计算模式(vipcard_type.calc = vipptcode.code)
select @cardtype=type from vipcard where no=@cardno
if @@rowcount = 0
	return 0
select @calc = calc from vipcard_type where code=@cardtype
if @@rowcount = 0
	return 0

-- bdate
select @ret = 0, @msg = '', @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead

-- 准备帐务数据 <-- from master_income
create table #account
(
	pccode				char(10)						not null,
	argcode				char(3)		default ''	not null,
	deptno				char(5)		default ''	not null,
	date					datetime						not null,
	quantity				money			default 0 	not null,
	charge				money			default 0 	not null,
	credit				money			default 0 	not null,
	base					money			default 0 	not null,
	step					money			default 0 	not null,
	rate					money			default 0 	not null,
	point		money			default 0 	not null
)
insert #account (pccode,date,quantity,charge)
	select pccode,@bdate,amount2,amount1 from master_income where accnt=@accnt

-- 去除无效消费，比如电话费等；在 vipdef1 中定义
update #account set argcode=a.argcode, deptno=a.deptno from pccode a where #account.pccode = a.pccode
update #account set base = a.base, step = a.step, rate = a.rate from vipdef1 a where a.code=@calc and #account.pccode = a.pccode
delete #account where charge < base or argcode >= '9' or rate<=0

-- 计算积分
update #account set point = charge / step * rate where step <> 0

-- 对特殊日期特殊处理
declare c_vipdef2 cursor for select type, starting, ending, rate from vipdef2 where rate <> 1
open  c_vipdef2
fetch c_vipdef2 into @type, @starting, @ending, @rate
while @@sqlstatus = 0
	begin
	if @type = 'B'
		begin
		select @birth = b.birth from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
		update #account set point = point * @rate
			where convert(char(5), date, 101) = convert(char(5), @birth, 101)
		end
	else
		update #account set point = point * @rate
			where date >= @starting and date <= @ending
	fetch c_vipdef2 into @type, @starting, @ending, @rate
	end
close c_vipdef2
deallocate cursor c_vipdef2

-- 检查积分付款的消费 - m5 
select @pts_amt=isnull((select sum(credit) from haccount where accnt=@accnt), 0)
select @pts_out=round(@pts_amt/step*rate, 0) from vipdef1 where code=@calc and pccode = (select min(a.pccode) from vipdef1 a where a.code=@calc)

--
select @m1 = isnull((select sum(charge) from #account where deptno='10'), 0)
select @m2 = isnull((select sum(charge) from #account where deptno='20'), 0)
select @m3 = isnull((select sum(charge) from #account where deptno<>'10' and deptno<>'20'), 0)
select @m4 = 0
select @m5 = -1 * @pts_amt
select @m9 = @m1 + @m2 + @m3 + @m4 + @m5

-- 汇总 (需要扣除 pts_out)
select @point = floor(sum(point)) - @pts_out from #account

-- other 
select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
-- Send out flag
if exists(select 1 from sysoption where catalog = "hotel" and item = "hotelid" and ltrim(rtrim(value))='crs')
		or exists(select 1 from vipcard a, vipcard_type b where a.no=@cardno and a.type=b.code and b.center='F')
	select @sendout = 'T'
else
	select @sendout = 'F'
select @log_date = getdate(), @expiry_date = convert(datetime, '2018/1/1')
select @ref=substring(name,1,24) from guest where no=@haccnt
select @ref1='NightAudit'

begin tran
save tran aaaa
delete vippoint where no=@cardno and ref1='NightAudit'
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
			'02', @accnt, 0, '', '3', @empno, '', @ref, @ref1, @ref2,
			@m1,@m2,@m3,@m4,@m5,@m9,@calc,@sendout)
	if @@rowcount <> 1
		select @ret=1, @msg='Insert error - vippoint'
end

if @ret<> 0
	rollback tran aaaa
commit tran 

return 0
;


