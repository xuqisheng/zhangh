drop proc p_fhb_pos_plumod_record;
create proc p_fhb_pos_plumod_record
	@id	int
as
--记录菜谱，菜价，欢乐时光更新信息到pos_plu_record,方便系统登录时读取信息
--注：@shift = 1 价格取1-3
--		@shift = 2 价格取4-6
--		@shift = 3 价格取7-9
--		@shift = 4 价格取10-12
--		@shift = 5 价格取13-15
declare	@menu	char(5),
			@inumber	int,
			@unit	char(4),
			@price	money,
			@pccode_1	char(3),
			@pccodes	char(255),
			@add	int


delete pos_plu_update
insert pos_plu_update select id,menu,sta from pos_plu

select @menu = menu from pos_plu where id = @id
--新增没有的记录，插入初始信息，前三个价格
--价格写入方式：只有单个价格，则写入；如果多个价格，且不是默认价格，则先写入inumber最小的，如果没有设定营业点价格，
--则设默认价格inumber最小的


	if substring(@menu,1,1) = '1'
	begin
		if not exists( select 1 from pos_plu_record where id = @id )
		insert pos_plu_record select a.pccode,'',a.id,'',a.unit,a.price,a.inumber,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,1,'','','','','',1
 			from pos_price a,pos_plu_update b 
				where a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,1,1) = '1' and b.sta = '0'
					and ((select count(1) from pos_price where id = @id and halt = 'F') = 1 or 
					(a.pccode = '###' and a.inumber = (select min(inumber) from pos_price where id = @id and pccode = '###' and halt = 'F') ) or
					(exists (select 1 from pos_price where id = @id and pccode <> '###' and halt = 'F' group by pccode having a.inumber = min(inumber)))
					)   order by a.id,a.inumber 
		else
		update pos_plu_record set unit1 = a.unit,price1 = a.price,inumber1 = a.inumber,adds = 1
			from pos_price a,pos_plu_update b 
				where a.id = pos_plu_record.id and a.pccode = pos_plu_record.pccode and a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,1,1) = '1' and b.sta = '0'
					and ((select count(1) from pos_price where id = @id and halt = 'F') = 1 or 
					(a.pccode = '###' and a.inumber = (select min(inumber) from pos_price where id = @id and pccode = '###' and halt = 'F') ) or
					(exists (select 1 from pos_price where id = @id and pccode <> '###' and halt = 'F' group by pccode having a.inumber = min(inumber)))
					) 
		declare c_plu1 cursor for 
			select a.pccode,a.inumber,a.unit,a.price from pos_price a,pos_plu_update b,pos_plu_record c 
				where a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,1,1) = '1' and b.sta = '0'
					and (a.id = c.id and a.inumber <> c.inumber1 and a.pccode = c.pccode)
						order by a.inumber
		open c_plu1
		fetch c_plu1 into @pccode_1,@inumber,@unit,@price
		while @@sqlstatus = 0 
		begin
			select @add = adds from pos_plu_record where pccode = @pccode_1 and id = @id
			if @add is null or @add = 0
				select @add = 1
			if @add = 1  
				update pos_plu_record set unit2 = @unit,price2 = @price,inumber2 = @inumber,adds = adds + 1 
					where id = @id and pccode = @pccode_1
			if @add = 2
				update pos_plu_record set unit3 = @unit,price3 = @price,inumber3 = @inumber,adds = adds + 1 
					where id = @id and pccode = @pccode_1
			if @add >= 3
				update pos_plu_record set adds = @add + 1 where id = @id and pccode = @pccode_1

			fetch c_plu1 into @pccode_1,@inumber,@unit,@price
		end
		close c_plu1
		deallocate cursor c_plu1
	end
	else
		update pos_plu_record set unit1 = '',price1 = 0,inumber1 = 0,unit2 = '',price2 = 0,inumber2 = 0,unit3 = '',price3 = 0,inumber3 = 0
			where id = @id
	if substring(@menu,2,1) = '1'
	begin
		if not exists( select 1 from pos_plu_record where id = @id )
		insert pos_plu_record select a.pccode,'',a.id,'','',0,0,'',0,0,'',0,0,a.unit,a.price,a.inumber,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,1,'','','','','',1
 			from pos_price a,pos_plu_update b 
				where a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,2,1) = '1' and b.sta = '0'
					and ((select count(1) from pos_price where id = @id and halt = 'F') = 1 or 
					(a.pccode = '###' and a.inumber = (select min(inumber) from pos_price where id = @id and pccode = '###' and halt = 'F') ) or
					(exists (select 1 from pos_price where id = @id and pccode <> '###' and halt = 'F' group by pccode having a.inumber = min(inumber)))
					)   order by a.id,a.inumber
 	     else
		update pos_plu_record set unit4 = a.unit,price4 = a.price,inumber4 = a.inumber,adds = 1
			from pos_price a,pos_plu_update b 
				where a.id = pos_plu_record.id and a.pccode = pos_plu_record.pccode and a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,2,1) = '1' and b.sta = '0'
					and ((select count(1) from pos_price where id = @id and halt = 'F') = 1 or 
					(a.pccode = '###' and a.inumber = (select min(inumber) from pos_price where id = @id and pccode = '###' and halt = 'F') ) or
					(exists (select 1 from pos_price where id = @id and pccode <> '###' and halt = 'F' group by pccode having a.inumber = min(inumber)))
					) 
		declare c_plu2 cursor for 
			select a.pccode,a.inumber,a.unit,a.price from pos_price a,pos_plu_update b,pos_plu_record c 
				where a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,2,1) = '1' and b.sta = '0'
					and (a.id = c.id and a.inumber <> c.inumber4 and a.pccode = c.pccode)
						order by a.inumber
		open c_plu2
		fetch c_plu2 into @pccode_1,@inumber,@unit,@price
		while @@sqlstatus = 0 
		begin
			select @add = adds from pos_plu_record where pccode = @pccode_1 and id = @id
			if @add is null or @add = 0
				select @add = 1
			if @add = 1  
				update pos_plu_record set unit5 = @unit,price5 = @price,inumber5 = @inumber,adds = adds + 1 
					where id = @id and pccode = @pccode_1
			if @add = 2
				update pos_plu_record set unit6 = @unit,price6 = @price,inumber6 = @inumber,adds = adds + 1 
					where id = @id and pccode = @pccode_1
			if @add >= 3
				update pos_plu_record set adds = @add + 1 where id = @id and pccode = @pccode_1

			fetch c_plu2 into @pccode_1,@inumber,@unit,@price
		end
		close c_plu2
		deallocate cursor c_plu2
	end
	else
		update pos_plu_record set unit4 = '',price4 = 0,inumber4 = 0,unit5 = '',price5 = 0,inumber5 = 0,unit6 = '',price6 = 0,inumber6 = 0
			where id = @id
	if substring(@menu,3,1) = '1'
	begin
		if not exists( select 1 from pos_plu_record where id = @id )
		insert pos_plu_record select a.pccode,'',a.id,'','',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,a.unit,a.price,a.inumber,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,1,'','','','','',1
 			from pos_price a,pos_plu_update b 
				where a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,3,1) = '1' and b.sta = '0'
					and ((select count(1) from pos_price where id = @id and halt = 'F') = 1 or 
					(a.pccode = '###' and a.inumber = (select min(inumber) from pos_price where id = @id and pccode = '###' and halt = 'F') ) or
					(exists (select 1 from pos_price where id = @id and pccode <> '###' and halt = 'F' group by pccode having a.inumber = min(inumber)))
					)   order by a.id,a.inumber 
		else
		update pos_plu_record set unit7 = a.unit,price7 = a.price,inumber7 = a.inumber,adds = 1
			from pos_price a,pos_plu_update b 
				where a.id = pos_plu_record.id and a.pccode = pos_plu_record.pccode and a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,3,1) = '1' and b.sta = '0'
					and ((select count(1) from pos_price where id = @id and halt = 'F') = 1 or 
					(a.pccode = '###' and a.inumber = (select min(inumber) from pos_price where id = @id and pccode = '###' and halt = 'F') ) or
					(exists (select 1 from pos_price where id = @id and pccode <> '###' and halt = 'F' group by pccode having a.inumber = min(inumber)))
					) 
		declare c_plu3 cursor for 
			select a.pccode,a.inumber,a.unit,a.price from pos_price a,pos_plu_update b,pos_plu_record c 
				where a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,3,1) = '1' and b.sta = '0'
					and (a.id = c.id and a.inumber <> c.inumber7 and a.pccode = c.pccode)
						order by a.inumber
		open c_plu3
		fetch c_plu3 into @pccode_1,@inumber,@unit,@price
		while @@sqlstatus = 0 
		begin
			select @add = adds from pos_plu_record where pccode = @pccode_1 and id = @id
			if @add is null or @add = 0
				select @add = 1
			if @add = 1  
				update pos_plu_record set unit8 = @unit,price8 = @price,inumber8 = @inumber,adds = adds + 1 
					where id = @id and pccode = @pccode_1
			if @add = 2
				update pos_plu_record set unit9 = @unit,price9 = @price,inumber9 = @inumber,adds = adds + 1 
					where id = @id and pccode = @pccode_1
			if @add >= 3
				update pos_plu_record set adds = @add + 1 where id = @id and pccode = @pccode_1

			fetch c_plu3 into @pccode_1,@inumber,@unit,@price
		end
		close c_plu3
		deallocate cursor c_plu3
	end
	else
		update pos_plu_record set unit7 = '',price7 = 0,inumber7 = 0,unit8 = '',price8 = 0,inumber8 = 0,unit9 = '',price9 = 0,inumber9 = 0
			where id = @id
	if substring(@menu,4,1) = '1'
	begin
		if not exists( select 1 from pos_plu_record where id = @id )
		insert pos_plu_record select a.pccode,'',a.id,'','',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,a.unit,a.price,a.inumber,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,1,'','','','','',1
 			from pos_price a,pos_plu_update b 
				where a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,4,1) = '1' and b.sta = '0'
					and ((select count(1) from pos_price where id = @id and halt = 'F') = 1 or 
					(a.pccode = '###' and a.inumber = (select min(inumber) from pos_price where id = @id and pccode = '###' and halt = 'F') ) or
					(exists (select 1 from pos_price where id = @id and pccode <> '###' and halt = 'F' group by pccode having a.inumber = min(inumber)))
					)   order by a.id,a.inumber 
		else
		update pos_plu_record set unit10 = a.unit,price10 = a.price,inumber10 = a.inumber,adds = 1
			from pos_price a,pos_plu_update b 
				where a.id = pos_plu_record.id and a.pccode = pos_plu_record.pccode and a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,4,1) = '1' and b.sta = '0'
					and ((select count(1) from pos_price where id = @id and halt = 'F') = 1 or 
					(a.pccode = '###' and a.inumber = (select min(inumber) from pos_price where id = @id and pccode = '###' and halt = 'F') ) or
					(exists (select 1 from pos_price where id = @id and pccode <> '###' and halt = 'F' group by pccode having a.inumber = min(inumber)))
					) 
		declare c_plu4 cursor for 
			select a.pccode,a.inumber,a.unit,a.price from pos_price a,pos_plu_update b,pos_plu_record c 
				where a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,4,1) = '1' and b.sta = '0'
					and (a.id = c.id and a.inumber <> c.inumber10 and a.pccode = c.pccode)
						order by a.inumber
		open c_plu4
		fetch c_plu4 into @pccode_1,@inumber,@unit,@price
		while @@sqlstatus = 0 
		begin
			select @add = adds from pos_plu_record where pccode = @pccode_1 and id = @id
			if @add is null or @add = 0
				select @add = 1
			if @add = 1  
				update pos_plu_record set unit11 = @unit,price11 = @price,inumber11 = @inumber,adds = adds + 1 
					where id = @id and pccode = @pccode_1
			if @add = 2
				update pos_plu_record set unit12 = @unit,price12 = @price,inumber12 = @inumber,adds = adds + 1 
					where id = @id and pccode = @pccode_1
			if @add >= 3
				update pos_plu_record set adds = @add + 1 where id = @id and pccode = @pccode_1

			fetch c_plu4 into @pccode_1,@inumber,@unit,@price
		end
		close c_plu4
		deallocate cursor c_plu4
	end
	else
		update pos_plu_record set unit10 = '',price10 = 0,inumber10 = 0,unit11 = '',price11 = 0,inumber11 = 0,unit12 = '',price12 = 0,inumber12 = 0
			where id = @id
	if substring(@menu,5,1) = '1'
	begin
		if not exists( select 1 from pos_plu_record where id = @id )
		insert pos_plu_record select a.pccode,'',a.id,'','',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,'',0,0,a.unit,a.price,a.inumber,'',0,0,'',0,0,1,'','','','','',1
 			from pos_price a,pos_plu_update b 
				where a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,5,1) = '1' and b.sta = '0'
					and ((select count(1) from pos_price where id = @id and halt = 'F') = 1 or 
					(a.pccode = '###' and a.inumber = (select min(inumber) from pos_price where id = @id and pccode = '###' and halt = 'F') ) or
					(exists (select 1 from pos_price where id = @id and pccode <> '###' and halt = 'F' group by pccode having a.inumber = min(inumber)))
					)   order by a.id,a.inumber 
		else
		update pos_plu_record set unit13 = a.unit,price13 = a.price,inumber13 = a.inumber,adds = 1
			from pos_price a,pos_plu_update b 
				where a.id = pos_plu_record.id and a.pccode = pos_plu_record.pccode and a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,5,1) = '1' and b.sta = '0'
					and ((select count(1) from pos_price where id = @id and halt = 'F') = 1 or 
					(a.pccode = '###' and a.inumber = (select min(inumber) from pos_price where id = @id and pccode = '###' and halt = 'F') ) or
					(exists (select 1 from pos_price where id = @id and pccode <> '###' and halt = 'F' group by pccode having a.inumber = min(inumber)))
					) 
		declare c_plu5 cursor for 
			select a.pccode,a.inumber,a.unit,a.price from pos_price a,pos_plu_update b,pos_plu_record c 
				where a.id = @id and a.id= b.id and a.halt = 'F' and substring(b.menu,5,1) = '1' and b.sta = '0'
					and (a.id = c.id and a.inumber <> c.inumber13 and a.pccode = c.pccode)
						order by a.inumber
		open c_plu5
		fetch c_plu5 into @pccode_1,@inumber,@unit,@price
		while @@sqlstatus = 0 
		begin
			select @add = adds from pos_plu_record where pccode = @pccode_1 and id = @id
			if @add is null or @add = 0
				select @add = 1
			if @add = 1  
				update pos_plu_record set unit14 = @unit,price14 = @price,inumber14 = @inumber,adds = adds + 1 
					where id = @id and pccode = @pccode_1
			if @add = 2
				update pos_plu_record set unit15 = @unit,price15 = @price,inumber15 = @inumber,adds = adds + 1 
					where id = @id and pccode = @pccode_1
			if @add >= 3
				update pos_plu_record set adds = @add + 1 where id = @id and pccode = @pccode_1

			fetch c_plu5 into @pccode_1,@inumber,@unit,@price
		end
		close c_plu5
		deallocate cursor c_plu5
	end
	else
		update pos_plu_record set unit13 = '',price13 = 0,inumber13 = 0,unit14 = '',price14 = 0,inumber14 = 0,unit15 = '',price15 = 0,inumber15 = 0
			where id = @id
