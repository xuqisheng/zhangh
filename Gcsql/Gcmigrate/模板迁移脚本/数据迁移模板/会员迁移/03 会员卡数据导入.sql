
DELIMITER $$

DROP PROCEDURE IF EXISTS up_ihotel_up_member_import$$

CREATE DEFINER=`root`@`%` PROCEDURE up_ihotel_up_member_import(
	INOUT var_return VARCHAR(128)  -- 返回空串表示成功，否则表示失败  
)
label_0:
BEGIN
	DECLARE var_hotel_group_id BIGINT;
	DECLARE var_hotel_descript VARCHAR(60);
	DECLARE var_feecode VARCHAR(20);
	DECLARE var_feecode_descript VARCHAR(60);
	DECLARE var_feecode_descript_en VARCHAR(60);
	
	SELECT hotel_group_id INTO var_hotel_group_id FROM migrate_db.membercard LIMIT 0,1;
	SELECT pay_code  INTO var_feecode FROM migrate_db.membercard LIMIT 0,1;
	SELECT descript_short INTO var_hotel_descript FROM hotel_group WHERE id = var_hotel_group_id;
	SELECT descript,descript_en INTO var_feecode_descript,var_feecode_descript_en FROM code_transaction WHERE hotel_group_id = var_hotel_group_id AND hotel_id = 0 AND CODE = var_feecode;
	
	SET autocommit=0; 
	/*******************************
	各酒店统一处理过程
	*******************************/
	START TRANSACTION;  
  	-- 补充，将没有档案的卡默认一个档案
  	UPDATE migrate_db.membercard SET card_master = NULL WHERE card_master = '';
  	UPDATE migrate_db.membercard SET card_name = card_no WHERE card_name IS NULL OR card_name = '';
  	UPDATE migrate_db.membercard SET hno = card_id_temp ,hname = IFNULL(card_name,card_no) ,hname_combine = IFNULL(card_name,card_no) ,
		hcreate_user ='ADMIN_YQ' ,hcreate_datetime =NOW() ,hmodify_user = 'ADMIN_YQ' ,hmodify_datetime = NOW()  	
		WHERE hno IS NULL OR hname IS NULL;
	
	
  
  	-- 统一 预处理
  	UPDATE migrate_db.membercard  SET card_id_temp = card_id_temp -1000000000,member_id_temp = card_id_temp ,card_master = card_master -1000000000;

	-- 有card_base member_base,需要改善
