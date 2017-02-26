
if exists (select * from sysobjects where name='p_pos_sys_init' and type='P')
   drop proc p_pos_sys_init;
create proc p_pos_sys_init
   @initmode varchar(10) = 'A'  -- 'C' code,'A' account detail, 'S' sysoption 
as 
----------------------------------------------------------
--	foxhis ����ϵͳ��ʼ�� 
--
--	����: C - ������� A - ���Ӫҵ����, S - ����sysoption Ĭ��ֵ
--
----------------------------------------------------------

--
-- pos  

if charindex('A',@initmode) > 0 
   begin
   truncate table pos_menu
   truncate table pos_tmenu
   truncate table pos_hmenu

   truncate table pos_dish
   truncate table pos_tdish
   truncate table pos_hdish

   truncate table pos_pay
   truncate table pos_tpay
   truncate table pos_hpay

   truncate table pos_dishcard
   truncate table pos_hdishcard

   truncate table pos_hxsale
   truncate table pos_thxsale
   truncate table pos_hhxsale

   truncate table pos_reserve
   truncate table pos_hreserve
   truncate table pos_reserve_log
   truncate table pos_reserve_plu
   truncate table pos_reserveplu

   truncate table pos_tblav
   truncate table pos_rsvdtl
   truncate table pos_rsvpc

   truncate table pos_menu_bill
   truncate table pos_store_plu
	truncate table pos_plu_rela
	truncate table pos_empnoav
	truncate table pos_plutext

   truncate table pos_bar_dtl
   truncate table pos_bar_hdtl
   truncate table pos_bar_mst
   truncate table pos_bar_hmst
   truncate table pos_bar_sale
   truncate table pos_bar_hsale

   truncate table pos_bar_store
   truncate table pos_bar_month
   truncate table pos_bar_sfc

   truncate table pos_detail_jie
   truncate table pos_detail_dai
   truncate table pos_sort_log

   truncate table pos_dish_add
   truncate table pos_assess
   truncate table pos_bkf

   end
if charindex('S',@initmode) > 0 
	begin
	update sysoption set value = 'N'  where catalog ='pos' and item = 'all_using_interface'
	update sysoption set value = 'N'  where catalog ='pos' and item = 'autoprint_guestbill'
	update sysoption set value = 'dw'  where catalog ='pos' and item = 'banquet_print'
	update sysoption set value = 'day'  where catalog ='pos' and item = 'bar_month_mode'
	update sysoption set value = 'N'  where catalog ='pos' and item = 'cost_hxsale_report'
	update sysoption set value = '0.3'  where catalog ='pos' and item = 'costate'
	update sysoption set value = '20'  where catalog ='pos' and item = 'deptno'
	update sysoption set value = '1'  where catalog ='pos' and item = 'detail_savedays'
	update sysoption set value = '1'  where catalog ='pos' and item = 'dish_card_line'
	update sysoption set value = 'yy'  where catalog ='pos' and item = 'dsc_sttype'
	update sysoption set value = 'N'  where catalog ='pos' and item = 'earnest'
	update sysoption set value = 'F'  where catalog ='pos' and item = 'emp_manage'
	update sysoption set value = 'T'  where catalog ='pos' and item = 'fixup_tableno'
	update sysoption set value = 'N'  where catalog ='pos' and item = 'have_yule_system'
	update sysoption set value = '30'  where catalog ='pos' and item = 'hdishcard'
	update sysoption set value = 'N'  where catalog ='pos' and item = 'input_billno'
	update sysoption set value = '3'  where catalog ='pos' and item = 'interface_response_time'
	update sysoption set value = 'XA'  where catalog ='pos' and item = 'map'
	update sysoption set value = '0'  where catalog ='pos' and item = 'map_display'
	update sysoption set value = '5'  where catalog ='pos' and item = 'order_sort_max'
	update sysoption set value = '2'  where catalog ='pos' and item = 'pdeptrep'
	update sysoption set value = '1'  where catalog ='pos' and item = 'pluid'
	update sysoption set value = '3#1,9600,8,N,1,0,1'  where catalog ='pos' and item = 'pos_com'
	update sysoption set value = 'POS'  where catalog ='pos' and item = 'pos_meet'
	update sysoption set value = '1'  where catalog ='pos' and item = 'posstation'
	update sysoption set value = '1'  where catalog ='pos' and item = 'print_count'
	update sysoption set value = '1'  where catalog ='pos' and item = 'print_plu'
	update sysoption set value = '0.25'  where catalog ='pos' and item = 'print_server'
	update sysoption set value = '0'  where catalog ='pos' and item = 'print_set'
	update sysoption set value = 'R999999999'  where catalog ='pos' and item = 'reserve_remark'
	update sysoption set value = 'y'  where catalog ='pos' and item = 'show_room_in_all'
	update sysoption set value = 'T'  where catalog ='pos' and item = 'show_room_no'
	update sysoption set value = '10'  where catalog ='pos' and item = 'showtimes'
	update sysoption set value = '5'  where catalog ='pos' and item = 'table_bmp_pen_width'
	update sysoption set value = 'T'  where catalog ='pos' and item = 'table_share'
	update sysoption set value = 'Y'  where catalog ='pos' and item = 'touch_dsc_card'
	update sysoption set value = 'TOUCH'  where catalog ='pos' and item = 'touch_map'
	update sysoption set value = 'N'  where catalog ='pos' and item = 'touch_open_need_foliono'
	update sysoption set value = 'Y'  where catalog ='pos' and item = 'toucher'
	update sysoption set value = 'N'  where catalog ='pos' and item = 'use_creditcard_no'
	update sysoption set value = 'N'  where catalog ='pos' and item = 'using_interface'
	update sysoption set value = 'F'  where catalog ='pos' and item = 'using_pos_int_pccode'
	end

return 0
;

