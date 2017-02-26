DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_pccode_jierep_all`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_pccode_jierep_all`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_accnt			INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ===============================================================
	--  往指定消费账账号里插入每一笔费用码，用于测试底表是否平衡
	-- 
	-- 作者：张惠
	-- ===============================================================
	DECLARE done_cursor		INT DEFAULT 0;
	DECLARE var_bdate		DATETIME;
	DECLARE var_number		INT;
	DECLARE var_tacode		VARCHAR(10);
	DECLARE var_arrcode		VARCHAR(10);	
	DECLARE var_descript	VARCHAR(60);
	DECLARE var_descript_en	VARCHAR(60);
	DECLARE var_subaccnt	INT;
	
	DECLARE c_cursor CURSOR FOR 
	SELECT code,arrange_code,descript,descript_en FROM code_transaction 
		WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9' AND is_halt='F' ORDER BY code;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;

	SELECT biz_date1 INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	SELECT id INTO var_subaccnt FROM account_sub WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND type='SUBACCNT' AND tag='SYS_FIX' AND accnt_type='MASTER' AND accnt=arg_accnt;
	SELECT IFNULL(MAX(number),0) INTO var_number FROM account WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt=arg_accnt;
				
	OPEN c_cursor;
	SET done_cursor = 0;
	FETCH c_cursor INTO var_tacode,var_arrcode,var_descript,var_descript_en;
	WHILE done_cursor = 0 DO
		BEGIN		
			SET var_number = var_number + 1;

			INSERT INTO account(hotel_group_id,hotel_id,accnt,subaccnt,number,inumber,modu_code,biz_date,gen_date,ta_code,arrange_code,
				article_code,quantity,charge,charge_base,charge_dsc,charge_srv,charge_tax,charge_oth,package_use,package_limit,package_rate
				,pay,balance,cashier,act_flag,accept_bank,market,reason,trans_flag,trans_accnt,trans_subaccnt,ta_descript,ta_descript_en,
				ta_no,ta_remark,rmno,grp_accnt,rmpost_mode,close_flag,close_id,split_flag,split_user,split_datetime,split_cashier,mode1,
				pkg_number,create_user,create_datetime,modify_user,modify_datetime,card_id,card_no)	
			SELECT arg_hotel_group_id,arg_hotel_id,arg_accnt,var_subaccnt,var_number,NULL,'02',var_bdate,NOW(),var_tacode,var_arrcode,
				'','1.00','1.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0.00','0','','','','',NULL,NULL,NULL,
				var_descript,var_descript_en,'','','',NULL,'','',NULL,'','',NULL,NULL,'',NULL,'ADMIN',NOW(),'ADMIN',NOW(),NULL,NULL;			
	
			SET done_cursor = 0;
			FETCH c_cursor INTO var_tacode,var_arrcode,var_descript,var_descript_en;
		END;
	END WHILE;	
	CLOSE c_cursor;	
	
	UPDATE master_base a SET a.charge=IFNULL((SELECT SUM(b.charge) FROM account b WHERE a.id=b.accnt AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id),0) WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=arg_accnt;
	UPDATE master_base a SET a.pay=IFNULL((SELECT SUM(b.pay) FROM account b WHERE a.id=b.accnt AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id),0) WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=arg_accnt;
	
  END$$

DELIMITER ;

CALL up_ihotel_pccode_jierep_all(1,101,'');

DROP PROCEDURE IF EXISTS `up_ihotel_pccode_jierep_all`;
