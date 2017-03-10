DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_coderate_v5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_coderate_v5`(
	IN arg_hotel_group_id BIGINT(16),
	IN arg_hotel_id 	  BIGINT(16)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- =============================
	-- 公司档案导入
	-- =============================
	DECLARE var_companyid 	INT;
	DECLARE var_code1 		VARCHAR(20);
	DECLARE var_valid_begin DATETIME;
	DECLARE var_valid_end 	DATETIME;
    DECLARE done_cursor INT DEFAULT 0;

		
	DECLARE c_profile CURSOR FOR SELECT company_id,code1,valid_begin,valid_end FROM company_type 
	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code1 <> '';	

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	-- UPDATE company_type SET code1='TGR' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND sys_cat='A';
	
	-- UPDATE company_type a,up_map_code b SET a.code1 = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code_old = a.code1 AND b.cat = 'ratecode';
	-- UPDATE company_type a,up_map_code b SET a.saleman = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code_old = a.saleman AND b.cat = 'salesman';
	
	-- ==================================================
	-- 根据协议公司主单上的房价码生成profileExtra中的值
	-- ==================================================	
	DELETE FROM profile_extra WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id AND extra_item = 'RATECODE' AND master_type = 'COMPANY';
	
	OPEN c_profile;
	SET done_cursor = 0;
	FETCH c_profile INTO var_companyid,var_code1,var_valid_begin,var_valid_end;
		WHILE done_cursor = 0 DO		
			IF NOT EXISTS(SELECT 1 FROM profile_extra WHERE extra_item = 'RATECODE' AND master_type = 'COMPANY' AND master_id = var_company_id AND hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id) THEN	    
				INSERT INTO profile_extra(hotel_group_id,hotel_id,extra_item,master_type,master_id,extra_value,date_begin,date_end,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime)
					VALUES(arg_hotel_group_id,arg_hotel_id,'RATECODE','COMPANY',var_companyid,var_code1,var_valid_begin,var_valid_end,'F','0','ADMIN',NOW(),'ADMIN',NOW());
			END IF;			
			SET done_cursor = 0;
			FETCH c_profile INTO var_companyid,var_code1,var_valid_begin,var_valid_end;
		END WHILE;
	CLOSE c_profile;
	
	
END$$

DELIMITER ;

-- CALL ihotel_up_coderate_v5(1,105)