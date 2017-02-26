DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_minus_alltable`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_minus_alltable`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_biz_date			DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- =============================================================================
	-- 用途:更新指定日期前所有单子的hotel_id成负数，类似删除工作
	-- 解释:CALL up_ihotel_update_alltable(集团id,酒店id,开始日期)
	-- 作者:张惠 2015-11-03
	-- =============================================================================

	UPDATE account_close_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND gen_biz_date < arg_biz_date;	
	UPDATE account_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;	
	UPDATE account_sub_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE(create_datetime) < arg_biz_date;	
	-- UPDATE accredit_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND expiry_date < arg_biz_date;	
	UPDATE apportion_detail_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;	
	UPDATE master_arrdep_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND trans_date < arg_biz_date;	
	UPDATE master_base_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;	
	UPDATE master_guest_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE(create_datetime) < arg_biz_date;	
	UPDATE master_hung_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE(create_datetime) < arg_biz_date;	
	UPDATE master_snapshot SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date_begin < arg_biz_date;	
	UPDATE master_stalog_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE(rsv_datetime) < arg_biz_date;
	
	UPDATE master_sub_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE(create_datetime) < arg_biz_date;
	UPDATE master_upgrade_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE phone_folio_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE production_detail SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE rep_dai_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE rep_diffchange_price_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE rep_diff_price_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE rep_diff_rate_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE rep_jiedai_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE rep_jie_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE rep_jour_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE rep_pay_sum_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE rep_revenue_type_detail SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE rep_revenue_type_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE rep_rmsale_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE rep_trial_balance_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE rep_zero_price_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE reserve_guest_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE(create_datetime) < arg_biz_date;
	UPDATE resrv_base_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < arg_biz_date;
	UPDATE resrv_guest_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE(create_datetime) < arg_biz_date;
	UPDATE resrv_guest_rmno_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE(create_datetime) < arg_biz_date;
	UPDATE resrv_rmno_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE(create_datetime) < arg_biz_date;
	UPDATE resrv_rm_stat_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE(create_datetime) < arg_biz_date;
	UPDATE rsv_src_cxl_noshow_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE(create_datetime) < arg_biz_date;	
	UPDATE rsv_src_wait_list_history SET hotel_id = - arg_hotel_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE(create_datetime) < arg_biz_date;	
		
END$$

DELIMITER ;

-- CALL up_ihotel_minus_alltable(1,1,'2015-3-26');

-- DROP PROCEDURE IF EXISTS `up_ihotel_minus_alltable`;