/*else
begin
	if substring(@menu,1,1) = '1'
	begin
		if exists (select 1 from pos_plu_record where id = @id and inumber1 = @pinumber)
			update pos_plu_record set unit1 = a.unit,price1 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber1 and a.id = @id and a.inumber = @pinumber
		if exists (select 1 from pos_plu_record where id = @id and inumber2 = @pinumber)
			update pos_plu_record set unit2 = a.unit,price2 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber2 and a.id = @id and a.inumber = @pinumber
		if exists (select 1 from pos_plu_record where id = @id and inumber3 = @pinumber)
			update pos_plu_record set unit3 = a.unit,price3 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber3 and a.id = @id and a.inumber = @pinumber
	end
	if substring(@menu,2,1) = '1'
	begin
		if exists (select 1 from pos_plu_record where id = @id and inumber4 = @pinumber)
			update pos_plu_record set unit4 = a.unit,price4 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber4 and a.id = @id and a.inumber = @pinumber
		if exists (select 1 from pos_plu_record where id = @id and inumber5 = @pinumber)
			update pos_plu_record set unit5 = a.unit,price5 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber5 and a.id = @id and a.inumber = @pinumber
		if exists (select 1 from pos_plu_record where id = @id and inumber6 = @pinumber)
			update pos_plu_record set unit6 = a.unit,price6 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber6 and a.id = @id and a.inumber = @pinumber
	end
	if substring(@menu,3,1) = '1'
	begin
		if exists (select 1 from pos_plu_record where id = @id and inumber7 = @pinumber)
			update pos_plu_record set unit7 = a.unit,price7 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber7 and a.id = @id and a.inumber = @pinumber
		if exists (select 1 from pos_plu_record where id = @id and inumber8 = @pinumber)
			update pos_plu_record set unit8 = a.unit,price8 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber8 and a.id = @id and a.inumber = @pinumber
		if exists (select 1 from pos_plu_record where id = @id and inumber9 = @pinumber)
			update pos_plu_record set unit9 = a.unit,price9 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber9 and a.id = @id and a.inumber = @pinumber
	end
	if substring(@menu,4,1) = '1'
	begin
		if exists (select 1 from pos_plu_record where id = @id and inumber10 = @pinumber)
			update pos_plu_record set unit10 = a.unit,price10 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber10 and a.id = @id and a.inumber = @pinumber
		if exists (select 1 from pos_plu_record where id = @id and inumber11 = @pinumber)
			update pos_plu_record set unit11 = a.unit,price11 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber11 and a.id = @id and a.inumber = @pinumber
		if exists (select 1 from pos_plu_record where id = @id and inumber12 = @pinumber)
			update pos_plu_record set unit12 = a.unit,price12 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber12 and a.id = @id and a.inumber = @pinumber
	end
	if substring(@menu,5,1) = '1'
	begin
		if exists (select 1 from pos_plu_record where id = @id and inumber13 = @pinumber)
			update pos_plu_record set unit13 = a.unit,price13 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber13 and a.id = @id and a.inumber = @pinumber
		if exists (select 1 from pos_plu_record where id = @id and inumber14 = @pinumber)
			update pos_plu_record set unit14 = a.unit,price14 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber14 and a.id = @id and a.inumber = @pinumber
		if exists (select 1 from pos_plu_record where id = @id and inumber15 = @pinumber)
			update pos_plu_record set unit15 = a.unit,price15 = a.price from pos_price a 
				where a.id = pos_plu_record.id and a.inumber = pos_plu_record.inumber15 and a.id = @id and a.inumber = @pinumber
	end
end*/
if substring(@menu,1,1) = '1'
	begin
		--欢乐时光菜价
		update pos_plu_record set happy1 = '1',price1 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber1 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber1 = a.inumber and a.code = b.code and (charindex('1',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate()) 
		update pos_plu_record set happy1 = happy1+'2',price2 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber2 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber2 = a.inumber and a.code = b.code and (charindex('1',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate()) 
		update pos_plu_record set happy1 = happy1+'3',price3 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber3 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber3 = a.inumber and a.code = b.code and (charindex('1',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate()) 
	end
if substring(@menu,2,1) = '1'
	begin
			--欢乐时光菜价
		update pos_plu_record set happy2 = '1',price4 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber4 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber4 = a.inumber and a.code = b.code and (charindex('2',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate()) 
		update pos_plu_record set happy2 = happy2+'2',price5 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber5 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber5 = a.inumber and a.code = b.code and (charindex('2',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate()) 
		update pos_plu_record set happy2 = happy2+'3',price6 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber6 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber6 = a.inumber and a.code = b.code and (charindex('2',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate())
	end
if substring(@menu,3,1) = '1'
	begin
			--欢乐时光菜价
		update pos_plu_record set happy3 = '1',price7 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber7 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber7 = a.inumber and a.code = b.code and (charindex('3',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate()) 
		update pos_plu_record set happy3 = happy3+'2',price8 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber8 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber8 = a.inumber and a.code = b.code and (charindex('3',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate()) 
		update pos_plu_record set happy3 = happy3+'3',price9 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber9 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber9 = a.inumber and a.code = b.code and (charindex('3',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate()) 
	end
if substring(@menu,4,1) = '1'
	begin
			--欢乐时光菜价
		update pos_plu_record set happy4 = '1',price10 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber10 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber10 = a.inumber and a.code = b.code and (charindex('4',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate())
		update pos_plu_record set happy4 = happy4+'2',price11 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber11 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber11 = a.inumber and a.code = b.code and (charindex('4',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate()) 
		update pos_plu_record set happy4 = happy4+'3',price12 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber12 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber12 = a.inumber and a.code = b.code and (charindex('4',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate()) 
	end
if substring(@menu,5,1) = '1'
	begin
			--欢乐时光菜价
		update pos_plu_record set happy5 = '1',price13 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber13 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber13 = a.inumber and a.code = b.code and (charindex('5',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate()) 
		update pos_plu_record set happy5 = happy5+'2',price14 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber14 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber14 = a.inumber and a.code = b.code and (charindex('5',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate()) 
		update pos_plu_record set happy5 = happy5+'3',price15 =  c.price from pos_happytime c where pos_plu_record.id = c.id and pos_plu_record.inumber15 = c.inumber and c.price > 0 and c.code = (select min(a.code) from pos_happytime a,pos_season b where pos_plu_record.id = a.id and pos_plu_record.inumber15 = a.inumber and a.code = b.code and (charindex('5',b.shift)>0 or  b.shift='0')
			and (charindex(convert(char(1),datepart(dw,getdate()) - 1),b.week)>0 or charindex(substring(convert(char(10),getdate(),111),6,5),b.day)>0) and b.begin_ <= getdate() and b.end_ >= getdate()) 
	end

--海鲜默认数量为0，其他默认数量为1
update pos_plu_record set number = 1.000 from pos_plu a where a.id = pos_plu_record.id and a.flag1 <> 'T'
update pos_plu_record set number = 0.000 from pos_plu a where a.id = pos_plu_record.id and a.flag1 = 'T'

--更新pccode1值
if @menu = '00000'
	delete from pos_plu_record where id = @id

if exists(select 1 from pos_plu_record where id = @id and pccode <> '###')
begin
	declare c_pccode cursor for select pccode from pos_plu_record where id = @id and pccode <> '###'
	open c_pccode 
	fetch c_pccode into @pccode_1
	while @@sqlstatus = 0 
	begin 
		select @pccodes = @pccodes + @pccode_1 + '#'
		fetch c_pccode into @pccode_1
	end
	update pos_plu_record set pccode1 = @pccodes where id = @id and rtrim(pccode) = '###'
	close c_pccode
	deallocate cursor c_pccode
	
end;