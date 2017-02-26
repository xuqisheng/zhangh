/* 打印用临时表*/

if exists (select * from sysobjects where name = 'pcashrep' and type = 'U')
	drop table pcashrep;
create table pcashrep
(
	pc_id		char(4), 
	modu_id	char(2), 
	class		char(2)	default '' null, /* '01' 前厅, '02' AR帐, '03', 商务中心, '04', 综合收银 */
	pccode	char(5)	default '' null, 
	descript	char(50)	default '' null, 
	shift		char(1)	default '' null, 
	sname		char(20)	default '' null, 
	empno		char(10)	default '' null, 
	ename		char(20)	default '' null, 
	v1			money		default 0  not null, 
	v2			money		default 0  not null, 
	v3			money		default 0  not null, 
	v4			money		default 0  not null, 
	v5			money		default 0  not null, 
	v6			money		default 0  not null, 
	v7			money		default 0  not null, 
	v8			money		default 0  not null, 
	v9			money		default 0  not null, 
	v10		money		default 0  not null, 
	v11		money		default 0  not null, 
	v12		money		default 0  not null, 
	v13		money		default 0  not null, 
	v14		money		default 0  not null, 
	v15		money		default 0  not null, 
	v16		money		default 0  not null, 
	v17		money		default 0  not null, 
	v18		money		default 0  not null, 
	v19		money		default 0  not null, 
	v20		money		default 0  not null, 
	v21		money		default 0  not null, 
	v22		money		default 0  not null, 
	v23		money		default 0  not null, 
	v24		money		default 0  not null, 
	v25		money		default 0  not null, 
	v26		money		default 0  not null, 
	v27		money		default 0  not null, 
	v28		money		default 0  not null, 
	v29		money		default 0  not null, 
	v30		money		default 0  not null, 
	vtl		money		default 0  not null, 
)
exec sp_primarykey pcashrep, pc_id, modu_id, class, pccode, shift, empno
create unique index index1 on pcashrep(pc_id, modu_id, class, pccode, shift, empno)
;


if exists (select * from sysobjects where name = 'p_hry_audit_pcashrep' and type = 'P')
	drop proc p_hry_audit_pcashrep;
create proc p_hry_audit_pcashrep
	@pc_id		char(4), 
	@modu_id		char(2), 
	@date			datetime,
	@mode			char(10) = 'subtotal',					-- S:按类打印    D:按付款方式打印
	@langid		integer = 0
as
-- 转储数据到临时表供打印 
declare 
	@clsset		varchar(16), 
	@codeset		varchar(255), 
	@cls			char(1), 
	@scls			char(1), 
	@ccode		char(5), 
	@scode		char(5), 
	@class		char(2), 
	@pccode		char(5), 
	@shift		char(1), 
	@sname		char(6), 
	@empno		char(10), 
	@ename		char(12), 
	@fee			money, 
	@vpos			integer

if @mode = 'subtotal'
	begin
	declare c_cls cursor for 
		select distinct cclass from ycashrep where date = @date order by cclass
	open c_cls
	fetch c_cls into @cls
	while @@sqlstatus = 0
		begin
		select @clsset = @clsset + @cls
		fetch c_cls into @cls
		end
	close c_cls
	deallocate cursor c_cls
	end
else
	begin
	declare c_code cursor for 
		select distinct ccode from ycashrep where date = @date order by ccode
	open c_code
	fetch c_code into @ccode
	while @@sqlstatus = 0
		begin
		select @codeset = @codeset + @ccode + '#'
		fetch c_code into @ccode
		end
	close c_code
	deallocate cursor c_code
	end
delete pcashrep where pc_id = @pc_id and modu_id = @modu_id
insert pcashrep (pc_id, modu_id, class, pccode, shift, empno)
	select distinct @pc_id, @modu_id, class, pccode, shift, empno
	from ycashrep where date = @date
declare c_cash cursor for 
	select class, pccode, shift, empno, cclass, ccode, credit from ycashrep where date = @date order by cclass, ccode
