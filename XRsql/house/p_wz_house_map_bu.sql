//======================================================
//由于房号和楼层是字符型，因此排序起来是有问题的 
//eg.(6,10)排序是10排前面的  因此要进行类型的转换。 
//by wz
//======================================================

drop proc p_wz_house_map_bu;
create proc p_wz_house_map_bu
		@modu_id 		char(2),
		@pc_id			char(4)
as
declare
	@flr_min		char(3),
	@flr_max		char(3),
	@floor		char(3),
	@floor_min	char(3),
	@floor_max	char(3),
	@yu			int,
	@num			int,
	@column		int,
	@rmno			char(5)

create table #tmp(
		flr 	char(3)
)

create table #hs_flr(
		flr		char(3)     			not null,
		num		int		 default 0
)

delete hsmap_bu where modu_id = @modu_id and pc_id = @pc_id

insert #tmp(flr) select flr from hsmap_new 
	where modu_id = @modu_id and pc_id = @pc_id  
	

insert #hs_flr select flr , count(1) from #tmp group by flr

select @column = b.colnum from sysoption a, hsmap_project b 
	where a.catalog = 'house' and a.item = 'project' and a.value = b.project

if @column <= 1
	goto P_OUT

select @floor_min = min(flr) from #hs_flr  
select @floor_max = max(flr) from #hs_flr

select @floor=flr,@num = num	from #hs_flr where flr = @floor_min
while @floor < @floor_max
	begin
	 if (@num % @column) <> 0
		begin
			select @yu = @column - @num % @column
			while @yu > 0
			 begin
				select @rmno =rtrim(convert(char(2),convert(integer,@floor))) + substring(convert(char(8),inttohex(160 + @yu)),7,2)
				insert hsmap_bu select @modu_id,@pc_id,@rmno,@floor
				select @yu = @yu - 1
			 end
		end
	 select @floor_min = min(flr) from #hs_flr where (convert(integer,flr)) > convert(integer,@floor)
	 select @floor = flr,@num = num from #hs_flr where flr = @floor_min
	end

P_OUT:
update hsmap_bu set oroomno = ltrim(oroomno) where modu_id=@modu_id and pc_id=@pc_id


return 0;
