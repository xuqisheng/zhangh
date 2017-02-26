
/* 房费计算 */
if exists(select * from sysobjects where name = 'p_gl_audit_rmpost_index')
	drop proc p_gl_audit_rmpost_index;

create proc p_gl_audit_rmpost_index
	@date							datetime,
	@types						varchar(255),
	@index						varchar(30)		-- 统计指标

as
declare
	@charge1_sum				money,				/* 房费 */
	@charge2_sum				money,				/* 优惠 */
	@charge3_sum				money,				/* 服务费 */
	@charge4_sum				money,				/* 城建费 */
	@charge5_sum				money,				/* 加床 */
	@charge1						money,				/* 房费 */
	@charge2						money,				/* 优惠 */
	@charge3						money,				/* 服务费 */
	@charge4						money,				/* 城建费 */
	@charge5						money,				/* 加床 */
	@package_i					money,				/* Packages */
	@package_e					money,				/* Packages */
	@operation					char(58),			/* 仅计算房价的标志
															第1位:Ff:正常计算房费(缺省值); Rr:重新计算房费; 小写:带Select返回值; 
															第2位:N稽核房费,D:日租
															第3-52位:Packages
															第53-57位:Gstno
															第58-58位：Class*/
	@pc_id						char(4),				/* 过房租的计算机地址 */
	@mdi_id						integer,				/* 过房租的Mdi */
	@packages					char(50),			/* Master.Packages */
	@accnt						char(10),
	@rmrate						money,
	@qtrate						money,
	@setrate						money,
	@ratecode					char(10),
	@quantity					money,
	@gstno						integer,
	@ret							integer,
	@id							integer    -- rsvsrc 

exec p_yjw_reserve_rsvsrc_calc '','ZZZZ',1 --针对未计算包价明细的 rsvsrc_detail记录进行计算
    
select @pc_id = '9998', @mdi_id = 0, @charge1_sum = 0, @charge2_sum = 0, @charge3_sum = 0, @charge4_sum = 0, @charge5_sum = 0, @package_i = 0, @package_e = 0
declare c_accnt cursor for
	select accnt, id, ratecode, packages, rate, quantity, gstno from rsvsrc where begin_ <= @date and end_ > @date and charindex(type, @types)>0
open c_accnt
fetch c_accnt into @accnt, @id, @ratecode, @packages, @setrate, @quantity, @gstno
while @@sqlstatus = 0
	begin
	if @id = 0 or @packages='' 
		if exists(select 1 from rsvsrc_detail where date_=@date and accnt=@accnt)
			select @ratecode=ratecode, @packages=packages, @setrate=rate,@quantity=quantity,@gstno=gstno 
					from rsvsrc_detail where date_=@date and accnt=@accnt
		select @packages = packages from master where accnt = @accnt
		select @rmrate = @setrate, @qtrate = @setrate, @charge1 = 0, @charge2 = 0, @charge3 = 0, @charge4 = 0, @charge5 = 0,
			@operation = 'FN' + @packages + convert(char(5), @gstno) + 'F'
		exec @ret = p_gl_audit_rmpost_calculate @date, @accnt, 1, @rmrate, @qtrate, @setrate,
			@charge1 out, @charge2 out, @charge3 out, @charge4 out, @charge5 out, @operation, @pc_id, @mdi_id
		select @charge1_sum = @charge1_sum + @charge1 * @quantity,
			@charge2_sum = @charge2_sum + @charge2 * @quantity, @charge3_sum = @charge3_sum + @charge3 * @quantity, 
			@charge4_sum = @charge4_sum + @charge4 * @quantity, @charge5_sum = @charge5_sum + @charge5 * @quantity
		select @package_i = @package_i + isnull((select sum(amount) from rmpostpackage
			where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt and rule_calc like '0%'), 0) * @quantity
		select @package_e = @package_e + isnull((select sum(amount) from rmpostpackage
			where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt and rule_calc like '1%'), 0) * @quantity
		fetch c_accnt into @accnt, @id, @ratecode, @packages, @setrate, @quantity, @gstno
	end
close c_accnt
deallocate cursor c_accnt
if @index = 'Room Revenue Net'
	return @charge1_sum - @charge2_sum + @charge4_sum + @charge5_sum - @package_i
else if @index = 'Room Revenue Include SVC'
	return @charge1_sum - @charge2_sum + @charge3_sum + @charge4_sum + @charge5_sum - @package_i
else if @index = 'Room Revenue Include Packages'
	return @charge1_sum - @charge2_sum + @charge3_sum + @charge4_sum + @charge5_sum + @package_e
;
