DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_armst_v5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_armst_v5`(
	IN arg_hotel_group_id BIGINT(16),
	IN arg_hotel_id 	BIGINT(16)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	
	DECLARE var_int 	INTEGER ;
	DECLARE var_biz_date DATETIME ;
	DECLARE done_cursor INT DEFAULT 0 ;
	DECLARE var_accnt 	VARCHAR(7);
	DECLARE var_name 	VARCHAR(60); 
	DECLARE var_tag0 	VARCHAR(2); 
	DECLARE var_class 	VARCHAR(2);
	DECLARE var_cno 	VARCHAR(10); 
	DECLARE var_arr 	DATETIME; 
	DECLARE var_dep 	DATETIME; 
	DECLARE var_phone 	VARCHAR(20); 
	DECLARE var_fax 	VARCHAR(20); 
	DECLARE var_ref 	VARCHAR(256); 
	DECLARE var_mkt		VARCHAR(6);
	DECLARE var_profile_type VARCHAR(10);
	DECLARE var_profile_id BIGINT(16);
	DECLARE var_ar_cycle VARCHAR(10);
	DECLARE var_limit_type VARCHAR(2);
	DECLARE var_balance DECIMAL(12,2); 
	DECLARE var_ta_code VARCHAR(10);
	DECLARE var_arg_code VARCHAR(10);
	DECLARE var_ta_code_des VARCHAR(60);
	DECLARE var_ta_code_des_en VARCHAR(60);
	DECLARE var_id 		BIGINT(16);
	DECLARE var_sta		CHAR(1);
	DECLARE var_address VARCHAR(200);
	DECLARE var_zip CHAR(6);
	DECLARE var_cname VARCHAR(50);
	DECLARE var_intinfo VARCHAR(50);
	DECLARE var_cardno VARCHAR(20);
	DECLARE var_cby VARCHAR(20);
	DECLARE var_changed DATETIME;
	
	DECLARE c_armst CURSOR FOR SELECT accnt,NAME,tag0,class,arr,dep,ref,mkt,LEFT(phone,20),LEFT(fax,20),
	rmb_db-depr_cr-addrmb,sta,address,zip,c_name,intinfo,cardno,cby,changed 
		FROM migrate_xc.armst WHERE tag0<>'4';
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1 ;
	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='ARMST';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'ARMST',NOW(),NULL,0,''); 
	DELETE FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='armst';
	
	SELECT biz_date INTO var_biz_date FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id; 
	SELECT MIN(CODE) INTO var_ar_cycle FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code='ar_cycle'; 
	
	DELETE FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='armst' AND accnt_class='';
	
	SET var_int = 10 ;
	OPEN c_armst ;
	SET done_cursor = 0 ;
	FETCH c_armst INTO var_accnt,var_name,var_tag0,var_class,var_arr,var_dep,var_ref,var_mkt,var_phone,var_fax,var_balance,
		var_sta,var_address,var_zip,var_cname,var_intinfo,var_cardno,var_cby,var_changed; 
	WHILE done_cursor = 0 DO
		BEGIN			
				SET var_profile_id=0,var_limit_type = '1'; 
				
				INSERT INTO ar_master(hotel_group_id,hotel_id,arno,profile_type,profile_id,biz_date,sta,arr,dep,exp_sta,tm_sta,tag0,building,
					ar_cycle,ar_category,is_permanent,posting_flag,extra_flag,pay_code,limit_type,limit_amt,credit_no,credit_man,credit_company,salesman,
					phone,fax,email,charge,pay,credit,last_num,last_num_link,link_id,remark,co_msg,reminder_msg,
					last_charge_user,last_charge_datetime,last_pay_user,last_pay_datetime,last_invoice_user,last_invoice_datetime,last_statement_user,last_statement_datetime,
					last_reminder_to,last_reminder_user,last_reminder_datetime,create_user,create_datetime,modify_user,modify_datetime)
				VALUES(arg_hotel_group_id,arg_hotel_id,var_accnt,'',var_profile_id,var_biz_date,var_sta,var_arr,var_dep,'','I','','###',
					var_ar_cycle,var_tag0,'T','1','001000000000000000000000000000','',var_limit_type,0,'','','',var_mkt,
					var_phone,var_fax,var_intinfo,var_balance,0,0,0,0,NULL,var_ref,'','',
					'',NULL,'',NULL,'',NULL,'',NULL,
					'','',NULL,var_cby,var_changed,var_cby,var_changed);
					
				SET var_id = LAST_INSERT_ID(); 
				
				INSERT INTO ar_master_guest(hotel_group_id,hotel_id,id,NAME,name2,name_combine,coding,LANGUAGE,nation,linkman,
					address,zipcode,create_user,create_datetime,modify_user,modify_datetime)
				VALUES(arg_hotel_group_id,arg_hotel_id,var_id,var_name,'',var_name,var_accnt,'C','CN',var_cname,
					var_address,var_zip,var_cby,var_changed,var_cby,var_changed);

			SET done_cursor = 0 ;
			FETCH c_armst INTO var_accnt,var_name,var_tag0,var_class,var_arr,var_dep,var_ref,var_mkt,var_phone,var_fax,var_balance,
				var_sta,var_address,var_zip,var_cname,var_intinfo,var_cardno,var_cby,var_changed;		
			END ;
	END WHILE ;
	CLOSE c_armst ;	
	
	INSERT INTO up_map_accnt(hotel_group_id,hotel_id,accnt_type,accnt_class,accnt_old,accnt_new) 
		SELECT arg_hotel_group_id,arg_hotel_id,'armst','',arno,id FROM ar_master
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND building='###'; 
	
	INSERT INTO ar_account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt,rmno,guest_id,to_accnt,to_rmno,NAME,
			ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
		SELECT arg_hotel_group_id,arg_hotel_id,'POSTING','',id,'',0,0,'','',
			'*','',arr,dep,'',create_user,create_datetime,modify_user,modify_datetime
		FROM ar_master WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND building='###'; 
	
	INSERT INTO ar_account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt,rmno,guest_id,to_accnt,to_rmno,NAME,
			ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
		SELECT arg_hotel_group_id,arg_hotel_id,'SUBACCNT','SYS_FIX',id,'',profile_id,0,'','',
			'*','',arr,dep,'',create_user,create_datetime,modify_user,modify_datetime
		FROM ar_master WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND building='###'; 
	
	-- 更新分账户的名称 
	UPDATE ar_account_sub a,ar_master_guest b SET a.name=b.name 
	WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
	AND a.accnt=b.id AND a.type='SUBACCNT' AND a.tag='SYS_FIX';
	-- 销售员
	UPDATE ar_master a,up_map_code b SET a.salesman = b.code_new WHERE  b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.cat = 'salesman' AND a.salesman = b.code_old AND a.salesman<>'' ;
	
	UPDATE ar_master SET link_id = id WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND building='###'; 
	
 	CALL ihotel_up_armst_account_v5(arg_hotel_group_id,arg_hotel_id);	
		
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='ARMST';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='ARMST';
	
END$$

DELIMITER ;