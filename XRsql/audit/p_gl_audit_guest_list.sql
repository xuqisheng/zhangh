
if exists(select * from sysobjects where name = "p_gl_audit_guest_list")
	drop proc p_gl_audit_guest_list;

create proc p_gl_audit_guest_list
	@parameter			char(20),
	@operation			char(20) = 'set', -- set 输出列表， 否则输出记录数
	@langid				integer = 0
as
--  应到未到、应离未离客人列表

declare
	@bdate				datetime,
	@bdate1				datetime,
	@date					datetime,
	@audit				datetime,				-- 本营业日的开始时间
	@empno				char(10),
	@half_rmrate		char(10),
	@rm_pccodes			varchar(255)

create table #list
(
	accnt				char(10)		null,
	type				char(5)		null,
	rmnum				integer		default 1 null,
	roomno			char(5)		null,
	name				char(50)		null,
	arr				datetime		null,
	dep				datetime		null,
	sta_des			char(50)		null,
	agt_name			char(50)		null,
	grp_name			char(50)		null,
	cus_name			char(50)		null,
	src_name			char(50)		null,
	type_des			char(50)		null,
	balance			money			null,
	rmrate			money			null,
	qtrate			money			null,
	setrate			money			null,
	packages			char(50)		null,
	rmcharge			money			null
)
select @parameter = substring(@parameter, 1, 10), @empno = substring(@parameter, 11, 10)
select @bdate = bdate, @bdate1= bdate1 from sysdata
if @parameter = 'nocheckin'
	insert #list select a.accnt, a.type, a.rmnum, a.roomno, b.name, a.arr, a.dep, a.sta, a.agent, a.groupno, a.cusno, a.source, c.descript, round(a.charge, 2) - round(a.credit, 2),
		a.rmrate, a.qtrate, a.setrate, a.packages, 0
		from master a, guest b, restype c
		where a.class in ('F','G','M') and a.sta = 'R' and datediff(dd, a.arr, @bdate1) >= 0 and a.haccnt = b.no and a.restype *= c.code
else if @parameter = 'nocheckout'
	insert #list select a.accnt, a.type, a.rmnum, a.roomno, b.name, a.arr, a.dep, a.sta, a.agent, a.groupno, a.cusno, a.source, c.descript, round(a.charge, 2) - round(a.credit, 2),
		a.rmrate, a.qtrate, a.setrate, a.packages, 0
		from master a, guest b, restype c
		where a.class in ('F','G','M') and a.sta = 'I' and datediff(dd, a.dep, @bdate1) >= 0 and a.haccnt = b.no and a.restype *= c.code
else if @parameter = 'cancel'
	insert #list select a.accnt, a.type, a.rmnum, a.roomno, b.name, a.arr, a.dep, a.sta, a.agent, a.groupno, a.cusno, a.source, c.descript, round(a.charge, 2) - round(a.credit, 2),
		a.rmrate, a.qtrate, a.setrate, a.packages, 0
		from master a, guest b, restype c
		where a.class in ('F','G','M') and a.sta = 'X' and a.haccnt = b.no and a.restype *= c.code
