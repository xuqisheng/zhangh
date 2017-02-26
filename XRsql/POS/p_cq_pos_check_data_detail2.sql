drop proc p_cq_pos_check_data_detail2;
create proc p_cq_pos_check_data_detail2
	@type			char(10)
as
declare
	@pluid		int,
	@plucode		char(2),
	@sort			char(4),
	@code			char(6),
	@name1		char(50),
	@name2		char(60),

	@count		int,
	@pccodes		char(200)
	


declare c_plucode cursor for 
	select pluid,plucode,descript,descript1,pccodes from pos_plucode 

declare c_sort cursor for 
	select pluid,sort,name1,name2 from pos_sort_all 

declare c_plu cursor for 
	select id,name1,name2 from pos_plu_all 

select * from pos_sort_all into #pos_osrt where 1=2
delete pos_check_detail where type = @code
	if @code = 'maint_11'			--���׳��涨����
		begin
		insert pos_check_detail
			select 'maint_11','plucode','�˱�','',0,pluid,plucode,'','',0,descript,descript1,'plucode','#Ӣ������Ϊ��' 
				from pos_plucode where descript1 = '' or descript1 is null

		insert pos_check_detail
			select 'maint_11','sort','����','',0,pluid,plucode,sort,'',0,name1,name2,'sort','#Ӣ������Ϊ��' 
				from pos_sort_all where (name2 = '' or name2 is null) and halt = 'F'
		if exists(select 1 from pos_sort_all a where  a.plucode not in (select plucode from pos_plucode where pluid = a.pluid) and a.halt = 'F')
			

	
		end
	if @code = 'maint_a2'			--�˱���Ӫҵ��Ĺ�ϵ���
	if @code = 'maint_b1'			--�����븨�ϵĹ�ϵ���
	if @code = 'maint_b2'			--�������ӡ���Ĺ�ϵ���
	if @code = 'maint_b3'			--������ģʽ�Ĺ�ϵ���
	if @code = 'maint_b4'			--�����뱨��������Ĺ�ϵ���
	if @code = 'maint_c1'			--����ļ۸�����
	if @code = 'maint_c2'			--�����븨�ϵĹ�ϵ���
	if @code = 'maint_c3'			--�������ӡ���Ĺ�ϵ���
	if @code = 'maint_c4'			--������ģʽ�Ĺ�ϵ���
	if @code = 'maint_c5'			--�����뱨��������Ĺ�ϵ���
	if @code = 'maint_d1'			--Ӫҵ�����ó�����
	if @code = 'maint_e1'			--վ�����ó�����

return 0;
