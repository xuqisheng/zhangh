
-- 0204 û������ simon  

if exists(select * from sysobjects where name = 'p_wz_master_rmcalc_index')
	drop proc p_wz_master_rmcalc_index;

//create proc p_wz_master_rmcalc_index
//	@date							datetime,
//	@accnt						char(10),
//	@index						varchar(30)		-- ͳ��ָ��
//
//as
//---------------------------------------------------
//-- ���Ѽ��� ���ݴ��������ʺ���ͳ�� 
//---------------------------------------------------
//declare
//	@charge1_sum				money,				/* ���� */
//	@charge2_sum				money,				/* �Ż� */
//	@charge3_sum				money,				/* ����� */
//	@charge4_sum				money,				/* �ǽ��� */
//	@charge5_sum				money,				/* �Ӵ� */
//	@charge1						money,				/* ���� */
//	@charge2						money,				/* �Ż� */
//	@charge3						money,				/* ����� */
//	@charge4						money,				/* �ǽ��� */
//	@charge5						money,				/* �Ӵ� */
//	@package_i					money,				/* Packages */
//	@package_e					money,				/* Packages */
//	@operation					char(27),			/* �����㷿�۵ı�־
//															��1λ:Ff:�������㷿��(ȱʡֵ); Rr:���¼��㷿��; Сд:��Select����ֵ; 
//															��2λ:N���˷���,D:����
//															��3-22λ:Packages
//															��23-27λ:Gstno*/
//	@pc_id						char(4),				/* ������ļ������ַ */
//	@mdi_id						integer,				/* �������Mdi */
//	@packages					varchar(50),	 	/* Master.Packages */
//	@accnt0						char(10),
//	@rmrate						money,
//	@qtrate						money,
//	@setrate						money,
//	@ratecode					char(10),
//	@quantity					money,
//	@gstno						integer,
//	@ret							integer,
//	@id							integer    -- rsvsrc 
//
//select @pc_id = '9998', @mdi_id = 0, @charge1_sum = 0, @charge2_sum = 0, @charge3_sum = 0, @charge4_sum = 0, @charge5_sum = 0, @package_i = 0, @package_e = 0
//--
//if exists(select 1 from rsvsrc where accnt = @accnt)
//	select  @accnt0 = accnt, @id = id, @ratecode = ratecode, @packages = packages, @setrate = rate, @quantity = quantity, @gstno = gstno from rsvsrc where begin_ <= @date and end_ > @date and accnt = @accnt
//else if exists(select 1 from master where accnt = @accnt)
//		select  @accnt0 = accnt, @id = 0, @ratecode = ratecode, @packages = packages, @setrate = setrate, @quantity = rmnum, @gstno = gstno from master where arr <= @date and dep > @date and accnt = @accnt
//else if exists(select 1 from hmaster where accnt = @accnt)
//		select  @accnt0 = accnt, @id = 0, @ratecode = ratecode, @packages = packages, @setrate = setrate, @quantity = rmnum, @gstno = gstno from hmaster where arr <= @date and dep > @date and accnt = @accnt
//
//if @id = 0 or @packages='' 
//	select @packages = packages from master where accnt = @accnt0
//
//select @rmrate = @setrate, @qtrate = @setrate, @charge1 = 0, @charge2 = 0, @charge3 = 0, @charge4 = 0, @charge5 = 0,
//	@operation = 'RN' + @packages + convert(char(5), @gstno)
//exec @ret = p_gl_audit_rmpost_calculate @date, @accnt0, 1, @rmrate, @qtrate, @setrate,
//	@charge1 out, @charge2 out, @charge3 out, @charge4 out, @charge5 out, @operation, @pc_id, @mdi_id
//select @charge1_sum = @charge1_sum + @charge1 * @quantity,
//	@charge2_sum = @charge2_sum + @charge2 * @quantity, @charge3_sum = @charge3_sum + @charge3 * @quantity, 
//	@charge4_sum = @charge4_sum + @charge4 * @quantity, @charge5_sum = @charge5_sum + @charge5 * @quantity
//select @package_i = @package_i + isnull((select sum(amount) from rmpostpackage
//	where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt0 and rule_calc like '0%'), 0) * @quantity
//select @package_e = @package_e + isnull((select sum(amount) from rmpostpackage
//	where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt0 and rule_calc like '1%'), 0) * @quantity
//
//
//
//-- 
//if @index = 'Room Revenue Net'
//	return @charge1_sum - @charge2_sum + @charge4_sum + @charge5_sum - @package_i
//else if @index = 'Room Revenue Include SVC'
//	return @charge1_sum - @charge2_sum + @charge3_sum + @charge4_sum + @charge5_sum - @package_i
//else if @index = 'Room Revenue Include Packages'
//	return @charge1_sum - @charge2_sum + @charge3_sum + @charge4_sum + @charge5_sum + @package_e
//;
//