else if @parameter = 'predaycred'
begin
--	insert #list select a.accnt, a.type, a.rmnum, a.roomno, b.name, a.arr, a.dep, a.sta, a.agent, a.groupno, a.cusno, a.source, c.descript, round(a.charge, 2) - round(a.credit, 2),
--		a.rmrate, a.qtrate, a.setrate, a.packages, 0
--		frommaster a, guest b, restype c
--		where a.cby = @empno and a.sta = 'O' and (round(a.charge, 2) - round(a.credit, 2) <> 0 or (select count(1) from account d where d.accnt = a.accnt and d.billno = '') > 0) and a.haccnt = b.no and a.restype *= c.code

	-- 结帐之后，可能其他人入帐了，此时需要判断帐务的最新日期工号 与 主单结帐信息
	insert #list
		select a.accnt, a.type, a.rmnum, a.roomno, b.name, a.arr, a.dep, a.sta, a.agent, a.groupno, a.cusno, a.source, c.descript, round(a.charge, 2) - round(a.credit, 2),
				a.rmrate, a.qtrate, a.setrate, a.packages, 0
			from master a, guest b, restype c
			where a.haccnt = b.no and a.restype *= c.code and a.sta = 'O'  -- 结帐后，又有入帐
				and exists(select 1 from account d where d.accnt = a.accnt and d.billno = '' and d.log_date>a.changed and d.empno=@empno)
	insert #list
		select a.accnt, a.type, a.rmnum, a.roomno, b.name, a.arr, a.dep, a.sta, a.agent, a.groupno, a.cusno, a.source, c.descript, round(a.charge, 2) - round(a.credit, 2),
				a.rmrate, a.qtrate, a.setrate,a.packages, 0
			from master a, guest b, restype c										-- 结帐日期前还有帐未结
			where a.cby = @empno and a.haccnt = b.no and a.restype *= c.code and a.sta = 'O'
				and exists(select 1 from account d where d.accnt = a.accnt and d.billno = '' and d.log_date<a.changed)
end
else if @parameter = 'nobalance'
	insert #list select a.accnt, a.type, a.rmnum, a.roomno, b.name, a.arr, a.dep, a.sta, a.agent, a.groupno, a.cusno, a.source, c.descript, round(a.charge, 2) - round(a.credit, 2),
		a.rmrate, a.qtrate, a.setrate, a.packages, 0
		from master a, guest b, restype c
		where a.sta = 'O' and (round(a.charge, 2) - round(a.credit, 2) <> 0 or (select count(1) from account d where d.accnt = a.accnt and d.billno = '') > 0) and a.haccnt = b.no and a.restype *= c.code
else if @parameter = 'nomarket'
	insert #list select a.accnt, a.type, a.rmnum, a.roomno, b.name, a.arr, a.dep, a.sta, a.agent, a.groupno, a.cusno, a.source, c.descript, round(a.charge, 2) - round(a.credit, 2),
		a.rmrate, a.qtrate, a.setrate, a.packages, 0
		from master a, guest b, restype c
		where a.class in ('F','G','M') and a.sta = 'I' and (a.market='' or a.src='') and a.haccnt = b.no and a.restype *= c.code
else if @parameter = 'errmarket1'	-- 市场码输入错误客人一览表
	insert #list select a.accnt, a.type, a.rmnum, a.roomno, b.name, a.arr, a.dep, a.sta, a.agent, a.groupno, a.cusno, a.source, c.descript, round(a.charge, 2) - round(a.credit, 2),
		a.rmrate, a.qtrate, a.setrate, a.packages, 0
		from master a, guest b, restype c
		where a.class in ('F','G','M', 'C') and a.sta = 'I' and a.haccnt = b.no and a.restype *= c.code and a.market not in (select code from mktcode)
else if @parameter = 'errmarket2'	-- 成员与团体(会议)的市场码不一致 
	insert #list select a.accnt, a.type, a.rmnum, a.roomno, b.name, a.arr, a.dep, a.sta, a.agent, a.groupno, a.cusno, a.source, c.descript, round(a.charge, 2) - round(a.credit, 2),
		a.rmrate, a.qtrate, a.setrate, a.packages, 0
		from master a, guest b, restype c, master d 
		where a.groupno=d.accnt and a.sta = 'I' and a.market<>d.market and a.haccnt = b.no and a.restype *= c.code
