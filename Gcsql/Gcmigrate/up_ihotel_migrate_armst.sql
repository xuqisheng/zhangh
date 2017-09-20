DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_migrate_armst`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_migrate_armst`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	
	DECLARE var_biz_date DATETIME ;
	DECLARE done_cursor INT DEFAULT 0 ;
	DECLARE var_accnt 	VARCHAR(20);
	DECLARE var_name 	VARCHAR(60); 
	DECLARE var_tag0 	VARCHAR(2); 
	DECLARE var_class 	VARCHAR(2);
	DECLARE var_arr 	DATETIME; 
	DECLARE var_dep 	DATETIME; 
	DECLARE var_phone 	VARCHAR(20); 
	DECLARE var_fax 	VARCHAR(20); 
	DECLARE var_ref 	VARCHAR(256); 
	DECLARE var_mkt		VARCHAR(10);
	DECLARE var_profile_id 	BIGINT(16);
	DECLARE var_ar_cycle 	VARCHAR(10);
	DECLARE var_limit_type 	VARCHAR(2);
	DECLARE var_balance 	DECIMAL(12,2); 
	DECLARE var_ta_code 	VARCHAR(10);
	DECLARE var_arg_code 	VARCHAR(10);
	DECLARE var_ta_code_des VARCHAR(60);
	DECLARE var_ta_code_des_en VARCHAR(60);
	DECLARE var_ta_code1 	VARCHAR(10);
	DECLARE var_arg_code1 	VARCHAR(10);
	DECLARE var_ta_code_des1 VARCHAR(60);
	DECLARE var_ta_code_des_en1 VARCHAR(60);
	DECLARE var_id 		BIGINT(16);
	DECLARE var_sta		CHAR(1);
	DECLARE var_address VARCHAR(200);
	DECLARE var_zip 	CHAR(6);
	DECLARE var_cname 	VARCHAR(50);
	DECLARE var_intinfo VARCHAR(50);
	DECLARE var_cardno 	VARCHAR(20);
	DECLARE var_cby 	VARCHAR(20);
	DECLARE var_changed DATETIME;
	DECLARE var_paycode VARCHAR(20);
	
	DECLARE c_armst CURSOR FOR SELECT accnt,name1,IFNULL(artype,'LC'),'',begin_,end_,IF(remark='NULL','',remark),'',LEFT(IF(IFNULL(phone,'')='NULL','',IFNULL(phone,'')),20),
		LEFT(IF(IFNULL(fax,'')='NULL','',IFNULL(fax,'')),20),IFNULL(balance,0),'I',IFNULL(IF(street='NULL','',street),''),'','',IFNULL(IF(email='NULL','',email),''),'','migrate',NOW() 
		FROM migrate_db.armst;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1 ;

	DELETE FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='armst';
	
	SELECT biz_date INTO var_biz_date FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id; 
	SELECT MIN(code) INTO var_ar_cycle FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code='ar_cycle';	
	
	DELETE FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='armst' AND accnt_class='';

	SET var_paycode = '9000',var_limit_type = '1';	-- AR账主单的付款码
	
	OPEN c_armst ;
	SET done_cursor = 0 ;
	FETCH c_armst INTO var_accnt,var_name,var_tag0,var_class,var_arr,var_dep,var_ref,var_mkt,var_phone,
		var_fax,var_balance,var_sta,var_address,var_zip,var_cname,var_intinfo,var_cardno,var_cby,var_changed; 
	WHILE done_cursor = 0 DO
		BEGIN			
				SET var_profile_id=0; 
				
				INSERT INTO ar_master(hotel_group_id,hotel_id,arno,profile_type,profile_id,biz_date,sta,arr,dep,exp_sta,tm_sta,tag0,building,
					ar_cycle,ar_category,is_permanent,posting_flag,extra_flag,pay_code,limit_type,limit_amt,credit_no,credit_man,credit_company,salesman,
					phone,fax,email,charge,pay,credit,last_num,last_num_link,link_id,remark,co_msg,reminder_msg,
					last_charge_user,last_charge_datetime,last_pay_user,last_pay_datetime,last_invoice_user,last_invoice_datetime,last_statement_user,last_statement_datetime,
					last_reminder_to,last_reminder_user,last_reminder_datetime,create_user,create_datetime,modify_user,modify_datetime)
				VALUES(arg_hotel_group_id,arg_hotel_id,var_accnt,'',var_profile_id,var_biz_date,var_sta,var_arr,var_dep,'','I','','###',
					var_ar_cycle,var_tag0,'T','1','001000000000000000000000000000',var_paycode,var_limit_type,0,'','','',var_mkt,
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

	UPDATE ar_master SET link_id = id WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND building='###';	
 
	-- 需要余额导入时开启
	/*
	-- 取切换余额的费用码
	SELECT CODE,descript,descript_en,arrange_code INTO var_ta_code,var_ta_code_des,var_ta_code_des_en,var_arg_code FROM code_transaction 
	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND CODE='8000';
	-- 取切换余额的付款码
	SELECT CODE,descript,descript_en,arrange_code INTO var_ta_code1,var_ta_code_des1,var_ta_code_des_en1,var_arg_code1 FROM code_transaction 
	WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND CODE='9000';

	-- ar_account汇总表
	INSERT INTO ar_account (hotel_group_id,hotel_id,accnt,subaccnt,number,inumber,modu_code,biz_date,gen_date,ta_code,arrage_code,quantity,charge,pay,balance,charge0,pay0, 
		charge1, pay1,charge9, pay9, balance9, disputed,invoice_code, invoice_amt, guest_name, guest_name2, cashier, reason, act_flag, trans_flag, trans_accnt, trans_subaccnt, 
		ta_descript, ta_descript_en, ta_no, ta_remark, rmno, close_flag, close_id, act_tag, audit_tag, audit_user, audit_datetime, audit_cashier, mode1, pkg_number, 
		pkg_code, create_user, create_datetime, modify_user, modify_datetime)
		SELECT arg_hotel_group_id,arg_hotel_id, b.id, c.id,1, 0, '02', var_biz_date, var_biz_date, var_ta_code,var_arg_code, 1, 0, 0, 0 ,b.charge,0,
		0,0,0,0,0,0,'',0,a.name,a.name,'1','','','',0,0,
		var_ta_code_des,var_ta_code_des_en,'','','','',0,'A',1,NULL,NULL,NULL,NULL,NULL,
		NULL,'migrate',NOW(),'migrate',NOW()
		FROM ar_master b,ar_account_sub c,ar_master_guest a WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id
		AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND c.type ='SUBACCNT' AND b.id = c.accnt
		AND b.id = a.id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id =arg_hotel_id AND b.charge>0; 
	INSERT INTO ar_account (hotel_group_id,hotel_id,accnt,subaccnt,number,inumber,modu_code,biz_date,gen_date,ta_code,arrage_code,quantity,charge,pay,balance,charge0,pay0, 
		charge1, pay1,charge9, pay9, balance9, disputed,invoice_code, invoice_amt, guest_name, guest_name2, cashier, reason, act_flag, trans_flag, trans_accnt, trans_subaccnt, 
		ta_descript, ta_descript_en, ta_no, ta_remark, rmno, close_flag, close_id, act_tag, audit_tag, audit_user, audit_datetime, audit_cashier, mode1, pkg_number, 
		pkg_code, create_user, create_datetime, modify_user, modify_datetime)
		SELECT arg_hotel_group_id,arg_hotel_id, b.id, c.id,1, 0, '02', var_biz_date, var_biz_date, var_ta_code1,var_arg_code1, 1, 0, 0, 0 ,0,-1*b.charge,
		0,0,0,0,0,0,'',0,a.name,a.name,'1','','','',0,0,
		var_ta_code_des1,var_ta_code_des_en1,'','','','',0,'A',1,NULL,NULL,NULL,NULL,NULL,
		NULL,'migrate',NOW(),'migrate',NOW()
		FROM ar_master b,ar_account_sub c,ar_master_guest a WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id
		AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND c.type ='SUBACCNT' AND b.id = c.accnt
		AND b.id = a.id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id =arg_hotel_id AND b.charge<0; 

	-- ar_detail明细表
	INSERT INTO ar_detail (hotel_group_id,hotel_id,accnt,subaccnt,number,inumber,modu_code,biz_date,gen_date,ta_code,arrange_code,article_code,quantity,charge,charge_base, 
		charge_dsc,charge_srv,charge_tax,charge_oth,package_use,package_limit,package_rate,pay,balance,cashier,act_flag,accept_bank,market,src,rm_class,reason,trans_flag, 
		trans_accnt,trans_subaccnt,ta_descript,ta_descript_en,ta_no,ta_remark,rmno,grp_accnt,rmpost_mode,close_flag,close_id,split_flag,split_user,split_datetime, 
		split_cashier,mode1,pkg_number,create_user,create_datetime,modify_user,modify_datetime,ar_accnt,ar_subaccnt,ar_number,ar_inumber,ar_tag,ar_subtotal,ar_pnumber,charge9,credit9)
	SELECT arg_hotel_group_id,arg_hotel_id,b.id, c.id,1,1, '02',var_biz_date,var_biz_date,var_ta_code,var_arg_code, '', 1, b.charge,b.charge,
		0,0,0,0,0,0,0,0,b.charge,'1','','','',NULL,NULL,'','',
		0,0,var_ta_code_des,var_ta_code_des_en,'','','',NULL,'','',0,'',NULL,NULL,
		NULL,'',NULL,'migrate', NOW(),'migrate',NOW(),b.id,c.id,1,1,'A','F',0,0,0
	FROM  ar_master b,ar_account_sub c WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
	AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND c.type = 'SUBACCNT' AND b.id = c.accnt AND b.charge>0;
	INSERT INTO ar_detail (hotel_group_id,hotel_id,accnt,subaccnt,number,inumber,modu_code,biz_date,gen_date,ta_code,arrange_code,article_code,quantity,charge,charge_base, 
		charge_dsc,charge_srv,charge_tax,charge_oth,package_use,package_limit,package_rate,pay,balance,cashier,act_flag,accept_bank,market,src,rm_class,reason,trans_flag, 
		trans_accnt,trans_subaccnt,ta_descript,ta_descript_en,ta_no,ta_remark,rmno,grp_accnt,rmpost_mode,close_flag,close_id,split_flag,split_user,split_datetime, 
		split_cashier,mode1,pkg_number,create_user,create_datetime,modify_user,modify_datetime,ar_accnt,ar_subaccnt,ar_number,ar_inumber,ar_tag,ar_subtotal,ar_pnumber,charge9,credit9)
	SELECT arg_hotel_group_id,arg_hotel_id,b.id, c.id,1,1, '02',var_biz_date,var_biz_date,var_ta_code1,var_arg_code1, '', 1, 0,0,
		0,0,0,0,0,0,0,-1*b.charge,-1*b.charge,'1','','','',NULL,NULL,'','',
		0,0,var_ta_code_des1,var_ta_code_des_en1,'','','',NULL,'','',0,'',NULL,NULL,
		NULL,'',NULL,'migrate', NOW(),'migrate',NOW(),b.id,c.id,1,1,'A','F',0,0,0
	FROM  ar_master b,ar_account_sub c WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
	AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND c.type = 'SUBACCNT' AND b.id = c.accnt AND b.charge<0;
		 
	-- 更新帐次
	UPDATE ar_master a,(SELECT accnt,MAX(ar_number) ar_number FROM ar_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id GROUP BY accnt) b
	SET a.last_num_link = b.ar_number + 1  WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.accnt;
	UPDATE ar_master a,(SELECT accnt,MAX(ar_inumber) ar_inumber FROM ar_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id GROUP BY accnt) b
	SET a.last_num = b.ar_inumber + 1 WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.accnt;
	*/

	
END$$

DELIMITER ;