///* 四川锦江房费及餐费优惠汇总表(以结帐为准) */
//if exists (select * from sysobjects where name ='discount_scjj' and type ='U')
//	drop table discount_scjj;
//
//create table discount_scjj
//(
//	date				datetime,										/* 营业日期 */
//	key0				char(3)	not null,							/* 优惠人员代码 */
//	day11				money		default 0 not null,				/* 本日应收房费 */
//	day12				money		default 0 not null,				/* 本日优惠房费 */
//	day21				money		default 0 not null,				/* 本日应收餐费 */
//	day22				money		default 0 not null,				/* 本日优惠餐费 */
//	month11			money		default 0 not null,				/* 本月应收房费 */
//	month12			money		default 0 not null,				/* 本月优惠房费 */
//	month21			money		default 0 not null,				/* 本月应收餐费 */
//	month22			money		default 0 not null,				/* 本月优惠餐费 */
//	year11			money		default 0 not null,				/* 本年应收房费 */
//	year12			money		default 0 not null,				/* 本年优惠房费 */
//	year21			money		default 0 not null,				/* 本年应收餐费 */
//	year22			money		default 0 not null				/* 本年优惠餐费 */
//)
//exec sp_primarykey discount_scjj, key0
//create unique index index1 on discount_scjj(key0)
//;
//
///* 各种优惠,折扣,款待汇总表 */
//if exists (select * from sysobjects where name ='ydiscount_scjj' and type ='U')
//	drop table ydiscount_scjj;
//
//create table ydiscount_scjj
//(
//	date				datetime,										/* 营业日期 */
//	key0				char(3)	not null,							/* 优惠人员代码 */
//	day11				money		default 0 not null,				/* 本日应收房费 */
//	day12				money		default 0 not null,				/* 本日优惠房费 */
//	day21				money		default 0 not null,				/* 本日应收餐费 */
//	day22				money		default 0 not null,				/* 本日优惠餐费 */
//	month11			money		default 0 not null,				/* 本月应收房费 */
//	month12			money		default 0 not null,				/* 本月优惠房费 */
//	month21			money		default 0 not null,				/* 本月应收餐费 */
//	month22			money		default 0 not null,				/* 本月优惠餐费 */
//	year11			money		default 0 not null,				/* 本年应收房费 */
//	year12			money		default 0 not null,				/* 本年优惠房费 */
//	year21			money		default 0 not null,				/* 本年应收餐费 */
//	year22			money		default 0 not null				/* 本年优惠餐费 */
//)
//exec sp_primarykey ydiscount_scjj, date, key0
//create unique index index1 on ydiscount_scjj(date, key0)
//;
//
/* 分摊 */
if exists ( select * from sysobjects where name = 'p_gl_audit_discount_scjj' and type ='P')
	drop proc p_gl_audit_discount_scjj;
create proc p_gl_audit_discount_scjj
as

declare
	@bdate			datetime, 
	@bfdate			datetime, 
	@duringaudit	char(1), 
	@isfstday		char(1), 
	@isyfstday		char(1), 
	--
	@last_key0		char(3), 
	@billno			char(10), 
	@key0				char(3), 
	@log_date		datetime, 
	@total			money, 
	@discount		money, 
	@charge			money, 
	@charge1			money, 
	@charge2			money, 
	@charge3			money, 
	@charge4			money, 
	@charge5			money, 
	@rebate			char(3), 
	@menu				char(10), 
	@reason1			char(3), 
	@reason2			char(3), 
	@amount0			money, 
	@amount1			money, 
	@amount2			money, 
	@amount3			money, 
	@sqlmark			integer

select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
--
if exists ( select 1 from discount_scjj where date = @bdate )
	update discount_scjj 
		set month11 = month11 - day11, month12 = month12 - day12, month21 = month21 - day21, month22 = month22 - day22, 
		year11 = year11 - day11, year12 = year12 - day12, year21 = year21 - day21, year22 = year22 - day22 
update discount_scjj set day11 = 0, day12 = 0, day21 = 0, day22 = 0, date = @bfdate

-- 第二部分计算总台房费优惠 
declare c_billno cursor for
	select distinct billno from outtemp
declare c_discount cursor for
	select a.charge, a.charge1, a.charge2, a.charge3, a.charge4, a.charge5, a.reason, a.log_date, b.deptno8
	from outtemp a, pccode b
	where a.billno = @billno and a.pccode < '02' and a.pccode = b.pccode
	order by a.accnt, a.number desc
