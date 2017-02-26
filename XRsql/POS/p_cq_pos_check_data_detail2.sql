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
	if @code = 'maint_11'			--菜谱常规定义检查
		begin
		insert pos_check_detail
			select 'maint_11','plucode','菜本','',0,pluid,plucode,'','',0,descript,descript1,'plucode','#英文名称为空' 
				from pos_plucode where descript1 = '' or descript1 is null

		insert pos_check_detail
			select 'maint_11','sort','菜类','',0,pluid,plucode,sort,'',0,name1,name2,'sort','#英文名称为空' 
				from pos_sort_all where (name2 = '' or name2 is null) and halt = 'F'
		if exists(select 1 from pos_sort_all a where  a.plucode not in (select plucode from pos_plucode where pluid = a.pluid) and a.halt = 'F')
			

	
		end
	if @code = 'maint_a2'			--菜本与营业点的关系检查
	if @code = 'maint_b1'			--菜类与辅料的关系检查
	if @code = 'maint_b2'			--菜类与打印机的关系检查
	if @code = 'maint_b3'			--菜类与模式的关系检查
	if @code = 'maint_b4'			--菜类与报表数据项的关系检查
	if @code = 'maint_c1'			--菜项的价格定义检查
	if @code = 'maint_c2'			--菜项与辅料的关系检查
	if @code = 'maint_c3'			--菜项与打印机的关系检查
	if @code = 'maint_c4'			--菜项与模式的关系检查
	if @code = 'maint_c5'			--菜项与报表数据项的关系检查
	if @code = 'maint_d1'			--营业点设置常规检查
	if @code = 'maint_e1'			--站点设置常规检查

return 0;
