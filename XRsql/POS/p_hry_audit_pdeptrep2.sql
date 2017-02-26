drop proc p_hry_audit_pdeptrep2;
create proc p_hry_audit_pdeptrep2
	@pc_id		char(4),
@date			datetime,
@shift		char(1),
@empno		char(10),
@deptno		char(5)
as
declare
@codes		char(255),
@code			char(3),
@ccode		char(3),
@cshift		char(1),
@pccode		char(5),
@feed			money,
@feem			money,
@vpos			integer,
@tl			money,
@count		money,
@avfee		money,
@jiedai		char(1),
@itemcnt		integer

if rtrim (@shift) is null 	select @shift = '9' if rtrim (@empno) is null
select @empno = '{{{'
declare c_code cursor for select code from pos_namedef 	where deptno = @deptno and code <= '099' order by code
open c_code fetch c_code into @code
while @@sqlstatus = 0
	begin
	select @codes = @codes + @code + '#'
	fetch c_code into @code
	end
delete pdeptrep2 where pc_id = @pc_id
insert pdeptrep2 (pc_id, pccode, shift, descript2, descript)
	select @pc_id, b.pccode, '1', b.descript, 'Ôç°à' from pos_pccode b where  b.deptno = @deptno 
insert pdeptrep2 (pc_id, pccode, shift, descript2, descript)
	select @pc_id, b.pccode, '2', b.descript, 'ÖÐ°à' from pos_pccode b where  b.deptno = @deptno
insert pdeptrep2 (pc_id, pccode, shift, descript2, descript)
	select @pc_id, b.pccode, '3', b.descript, 'Íí°à' from pos_pccode b where  b.deptno = @deptno
insert pdeptrep2 (pc_id, pccode, shift, descript2, descript)
	select @pc_id, b.pccode, '4', b.descript, 'Ò¹°à' from pos_pccode b where  b.deptno = @deptno

declare c_ydeptjie cursor for select a.pccode, a.shift, a.code, a.feed, a.feem
	from ydeptjie a,pos_pccode c	where a.date = @date and a.empno = @empno and a.pccode = c.pccode 
	and c.deptno = @deptno 	and ((shift = @shift and @shift != '9')
	or (@shift = '9' and shift != '9')) 	order by pccode, shift, code
open c_ydeptjie
fetch c_ydeptjie into @pccode, @cshift, @code, @feed, @feem
while @@sqlstatus = 0
begin
if @code in ('010')
	update pdeptrep2 set d1 = d1 + @feed, m1 = m1 + @feem
	where pc_id = @pc_id and pccode = @pccode and (shift = @cshift or shift = '9')
else if @code in ('020')
	update pdeptrep2 set d2 = d2 + @feed, m2 = m2 + @feem
	where pc_id = @pc_id and pccode = @pccode and (shift = @cshift or shift = '9')
else if @code in ('030')
	update pdeptrep2 set d3 = d3 + @feed, m3 = m3 + @feem
	where pc_id = @pc_id and pccode = @pccode and (shift = @cshift or shift = '9')
else if @code in ('040')
	update pdeptrep2 set d4 = d4 + @feed, m4 = m4 + @feem
	where pc_id = @pc_id and pccode = @pccode and (shift = @cshift or shift = '9')
else if @code in ('ZZX')
	update pdeptrep2 set d6 = d6 + @feed, m6 = m6 + @feem
	where pc_id = @pc_id and pccode = @pccode and (shift = @cshift or shift = '9')
else if @code in ('99A')
	update pdeptrep2 set d7 = d7 + @feed, m7 = m7 + @feem
	where pc_id = @pc_id and pccode = @pccode and (shift = @cshift or shift = '9')
else if @code in ('99C')
	update pdeptrep2 set d9 = d9 + @feed, m9 = m9 + @feem
	where pc_id = @pc_id and pccode = @pccode and (shift = @cshift or shift = '9')
else if @code > '0' and @code < '6'
	update pdeptrep2 set d5 = d5 + @feed, m5 = m5 + @feem
	where pc_id = @pc_id and pccode = @pccode and (shift = @cshift or shift = '9')
fetch c_ydeptjie into @pccode, @cshift, @code, @feed, @feem
end
close c_ydeptjie
deallocate cursor c_ydeptjie
return 0
;