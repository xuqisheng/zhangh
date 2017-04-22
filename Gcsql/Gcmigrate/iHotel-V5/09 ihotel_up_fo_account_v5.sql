DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_fo_account_v5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_fo_account_v5`(
	IN arg_hotel_group_id BIGINT(16),
	IN arg_hotel_id 	BIGINT(16)
)
label_0:
BEGIN
	-- -------------------------------------------------------
	-- 明细账务迁移(前台) 
	-- -------------------------------------------------------
	DECLARE var_bdate    	DATETIME;
	DECLARE done_cursor 	INT DEFAULT 0 ;
	DECLARE var_accnt 		VARCHAR(30);
	DECLARE var_number 		INT(11);
	DECLARE var_inumber 	INT(11);
	DECLARE var_checkout 	VARCHAR(4);
	DECLARE var_moduno 		VARCHAR(4);
	DECLARE var_gen_date 	DATETIME ;
	DECLARE var_ta_code 	VARCHAR(7);
	DECLARE var_charge 		DECIMAL(12,2);
	DECLARE var_pay 		DECIMAL(12,2);
	DECLARE var_banlance 	DECIMAL(12,2);	
	DECLARE var_cashier 	VARCHAR(4);
	DECLARE var_empno 		VARCHAR(30);
	DECLARE var_act_flag 	VARCHAR(30);
	DECLARE var_to_from 	VARCHAR(30);
	DECLARE var_to_accnt 	VARCHAR(30);
	DECLARE var_descript 	VARCHAR(30);
	DECLARE var_descript_en VARCHAR(30);         
	DECLARE var_remark 		VARCHAR(300);
	DECLARE var_rmno 		VARCHAR(300);  
	DECLARE var_grpaccnt 	VARCHAR(300); 
	DECLARE var_mode 		VARCHAR(300);  
	DECLARE var_close_id 	VARCHAR(300);  
	DECLARE var_close_flag 	VARCHAR(300);  
	DECLARE var_tag  		VARCHAR(5);	
	DECLARE var_log_date 	DATETIME; 
	
	DECLARE c_account CURSOR FOR 
		SELECT accnt,number,inumber,checkout,modu_id,bdate,DATE,CONCAT(pccode,servcode),charge,credit,balance,shift,
			empno,crradjt,tag,tofrom,accntof,ref,ref1,ref2,roomno,groupno,MODE,billno,log_date
		FROM migrate_xc.account WHERE accnt NOT LIKE '%AR%';
		
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1 ;
	
	-- 为了保证对应关系，先更新下account表的字段类型
	ALTER TABLE account MODIFY COLUMN accnt VARCHAR(30);
	ALTER TABLE account MODIFY COLUMN trans_accnt VARCHAR(30);
	-- 初始值 
    SET var_close_flag = NULL;
	-- 开始迁移，光标扫描 
	OPEN c_account ;
	SET done_cursor = 0;
	FETCH c_account INTO var_accnt,var_number,var_inumber,var_checkout,var_moduno,var_bdate,var_gen_date,var_ta_code,var_charge,var_pay,var_banlance,var_cashier,
						var_empno,var_act_flag,var_tag,var_to_from,var_to_accnt,var_descript,var_descript_en,var_remark,var_rmno,
	                    var_grpaccnt,var_mode,var_close_id,var_log_date;
	WHILE done_cursor = 0 DO
		BEGIN
			IF var_close_id = '' THEN 
				SET var_close_flag = '';
				SET var_close_id = NULL; 
			ELSE
				SET var_close_flag = SUBSTR(var_close_id,1,1);
				SET var_close_id = '-1';  
			END IF; 
			
			IF var_mode = '' THEN 
				SET var_mode = '';
			ELSE
				SET var_mode = SUBSTR(var_mode,1,1);
			END IF;
			
			-- 插入账务表
			INSERT INTO account (hotel_group_id,hotel_id, accnt,subaccnt,number,inumber,modu_code,biz_date,gen_date,ta_code,
			       arrange_code,article_code,quantity,charge,charge_base,charge_dsc,charge_srv,charge_tax,charge_oth,package_use,
			       package_limit,package_rate,pay,balance,cashier,act_flag,accept_bank,market,reason,trans_flag,trans_accnt,trans_subaccnt,
			       ta_descript,ta_descript_en,ta_no,ta_remark,rmno,grp_accnt,rmpost_mode,close_flag,close_id,split_flag,split_user,split_datetime,
			       split_cashier,mode1,pkg_number,create_user,create_datetime,modify_user,modify_datetime,card_id,card_no) 
			VALUES(arg_hotel_group_id,arg_hotel_id,var_accnt,0,var_number,var_inumber,'02',var_bdate,var_gen_date,var_ta_code,'00',var_tag,1,var_charge,0,0,0,0,0,0,0,0,var_pay,0,
			       var_cashier,var_act_flag,'','','',var_to_from,var_to_accnt,NULL,var_descript,var_descript_en,'',var_remark,var_rmno,0,var_mode,var_close_flag,var_close_id,
			       '','',NULL,NULL,'',NULL,var_empno,var_log_date,var_empno,var_log_date,NULL,NULL);
			       			
			SET done_cursor = 0 ;
			FETCH c_account INTO var_accnt,var_number,var_inumber,var_checkout,var_moduno,var_bdate,var_gen_date,var_ta_code,var_charge,var_pay ,var_banlance,
	                    var_cashier,var_empno,var_act_flag,var_tag,var_to_from,var_to_accnt,var_descript,var_descript_en,var_remark,var_rmno,
	                    var_grpaccnt,var_mode,var_close_id,var_log_date;
		END ;
	END WHILE ;
	CLOSE c_account ;
		
	-- 处理up_map_accnt账户对照关系
  	UPDATE account a,up_map_accnt b SET a.accnt = b.accnt_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.accnt_type IN ('master_r','master_si','consume','grpmst') AND SUBSTRING(b.accnt_old,1,7)= a.accnt;
	UPDATE account a,up_map_accnt b SET a.trans_accnt = b.accnt_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.accnt_type IN ('master_r','master_si','consume','grpmst') AND SUBSTRING(b.accnt_old,1,7)= a.trans_accnt;
	UPDATE account a SET a.trans_accnt = CONCAT('1',MID(a.trans_accnt,3)) WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.trans_accnt<>'' AND a.trans_accnt LIKE 'AR%';
		
	-- 将account表的字段类型恢复
	ALTER TABLE account MODIFY COLUMN accnt BIGINT(16);
 	ALTER TABLE account MODIFY COLUMN trans_accnt BIGINT(16);
	
	DELETE a FROM account a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id
		AND NOT EXISTS (SELECT 1 FROM master_base b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.accnt=b.id);
 	
	UPDATE account a,up_map_code b SET a.ta_code  = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id  AND b.hotel_id=arg_hotel_id AND b.cat ='paymth' AND b.code_old = a.ta_code; 
 	UPDATE account a,up_map_code b SET a.ta_code  = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id  AND b.hotel_id=arg_hotel_id AND b.cat ='pccode' AND b.code_old = a.ta_code;
	
	-- 更新arrange_code
	UPDATE account a,code_transaction b SET a.arrange_code=b.arrange_code WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.ta_code=b.code;	

	-- up act_flag账务其他标记的更新操作
	UPDATE account SET act_flag = '' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND act_flag NOT IN('C','CO','AD','LT');
	UPDATE account SET rmpost_mode = '' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmpost_mode NOT IN('J','K','S','N','P');
	UPDATE account SET close_flag = 'B' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND close_flag IN('P','O');

END$$

DELIMITER ;