/* Rebate±¨±í */

if exists(select * from sysobjects where name = "p_gl_audit_rebaterep" and type = "P")
	drop proc p_gl_audit_rebaterep;

create proc p_gl_audit_rebaterep
	@ret				integer		out, 
	@msg				varchar(70)	out
as
declare
	@bdate			datetime, 
	@bfdate			datetime, 
	@duringaudit	char(1), 
	@isfstday		char(1), 
	@isyfstday		char(1), 
	@modu_id			char(2), 
	@accnt			char(10),
	@number			integer,
	@paycode			char(5),
	@pccode			char(5),
	@roomno			char(5),
	@tag				char(3),
	@jierep			char(8), 
	@tail				char(2), 
	@dcharge			money,
	@charge			money,
	@charge1			money,
	@charge2			money,
	@charge3			money,
	@charge4			money,
	@charge5			money

select @ret = 0, @msg = ''
/* ---------Initialization--------------- */
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
//
exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
if @isfstday ='T'
	truncate table rebaterep
else if exists ( select 1 from rebaterep where date = @bdate )
	update rebaterep set 
		month01 = month01 - day01, month02 = month02-day02, month03 = month03-day03, 
		month04 = month04 - day04, month05 = month05-day05, month06 = month06-day06, 
 		month07 = month07 - day07, month08 = month08-day08, month09 = month09-day09, 
		month99 = month99 - day99
update rebaterep set day01 = 0, day02 = 0, day03 = 0, day04 = 0, day05 = 0, day06 = 0, day07 = 0, day08 = 0, day09 = 0, day99 = 0, date = @bfdate
//
declare c_front cursor for 
	select a.modu_id, a.accnt, a.number, a.charge, a.paycode, a.pccode, c.jierep, c.tail
	from account_detail a, pccode b, pccode c
	where a.modu_id <> '04' and a.paycode = b.pccode and not b.deptno8 in ('', '#') and a.pccode = c.pccode
open c_front
fetch c_front into @modu_id, @accnt, @number, @dcharge, @paycode, @pccode, @jierep, @tail
while @@sqlstatus = 0
	begin
	if @modu_id = '02'
		begin
		select @accnt = a.accnt, @tag = a.tag, @charge = a.charge, @charge1 = a.charge1, @charge2 = a.charge2, 
			@charge3 = a.charge3, @charge4 = a.charge4, @charge5 = a.charge5, @roomno = a.roomno
			from outtemp a where a.accnt = @accnt and a.number = @number
		if @dcharge = 0
			select @charge = 0, @charge1 = 0, @charge2 = 0, @charge3 = 0, @charge4 = 0, @charge5 = 0
		else if @dcharge != @charge and @charge<>0 
			begin
			select @charge = @dcharge, @charge1 = @charge1 * (@dcharge / @charge), @charge2 = @charge2 * (@dcharge / @charge),
				@charge3 = @charge3 * (@dcharge / @charge), @charge4 = @charge4 * (@dcharge / @charge), @charge5 = @charge5 * (@dcharge / @charge)
			select @charge1 = @charge + @charge2 - @charge3 - @charge4 - @charge5
			end
		else 
			select @charge = @dcharge, @charge1 = @dcharge, @charge2 = 0, @charge3 = 0, @charge4 = 0, @charge5 = 0
		end
	else
		select @charge = @dcharge, @charge1 = 0, @charge2 = 0, @charge3 = 0, @charge4 = 0, @charge5 = 0 
	exec p_gl_audit_rebaterep_jie @jierep, @tail, @roomno, @paycode, @pccode, @tag, @charge, @charge1, @charge2, @charge3, @charge4, @charge5
	fetch c_front into @modu_id, @accnt, @number, @dcharge, @paycode, @pccode, @jierep, @tail
	end
close c_front
deallocate cursor c_front
//
declare c_pos cursor for 
	select b.pccode, a.pccode, a.amount3, c.jierep, c.tail
		from pos_detail_jie a, pccode b, pos_itemdef c
		where a.date = @bdate and a.type = b.pccode and not b.deptno8 in ('', '#') and a.pccode = c.pccode and a.tocode = c.code
open c_pos
fetch c_pos into @paycode, @pccode, @charge, @jierep, @tail
while @@sqlstatus = 0
	begin
	exec p_gl_audit_rebaterep_jie @jierep, @tail, '', @paycode, @pccode, '', @charge, 0, 0, 0, 0, 0
	fetch c_pos into @paycode, @pccode, @charge, @jierep, @tail
	end
close c_pos
deallocate cursor c_pos
//
update rebaterep set day99 = day01 + day02 + day03 + day04 + day05 + day06 + day07
update rebaterep set
	month01 = month01 + day01, month02 = month02 + day02, month03 = month03 + day03, 
	month04 = month04 + day04, month05 = month05 + day05, month06 = month06 + day06, 
	month07 = month07 + day07, month08 = month08 + day08, month09 = month09 + day09, 
	month99 = month99 + day99, date	 = @bdate
delete yrebaterep where date = @bdate
insert yrebaterep select * from rebaterep
return @ret
;
