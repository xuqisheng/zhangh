DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_migrate_member_import`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_migrate_member_import`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT
)
label_0:
BEGIN
	DECLARE var_hotel_descript 	    VARCHAR(60);
	DECLARE var_hotel_code	 	    VARCHAR(60);
	DECLARE var_feecode 		    VARCHAR(20);
	DECLARE var_feecode_descript    VARCHAR(60);
	DECLARE var_feecode_descript_en VARCHAR(60);

	SELECT pay_code  INTO var_feecode FROM aranya_member_data LIMIT 0,1;
	SELECT code,descript_short INTO var_hotel_code,var_hotel_descript FROM hotel_group WHERE id = arg_hotel_group_id;
	SELECT descript,descript_en INTO var_feecode_descript,var_feecode_descript_en FROM code_transaction
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code = var_feecode;

	SET autocommit=0;
	SET @procresult = 1;
	/* ******************************
	各酒店统一处理过程
	****************************** */
	START TRANSACTION;
        -- 补充,将没有档案的卡默认一个档案
        UPDATE aranya_member_data SET card_master = NULL WHERE card_master = '' AND hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
        UPDATE aranya_member_data SET card_name = card_no WHERE card_name IS NULL OR card_name = '' AND hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
        UPDATE aranya_member_data SET hname = card_name WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND hname = '';
        UPDATE aranya_member_data SET hlname = card_name WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND hlname = '';
        UPDATE aranya_member_data SET hfname = card_name WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND hfname = '';
        UPDATE aranya_member_data SET hname2 = card_name WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND hname2 = '';
        UPDATE aranya_member_data SET hname3 = card_name WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND hname3 = '';
        UPDATE aranya_member_data SET hname_combine = card_name WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND hname_combine = '';

        UPDATE aranya_member_data SET hno = card_id_temp,hname = IFNULL(card_name,card_no),hname_combine = IFNULL(card_name,card_no),
            hcreate_user ='ARANYA' ,hcreate_datetime =NOW(),hmodify_user = 'ARANYA',hmodify_datetime = NOW()
            WHERE hno IS NULL OR hname IS NULL AND hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

        -- 统一 预处理
        UPDATE aranya_member_data SET card_id_temp = card_id_temp - 20000,member_id_temp = card_id_temp ,card_master = card_master - 20000
            WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

        -- 有card_base member_base,需要改善

        -- 处理一人多卡，将同一hno的card_id_temp 设为同一人
        -- 阿那亚项目原数据中不存在明确的一人多卡关系，暂时不考虑。
  	COMMIT;

  	-- 插入会员信息
  	START TRANSACTION;
        INSERT INTO member_base (hotel_group_id,hotel_id,inner_id,guest_id,NAME,last_name,first_name,name2,name3,name_combine,
                                 is_save,sex,LANGUAGE,title,salutation,birth,race,religion,career,occupation,
                                 nation,id_code,id_no,id_end,company_id,company_name,pic_photo,pic_sign,remark,
                                 create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime)
            SELECT hotel_group_id,0,member_id_temp,NULL,IFNULL(hname,card_name),hlname,hfname,hname2,hname3,hname_combine,
                                 'T',sex,LANGUAGE,'','',(DATE(birth) + INTERVAL 1 HOUR),'','','','',
                                 nation,id_code,id_no,NULL,NULL,NULL,NULL,NULL,remark,
                                 var_hotel_code,IFNULL(hcreate_user,'ARANYA'),IFNULL(hcreate_datetime,NOW()),'',IFNULL(hmodify_user,'ARANYA'),IFNULL(hmodify_datetime,NOW())
            FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

        SELECT CONCAT('member_base OK:',COUNT(1)) FROM member_base WHERE hotel_group_id=arg_hotel_group_id AND create_hotel=var_hotel_code;

        -- 将正式的member_id 写入 migriate_yw.membercard 供后续调用
        UPDATE aranya_member_data  mc,member_base m SET mc.member_id = m.id WHERE mc.member_id_temp = m.inner_id AND m.hotel_group_id=arg_hotel_group_id AND m.inner_id < 0;
        UPDATE member_base SET inner_id = id WHERE inner_id < 0;
  	COMMIT;

  	START TRANSACTION;
  	INSERT INTO member_link_base (hotel_group_id,hotel_id,id,mobile,phone,fax,email,website,msn,qq,sns,blog,
  					    linkman1,linkman2,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime)
  		SELECT DISTINCT hotel_group_id,0,member_id,mobile,phone,'',email,'','','','','',
			'','',var_hotel_code,IFNULL(hcreate_user,'ARANYA'),IFNULL(hcreate_datetime,NOW()),'',IFNULL(hmodify_user,'ARANYA'),IFNULL(hmodify_datetime,NOW())
  		FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id ORDER BY member_id;

  	INSERT INTO member_link_addr (hotel_group_id,hotel_id,member_id, addr_type,is_default,country,
  					    state,city,division,street,zipcode,list_order,remark,
  					    create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime)
  		SELECT hotel_group_id,hotel_id,member_id,'HOME','T',
				IFNULL(country,'CN'),
				IFNULL(state,IF(LENGTH(id_no) = 18,SUBSTRING(id_no,1,2),'')) ,
				IFNULL(city,IF(LENGTH(id_no) = 18,SUBSTRING(id_no,3,2),'')),
				IFNULL(division,IF(LENGTH(id_no) = 18,SUBSTRING(id_no,5,2),'')),
				street,zipcode,0,'',
  				var_hotel_code,IFNULL(hcreate_user,'ARANYA'),IFNULL(hcreate_datetime,NOW()),'',IFNULL(hmodify_user,'ARANYA'),IFNULL(hmodify_datetime,NOW())
  		FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id ORDER BY member_id;
	    SELECT CONCAT('member_link_base OK:',COUNT(1)) FROM member_link_base WHERE hotel_group_id=arg_hotel_group_id AND create_hotel=var_hotel_code;
	COMMIT;


	START TRANSACTION;
        INSERT INTO member_type (hotel_group_id,hotel_id,member_id,sta,create_user,create_datetime,modify_user,modify_datetime)
            SELECT DISTINCT hotel_group_id ,hotel_id,member_id,'I',IFNULL(hcreate_user,'ARANYA'),IFNULL(hcreate_datetime,NOW()),IFNULL(hmodify_user,'ARANYA'),IFNULL(hmodify_datetime,NOW())
            FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

        INSERT INTO member_prefer (hotel_group_id,hotel_id,member_id,create_user,create_datetime,modify_user,modify_datetime)
            SELECT DISTINCT hotel_group_id,0,member_id,IFNULL(hcreate_user,'ARANYA'),IFNULL(hcreate_datetime,NOW()),IFNULL(hmodify_user,'ARANYA'),IFNULL(hmodify_datetime,NOW())
            FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

        INSERT INTO member_web (hotel_group_id,hotel_id,member_id,login_pw,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime)
            SELECT DISTINCT hotel_group_id ,hotel_id,member_id,loginpw,var_hotel_code,IFNULL(hcreate_user,'ARANYA'),IFNULL(hcreate_datetime,NOW()),'',IFNULL(hmodify_user,'ARANYA'),IFNULL(hmodify_datetime,NOW())
            FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

        SELECT CONCAT('member_web OK:',COUNT(1)) FROM member_web WHERE hotel_group_id=arg_hotel_group_id AND create_hotel=var_hotel_code;
	COMMIT;
  	-- 插入卡信息
  	START TRANSACTION;
  	INSERT INTO card_base (hotel_group_id,hotel_id,member_id,card_no,card_no2,inner_card_no,card_master,sta,card_type,card_level,
  			card_src,card_name,ratecode,posmode,date_begin,date_end,PASSWORD,salesman,extra_flag,card_flag,crc,remark,
  			point_pay,point_charge,point_last_num,point_last_num_link,charge,pay,last_num,last_num_link,
  			create_user,create_datetime,iss_hotel,create_user2,create_datetime2,modify_user2,modify_datetime2,modify_user,modify_datetime)
  		SELECT hotel_group_id,hotel_id,member_id,card_no,card_no2,card_id_temp,IFNULL(card_master,''),sta,card_type,card_level,
  			card_src,card_name,ratecode,posmode,date_begin,date_end,PASSWORD,salesman,'','',crc,remark,
  			point_pay,point_charge,IF((point_pay=0 AND point_charge= 0),0,1),0,charge,pay,IF((charge = 0 AND pay = 0),0,1),0,
  			IFNULL(create_user,'ARANYA'),IFNULL(create_datetime,NOW()),iss_hotel,IFNULL(create_user,'ARANYA'),IFNULL(create_datetime,NOW()),
  			IFNULL(modify_user,'ARANYA'),IFNULL(modify_datetime,NOW()),IFNULL(modify_user,'ARANYA'),IFNULL(modify_datetime,NOW())
  		FROM aranya_member_data ;
  	UPDATE aranya_member_data mc,card_base cb SET mc.card_id = cb.id WHERE  mc.card_id_temp = cb.inner_card_no AND cb.inner_card_no < 0;
  	UPDATE card_base SET inner_card_no = id WHERE inner_card_no < 0 AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

  	-- 处理附属卡
  	UPDATE aranya_member_data a,card_base b SET b.card_master = a.card_id
		WHERE a.card_id_temp = b.card_master AND b.card_master <>'' AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id
			AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;

   	SELECT CONCAT('card_base OK:',COUNT(1)) FROM card_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
  	COMMIT;
   	/*
 	-- 插入积分信息
 	START TRANSACTION;
        INSERT INTO card_point (hotel_group_id,hotel_id, card_no,number,biz_date,gen_date,fm_hotel,remark,
                produce,amount,accnt,subaccnt,roomno,ratecode,apply,exchange_no,balance,
                 point_gen_date,invalid_date,invalid_sta,invalid_mark_date,src,promotion,link,trans_code,
                create_user,create_datetime,modify_user,modify_datetime)
            SELECT m.hotel_group_id,m.hotel_id,card_id,1,biz_date,biz_date,h.descript ,'[系统：期初导入]',
                point_pay,0,NULL,NULL,'','',point_charge,NULL,point_pay - point_charge,
                m.biz_date,m.biz_date,'N',NULL,'AD','',NULL,NULL,
                 'ARANYA',NOW(),'ARANYA',NOW()
            FROM aranya_member_data m,(SELECT hotel_group_id,id AS hotel_id,descript FROM hotel UNION SELECT id AS hotel_group_id,0,descript FROM hotel_group) h
            WHERE h.hotel_id = m.hotel_id AND (point_pay<>0 OR point_charge<> 0) ;
	    SELECT CONCAT('card_point OK:',COUNT(1),',',SUM(produce),',',SUM(apply),',',SUM(produce-apply)) FROM card_point;
	COMMIT;
 	*/
 	-- 插入储值信息
 	START TRANSACTION;
        INSERT INTO card_account_master (hotel_group_id,hotel_id,card_id,member_id,NAME,sta,validate_begin,validate_end,charge,pay,credit,charge_limit,freeze,
                    last_num,freeze_last_num,tag,fee_allow,remark,create_user,create_datetime,modify_user,modify_datetime)
            SELECT hotel_group_id,0,card_id ,member_id,'主帐户','I',NULL,NULL,charge,pay,0,NULL,0,IF((charge = 0 AND pay = 0),0,1),0,'BASE','',CONCAT('原帐号',araccnt),'ARANYA',NOW(),'ARANYA',NOW()
            FROM aranya_member_data WHERE araccnt <> '' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

        UPDATE aranya_member_data a ,card_account_master b SET a.account_master_id = b.id
            WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = 0 AND a.card_id = b.card_id;

        INSERT INTO card_account (hotel_group_id,hotel_id,card_no,card_id,member_id,accnt,number,number_accnt,link_id,ta_code,ta_descript,ta_descript_en,charge,
                source,source_accnt,source_accnt_sub,source_accnt_id,roomno,pay,accept_bank,balance,biz_date,gen_date,cashier,act_flag,
                    ta_remark,ta_no,trans_flag,trans_accnt,close_flag,close_id,create_user,create_datetime,modify_user,modify_datetime	)
            SELECT hotel_group_id,hotel_id,card_no,card_id,member_id,account_master_id,1,1,NULL,var_feecode,var_feecode_descript,var_feecode_descript_en,charge,'OWN',NULL,NULL,NULL,'',pay,NULL,pay-charge,biz_date,biz_date,1,'AD',
                        '期初导入',NULL,NULL,NULL,NULL,NULL,'ARANYA',NOW(),'ARANYA',NOW()
            FROM aranya_member_data WHERE  araccnt <> '' AND (charge <> 0 OR pay <> 0) AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;


        SELECT CONCAT('card_account OK:',COUNT(1),',',SUM(pay),',',SUM(charge),',',SUM(pay-charge)) FROM card_account WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	COMMIT;

	/* *********************************************************************************************************
	生成card_snapshot数据
	***********************************************************************************************************/




	/* *********************************************************************************************************
	统一处理完毕
	***********************************************************************************************************/


	SET autocommit=1;

	BEGIN
 		SET @procresult = 0;
		LEAVE label_0 ;
	END ;

END$$

DELIMITER ;

-- CALL up_ihotel_migrate_member_import(2,14);