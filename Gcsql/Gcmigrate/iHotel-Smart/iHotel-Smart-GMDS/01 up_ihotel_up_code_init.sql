DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_up_code_init`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_code_init`(
	arg_hotel_group_id	INT,
	arg_hotel_id		INT,
	arg_biz_date		DATETIME
)
SQL SECURITY INVOKER
label_0:
BEGIN

	DELETE FROM up_status WHERE hotel_id = arg_hotel_id;
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark)VALUES(arg_hotel_id,'INIT',NOW(),NULL,0,''); 
	
	-- 中间库 migrate_db.guest建立相关索引,比如:idcls、saleid、class1
	UPDATE migrate_db.guest SET idcls ='01' WHERE idcls 	= '?' OR idcls = '';
	ALTER TABLE migrate_db.guest MODIFY COLUMN src 			VARCHAR(10);
	ALTER TABLE migrate_db.guest MODIFY COLUMN market 		VARCHAR(10);
	ALTER TABLE migrate_db.guest MODIFY COLUMN code1 		VARCHAR(10);
	
	ALTER TABLE migrate_db.master MODIFY COLUMN src 		VARCHAR(10);
	ALTER TABLE migrate_db.master MODIFY COLUMN market 		VARCHAR(10);
	ALTER TABLE migrate_db.master MODIFY COLUMN ratecode 	VARCHAR(10);
	ALTER TABLE migrate_db.master MODIFY COLUMN restype 	VARCHAR(10);
	
	ALTER TABLE migrate_db.rsvsrc MODIFY COLUMN src 		VARCHAR(10);
	ALTER TABLE migrate_db.rsvsrc MODIFY COLUMN market 		VARCHAR(10);
	ALTER TABLE migrate_db.rsvsrc MODIFY COLUMN ratecode 	VARCHAR(10);	
	
	UPDATE migrate_db.guest a,up_map_code b SET a.idcls 	= b.code_new WHERE b.code = 'idcode' AND a.idcls = b.code_old AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id;
	UPDATE migrate_db.guest a,up_map_code b SET a.nation 	= b.code_new WHERE b.code = 'nation'  AND a.nation = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.guest a,up_map_code b SET a.country	= b.code_new WHERE b.code = 'country' AND a.nation = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.guest a,up_map_code b SET a.saleid 	= b.code_new WHERE b.code = 'salesman' AND a.saleid = b.code_old AND a.saleid<>'' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id;
	UPDATE migrate_db.guest a,up_map_code b SET a.src 		= b.code_new WHERE b.code = 'srccode'  AND a.src = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.guest a,up_map_code b SET a.market 	= b.code_new WHERE b.code = 'mktcode'  AND a.market = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.guest a,up_map_code b SET a.code1 	= b.code_new WHERE b.code = 'ratecode'  AND a.code1 = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	
	
	UPDATE migrate_db.master a,up_map_code b SET a.src 		= b.code_new WHERE b.code = 'srccode'  AND a.src = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.master a,up_map_code b SET a.market 	= b.code_new WHERE b.code = 'mktcode'  AND a.market = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.master a,up_map_code b SET a.restype 	= b.code_new WHERE b.code = 'rsv_type' AND a.restype = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.master a,up_map_code b SET a.channel 	= b.code_new WHERE b.code = 'channel' AND a.channel = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.master a,up_map_code b SET a.ratecode = b.code_new WHERE b.code = 'ratecode' AND a.ratecode = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.master a,up_map_code b SET a.paycode 	= b.code_new WHERE b.code = 'paymth'   AND a.paycode = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.master a,up_map_code b SET a.saleid 	= b.code_new WHERE b.code = 'salesman' AND a.saleid = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.master a,up_map_code b SET a.rtreason	= b.code_new WHERE b.code = 'code_reason' AND a.rtreason = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;	
	-- UPDATE migrate_db.master a,up_map_code b SET a.packages	= b.code_new WHERE b.code = 'package'  AND a.packages = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	
	UPDATE migrate_db.rsvsrc a,up_map_code b SET a.src 		= b.code_new WHERE b.code = 'srccode'  AND a.src = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.rsvsrc a,up_map_code b SET a.market 	= b.code_new WHERE b.code = 'mktcode'  AND a.market = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.rsvsrc a,up_map_code b SET a.ratecode = b.code_new WHERE b.code = 'ratecode' AND a.ratecode = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.rsvsrc a,up_map_code b SET a.rtreason	= b.code_new WHERE b.code = 'code_reason' AND a.rtreason = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;		
	-- UPDATE migrate_yl.rsvsrc a,up_map_code b SET a.packages = b.code_new WHERE b.code = 'package'  AND a.packages = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	
	UPDATE migrate_db.master SET channel = 'QT' WHERE channel NOT IN ('COL','EML','FAX','TEL');
	UPDATE migrate_db.master SET packages = '';
	
	-- CALL up_ihotel_code_table();
	-- 特殊处理,避免被清空
	UPDATE code_table SET table_action='' WHERE table_name IN ('lang','lang_custom','fpos_def','fpos_station','res','up_map_accnt','up_status','up_map_code');
	-- 初始化 特别注意营业日期,不能在12点后做初始化
	UPDATE hotel SET online_check = 'F' WHERE id = arg_hotel_id;
	CALL up_exec('up_ihotel_init',arg_hotel_id);
	-- 餐饮初始化
	CALL up_pos_data_init(arg_hotel_group_id,arg_hotel_id,@msg);
	
	-- 营业日期更正 | 前台iHotel
	UPDATE sys_option SET set_value = DATE_FORMAT(arg_biz_date,'%Y-%m-%d') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog='system' AND item='biz_date';
	UPDATE audit_flag SET biz_date  = arg_biz_date,biz_date1 = arg_biz_date,rmpost_datetime = arg_biz_date,rmpost_biz_date = ADDDATE(arg_biz_date,-1) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	-- 营业日期更正 | 餐饮云POS
	UPDATE sys_option SET set_value = DATE_FORMAT(arg_biz_date,'%Y-%m-%d') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog='system' AND item='pos_biz_date'; 	
	
	-- 集团首家店才执行以下语句
 	DELETE FROM guest_black 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_link_addr WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_link_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_prefer 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM guest_type 		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM company_type 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM guest_production 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM company_production 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM sales_man_production WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM guest_production_old 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM company_production_old 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
 	TRUNCATE TABLE sys_error;
	TRUNCATE TABLE sys_debug;
	
	DELETE FROM guest_base 		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND id IN (SELECT accnt_new FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'GUEST_FIT');
	DELETE FROM guest_base 		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND id IN (SELECT accnt_new FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'GUEST_GRP');	
	DELETE FROM guest_type 		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND guest_id IN (SELECT accnt_new FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'GUEST_FIT');
	DELETE FROM guest_type 		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND guest_id IN (SELECT accnt_new FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'GUEST_GRP');	
	DELETE FROM company_base	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND id IN (SELECT accnt_new FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'COMPANY');
	DELETE FROM company_type	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND company_id IN (SELECT accnt_new FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'COMPANY');
	DELETE FROM portal_group.company_base	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND id IN (SELECT accnt_new FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'COMPANY');
	DELETE FROM portal_group.company_type	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND company_id IN (SELECT accnt_new FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'COMPANY');
	DELETE FROM portal_group.company_type	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND company_id IN (SELECT accnt_new FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'COMPANY');
	DELETE FROM portal_group.company_production	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND company_id IN (SELECT accnt_new FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'COMPANY');
	DELETE FROM portal_group.company_production	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND company_id IN (SELECT accnt_new FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'COMPANY');
	DELETE FROM portal_group.profile_extra	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND extra_item = 'RATECODE' AND master_type = 'COMPANY' AND master_id IN (SELECT accnt_new FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'COMPANY');
	
	DELETE FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='INIT';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='INIT';
	
END$$

DELIMITER ;