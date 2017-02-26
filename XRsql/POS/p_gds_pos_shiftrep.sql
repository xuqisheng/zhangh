
if exists ( select * from sysobjects where name = 'p_gds_pos_shiftrep' and type  = 'P')
	drop proc p_gds_pos_shiftrep;
create proc p_gds_pos_shiftrep
	@pc_id				char(4),			/* 站点 */
	@limpcs				varchar(120),	/* Pccode 限制*/
	@date					datetime,		/* 报表日期 */
	@empno				char(3),			/* 工号 null 表示所有工号 */
	@shift				char(1)			/* 班别 null 表示所有班别 */
as

declare
	@bdate				datetime,	/*营业日期*/
	@type					char(5), 
	@plucode				char(15), 
	@tocode				char(3),
	@paycode				char(5),
	@menu					char(10),
	@amount				money,
	@amount0				money,
	@tax					money,
	@dsc					money,
	@ent					money,
	@serve				money,
	@no					int,
	@bills				int,		// 单数
	@guest				int,		// 客人
	@deptno				char(2),
	@special				char(1),
	@deptno8				char(10)

if rtrim(@empno) is null
	select @empno = '%'
if rtrim(@shift) is null
	select @shift = '%'
select @bdate = bdate1 from sysdata

select * into #detail_jie from pos_detail_jie where 1=2

//
select * into #pos_menu from pos_menu where 1 = 2
if @date = @bdate
	insert #pos_menu select * from pos_menu
else
	insert #pos_menu select * from pos_hmenu where bdate = @date
delete #pos_menu where not empno3 like @empno or not shift like @shift or charindex(pccode, @limpcs) = 0

insert into #detail_jie select a.* from pos_detail_jie a, #pos_menu b where a.menu=b.menu and b.paid='1' and  rtrim(ltrim(a.code))<>'Y' and rtrim(ltrim(a.code))<>'Z' order by a.menu
update #detail_jie set amount0 = 0,amount1= 0,amount2 = 0 where type in (select pccode from pccode where pccode>'900' and deptno8<>'' and deptno8 is not null)  -- and special <>'E'

//
delete pos_nshift1 where pc_id=@pc_id
delete pos_nshift2 where pc_id=@pc_id

// 借方
declare c_jie cursor for 
select a.menu,a.code,a.type,a.amount0,a.amount1+a.amount2+a.amount3,a.amount3+a.serve3+a.tax3,round(a.serve0,2)-round(a.serve1,2)-round(a.serve2,2)-round(a.serve3,2),a.tax0-a.tax1-a.tax2-a.tax3,a.tocode,a.special
	from #detail_jie a, #pos_menu b where a.menu=b.menu and b.paid='1' and  rtrim(ltrim(a.code))<>'Y' and rtrim(ltrim(a.code))<>'Z' order by a.menu
open c_jie 
fetch c_jie into @menu,@plucode,@type,@amount0, @dsc,@ent,@serve, @tax, @tocode,@special
while @@sqlstatus = 0
	begin
--	if @special='U' or @type='4' or @type='6' select @serve=0
	if @special='U' select @serve=0
	if @special='G' select @tax=0
	if not exists(select 1 from pos_nshift1 where pc_id=@pc_id and code=@tocode)
		insert pos_nshift1(pc_id, code) values(@pc_id, @tocode)
	select @deptno8 =''
	select @deptno8 = deptno8 from pccode where pccode = @type 
	if @deptno8 > ''
		update pos_nshift1 set ent=ent-@ent where pc_id=@pc_id and code=@tocode
	else
		if rtrim(ltrim(@plucode))<>'Y' and rtrim(ltrim(@plucode))<>'Z'
			update pos_nshift1 set amount0=amount0+@amount0, dsc=dsc-@dsc, srv=srv+@serve, tax=tax+@tax where pc_id=@pc_id and code=@tocode
	fetch c_jie into @menu,@plucode,@type,@amount0, @dsc,@ent, @serve, @tax, @tocode,@special
	end
close c_jie
deallocate cursor c_jie
// 借方合计
insert pos_nshift1(pc_id,code,descript,amount0,dsc,srv,tax,amt1,ent,amt2) 
	select @pc_id,'ZZ9','合  计',sum(amount0),sum(dsc),sum(srv),sum(tax),sum(amt1),sum(ent),sum(amt2)
	from pos_nshift1 where pc_id=@pc_id

// 借方整理
update pos_nshift1 set amt1=amount0+dsc+srv+tax where pc_id=@pc_id
update pos_nshift1 set amt2=amt1+ent where pc_id=@pc_id
select @bills=count(1) from #pos_menu
select @guest=sum(guest) from #pos_menu
if @guest <> 0 
	update pos_nshift1 set avg1=round(amt1/@guest,2) where pc_id=@pc_id
if @bills <> 0 
	update pos_nshift1 set avg2=round(amt1/@bills,2) where pc_id=@pc_id
