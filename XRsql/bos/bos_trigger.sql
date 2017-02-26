// ----------------------------------------------------------------------------
//		t_gds_bos_plu_insert
//		t_gds_bos_plu_delete
//		t_gds_bos_plu_update
//
//		t_gds_bos_sort_insert
//		t_gds_bos_sort_delete
//		t_gds_bos_sort_update
//		
//		t_gds_bos_station_insert
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
//		bos_plu trigger 
// ----------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = 't_gds_bos_plu_insert')
	drop trigger t_gds_bos_plu_insert;
create trigger t_gds_bos_plu_insert
on bos_plu for insert
as
declare	@count	integer
if exists (select count(1) from bos_plu a,inserted b
	where a.pccode = b.pccode and a.code = b.code
		group by a.pccode,a.code
			having count(1) > 1)
	begin
	rollback trigger with raiserror 55555 "Attempt to insert duplicate key row in object 'bos_plu' with bos rule/\"
	return
	end
;
if exists(select 1 from sysobjects where name = 't_gds_bos_plu_delete')
	drop trigger t_gds_bos_plu_delete;
create trigger t_gds_bos_plu_delete
on bos_plu for delete
as
if (select count(1) from bos_store a, deleted c where a.pccode = c.pccode and a.code = c.code) > 0
	begin
	rollback trigger with raiserror 55555 "该代码正在使用，不能删除! HRY_MARK"
	return
	end
if (select count(1) from bos_hstore a, deleted c where a.pccode = c.pccode and a.code = c.code) > 0
	begin
	rollback trigger with raiserror 55555 "该代码曾经使用，不能删除! HRY_MARK"
	return
	end
;
if exists(select 1 from sysobjects where name = 't_gds_bos_plu_update')
	drop trigger t_gds_bos_plu_update;
//create trigger t_gds_bos_plu_update
//on bos_plu for update
//as
//declare @ha char(5)
//if update(pccode) or update(code) or update(name) or update(ename) or update(helpcode) or update(unit) or update(price) or update(menu)
//	select @ha = 'ooooo'
//;


// ----------------------------------------------------------------------------
//		bos_sort trigger 
// ----------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = 't_gds_bos_sort_insert')
	drop trigger t_gds_bos_sort_insert;
//create trigger t_gds_bos_sort_insert
//on bos_sort for insert
//as
//declare @ha char(5)
//	select @ha = 'ooooo'
//;
if exists(select 1 from sysobjects where name = 't_gds_bos_sort_delete')
	drop trigger t_gds_bos_sort_delete;
create trigger t_gds_bos_sort_delete
on bos_sort for delete
as
if exists(select 1 from bos_plu a, deleted b 
				where a.pccode = b.pccode and a.sort = b.sort)
	begin
	rollback trigger with raiserror 55555 " 有菜谱使用该类别，不能删除 !HRY_MARK"
	return
	end
;
if exists(select 1 from sysobjects where name = 't_gds_bos_sort_update')
	drop trigger t_gds_bos_sort_update;
create trigger t_gds_bos_sort_update
on bos_sort for update
as
if update(pccode) or update(sort) 
	begin
	rollback trigger with raiserror 55555 "不能修改费用码 和 类别码 !HRY_MARK "
	return
	end
if update(hlpcode)
	update bos_plu set hlpcode=a.hlpcode from deleted a where bos_plu.pccode=a.pccode and bos_plu.sort=a.sort
;


// ----------------------------------------------------------------------------
//		bos_station trigger 
// ----------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = 't_gds_bos_station_insert')
	drop trigger t_gds_bos_station_insert;
create trigger t_gds_bos_station_insert
on bos_station for insert
as
declare 	@num1		int,
			@num2		int
select @num1 = count(1) from bos_station a, inserted b where a.netaddress=b.netaddress
select @num2 = count(distinct modu) from bos_posdef
	where posno in (select a.posno from bos_station a, inserted b where a.netaddress=b.netaddress)
if @num1 <> @num2 
begin
	rollback trigger with raiserror 55555 "一个工作站不能定义 <针对一个模块> 的两个收银点 !HRY_MARK"
	return
end
;
