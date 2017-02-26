drop proc p_cq_pos_check_data;
create proc p_cq_pos_check_data
	@type			char(1),
	@code			char(10)
as

if rtrim(@code) is null
	return 0

if @type='1'
	exec p_cq_pos_check_data_detail1 @code
else if @type='2'
	exec p_cq_pos_check_data_detail2 @code

return 0;
