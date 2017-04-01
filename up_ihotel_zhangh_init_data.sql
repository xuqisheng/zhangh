DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_init_data`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_zhangh_init_data`()
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==================================================================
	-- 用途：清除不必要的表、数据、日志、过程
	--       初始化一些默认值
	-- 解释: 
	-- 范例: 
	-- 作者：
	-- ==================================================================

	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_group_id 	INT;
	DECLARE var_hotel_id 	INT;
	
	DECLARE c_cursor CURSOR FOR SELECT hotel_group_id,id FROM hotel ORDER BY id;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;	
	
	OPEN c_cursor ;
	SET done_cursor = 0 ;	
	FETCH c_cursor INTO var_group_id,var_hotel_id;	
	WHILE done_cursor = 0 DO
		BEGIN		
			IF EXISTS(SELECT 1 FROM audit_process WHERE hotel_group_id = var_group_id AND hotel_id = var_hotel_id AND descript LIKE '%准备数据%' AND exec_type='A' AND exec_service_name LIKE 'fRmpostSub%') THEN
				UPDATE hotel SET client_type = 'THEF' WHERE hotel_group_id = var_group_id AND id = var_hotel_id;
			ELSE
				UPDATE hotel SET client_type = 'IHOTEL' WHERE hotel_group_id = var_group_id AND id = var_hotel_id;
			END IF;							
		SET done_cursor = 0 ;
		FETCH c_cursor INTO var_group_id,var_hotel_id;  
		END ;
	END WHILE ;
	CLOSE c_cursor ;

	DELETE FROM audit_process WHERE descript IN ('房价差异报表','房价变动报表') AND exec_type='D';
	DELETE FROM audit_process WHERE descript IN ('锦江百时ERP','上传锦江CRM') AND exec_type='D';	

  UPDATE res SET folder_id='';
  UPDATE res SET folder_id='' WHERE name like '%会员%';

  -- only use portal_f
  UPDATE sys_option SET set_value='F' WHERE item='search_front' AND catalog='profile' AND set_value='T';
  UPDATE code_base SET code_category='A' WHERE parent_code='payment_category' AND code='A';
  UPDATE code_base SET code_category='C' WHERE parent_code='payment_category' AND code='C';
  UPDATE code_base SET flag='' WHERE parent_code='payment_category' AND flag<>'J';
	
	-- drop 不必要的表 
	DROP TABLE IF EXISTS _abcde;
	DROP TABLE IF EXISTS _aa;
	DROP TABLE IF EXISTS a;
	DROP TABLE IF EXISTS aa;
	DROP TABLE IF EXISTS _code_maint;
	DROP TABLE IF EXISTS _code_map;
	DROP TABLE IF EXISTS _google_position;
	DROP TABLE IF EXISTS _gridbox_demo;
	DROP TABLE IF EXISTS _input_code_samples;
	DROP TABLE IF EXISTS ar_till2;
	DROP TABLE IF EXISTS code_table_copy;
	DROP TABLE IF EXISTS room_status_1;
	DROP TABLE IF EXISTS rep_dai_history_copy;
	DROP TABLE IF EXISTS rep_jie_history_copy;
	DROP TABLE IF EXISTS rep_jiedai_history_copy;
	DROP TABLE IF EXISTS rep_jour_history_copy;
	DROP TABLE IF EXISTS s;
	DROP TABLE IF EXISTS `sheet1$`;
	DROP TABLE IF EXISTS sys_list_meta2;
	DROP TABLE IF EXISTS tmp_account_1;
	DROP TABLE IF EXISTS tmp_account_audit;
	DROP TABLE IF EXISTS tmp_all_accnt;
	DROP TABLE IF EXISTS tmp_dis_accnt;
	DROP TABLE IF EXISTS tmp_search_bar;
	DROP TABLE IF EXISTS tmp_statistic;
	DROP TABLE IF EXISTS tmp_yield_statistic;
	DROP TABLE IF EXISTS tmp_yield_statistic_c;
	DROP TABLE IF EXISTS toolbar_20111121;
	DROP TABLE IF EXISTS toolbar_favourite_20111121;
	DROP TABLE IF EXISTS toolbar_gds;
	DROP TABLE IF EXISTS yjourrep$;	
	
	-- truncate 不必要的表数据
	TRUNCATE TABLE alchkout;
	TRUNCATE TABLE allouts;
	-- TRUNCATE TABLE guest_production_old;
	-- TRUNCATE TABLE company_production_old;
	
	TRUNCATE TABLE sys_error;	
	TRUNCATE TABLE sys_debug;	
	
	-- delete 历史数据
	DELETE FROM channel_error_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM channel_item_error_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM channel_item_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM channel_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM channel_rmtype_error_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM channel_rmtype_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM code_ratecode_delete_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM code_ratecode_detail_temp WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM code_ratecode_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM code_ratecode_log_copy WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM cti_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM doorcard_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM interface_crs_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM interface_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM phone_folio WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM room_villa_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM rsv_limit_log WHERE DATE(create_datetime) < '2016-1-1';
	DELETE FROM web_service_log WHERE DATE(create_datetime) < '2016-1-1';	
	
	-- drop 不必要的存储过程  | 不在能另一过程中执行，需手工单独执行

--	DROP PROCEDURE IF EXISTS `hhryproc9145`;
--	DROP PROCEDURE IF EXISTS `hhryproc9541`;
--	DROP PROCEDURE IF EXISTS `hhryproc9936`;
--	DROP PROCEDURE IF EXISTS `insert_update_for_ImportCharge`;
--	DROP PROCEDURE IF EXISTS `p_guest_sta_internal1`;
--	DROP PROCEDURE IF EXISTS `p_guest_sta_internal2`;
--	DROP PROCEDURE IF EXISTS `p_guest_sta_internal3`;
--	DROP PROCEDURE IF EXISTS `p_guest_sta_overseas1`;
--	DROP PROCEDURE IF EXISTS `p_guest_sta_overseas2`;
--	DROP PROCEDURE IF EXISTS `p_guest_sta_overseas3`;
--	DROP PROCEDURE IF EXISTS `p_reb_guest_sta_inland`;
--	DROP PROCEDURE IF EXISTS `p_reb_guest_sta_overseas`;
--	DROP PROCEDURE IF EXISTS `p_report_cmslist_v6`;
--	DROP PROCEDURE IF EXISTS `p_report_cmslist_v6_sum`;
--	DROP PROCEDURE IF EXISTS `p_statistic_clear_month`;
--	DROP PROCEDURE IF EXISTS `p_statistic_month`;
--	DROP PROCEDURE IF EXISTS `p_statistic_month_nts_check`;
--	DROP PROCEDURE IF EXISTS `p_statistic_month_save`;
--	DROP PROCEDURE IF EXISTS `p_statistic_rebuild`;
--	DROP PROCEDURE IF EXISTS `p_statistic_year`;
--	DROP PROCEDURE IF EXISTS `p_trans_guest_sta`;
--	DROP PROCEDURE IF EXISTS `rep_business_room_statistic_proc1`;

	
END$$

DELIMITER ;

CALL up_ihotel_zhangh_init_data();

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_init_data`;
