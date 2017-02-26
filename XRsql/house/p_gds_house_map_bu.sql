//------------------------------------------------------------------------------
//	补充房态表  --  楼层焕行
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_gds_house_map_bu' and type='P')
	drop proc p_gds_house_map_bu
;
create proc  p_gds_house_map_bu
	@modu_id		char(2),
	@pc_id		char(4)
as
declare   	@flr		char(3),
				@line		int,
				@num		int,
				@yu		int

create table #hsmap_flr (
	flr			char(3)						not null,
	num			int 			default 0 	not null
)

delete hsmap_bu  where modu_id=@modu_id and pc_id=@pc_id

insert #hsmap_flr select flr, count(1) from hsmap
	where modu_id=@modu_id and pc_id=@pc_id and bu='F' group by modu_id, pc_id, flr

-- 每行额定的列数
select @line = b.colnum from hs_sysdata a, hs_mapparm b where a.mapcode=b.code

if @line <= 1
	goto P_OUT

declare @rmtmp char(5)

-- 下面的计算不能采用光标
declare   	@flr_min char(3), @flr_max char(3)
select @flr_max = max(flr), @flr_min = min(flr) from #hsmap_flr
select @flr = flr, @num = num from #hsmap_flr where flr = @flr_min
while @flr < @flr_max
	begin

	if (@num % @line) <> 0
		begin
		select @yu = @line - @num % @line

		while @yu > 0
			begin
			select @rmtmp = rtrim(@flr)+substring(convert(char(8),inttohex(160+@yu)),7,2)
			if not exists(select 1 from hsmap_bu where modu_id=@modu_id and pc_id=@pc_id and flr=@flr and oroomno=@rmtmp)
				insert hsmap_bu select @modu_id, @pc_id, @rmtmp, @flr
			select @yu = @yu - 1
			end
		end

	select @flr = min(flr) from #hsmap_flr where flr > @flr
	select @flr = flr, @num = num from #hsmap_flr where flr = @flr

	end

P_OUT:
update hsmap_bu set oroomno = ltrim(oroomno) where modu_id=@modu_id and pc_id=@pc_id

return 0
;