select @scls = '', @scode = ''
open c_cash
fetch c_cash into @class, @pccode, @shift, @empno, @cls, @ccode, @fee
while @@sqlstatus = 0
	begin
	if @mode = 'subtotal'
		begin
		if @scls <> @cls
			select @scls = @cls, @vpos = charindex(@cls, @clsset)
		end
	else
		begin
		if @scode <> @ccode
			begin
			select @scode = @ccode, @vpos = charindex(@ccode, @codeset)
			select @vpos = (@vpos + 3) / 4
			end
		end
	if @vpos = 1
		update pcashrep set v1 = v1 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 2
		update pcashrep set v2 = v2 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 3
		update pcashrep set v3 = v3 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 4
		update pcashrep set v4 = v4 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 5
		update pcashrep set v5 = v5 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 6
		update pcashrep set v6 = v6 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 7
		update pcashrep set v7 = v7 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 8
		update pcashrep set v8 = v8 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 9
		update pcashrep set v9 = v9 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 10
		update pcashrep set v10 = v10 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 11
		update pcashrep set v11 = v11 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 12
		update pcashrep set v12 = v12 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 13
		update pcashrep set v13 = v13 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 14
		update pcashrep set v14 = v14 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 15
		update pcashrep set v15 = v15 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 16
		update pcashrep set v16 = v16 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 17
		update pcashrep set v17 = v17 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 18
		update pcashrep set v18 = v18 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 19
		update pcashrep set v19 = v19 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 20
		update pcashrep set v20 = v20 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 21
		update pcashrep set v21 = v21 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 22
		update pcashrep set v22 = v22 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 23
		update pcashrep set v23 = v23 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 24
		update pcashrep set v24 = v24 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 25
		update pcashrep set v25 = v25 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 26
		update pcashrep set v26 = v26 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 27
		update pcashrep set v27 = v27 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 28
		update pcashrep set v28 = v28 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else if @vpos = 29
		update pcashrep set v29 = v29 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	else 
		update pcashrep set v30 = v30 + @fee where pc_id = @pc_id and modu_id = @modu_id and class = @class and pccode = @pccode and shift = @shift and empno = @empno
	fetch c_cash into @class, @pccode, @shift, @empno, @cls, @ccode, @fee
	end
close c_cash
deallocate cursor c_cash
--
update pcashrep set ename = a.name from sys_empno a
	where pcashrep.pc_id = @pc_id and pcashrep.modu_id = @modu_id and pcashrep.empno = a.empno
update pcashrep set vtl = v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 
								+ v11 + v12 + v13 + v14 + v15 + v16 + v17 + v18 + v19 + v20
								+ v21 + v22 + v23 + v24 + v25 + v26 + v27 + v28 + v29 + v30
	where pc_id = @pc_id and modu_id = @modu_id
if @langid = 0
	begin
	update pcashrep set sname = a.descript from basecode a
		where pcashrep.pc_id = @pc_id and pcashrep.modu_id = @modu_id and pcashrep.shift = a.code and a.cat = 'shift'
	update pcashrep set descript = '前厅' where pc_id = @pc_id and modu_id = @modu_id and class = '01'
	update pcashrep set descript = 'AR账' where pc_id = @pc_id and modu_id = @modu_id and class = '02'
	update pcashrep set descript = a.descript from basecode a
		where pcashrep.pc_id = @pc_id and pcashrep.modu_id = @modu_id and pcashrep.class = '03'
		and pcashrep.pccode = a.code and a.cat = 'moduno'
	update pcashrep set descript = a.descript from pccode a
		where pcashrep.pc_id = @pc_id and pcashrep.modu_id = @modu_id and pcashrep.class not in ('01', '02', '03')
		and pcashrep.pccode = a.pccode
	end
else
	begin
	update pcashrep set sname = a.descript1 from basecode a
		where pcashrep.pc_id = @pc_id and pcashrep.modu_id = @modu_id and pcashrep.shift = a.code and a.cat = 'shift'
	update pcashrep set descript = 'FO' where pc_id = @pc_id and modu_id = @modu_id and class = '01'
	update pcashrep set descript = 'AR BACK' where pc_id = @pc_id and modu_id = @modu_id and class = '02'
	update pcashrep set descript = a.descript1 from basecode a
		where pcashrep.pc_id = @pc_id and pcashrep.modu_id = @modu_id and pcashrep.class = '03'
		and pcashrep.pccode = a.code and a.cat = 'moduno'
	update pcashrep set descript = a.descript1 from pccode a
		where pcashrep.pc_id = @pc_id and pcashrep.modu_id = @modu_id and pcashrep.class not in ('01', '02', '03')
		and pcashrep.pccode = a.pccode
	end
return 0
;
