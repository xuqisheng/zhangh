if exists(select 1 from sysobjects where name = 'p_cyj_pos_plu_price' and type = 'P')
	drop proc p_cyj_pos_plu_price;
create proc p_cyj_pos_plu_price
	@pccode				char(3),
	@id					int,
	@date					datetime,
	@shift				char(1)
as
-----------------------------------------------------------
-- 取菜价，考虑欢乐时光
-----------------------------------------------------------

create table #plu(
	unit			char(4),
	id				int,
	inumber		int,
	price			money,
	cost			money,
	show			char(1)          -- '1' - Happy time 
)
declare
	@code			char(3),
	@week			char(1),
	@day			char(5)

insert into #plu 
  SELECT pos_price.unit,pos_price.id,pos_price.inumber,pos_price.price,pos_price.cost,'0'   
    FROM pos_price 
	 where ((exists(select 1 from pos_price where pccode = @pccode and id = @id and halt = 'F') and pccode = @pccode and id = @id and halt = 'F') 
		or (not exists(select 1 from pos_price where pccode = @pccode and id = @id and halt = 'F') and pccode = '###' and id = @id and halt = 'F'))
		and not exists(select 1 from pos_happytime a,pos_season b where pos_price.id = a.id and pos_price.inumber = a.inumber and a.code = b.code and (charindex(rtrim(@shift),b.shift)>0 or b.shift='0')
		and (charindex(convert(char(1),datepart(dw,@date)-1),b.week)>0 or charindex(substring(convert(char(10),@date,111),6,5),b.day)>0))
	union
	SELECT pos_price.unit,pos_price.id,pos_price.inumber,
		price = (select c.price from pos_happytime c where pos_price.id = c.id and pos_price.inumber = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_price.id = a.id and pos_price.inumber = a.inumber and a.code = b.code and (charindex(rtrim(@shift),b.shift)>0  or b.shift='0')
			and (charindex(convert(char(1),datepart(dw,@date)-1),b.week)>0 or charindex(substring(convert(char(10),@date,111),6,5),b.day)>0))), 
		pos_price.cost,'0' FROM pos_price  
	where ((exists(select 1 from pos_price where pccode = @pccode and id = @id and halt = 'F') and pccode = @pccode and id = @id and halt = 'F') 
		or (not exists(select 1 from pos_price where pccode = @pccode and id = @id and halt = 'F') and pccode = '###' and id = @id and halt = 'F'))
		and exists(select 1 from pos_happytime a,pos_season b where pos_price.id = a.id and pos_price.inumber = a.inumber and a.code = b.code and (charindex(rtrim(@shift),b.shift)>0 or b.shift='0')
		and (charindex(convert(char(1),datepart(dw,@date)-1),b.week)>0 or charindex(substring(convert(char(10),@date,111),6,5),b.day)>0))
	order by inumber

select unit,id,inumber,price,cost, show FROM #plu order by inumber
;

