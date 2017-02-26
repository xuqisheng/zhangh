drop proc p_cq_pos_shift_detail;
create proc p_cq_pos_shift_detail
	@pc_id				char(4),			-- 站点
	@limpcs				varchar(255),	-- Pccode 限制
	@date					datetime,		-- 报表日期
	@empno				char(10),		-- 工号 null 表示所有工号
	@shift				char(1),			-- 班别 null 表示所有班别
	@sorts				char(250)		--菜类类别限制
as
------------------------------------------------------------------------------------
--
--		餐饮交班表的明细菜打印
--
------------------------------------------------------------------------------------


declare
	@bdate				datetime			-- 营业日期

if rtrim(@empno) is null
	select @empno = '%'
if rtrim(@shift) is null
	select @shift = '%'
if rtrim(@sorts) is null or datalength(rtrim(@sorts)) < 3
	select @sorts = '%'
select @bdate = bdate1 from sysdata

select * into #pos_detail_jie from pos_detail_jie where 1=2
insert into #pos_detail_jie select * from pos_detail_jie where date = @date


update #pos_detail_jie set number = 0,amount0 = 0,amount1= 0,amount2 = 0 where type in (select pccode from pccode where pccode>'900' and deptno8<>'' and deptno8 is not null) -- and special <>'E'

select *, menu_empno = space(10), menu_shift = space(1), menu_sta = space(1), pccode = space(3)
	into #dish from pos_dish where 1 = 2


if @date = @bdate
	insert #dish select a.*, b.empno3, b.shift, b.sta, b.pccode
		from pos_dish a, pos_menu b where a.menu = b.menu and charindex(b.pccode,@limpcs) >0
			and b.empno3 like @empno and b.shift like @shift and b.sta = '3' and (charindex(a.plucode+a.sort,@sorts) > 0 or @sorts = '%')
				and charindex(rtrim(a.code),'XYZ')=0 and charindex(a.sta,'03579ATM')>0
else
	insert #dish select a.*, b.empno3, b.shift, b.sta, b.pccode
		from pos_hdish a, pos_hmenu b where a.menu = b.menu and b.bdate = @date and charindex(b.pccode,@limpcs) >0
			and b.empno3 like @empno and b.shift like @shift and b.sta = '3' and (charindex(a.plucode+a.sort,@sorts) > 0  or @sorts = '%')
				and charindex(rtrim(a.code),'XYZ')=0 and charindex(a.sta,'03579ATM')>0

--delete #dish where not (menu_empno like @empno and menu_shift like @shift and menu_sta = '3')
create table #out
(
	descript		char(16) null,
	descript1	char(8)	null,
	name1			char(40)	null,
	code			char(15)	null,
	name2			char(20)	null,
	sort			char(4)	null,
	number		money,
	unit			char(4),
	price			money,
	amount		money
)

insert #out
select substring(rtrim(d.descript), 1, 16), substring(rtrim(b.descript), 1, 8), rtrim(e.name1) , a.code,
	substring(rtrim(a.name1), 1, 15), f.sort, sum(a.number), f.unit, f.price, sum(a.amount0 -a.amount1 - a.amount2 - a.amount3)
	from  #pos_detail_jie a, pos_pccode b, basecode d ,pos_sort e,#dish f
	where a.pccode = b.pccode   and d.cat = 'chgcod_deptno'
	and f.plucode *= e.plucode and f.sort *= e.sort and a.menu=f.menu and a.id = f.inumber
	and b.deptno = d.code 
	group by d.descript, b.descript, a.code, f.sort, e.name1, a.name1, f.unit,f.price
	order by d.descript, b.descript, a.code, f.sort, e.name1, a.name1, f.unit,f.price
//delete #out where number = 0
select descript,descript1,name1,code,name2,sort,number,unit,price,amount from #out
return 0;
