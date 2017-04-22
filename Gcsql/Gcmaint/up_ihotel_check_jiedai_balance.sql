DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_check_jiedai_balance`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_check_jiedai_balance`(
	IN arg_hotel_group_id		INT,
	IN arg_hotel_id			INT,
	IN arg_biz_date			DATETIME,
	OUT arg_msg			VARCHAR(255)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	
	-- 检查底表配置是否平衡，用于处理底表不平
	
	
	DECLARE var_credit_ar			VARCHAR(5);
	
	DECLARE var_tmp 		VARCHAR(800); 	
	DECLARE var_tmp_1 		VARCHAR(800); 	
	
	DECLARE var_tmp_4 		VARCHAR(800); 	
	
	DECLARE var_modeno 		VARCHAR(800); 	
	DECLARE var_classno		VARCHAR(60); 	
	DECLARE var_descript		VARCHAR(60); 	
	DECLARE var_toop		VARCHAR(60); 	
	DECLARE var_toclass		VARCHAR(60);	
	
	DECLARE var_qx_code  VARCHAR(60);  
	DECLARE var_code_descript  VARCHAR(60);  
	DECLARE var_mktcode  VARCHAR(200);   
	
	DECLARE var_code_tr   VARCHAR(60);
	DECLARE var_code_buff VARCHAR(600);
	
	DECLARE done_cursor     INT DEFAULT 0;
	
	DECLARE cur_yb  CURSOR FOR SELECT modeno,classno,descript,toop,toclass FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id ;
			
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	DROP TEMPORARY TABLE IF EXISTS tmp_check_jiedai;
	CREATE TEMPORARY TABLE tmp_check_jiedai(
		CODE		VARCHAR(10),
		biz_date	VARCHAR(100),
		descript1	VARCHAR(255) NOT NULL DEFAULT '',
		day99		DECIMAL(12,2) NOT NULL DEFAULT 0,
		descript2	VARCHAR(255) NOT NULL DEFAULT '',
		sumcre		DECIMAL(12,2) NOT NULL DEFAULT 0,	
		remark		VARCHAR(255) NOT NULL DEFAULT '',
		diff		DECIMAL(12,2) NOT NULL DEFAULT 0,
		KEY(CODE)
	);
	DROP TEMPORARY TABLE IF EXISTS tmp_jie_all;
	CREATE TEMPORARY TABLE tmp_jie_all(
		accnt_type	VARCHAR(10),
		modu_code	VARCHAR(10),
		ta_code		VARCHAR(25),
		ta_descript	VARCHAR(25),	
		charge		DECIMAL(12,2) NOT NULL DEFAULT 0,		
		pay		DECIMAL(12,2) NOT NULL DEFAULT 0,
		KEY index1(accnt_type,modu_code),
		KEY index2(accnt_type,modu_code,ta_code)
	);
	DROP TEMPORARY TABLE IF EXISTS tmp_tacode_ar;
	CREATE TEMPORARY TABLE tmp_tacode_ar(
		ta_code		VARCHAR(25),
		ta_descript	VARCHAR(25),	
		KEY index1(ta_code)
		);
	DROP TEMPORARY TABLE IF EXISTS tmp_role_table;
	CREATE TEMPORARY TABLE tmp_role_table
	(
		CODE 	VARCHAR(60) 
	);	
		
		
			
	SELECT set_value INTO var_credit_ar FROM sys_option WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND catalog='ar' AND item='creditcard_as_ar';


	INSERT INTO tmp_tacode_ar(ta_code,ta_descript)
		SELECT a.code,a.descript FROM code_transaction a,code_bankcard_link b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.code=b.ta_code AND b.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id;
		
 	
	INSERT INTO tmp_check_jiedai(CODE,biz_date) VALUE (1,'1:开始数据检查-------');
	INSERT INTO tmp_check_jiedai(CODE,biz_date,descript1,day99,descript2,sumcre,remark,diff)
	SELECT 2,DATE(a.biz_date),'借方合计',a.day99,'贷方合计',b.sumcre,'借贷差额',a.day99-b.sumcre FROM rep_jie a,rep_dai b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.classno='999'
		AND b.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.classno='09000';
	
	
	INSERT INTO tmp_jie_all(accnt_type,modu_code,ta_code,ta_descript,charge,pay)
	SELECT 'FO','02',ta_code,ta_descript,SUM(charge),SUM(pay) FROM account_audit WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND accnt_type='FO' AND modu_code='02' GROUP BY ta_code;
	INSERT INTO tmp_jie_all(accnt_type,modu_code,ta_code,ta_descript,charge,pay)
	SELECT 'FO','04',ta_code,ta_descript,SUM(charge),SUM(pay) FROM account_audit WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND accnt_type='FO' AND modu_code='04' GROUP BY ta_code;
	
	INSERT INTO tmp_jie_all(accnt_type,modu_code,ta_code,ta_descript,charge,pay)
	SELECT 'POS','02',CODE,descript,SUM(amount_day),0 FROM pos_deptjie WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date GROUP BY CODE;
	INSERT INTO tmp_jie_all(accnt_type,modu_code,ta_code,ta_descript,charge,pay)
	SELECT 'POS','02',CODE,descript,0,SUM(amount_day) FROM pos_deptdai WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date GROUP BY CODE;
	
	INSERT INTO tmp_jie_all(accnt_type,modu_code,ta_code,ta_descript,charge,pay)
	SELECT 'AR','A',ta_code,ta_descript,SUM(charge),SUM(pay) FROM account_audit WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND accnt_type='AR' AND modu_code='02' AND act_flag='A' GROUP BY ta_code;
	INSERT INTO tmp_jie_all(accnt_type,modu_code,ta_code,ta_descript,charge,pay)
	SELECT 'AR','02',ta_code,ta_descript,SUM(charge),SUM(pay) FROM account_audit WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND accnt_type='AR' AND modu_code='02' AND act_flag<>'A' GROUP BY ta_code;
	INSERT INTO tmp_jie_all(accnt_type,modu_code,ta_code,ta_descript,charge,pay)
	SELECT 'AR','04',ta_code,ta_descript,SUM(charge),SUM(pay) FROM account_audit WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND accnt_type='AR' AND modu_code='04' GROUP BY ta_code;
	
	INSERT INTO tmp_jie_all(accnt_type,modu_code,ta_code,ta_descript,charge,pay)
	SELECT 'VIP',source,ta_code,ta_descript,SUM(charge),SUM(pay) FROM card_account WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date  GROUP BY source,ta_code;
	
	INSERT INTO tmp_check_jiedai(CODE,biz_date,day99)
	SELECT 3,'3:收入合计',SUM(charge) FROM tmp_jie_all WHERE ((accnt_type='FO' AND modu_code='02') OR (accnt_type='POS' AND modu_code='02') OR (accnt_type='AR' AND modu_code='A') OR (accnt_type='VIP' AND modu_code='OWN'));
	
	INSERT INTO tmp_check_jiedai(CODE,biz_date,descript1,day99,descript2,sumcre,remark,diff)
		SELECT 4,'4:餐饮合计','餐饮借方',SUM(charge),'餐饮借方',SUM(pay),'餐饮差额',SUM(charge-pay) FROM tmp_jie_all WHERE accnt_type='POS' AND modu_code='02';
	
	INSERT INTO tmp_check_jiedai(CODE,biz_date,descript1,day99)
		SELECT 5,'5:餐饮转前台','前台部分',SUM(charge) FROM tmp_jie_all WHERE accnt_type='FO' AND modu_code='04';
 	UPDATE 	tmp_check_jiedai a,(SELECT SUM(a.pay) AS pay FROM tmp_jie_all a,code_transaction b WHERE a.accnt_type='POS' AND a.modu_code='02' AND a.ta_code=b.code AND b.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.cat_posting='TF' ) b 
  		SET a.descript2='餐饮部分',a.sumcre=b.pay WHERE a.code=5;
	UPDATE tmp_check_jiedai SET remark='差额',diff=day99-sumcre WHERE CODE=5;
	
	INSERT INTO tmp_check_jiedai(CODE,biz_date,descript1,day99)
		SELECT 6,'6:餐饮转AR','AR部分',SUM(charge) FROM tmp_jie_all WHERE accnt_type='AR' AND modu_code='04';
 	UPDATE 	tmp_check_jiedai a,(SELECT SUM(a.pay) AS pay FROM tmp_jie_all a,code_transaction b WHERE a.accnt_type='POS' AND a.modu_code='02' AND a.ta_code=b.code AND b.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.cat_posting='TA' ) b 
  		SET a.descript2='餐饮部分',a.sumcre=b.pay WHERE a.code=6;
	UPDATE tmp_check_jiedai SET remark='差额',diff=day99-sumcre WHERE CODE=6;
	
	INSERT INTO tmp_check_jiedai(CODE,biz_date,descript1,day99)
		SELECT 7,'7:餐饮储值卡结账','储值卡部分',SUM(charge) FROM tmp_jie_all WHERE accnt_type='VIP' AND modu_code='FB';
 	UPDATE 	tmp_check_jiedai a,(SELECT SUM(a.pay) AS pay FROM tmp_jie_all a,code_transaction b WHERE a.accnt_type='POS' AND a.modu_code='02' AND a.ta_code=b.code AND b.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.cat_posting='RCV' ) b 
  		SET a.descript2='餐饮部分',a.sumcre=b.pay WHERE a.code=7;
	UPDATE tmp_check_jiedai SET remark='差额',diff=day99-sumcre WHERE CODE=7;
	
	IF var_credit_ar = 'F' THEN
		INSERT INTO tmp_check_jiedai(CODE,biz_date,descript1,day99)
			SELECT 8,'8:前台转AR','AR部分',SUM(charge) FROM tmp_jie_all WHERE accnt_type='AR' AND modu_code='02';
		UPDATE 	tmp_check_jiedai a,(SELECT SUM(a.pay) AS pay FROM tmp_jie_all a,code_transaction b WHERE a.accnt_type='FO' AND a.modu_code='02' AND a.ta_code=b.code AND b.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.cat_posting='TA' ) b 
			SET a.descript2='前台部分',a.sumcre=b.pay WHERE a.code=8;
		UPDATE tmp_check_jiedai SET remark='差额',diff=day99-sumcre WHERE CODE=8;
	ELSE
		INSERT INTO tmp_check_jiedai(CODE,biz_date,descript1,day99)
			SELECT 8,'8:AR发生部分(含AR管理信用卡)','AR部分',SUM(charge) FROM tmp_jie_all WHERE accnt_type='AR' AND modu_code='02';
		UPDATE 	tmp_check_jiedai a,(SELECT SUM(a.pay) AS pay FROM tmp_jie_all a,code_transaction b WHERE a.accnt_type='FO' AND a.modu_code='02' AND a.ta_code=b.code AND b.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.cat_posting='TA' ) b 
			SET a.descript2='前台部分',a.sumcre=b.pay WHERE a.code=8;
		UPDATE tmp_check_jiedai a,(SELECT SUM(a.pay) AS pay FROM tmp_jie_all a,tmp_tacode_ar b WHERE ((a.accnt_type='FO' AND a.modu_code='02') OR (a.accnt_type='POS' AND a.modu_code='02') OR (a.accnt_type='AR' AND a.modu_code='02')) AND a.ta_code=b.ta_code) b
			SET a.descript2='前台挂AR和餐饮信用卡',a.sumcre=a.sumcre+b.pay WHERE a.code=8;
		UPDATE tmp_check_jiedai SET remark='差额',diff=day99-sumcre WHERE CODE=8;
	END IF;
	
	INSERT INTO tmp_check_jiedai(CODE,biz_date,descript1,day99)
		SELECT 9,'9:前台储值卡结账','储值卡部分',SUM(charge) FROM tmp_jie_all WHERE accnt_type='VIP' AND modu_code='FRONT';
 	UPDATE 	tmp_check_jiedai a,(SELECT SUM(a.pay) AS pay FROM tmp_jie_all a,code_transaction b WHERE a.accnt_type='FO' AND a.modu_code='02' AND a.ta_code=b.code AND b.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.cat_posting='RCV' ) b 
  		SET a.descript2='前台部分',a.sumcre=b.pay WHERE a.code=9;
	UPDATE tmp_check_jiedai SET remark='差额',diff=day99-sumcre WHERE CODE=9;
	
	
	 
	 
	
	INSERT INTO tmp_check_jiedai(CODE,biz_date,descript1,day99,descript2,sumcre,remark,diff)
	 SELECT '001','001:付款码大类检查','付款码大类检查',0.00,'sys_option检查',0.00,CONCAT('付款码:',a.code,' ','对应的','---',a.category_code,' 未在sys_option中定义'),0.00  
		FROM code_transaction a,(SELECT hotel_group_id ,hotel_id ,GROUP_CONCAT(set_value) set_value FROM sys_option WHERE hotel_group_id =arg_hotel_group_id AND hotel_id =arg_hotel_id AND catalog = 'audit' AND item IN ('deail_dai_c1','deail_dai_c2','deail_dai_c3','deail_dai_c4','deail_dai_c5','deail_dai_c6')) AS b 
	     WHERE a.hotel_group_id =  b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id =arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code IN ('98','99') AND INSTR(b.set_value,a.category_code) = 0 AND a.cat_posting NOT IN ('TA','TF') ;
 
	
		
	
	OPEN cur_yb;
	FETCH  cur_yb   INTO  var_modeno,var_classno,var_descript,var_toop,var_toclass;
	
	SET done_cursor = 0 ;
	SET var_tmp_4 = '';
	WHILE done_cursor = 0 DO
	     BEGIN
		  
		  SET var_modeno = REPLACE(var_modeno,':',';');
		  
		  SET var_modeno = REPLACE(var_modeno,',',';');
		  
		  SET var_modeno = CONCAT(var_modeno,';');
		  
		  
		  SET var_modeno = REPLACE(var_modeno,'GCNULL;','');
		  
		  
		  SET var_tmp = var_modeno ;
		  SET var_tmp_1 = '';
		  SET var_mktcode = '';
		  
		 
		  IF var_tmp <>'' OR LENGTH(var_tmp)>0 OR var_tmp =';'  THEN  		  
			SET var_qx_code = 'To_be_Number_One';
			WHILE var_tmp <> var_qx_code DO
				BEGIN
					 
					 IF   var_qx_code = 'To_be_Number_One' THEN 
						SET var_qx_code = SUBSTRING_INDEX(var_tmp,';',1);
					 ELSE
						SET var_tmp = REPLACE(var_tmp,CONCAT (var_qx_code,';'),'');
						SET var_qx_code = SUBSTRING_INDEX(var_tmp,';',1);
					END IF;
					
					
					INSERT tmp_role_table(CODE) SELECT TRIM(var_qx_code);
					
					
					
					
					   SELECT descript INTO var_code_descript 
							FROM code_transaction
							WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = var_qx_code;
					
					
					IF EXISTS(SELECT 1 FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND  parent_code = 'market_code' AND CODE = var_qx_code) THEN
					  SELECT CONCAT(var_mktcode,'[',var_qx_code,']',descript,';') INTO var_mktcode 
							FROM code_base
							WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code = 'market_code' AND CODE = var_qx_code;
					
					
					 END IF;	
					IF LENGTH(var_qx_code) > 0 AND var_qx_code <> ';'THEN
						SET var_tmp_1 = CONCAT(var_tmp_1,'[',var_qx_code,']',var_code_descript,';');
					END IF ;
					SET var_code_descript = '';
					
				END;
			END WHILE;
		
		  END IF;
			
		  
		  SET done_cursor = 0 ;
		  FETCH  cur_yb   INTO  var_modeno,var_classno,var_descript,var_toop,var_toclass;
	     END;	
	END WHILE ;
	CLOSE cur_yb;
	
	
        INSERT INTO tmp_check_jiedai(CODE,biz_date,descript1,day99,descript2,sumcre,remark,diff) 
	SELECT '002','002:底表费用码配置检查','底表费用码配置检查',0.00,'底表费用码配置检查', 0.00,CONCAT('费用码:',CODE,' ','对应的','---',descript,' 存在未配置'),0.00 FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND arrange_code <> '98' AND is_halt='F' AND CODE NOT IN (SELECT CODE FROM tmp_role_table GROUP BY CODE);
        
        
        IF  EXISTS (SELECT 1 FROM tmp_role_table   WHERE CODE NOT IN (SELECT CODE  FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id 
							AND  parent_code = 'market_code' )) THEN 
	INSERT INTO tmp_check_jiedai(CODE,biz_date,descript1,day99,descript2,sumcre,remark,diff) 
	SELECT '003','003:稽核底表按费用码配置-无需检查市场码','稽核底表按费用码配置-无需检查市场码',0.00,'底表市场码不检查', 0.00,CONCAT('稽核底表按费用码配置-无需检查市场码'),0.00 ;
           
	ELSE
		INSERT INTO tmp_check_jiedai(CODE,biz_date,descript1,day99,descript2,sumcre,remark,diff) 
		SELECT '003','003:底表市场码检查','底表市场码检查',0.00,'底表市场码检查', 0.00,CONCAT('市场码:',CODE,' ','对应的','---',descript,' 存在未配置'),0.00 FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND  parent_code = 'market_code' AND is_halt='F' AND CODE NOT IN (SELECT CODE FROM tmp_role_table GROUP BY CODE);
	END IF ;
	
	SELECT CODE,biz_date,remark FROM tmp_check_jiedai WHERE CODE<'1';	
	SELECT * FROM tmp_check_jiedai WHERE CODE>='1';
	

  
 	DROP TEMPORARY TABLE IF EXISTS tmp_check_jiedai;
    		
        BEGIN 
		SET @procresult = 0 ;
		LEAVE label_0 ;
	END ;
	
  END$$

DELIMITER ;