else if @parameter in ('<06:00', '>12:00', 'dayuse')
	begin
	if @parameter = '<06:00'
		begin
		select @half_rmrate = value from sysoption where catalog = 'ratemode' and item = 't_half_rmrate'
		select @date = convert(datetime, convert(char(10), bdate, 111) + ' ' + @half_rmrate) from sysdata
		select @audit = end_ from audit_date where date = dateadd(dd, -1, @bdate)
		insert #list select a.accnt, a.type, a.rmnum, a.roomno, b.name, a.citime, a.deptime, a.sta, a.agent, a.groupno, a.cusno, a.source, c.descript, round(a.charge, 2) - round(a.credit, 2),
			a.rmrate, a.qtrate, a.setrate, a.packages, 0
			from master a, guest b, restype c
			where a.class in ('F') and a.sta in ('I', 'O', 'S') and a.citime >= @audit and a.citime <= @date and a.haccnt = b.no and a.restype *= c.code
		end
	else if @parameter = '>12:00'
		begin
		select @half_rmrate = value from sysoption where catalog = 'ratemode' and item = 'd_half_rmrate'
		select @date = convert(datetime, convert(char(10), bdate, 111) + ' ' + @half_rmrate) from sysdata
		select @audit = isnull((select end_ from audit_date where date = @bdate), getdate())
		insert #list select a.accnt, a.type, a.rmnum, a.roomno, b.name, a.citime, a.deptime, a.sta, a.agent, a.groupno, a.cusno, a.source, c.descript, round(a.charge, 2) - round(a.credit, 2),
			a.rmrate, a.qtrate, a.setrate, a.packages, 0
			from master a, guest b, restype c
			where a.class in ('F') and a.sta in ('I', 'O', 'S') and a.deptime >= @date and a.deptime <= @audit and a.haccnt = b.no and a.restype *= c.code
		end
	else
		insert #list select a.accnt, a.type, a.rmnum, a.roomno, b.name, a.citime, a.deptime, a.sta, a.agent, a.groupno, a.cusno, a.source, c.descript, round(a.charge, 2) - round(a.credit, 2),
			a.rmrate, a.qtrate, a.setrate, a.packages, 0
			from master a, guest b, restype c
			where a.class in ('F') and a.sta in ('O', 'S') and a.rmposted = 'F' and a.haccnt = b.no and a.restype *= c.code and a.bdate=@bdate
	select @rm_pccodes = value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes'
	-- 返回汇总数
	if @operation != 'set'
		select @operation = @operation
	-- 夜审过程中
	else if exists (select 1 from gltemp where bdate = @bdate)
		update #list set rmcharge = isnull((select sum(a.charge) from gltemp a where a.accnt = #list.accnt and a.tofrom = '' and charindex(a.pccode, @rm_pccodes) > 0 and not mode like '[Jj]%'), 0) +
			isnull((select sum(a.charge) from gltemp a where a.accntof = #list.accnt and a.tofrom = '' and charindex(a.pccode, @rm_pccodes) > 0 and not mode like '[Jj]%'), 0)
	-- 夜审开始前
	else
		update #list set rmcharge = isnull((select sum(a.charge) from account a where a.bdate = @bdate and a.accnt = #list.accnt and a.tofrom = '' and charindex(a.pccode, @rm_pccodes) > 0 and not mode like '[Jj]%'), 0) +
			isnull((select sum(a.charge) from account a where a.bdate = @bdate and a.accntof = #list.accnt and a.tofrom = '' and charindex(a.pccode, @rm_pccodes) > 0 and not mode like '[Jj]%'), 0)
	end
if @operation = 'set'
	begin
	update #list set grp_name = b.name from master a, guest b where #list.grp_name = a.accnt and a.haccnt = b.no
	update #list set agt_name = a.name from guest a where #list.agt_name = a.no
	update #list set cus_name = a.name from guest a where #list.cus_name = a.no
	update #list set src_name = a.name from guest a where #list.src_name = a.no
	update #list set sta_des = a.descript from basecode a where a.cat = 'mststa' and #list.sta_des = a.code
	select accnt, type, rmnum, roomno, name, arr, dep, sta_des, isnull(rtrim(agt_name), src_name), isnull(rtrim(grp_name), cus_name), type_des, balance,
		rmrate, qtrate, setrate, packages, rmcharge
		from #list order by accnt
	end
else
	select count(1) from #list
return 0
;
