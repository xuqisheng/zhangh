drop  proc p_poswdt_retrieve_plu;
create proc p_poswdt_retrieve_plu
		@plucodes			char(255),
		@shift				char(1),
		@pccodes				char(255)
 
as
--------------------------------------------------------------------------------------------------
--
-- 菜谱刷新--
-- 按行显示菜及其单价   --  
-- 如果存在多个价格那么自动显示前3个
-- 加上@pccodes 按餐厅过滤，相同菜不同餐厅不同价格,cyj 090331
--------------------------------------------------------------------------------------------------

declare 
		@id					integer,
		@inumber				integer,
		@unit					char(4),
		@price				money,
		@pccode_1			char(3),
		@pccode				char(3),
		@ii					integer,
		@add					integer

create table #plu 
(
	pccode		char(3),
	pccode1		char(100),
	id				integer,
	code			char(6),
	helpcode		char(30),
	plucode		char(2),
	dept			char(1),
	sort			char(4),
	name1			char(30),
	name2			char(50),
	unit1			char(4),
	price1		money,
	inumber1		integer,
	unit2			char(4),
	price2		money,
	inumber2		integer,
	unit3			char(4),
	price3		money,
	inumber3		integer,
	unit4			char(4),
	price4		money,
	inumber4		integer,
	adds			integer,
	happy			char(10)
)
create table #pos_plu
(
	id			integer,
	menu		char(10),
	sta		char(1)
)

insert #pos_plu select id,menu,sta from pos_plu where charindex(plucode, @plucodes)>0
-----------------------------
--注意:
--为加快读取速度，先把单一价格的，或有多个价格的，并且设置了默认值的
--还有有多个价格的，并且没有设置过默认值的就把INUMBER最小的先写入临时表
-----------------------------
insert #plu select a.pccode,'',a.id,'','','','','','','',a.unit,a.price,a.inumber,'',0,0,'',0,0,'',0,0,1,''
 from pos_price a,#pos_plu b where 
	a.id= b.id and a.halt = 'F' and substring(b.menu,convert(int,@shift),1) = '1' and b.sta = '0' 
	and (charindex(a.pccode,@pccodes)>0)
	and a.inumber = (select min(inumber) from pos_price where id = a.id and charindex(pccode,@pccodes)>0 and halt = 'F')
	order by a.id,a.inumber

insert #plu select a.pccode,'',a.id,'','','','','','','',a.unit,a.price,a.inumber,'',0,0,'',0,0,'',0,0,1,''
 from pos_price a,#pos_plu b where 
	a.id= b.id and a.halt = 'F' and substring(b.menu,convert(int,@shift),1) = '1' and b.sta = '0' 
	and a.pccode = '###' and a.id not in(select id from #plu)
	and ((select count(1) from pos_price where id = a.id and halt = 'F') = 1 or 
		(a.pccode = '###' and a.inumber = (select min(inumber) from pos_price where id = a.id and pccode = '###' and halt = 'F') ) 
		)   
	order by a.id,a.inumber



--
declare c_plu cursor for 
	select a.pccode,a.id,a.inumber,a.unit,a.price from pos_price a,#pos_plu b,#plu c where 
	a.id= b.id and a.halt = 'F' and substring(b.menu,convert(int,@shift),1) = '1' and b.sta = '0'
	and (charindex(a.pccode,@pccodes)>0  or a.pccode = '###')
	--and rtrim(convert(char,a.id))+ rtrim(convert(char,a.inumber)) not in (select rtrim(convert(char,id))+ rtrim(convert(char,inumber1)) from #plu) 
	and (a.id = c.id and a.inumber <> c.inumber1)
	order by a.id,a.inumber
open c_plu
fetch c_plu into @pccode_1,@id,@inumber,@unit,@price
while @@sqlstatus = 0 
	begin
	select @add = 0
	select @pccode = @pccode_1
	update #plu set pccode1 = pccode1 + @pccode+'#' where id = @id and pccode = '###' and charindex(@pccode,pccode1)=0 and pccode <> @pccode
	select @add = adds from #plu where pccode = @pccode and id = @id
	if @add = 0 or @add is null
		insert #plu select @pccode,'',@id,'','','','','','','',@unit,@price,@inumber,'',0,0,'',0,0,'',0,0,1,''
	if @add = 1 
		update #plu set inumber2 = @inumber,unit2 = @unit,price2 = @price,adds = @add + 1 where id = @id and pccode = @pccode
	if @add = 2 
		update #plu set inumber3 = @inumber,unit3 = @unit,price3 = @price,adds = @add + 1 where id = @id and pccode = @pccode
	if @add >=3 
		update #plu set adds = @add + 1 where id = @id and pccode = @pccode
	fetch c_plu into @pccode_1,@id,@inumber,@unit,@price
	end
close c_plu
deallocate cursor c_plu
--更新欢乐时光的菜价
update #plu set happy = '1',price1 =  c.price from pos_happytime c where #plu.id = c.id and #plu.inumber1 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where #plu.id = a.id and #plu.inumber1 = a.inumber and a.code = b.code and charindex(rtrim(@shift),b.shift)>0
	and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0))
update #plu set happy = happy+'2',price2 =  c.price from pos_happytime c where #plu.id = c.id and #plu.inumber2 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where #plu.id = a.id and #plu.inumber2 = a.inumber and a.code = b.code and charindex(rtrim(@shift),b.shift)>0
	and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0))
update #plu set happy = happy+'3',price3 =  c.price from pos_happytime c where #plu.id = c.id and #plu.inumber3 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where #plu.id = a.id and #plu.inumber3 = a.inumber and a.code = b.code and charindex(rtrim(@shift),b.shift)>0
	and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0))
--
select a.pccode,a.pccode1,b.code,a.id,b.helpcode,dept=substring(b.code,1,1),b.sort,b.name1,b.name2,
	a.unit1,a.price1,a.inumber1,a.unit2,a.price2,a.inumber2,
	a.unit3,a.price3,a.inumber3,a.unit4,a.price4,a.inumber4,a.adds,number=1.000,b.condgp1,b.condgp2,b.flag0,b.flag1,b.flag2,b.flag3,b.flag4,b.flag5,b.flag6,b.flag7,b.flag8,b.flag9,
	b.flag10,b.flag11,b.flag12,b.flag13,b.flag14,b.flag15,b.flag16,b.flag17,b.flag18,b.flag19,
	b.th_sort,b.plucode,a.happy from #plu a,pos_plu b where a.id = b.id and b.flag1 <> 'T'
union
select a.pccode,a.pccode1,b.code,a.id,b.helpcode,dept=substring(b.code,1,1),b.sort,b.name1,b.name2,
	a.unit1,a.price1,a.inumber1,a.unit2,a.price2,a.inumber2,
	a.unit3,a.price3,a.inumber3,a.unit4,a.price4,a.inumber4,a.adds,number=0.000,b.condgp1,b.condgp2,b.flag0,b.flag1,b.flag2,b.flag3,b.flag4,b.flag5,b.flag6,b.flag7,b.flag8,b.flag9,
	b.flag10,b.flag11,b.flag12,b.flag13,b.flag14,b.flag15,b.flag16,b.flag17,b.flag18,b.flag19,
	b.th_sort,b.plucode,a.happy from #plu a,pos_plu b where a.id = b.id and b.flag1 = 'T'
 order by b.plucode,b.code
   
return 0
;