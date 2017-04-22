DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_code_init_smart`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_code_init_smart`(
	arg_hotel_group_id	BIGINT(16),
	arg_hotel_id		BIGINT(16)
)
SQL SECURITY INVOKER
label_0:
BEGIN

	DELETE FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM up_status WHERE hotel_id = arg_hotel_id;
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark)VALUES(arg_hotel_id,'init',NOW(),NULL,0,''); 
	
	-- 中间库 migrate_yl.guest建立相关索引,比如:idcls、saleid、class1
	UPDATE migrate_yl.guest SET idcls ='01' WHERE idcls = '?' OR idcls = '';
	UPDATE migrate_yl.guest a,up_map_code b SET a.idcls = b.code_new WHERE b.cat = 'idcode' AND a.idcls = b.code_old AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id;
	UPDATE migrate_yl.guest a,up_map_code b SET a.nation = b.code_new WHERE b.cat = 'nation'  AND a.nation = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_yl.guest a,up_map_code b SET a.country= b.code_new WHERE b.cat = 'country' AND a.nation = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_yl.guest a,up_map_code b SET a.saleid = b.code_new WHERE b.cat = 'saleman' AND a.saleid = b.code_old AND a.saleid<>'' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id;
	UPDATE migrate_yl.guest a,up_map_code b SET a.src 	= b.code_new WHERE b.cat = 'srccode'  AND a.src = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_yl.guest a,up_map_code b SET a.market 	= b.code_new WHERE b.cat = 'mktcode'  AND a.market = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_yl.guest a,up_map_code b SET a.code1 	= b.code_new WHERE b.cat = 'ratecode'  AND a.code1 = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	
	UPDATE migrate_yl.master a,up_map_code b SET a.src 		= b.code_new WHERE b.cat = 'srccode'  AND a.src = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_yl.master a,up_map_code b SET a.market 	= b.code_new WHERE b.cat = 'mktcode'  AND a.market = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_yl.master a,up_map_code b SET a.restype 	= b.code_new WHERE b.cat = 'restype'  AND a.restype = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_yl.master a,up_map_code b SET a.ratecode = b.code_new WHERE b.cat = 'ratecode' AND a.ratecode = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_yl.master a,up_map_code b SET a.paycode 	= b.code_new WHERE b.cat = 'paymth'   AND a.paycode = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_yl.master a,up_map_code b SET a.saleid 	= b.code_new WHERE b.cat = 'saleman' AND a.saleid = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	-- UPDATE migrate_yl.master a,up_map_code b SET a.packages	= b.code_new WHERE b.cat = 'package'  AND a.packages = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	
	UPDATE migrate_yl.rsvsrc a,up_map_code b SET a.src 		= b.code_new WHERE b.cat = 'srccode'  AND a.src = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_yl.rsvsrc a,up_map_code b SET a.market 	= b.code_new WHERE b.cat = 'mktcode'  AND a.market = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_yl.rsvsrc a,up_map_code b SET a.ratecode = b.code_new WHERE b.cat = 'ratecode' AND a.ratecode = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	-- UPDATE migrate_yl.rsvsrc a,up_map_code b SET a.packages = b.code_new WHERE b.cat = 'package'  AND a.packages = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	
	-- 清空相关表数据
	DELETE FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM account 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM account_cashier	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM account_history	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM account_rmpost	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM account_sub WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM account_sub_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_master 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_master_till 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_master_last 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_master_history 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_master_guest 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_master_guest_till 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_master_guest_last 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_account 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_account_history 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_account_close 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_account_close_history 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_detail 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_detail_history 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_apply 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_apply_history 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_log 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM ar_account_sub WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	DELETE FROM company_prefer WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM company_production WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM company_production_old WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM company_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	DELETE FROM guest_type 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_black	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_link_addr	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_link_base	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_prefer WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_production WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_production_old WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	DELETE FROM master_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM master_base_till WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM master_base_last WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM master_base_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM master_guest WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM master_guest_till WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM master_guest_last WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM master_guest_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM master_stalog WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM master_stalog_till WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM master_stalog_last WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM master_stalog_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

	DELETE FROM pos_deptdai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM pos_deptdai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM pos_deptjie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM pos_deptjie_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM pos_dish WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM pos_menu WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	DELETE FROM production_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM sys_error WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
		
	DELETE FROM rep_jie_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_dai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_jiedai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='init';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='init';
	
END$$

DELIMITER ;