DELIMITER $$

USE `portal_group`$$

DROP PROCEDURE IF EXISTS `up_ihotel_migrate_company_import`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_migrate_company_import`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==========================================================
	-- 协议单位档案导入
	-- 适用于在同一服务器中的分库，注意此过程中涉及多个库名
	-- ==========================================================
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_vch_vipkh	VARCHAR(50);
	DECLARE var_vch_dwmc	VARCHAR(50);
	DECLARE var_company_id	INT;	
	
	DECLARE c_cursor CURSOR FOR SELECT vch_vipkh,TRIM(vch_dwmc)
		FROM portal_member.TV_VIPXX WHERE vch_dwmc<>'' GROUP BY vch_dwmc;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;

	DELETE FROM company_base WHERE hotel_group_id = arg_hotel_group_id AND remark ='ARANYA';
	DELETE FROM company_type WHERE hotel_group_id = arg_hotel_group_id AND comments ='ARANYA';
		
    OPEN c_cursor;
    SET done_cursor = 0;
	FETCH c_cursor INTO var_vch_vipkh,var_vch_dwmc;
	WHILE done_cursor = 0 DO		
		
		INSERT INTO company_base(hotel_group_id,hotel_id,NAME,name2,name3,name_combine,is_save,LANGUAGE,nation,
				phone,mobile,mobile2,fax,email,website,blog,linkman1,linkman2,country,state,city,division,street,zipcode,
				representative,register_no,bank_name,bank_account,tax_no,remark,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime) 
			VALUES(arg_hotel_group_id,'0',var_vch_dwmc,var_vch_dwmc,var_vch_dwmc,var_vch_dwmc,'F','C','CN',
				'','','','','','','','','','CN','','','','','',
				'','','','','','ARANYA','ARANYA','ARANYA',NOW(),'ARANYA','ARANYA',NOW());			
		
		SET var_company_id=LAST_INSERT_ID();
		
		IF NOT EXISTS(SELECT 1 FROM company_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = '0' AND company_id = var_company_id) THEN
		    INSERT INTO company_type (hotel_group_id,hotel_id,company_id,sta,manual_no,sys_cat,flag_cat,grade,latency,
					class1,class2,class3,class4,src,market,vip,belong_app_code,membership_type,membership_no,membership_level,over_rsvsrc,valid_begin,valid_end,
					code1,code2,code3,code4,code5,flag,saleman,ar_no1,ar_no2,extra_flag,extra_info,comments,create_user,create_datetime,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,'0',var_company_id,'I',var_vch_vipkh,'C','','','',
					'','','','','','','','1','','','','F',NOW(),DATE_ADD(NOW(),INTERVAL +1 YEAR),
					'','','','','','','','','','000000000000000000000000000000','','ARANYA','ARANYA',NOW(),'ARANYA',NOW());
		END IF;
		
		SET done_cursor = 0;
		FETCH c_cursor INTO var_vch_vipkh,var_vch_dwmc;
	END WHILE;
	CLOSE c_cursor;

	UPDATE company_base SET name_combine=REPLACE(name_combine,' ','');
		
		    
END$$

DELIMITER ;


-- CALL up_ihotel_migrate_company_import(3,0);