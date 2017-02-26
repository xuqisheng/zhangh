
if exists ( select * from sysobjects where name = 'p_gl_info_info_pmsgraph' and type ='P')
	drop proc p_gl_info_info_pmsgraph;
create proc p_gl_info_info_pmsgraph
	@pc_id			char(4), 
	@modu_id			char(2),
	@class_set		varchar(255)

as
-------------------------------------------
-- 经理查询部门表数据准备
-------------------------------------------

declare
	@date				datetime,
	@class			char(8),
	@cclass			char(8),
	@value			money,
	@vpos				integer

delete info_pmsgraph where pc_id = @pc_id and modu_id = @modu_id
if (select count(distinct date) from info_analyze where pc_id = @pc_id and modu_id = @modu_id) > 30
	insert info_pmsgraph (pc_id, modu_id, date, descript)
		select distinct pc_id, modu_id, date, convert(char(5), date, 1) + '(' + ltrim(descriptx) + ')'
		from info_analyze where pc_id = @pc_id and modu_id = @modu_id
else
	insert info_pmsgraph (pc_id, modu_id, date, descript)
		select distinct pc_id, modu_id, date, convert(char(2), date, 105) + '(' + ltrim(descriptx) + ')'
		from info_analyze where pc_id = @pc_id and modu_id = @modu_id
if (select min(value) from info_analyze where pc_id = @pc_id and modu_id = @modu_id) > 5000
	update info_analyze set value = value / 10000 where pc_id = @pc_id and modu_id = @modu_id
declare c_msgraph cursor for
	select date, class, value from info_analyze
	where pc_id = @pc_id and modu_id = @modu_id order by class, date
select @class_set = ltrim(@class_set), @cclass = ''
open c_msgraph
fetch c_msgraph into @date, @class, @value
while @@sqlstatus = 0
	begin
	if @cclass <> @class
		select @cclass = @class, @vpos = convert(int, (charindex(@class + ',', @class_set) + 8) / 9)
	if @vpos = 1
		update info_pmsgraph set v1 = v1 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 2
		update info_pmsgraph set v2 = v2 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 3
		update info_pmsgraph set v3 = v3 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 4
		update info_pmsgraph set v4 = v4 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 5
		update info_pmsgraph set v5 = v5 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 6
		update info_pmsgraph set v6 = v6 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 7
		update info_pmsgraph set v7 = v7 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 8
		update info_pmsgraph set v8 = v8 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 9
		update info_pmsgraph set v9 = v9 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 10
		update info_pmsgraph set v10 = v10 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 11
		update info_pmsgraph set v11 = v11 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 12
		update info_pmsgraph set v12 = v12 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 13
		update info_pmsgraph set v13 = v13 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 14
		update info_pmsgraph set v14 = v14 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 15
		update info_pmsgraph set v15 = v15 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 16
		update info_pmsgraph set v16 = v16 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 17
		update info_pmsgraph set v17 = v17 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 18
		update info_pmsgraph set v18 = v18 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 19
		update info_pmsgraph set v19 = v19 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 20
		update info_pmsgraph set v20 = v20 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 21
		update info_pmsgraph set v21 = v21 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 22
		update info_pmsgraph set v22 = v22 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 23
		update info_pmsgraph set v23 = v23 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 24
		update info_pmsgraph set v24 = v24 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 25
		update info_pmsgraph set v25 = v25 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 26
		update info_pmsgraph set v26 = v26 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 27
		update info_pmsgraph set v27 = v27 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 28
		update info_pmsgraph set v28 = v28 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 29
		update info_pmsgraph set v29 = v29 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 30
		update info_pmsgraph set v30 = v30 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	if @vpos = 31
		update info_pmsgraph set v31 = v31 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 32
		update info_pmsgraph set v32 = v32 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 33
		update info_pmsgraph set v33 = v33 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 34
		update info_pmsgraph set v34 = v34 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 35
		update info_pmsgraph set v35 = v35 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 36
		update info_pmsgraph set v36 = v36 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 37
		update info_pmsgraph set v37 = v37 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 38
		update info_pmsgraph set v38 = v38 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 39
		update info_pmsgraph set v39 = v39 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	else if @vpos = 40
		update info_pmsgraph set v40 = v40 + @value where pc_id = @pc_id and modu_id = @modu_id and date = @date
	fetch c_msgraph into @date, @class, @value
	end
close c_msgraph
deallocate cursor c_msgraph
update info_pmsgraph set vtl = v1+v2+v3+v4+v5+v6+v7+v8+v9+v10+v11+v12+v13+v14+v15+v16+v17+v18+v19+v20+v21+v22+v23+v24+v25+v26+v27+v28+v29+v30+v31+v32+v33+v34+v35+v36+v37+v38+v39+v40
	where pc_id = @pc_id and modu_id = @modu_id
return 0
;
