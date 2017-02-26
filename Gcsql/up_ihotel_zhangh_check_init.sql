DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_check_init`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_zhangh_check_init`(
	IN arg_hotel_group_id	INT,		-- 集团id
	IN arg_hotel_id			INT			-- 酒店id
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ===========================================
	-- 用途:初始化检查
	-- 作者:张惠 2014-10-08
	-- ===========================================
	
	DROP TEMPORARY TABLE IF EXISTS tmp_check_msg;
	CREATE TEMPORARY TABLE tmp_check_msg(
		checkmsg			VARCHAR(255),
		checkcode			VARCHAR(100) DEFAULT '',
		checkdesc			VARCHAR(100) DEFAULT ''
	);
	
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 hotel : ','省份代码 [',province_code,']; 城市代码 [',city_code,'];区域代码 [',district_code,']'),'检查相关代码是否正确','' FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id;	
	INSERT INTO tmp_check_msg SELECT '','','';
	
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 sys_option : ','catalog [',catalog,']; item [',item,']'),set_value,descript FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog='account' AND item IN ('article_detail_mode','balance_transfer_ta_code','business_accnt','check_out_card_sure','day_use_tacode','rm_zore_mode','roomAccnt_accnt','round_size','round_tail','round_ta_pccode','sta_valid');
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 sys_option : ','catalog [',catalog,']; item [',item,']'),set_value,descript FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog='audit' AND item IN ('audit_time_limit','day_use_night_amount','room_night_count_mode','ta_code_for_day_half','ta_code_for_day_whole','ta_code_for_extra_bed','ta_code_for_morning_half','ta_code_for_morning_whole','ta_code_for_room_fee','ta_code_for_room_night','ta_code_for_room_night_count','jiedai_audit_stop');
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 sys_option : ','catalog [',catalog,']; item [',item,']'),set_value,descript FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog='interface' AND item IN ('pos_company_search_area','pos_guest_search_area','pos_remark_coMsg','phone_callno_A','phone_callno_C','phone_callno_D','phone_callno_EFJKM','phone_callno_OTHER','pos_master_account_only_byI','pos_remark_sale');	
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 sys_option : ','catalog [',catalog,']; item [',item,']'),set_value,descript FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog='ratecode' AND item IN ('master_change_rate','master_change_rate_every_day','rsv_rate_round_size','rsv_rate_round_tail','rsv_rate_calculation_mode','day_time_half_rmrate','day_time_whole_rmrate','morning_post_rmfee','morning_time_half_rmrate','morning_time_whole_rmrate');	
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 sys_option : ','catalog [',catalog,']; item [',item,']'),set_value,descript FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog='reserve' AND item IN ('allow_dirty_checkin','default_arr_time','default_dep_time','profile_fix_salesman','resrv_max_stay','resrv_rate_change_to_sub_note','resrv_rate_code_change_to_sub','master_show_invalid_master','master_show_resrv','alert_checkin_credit','master_auto_cite_info','master_to_history_model','use_daily_rsv_rate');		
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 sys_option : ','catalog [',catalog,']; item [',item,']'),set_value,descript FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog='system' AND item IN ('hotel_code','hotel_devision','id_hotel_code','station_hardware_verify','user_password_init','search_mode','search_mode_company','search_mode_guest','search_mode_master','user_occ_rmno_descript','pos_audit_limit');	
	INSERT INTO tmp_check_msg SELECT '','','';
	
	IF NOT EXISTS (SELECT 1 FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno='999') THEN
		INSERT INTO tmp_check_msg SELECT CONCAT('检查 rep_jie : 借方合计classno不为 999 或者不存在借方合计,请注意修改'),'','';
	END IF;
	IF NOT EXISTS (SELECT 1 FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno='998' AND descript LIKE '%款待%') THEN
		INSERT INTO tmp_check_msg SELECT CONCAT('检查 rep_jie : 借方款待classno不为 998,请注意修改'),'','';
	END IF;	
	IF EXISTS (SELECT 1 FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (orderno='' OR orderno IS NULL)) THEN
		INSERT INTO tmp_check_msg SELECT CONCAT('检查 rep_jie : orderno 字段存在空值或空字符串,请注意修改'),'','';
	END IF;
	IF EXISTS (SELECT 1 FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (modeno='' OR modeno IS NULL)) THEN
		INSERT INTO tmp_check_msg SELECT CONCAT('检查 rep_jie : modeno 字段存在空值或空字符串,请注意修改'),'','';
	END IF;
	
	INSERT INTO tmp_check_msg SELECT '','','';	
	
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 code_transaction : 费用码和付款码对应的arrange_code错误,请注意修改'),a.code,a.descript FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.arrange_code=b.code AND b.parent_code='arrangement_bill');
	
	IF EXISTS (SELECT 1 FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (arrange_code='' OR arrange_code IS NULL)) THEN
		INSERT INTO tmp_check_msg SELECT CONCAT('检查 code_transaction : arrange_code 字段存在空值或空字符串,请注意修改'),'','';
	END IF;
	IF EXISTS (SELECT 1 FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (category_code='' OR category_code IS NULL)) THEN
		INSERT INTO tmp_check_msg SELECT CONCAT('检查 code_transaction : category_code 字段存在空值或空字符串,请注意修改'),'','';
	END IF;
	
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 code_transaction : 费用码对应的category_code错误,请注意修改'),a.code,a.descript FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code < '9' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.category_code=b.code AND b.parent_code='revenue_category');
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 code_transaction : 付款码对应的category_code错误,请注意修改'),a.code,a.descript FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code > '9' AND  NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.category_code=b.code AND b.parent_code='payment_category');
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 code_transaction : 费用码对应的cat_posting错误,请注意修改'),a.code,a.descript FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code < '9' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.cat_posting=b.code AND b.parent_code='posting_category');
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 code_transaction : 付款码对应的cat_posting错误,请注意修改'),a.code,a.descript FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code > '9' AND  NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.cat_posting=b.code AND b.parent_code='payment_flag');
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 code_transaction : 费用码对应的cat_bal错误,请注意修改'),a.code,a.descript FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code < '9' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.cat_bal=b.code AND b.parent_code='balance_category');
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 code_transaction : 费用码对应的cat_sum错误,请注意修改'),a.code,a.descript FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code < '9' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.cat_sum=b.code AND b.parent_code='production_category');	
	
	
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 sys_constraint : 市场码默认值不代码存在,请注意修改',a.code),a.parent_code,a.value_default FROM sys_constraint a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code='market' AND a.value_default<>'' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.value_default=b.code AND b.parent_code='market_code');
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 sys_constraint : 来源码默认值不代码存在,请注意修改',a.code),a.parent_code,a.value_default FROM sys_constraint a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code='src' AND a.value_default<>'' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.value_default=b.code AND b.parent_code='src_code');
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 sys_constraint : 渠道码默认值不代码存在,请注意修改',a.code),a.parent_code,a.value_default FROM sys_constraint a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code='channel' AND a.value_default<>'' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.value_default=b.code AND b.parent_code='channel');

	INSERT INTO tmp_check_msg SELECT CONCAT('检查 sys_constraint : 预订类型默认值不代码存在,请注意修改',a.code),a.parent_code,a.value_default FROM sys_constraint a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code='rsvType' AND a.value_default<>'' AND NOT EXISTS(SELECT 1 FROM code_rsv_type b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.value_default=b.code);	
	
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 sys_constraint : 预订类型默认值不代码存在,请注意修改',a.code),a.parent_code,a.value_default FROM sys_constraint a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code='payCode' AND a.value_default<>'' AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.value_default=b.code AND b.arrange_code>'9');	
	
	IF NOT EXISTS (SELECT 1 FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code='idcode' AND code='01') THEN
		INSERT INTO tmp_check_msg SELECT CONCAT('检查 code_base : 证件类别缺失代码 01,请注意修改'),'','';
	END IF;
	IF NOT EXISTS (SELECT 1 FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code='arrangement_bill' AND code IN ('98','99')) THEN
		INSERT INTO tmp_check_msg SELECT CONCAT('检查 code_base : 账单编码缺失代码 98或99,请注意修改'),'','';
	END IF;	
	
	INSERT INTO tmp_check_msg SELECT CONCAT('检查 code_base : 客户系统类别存在多余,请注意修改'),a.code,a.descript FROM code_base a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.parent_code='guest_class' AND a.code NOT IN ('F','G','A','S','C');
	
		
	SELECT * FROM tmp_check_msg;
	DROP TEMPORARY TABLE IF EXISTS tmp_check_msg;
	
	
END$$

DELIMITER ;

-- CALL up_ihotel_zhangh_check_init(1,104);
DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_check_init`;