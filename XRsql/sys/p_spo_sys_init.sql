

if object_id('p_spo_sys_init') is not null
	drop proc p_spo_sys_init  ;
create proc p_spo_sys_init
   @initmode varchar(10) = 'A'  -- 'C' code,'A' account detail, 'S' sysoption
as
----------------------------------------------------------
--	foxhis 康乐系统初始化
--
--	参数: C - 清除代码 A - 清除营业数据, S - 设置sysoption 默认值
--
----------------------------------------------------------

if charindex('A',@initmode) > 0
begin
	truncate table sp_menu
	truncate table sp_tmenu
	truncate table sp_hmenu
	
	truncate table sp_dish
	truncate table sp_tdish
	truncate table sp_hdish
	
	truncate table sp_pay
	truncate table sp_tpay
	truncate table sp_hpay
	
	truncate table sp_reserve
	truncate table sp_hreserve
	
	truncate table sp_plaav
	truncate table sp_hplaav
	truncate table sp_plaooo
	truncate table sp_hplaooo
	truncate table sp_pla_use
	
	truncate table sp_menu_bill
	truncate table sp_viptax
	truncate table sp_hviptax
	truncate table sp_mind
	truncate table sp_plan
	
	truncate table sp_remind
	truncate table sp_vipcard
	truncate table sp_vipcard_define
end

-- 
if charindex('A',@initmode) > 0
begin
	truncate table sp_place
	truncate table sp_locker
	truncate table sp_rent
end

-- 
if charindex('S',@initmode) > 0
begin
	update sysoption set value = '07:00:00' where catalog = 'spo' and item = 'begin_time'
	update sysoption set value = 'ABCDEF12' where catalog = 'spo' and item = 'vipcard_type'
	update sysoption set value = '300' where catalog = 'spo' and item = 'system_pccode'
	update sysoption set value = '' where catalog = 'spo' and item = 'place_display'
	update sysoption set value = ' 0.25#' where catalog = 'spo' and item = 'plu_display'
	update sysoption set value = 'ABC' where catalog = 'spo' and item = 'tax_type'
	update sysoption set value = 'F' where catalog = 'spo' and item = 'chare_denifit'
	update sysoption set value = '10' where catalog = 'spo' and item = 'remind_time'
	update sysoption set value = 'T' where catalog = 'spo' and item = 'remind_insert'
	update sysoption set value = '1' where catalog = 'spo' and item = 'rent'
	update sysoption set value = '10' where catalog = 'spo' and item = 'refresh'
end

return 0;
