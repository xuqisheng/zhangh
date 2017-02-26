/* 房租预审 */

if  exists(select * from sysobjects where name = 'p_gl_audit_rmpost_first')
	drop proc p_gl_audit_rmpost_first;

create proc p_gl_audit_rmpost_first
	@operation			char(1)				/* 'S':SELECT返回;''或'R':RETURN返回 */
as
declare
	@accnt				char(10),
	@arr					datetime,
	@ratemode			char(6),
	@rmrate				money,
	@qtrate				money,
	@setrate				money,
	@half_time			datetime,
	@whole_time			datetime,
	@rmposted			char(1),
	@rmpoststa			char(1),
	@rmpostdate			datetime,
	@bdate				datetime,
	@fir					varchar(60),
	//
	@charge1				money, 
	@charge2				money, 
	@charge3				money, 
	@charge4				money, 
	@charge5				money, 
	@package_c			money, 
	@name					varchar(50), 
	@w_or_h				integer,
	//
	@pc_id				char(4), 
	@mdi_id				integer

select @pc_id = '9999', @mdi_id = 0, @w_or_h = 1
select @bdate = bdate, @rmpostdate = dateadd(dd, 1, rmpostdate) from sysdata
delete rmpostbucket where rmpostdate = @rmpostdate and posted = 'F'
delete rmpostpackage where pc_id = @pc_id and mdi_id = @mdi_id
//delete rmpostvip where pc_id = @pc_id and mdi_id = @mdi_id
select @half_time = dateadd(dd, 1, convert(datetime, convert(char(10), @bdate, 111) + ' ' + value))
	from sysoption where catalog = 'ratemode' and item = 't_half_rmrate'
select @whole_time = dateadd(dd, 1, convert(datetime, convert(char(10), @bdate, 111) + ' ' + value))
	from sysoption where catalog = 'ratemode' and item = 't_whole_rmrate'
/* rmpoststa用于控制在部分帐号已过房费, 部分未过而且rmpostdate未置时重复执行 */
declare c_rmpost cursor for select a.accnt, a.arr, a.rmposted, a.rmpoststa, isnull(b.name, a.roomno), isnull(b.address, '')
	from master a, guest b where a.class = 'F' and a.sta = 'I' and a.rmpoststa != '1' and a.arr < @half_time and a.haccnt = b.no
	order by accnt 
open c_rmpost
fetch c_rmpost into @accnt, @arr, @rmposted, @rmpoststa, @name, @fir
while @@sqlstatus = 0
	begin
	if @arr < @whole_time
		select @w_or_h = 1
	else
		select @w_or_h = 2
	//
	exec p_gl_audit_rmpost_calculate @rmpostdate, @accnt, @w_or_h, @rmrate out, @qtrate out, @setrate out,
		@charge1 out, @charge2 out, @charge3 out, @charge4 out, @charge5 out, 'FN', @pc_id, @mdi_id
	select @package_c = isnull((select sum(amount) from rmpostpackage
		where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt and rule_calc like '1%'), 0)
	insert rmpostbucket
		(accnt, roomno, src, class, name, fir, groupno, headname, type, market, ratecode, packages, paycode, rmrate, qtrate, setrate, 
		charge1, charge2, charge3, charge4, charge5, package_c, rtreason, gstno, arr, dep, w_or_h, rmpostdate, logmark, empno, shift)
		select @accnt, roomno, src, class, @name, @fir, groupno, '', type, market, ratecode, packages, paycode, @rmrate, @qtrate, @setrate, 
		@charge1, @charge2, @charge3, @charge4, @charge5, @package_c, rtreason, gstno, arr, dep, @w_or_h, @rmpostdate, logmark, '', ''
		from master where accnt = @accnt
	fetch c_rmpost into @accnt, @arr, @rmposted, @rmpoststa, @name, @fir
	end
close c_rmpost
deallocate cursor c_rmpost
update rmpostbucket set headname = '['+rtrim(b.name)+']', class = a.class
	from master a, guest b where rmpostbucket.rmpostdate = @rmpostdate and rmpostbucket.groupno = a.accnt and a.haccnt = b.no
update rmpostbucket set headname = '[ 散客 ]' where rmpostdate = @rmpostdate and groupno = ''
update rmpostbucket set headname = '[ 长住客 ]', class = 'L' from master a, mktcode b
	where rmpostbucket.rmpostdate = @rmpostdate and rmpostbucket.groupno = '' and rmpostbucket.accnt = a.accnt
	and a.market = b.code and b.flag = 'LON'
//	where rmpostbucket.rmpostdate = @rmpostdate and rmpostbucket.groupno = '' and rmpostbucket.accnt = a.accnt and a.extra like '_1%'
if @operation = 'S'
	select 0, '成功'
return 0
;

