DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_company_ratecode`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_company_ratecode`(
	IN arg_hotel_group_id BIGINT(16),
	IN arg_hotel_id 	BIGINT(16)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==================================
	-- 协议单位关联房价码
	-- ==================================
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_companyid 	INT;
	DECLARE var_valid_begin DATETIME;
	DECLARE var_valid_end 	DATETIME;
	DECLARE var_code1		VARCHAR(10);	

	DECLARE c_profile CURSOR FOR SELECT company_id,code1,'2015-1-1',valid_end FROM company_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code1 <> '';
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	UPDATE company_type SET code1 = '2014CORPB' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code1='2014 L COB';
	UPDATE company_type SET code1 = '2014CORPA' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code1='2014 L COA';
	UPDATE company_type SET code1 = '2014GOVA'  WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code1='2014 GOVA';
	UPDATE company_type SET code1 = '2014GOVB'  WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code1='2014 GOVB';	
	
	OPEN c_profile;
	SET done_cursor = 0;
	FETCH c_profile INTO var_companyid,var_code1,var_valid_begin,var_valid_end;
		WHILE done_cursor = 0 DO
		
			IF EXISTS(SELECT 1 FROM code_ratecode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code=var_code1) THEN		
				IF NOT EXISTS(SELECT 1 FROM profile_extra WHERE extra_item = 'RATECODE' AND master_type = 'COMPANY' AND master_id = var_companyid AND hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id) THEN
					INSERT INTO profile_extra(hotel_group_id,hotel_id,extra_item,master_type,master_id,extra_value,date_begin,date_end,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime)
					VALUES(arg_hotel_group_id,arg_hotel_id,'RATECODE','COMPANY',var_companyid,var_code1,var_valid_begin,var_valid_end,'F','0','ADMIN',NOW(),'ADMIN',NOW());
				END IF;
			END IF;
			SET done_cursor = 0;
			FETCH c_profile INTO var_companyid,var_code1,var_valid_begin,var_valid_end;
		END WHILE;
	CLOSE c_profile;    	

	
END$$

DELIMITER ;

CALL ihotel_up_company_ratecode(1,101);

DROP PROCEDURE IF EXISTS `ihotel_up_company_ratecode`;