DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_armst_x5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_armst_x5`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_biz_date 	DATETIME ;	
	DECLARE var_accnt 		VARCHAR(7);
	DECLARE var_name 		VARCHAR(60); 
	DECLARE var_artag1 		VARCHAR(2); 
	DECLARE var_artag2 		VARCHAR(2);
	DECLARE var_cno 		VARCHAR(10); 
	DECLARE var_arr 		DATETIME; 
	DECLARE var_dep 		DATETIME; 
	DECLARE var_phone 		VARCHAR(20);
	DECLARE var_fax 		VARCHAR(20);
	DECLARE var_mobile 		VARCHAR(20);	
	DECLARE var_ref 		VARCHAR(256); 
	DECLARE var_profile_type VARCHAR(10);
	DECLARE var_profile_id 	BIGINT(16);
	DECLARE var_ar_cycle 	VARCHAR(10);
	DECLARE var_balance 	DECIMAL(12,2); 
	DECLARE var_id 			BIGINT(16);
	DECLARE var_sno 		VARCHAR(15);
	DECLARE var_cby			VARCHAR(10);
	DECLARE var_changed		DATETIME;
	DECLARE var_address		VARCHAR(200);
	DECLARE var_liason		VARCHAR(20);
	DECLARE var_zip			VARCHAR(6);
	
	DECLARE c_armst CURSOR FOR SELECT a.accnt,b.name,a.artag1,a.artag2,a.arr,a.dep,a.ref,b.phone,b.fax,b.mobile,
		a.charge-a.credit,b.sno,a.cby,a.changed,CONCAT(a.address1,' ',a.address2,' ',a.address3,' ',a.address4),b.liason,b.zip 
		FROM migrate_db.ar_master a,migrate_db.guest b 
		WHERE a.haccnt=b.no AND a.sta='I' AND a.artag1<>'LO' ORDER BY a.accnt;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1 ;
	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='armst';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'armst',NOW(),NULL,0,''); 
	
	SELECT biz_date INTO var_biz_date FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id; 
	SELECT MIN(CODE) INTO var_ar_cycle FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code='ar_cycle'; 
	
	DELETE FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='armst';
	
	OPEN c_armst ;
	SET done_cursor = 0 ;
	
	FETCH c_armst INTO var_accnt,var_name,var_artag1,var_artag2,var_arr,var_dep,var_ref,var_phone,var_fax,var_mobile,var_balance,var_sno,var_cby,var_changed,var_address,var_liason,var_zip; 
	WHILE done_cursor = 0 DO
		BEGIN			
				SET var_profile_id=0,var_profile_type='';
				
				IF var_arr IS NULL THEN 
					SET var_arr = '2016-01-01'; 
				END IF; 
				IF var_dep IS NULL OR var_dep  THEN 
					SET var_dep = '2020-12-31'; 
				END IF; 
				
				INSERT INTO ar_master(hotel_group_id,hotel_id,arno,profile_type,profile_id,biz_date,sta,arr,dep,exp_sta,tm_sta,tag0,building,
					ar_cycle,ar_category,is_permanent,posting_flag,extra_flag,pay_code,limit_type,limit_amt,credit_no,credit_man,credit_company,salesman,
					phone,fax,email,charge,pay,credit,last_num,last_num_link,link_id,remark,co_msg,reminder_msg,
					last_charge_user,last_charge_datetime,last_pay_user,last_pay_datetime,last_invoice_user,last_invoice_datetime,last_statement_user,last_statement_datetime,
					last_reminder_to,last_reminder_user,last_reminder_datetime,create_user,create_datetime,modify_user,modify_datetime,mobil)
				VALUES(arg_hotel_group_id,arg_hotel_id,var_accnt,var_profile_type,var_profile_id,var_biz_date,'I',var_arr,'2018-12-31','','I','','###',
					var_ar_cycle,var_artag1,'T','1','001000000000000000000000000000','',var_artag2,0,'','','','',
					var_phone,var_fax,'',var_balance,0,0,0,0,NULL,var_ref,var_sno,'',
					'',NULL,'',NULL,'',NULL,'',NULL,
					'','',NULL,var_cby,var_changed,var_cby,var_changed,var_mobile);

				SET var_id = LAST_INSERT_ID(); 
				
				INSERT INTO ar_master_guest(hotel_group_id,hotel_id,id,name,name2,name_combine,coding,language,nation,linkman,address,zipcode,create_user,create_datetime,modify_user,modify_datetime)
					VALUES(arg_hotel_group_id,arg_hotel_id,var_id,var_name,'',var_name,var_accnt,'C','CN',var_liason,var_address,var_zip,var_cby,var_changed,var_cby,var_changed);
					
			SET done_cursor = 0 ;
			FETCH c_armst INTO var_accnt,var_name,var_artag1,var_artag2,var_arr,var_dep,var_ref,var_phone,var_fax,var_mobile,var_balance,var_sno,var_cby,var_changed,var_address,var_liason,var_zip; 
		END ;
	END WHILE ;
	CLOSE c_armst ;		
	
	INSERT INTO up_map_accnt(hotel_group_id,hotel_id,accnt_type,accnt_class,accnt_old,accnt_new) 
		SELECT arg_hotel_group_id,arg_hotel_id,'armst','',arno,id FROM ar_master 
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND building='###'; 
	
	INSERT INTO ar_account_sub(hotel_group_id,hotel_id,TYPE,tag,accnt,rmno,guest_id,to_accnt,to_rmno,NAME,
			ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
		SELECT arg_hotel_group_id,arg_hotel_id,'POSTING','',id,'',0,0,'','',
			'*','',arr,dep,'','ADMIN',NOW(),'ADMIN',NOW()
		FROM ar_master WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND building='###'; 
	
	INSERT INTO ar_account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt,rmno,guest_id,to_accnt,to_rmno,NAME,
			ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
		SELECT arg_hotel_group_id,arg_hotel_id,'SUBACCNT','SYS_FIX',id,'',profile_id,0,'','',
			'*','',arr,dep,'','ADMIN',NOW(),'ADMIN',NOW()
		FROM ar_master WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND building='###'; 
	
	-- 更新分账户的名称 
	UPDATE ar_account_sub a,ar_master_guest b SET a.name=b.name 
	WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id
	AND a.accnt=b.id AND a.type='SUBACCNT' AND a.tag='SYS_FIX';
	
	UPDATE ar_master SET link_id = id WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND building='###';
	
	UPDATE ar_master a,(SELECT hotel_id,accnt,SUM(amount) amount FROM accredit WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type = 'A' GROUP BY accnt) AS b 
	SET a.credit = b.amount WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_id=arg_hotel_id AND a.id = b.accnt;
	
	UPDATE ar_master SET extra_flag = '001000000000000000010000000000' WHERE id IN (SELECT DISTINCT accnt FROM accredit WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type = 'A' ) AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	
 	CALL ihotel_up_armst_account_x5(arg_hotel_group_id,arg_hotel_id);
	
	UPDATE ar_master a,up_map_code b SET a.ar_category = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.code = 'ar_tag' AND b.code_old = a.ar_category; 
	
	UPDATE ar_master a,up_map_code b SET a.pay_code = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code IN ('paymth','pccode') AND b.code_old = a.pay_code; 
	UPDATE ar_master SET pay_code = '9000' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id AND pay_code = '';		
	
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='armst';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='armst';
	
END$$

DELIMITER ;