DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_get_guest_id_x5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_get_guest_id_x5`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_gno 				VARCHAR(20),
	IN arg_name 			VARCHAR(60),
	IN arg_idcls 			CHAR(3),
	IN arg_ident 			VARCHAR(20),
	IN arg_sex 				CHAR(1),
	IN arg_birth 			DATETIME,
	IN arg_race 			CHAR(2),
	IN arg_address 			CHAR(60),
	IN arg_birthplace 		CHAR(6),
	INOUT arg_guest_id 		BIGINT(16) 
	)
    SQL SECURITY INVOKER
label_0:
BEGIN
		
	DECLARE var_exists_in_group INT DEFAULT 0; 
	
	IF arg_gno = '' AND arg_name = '' THEN 
		BEGIN
		SET arg_guest_id = 0;
		LEAVE label_0;
		END; 
	END IF;

	SET arg_guest_id = 0; 
	SET var_exists_in_group = 0;
	IF arg_gno<>'' THEN 
		SELECT accnt_new INTO arg_guest_id FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'GUEST' AND accnt_old = arg_gno;
	END IF;
	
	IF arg_guest_id = 0 THEN
	   BEGIN		
		SELECT id INTO arg_guest_id FROM guest_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND id_no = arg_ident AND NAME = arg_name LIMIT 0,1;
		
		IF arg_guest_id <> 0 THEN  
			SET var_exists_in_group = 1; 
			IF EXISTS(SELECT 1 FROM guest_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_id = arg_guest_id) THEN
			   LEAVE label_0; 
			END IF;
		END IF;
	
		IF var_exists_in_group <> 1 THEN
		   INSERT INTO guest_base (hotel_group_id,hotel_id,name,last_name,first_name,name2,name3,name_combine,is_save,
					sex,LANGUAGE,title,salutation,birth,race,religion,career,occupation,nation,id_code,id_no,id_end,company_id,company_name,
					pic_photo,pic_sign,remark,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime)
				VALUES(arg_hotel_group_id,0,arg_name,'','',arg_name,arg_name,arg_name,'T',
					arg_sex,'C','','',arg_birth,arg_race,'','','','CN',arg_idcls,arg_ident,NULL,NULL,'',
					0,0,'',arg_hotel_id,'ADMIN',NOW(),arg_hotel_id,'ADMIN',NOW());
		   
		   SET arg_guest_id = LAST_INSERT_ID();
		   
		   INSERT INTO guest_link_base (hotel_group_id,hotel_id,id,mobile,phone,fax,email,website,msn,qq,sns,
					blog,linkman1,linkman2,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime)
				VALUES(arg_hotel_group_id,0,arg_guest_id,'','','','','','','','','','','',arg_hotel_id,'ADMIN',NOW(),arg_hotel_id,'ADMIN',NOW());
		   
		   IF arg_address <> '' OR arg_birthplace <> '' THEN			 
				INSERT INTO guest_link_addr (hotel_group_id,hotel_id,guest_id,addr_name,addr_type,is_default,country,
						state,city,division,street,zipcode,list_order,remark,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime) 
					 VALUES(arg_hotel_group_id,'0',arg_guest_id,'默认地址','HOME','T','CN','','',arg_birthplace,arg_address,'','0','','','ADMIN',NOW(),'','ADMIN',NOW());
			END IF;
		   
		   INSERT INTO guest_type (hotel_group_id,hotel_id,guest_id,sta,manual_no,sys_cat,flag_cat,grade,latency,class1,class2,class3,class4,
						src,market,vip,belong_app_code,membership_type,membership_no,membership_level,over_rsvsrc,valid_begin,valid_end,code1,code2,code3,code4,code5,
						flag,saleman,ar_no1,ar_no2,extra_flag,extra_info,comments,create_user,create_datetime,modify_user,modify_datetime)
					VALUES(arg_hotel_group_id,'0',arg_guest_id,'I','','F','','','','','','','',
						'','','','1','','','','F',NULL,NULL,'','','','','','','',NULL,NULL,'000000000000000000000000000000','','','ADMIN',NOW(),'ADMIN',NOW());
		END IF;
		
		IF arg_gno <> '' THEN 			
			INSERT INTO up_map_accnt(hotel_group_id,hotel_id,accnt_type,accnt_class,accnt_old,accnt_new) VALUES(arg_hotel_group_id,arg_hotel_id,'guest','F',arg_gno,arg_guest_id);
		END IF; 
		
		INSERT INTO guest_type (hotel_group_id,hotel_id,guest_id,sta,manual_no,sys_cat,flag_cat,grade,latency,class1,class2,class3,class4,
						src,market,vip,belong_app_code,membership_type,membership_no,membership_level,over_rsvsrc,valid_begin,valid_end,code1,code2,code3,code4,code5,
						flag,saleman,ar_no1,ar_no2,extra_flag,extra_info,comments,create_user,create_datetime,modify_user,modify_datetime)
					VALUES(arg_hotel_group_id,arg_hotel_id,arg_guest_id,'I','','F','','','','','','','',
						'','','','1','','','','F',NULL,NULL,'','','','','','','',NULL,NULL,'000000000000000000000000000000','','','ADMIN',NOW(),'ADMIN',NOW());
	   END;
	   
	END IF;
	
END$$

DELIMITER ;