select @deptno=b.deptno from  pos_pccode b where b.pccode=substring(@limpcs, 1, 3)
update pos_nshift1 set descript=a.descript from pos_namedef a where  a.code=pos_nshift1.code and pos_nshift1.pc_id=@pc_id

// 贷方 -- 付款折扣除外
declare c_dai cursor for select a.menu,a.paycode,a.amount
	from pos_detail_dai a, #pos_menu b where a.menu=b.menu and a.paycode<>'C93' order by a.paycode
open c_dai 
fetch c_dai into @menu,@paycode,@amount
while @@sqlstatus = 0
	begin
	select @no=no from pos_nshift2 where pc_id=@pc_id and paycode=@paycode
	if @@rowcount = 0
		begin
		select @no = (select count(1) from pos_nshift2 where pc_id=@pc_id)+1
		insert pos_nshift2(pc_id, no, paycode) values(@pc_id, @no, @paycode)
		end
	update pos_nshift2 set amount=amount+@amount where pc_id=@pc_id and no=@no
	fetch c_dai into @menu,@paycode,@amount
	end
close c_dai
deallocate cursor c_dai
update pos_nshift2 set descript=a.descript from pccode a where a.pccode=pos_nshift2.paycode and pos_nshift2.pc_id=@pc_id

// 统计各种付款的单据数目 --- 为什么一个 update 不行 ? 
//update pos_nshift2 set number=isnull((select count(distinct a.menu) from #pos_menu a, pos_detail_dai b where a.menu=b.menu and pos_nshift2.paycode=b.paycode),0)
//	where pos_nshift2.pc_id=@pc_id 
declare c_paycode cursor for select no, paycode from pos_nshift2 where pc_id=@pc_id and rtrim(paycode) is not null order by no
open c_paycode 
fetch c_paycode into @no, @paycode
while @@sqlstatus = 0
	begin
	update pos_nshift2 set number=isnull((select count(distinct b.menu) from #pos_menu a, pos_detail_dai b 
				where a.menu=b.menu and b.paycode=@paycode),0)
		where pc_id=@pc_id and no=@no
	fetch c_paycode into @no, @paycode
	end
close c_paycode
deallocate cursor c_paycode


// 单据数目的统计
select @no = 1
if not exists(select 1 from pos_nshift2 where no=@no and pc_id=@pc_id)
	insert pos_nshift2(pc_id, no) values(@pc_id, @no)
update pos_nshift2 set descript1='已结单' where pc_id=@pc_id and no=@no
select @amount=sum(amount),@guest=sum(guest),@bills=count(1) from #pos_menu where paid='1'
update pos_nshift2 set amt=@amount,guest=@guest,bill=@bills where pc_id=@pc_id and no=@no

select @no = 2
if not exists(select 1 from pos_nshift2 where no=@no and pc_id=@pc_id)
	insert pos_nshift2(pc_id, no) values(@pc_id, @no)
update pos_nshift2 set descript1='重结单' where pc_id=@pc_id and no=@no
select @amount=isnull(sum(a.amount),0),@guest=isnull(sum(a.guest),0),@bills=isnull(count(1),0) 
	from #pos_menu a where exists(select 1 from pos_pay b where a.menu=b.menu and b.crradjt='CO')
select @amount=@amount+isnull(sum(a.amount),0),@guest=@guest+isnull(sum(a.guest),0),@bills=@bills+isnull(count(1),0) 
	from #pos_menu a where exists(select 1 from pos_hpay b where a.menu=b.menu and b.crradjt='CO')
update pos_nshift2 set amt=@amount,guest=@guest,bill=@bills where pc_id=@pc_id and no=@no

select @no = 3
if not exists(select 1 from pos_nshift2 where no=@no and pc_id=@pc_id)
	insert pos_nshift2(pc_id, no) values(@pc_id, @no)
update pos_nshift2 set descript1='未结单' where pc_id=@pc_id and no=@no
select @amount=isnull(sum(amount),0),@guest=isnull(sum(guest),0),@bills=isnull(count(1),0) from #pos_menu where sta='2' or sta='5'
update pos_nshift2 set amt=@amount,guest=@guest,bill=@bills where pc_id=@pc_id and no=@no

select @no = 4
if not exists(select 1 from pos_nshift2 where no=@no and pc_id=@pc_id)
	insert pos_nshift2(pc_id, no) values(@pc_id, @no)
update pos_nshift2 set descript1='取消单' where pc_id=@pc_id and no=@no
select @amount=isnull(sum(amount),0),@guest=isnull(sum(guest),0),@bills=isnull(count(1),0) from #pos_menu where sta='7'
update pos_nshift2 set amt=@amount,guest=@guest,bill=@bills where pc_id=@pc_id and no=@no

// 贷方合计
select @no=isnull((select max(no) from pos_nshift2 where pc_id=@pc_id), 0)+1
insert pos_nshift2(pc_id,no,paycode,descript,amount,number) 
	select @pc_id,@no,'ZZZ','合  计',sum(amount),sum(number)	
from pos_nshift2 where pc_id=@pc_id

return 0
;
