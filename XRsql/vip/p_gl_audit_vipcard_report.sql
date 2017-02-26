
IF OBJECT_ID('p_gl_audit_vipcard_report') IS NOT NULL
    DROP PROCEDURE p_gl_audit_vipcard_report
;
create proc p_gl_audit_vipcard_report
	@option				char(10)
as

declare
	@duringaudit		char(1),
	@bdate				datetime,
	@bfdate				datetime,
	@type					char(3),
	@ret					integer,
	@msg					varchar(60)

-- ---------Initialization--------------- 
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
declare c_type cursor for select code from vipcard_type
open c_type
fetch c_type into @type
while @@sqlstatus = 0
	begin
	-- 合计
	if not exists (select 1 from vipreport where type = @type and class = '1010')
		insert vipreport values (@bfdate, '1010', @type, '会员总数', '', 0, 0, 0)
	if not exists (select 1 from vipreport where type = @type and class = '1020')
		insert vipreport values (@bfdate, '1070', @type, '累计积分', '', 0, 0, 0)
	if not exists (select 1 from vipreport where type = @type and class = '1080')
		insert vipreport values (@bfdate, '1080', @type, '已兑现积分', '', 0, 0, 0)
	if not exists (select 1 from vipreport where type = @type and class = '1090')
		insert vipreport values (@bfdate, '1090', @type, '未兑现积分', '', 0, 0, 0)
	-- 本日
	if not exists (select 1 from vipreport where type = @type and class = '2010')
		insert vipreport values (@bfdate, '2010', @type, '新增会员', '', 0, 0, 0)
	if not exists (select 1 from vipreport where type = @type and class = '2020')
		insert vipreport values (@bfdate, '2020', @type, '到访人数', '', 0, 0, 0)
	if not exists (select 1 from vipreport where type = @type and class = '2030')
		insert vipreport values (@bfdate, '2030', @type, '过夜人数', '', 0, 0, 0)
	if not exists (select 1 from vipreport where type = @type and class = '2040')
		insert vipreport values (@bfdate, '2040', @type, '过夜房数', '', 0, 0, 0)
	if not exists (select 1 from vipreport where type = @type and class = '2050')
		insert vipreport values (@bfdate, '2050', @type, '本期消费(*)', '', 0, 0, 0)
	if not exists (select 1 from vipreport where type = @type and class = '2060')
		insert vipreport values (@bfdate, '2060', @type, '累计房量', '', 0, 0, 0)
	if not exists (select 1 from vipreport where type = @type and class = '2070')
		insert vipreport values (@bfdate, '2070', @type, '累计消费', '', 0, 0, 0)
	if not exists (select 1 from vipreport where type = @type and class = '2080')
		insert vipreport values (@bfdate, '2080', @type, '新增积分', '', 0, 0, 0)
	if not exists (select 1 from vipreport where type = @type and class = '2090')
		insert vipreport values (@bfdate, '2090', @type, '兑现积分', '', 0, 0, 0)
	fetch c_type into @type
	end
close c_type
deallocate cursor c_type
--
if exists ( select * from vipreport where date = @bdate )
	update vipreport set month = month - day, year = year - day
update jourrep set day = 0, date = @bfdate
create table #viplgfl
(
	type			char(3)		not null,
	value			money			default 0 not null
)
-- 新增会员
truncate table #viplgfl
insert #viplgfl select type, count(1) from vipcard where datediff(dd, reserved, @bdate) = 0 group by type
update vipreport set day = a.value from #viplgfl a where vipreport.class = '2010' and vipreport.type = a.type
-- 到访人数
truncate table #viplgfl
insert #viplgfl select b.type, count(distinct a.no)
	from viplgfl a, vipcard b where a.date = @bdate and a.no = b.no group by b.type
update vipreport set day = a.value from #viplgfl a where vipreport.class = '2020' and vipreport.type = a.type
-- 过夜人数
truncate table #viplgfl
insert #viplgfl select b.type, count(1)
	from master_till a, vipcard b where a.sta = 'I' and a.cardno = b.no group by b.type
update vipreport set day = a.value from #viplgfl a where vipreport.class = '2030' and vipreport.type = a.type
-- 过夜房数
truncate table #viplgfl
insert #viplgfl select b.type, count(distinct a.roomno)
	from master_till a, vipcard b where a.sta = 'I' and a.cardno = b.no group by b.type
update vipreport set day = a.value from #viplgfl a where vipreport.class = '2040' and vipreport.type = a.type
-- 本期消费(*), 这个数据仅供参考
truncate table #viplgfl
insert #viplgfl select b.type, sum(c.xf_dtl)
	from master_till a, vipcard b, cus_xf c where a.sta = 'I' and a.cardno = b.no and a.accnt = c.accnt group by b.type
update vipreport set day = a.value from #viplgfl a where vipreport.class = '2050' and vipreport.type = a.type
-- 累计房量
truncate table #viplgfl
insert #viplgfl select b.type, sum(a.i_days)
	from viplgfl a, vipcard b where a.date = @bdate and a.no = b.no group by b.type
update vipreport set day = a.value from #viplgfl a where vipreport.class = '2060' and vipreport.type = a.type
-- 累计消费
truncate table #viplgfl
insert #viplgfl select b.type, sum(a.charge)
	from viplgfl a, vipcard b where a.date = @bdate and a.no = b.no group by b.type
update vipreport set day = a.value from #viplgfl a where vipreport.class = '2070' and vipreport.type = a.type
-- 新增积分
truncate table #viplgfl
insert #viplgfl select b.type, sum(a.vippoint_c)
	from viplgfl a, vipcard b where a.date = @bdate and a.no = b.no group by b.type
update vipreport set day = a.value from #viplgfl a where vipreport.class = '2080' and vipreport.type = a.type
-- 兑现积分
truncate table #viplgfl
insert #viplgfl select b.type, sum(a.vippoint_d)
	from viplgfl a, vipcard b where a.date = @bdate and a.no = b.no group by b.type
update vipreport set day = a.value from #viplgfl a where vipreport.class = '2090' and vipreport.type = a.type
--
update vipreport set date = @bdate
delete yvipreport where date = @bdate
insert yvipreport select date, class, type, day, month, year from vipreport
return 0
;


