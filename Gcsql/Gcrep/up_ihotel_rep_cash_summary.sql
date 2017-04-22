DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_cash_summary`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_cash_summary`(
	IN arg_hotel_group_id	BIGINT(16),
	IN arg_hotel_id		BIGINT(16),
	IN arg_biz_date		DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ====================================================================================
	-- 现金收入表:包含前台、餐饮、会员，其中餐饮部分分营业点统计
	-- 作者：zhangh
	-- A:现金 B:支票 C:国内卡 D: 国外卡 E:贵宾卡 F:代价券 G:内部转账 H:款待 I:宾客账 J:AR账
	-- ====================================================================================
	DECLARE done_cursor INT DEFAULT 0;
	DECLARE var_cat		VARCHAR(4);
	DECLARE var_tacode	VARCHAR(10);
	DECLARE var_paytype	VARCHAR(10);
	DECLARE var_cashier TINYINT(4);
	DECLARE var_cashier_user VARCHAR(20);
	DECLARE var_fee	DECIMAL(12,2);
	DECLARE c_cursor CURSOR FOR SELECT pay_type,cashier,cashier_user,cat_code,ta_code,SUM(amount) FROM tmp_rep_cashrep WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id 
		GROUP BY pay_type,cashier,cashier_user,cat_code,ta_code
		ORDER BY pay_type,cashier,cashier_user,cat_code,ta_code;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	DROP TEMPORARY TABLE IF EXISTS tmp_rep_cashrep;	
	CREATE TEMPORARY TABLE tmp_rep_cashrep (
	  hotel_group_id 	BIGINT(16)  NOT NULL,
	  hotel_id 		BIGINT(16)  NOT NULL,
	  pay_type 		VARCHAR(10) NOT NULL,
	  pay_des		VARCHAR(20) NOT NULL,
	  ta_code 		VARCHAR(10) NOT NULL,
	  cat_code		VARCHAR(4)  NOT NULL,
	  cashier 		TINYINT(4)  NOT NULL,
	  cash_des		VARCHAR(20) NOT NULL,
	  cashier_user 		VARCHAR(20) NOT NULL,
	  user_des		VARCHAR(30) NOT NULL,
	  amount 		DECIMAL(12,2) NOT NULL,
	  KEY Index_1 (hotel_group_id,hotel_id,pay_type,ta_code)
	);
	
	DROP TEMPORARY TABLE IF EXISTS tmp_rep_pcashrep;	
	CREATE TEMPORARY TABLE tmp_rep_pcashrep (
	  hotel_group_id 	BIGINT(16)  NOT NULL,
	  hotel_id 		BIGINT(16)  NOT NULL,
	  pay_type 		VARCHAR(10) NOT NULL,
	  pay_des		VARCHAR(20) NOT NULL,
	  cashier 		TINYINT(4)  NOT NULL,
	  cash_des		VARCHAR(20) NOT NULL,
	  cashier_user 		VARCHAR(20) NOT NULL,
	  user_des		VARCHAR(30) NOT NULL,
	  v1	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v2	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v3	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v4	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v5	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v6	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v7	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v8	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v9	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v10	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v11	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v12	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v13	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v14	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v15	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v16	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v17	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v18	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v19	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  v20	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	  vtl	 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',	  
	  KEY Index_1 (hotel_group_id,hotel_id,pay_type,cashier,cashier_user)
	);
	
	DELETE FROM tmp_rep_cashrep WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	-- 前台
	INSERT INTO tmp_rep_cashrep	
		SELECT a.hotel_group_id,a.hotel_id,a.pay_type,'',a.ta_code,b.category_code,a.cashier,d.descript,a.cashier_user,IFNULL(c.name,''),a.amount
			FROM rep_pay_sum_history a 
				LEFT JOIN code_transaction b ON a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.ta_code = b.code AND b.arrange_code IN ('98','99')
				LEFT JOIN USER c ON a.hotel_group_id = c.hotel_group_id AND a.hotel_id = c.hotel_id AND a.cashier_user = c.code AND a.cashier_user <> ''
				LEFT JOIN code_base d ON a.hotel_group_id = d.hotel_group_id AND a.hotel_id = d.hotel_id AND a.cashier = d.code AND d.parent_code='shift'
			WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_biz_date AND a.pay_type <> 'PO'
			ORDER BY a.pay_type,a.cashier_user,b.category_code;
	-- 餐饮		
	INSERT INTO tmp_rep_cashrep
		SELECT a.hotel_group_id,a.hotel_id,b.pos_code,b.descript,a.code,c.category_code,a.cashier,e.descript,a.puser,IFNULL(d.name,''),SUM(a.fee)
			FROM pos_dish a
				LEFT JOIN code_transaction c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.code = c.code AND c.arrange_code IN ('98','99')
				LEFT JOIN USER d ON d.hotel_group_id = arg_hotel_group_id AND d.hotel_id = arg_hotel_id AND a.puser = d.code
				LEFT JOIN code_base e ON e.hotel_group_id = arg_hotel_group_id AND e.hotel_id = arg_hotel_id AND a.cashier = e.code AND e.parent_code='shift'
				,pos_interface_map b
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date AND a.list_order>=100 AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.pos_station=b.code AND b.link_type='ta_code' 
			GROUP BY pos_code,cashier,puser,CODE
			ORDER BY pos_code,cashier,puser,CODE;
	-- 会员		
	INSERT INTO tmp_rep_cashrep
		SELECT a.hotel_group_id,a.hotel_id,'CARD','会员卡',a.ta_code,b.category_code,a.cashier,d.descript,a.create_user,IFNULL(c.name,''),SUM(a.pay)
			FROM card_account a
				LEFT JOIN code_transaction b ON b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.ta_code = b.code AND b.arrange_code IN ('98','99')
				LEFT JOIN USER c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.create_user = c.code
				LEFT JOIN code_base d ON d.hotel_group_id = arg_hotel_group_id AND d.hotel_id = arg_hotel_id AND a.cashier = d.code AND d.parent_code='shift'
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date AND a.pay <>0
			GROUP BY a.cashier,a.create_user,a.ta_code
			ORDER BY a.cashier,a.create_user,a.ta_code;			
			
	DELETE FROM tmp_rep_cashrep WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_code IN ('H','J');
	UPDATE tmp_rep_cashrep SET pay_type = 'PO',cashier = '0',cash_des = '所有' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cashier_user = '' AND user_des = '';
	UPDATE tmp_rep_cashrep SET pay_des = 'AR帐' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pay_type = 'AR';
	-- UPDATE tmp_rep_cashrep SET pay_des = '餐饮' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pay_type = 'PO';
	UPDATE tmp_rep_cashrep SET pay_des = '前台' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pay_type = 'FO';
	UPDATE tmp_rep_cashrep SET pay_des = '预订' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pay_type = 'RESER';
		
	INSERT INTO tmp_rep_pcashrep(hotel_group_id,hotel_id,pay_type,pay_des,cashier,cash_des,cashier_user,user_des)
		SELECT DISTINCT hotel_group_id,hotel_id,pay_type,pay_des,cashier,cash_des,cashier_user,user_des
			FROM tmp_rep_cashrep WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
		
	SET done_cursor = 0;	
	OPEN c_cursor;
	FETCH c_cursor INTO var_paytype,var_cashier,var_cashier_user,var_cat,var_tacode,var_fee;
		WHILE done_cursor = 0 DO
			BEGIN
				IF var_cat = 'A' THEN	-- 现金		
					UPDATE tmp_rep_pcashrep SET v1 = v1 + var_fee WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pay_type = var_paytype AND cashier = var_cashier AND cashier_user = var_cashier_user;
				ELSEIF var_cat = 'B' THEN -- 支票	
					UPDATE tmp_rep_pcashrep SET v2 = v2 + var_fee WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pay_type = var_paytype AND cashier = var_cashier AND cashier_user = var_cashier_user;
				ELSEIF var_cat IN ('C','D') THEN  -- 信用卡
					UPDATE tmp_rep_pcashrep SET v3 = v3 + var_fee WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pay_type = var_paytype AND cashier = var_cashier AND cashier_user = var_cashier_user;
				-- ELSEIF var_cat = 'D' THEN	
					-- UPDATE tmp_rep_pcashrep SET v4 = v4 + var_fee WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pay_type = var_paytype AND cashier = var_cashier AND cashier_user = var_cashier_user;
				ELSEIF var_cat = 'E' THEN	-- 贵宾卡
					UPDATE tmp_rep_pcashrep SET v5 = v5 + var_fee WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pay_type = var_paytype AND cashier = var_cashier AND cashier_user = var_cashier_user;
				ELSEIF var_cat = 'F' THEN	-- 代价券
					UPDATE tmp_rep_pcashrep SET v6 = v6 + var_fee WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pay_type = var_paytype AND cashier = var_cashier AND cashier_user = var_cashier_user;
				ELSEIF var_cat = 'G' THEN	-- 内部转账
					UPDATE tmp_rep_pcashrep SET v7 = v7 + var_fee WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pay_type = var_paytype AND cashier = var_cashier AND cashier_user = var_cashier_user;
				ELSE
					UPDATE tmp_rep_pcashrep SET v20 = v20 + var_fee WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pay_type = var_paytype AND cashier = var_cashier AND cashier_user = var_cashier_user;
				END IF;	
			END;
		SET done_cursor = 0 ;
		FETCH c_cursor INTO var_paytype,var_cashier,var_cashier_user,var_cat,var_tacode,var_fee;
		END WHILE;
	CLOSE c_cursor;	
		UPDATE tmp_rep_pcashrep SET vtl = v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 + v12 + v13 + v14 + v15 + v16 + v17 + v18 + v19 + v20
			WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
		DELETE FROM tmp_rep_pcashrep WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id 
			AND v1 = 0 AND v2 = 0 AND v3 = 0 AND v4 = 0 AND v5 = 0 AND v6 = 0 AND v7 = 0 AND v8 = 0 AND v9 = 0 AND v10 = 0 
			AND v11 = 0 AND v12 = 0 AND v13 = 0 AND v14 = 0 AND v15 = 0 AND v16 = 0 AND v17 = 0 AND v18 = 0 AND v19 = 0 AND v20 = 0;
	
	SELECT pay_type,pay_des,cashier,cash_des,cashier_user,user_des,v1,v2,v3,v4,v5,v6,v7,vtl 
		FROM tmp_rep_pcashrep 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id 
		ORDER BY pay_type DESC,cashier,cashier_user;
	DROP TEMPORARY TABLE IF EXISTS tmp_rep_cashrep;
	DROP TEMPORARY TABLE IF EXISTS tmp_rep_pcashrep;
	
END$$

DELIMITER ;