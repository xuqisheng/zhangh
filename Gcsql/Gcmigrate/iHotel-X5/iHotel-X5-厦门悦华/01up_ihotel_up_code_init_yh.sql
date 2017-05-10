DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_up_code_init_yh`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_code_init_yh`(
	arg_hotel_group_id	BIGINT(16),
	arg_hotel_id		BIGINT(16)
)
SQL SECURITY INVOKER
label_0:
BEGIN

	DELETE FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM up_status WHERE hotel_id = arg_hotel_id;
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark)VALUES(arg_hotel_id,'INIT',NOW(),NULL,0,''); 
	
	-- 中间库 migrate_xmyh.guest建立相关索引,比如:idcls、saleid、class1
	UPDATE migrate_xmyh.guest SET idcls ='01' WHERE idcls = '?' OR idcls = '';
	UPDATE migrate_xmyh.guest a,up_map_code b SET a.idcls = b.code_new WHERE b.code = 'idcode' AND a.idcls = b.code_old AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id;
	UPDATE migrate_xmyh.guest a,up_map_code b SET a.nation = b.code_new WHERE b.code = 'nation'  AND a.nation = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_xmyh.guest a,up_map_code b SET a.country= b.code_new WHERE b.code = 'country' AND a.nation = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
-- 	UPDATE migrate_xmyh.guest a,up_map_code b SET a.saleid = b.code_new WHERE b.code = 'salesman' AND a.saleid = b.code_old AND a.saleid<>'' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id;
-- 	UPDATE migrate_xmyh.guest a,up_map_code b SET a.class1 = b.code_new WHERE b.code = 'compcode1' AND a.class IN ( 'A','S','C') AND a.class1 = b.code_old AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id;
-- 	UPDATE migrate_xmyh.guest a,up_map_code b SET a.src = b.code_new WHERE b.code = 'srccode'  AND a.src = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
--  	UPDATE migrate_xmyh.guest a,up_map_code b SET a.market = b.code_new WHERE b.code = 'mktcode'  AND a.market = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
-- 	UPDATE migrate_xmyh.guest a,up_map_code b SET a.code1 = b.code_new WHERE b.cat = 'ratecode'  AND a.code1 = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
/* 	
	UPDATE migrate_xmyh.master a,up_map_code b SET a.src 		= b.code_new WHERE b.cat = 'srccode'  AND a.src = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_xmyh.master a,up_map_code b SET a.market 	= b.code_new WHERE b.cat = 'mktcode'  AND a.market = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_xmyh.master a,up_map_code b SET a.restype 	= b.code_new WHERE b.cat = 'restype'  AND a.restype = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_xmyh.master a,up_map_code b SET a.channel 	= b.code_new WHERE b.cat = 'channel'  AND a.channel = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_xmyh.master a,up_map_code b SET a.ratecode = b.code_new WHERE b.cat = 'ratecode' AND a.ratecode = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_xmyh.master a,up_map_code b SET a.paycode 	= b.code_new WHERE b.cat = 'paymth'   AND a.paycode = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_xmyh.master a,up_map_code b SET a.saleid 	= b.code_new WHERE b.cat = 'salesman' AND a.saleid = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_xmyh.master a,up_map_code b SET a.packages	= b.code_new WHERE b.cat = 'package'  AND a.packages = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	
	UPDATE migrate_xmyh.rsvsrc a,up_map_code b SET a.src 		= b.code_new WHERE b.cat = 'srccode'  AND a.src = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_xmyh.rsvsrc a,up_map_code b SET a.market 	= b.code_new WHERE b.cat = 'mktcode'  AND a.market = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_xmyh.rsvsrc a,up_map_code b SET a.ratecode = b.code_new WHERE b.cat = 'ratecode' AND a.ratecode = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_xmyh.rsvsrc a,up_map_code b SET a.packages = b.code_new WHERE b.cat = 'package'  AND a.packages = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	
	UPDATE migrate_xmyh.master SET amenities = REPLACE(amenities,'CB','BB') WHERE amenities <> '';
	UPDATE migrate_xmyh.master SET amenities = REPLACE(amenities,'CK','PAT') WHERE amenities <> '';
	UPDATE migrate_xmyh.master SET amenities = REPLACE(amenities,'CL','CH') WHERE amenities <> '';
	UPDATE migrate_xmyh.master SET amenities = REPLACE(amenities,'CP','CHP') WHERE amenities <> '';
	UPDATE migrate_xmyh.master SET amenities = REPLACE(amenities,'F3','FB4') WHERE amenities <> '';
	UPDATE migrate_xmyh.master SET amenities = REPLACE(amenities,'FD','FL4') WHERE amenities <> '';
	UPDATE migrate_xmyh.master SET amenities = REPLACE(amenities,'NC','CN') WHERE amenities <> '';
	UPDATE migrate_xmyh.master SET amenities = REPLACE(amenities,'NE','EN') WHERE amenities <> '';

	UPDATE migrate_xmyh.master SET srqs = REPLACE(srqs,'CR','CB') WHERE srqs <> '';
	
	-- UPDATE migrate_xmyh.guest SET srqs = REPLACE(srqs,'CR','CB') WHERE srqs <> '';

	UPDATE migrate_xmyh.guest SET amenities = REPLACE(amenities,'CB','BB') WHERE amenities <> '';
	UPDATE migrate_xmyh.guest SET amenities = REPLACE(amenities,'CK','PAT') WHERE amenities <> '';
	UPDATE migrate_xmyh.guest SET amenities = REPLACE(amenities,'CL','CH') WHERE amenities <> '';
	UPDATE migrate_xmyh.guest SET amenities = REPLACE(amenities,'CP','CHP') WHERE amenities <> '';
	UPDATE migrate_xmyh.guest SET amenities = REPLACE(amenities,'F3','FB4') WHERE amenities <> '';
	UPDATE migrate_xmyh.guest SET amenities = REPLACE(amenities,'FD','FL4') WHERE amenities <> '';
	UPDATE migrate_xmyh.guest SET amenities = REPLACE(amenities,'NC','CN') WHERE amenities <> '';
	UPDATE migrate_xmyh.guest SET amenities = REPLACE(amenities,'NE','EN') WHERE amenities <> '';
	
	UPDATE migrate_xmyh.guest SET feature = REPLACE(feature,'AJ','A') WHERE feature <> '';
	UPDATE migrate_xmyh.guest SET feature = REPLACE(feature,'AL','J') WHERE feature <> '';
	UPDATE migrate_xmyh.guest SET feature = REPLACE(feature,'CN','B') WHERE feature <> '';
	UPDATE migrate_xmyh.guest SET feature = REPLACE(feature,'CV','S') WHERE feature <> '';
	UPDATE migrate_xmyh.guest SET feature = REPLACE(feature,'HF','H') WHERE feature <> '';
	UPDATE migrate_xmyh.guest SET feature = REPLACE(feature,'HR','C') WHERE feature <> '';
	UPDATE migrate_xmyh.guest SET feature = REPLACE(feature,'HV','Q') WHERE feature <> '';
	UPDATE migrate_xmyh.guest SET feature = REPLACE(feature,'LF','G') WHERE feature <> '';
	UPDATE migrate_xmyh.guest SET feature = REPLACE(feature,'NL','I') WHERE feature <> '';
	UPDATE migrate_xmyh.guest SET feature = REPLACE(feature,'NS','D') WHERE feature <> '';
	
	
	-- CALL up_ihotel_code_table();
	-- 特殊处理,避免被清空
	-- UPDATE code_table SET table_action='' WHERE table_name LIKE 'up_%';
	-- UPDATE code_table SET table_action='' WHERE table_name IN ('fpos_def','fpos_station','rep_localfit_narada','rep_gststa_narada');
	-- UPDATE code_table SET table_action='' WHERE table_name IN ('rep_localfit_narada','rep_gststa_narada');
	-- 初始化 特别注意营业日期,不能在12点后做初始化
	-- CALL up_exec('up_ihotel_init',arg_hotel_id);
	
	-- 集团首家店才执行以下语句
 	DELETE FROM guest_black 	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	DELETE FROM guest_link_addr WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	DELETE FROM guest_link_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	DELETE FROM guest_prefer 	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;	
	DELETE FROM guest_type 		WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;	
	DELETE FROM company_type 	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;	
	DELETE FROM guest_production 	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	DELETE FROM member_production 	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	DELETE FROM company_production 	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;	
	DELETE FROM sales_man_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;	
	DELETE FROM guest_production_old 	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	DELETE FROM company_production_old 	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
 	-- TRUNCATE TABLE sys_error;
	-- TRUNCATE TABLE sys_debug;
*/
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='INIT';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='INIT';
	
END$$

DELIMITER ;