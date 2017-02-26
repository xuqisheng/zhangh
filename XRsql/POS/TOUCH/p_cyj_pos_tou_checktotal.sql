/*---------------------------------------------------------------------------------------------*/
//
//	触摸屏: 结帐餐单信息, 各类汇总
//
/*---------------------------------------------------------------------------------------------*/

if exists ( select * from sysobjects where name = "p_cyj_pos_tou_checktotal" and type ="P")
   drop proc p_cyj_pos_tou_checktotal;
create proc p_cyj_pos_tou_checktotal
	@menus	char(100),					/**/
	@langid	int  = 0
as

declare
	@menu				char(10),
	@plucode			char(10),
	@tocode			char(3),
	@pccode			char(3),
	@deptno			char(2),
	@id				int,  
	@inumber			int,  
	@amount			money, 
	@dsc				money, 
	@srv				money, 
	@tax				money


create table #info
(	
	code	 		char(3)       	default space(2) not null,
	descript		char(60)      	default space(20) not null,
	amount		money
)
create table #dish
(	
	menu			char(10)      	default space(10) not null,
	inumber		int,
	id	 			int,
	code	 		char(10)      	default space(10) not null,
	amount		money,
	dsc			money,
	srv			money,
	tax			money,
	tocode		char(3)       	default space(3) not null
)

insert into #dish(menu,inumber,id,code,amount,dsc,srv,tax,tocode) 
	select menu,inumber,id,rtrim(ltrim(sort))+ltrim(rtrim(code)), amount, dsc, srv, tax, ''  
from pos_dish where charindex(menu,@menus)>0 and charindex(sta, '03579A') >0 and ltrim(code)<='X' 

select @deptno = deptno, @pccode = pccode from pos_menu where menu = substring(@menus, 1, 10)
declare c_dish cursor for 	select menu,inumber,id,code,amount,dsc,srv,tax from #dish  order by code, id
open c_dish 
fetch c_dish into @menu,@inumber,@id, @plucode, @amount, @dsc, @srv, @tax
while @@sqlstatus = 0
	begin
	exec p_cq_pos_get_item_code @pccode, @plucode,@id, @tocode out                       
	update #dish set tocode=@tocode where menu=@menu and inumber=@inumber
	fetch c_dish into @menu,@inumber,@id, @plucode, @amount, @dsc, @srv, @tax
	end
close c_dish
deallocate cursor c_dish

if @langid = 0 
	begin
	insert #info select tocode, '', isnull(sum(amount), 0) from #dish group by tocode order by tocode
	insert #info select '901', '服务费: ', isnull(sum(srv+tax), 0) from #dish 
	insert #info select '903', '折扣: ',   isnull(sum(dsc), 0) from #dish 
	insert #info select '908', '合计: ',   isnull(sum(amount - dsc + srv + tax), 0) from #dish 
	update #info set descript = b.descript from pos_namedef b where #info.code = b.code and b.deptno = @deptno
	end
else
	begin
	insert #info select tocode, '', isnull(sum(amount), 0) from #dish group by tocode order by tocode
	insert #info select '901', 'Service Charge:', isnull(sum(srv+tax), 0) from #dish 
	insert #info select '903', 'Discount:',   isnull(sum(dsc), 0) from #dish 
	insert #info select '908', 'Total: ',   isnull(sum(amount - dsc + srv + tax), 0) from #dish 
	update #info set descript = b.descript1 from pos_namedef b where #info.code = b.code and b.deptno = @deptno
	end

select descript,amount from #info order by code

;



