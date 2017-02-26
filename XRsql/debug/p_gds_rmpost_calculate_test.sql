
/* 房费计算 */
if exists(select * from sysobjects where name = 'p_gds_rmpost_calculate_test')
	drop proc p_gds_rmpost_calculate_test;
create proc p_gds_rmpost_calculate_test
	@pc_id						char(4),
	@rmpostdate					datetime,
	@qtrate						money,
	@rmrate						money,
	@setrate						money,
	@gstno						int,
	@packages					varchar(50)
as

declare
	@charge1						money,				/* 房费 */
	@charge2						money,				/* 优惠 */
	@charge3						money,				/* 服务费 */
	@charge4						money,				/* 城建费 */
	@charge5						money,
	@accnt						char(10),
	@operation					char(22)

select @accnt='PCID' + @pc_id, @charge1=@gstno, @operation='FN'+@packages

exec p_gl_audit_rmpost_calculate @rmpostdate,@accnt,1,@rmrate out,@qtrate out,@setrate out,
		@charge1 out,@charge2 out,@charge3 out,@charge4 out,@charge5 out,
		@operation,@pc_id,0

select @charge1, @charge2, @charge3, @charge4, @charge5
select * from rmpostpackage where pc_id = @pc_id and mdi_id = 0 and accnt = @accnt // and rule_calc like '1%'

return 0
;


// select * from rmpostpackage;
// select * from rmpostvip;
// select dateadd(ss, -1, dateadd(dd, 2, bdate1)) from sysdata;

//select value from sysoption where catalog = 'audit' and item = 'room_charge_deptno';
//select * from auditprg order by exec_order;



//select * from pccode;
//select * from package;
//

//exec p_gds_rmpost_calculate_test '1.16', '2004.5.21', 2000, 1300, 900, 2, 'NET';

// select * from account where accnt='F405210019';
// select * from pccode order by pccode;

