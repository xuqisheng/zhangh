DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_up_armst`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_armst`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN		
		DELETE FROM ar_master 		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
		DELETE FROM ar_master_guest WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
		
		INSERT INTO ar_master (hotel_group_id,hotel_id,arno,profile_type,profile_id,biz_date,sta,arr,dep,exp_sta,tm_sta,tag0,building,
			ar_cycle,ar_category,is_permanent,posting_flag,extra_flag,pay_code,limit_type,limit_amt,credit_no,credit_man,credit_company,
			salesman,phone,fax,email,charge,pay,credit,last_num,last_num_link,link_id,remark,co_msg,reminder_msg,
			last_charge_user,last_charge_datetime,last_pay_user,last_pay_datetime,last_invoice_user,last_invoice_datetime,
			last_statement_user,last_statement_datetime,
			last_reminder_to,last_reminder_user,last_reminder_datetime,create_user,create_datetime,modify_user,modify_datetime,mobil)
		SELECT arg_hotel_group_id,arg_hotel_id,code,'',0,'2016-10-26','I',NOW(),'2020-12-31','','I','','###',
			'1','A','T','1','001000000000000000000000000000','9001',1,0,'','','','',
			'','','',0,0,0,0,0,NULL,0,'','',
			'',NULL,'',NULL,'',NULL,'',NULL,
			'','',NULL,'ADMIN',NOW(),'ADMIN',NOW(),''		
			FROM jg_ar ORDER BY code;		 
		
		INSERT INTO ar_master_guest (hotel_group_id,hotel_id,id,NAME,name2,name_combine,coding,LANGUAGE,nation,linkman,address,zipcode,create_user,create_datetime,modify_user,modify_datetime)
			SELECT arg_hotel_group_id,arg_hotel_id,a.id,b.name,'',b.name,b.code,'C','CN','','','','ADMIN',NOW(),'ADMIN',NOW()
				FROM ar_master a,jg_ar b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
					AND a.arno = b.code;
					
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
		
END$$

DELIMITER ;