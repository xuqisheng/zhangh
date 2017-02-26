drop proc p_cq_pos_check_data_detail1;
create proc p_cq_pos_check_data_detail1
	@code			char(10)
as
	if @code = 'data_b'			--主单金额的一致性检查
	if @code = 'data_a'			--主单日期的一致性检查
	if @code = 'data_c'			--销单的理由检查
	if @code = 'data_e'			--联单情况的检查
	if @code = 'data_d'			--冲菜的理由检查
	if @code = 'data_f'			--检查是否存在未定义项
	if @code = 'data_g'			--分摊情况的检查
	if @code = 'data_h'			--检查套菜明细是否输入
	if @code = 'data_i'			--预付定金情况检查
	

return 0;