open c_billno
fetch c_billno into @billno
while @@sqlstatus = 0
	begin
	select @total = 0, @discount = 0, @last_key0 = null
	open c_discount
	fetch c_discount into @charge, @charge1, @charge2, @charge3, @charge4, @charge5, @key0, @log_date, @rebate
	while @@sqlstatus = 0
		begin
		select @key0 = isnull(@key0, '')   -- gds set 
		if @rebate = 'RB'
			begin
			if rtrim(@last_key0) is null
				select @last_key0 = @key0
			select @discount = @discount - @charge
			end
		else if @charge2 != 0
			begin
			if rtrim(@last_key0) is null
				select @last_key0 = @key0
			select @total = @total + @charge1 + @charge3 + @charge4 + @charge5, @discount = @discount + @charge2
			end
		else
			select @total = @total + @charge
		fetch c_discount into @charge, @charge1, @charge2, @charge3, @charge4, @charge5, @key0, @log_date, @rebate
		end
	close c_discount
	if @discount != 0
		begin
		if not exists (select 1 from discount_scjj where key0 = @last_key0)
			insert discount_scjj (date, key0) select @bfdate, @last_key0
		update discount_scjj set day11 = day11 + @total, day12 = day12 + @discount 
			where key0 = @last_key0
		end
	fetch c_billno into @billno
	end
deallocate cursor c_discount
close c_billno
deallocate cursor c_billno

-- 第二部分计算餐饮娱乐优惠(pos_detail_jie) 只统计模式优惠和菜单优惠
declare pos_cursor cursor for
	select menu, sum(amount0), sum(amount1), sum(amount2), sum(amount3), isnull(reason1, ''), isnull(reason2, '')
	from pos_detail_jie
	where date = @bdate and type = ''
	group by menu, isnull(reason1, ''), isnull(reason2, '')
open pos_cursor
fetch pos_cursor into @menu, @amount0, @amount1, @amount2, @amount3, @reason1, @reason2
while @@sqlstatus = 0
	begin
	-- 菜单优惠
	if @amount2 != 0 and @reason2 != ''
		begin
		select @key0 = type from reason where code = @reason2
		if @@rowcount=0 or @key0 is null  -- gds set 
			select @key0 = ''
		if not exists (select 1 from discount_scjj where key0 = @key0)
			insert discount_scjj (date, key0) select @bfdate, @key0
		update discount_scjj set day21 = day21 + @amount0, day22 = day22 + @amount1 + @amount2 + @amount3
			where key0 = @key0
		end
	-- 模式优惠
	else if @amount1 != 0 and @reason1 != ''
		begin
		select @key0 = type from reason where code = @reason1
		if @@rowcount=0 or @key0 is null 
			select @key0 = ''
		if not exists (select 1 from discount_scjj where key0 = @key0)
			insert discount_scjj (date, key0) select @bfdate, @key0
		update discount_scjj set day21 = day21 + @amount0, day22 = day22 + @amount1 + @amount2 + @amount3
			where key0 = @key0
		end
	fetch pos_cursor into @menu, @amount0, @amount1, @amount2, @amount3, @reason1, @reason2
	end
close pos_cursor
deallocate cursor pos_cursor
exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
-- 最后调整销售策略优惠 = 优惠总额 - 其他优惠合计
select @amount0 = sum(day12), @amount1 = sum(day22)
	from discount_scjj where key0 != 'XX'
select @amount2 = day1 + day2 from sjourrep where deptno = '05'
select @amount3 = day1 + day2 from sjourrep where deptno = '10'
update discount_scjj set day12 = @amount2 - @amount0, day22 = @amount3 - @amount1 
	where key0 = 'XX'
--
if @isfstday = 'T'
	update discount_scjj set month11 = 0, month12 = 0, month21 = 0, month22 = 0
if @isyfstday = 'T'
	update discount_scjj 
		set month11 = 0, month12 = 0, month21 = 0, month22 = 0, 
		year11 = 0, year12 = 0, year21 = 0, year22 = 0
update discount_scjj 
	set month11 = month11 + day11, month12 = month12 + day12, month21 = month21 + day21, month22 = month22 + day22, 
	year11 = year11 + day11, year12 = year12 + day12, year21 = year21 + day21, year22 = year22 + day22, date = @bdate
--
delete ydiscount_scjj where date = @bdate
insert ydiscount_scjj select * from discount_scjj
return 0
;
