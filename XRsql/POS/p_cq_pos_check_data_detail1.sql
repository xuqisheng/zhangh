drop proc p_cq_pos_check_data_detail1;
create proc p_cq_pos_check_data_detail1
	@code			char(10)
as
	if @code = 'data_b'			--��������һ���Լ��
	if @code = 'data_a'			--�������ڵ�һ���Լ��
	if @code = 'data_c'			--���������ɼ��
	if @code = 'data_e'			--��������ļ��
	if @code = 'data_d'			--��˵����ɼ��
	if @code = 'data_f'			--����Ƿ����δ������
	if @code = 'data_g'			--��̯����ļ��
	if @code = 'data_h'			--����ײ���ϸ�Ƿ�����
	if @code = 'data_i'			--Ԥ������������
	

return 0;
