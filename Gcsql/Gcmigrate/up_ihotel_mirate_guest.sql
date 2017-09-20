DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_mirate_guest`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_mirate_guest`(
	IN arg_hotel_group_id 	INT, 
	IN arg_hotel_id 		INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN

	DECLARE var_accnt		BIGINT;
	DECLARE var_name 		CHAR(40);
	DECLARE	var_sex			CHAR(10);
	DECLARE var_class		CHAR(10);
	DECLARE var_birth		DATETIME;
	DECLARE var_idtype		CHAR(10);
	DECLARE var_id_des		CHAR(20);
	DECLARE var_idno		CHAR(30);
	DECLARE var_nation		CHAR(10);
	DECLARE var_address		VARCHAR(200);
	DECLARE var_CertNO		CHAR(20);
	DECLARE var_guest_id 	INT;
	DECLARE done_cursor 	INT DEFAULT 0;
	
	DECLARE c_cursor CURSOR FOR SELECT a.id,a.name,IF(a.sex = '男','1','2') sex,a.class,a.birth,a.id_code,a.id_des,a.id_no,a.nation,CONCAT(a.address1,a.address2) 
	FROM migrate_db.guest a;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;

	-- 基础表数据修复
	UPDATE migrate_db.guest SET class = 'F',id_des = '01','CN';
		
	OPEN c_cursor;
	FETCH c_cursor INTO var_accnt,var_name,var_sex,var_class,var_birth,var_idtype,var_id_des,var_idno,var_nation,var_address;
	WHILE done_cursor <> 1 DO
 		INSERT INTO guest_base(hotel_group_id,hotel_id,NAME,last_name,first_name,name2,name3,name_combine,is_save,
			sex,LANGUAGE,title,salutation,birth,race,religion,career,occupation,nation,id_code,id_no,id_end,company_id,
			company_name,pic_photo,pic_sign,remark,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime) 
		VALUES(arg_hotel_group_id,0,var_name,'','',var_name,var_name,var_name,'F',
			var_sex,'C','','',var_birth,'HA','','',NULL,var_nation,var_idtype,var_idno,NULL,NULL,
			'',NULL,NULL,'',arg_hotel_id,'ADMIN',NOW(),arg_hotel_id,'ADMIN',NOW());
			
		SET var_guest_id=LAST_INSERT_ID();
		
		IF NOT EXISTS(SELECT 1 FROM guest_link_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND id = var_guest_id) THEN
			INSERT INTO guest_link_base(hotel_group_id, hotel_id, id, mobile, phone, fax, email, website, msn, qq, sns, blog, 
				linkman1, linkman2, create_hotel, create_user, create_datetime, modify_hotel, modify_user, modify_datetime) 
			VALUES(arg_hotel_group_id,0,var_guest_id,'','','','','','','','','',
				'','',arg_hotel_id,'ADMIN',NOW(),arg_hotel_id,'ADMIN',NOW());
		END IF;
		
		IF NOT EXISTS(SELECT 1 FROM guest_link_addr WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND guest_id = var_guest_id) THEN
			INSERT INTO guest_link_addr (hotel_group_id, hotel_id, guest_id, addr_name, addr_type, is_default, country,state, 
				city, division, street, zipcode, list_order, remark, create_hotel, create_user, create_datetime, modify_hotel, modify_user, modify_datetime) 
			VALUES(arg_hotel_group_id,0,var_guest_id,'默认地址','HOME','T',var_nation,NULL,
				'',NULL,var_address,'','0','',arg_hotel_id,'ADMIN',NOW(),arg_hotel_id,'ADMIN',NOW());
		END IF;
		-- 酒店客史档案 
		IF NOT EXISTS(SELECT 1 FROM guest_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_id = var_guest_id) THEN
			INSERT INTO guest_type (hotel_group_id, hotel_id, guest_id, sta, manual_no, sys_cat, flag_cat, grade, latency, 
				class1, class2, class3, class4, src, market, vip, belong_app_code, membership_type, membership_no, membership_level, 
				over_rsvsrc, valid_begin, valid_end, code1, code2, code3, code4, code5, flag, saleman, ar_no1, ar_no2, 
				extra_flag, extra_info, comments, create_user, create_datetime, modify_user, modify_datetime) 
			VALUES(arg_hotel_group_id,arg_hotel_id,var_guest_id,'I',var_accnt,'F','','','',
				'','','','','','','','','','','','F',NULL,NULL,'','','','','','','',NULL,NULL,
				'000000000000000000000000000000','','','ADMIN',NOW(),'ADMIN',NOW());
		END IF;
		-- 集团客史档案
		IF NOT EXISTS(SELECT 1 FROM guest_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_id = var_guest_id) THEN
			INSERT INTO guest_type (hotel_group_id, hotel_id, guest_id, sta, manual_no, sys_cat, flag_cat, grade, latency, 
				class1, class2, class3, class4, src, market, vip, belong_app_code, membership_type, membership_no, membership_level, 
				over_rsvsrc, valid_begin, valid_end, code1, code2, code3, code4, code5, flag, saleman, ar_no1, ar_no2, 
				extra_flag, extra_info, comments, create_user, create_datetime, modify_user, modify_datetime) 
			VALUES(arg_hotel_group_id,0,var_guest_id,'I',var_accnt,'F','','','',
				'','','','','','','','','','','','F',NULL,NULL,'','','','','','','',NULL,NULL,
				'000000000000000000000000000000','','','ADMIN',NOW(),'ADMIN',NOW());
		END IF; 	
		
		IF var_guest_id IS NOT NULL THEN
			INSERT INTO up_map_accnt(hotel_group_id,hotel_id,accnt_type,accnt_class,accnt_old,accnt_new) VALUES(arg_hotel_group_id,arg_hotel_id,'GUEST','F',var_accnt,var_guest_id);
		END IF;
		
		FETCH c_cursor INTO var_accnt,var_name,var_sex,var_class,var_birth,var_idtype,var_id_des,var_idno,var_nation,var_address;
	END WHILE;
	CLOSE c_cursor;
    
END$$

DELIMITER ;