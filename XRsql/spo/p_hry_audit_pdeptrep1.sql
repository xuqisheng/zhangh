create proc p_hry_audit_pdeptrep1
	@pc_id		char(4),
	@date			datetime,
	@shift		char(1),
	@empno		char(10),
	@deptno		char(2),
	@daymark		char(1)

as

declare
	@codes		char(255),
	@code			char(3),
	@ccode		char(3),
	@cshift		char(1),
	@pccode		char(3),
	@fee			money,
	@vpos			integer,
	@tl			money,
	@count		money,
	@avfee		money,
	@jiedai		char(1),
	@itemcnt		integer

if rtrim (@shift) is null
	select @shift = '9'
if rtrim (@empno) is null
	select @empno = '{{{'
if rtrim (@daymark) is null
	select @daymark = 'D'
        
declare c_code cursor for select code from pos_namedef
	where deptno = @deptno and code <= '099' order by code
open c_code
fetch c_code into @code
while @@sqlstatus = 0
	begin
	select @codes = @codes + @code+ '#'
	fetch c_code into @code
	end

delete pdeptrep1 where pc_id = @pc_id
insert pdeptrep1 (pc_id, pccode, shift, descript2, descript)
	select @pc_id, b.pccode, '1', b.descript, 'Ôç°à' from pccode a, pos_pccode b where  a.deptno = @deptno and a.pccode = b.chgcod
insert pdeptrep1 (pc_id, pccode, shift, descript2, descript)
	select @pc_id, b.pccode, '2', b.descript,  'ÖÐ°à' from pccode a, pos_pccode b where  a.deptno = @deptno and a.pccode = b.chgcod
insert pdeptrep1 (pc_id, pccode, shift, descript2, descript)
	select @pc_id, b.pccode, '3', b.descript, 'Íí°à' from pccode a, pos_pccode b where  a.deptno = @deptno and a.pccode = b.chgcod
                                                               
                                                                                                         
   
if charindex(@daymark, 'mM') > 0
	declare c_ydeptjie cursor for select a.pccode, a.shift, a.code, a.feem
		from ydeptjie a, pccode b,pos_pccode c
		where a.date = @date and a.empno = @empno and a.pccode = c.pccode and c.chgcod = b.pccode and b.deptno = @deptno
		and ((shift= @shift and @shift != '9') or (@shift = '9' and shift != '9'))
		and (a.code <= '099' or a.code = 'ZZZ')
		order by pccode, shift, code
else
	declare c_ydeptjie cursor for select a.pccode, a.shift, a.code, a.feed
		from ydeptjie a, pccode b,pos_pccode c
		where a.date = @date and a.empno = @empno and a.pccode = c.pccode and c.chgcod = b.pccode  and b.deptno = @deptno
		and ((shift = @shift and @shift != '9') or (@shift = '9' and shift != '9'))
		and (a.code <= '099' or a.code = 'ZZZ')
		order by pccode, shift, code
select @ccode = ''
open c_ydeptjie
fetch c_ydeptjie into @pccode, @cshift,@code, @fee
while @@sqlstatus = 0
	begin
	if @ccode <> @code
		select @ccode = @code, @vpos = convert(int, (charindex(@code, @codes) + 3) / 4)
	if @vpos = 1
		update pdeptrep1 set v1 = v1 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 2
		update pdeptrep1 set v2 = v2 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 3
		update pdeptrep1 set v3 = v3 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 4
		update pdeptrep1 set v4 = v4 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 5
		update pdeptrep1 set v5 = v5 + @fee where pc_id =@pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 6
		update pdeptrep1 set v6 = v6 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 7
		update pdeptrep1 set v7 = v7 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 8
		update pdeptrep1 set v8 = v8 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 9
		update pdeptrep1 set v9 = v9 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 10
		update pdeptrep1 set v10 = v10 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 11
		update pdeptrep1 set v11 = v11 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift= '9')
	else if @vpos = 12
		update pdeptrep1 set v12 = v12 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 13
		update pdeptrep1 set v13 = v13 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 14
		update pdeptrep1 set v14 = v14 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 15
		update pdeptrep1 set v15 = v15 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 16
		update pdeptrep1 set v16 = v16 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 17
		update pdeptrep1 set v17 = v17 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 18
		update pdeptrep1 set v18 = v18 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 19
		update pdeptrep1 set v19 = v19 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 20
		update pdeptrep1 set v20 = v20 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 21
		update pdeptrep1 set v21 = v21 + @fee where pc_id = @pc_id and pccode = @pccode
			and(shift = @cshift or shift = '9')
	else if @vpos = 22
		update pdeptrep1 set v22 = v22 + @fee where pc_id= @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 23
		update pdeptrep1 set v23 = v23 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 24
		update pdeptrep1 set v24 = v24 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 25
		update pdeptrep1 set v25 = v25 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 26
		update pdeptrep1 set v26 = v26 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 27
		update pdeptrep1 set v27 = v27 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 28
		update pdeptrep1 set v28 = v28 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift= '9')
	else if @vpos = 29
		update pdeptrep1 set v29 = v29 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 30
		update pdeptrep1 set v30 = v30 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 31
		update pdeptrep1 set v31 = v31 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 32
		update pdeptrep1 set v32 = v32 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 33
		update pdeptrep1 set v33 = v33 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 34
		update pdeptrep1 set v34 = v34 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 35
		update pdeptrep1 set v35 = v35 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 36
		update pdeptrep1 set v36 = v36 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 37
		update pdeptrep1 set v37 = v37 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 38
		update pdeptrep1 set v38 = v38 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 39
		update pdeptrep1 set v39 = v39 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	else if @vpos = 0 or @vpos >= 40
		update pdeptrep1 set v40 = v40 + @fee where pc_id = @pc_id and pccode = @pccode
			and (shift = @cshift or shift = '9')
	fetch c_ydeptjie into @pccode, @cshift, @code, @fee
	end
close c_ydeptjie
deallocate cursor c_ydeptjie
update pdeptrep1 set vtl = v1+v2+v3+v4+v5+v6+v7+v8+v9+v10+v11+v12+v13+v14+v15+v16+v17+v18+v19+v20+v21+v22+v23+v24+v25+v26+v27+v28+v29+v30+v31+v32+v33+v34+v35+v36+v37+v38+v39
	where pc_id = @pc_id
return 0