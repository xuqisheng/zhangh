if  exists(select * from sysobjects where name = 'p_gl_audit_rmpost_recalculate')
	drop proc p_gl_audit_rmpost_recalculate;

create proc p_gl_audit_rmpost_recalculate
	@pc_id				char(4),
	@mdi_id				integer,
	@accnt				char(10),
	@qtrate				money,
	@setrate				money,
	@packages			char(50),
	@arr					datetime,
	@dep					datetime,
	@langid				integer = 0
as
declare
	@gstno				integer, 
	@class				char(1),
	@rm_deptno			char(3),
	@rmpostdate			datetime,
	@w_or_h				integer, 
	@rmrate				money,
	@charge1				money, 
	@charge2				money, 
	@charge3				money, 
	@charge4				money, 
	@charge5				money, 
	@package_c			money,
	@mode					char(10),
	@operation			char(57), 
	@ret					integer
//
create table #rmpost
(
	date			datetime		not null,							/*传票日期*/
	mode			char(10)		not null,
	number		integer		not null,
	charge1		money			default 0 not null,				/*借方数,记录客人消费*/
	charge2		money			default 0 not null,
	pccode		char(5)		not null,
	tofrom		char(2)		not null
)
select @rm_deptno = value from sysoption where catalog = 'audit' and item = 'room_charge_deptno'
//
select @gstno = gstno, @class = class from master where accnt = @accnt
insert #rmpost select date, mode, number, charge, 0, pccode, tofrom from account where accnt = @accnt
insert #rmpost select date, mode, number, charge, 0, pccode, tofrom from account where accntof = @accnt
delete #rmpost from pccode a where (#rmpost.pccode = a.pccode and a.deptno <> @rm_deptno)
	or #rmpost.tofrom != '' or #rmpost.date < @arr or #rmpost.date >= @dep
//
delete rmpostpackage where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt
delete rmpostvip where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt
//
declare c_date cursor for 
	select date, mode from #rmpost where charindex(substring(mode, 1, 1), 'JjBbNP') > 0
open c_date
fetch c_date into @rmpostdate, @mode
while @@sqlstatus = 0
	begin
	if charindex(substring(@mode, 1, 1), 'JBN') > 0
		select @w_or_h = 1
	else
		select @w_or_h = 2
	if charindex(substring(@mode, 1, 1), 'JjBb') > 0
		select @operation = 'RN' + @packages + convert(char(5), @gstno) + @class
	else
		select @operation = 'RD' + @packages + convert(char(5), @gstno) + @class
	select @rmrate = 0, @charge1 = 0, @charge2 = 0, @charge3 = 0, @charge4 = 0, @charge5 = 0
	exec @ret = p_gl_audit_rmpost_calculate @rmpostdate, @accnt, @w_or_h, @rmrate, @qtrate, @setrate,
		@charge1 out, @charge2 out, @charge3 out, @charge4 out, @charge5 out, @operation, @pc_id, @mdi_id
	select @package_c = isnull((select sum(amount) from rmpostpackage
		where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt and rule_calc like '1%'), 0)
	update #rmpost set charge2 = @charge1 - @charge2 + @charge3 + @charge4 + @charge5 + @package_c where current of c_date
//	//
//	if @ret = 0 
//		/* HZDS GaoLiang 1999/10/21 */
//		begin
//		select @srqs = srqs, @tranlog = tranlog from master where accnt = @accnt
////		if charindex('VV', @srqs) > 0
////			begin
////			if exists(select 1 from rmpostvip where pc_id = @pc_id and cusid = @tranlog and charindex(@accnt, accnts) > 0)
////				begin
////				select @pos = charindex('VV', @srqs)
////				update master set srqs = substring(@srqs, 1, @pos - 1) + substring(@srqs, @pos + 4, 18), logmark = logmark + 1 where accnt = @accnt
////				select @ent1 = number1, @ent2 = number2 from rmpostvip where pc_id = @pc_id and cusid = @tranlog
////				select @extrainf = extrainf from cusdef where cusid = @tranlog
////				select @pos = charindex('|', @extrainf)
//////				if @pos = 0
//////					select @pos = 1
////				update cusdef set extrainf = rtrim(convert(char(5), @ent1)) + '/' + rtrim(convert(char(5), @ent2)) + substring(@extrainf, @pos, 30)
////					where cusid = @tranlog
////				end
////			end
//		update master set rmposted = 'T' where accnt = @accnt
//		end
//		select @lastnumb = @lastnumb + 1, @count = @count - 1
	fetch c_date into @rmpostdate, @mode
	end
close c_date
deallocate cursor c_date
if @langid = 0
	select roomno = substring(a.mode, 2, 5), a.date, a.charge1, a.charge2, b.descript, substring(a.mode, 1, 1) 
		from #rmpost a, basecode b where b.cat = 'accntcode_mode' and substring(a.mode, 1, 1) *= b.code 
		order by date
else
	select roomno = substring(a.mode, 2, 5), a.date, a.charge1, a.charge2, b.descript1, substring(a.mode, 1, 1) 
		from #rmpost a, basecode b where b.cat = 'accntcode_mode' and substring(a.mode, 1, 1) *= b.code 
		order by date
;