-- 	UPDATE card_base cb ,migrate_db.msg002_membercard mc,migrate_db.msg002_armst ar
-- 	SET cb.create_datetime=ar.reserved,cb.modify_datetime=ar.changed
-- 	WHERE cb.id = mc.card_id AND mc.araccnt = ar.accnt
-- 	AND cb.create_datetime = '0000-00-00 00:00:00'  	
  	
	-- 将membercard表的主键card_id_temp比照card_base 表处理，不要重复了
	
  	-- 处理一人多卡，将同一hno的card_id_temp 设为同一人	
  	UPDATE migrate_db.membercard m,(  
  	SELECT member_id_temp,hno FROM migrate_db.membercard WHERE hno <> '' GROUP BY hno HAVING COUNT(hno) > 1 
  	) t SET m.member_id_temp = t.member_id_temp WHERE m.hno = t.hno AND t.hno <> '';
  	COMMIT;
  	
  	
  	  
  	-- 插入会员信息
  	START TRANSACTION; 
  	INSERT INTO member_base (hotel_group_id, hotel_id, inner_id,guest_id,NAME, last_name, first_name, name2, name3, name_combine, 
  						     is_save, sex, LANGUAGE, title, salutation, birth, race, religion, career, occupation, 
  						     nation, id_code, id_no, id_end, company_id, company_name, pic_photo, pic_sign, remark, 
  						     create_hotel, create_user, create_datetime, modify_hotel, modify_user, modify_datetime) 
  		SELECT hotel_group_id,0,member_id_temp,guest_id,IFNULL(hname,card_name),hlname,hfname,hname2,hname3,hname_combine,
  						     'T',sex,LANGUAGE,'','',(DATE(birth) + INTERVAL 1 HOUR),'','','','',
  						     nation,id_code,id_no,NULL,company_id,NULL,NULL,NULL,CONCAT(remark,'###',card_no2),
  						     '',IFNULL(hcreate_user,'ADMIN_YQ'),IFNULL(hcreate_datetime,NOW()),'',IFNULL(hmodify_user,'ADMIN_YQ'),IFNULL(hmodify_datetime,NOW())
  		FROM migrate_db.membercard GROUP BY hno;
  	SELECT CONCAT('member_base OK:',COUNT(1)) FROM member_base WHERE hotel_group_id = 118;
  	
  	-- 将正式的member_id 写入migrate_db.membercard供后续调用
  	UPDATE migrate_db.membercard  mc,member_base m SET mc.member_id = m.id WHERE mc.member_id_temp = m.inner_id AND m.inner_id < 0;
  	UPDATE member_base SET inner_id = id WHERE inner_id < 0;
  	UPDATE member_base a,company_base b SET a.company_name = b.name WHERE a.company_id = b.id;
  	COMMIT;	

  	START TRANSACTION; 
  	INSERT INTO member_link_base (hotel_group_id, hotel_id, id, mobile, phone, fax, email, website, msn, qq, sns, blog, 
  					    linkman1, linkman2, create_hotel, create_user, create_datetime, modify_hotel, modify_user, modify_datetime) 	
  		SELECT hotel_group_id,0,member_id,mobile,phone,'',email,'','','','','','','',
  				'',IFNULL(hcreate_user,'ADMIN_YQ'),IFNULL(hcreate_datetime,NOW()),'',IFNULL(hmodify_user,'ADMIN_YQ'),IFNULL(hmodify_datetime,NOW())
  		FROM migrate_db.membercard GROUP BY hno ORDER BY member_id ;
  			
  	INSERT INTO member_link_addr (hotel_group_id, hotel_id, member_id,  addr_type, is_default, country,
  					    state, city, division, street, zipcode, list_order, remark, 
  					    create_hotel, create_user, create_datetime, modify_hotel, modify_user, modify_datetime) 
  		SELECT hotel_group_id ,0,member_id,'HOME','T',
				IFNULL(country,'CN'),
				IFNULL(state,IF(LENGTH(id_no) = 18,SUBSTRING(id_no,1,2),'')) ,
				IFNULL(city,IF(LENGTH(id_no) = 18,SUBSTRING(id_no,3,2),'')),
				IFNULL(division,IF(LENGTH(id_no) = 18,SUBSTRING(id_no,5,2),'')),
				street,zipcode,0,'',				
  				'',IFNULL(hcreate_user,'ADMIN_YQ'),IFNULL(hcreate_datetime,NOW()),'',IFNULL(hmodify_user,'ADMIN_YQ'),IFNULL(hmodify_datetime,NOW())
  		FROM migrate_db.membercard GROUP BY hno ORDER BY member_id;
	SELECT CONCAT('member_link_base OK:',COUNT(1)) FROM member_link_base WHERE hotel_group_id = 118;
	COMMIT;
	
 	
 	START TRANSACTION; 
  	INSERT INTO member_type ( member_id,hotel_group_id, hotel_id, sta,src,create_user, create_datetime, modify_user, modify_datetime)
		SELECT DISTINCT member_id,hotel_group_id ,0,'I',src,IFNULL(hcreate_user,'ADMIN_YQ'),IFNULL(hcreate_datetime,NOW()),IFNULL(hmodify_user,'ADMIN_YQ'),IFNULL(hmodify_datetime,NOW())
		FROM migrate_db.membercard GROUP BY hno;
		
  	INSERT INTO member_prefer ( member_id, hotel_group_id, hotel_id,create_user, create_datetime, modify_user, modify_datetime)
		SELECT DISTINCT member_id,hotel_group_id,0,IFNULL(hcreate_user,'ADMIN_YQ'),IFNULL(hcreate_datetime,NOW()),IFNULL(hmodify_user,'ADMIN_YQ'),IFNULL(hmodify_datetime,NOW())
		FROM migrate_db.membercard GROUP BY hno;

  	INSERT INTO member_web (member_id,hotel_group_id, hotel_id, login_pw, create_hotel,create_user, create_datetime, modify_hotel,modify_user, modify_datetime)
		SELECT DISTINCT member_id,hotel_group_id ,0,loginPW,'',IFNULL(hcreate_user,'ADMIN_YQ'),IFNULL(hcreate_datetime,NOW()),'',IFNULL(hmodify_user,'ADMIN_YQ'),IFNULL(hmodify_datetime,NOW())
		FROM migrate_db.membercard GROUP BY hno;
		  		
	SELECT CONCAT('member_web OK:',COUNT(1)) FROM member_web WHERE hotel_group_id = 118;
	COMMIT;
  	-- 插入卡信息
  	START TRANSACTION;
  	INSERT INTO card_base (hotel_group_id,hotel_id,member_id,card_no,card_no2,inner_card_no,card_master,sta,card_type,card_level,
  			card_src,card_name,ratecode,posmode,date_begin,date_end,PASSWORD,salesman,extra_flag,card_flag,crc,remark,
  			point_pay,point_charge,point_last_num,point_last_num_link,charge,pay,credit,last_num,last_num_link,
  			create_user,create_datetime,iss_hotel,create_user2,create_datetime2,modify_user2,modify_datetime2,modify_user,modify_datetime)
  		SELECT 	hotel_group_id,hotel_id,member_id,card_no,card_no2,card_id_temp,IFNULL(card_master,''),sta,card_type,card_level,
  			card_src,card_name,ratecode,posmode,date_begin,date_end,PASSWORD,salesman,'','',crc,remark,
  			point_pay,point_charge,IF((point_pay=0 AND point_charge= 0),0,1),0,charge,pay,accredit,IF((charge = 0 AND pay = 0),0,1),0,
  			IFNULL(create_user,'ADMIN_YQ'),IFNULL(create_datetime,NOW()),iss_hotel,IFNULL(create_user,'ADMIN_YQ'),IFNULL(create_datetime,NOW()),
  			IFNULL(modify_user,'ADMIN_YQ'),IFNULL(modify_datetime,NOW()),IFNULL(modify_user,'ADMIN_YQ'),IFNULL(modify_datetime,NOW())		
  		FROM migrate_db.membercard ;
  	UPDATE migrate_db.membercard  mc,card_base cb SET mc.card_id = cb.id WHERE  mc.card_id_temp = cb.inner_card_no AND cb.inner_card_no < 0;
  	UPDATE card_base SET inner_card_no = id WHERE inner_card_no < 0;
 
  	-- 处理附属卡
  	UPDATE migrate_db.membercard a,card_base b 
		SET b.card_master = a.card_id
		WHERE a.card_id_temp = b.card_master AND b.card_master <>'';
		
  	
   	SELECT CONCAT('card_base OK:',COUNT(1)) FROM card_base WHERE hotel_group_id = 118;
  	COMMIT;
   	
 	-- 插入积分信息
 	START TRANSACTION;
 	INSERT INTO card_point (hotel_group_id, hotel_id,  card_no, number, biz_date, gen_date, fm_hotel, remark, 
 			produce, amount, accnt, subaccnt, roomno, ratecode, apply, exchange_no, balance,
 			 point_gen_date,invalid_date, invalid_sta, invalid_mark_date, src, promotion, link, trans_code, 
 			create_user, create_datetime, modify_user, modify_datetime)
 		SELECT m.hotel_group_id, m.hotel_id,card_id, 1, biz_date, biz_date, h.descript , '[系统：期初导入]',
 			point_pay, 0, NULL, NULL, '', '', point_charge, NULL, point_pay - point_charge,
 			m.biz_date, m.biz_date, 'N', NULL, 'AD', '', NULL, NULL,
 			 'ADMIN_YQ', NOW(), 'ADMIN_YQ', NOW()
 		FROM migrate_db.membercard m,(SELECT hotel_group_id,id AS hotel_id,descript FROM hotel UNION SELECT id AS hotel_group_id,0,descript FROM hotel_group) h 
 		WHERE h.hotel_id = m.hotel_id AND (point_pay<>0 OR point_charge<> 0) ;
	SELECT CONCAT('card_point OK:',COUNT(1),',',SUM(produce),',',SUM(apply),',',SUM(produce-apply)) FROM card_point WHERE hotel_group_id = 118;
	COMMIT;
 		
 	-- 插入储值信息   
 	START TRANSACTION; 
 	INSERT INTO card_account_master (hotel_group_id, hotel_id,  card_id, member_id, NAME, sta, validate_begin, validate_end, charge, pay, credit, charge_limit, freeze, 
 				last_num, freeze_last_num, tag, fee_allow, remark, create_user, create_datetime, modify_user, modify_datetime)
		SELECT hotel_group_id,0,card_id ,member_id,'主帐户','I',NULL,NULL,charge,pay,accredit,NULL,0,IF((charge = 0 AND pay = 0),0,1),0,'BASE','',CONCAT('原帐号',araccnt),'ADMIN_YQ',NOW(),'ADMIN_YQ',NOW() 
		FROM migrate_db.membercard  ;
  	
  	UPDATE migrate_db.membercard mc ,card_account_master cam SET mc.account_master_id = cam.id  WHERE cam.hotel_group_id = mc.hotel_group_id AND cam.hotel_id = 0  AND mc.card_id = cam.card_id;  	
 	
 	INSERT INTO card_account (hotel_group_id, hotel_id, card_id, member_id, accnt, number, number_accnt, link_id, ta_code, ta_descript, ta_descript_en, charge, 
 			source, source_accnt, source_accnt_sub, source_accnt_id, roomno, pay, accept_bank, balance, biz_date, gen_date, cashier, act_flag, 
 				ta_remark, ta_no, trans_flag, trans_accnt, close_flag, close_id, create_user, create_datetime, modify_user, modify_datetime	)
		SELECT hotel_group_id,hotel_id,card_id,member_id,account_master_id,1,1,NULL,var_feecode,var_feecode_descript,var_feecode_descript_en,charge,'OWN',NULL,NULL,NULL,'',pay,NULL,pay-charge,biz_date,biz_date,1,'AD',
 	 				'期初导入',NULL,NULL,NULL,NULL,NULL,'ADMIN_YQ',NOW(),'ADMIN_YQ',NOW()
		FROM migrate_db.membercard WHERE  (charge <> 0 OR pay <> 0) ;
 		

	SELECT CONCAT('card_account OK:',COUNT(1),',',SUM(pay),',',SUM(charge),',',SUM(pay-charge)) FROM card_account WHERE hotel_group_id = 118;
	COMMIT;
	
	/**********************************************************************************************************
	生成card_snapshot数据
	***********************************************************************************************************/
	
		
 	
	
	/**********************************************************************************************************
	统一处理完毕
	***********************************************************************************************************/
	

	SET autocommit=1; 
			
	BEGIN
-- 		SET @procresult = 0 ;
		SET var_return = '';
		LEAVE label_0 ;
	END ;
	
END$$

DELIMITER ;
  