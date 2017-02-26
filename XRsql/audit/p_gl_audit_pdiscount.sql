
if exists (select * from sysobjects where name = 'p_gl_audit_pdiscount' and type = 'P')
	drop proc p_gl_audit_pdiscount;
create proc p_gl_audit_pdiscount
	@pc_id		char(4), 
	@date			datetime,
	@mode			char(1), 							-- D,M,Y
	@paycodes	char(255) = 'DSC#ENT#ZZZ',
	@tag			char(6) = 'PCCODE' 				-- PCCODE,DEPTNO
as
-- 转储数据到临时表供打印 
declare 
	@codes		varchar(255), 
	@key0			char(5), 
	@code			char(5), 
	@day			money, 
	@month		money, 
	@year			money, 
	@fee			money, 
	@vpos			integer

delete pdiscount where pc_id = @pc_id
insert pdiscount (pc_id, key0, descript)
	select distinct @pc_id, a.key0, b.descript
		from ydiscount a, basecode b
			where b.cat='reason_type' and a.date = @date and a.key0 = b.code and charindex(rtrim(a.paycode), @paycodes) > 0
--
if @tag = 'PCCODE'
	begin
	declare c_code cursor for 
		select distinct pccode 
			from ydiscount 
			where date = @date and charindex(rtrim(paycode), @paycodes) > 0 and 
				((@mode = "D" and day <> 0) or (@mode = "M" and month <> 0) or (@mode = "Y" and year <> 0)) 
			order by pccode
	declare c_discount cursor for 
		select key0, pccode, day, month, year 
			from ydiscount 
			where date = @date and charindex(rtrim(paycode), @paycodes) > 0 
			order by key0
	end
else
	begin
	declare c_code cursor for 
		select distinct b.deptno 
			from ydiscount a, pccode b
			where date = @date and charindex(rtrim(paycode), @paycodes) > 0 and a.pccode = b.pccode and
				((@mode = "D" and day <> 0) or (@mode = "M" and month <> 0) or (@mode = "Y" and year <> 0)) 
			order by b.deptno
	declare c_discount cursor for 
		select a.key0, b.deptno, a.day, a.month, a.year 
			from ydiscount a, pccode b
			where date = @date and charindex(rtrim(paycode), @paycodes) > 0 and a.pccode = b.pccode
			order by key0
	end

-- 
open c_code
fetch c_code into @code
while @@sqlstatus = 0
begin
	select @codes = @codes + substring(@code+space(5),1,5) + '#'
	fetch c_code into @code
end
close c_code
deallocate cursor c_code

--
open c_discount
fetch c_discount into @key0, @code, @day, @month, @year
while @@sqlstatus = 0
	begin
	if @mode = 'D'
		select @fee = @day
	else if @mode = 'M'
		select @fee = @month
	else
		select @fee = @year
	select @vpos = (charindex(@code, @codes) + 5) / 6
	if @vpos = 1
		update pdiscount set v1 = v1 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 2
		update pdiscount set v2 = v2 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 3
		update pdiscount set v3 = v3 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 4
		update pdiscount set v4 = v4 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 5
		update pdiscount set v5 = v5 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 6
		update pdiscount set v6 = v6 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 7
		update pdiscount set v7 = v7 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 8
		update pdiscount set v8 = v8 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 9
		update pdiscount set v9 = v9 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 10
		update pdiscount set v10 = v10 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 11
		update pdiscount set v11 = v11 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 12
		update pdiscount set v12 = v12 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 13
		update pdiscount set v13 = v13 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 14
		update pdiscount set v14 = v14 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 15
		update pdiscount set v15 = v15 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 16
		update pdiscount set v16 = v16 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 17
		update pdiscount set v17 = v17 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 18
		update pdiscount set v18 = v18 + @fee where pc_id = @pc_id and key0 = @key0
	else if @vpos = 19
		update pdiscount set v19 = v19 + @fee where pc_id = @pc_id and key0 = @key0
	else 
		update pdiscount set v20 = v20 + @fee where pc_id = @pc_id and key0 = @key0
	fetch c_discount into @key0, @code, @day, @month, @year
	end
close c_discount
deallocate cursor c_discount
update pdiscount set vtl = v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 + v12 + v13 + v14 + v15 + v16 + v17 + v18 + v19 + v20
	where pc_id = @pc_id
return 0
;