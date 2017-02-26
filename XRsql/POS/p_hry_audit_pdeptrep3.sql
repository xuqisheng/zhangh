/*---------------------------------------------------------------------------------------*/
//
//		餐饮收款分类汇总报表
//
/*---------------------------------------------------------------------------------------*/

if exists(select 1 from sysobjects where name = 'p_hry_audit_pdeptrep3')
	drop procedure p_hry_audit_pdeptrep3;
create proc p_hry_audit_pdeptrep3
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
	@feem			money,
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

declare c_code cursor for select substring(code,1,3) from basecode where cat ='pos_pay_sort' order by code
open c_code
fetch c_code into @code
while @@sqlstatus = 0
	begin
	select @codes = @codes + @code+ '#'
	fetch c_code into @code
	end

delete pdeptrep1 where pc_id = @pc_id
insert pdeptrep1 (pc_id, pccode, shift, descript2, descript)
	select @pc_id, b.pccode, '1', b.descript, '早市' from  pos_pccode b where  b.deptno = @deptno
insert pdeptrep1 (pc_id, pccode, shift, descript2, descript)
	select @pc_id, b.pccode, '2', b.descript, '午市' from  pos_pccode b where  b.deptno = @deptno 
insert pdeptrep1 (pc_id, pccode, shift, descript2, descript)
	select @pc_id, b.pccode, '3', b.descript, '午茶' from  pos_pccode b where  b.deptno = @deptno 
insert pdeptrep1 (pc_id, pccode, shift, descript2, descript)
	select @pc_id, b.pccode, '4', b.descript, '晚市' from  pos_pccode b where  b.deptno = @deptno 
insert pdeptrep1 (pc_id, pccode, shift, descript2, descript)
	select @pc_id, b.pccode, 'D', b.descript, '小计' from  pos_pccode b where  b.deptno = @deptno 
if @daymark = 'D'
	insert pdeptrep1 (pc_id, pccode, shift, descript2, descript)
		select @pc_id, b.pccode, 'M', b.descript, '月累' from  pos_pccode b where  b.deptno = @deptno 
else
	insert pdeptrep1 (pc_id, pccode, shift, descript2, descript)
		select @pc_id, b.pccode, 'M', b.descript, '年累' from  pos_pccode b where  b.deptno = @deptno 

insert pdeptrep1 (pc_id, pccode, shift, descript2, descript) select @pc_id, 'ZZZ', '1', '合计', '早市' 
insert pdeptrep1 (pc_id, pccode, shift, descript2, descript) select @pc_id, 'ZZZ', '2', '合计', '午市' 
insert pdeptrep1 (pc_id, pccode, shift, descript2, descript) select @pc_id, 'ZZZ', '3', '合计', '午茶' 
insert pdeptrep1 (pc_id, pccode, shift, descript2, descript) select @pc_id, 'ZZZ', '4', '合计', '晚市' 
insert pdeptrep1 (pc_id, pccode, shift, descript2, descript) select @pc_id, 'ZZZ', 'D', '合计', '小计' 
if @daymark = 'D'
	insert pdeptrep1 (pc_id, pccode, shift, descript2, descript) select @pc_id, 'ZZZ', 'M', '合计', '月累' 
else
  	insert pdeptrep1 (pc_id, pccode, shift, descript2, descript) select @pc_id, 'ZZZ', 'M', '合计', '年累' 
                                                             
create table #deptdai (
	pccode		char(3),
	shift			char(1),
	paycode		char(3),
	creditd		money,
	creditm		money
)

if @daymark = 'D'
	insert into #deptdai select a.pccode,a.shift,substring(c.code, 1, 3),sum(a.creditd),sum(a.creditm)
	from   ydeptdai a, pos_pccode b , basecode c 
			where a.date = @date and a.empno = @empno and a.pccode = b.pccode  and b.deptno = @deptno
			and a.shift  != '9'
			and c.cat = 'pos_pay_sort'  and charindex(rtrim(a.paycode)+'#',c.descript1)>0
		group by  a.pccode,a.shift,c.code order by a.pccode,a.shift,c.code
else
	insert into #deptdai select a.pccode,a.shift,substring(c.code, 1, 3),sum(a.creditm),sum(a.credity)
	from   ydeptdai a, pos_pccode b , basecode c 
			where a.date = @date and a.empno = @empno and a.pccode = b.pccode  and b.deptno = @deptno
			and a.shift  != '9'
			and c.cat = 'pos_pay_sort'  and charindex(rtrim(a.paycode)+'#',c.descript1)>0
		group by  a.pccode,a.shift,c.code order by a.pccode,a.shift,c.code
                                                                                                      
