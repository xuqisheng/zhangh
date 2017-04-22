DELIMITER $$

USE `portal_ipms`$$

DROP PROCEDURE IF EXISTS `up_ihotel_audit_rep_jiedai`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_audit_rep_jiedai`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	OUT arg_ret				INT,
	OUT arg_msg				VARCHAR(255)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ---------------------------------------------------------------
	-- 夜审过程- 定制底表
	-- 作者：张晓斌 2016.9.3
	-- 2016.09.03日 
	-- --------------------------------------------------------------- 
 	DECLARE var_duringaudit		CHAR(2);
 	DECLARE var_gst_calmode 	VARCHAR(512) ;
 	DECLARE var_bdate			DATETIME;
	DECLARE var_bfdate 			DATETIME ;
	DECLARE var_rmtype			VARCHAR(10);
	DECLARE var_rmno			VARCHAR(10);
	DECLARE var_tacode			VARCHAR(10);
 	DECLARE var_arrange_code	VARCHAR(10);
	DECLARE var_charge			DECIMAL(12,2) DEFAULT 0.00;	
	DECLARE var_pay				DECIMAL(12,2) DEFAULT 0.00;	
	DECLARE var_credit			DECIMAL(12,2) DEFAULT 0.00;	
 	DECLARE var_accnt_type		VARCHAR(10);
 	DECLARE var_modu_code		CHAR(2);
 	DECLARE var_act_flag		VARCHAR(10);
	DECLARE var_adult			MEDIUMINT(4);
 	DECLARE var_accnt			BIGINT;
	DECLARE var_trans_accnt		BIGINT;
	DECLARE var_quantity		DECIMAL(12,2) DEFAULT 0.00;
	DECLARE var_charge_srv		DECIMAL(12,2) DEFAULT 0.00;
	DECLARE var_package_rate 	DECIMAL(12,2) DEFAULT 0.00;
	DECLARE var_charge_tax		DECIMAL(12,2) DEFAULT 0.00;
	DECLARE var_charge_oth		DECIMAL(12,2) DEFAULT 0.00;
 	DECLARE var_market			VARCHAR(20);
 	DECLARE var_src				VARCHAR(20);
 	DECLARE var_channel			VARCHAR(20);
	DECLARE var_ratecode		VARCHAR(20);
	DECLARE var_descript		VARCHAR(20);
	DECLARE var_amount			DECIMAL(12,2) DEFAULT 0.00;
	DECLARE var_amount_sumcre	DECIMAL(12,2) DEFAULT 0.00;
	DECLARE var_amount_sumcre_pos	DECIMAL(12,2) DEFAULT 0.00;
 	DECLARE var_tacode_ent		VARCHAR(200);	
 	DECLARE var_tacode_tf		VARCHAR(200);	
 	DECLARE var_cat_posting		VARCHAR(10);
 	DECLARE var_item_type		VARCHAR(10);
	DECLARE var_pos_id	 		BIGINT;
	DECLARE var_vip_id	 		BIGINT;
	DECLARE var_source			VARCHAR(10);
	DECLARE var_toop			CHAR(1);
	DECLARE var_toclass			VARCHAR(10);
	DECLARE var_day01			DECIMAL(12,2);
	DECLARE var_day02			DECIMAL(12,2);
	DECLARE var_day03			DECIMAL(12,2);
	DECLARE var_day04			DECIMAL(12,2);
	DECLARE var_day05			DECIMAL(12,2);
	DECLARE var_day06			DECIMAL(12,2);
	DECLARE var_day07			DECIMAL(12,2);
	DECLARE var_day08			DECIMAL(12,2);
	DECLARE var_day09			DECIMAL(12,2);
	DECLARE var_day10			DECIMAL(12,2);
	DECLARE var_day11			DECIMAL(12,2);
	DECLARE var_day12			DECIMAL(12,2);
	DECLARE var_day13			DECIMAL(12,2);
	DECLARE var_day14			DECIMAL(12,2);
	DECLARE var_day15			DECIMAL(12,2);
	DECLARE var_day99			DECIMAL(12,2);
 	DECLARE var_market_default	VARCHAR(20);
 	DECLARE var_src_default		VARCHAR(20);
	DECLARE done_cursor			INT DEFAULT 0;
	DECLARE var_jiecode			VARCHAR(20);
	DECLARE var_amount_xx		DECIMAL(12,2);
	DECLARE var_amount_xs		DECIMAL(12,2);	
	
	-- ----前台+AR数据-------
	DECLARE c_gltemp_1 CURSOR FOR 
		SELECT a.accnt_type,a.modu_code,a.rmno,a.ta_code,b.arrange_code,a.charge,a.charge_tax,a.charge_oth,a.accnt,a.trans_accnt,a.quantity,a.market,a.charge_srv,a.package_rate,a.pay,a.act_flag,b.cat_posting FROM temp_account_2 a LEFT JOIN code_transaction b ON a.ta_code = b.code AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id;
	DECLARE p_deptjie CURSOR FOR 
		SELECT a.accnt_type,a.modu_code,a.id,a.ta_code,a.market,a.source,a.charge,a.charge_tax FROM tmp_deptjie a;
	DECLARE p_deptdai CURSOR FOR 
		SELECT a.accnt_type,a.ta_code,a.descript,a.credit FROM tmp_deptdai a ;
	DECLARE c_vipjie CURSOR FOR 
		SELECT a.accnt_type,a.modu_code,a.id,a.ta_code,a.market,a.source,a.charge,a.charge_tax FROM tmp_vipjie a;
	DECLARE c_vipdai CURSOR FOR 
		SELECT a.accnt_type,a.ta_code,a.descript,a.credit FROM tmp_vipdai a ;
	DECLARE c_charge_ent CURSOR FOR 
		SELECT a.accnt_type,'08',a.accnt,a.ta_code1,a.market,a.source,a.amount FROM tmp_apportion a ;
	DECLARE c_pay_ent CURSOR FOR 
		SELECT a.accnt_type,a.ta_code2,a.descript2,a.amount FROM tmp_apportion a ;
	DECLARE c_jie_custor CURSOR FOR 
		SELECT a.toop,a.toclass,a.day01,a.day02,a.day03,a.day04,a.day05,a.day06,a.day07,a.day08,a.day09,a.day10,a.day11,a.day12,a.day13,a.day14,a.day15,a.day99 FROM rep_jie_hd a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.rectype = 'B';
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;	
	SET @procresult = 1;	
	SET arg_ret = 1, arg_msg = 'OK';
	-- 日期取数
 
 	SET SESSION group_concat_max_len=15000;
 	
	SELECT DATE_ADD(set_value,INTERVAL -1 DAY) INTO var_bdate FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog = 'system' AND item = 'biz_date';
 	SET var_bfdate = DATE_ADD(var_bdate,INTERVAL -1 DAY);
	
	-- 款待付款码合集
	SELECT GROUP_CONCAT(DISTINCT CODE) INTO var_tacode_ent FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting = 'ENT';
	-- 转前台
	SELECT GROUP_CONCAT(DISTINCT CODE) INTO var_tacode_tf FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting = 'TF';
	-- 市场码
	SELECT MIN(CODE) INTO var_market_default FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code='market_code';
	-- 来源码
	SELECT MIN(CODE) INTO var_src_default FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code='src_code';
	-- 前台
 	DROP TEMPORARY TABLE IF EXISTS temp_account_2;
	CREATE TEMPORARY TABLE temp_account_2(
		accnt_type 	VARCHAR(10),
		modu_code	VARCHAR(10),
		rmno 		VARCHAR(10)  NOT NULL DEFAULT '',
		ta_code 	VARCHAR(10),
		arrange_code	VARCHAR(10),
		charge 		DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		charge_tax 	DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		charge_oth	DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		accnt 		BIGINT(16),
		quantity 	DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		market 		VARCHAR(10),
		charge_srv 	DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		package_rate 	DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		pay 		DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		act_flag	VARCHAR(10),
		trans_flag	VARCHAR(2),
		trans_accnt	BIGINT
		
 	);
 
	INSERT INTO temp_account_2(accnt_type,modu_code,rmno,ta_code,arrange_code,charge,charge_tax,charge_oth,accnt,quantity,market,charge_srv,package_rate,pay,act_flag,trans_flag,trans_accnt)
		SELECT a.accnt_type,a.modu_code,a.rmno,a.ta_code,a.arrange_code,a.charge,a.charge_tax,a.charge_oth,a.accnt,a.quantity,a.market,a.charge_srv,a.package_rate,a.pay,a.act_flag,a.trans_flag,a.trans_accnt
			FROM account_audit a 
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.accnt_type = 'AR' 
		UNION ALL
		SELECT a.accnt_type,a.modu_code,a.rmno,a.ta_code,a.arrange_code,a.charge,a.charge_tax,a.charge_oth,a.accnt,a.quantity,a.market,a.charge_srv,a.package_rate,a.pay,a.act_flag,a.trans_flag,a.trans_accnt
			FROM account_audit a 
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.accnt_type = 'FO';  
	
	-- 餐饮借贷
 	DROP TEMPORARY TABLE IF EXISTS tmp_deptjie;
	CREATE TEMPORARY TABLE tmp_deptjie(
		accnt_type	VARCHAR(5),
		modu_code	CHAR(2),
		id			BIGINT,
		ta_code	 	VARCHAR(10),
		market	 	VARCHAR(10)  NOT NULL DEFAULT '',
		source	 	VARCHAR(10)  NOT NULL DEFAULT '',
 		charge 		DECIMAL(12,2) NOT NULL DEFAULT 0.00, 	
 		charge_tax	DECIMAL(12,2) NOT NULL DEFAULT 0.00 	
 		);
	DROP TEMPORARY TABLE IF EXISTS tmp_deptdai;
	CREATE TEMPORARY TABLE tmp_deptdai(
		accnt_type	VARCHAR(5),
		ta_code	 	VARCHAR(10),
		descript 	VARCHAR(20)  NOT NULL DEFAULT '',
 		credit 		DECIMAL(12,2) NOT NULL DEFAULT 0.00,
 		KEY index1(accnt_type,ta_code) 	
 		);
	-- 款待
 	DROP TEMPORARY TABLE IF EXISTS tmp_apportion;
	CREATE TEMPORARY TABLE tmp_apportion(
		accnt_type	VARCHAR(10),
		accnt		BIGINT,
		ta_code1 	VARCHAR(10),
		ta_code2	VARCHAR(10),
		descript1 	VARCHAR(20)  NOT NULL DEFAULT '',
		descript2 	VARCHAR(20)  NOT NULL DEFAULT '',
 		amount 		DECIMAL(12,2) NOT NULL DEFAULT 0.00,
 		market		VARCHAR(10),
 		source		VARCHAR(10),
 		KEY index1(accnt_type,accnt) 	
 		);
	-- 会员借方
 	DROP TEMPORARY TABLE IF EXISTS tmp_vipjie;
	CREATE TEMPORARY TABLE tmp_vipjie(
		accnt_type	VARCHAR(5),
		modu_code	CHAR(2),
		id			BIGINT,
		ta_code	 	VARCHAR(10),
		market	 	VARCHAR(10)  NOT NULL DEFAULT '',
		source	 	VARCHAR(10)  NOT NULL DEFAULT '',
 		charge 		DECIMAL(12,2) NOT NULL DEFAULT 0.00, 	
 		charge_tax	DECIMAL(12,2) NOT NULL DEFAULT 0.00 	
 		);
 	DROP TEMPORARY TABLE IF EXISTS tmp_vipdai;
	CREATE TEMPORARY TABLE tmp_vipdai(
		accnt_type	VARCHAR(5),
		ta_code	 	VARCHAR(10),
		descript 	VARCHAR(20)  NOT NULL DEFAULT '',
 		credit 		DECIMAL(12,2) NOT NULL DEFAULT 0.00,
 		KEY index1(accnt_type,ta_code) 	
 		);		 
	INSERT INTO tmp_deptjie(accnt_type,modu_code,id,ta_code,market,source,charge,charge_tax)
		SELECT 'POS','04',a.id,a.code,a.market,a.source,a.amount_day,a.amount_tax FROM pos_deptjie_hd a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = var_bdate;
	INSERT INTO tmp_deptdai(accnt_type,ta_code,descript,credit)
		SELECT 'POS',a.ta_code,a.descript,a.amount_day FROM pos_deptdai a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = var_bdate;
	-- 餐预付	
	INSERT INTO tmp_deptdai(accnt_type,ta_code,descript,credit)
		SELECT 'POS',a.pay_code,b.descript,a.amount FROM pos_deposit_detail a,code_transaction b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=var_bdate AND a.pay_code=b.code AND b.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id;
	
	INSERT INTO tmp_apportion(accnt_type,accnt,ta_code1,descript1,ta_code2,descript2,amount)
		SELECT biz_type,accnt1,ta_code1,ta_descript1,ta_code2,ta_descript2,apportion_amount FROM apportion_detail 
			WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_type IN('fo','pos','AR') AND INSTR(CONCAT(',',var_tacode_ent,','),CONCAT(',',ta_code2,',')) > 0 ;
	
	-- 前台主单市场码和来源码
	UPDATE 	tmp_apportion a,master_base_till b SET a.market = b.market WHERE a.accnt_type = 'fo' AND a.accnt = b.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.market = ''; 
	UPDATE 	tmp_apportion a,master_base_till b SET a.source = b.src WHERE a.accnt_type = 'fo' AND a.accnt = b.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id ; 
	-- 餐饮
	UPDATE 	tmp_apportion a,pos_menu_hd b SET a.source = b.source,a.market = b.market WHERE a.accnt_type = 'pos' AND a.accnt = b.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id ; 
	-- AR
	UPDATE tmp_apportion a SET a.market = var_market_default WHERE a.accnt_type = 'AR' AND a.market = '';
	UPDATE tmp_apportion a SET a.source = var_src_default WHERE a.accnt_type = 'AR' AND a.source = '';
	-- 会员
 	INSERT INTO tmp_vipjie(accnt_type,modu_code,id,ta_code,market,source,charge,charge_tax)
		SELECT 'VIP','02',a.card_id,a.ta_code,'','',a.charge,'' FROM card_account a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = var_bdate AND a.source = 'OWN';
 	UPDATE tmp_vipjie a SET a.market = var_market_default,a.source = var_src_default WHERE a.accnt_type = 'VIP';
 	INSERT INTO tmp_vipdai(accnt_type,ta_code,descript,credit)
  		SELECT 'VIP',a.ta_code,a.ta_descript,a.pay FROM card_account a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = var_bdate AND a.source = 'OWN';
  		
	DELETE FROM rep_jie_hd WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	INSERT INTO rep_jie_hd(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,toclass,sequence)
		SELECT hotel_group_id,hotel_id,biz_date,orderno,itemno,CONCAT(modeno,','),classno,descript,descript1,rectype,toop,toclass,sequence FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	UPDATE rep_jie_hd SET day01=0,day02=0,day03=0,day04=0,day05=0,day06=0,day07=0,day08=0,day09=0,day10=0,
		day11=0,day12=0,day13=0,day14=0,day15=0,day16=0,day17=0,day18=0,day19=0,day99=0,biz_date = var_bfdate WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	UPDATE rep_jie_hd SET modeno = REPLACE(modeno,':',',') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
 	UPDATE rep_jie_hd SET modeno = REPLACE(modeno,'GCNULL,','') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	UPDATE rep_jie_hd SET modeno = REPLACE(modeno,';',',') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
 	UPDATE rep_jie_hd SET modeno = CONCAT(',',modeno) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND modeno <> '';
	DELETE FROM rep_dai_hd WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	INSERT INTO rep_dai_hd(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence)
		SELECT hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence FROM rep_dai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	UPDATE rep_dai_hd SET credit01=0,credit02=0,credit03=0,credit04=0,credit05=0,credit06=0,credit07=0,credit08=0,credit09=0,credit10=0,credit11=0,credit12=0,credit13=0,credit14=0,sumcre=0,debit=0,credit=0
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
  	-- 一、处理前台和AR
	OPEN c_gltemp_1;
	SET done_cursor = 0;
	FETCH c_gltemp_1 INTO var_accnt_type,var_modu_code,var_rmno,var_tacode,var_arrange_code,var_charge,var_charge_tax,var_charge_oth,var_accnt,var_trans_accnt,var_quantity,var_market,var_charge_srv,var_package_rate,var_pay,var_act_flag,var_cat_posting;
	WHILE done_cursor = 0	DO
		BEGIN
			IF var_arrange_code = '98' THEN
				CALL up_ihotel_audit_rep_jiedai_dai(arg_hotel_group_id,arg_hotel_id,var_accnt_type,'02',var_tacode,var_pay);		
			END IF;
			CALL up_ihotel_audit_rep_jiedai_jiedai(arg_hotel_group_id,arg_hotel_id,var_accnt_type,var_accnt,var_charge,var_pay);
			
			IF var_tacode <> '' THEN
				CALL up_ihotel_audit_rep_jiedai_jie(arg_hotel_group_id,arg_hotel_id,var_accnt_type,var_modu_code,var_accnt,var_tacode,var_market,'',var_charge,var_charge_tax,var_trans_accnt);	
			END IF;
			
			SET done_cursor = 0;
			FETCH c_gltemp_1 INTO var_accnt_type,var_modu_code,var_rmno,var_tacode,var_arrange_code,var_charge,var_charge_tax,var_charge_oth,var_accnt,var_trans_accnt,var_quantity,var_market,var_charge_srv,var_package_rate,var_pay,var_act_flag,var_cat_posting;
		END;
	END WHILE;	
	CLOSE c_gltemp_1 ;			
 	-- 二、处理餐饮借方
  	OPEN p_deptjie;
	SET done_cursor = 0;
	FETCH p_deptjie INTO var_accnt_type,var_modu_code,var_pos_id,var_tacode,var_market,var_source,var_charge,var_charge_tax;
	WHILE done_cursor = 0	DO
		BEGIN
		 	CALL up_ihotel_audit_rep_jiedai_jie(arg_hotel_group_id,arg_hotel_id,var_accnt_type,var_modu_code,var_pos_id,var_tacode,var_market,var_source,var_charge,var_charge_tax,NULL);
 			
			SET done_cursor = 0;
			FETCH p_deptjie INTO var_accnt_type,var_modu_code,var_pos_id,var_tacode,var_market,var_source,var_charge,var_charge_tax;
		END;
	END WHILE;	
	CLOSE p_deptjie ;		
	-- 三、处理餐饮贷方
	OPEN p_deptdai;
	SET done_cursor = 0;
	FETCH p_deptdai INTO var_accnt_type,var_tacode,var_descript,var_credit;
	WHILE done_cursor = 0	DO
		BEGIN
			CALL up_ihotel_audit_rep_jiedai_dai(arg_hotel_group_id,arg_hotel_id,var_accnt_type,'04',var_tacode,var_credit); 
  			SET done_cursor = 0;
			FETCH p_deptdai INTO var_accnt_type,var_tacode,var_descript,var_credit;
		END;
	END WHILE;	
	CLOSE p_deptdai ;
	-- 四、处理会员借方
 	OPEN c_vipjie;
	SET done_cursor = 0;
	FETCH c_vipjie INTO var_accnt_type,var_modu_code,var_vip_id,var_tacode,var_market,var_source,var_charge,var_charge_tax;
	WHILE done_cursor = 0	DO
		BEGIN
			CALL up_ihotel_audit_rep_jiedai_jie(arg_hotel_group_id,arg_hotel_id,var_accnt_type,var_modu_code,var_accnt,var_tacode,var_market,var_source,var_charge,var_charge_tax,NULL);
 			
			SET done_cursor = 0;
			FETCH c_vipjie INTO var_accnt_type,var_modu_code,var_vip_id,var_tacode,var_market,var_source,var_charge,var_charge_tax;
		END;
	END WHILE;	
	CLOSE c_vipjie ;		
	-- 四 会员贷方
	OPEN c_vipdai;
	SET done_cursor = 0;
	FETCH c_vipdai INTO var_accnt_type,var_tacode,var_descript,var_credit;
	WHILE done_cursor = 0	DO
		BEGIN
			CALL up_ihotel_audit_rep_jiedai_dai(arg_hotel_group_id,arg_hotel_id,var_accnt_type,'02',var_tacode,var_credit); 
  			SET done_cursor = 0;
			FETCH c_vipdai INTO var_accnt_type,var_tacode,var_descript,var_credit;
		END;
	END WHILE;	
	CLOSE c_vipdai ;
	
	IF EXISTS(SELECT 1 FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog='audit' AND item='ent_audit_show' AND set_value='T') THEN
		-- 五 处理款待借方
		OPEN c_charge_ent;
		SET done_cursor = 0;
		FETCH c_charge_ent INTO var_accnt_type,var_modu_code,var_accnt,var_tacode,var_market,var_source,var_amount;
		WHILE done_cursor = 0	DO
			BEGIN
				CALL up_ihotel_audit_rep_jiedai_jie(arg_hotel_group_id,arg_hotel_id,var_accnt_type,var_modu_code,var_accnt,var_tacode,var_market,var_source,var_amount,0,NULL);			
				SET done_cursor = 0;
				FETCH c_charge_ent INTO var_accnt_type,var_modu_code,var_accnt,var_tacode,var_market,var_source,var_amount;
			END;
		END WHILE;	
		CLOSE c_charge_ent;		
		-- 五 处理款待贷方
		OPEN c_pay_ent;
		SET done_cursor = 0;
		FETCH c_pay_ent INTO var_accnt_type,var_tacode,var_descript,var_amount;
		WHILE done_cursor = 0	DO
			BEGIN
				CALL up_ihotel_audit_rep_jiedai_dai(arg_hotel_group_id,arg_hotel_id,var_accnt_type,'08',var_tacode,var_amount); 
				SET done_cursor = 0;
				FETCH c_pay_ent INTO var_accnt_type,var_tacode,var_descript,var_amount;
			END;
		END WHILE;	
		CLOSE c_pay_ent;
	END IF;
		
	OPEN c_jie_custor;
	SET done_cursor = 0;
	FETCH c_jie_custor INTO var_toop,var_toclass,var_day01,var_day02,var_day03,var_day04,var_day05,var_day06,var_day07,var_day08,var_day09,var_day10,var_day11,var_day12,var_day13,var_day14,var_day15,var_day99;
	WHILE done_cursor = 0 DO
		BEGIN
			WHILE var_toclass <> SPACE(8) DO
				BEGIN
					IF var_toop = '+' THEN
						UPDATE rep_jie_hd SET day01 = day01+var_day01,day02=day02+var_day02,day03 = day03+var_day03,day04=day04+var_day04,day05=day05+var_day05,day06=day06+var_day06,
						day07=day07+var_day07,day08=day08+var_day08,day09=day09+var_day09,day10=day10+var_day10,day11=day11+var_day11,day12=day12+var_day12,day99=day99+var_day99 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = var_toclass;
					ELSE
						UPDATE rep_jie_hd SET day01 = day01-var_day01,day02=day02-var_day02,day03 = day03-var_day03,day04=day04-var_day04,day05=day05-var_day05,day06=day06-var_day06,
						day07=day07-var_day07,day08=day08-var_day08,day09=day09-var_day09,day10=day10-var_day10,day11=day11-var_day11,day12=day12-var_day12,day99=day99-var_day99 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = var_toclass;
						
					END IF;
  					SELECT toclass,toop INTO var_toclass,var_toop FROM rep_jie_hd WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = var_toclass;
					IF FOUND_ROWS() = 0 THEN
						SET var_toclass = SPACE(8) ;
					END IF ; 
				END;
			END WHILE;
   			SET done_cursor = 0;
			FETCH c_jie_custor INTO var_toop,var_toclass,var_day01,var_day02,var_day03,var_day04,var_day05,var_day06,var_day07,var_day08,var_day09,var_day10,var_day11,var_day12,var_day13,var_day14,var_day15,var_day99;
		END;
	END WHILE;	
	CLOSE c_jie_custor ;	 
	UPDATE rep_jie_hd SET biz_date = var_bdate WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	UPDATE rep_dai_hd a,rep_dai_hd_history b SET a.last_bl = b.till_bl WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
			AND a.classno = b.classno AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = var_bfdate;
	-- 餐预付	
	UPDATE rep_dai_hd a,pos_deposit_sum b SET a.debit=b.add,a.credit=b.reduce WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=var_bdate AND a.classno='04000' AND b.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.biz_date=var_bdate;		
	UPDATE rep_dai_hd a SET a.sumcre=a.debit-a.credit WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=var_bdate AND a.classno='04000';
	-- 本日余额
	UPDATE rep_dai_hd SET till_bl = IFNULL(last_bl,0) + debit - credit, biz_date = var_bdate WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	-- 会员卡部分
	UPDATE rep_dai_hd a,rep_dai b SET a.last_bl = b.last_bl,a.debit=b.debit,a.credit=b.credit,a.till_bl=b.till_bl,a.sumcre=b.sumcre WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
			AND a.biz_date = var_bdate AND a.classno = '06000' AND a.classno = b.classno AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = var_bdate;
 	SELECT IFNULL(SUM(sumcre),0) INTO var_amount_sumcre FROM rep_dai_hd WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id  AND classno IN('01010','02000','03000','06000');
 	SELECT IFNULL(-1*sumcre,0) INTO var_amount_sumcre_pos FROM rep_dai_hd WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id  AND classno='04000';
	UPDATE rep_dai_hd SET sumcre = IFNULL(var_amount_sumcre,  0) +IFNULL(var_amount_sumcre_pos,0)
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = '09000'; 
			
	-- 特殊项目处理
	IF EXISTS (SELECT 1 FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id AND brand_code = 'A') THEN
		SET var_jiecode = '010120';
	ELSEIF EXISTS (SELECT 1 FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id AND brand_code IN ( 'B','E')) THEN
		SET var_jiecode = '101010';		
	END IF;	
	-- 前台人数 | 市场 来源
	UPDATE rep_jie_hd SET day99 = (SELECT IFNULL(SUM(people_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day01 = (SELECT IFNULL(SUM(people_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'JZ')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day02 = (SELECT IFNULL(SUM(people_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'HW')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day03 = (SELECT IFNULL(SUM(people_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'YX')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day04 = (SELECT IFNULL(SUM(people_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'SWSK')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day05 = (SELECT IFNULL(SUM(people_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'LYSK')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day06 = (SELECT IFNULL(SUM(people_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'TD')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;	
	UPDATE rep_jie_hd SET day07 = (SELECT IFNULL(SUM(people_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'LYZXT')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;	
	UPDATE rep_jie_hd SET day11 = (SELECT IFNULL(SUM(people_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='SOURCE' AND CODE = 'XS') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day12 = (SELECT IFNULL(SUM(people_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='SOURCE' AND CODE = 'XX') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	
	-- 前台间夜 | 市场 来源
	IF (SELECT 1 FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id AND brand_code = 'A') THEN
		SET var_jiecode = '010130';
	ELSEIF EXISTS (SELECT 1 FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id AND brand_code IN ( 'B','E')) THEN
		SET var_jiecode = '101020';		
	END IF;
	
	SELECT IFNULL(SUM(rooms_total),0) INTO var_amount_xs FROM rep_revenue_type_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND master_type = 'FO' AND biz_date=var_bdate AND market='HSE' AND src='XS';
	SELECT IFNULL(SUM(rooms_total),0) INTO var_amount_xx FROM rep_revenue_type_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND master_type = 'FO' AND biz_date=var_bdate AND market='HSE' AND src='XX';
	
	UPDATE rep_jie_hd SET day99 = (SELECT IFNULL(SUM(rooms_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE<>'HSE') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day01 = (SELECT IFNULL(SUM(rooms_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'JZ' AND CODE<>'HSE')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day02 = (SELECT IFNULL(SUM(rooms_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'HW' AND CODE<>'HSE')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day03 = (SELECT IFNULL(SUM(rooms_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'YX' AND CODE<>'HSE')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day04 = (SELECT IFNULL(SUM(rooms_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'SWSK' AND CODE<>'HSE')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day05 = (SELECT IFNULL(SUM(rooms_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'LYSK' AND CODE<>'HSE')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day06 = (SELECT IFNULL(SUM(rooms_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'TD' AND CODE<>'HSE')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;	
	UPDATE rep_jie_hd SET day07 = (SELECT IFNULL(SUM(rooms_total),0) FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET' AND CODE IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'LYZXT' AND CODE<>'HSE')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;	
	UPDATE rep_jie_hd SET day11 = (SELECT IFNULL(SUM(rooms_total),0) - var_amount_xs FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='SOURCE' AND CODE = 'XS') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	UPDATE rep_jie_hd SET day12 = (SELECT IFNULL(SUM(rooms_total),0) - var_amount_xx FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='SOURCE' AND CODE = 'XX') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		
	IF EXISTS (SELECT 1 FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id AND brand_code IN ( 'B','E')) THEN
		SET var_jiecode = '101030';
		UPDATE rep_jie_hd SET day99 = (SELECT IFNULL(SUM(rooms_avl),0) FROM rep_rmsale WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND rep_type='B') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;		
	END IF;
	
	IF EXISTS (SELECT 1 FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id AND brand_code IN ( 'B','E')) THEN
		SET var_jiecode = '101040';
		UPDATE rep_jie_hd SET day99 = (SELECT IFNULL(ROUND(SUM(sold_fit+sold_grp+sold_long+sold_ent)*100/SUM(rooms_total),2),0) 
			FROM rep_rmsale WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate 
				AND rep_type='B') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate 
				AND classno = var_jiecode;		
	END IF;
	
	IF (SELECT 1 FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id AND brand_code = 'A') THEN
		SET var_jiecode = '020114';
	ELSEIF EXISTS (SELECT 1 FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id AND brand_code IN ( 'B','E')) THEN
		SET var_jiecode = '201030';
	END IF;	
	-- 餐饮人数 | 正餐 | 市场 来源
	IF arg_hotel_id = 11 THEN
		UPDATE rep_jie_hd SET day99 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND pccode <> '100') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day01 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'JZ' AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day02 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'HW' AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day03 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'YX' AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day04 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'SWSK' AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day05 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'LYSK' AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day06 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'TD'  AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;	
		UPDATE rep_jie_hd SET day07 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'LYZXT' AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;	
		UPDATE rep_jie_hd SET day11 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND source = 'XS'  AND pccode <> '100') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day12 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND source = 'XX'  AND pccode <> '100') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	ELSE
		UPDATE rep_jie_hd SET day99 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day01 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'JZ')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day02 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'HW')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day03 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'YX')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day04 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'SWSK')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day05 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'LYSK')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day06 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'TD')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;	
		UPDATE rep_jie_hd SET day07 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'LYZXT')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;	
		UPDATE rep_jie_hd SET day11 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND source = 'XS') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day12 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift NOT IN('1') AND source = 'XX') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	END IF;	
	
	IF (SELECT 1 FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id AND brand_code = 'A') THEN
		SET var_jiecode = '020115';
	ELSEIF EXISTS (SELECT 1 FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id AND brand_code IN ( 'B','E')) THEN
		SET var_jiecode = '201040';		
	END IF;
	-- 餐饮人数 | 早餐 | 市场 来源
	IF arg_hotel_id = 11 THEN
		UPDATE rep_jie_hd SET day99 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND pccode <> '100') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day01 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'JZ' AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day02 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'HW' AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day03 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'YX' AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day04 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'SWSK' AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day05 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'LYSK' AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day06 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'TD' AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;	
		UPDATE rep_jie_hd SET day07 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'LYZXT' AND pccode <> '100')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;	
		UPDATE rep_jie_hd SET day11 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND source = 'XS' AND pccode <> '100') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day12 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND source = 'XX' AND pccode <> '100') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	ELSE
		UPDATE rep_jie_hd SET day99 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day01 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'JZ')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day02 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'HW')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day03 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'YX')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day04 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'SWSK')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day05 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'LYSK')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day06 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'TD')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;	
		UPDATE rep_jie_hd SET day07 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND market IN (SELECT CODE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code' AND code_category = 'LYZXT')) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;	
		UPDATE rep_jie_hd SET day11 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND source = 'XS') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
		UPDATE rep_jie_hd SET day12 = (SELECT IFNULL(SUM(gsts),0) FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sta<>'X' AND shift='1' AND source = 'XX') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND classno = var_jiecode;
	END IF;
	
	
	DELETE FROM rep_jie_hd_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;
	INSERT INTO rep_jie_hd_history SELECT * FROM rep_jie_hd WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_dai_hd_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;
	INSERT INTO rep_dai_hd_history SELECT * FROM rep_dai_hd WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
    		
    BEGIN 
		SET @procresult = 0 ;
		LEAVE label_0 ;
	END ;
	
  END$$

DELIMITER ;