drop procedure p_cq_tor_detail;
create procedure p_cq_tor_detail
			@bdate		datetime	
			
as
declare 
			@plu_code	char(15),
			@type			char(2),
			@name1		char(20),
			@amount		money,
			@pccode		char(3),
			@int			integer,
			@tocode		char(3),
			@deptno		char(2)


create table #detail
(
		deptno		char(2),
		deptname		char(20),
		tocode		char(3),
		descript		char(20),
		amount1		money,
		amount2		money,
		amount3		money,
		amount4		money,
		amount5		money,
		amount6		money,
		amount7		money
)

declare c_type cursor for 
		select code from viptype order by code

declare c_dish cursor for
		select c.code, c.name1,c.amount-c.dsc+c.srv+c.tax,d.pccode,d.deptno
		from sp_hdish c,sp_hmenu d where  c.sta <>'M' and c.menu = d.menu and d.bdate = @bdate and charindex(rtrim(c.code),'XYZ') = 0
		and d.menu in (select a.menu from sp_hmenu a,sp_hpay b where a.sta = '3' and (a.setmodes = 'TOR' or b.paycode = 'TOR')
			 and a.bdate = @bdate
			and a.menu = b.menu and b.accnt in (select araccnt1 from vipcard where type = @type and sta = 'I')) 
		union
		select c.code, c.name1,c.amount-c.dsc+c.srv+c.tax,d.pccode,deptno
		from pos_hdish c,pos_hmenu d where  c.sta <>'M' and c.menu = d.menu and d.bdate = @bdate and charindex(rtrim(c.code),'YZ') = 0
		and d.menu in (select a.menu from pos_hmenu a,pos_hpay b where a.sta = '3' and (a.setmodes = 'TOR' or b.paycode = 'TOR')
			 and a.bdate = @bdate
			and a.menu = b.menu and b.accnt in (select araccnt1 from vipcard where type = @type and sta = 'I')) 



select @int = 1
open c_type
fetch c_type into @type
while @@sqlstatus = 0
	begin

	open c_dish
	fetch c_dish into @plu_code,@name1,@amount,@pccode,@deptno
	while @@sqlstatus = 0
	begin

	exec p_gl_pos_get_item_code @pccode, @plu_code, @tocode out

	if @int = 1
	begin

	if exists(select 1 from #detail where tocode = @tocode and deptno = @deptno)
		update #detail set amount1 = amount1+@amount where tocode = @tocode and deptno = @deptno
	else
		insert #detail select @deptno,'',@tocode ,'',@amount,0,0,0,0,0,0
	end
	if @int = 2
	begin

	if exists(select 1 from #detail where tocode = @tocode and deptno = @deptno)
		update #detail set amount2 = amount2+@amount where tocode = @tocode and deptno = @deptno
	else
		insert #detail select @deptno,'',@tocode ,'',0,@amount,0,0,0,0,0
	end

	if @int = 3
	begin

	if exists(select 1 from #detail where tocode = @tocode and deptno = @deptno)
		update #detail set amount3 = amount3+@amount where tocode = @tocode and deptno = @deptno
	else
		insert #detail select @deptno,'', @tocode ,'',0,0,@amount,0,0,0,0
	end

	if @int = 4
	begin

	if exists(select 1 from #detail where tocode = @tocode and deptno = @deptno)
		update #detail set amount4 = amount4+@amount where tocode = @tocode and deptno = @deptno
	else
		insert #detail select @deptno,'', @tocode ,'',0,0,0,@amount,0,0,0
	end

	if @int = 5
	begin

	if exists(select 1 from #detail where tocode = @tocode and deptno = @deptno)
		update #detail set amount5 = amount5+@amount where tocode = @tocode and deptno = @deptno
	else
		insert #detail select @deptno,'',@tocode ,'',0,0,0,0,@amount,0,0
	end

	if @int = 6
	begin

	if exists(select 1 from #detail where tocode = @tocode and deptno = @deptno)
		update #detail set amount6 = amount6+@amount where tocode = @tocode and deptno = @deptno
	else
		insert #detail select @deptno,'',@tocode ,'',0,0,0,0,0,@amount,0
	end

	fetch c_dish into @plu_code,@name1,@amount,@pccode,@deptno
	end
	
	close c_dish

	select @int = @int+1
	fetch c_type into @type
	end

close c_type

update #detail set descript = a.descript from pos_namedef a where a.deptno = #detail.deptno and a.code = #detail.tocode

update #detail set descript = '其他费用' where tocode = '099'

//insert #detail select '02','999','餐饮小计',(select sum(amount1) from #detail where deptno = '02'),
//	(select sum(amount2) from #detail where deptno = '02'),
//	(select sum(amount3) from #detail where deptno = '02'),
//	(select sum(amount4) from #detail where deptno = '02'),
//	(select sum(amount5) from #detail where deptno = '02'),
//	(select sum(amount6) from #detail where deptno = '02'),
//	(select sum(amount7) from #detail where deptno = '02')
// 
//
//insert #detail select '03','999','体中小计',(select sum(amount1) from #detail where deptno = '03'),
//	(select sum(amount2) from #detail where deptno = '03'),
//	(select sum(amount3) from #detail where deptno = '03'),
//	(select sum(amount4) from #detail where deptno = '03'),
//	(select sum(amount5) from #detail where deptno = '03'),
//	(select sum(amount6) from #detail where deptno = '03'),
//	(select sum(amount7) from #detail where deptno = '03')
//
//insert #detail select '04','999','总计',(select sum(amount1) from #detail),
//	(select sum(amount2) from #detail),
//	(select sum(amount3) from #detail),
//	(select sum(amount4) from #detail),
//	(select sum(amount5) from #detail),
//	(select sum(amount6) from #detail),
//	(select sum(amount7) from #detail)
update #detail set deptname = a.deptname from deptdef a where #detail.deptno = a.deptno

select deptno,deptname,tocode,descript,amount1,amount2,amount3,amount4,amount5,amount6 from #detail order by deptno,tocode

; 
	