declare c_ydeptdai cursor for select a.pccode, a.shift, a.paycode, a.creditd, a.creditm
	from #deptdai a order by a.pccode, a.shift, a.paycode
select @ccode = ''
open c_ydeptdai
fetch c_ydeptdai into @pccode, @cshift,@code, @fee, @feem
while @@sqlstatus = 0
	begin
	if @ccode <> @code
		select @ccode = @code, @vpos = convert(int, (charindex(@code, @codes) + 3) / 4)
	if @vpos = 1
		begin
		update pdeptrep1 set v1 = v1 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v1 = v1 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode ='ZZZ') and shift = 'M'
		end
	else if @vpos = 2
		begin
		update pdeptrep1 set v2 = v2 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v2 = v2 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 3
		begin
		update pdeptrep1 set v3 = v3 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v3 = v3 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 4
		begin
		update pdeptrep1 set v4 = v4 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v4 = v4 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 5
		begin
		update pdeptrep1 set v5 = v5 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v5 = v5 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 6
		begin
		update pdeptrep1 set v6 = v6 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v6 = v6 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 7
		begin
		update pdeptrep1 set v7 = v7 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v7 = v7 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 8
		begin
		update pdeptrep1 set v8 = v8 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v8 = v8 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 9
		begin
		update pdeptrep1 set v9 = v9 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v9 = v9 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 10
		begin
		update pdeptrep1 set v10 = v10 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v10 = v10 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 11
		begin
		update pdeptrep1 set v11 = v11 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v11 = v11 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 12
		begin
		update pdeptrep1 set v12 = v12 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v12 = v12 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 13
		begin
		update pdeptrep1 set v13 = v13 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v13 = v13 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 14
		begin
		update pdeptrep1 set v14 = v14 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v14 = v14 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 15
		begin
		update pdeptrep1 set v15 = v15 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v15 = v15 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 16
		begin
		update pdeptrep1 set v16 = v16 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v16 = v16 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 17
		begin
		update pdeptrep1 set v17 = v17 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v17 = v17 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 18
		begin
		update pdeptrep1 set v18 = v18 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v18 = v18 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 19
		begin
		update pdeptrep1 set v19 = v19 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v19 = v19 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 20
		begin
		update pdeptrep1 set v20 = v20 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v20 = v20 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 21
		begin
		update pdeptrep1 set v21 = v21 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v21 = v21 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 22
		begin
		update pdeptrep1 set v22 = v22 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v22 = v22 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 23
		begin
		update pdeptrep1 set v23 = v23 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v23 = v23 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 24
		begin
		update pdeptrep1 set v24 = v24 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v24 = v24 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 25
		begin
		update pdeptrep1 set v25 = v25 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v25 = v25 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 26
		begin
		update pdeptrep1 set v26 = v26 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v26 = v26 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 27
		begin
		update pdeptrep1 set v27 = v27 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v27 = v27 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 28
		begin
		update pdeptrep1 set v28 = v2 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v28 = v28 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 29
		begin
		update pdeptrep1 set v29 = v29 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v29 = v29 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 30
		begin
		update pdeptrep1 set v30 = v30 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v30 = v30 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 31
		begin
		update pdeptrep1 set v31 = v31 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v31 = v31 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 32
		begin
		update pdeptrep1 set v32 = v32 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v32 = v32 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 33
		begin
		update pdeptrep1 set v33 = v33 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v33 = v33 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 34
		begin
		update pdeptrep1 set v34 = v34 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v34 = v34 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 35
		begin
		update pdeptrep1 set v35 = v35 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v35 = v35 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 36
		begin
		update pdeptrep1 set v36 = v36 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v36 = v36 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 37
		begin
		update pdeptrep1 set v37 = v37 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v37 = v37 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 38
		begin
		update pdeptrep1 set v38 = v38 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v38 = v38 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 39
		begin
		update pdeptrep1 set v39 = v39 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v39 = v39 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	else if @vpos = 0 or @vpos >= 40
		begin
		update pdeptrep1 set v40 = v40 + @fee where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ')
			and (shift = @cshift or shift = '9' or shift = 'D' )
		update pdeptrep1 set v40 = v40 + @feem where pc_id = @pc_id and (pccode = @pccode or pccode = 'ZZZ') and shift = 'M'
		end
	fetch c_ydeptdai into @pccode, @cshift, @code, @fee, @feem
	end
close c_ydeptdai
deallocate cursor c_ydeptdai
update pdeptrep1 set vtl = v1+v2+v3+v4+v5+v6+v7+v8+v9+v10+v11+v12+v13+v14+v15+v16+v17+v18+v19+v20+v21+v22+v23+v24+v25+v26+v27+v28+v29+v30+v31+v32+v33+v34+v35+v36+v37+v38+v39
	where pc_id = @pc_id

return 0;
