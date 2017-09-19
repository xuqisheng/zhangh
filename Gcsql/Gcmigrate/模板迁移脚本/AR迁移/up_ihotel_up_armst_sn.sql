DELIMITER $$


DROP PROCEDURE IF EXISTS `up_ihotel_up_armst_sn`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_armst_sn`(
	IN var_hotel_group_id INT, 
	IN var_hotel_id INT
)
label_0:
BEGIN
	-- ---------------------------------------------------------------------------------------------------------
	-- 这个过程，需要在 portal 库执行 
	-- ---------------------------------------------------------------------------------------------------------
	-- ---------------------------------------------------------------------------------------------------------
	-- V603：先用数据管道把老系统 armst 导入到 migrate_db1.armst  
	-- ---------------------------------------------------------------------------------------------------------
	
	DECLARE var_int 		INTEGER ;
	DECLARE var_id 			BIGINT;	  
 	DECLARE var_ar_num   		BIGINT;
	DECLARE var_biz_date 		DATETIME ;
	DECLARE var_ar_cycle 		VARCHAR(10);
 	DECLARE var_ta_code 		VARCHAR(10);
	DECLARE var_arg_code 		VARCHAR(10);
	DECLARE var_profile_type 	VARCHAR(10);
	DECLARE var_profile_id 		BIGINT(16);
	DECLARE var_arr			DATETIME;
	DECLARE var_dep 		DATETIME;
 	DECLARE var_status		VARCHAR(2);
	DECLARE var_limit_type 		VARCHAR(2);
	DECLARE done_cursor 		INT DEFAULT 0 ;
	DECLARE var_accnt		CHAR(10);
	DECLARE var_name1 		VARCHAR(255);
	DECLARE var_name2 		VARCHAR(255);
	DECLARE	var_artype		CHAR(4);
	DECLARE	var_begin	 	DATETIME;
	DECLARE	var_end		 	DATETIME;
	DECLARE	var_linkman	  	CHAR(18);
	DECLARE	var_mobile		CHAR(32);	
	DECLARE	var_phone		CHAR(32);	
	DECLARE	var_fax			CHAR(16);
	DECLARE var_ta_code_des 	VARCHAR(60);
	DECLARE var_ta_code_des_en 	VARCHAR(60);
 	
 	DECLARE c_armst CURSOR FOR SELECT a.accnt,a.name1,a.name2,a.artype,a.begin_,a.end_,a.linkman,a.mobile,a.phone,a.fax     
	FROM migrate_xx.armst2 a;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1 ;
	-- 初始值 
	SELECT biz_date INTO var_biz_date FROM audit_flag WHERE hotel_group_id=var_hotel_group_id AND hotel_id=var_hotel_id; 
	SELECT MAX(CODE) INTO var_ar_cycle FROM code_base WHERE hotel_group_id=var_hotel_group_id AND hotel_id=var_hotel_id AND parent_code='ar_cycle'; 
	-- 提取余额录入入帐代码信息 
 	SET var_ta_code = '5920', var_arg_code='xxx'; 
	SELECT arrange_code, descript, descript_en INTO var_arg_code, var_ta_code_des, var_ta_code_des_en
		FROM code_transaction WHERE hotel_group_id=var_hotel_group_id AND hotel_id=var_hotel_id AND CODE=var_ta_code; 
	IF 	var_arg_code='xxx' THEN 
		SELECT CONCAT(var_ta_code, ' --- ', 'TA_CODE IS ERROR ! ');
		LEAVE label_0; 
	END IF ; 
 	
	-- 迁移状态更新 
	DELETE FROM up_status WHERE hotel_id=var_hotel_id AND up_step='armst';
	INSERT INTO up_status(hotel_id, up_step, time_begin, time_end, time_long, remark)
		VALUES(var_hotel_id, 'armst', NOW(), NULL, 0, ''); 
	DELETE FROM up_map_accnt WHERE hotel_id=var_hotel_id AND accnt_type='armst' AND accnt_class='';
	-- 开始迁移，光标扫描 
  	SET var_int = 10 ;
 	OPEN c_armst ;
	SET done_cursor = 0 ;
	FETCH c_armst INTO var_accnt,var_name1,var_name2,var_artype,var_begin,var_end,var_linkman,var_mobile,var_phone,var_fax; 
	WHILE done_cursor = 0 DO
		BEGIN
			-- 档案处理  -- 全部当公司导入 
-- 			IF var_ident<>'' THEN 
-- 				BEGIN
-- 				SET var_profile_type='F', var_profile_id=0; 
-- 				CALL up_ihotel_get_guest_id(var_hotel_group_id, var_hotel_id, '', var_name, var_ident, var_profile_id); 
-- 				END; 
-- 			ELSE
-- 				BEGIN
-- 				SET var_profile_type='C', var_profile_id=0; 
-- 				CALL up_ihotel_get_company_id(var_hotel_group_id, var_hotel_id, '', var_name, var_profile_type, var_profile_id); 
-- 				SET var_profile_type='COMPANY'; 
-- 				END; 
-- 			END IF ; 
			
			SET var_profile_id = 0;
			SET var_profile_type = '';	
				
			-- 	SELECT var_accnt;
			IF var_profile_id = 0 THEN 
				BEGIN
-- 				IF var_arr IS NULL THEN 
-- 					SET var_arr = '2013-12-01'; 
-- 				END IF; 
-- 				IF var_dep IS NULL THEN 
-- 					SET var_dep = '2018-12-01'; 
-- 				END IF; 
				SET var_status = 'I';
 				SET var_limit_type = '1'; 
 				
				-- 迁入的特别标记 building=### 
				INSERT INTO ar_master (hotel_group_id, hotel_id, arno, profile_type, profile_id, biz_date, sta, arr, dep, exp_sta, tm_sta, tag0, building, 
					ar_cycle, ar_category, is_permanent, posting_flag, extra_flag, pay_code, limit_type, limit_amt, credit_no, credit_man, credit_company, salesman, 
					phone, fax, email, charge, pay, credit, last_num, last_num_link, link_id, remark, co_msg, reminder_msg, 
					last_charge_user, last_charge_datetime, last_pay_user, last_pay_datetime, last_invoice_user, last_invoice_datetime, last_statement_user, last_statement_datetime, 
					last_reminder_to, last_reminder_user, last_reminder_datetime, create_user, create_datetime, modify_user, modify_datetime)
				VALUES(var_hotel_group_id, var_hotel_id, var_accnt, var_profile_type, var_profile_id, var_biz_date, var_status, var_begin,var_end, '', 'I', '', '###', 
					'1', var_artype, 'F', '1', IF(var_limit_type = '1','001000000000000000000000000000','000000000000000000000000000000'), '9000', var_limit_type, 0, '', '', '', '', 
					var_mobile, var_fax, '', 0, 0, 0, 0, 0, NULL, IF(var_phone IS NOT NULL,CONCAT('公司电话',var_phone),''), '', '', 
					'', NULL, '', NULL, '', NULL, '', NULL, 
					'', '', NULL, 'ADMIN', NOW(), 'ADMIN', NOW()); 
					
				SET var_id = LAST_INSERT_ID(); 	
				
				INSERT INTO ar_master_guest (hotel_group_id,hotel_id,id,NAME,name2,name_combine,coding,LANGUAGE,nation,linkman,zipcode,create_user,create_datetime,modify_user,modify_datetime)
				VALUES(var_hotel_group_id, var_hotel_id,var_id,var_name1,var_name2,CONCAT(var_name1,var_name2),'','C','CN',IFNULL(var_linkman,''),'','ADMIN', NOW(), 'ADMIN', NOW());
	
				
				END; 
			ELSE
				INSERT sys_debug(hotel_group_id, hotel_id, CODE, descript)
					VALUES(var_hotel_group_id, var_hotel_id, 'ar-input-error', CONCAT(var_accnt, '-', var_name)); 
			END IF; 
			SET done_cursor = 0 ;
			FETCH c_armst INTO  var_accnt,var_name1,var_name2,var_artype,var_begin,var_end,var_linkman,var_mobile,var_phone,var_fax; 
		END ;
	END WHILE ;
	CLOSE c_armst ;
 	-- 产生帐户对照表
	INSERT INTO up_map_accnt(hotel_group_id,hotel_id, accnt_type, accnt_class, accnt_old, accnt_new) 
		SELECT var_hotel_group_id,var_hotel_id, 'armst', '', arno, id FROM ar_master
			WHERE hotel_group_id=var_hotel_group_id AND hotel_id=var_hotel_id AND building='###'; 

	-- 产生允许记账
	INSERT INTO ar_account_sub (hotel_group_id, hotel_id, TYPE, tag, accnt, rmno, guest_id, to_accnt, to_rmno, NAME, 
			ta_codes, pay_code, begin_datetime, end_datetime, remark, create_user, create_datetime, modify_user, modify_datetime)
		SELECT var_hotel_group_id, var_hotel_id, 'POSTING', '', id, '', 0, 0, '', '', 
			'*', '', arr, dep, '', 'ADMIN', NOW(), 'ADMIN', NOW()
		FROM ar_master WHERE hotel_group_id=var_hotel_group_id AND hotel_id=var_hotel_id AND building='###' AND limit_type = '1'; 
	-- 产生基本分账户 
	INSERT INTO ar_account_sub (hotel_group_id, hotel_id, TYPE, tag, accnt, rmno, guest_id, to_accnt, to_rmno, NAME, 
			ta_codes, pay_code, begin_datetime, end_datetime, remark, create_user, create_datetime, modify_user, modify_datetime)
		SELECT var_hotel_group_id, var_hotel_id, 'SUBACCNT', 'SYS_FIX', id, '', profile_id, 0, '', '', 
			'*', '', arr, dep, '', 'ADMIN', NOW(), 'ADMIN', NOW()
		FROM ar_master WHERE hotel_group_id=var_hotel_group_id AND hotel_id=var_hotel_id AND building='###'; 
	-- 更新分账户的名称 
	UPDATE ar_account_sub a,ar_master_guest b SET a.name=b.name 
	WHERE a.hotel_group_id = var_hotel_group_id AND a.hotel_id = var_hotel_id AND  b.hotel_group_id = var_hotel_group_id AND b.hotel_id = var_hotel_id
	AND a.accnt=b.id AND a.type='SUBACCNT' AND a.tag='SYS_FIX';
	-- 更新分账户的名称 
-- 	UPDATE ar_account_sub, ar_master a, guest_base b SET ar_account_sub.name=b.name 
-- 		WHERE ar_account_sub.accnt=a.id AND ar_account_sub.type='SUBACCNT' AND ar_account_sub.tag='SYS_FIX' 
-- 			AND a.profile_type = 'GUEST' AND a.profile_id=b.id; 
-- 	UPDATE ar_account_sub, ar_master a, company_base b SET ar_account_sub.name=b.name
-- 		WHERE ar_account_sub.accnt=a.id AND ar_account_sub.type='SUBACCNT' AND ar_account_sub.tag='SYS_FIX' 
-- 			AND a.profile_type = 'COMPANY' AND a.profile_id=b.id; 
	-- link_id 
	UPDATE ar_master SET link_id = id WHERE hotel_group_id=var_hotel_group_id AND hotel_id=var_hotel_id AND building='###'; 
	
	UPDATE ar_master a,up_map_code b SET a.salesman = b.code_new WHERE b.hotel_group_id = var_hotel_group_id AND b.hotel_id = var_hotel_id AND b.code = 'salesman' AND b.code_old = a.salesman;
	-- 生成ar_account表中的数据
	-- 生成ar_detail表中的数据
 
 
--  	CALL up_ihotel_up_armst_account(var_hotel_group_id, var_hotel_id); 
	-- 根据AR主单的余额 charge 自动产生期初余额的帐次 
	-- 生成ar_account表中的数据
 
-- 	UPDATE ar_master a,up_map_code b SET a.ar_category = b.code_old WHERE a.hotel_group_id = var_hotel_group_id AND a.hotel_id = var_hotel_id
-- 	AND b.hotel_group_id = var_hotel_group_id AND b.hotel_id = var_hotel_id AND a.ar_category = b.code_new;
	-- 修改余额不为0的帐户的帐户指针 
-- 	UPDATE ar_master SET last_num = '100' , last_num_link = '100' 
--  		WHERE hotel_group_id=var_hotel_group_id AND hotel_id=var_hotel_id AND building='###';
 	-- ------------------------------------------
	-- 根据代码对照表替换代码信息 up_map_code 
	-- ------------------------------------------
	-- ------------------------------------------
	-- 耗时记录 
	-- ------------------------------------------
 	
 	UPDATE up_status SET time_end=NOW() WHERE hotel_id=var_hotel_id AND up_step='armst';
 	
	BEGIN
-- 		SET @procresult = 0 ;
		LEAVE label_0 ;
	END ;
END$$

DELIMITER ;