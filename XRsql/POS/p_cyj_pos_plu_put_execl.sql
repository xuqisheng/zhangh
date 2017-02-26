if exists(select 1 from sysobjects where name = 'p_cyj_pos_plu_put_execl' and type ='P')
	drop  proc p_cyj_pos_plu_put_execl;
create proc p_cyj_pos_plu_put_execl
	@pluid			integer
as
--
--	菜谱导出到Execl文件
--
declare	
	@ii			integer,
	@id			integer,
	@pccode		char(3),
	@unit			char(4),
	@price		money,
	@inumber		integer

create table #list
(
	pccode		char(3),			-- 餐厅
	pcdes			char(16),		-- 餐厅描述
	plucode		char(2),			-- 菜本
	pludes		char(20),
	sort			char(4),			-- 菜类
	sortname		char(30),
	code			char(6),			-- 菜号
	id				integer,			-- 菜ID
	name1			char(30),
	name2			char(50),
	unit1			char(4),
	price1		money,
	unit2			char(4),
	price2		money,
	unit3			char(4),
	price3		money,
	unit4			char(4),
	price4		money,
	unit5			char(4),
	price5		money
)
insert into #list
  SELECT '###','所有', a.plucode,c.descript,a.sort,b.name1,a.code,a.id,a.name1,a.name2,'',0,'',0,'',0,'',0,'',0
    FROM pos_plu_all a, pos_sort_all b, pos_plucode c  
where a.pluid = @pluid and a.pluid = b.pluid and c.pluid=a.pluid and a.plucode=b.plucode and a.plucode=c.plucode
and a.sort=b.sort 
and a.sta ='0' 
and b.halt = 'F'

insert #list select b.pccode,c.descript,a.plucode,a.pludes,a.sort,a.sortname,a.code,a.id,a.name1,a.name2,a.unit1,a.price1,a.unit2,a.price2,a.unit3,a.price3,a.unit4,a.price4,a.unit5,a.price5 
	from #list a, pos_price b, pos_pccode c where a.id = b.id and b.pccode <> '###' and b.pccode = c.pccode


declare	c_price cursor for select pccode,inumber,unit,price from pos_price where id = @id and pccode = @pccode order by pccode, inumber
declare	c_cur cursor for select id, pccode from #list order by id
open c_cur
fetch c_cur into @id,@pccode
while @@sqlstatus = 0 
	begin
	select @ii = 1
	open c_price
	fetch c_price into @pccode, @inumber,@unit,@price
	while @@sqlstatus = 0 
		begin
		if @ii = 1 
			update #list set unit1 = @unit, price1 = @price  where id = @id and pccode = @pccode
		else if @ii = 2 
			update #list set unit2 = @unit, price2 = @price  where id = @id and pccode = @pccode
		else if @ii = 3 
			update #list set unit3 = @unit, price3 = @price  where id = @id and pccode = @pccode
		else if @ii = 4 
			update #list set unit4 = @unit, price4 = @price  where id = @id and pccode = @pccode
		else if @ii = 5 
			update #list set unit5 = @unit, price5 = @price  where id = @id and pccode = @pccode
		fetch c_price into @pccode, @inumber,@unit,@price
		select @ii = @ii + 1
		end
	close c_price
	fetch c_cur into @id,@pccode
	end
close c_cur
deallocate cursor c_cur
deallocate cursor c_price 

select * from #list order by plucode, sort, code, pccode
;

/*
//菜谱从文件倒入，临时存放表
create table pos_plu_file
(
	pccode		char(3)		default ''	not null,			-- 餐厅
	pcdes			char(16)		default ''	not null,  		   -- 餐厅描述
	plucode		char(2)		default ''	not null,			-- 菜本
	pludes		char(20)		default ''	not null,
	sort			char(4)		default ''	not null,			-- 菜类
	sortname		char(30)		default ''	not null,
	code			char(6)		default ''	not null,			-- 菜号
	id				integer		default ''	not null,			-- 菜ID
	name1			char(30)		default ''	not null,
	name2			char(50)		default ''	not null,
	unit1			char(4)		default ''	not null,
	price1		money			default 0	not null,
	unit2			char(4)		default ''	not null,
	price2		money			default 0	not null,
	unit3			char(4)		default ''	not null,
	price3		money			default 0	not null,
	unit4			char(4)		default ''	not null,
	price4		money			default 0	not null,
	unit5			char(4)		default ''	not null,
	price5		money			default 0	not null
)
*/