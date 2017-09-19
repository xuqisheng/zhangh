DELIMITER $$
DROP PROCEDURE IF EXISTS `up_fill_company_profile_extra`$$
CREATE DEFINER=`root`@`%` PROCEDURE `up_fill_company_profile_extra`(
	IN var_hotel_group_id INT,var_hotel_id INT
	)
label_0:
BEGIN
	-- *******************************************
	-- 根据协议公司主单上的房价码生成profileExtra中的值
	-- *******************************************
	DECLARE var_company_id INT;
	DECLARE var_code1 VARCHAR(20);
	DECLARE var_valid_begin DATETIME;
	DECLARE var_valid_end DATETIME;
	DECLARE var_stop INT DEFAULT 0;
	DECLARE var_cursor CURSOR FOR SELECT a.company_id,a.code1,a.valid_begin,a.valid_end FROM company_type a,up_map_accnt b WHERE a.hotel_group_id = var_hotel_group_id AND a.hotel_id = var_hotel_id AND a.code1 <> '' AND a.company_id = b.accnt_new AND b.hotel_group_id = var_hotel_group_id AND b.hotel_id = var_hotel_id AND b.accnt_type = 'COMPANY';
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET var_stop = 1;
	
	DELETE a FROM profile_extra a,up_map_accnt b WHERE a.hotel_group_id=var_hotel_group_id AND a.hotel_id = var_hotel_id AND a.extra_item = 'RATECODE' AND a.master_type = 'COMPANY'
		AND a.master_id = b.accnt_new AND b.hotel_group_id = var_hotel_group_id AND b.hotel_id = var_hotel_id AND b.accnt_type = 'COMPANY';
	OPEN var_cursor;
		FETCH var_cursor INTO var_company_id,var_code1,var_valid_begin,var_valid_end;
		WHILE var_stop <> 1 DO
		
			IF NOT EXISTS(SELECT 1 FROM profile_extra WHERE extra_item = 'RATECODE' AND master_type = 'COMPANY' AND master_id = var_company_id AND hotel_group_id = var_hotel_group_id AND hotel_id = var_hotel_id) THEN
			    INSERT INTO profile_extra(hotel_group_id,hotel_id,extra_item,master_type,master_id,extra_value,date_begin,date_end,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime)
			    VALUES(var_hotel_group_id,var_hotel_id,'RATECODE','COMPANY',var_company_id,var_code1,var_valid_begin,var_valid_end,'F','0','ADMIN',NOW(),'ADMIN',NOW());
			
			END IF;

			FETCH var_cursor INTO var_company_id,var_code1,var_valid_begin,var_valid_end;
		END WHILE;
  CLOSE var_cursor;
	
END$$
DELIMITER ;

-- CALL up_fill_company_profile_extra(2,34);
-- DROP PROCEDURE IF EXISTS `up_fill_company_profile_extra`;

