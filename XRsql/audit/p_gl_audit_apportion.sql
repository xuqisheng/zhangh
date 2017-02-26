/* 分摊用临时表 */
if exists (select * from sysobjects where name ='apportion_jie' and type ='U')
	drop table apportion_jie;

create table apportion_jie
(
	pc_id				char(4)	not null,							/* IP地址 */
	accnt				char(10)	not null,							/* 帐号(前台)
																				菜单号(综合收银)
																				流水号(商务中心) */
	number			integer	default 0 not null,				/* 行次 */
	pccode			char(5)	not null,							/* 费用码 */
	refer				char(15) null,									/* tag(前台)
																				code(综合收银) */
	charge			money		default 0 not null				/* 金额 */
)
exec sp_primarykey apportion_jie, pc_id, accnt, number
create unique index index1 on apportion_jie(pc_id, accnt, number)
;

if exists (select * from sysobjects where name ='apportion_dai' and type ='U')
	drop table apportion_dai;

create table apportion_dai
(
	pc_id				char(4)	not null,							/* IP地址 */
	paycode			char(5)	not null,							/* 付款方式 */
	credit			money		default 0 not null,				/* 金额 */
	key0				char(3)	null,									/* 优惠人员代码 */
	accnt				char(10)	not null								/* 帐号(前台)
																				菜单号(综合收银)
																				流水号(商务中心) */
)
exec sp_primarykey apportion_dai, pc_id, paycode, key0, accnt
create unique index index1 on apportion_dai(pc_id, paycode, key0, accnt)
;

if exists (select * from sysobjects where name ='apportion_jiedai' and type ='U')
	drop table apportion_jiedai;

create table apportion_jiedai
(
	pc_id				char(4)	not null,							/* IP地址 */
	accnt				char(10)	not null,							/* 帐号(前台)
																				菜单号(综合收银)
																				流水号(商务中心) */
	number			integer	default 0 not null,				/* 行次 */
	pccode			char(5)	not null,							/* 费用码 */
	refer				char(15) null,									/* tag(前台)
																				code(综合收银) */
	charge			money		default 0 not null,				/* 金额 */
	paycode			char(5)	not null,							/* 付款方式 */
	key0				char(3)	default '' null					/* 优惠人员代码 */
)
exec sp_primarykey apportion_jiedai, pc_id, accnt, number, paycode, key0
create unique index index1 on apportion_jiedai(pc_id, accnt, number, paycode, key0)
;

/* 分摊 */
if exists ( select * from sysobjects where name = 'p_gl_audit_apportion' and type ='P')
	drop proc p_gl_audit_apportion;
create proc p_gl_audit_apportion
	@pc_id			char(4), 
	@pccode			char(5) = '010'
as

declare
	@this				money, 
	@sum				money, 
	@paycode			char(5), 
	@key0				char(3), 
	@accnt			char(10), 
	@number			integer, 
	@refer			char(15), 
	@opccode			char(5), 
	@orefer			char(15), 
	@onumber			integer, 
	@countjie		integer, 
	@countdai		integer, 
	@mcredit			money, 
	@charge			money,
	@credit			money

select @countjie = isnull((select count(1) from apportion_jie where pc_id = @pc_id), 0)
select @countdai = isnull((select count(1) from apportion_dai where pc_id = @pc_id), 0)
select @mcredit = isnull((select sum(credit) from apportion_dai where pc_id = @pc_id), 0)
declare charge_cursor cursor for
	select accnt, number, pccode, refer, charge from apportion_jie 
	where pc_id = @pc_id and charge != 0 and rtrim(accnt) is not null
	order by accnt, number
declare credit_cursor cursor for
	select paycode, key0, sum(credit) from apportion_dai 
	where pc_id = @pc_id and credit != 0
	group by paycode, key0
open credit_cursor
fetch credit_cursor into @paycode, @key0, @credit
// 借方(贷方)为零
if round(@mcredit, 2) = 0
	begin
	if @countjie = 0
		insert apportion_jiedai select @pc_id, accnt, 0, @pccode, '', credit, paycode, key0
			from apportion_dai where pc_id = @pc_id and rtrim(accnt) is not null
	else if @countdai = 0
		insert apportion_jiedai select @pc_id, accnt, number, pccode, refer, charge, '901', ''
			from apportion_jie where pc_id = @pc_id and rtrim(accnt) is not null
	else
		begin
		insert apportion_jiedai select @pc_id, accnt, 0, @pccode, '', credit, paycode, key0
			from apportion_dai where pc_id = @pc_id and rtrim(accnt) is not null
		insert apportion_jiedai select @pc_id, accnt, number, pccode, refer, charge, '901', ''
			from apportion_jie where pc_id = @pc_id and rtrim(accnt) is not null
		end
	end
else
	// 分摊
	begin
	while @@sqlstatus = 0
		begin
		select @sum = 0
		open charge_cursor
		fetch charge_cursor into @accnt, @number, @pccode, @refer, @charge
		while @@sqlstatus = 0
			begin
			if rtrim(@accnt) is  null continue // gds
			if @opccode is null and @charge <> 0 
				select @opccode = @pccode, @onumber = @number, @orefer = @refer
			select @this = round(@charge * @credit / @mcredit * 1.0 , 2)
			if not exists (select 1 from apportion_jiedai where pc_id = @pc_id and accnt = @accnt 
				and number = @number and paycode = @paycode and key0 = @key0)
				insert apportion_jiedai values (@pc_id, @accnt, @number, @pccode, @refer, @this, @paycode, @key0)
			else
				update apportion_jiedai set charge = charge + @this where pc_id = @pc_id 
				and accnt = @accnt and number = @number and paycode = @paycode and key0 = @key0
			select @sum = @sum + @this
			fetch charge_cursor into @accnt, @number, @pccode, @refer, @charge
			end
		close charge_cursor 
		// 补零
		if round(@sum, 2) <> round(@credit, 2) and rtrim(@accnt) is not null  // gds
			begin 
			if not exists (select 1 from apportion_jiedai where pc_id = @pc_id and accnt = @accnt 
				and number = @onumber and paycode = @paycode and key0 = @key0)
				insert apportion_jiedai values (@pc_id, @accnt, @onumber, @opccode, @orefer, @credit - @sum, @paycode, @key0)
			else
				update apportion_jiedai set charge = charge + @credit - @sum where pc_id = @pc_id 
				and accnt = @accnt and number = @onumber and paycode = @paycode and key0 = @key0
			end
		fetch credit_cursor into @paycode, @key0, @credit
		end
	end
close credit_cursor
deallocate cursor credit_cursor
deallocate cursor charge_cursor
/* 最后调整构稽关系 */
select @paycode = min(paycode) from apportion_dai where pc_id = @pc_id
select @key0 = min(key0) from apportion_dai where pc_id = @pc_id and paycode = @paycode
update apportion_jiedai set charge = charge
	- (select isnull(sum(charge), 0) from apportion_jiedai a 
		where a.pc_id = @pc_id and a.accnt = apportion_jiedai.accnt and a.number = apportion_jiedai.number)
	+ (select isnull(sum(charge), 0) from apportion_jie b 
		where b.pc_id = @pc_id and b.accnt = apportion_jiedai.accnt and b.number = apportion_jiedai.number)
	where accnt <> '' and paycode = @paycode and key0 = @key0
return
;
