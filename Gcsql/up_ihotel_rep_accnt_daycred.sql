DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_accnt_daycred`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_accnt_daycred`(
	IN arg_hotel_group_id   INT,
	IN arg_hotel_id     	INT,	        
	IN arg_biz_date			DATETIME,
	IN arg_user     		VARCHAR(20),
	IN arg_shift    		VARCHAR(20)
    )
	
	SQL SECURITY INVOKER
label_0:
BEGIN
	-- =============================================================================
	-- 用途:应交款项表 权责发生制
	-- 解释:
	-- 作者:zhangh 2015-04-29
	-- =============================================================================
	DECLARE done_cursor INT DEFAULT 0;
	DECLARE var_count 	INT;
	DECLARE var_code	VARCHAR(10);
	DECLARE var_number	CHAR(1);
	DECLARE var_tor		VARCHAR(10);

	-- DECLARE c_cursor CURSOR FOR SELECT code FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code='payment_category' ORDER BY code;

	DECLARE c_cursor CURSOR FOR SELECT ta_class FROM tmp_accnt_daycred WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY ta_class ORDER BY ta_class;	

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	DROP TABLE IF EXISTS tmp_accnt_daycred;
	CREATE TABLE tmp_accnt_daycred(
		hotel_group_id	INT,
		hotel_id		INT,
		ta_class		CHAR(1)		not null,				-- 款项大类
		classdes		VARchar(20)	null,					-- 大类说明
		ta_code			VARCHAR(10)	not null,				-- RMB的排序码			
		codedes			VARCHAR(50)	null,					-- 细类说明
		amount1			DECIMAL(12,2) DEFAULT '0.00', 
		amount2			DECIMAL(12,2) DEFAULT '0.00', 
		amount3			DECIMAL(12,2) DEFAULT '0.00', 
		amount4			DECIMAL(12,2) DEFAULT '0.00',
		amount5			DECIMAL(12,2) DEFAULT '0.00',
		KEY index1(hotel_group_id,hotel_id,ta_class),
		KEY index2(hotel_group_id,hotel_id,ta_code)
	);	
	
	DROP TABLE IF EXISTS tmp_account_daycred;
	CREATE TABLE tmp_account_daycred (
		hotel_group_id 		INT NOT NULL,
		hotel_id 			INT NOT NULL,
		biz_date 			DATETIME,
		accnt_type			VARCHAR(10),
		accnt 				BIGINT(16),		
		arrange_code 		VARCHAR(10) ,
		ta_code 			VARCHAR(10) ,
		ta_descript 		VARCHAR(60) NOT NULL,  
		charge 				DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		pay 				DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		act_flag 			VARCHAR(10),
		trans_flag 			CHAR(2) DEFAULT NULL,
		trans_accnt 		BIGINT(16) DEFAULT NULL,
		cashier				INT,
		KEY index1 (hotel_group_id,hotel_id,accnt_type,accnt),
		KEY index2 (hotel_group_id,hotel_id,ta_code),
		KEY index3 (hotel_group_id,hotel_id,trans_accnt)
	);
	
	IF  arg_shift = '' OR arg_shift IS NULL THEN
		SET arg_shift='%';
	END IF;
	IF  arg_user = '' OR arg_user IS NULL THEN 
		SET arg_user='%';
	END IF;
	
	INSERT INTO tmp_account_daycred
		SELECT hotel_group_id,hotel_id,biz_date,'FO',accnt,arrange_code,ta_code,ta_descript,charge,pay,act_flag,trans_flag,trans_accnt,cashier
			FROM account 
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND cashier LIKE arg_shift AND create_user LIKE arg_user
		UNION ALL
		SELECT hotel_group_id,hotel_id,biz_date,'FO',accnt,arrange_code,ta_code,ta_descript,charge,pay,act_flag,trans_flag,trans_accnt,cashier
			FROM account_history 
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND cashier LIKE arg_shift AND create_user LIKE arg_user;		
	
	INSERT INTO tmp_account_daycred
		SELECT hotel_group_id,hotel_id,biz_date,'AR',accnt,arrage_code,ta_code,ta_descript,charge+charge0,pay+pay0,act_flag,trans_flag,trans_accnt,cashier
			FROM ar_account 
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND act_tag='A' AND cashier LIKE arg_shift AND create_user LIKE arg_user
		UNION ALL
		SELECT hotel_group_id,hotel_id,biz_date,'AR',accnt,arrage_code,ta_code,ta_descript,charge,pay,act_flag,trans_flag,trans_accnt,cashier
			FROM ar_account_history 
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND act_tag='A' AND cashier LIKE arg_shift AND create_user LIKE arg_user;
	
	INSERT INTO tmp_accnt_daycred(hotel_group_id,hotel_id,ta_class,classdes,ta_code,codedes)	
		SELECT arg_hotel_group_id,arg_hotel_id,b.code,b.descript,a.code,a.descript FROM code_transaction a,code_base b 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.arrange_code>'9' AND a.category_code=b.code			
			AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.parent_code='payment_category' ORDER BY b.code,a.code;

	UPDATE tmp_accnt_daycred a SET a.amount1 = a.amount1 + IFNULL((SELECT SUM(b.pay) FROM tmp_account_daycred b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.ta_code=b.ta_code AND b.cashier='1'),0) 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id;
	UPDATE tmp_accnt_daycred a SET a.amount2 = a.amount2 + IFNULL((SELECT SUM(b.pay) FROM tmp_account_daycred b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.ta_code=b.ta_code AND b.cashier='2'),0) 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id;
	UPDATE tmp_accnt_daycred a SET a.amount3 = a.amount3 + IFNULL((SELECT SUM(b.pay) FROM tmp_account_daycred b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.ta_code=b.ta_code AND b.cashier='3'),0) 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id;
	UPDATE tmp_accnt_daycred a SET a.amount4 = a.amount4 + IFNULL((SELECT SUM(b.pay) FROM tmp_account_daycred b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.ta_code=b.ta_code AND b.cashier='4'),0) 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id;		
	
	/*
	SELECT code INTO var_tor FROM code_transaction WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat_posting='TA';
	UPDATE tmp_accnt_daycred a SET a.amount1 = a.amount1 + IFNULL((SELECT SUM(b.charge) FROM tmp_account_daycred b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.accnt_type='AR' AND arrange_code<'9' AND b.cashier='1'),0) 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND ta_code=var_tor;
	UPDATE tmp_accnt_daycred a SET a.amount2 = a.amount2 + IFNULL((SELECT SUM(b.charge) FROM tmp_account_daycred b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.accnt_type='AR' AND arrange_code<'9' AND b.cashier='2'),0) 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND ta_code=var_tor;
	UPDATE tmp_accnt_daycred a SET a.amount3 = a.amount3 + IFNULL((SELECT SUM(b.charge) FROM tmp_account_daycred b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.accnt_type='AR' AND arrange_code<'9' AND b.cashier='3'),0) 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND ta_code=var_tor;
	UPDATE tmp_accnt_daycred a SET a.amount4 = a.amount4 + IFNULL((SELECT SUM(b.charge) FROM tmp_account_daycred b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.accnt_type='AR' AND arrange_code<'9' AND b.cashier='4'),0) 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND ta_code=var_tor;		
	*/

	UPDATE tmp_accnt_daycred SET amount5 = amount1 + amount2 + amount3 + amount4 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	DELETE FROM tmp_accnt_daycred WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND amount1 = 0 AND amount2 = 0 AND amount3 = 0 AND amount4 = 0;
		
	SET var_count = 1;		

	OPEN c_cursor ;
	SET done_cursor = 0 ;	
	FETCH c_cursor INTO var_code;	
	WHILE done_cursor = 0 DO
		BEGIN	
			CALL up_ihotel_getchinanumber(var_count,'F',var_number);
			UPDATE tmp_accnt_daycred SET classdes = CONCAT(var_number,'.',classdes) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND ta_class=var_code;
			
			SET var_count = var_count + 1;
			
		SET done_cursor = 0 ;
		FETCH c_cursor INTO var_code;  
		END ;
	END WHILE ;
	CLOSE c_cursor;	

	
	SELECT ta_class,classdes,ta_code,codedes,amount1,amount2,amount3,amount4,amount5 FROM tmp_accnt_daycred WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id ORDER BY ta_class,ta_code;
	
	DROP TABLE IF EXISTS tmp_accnt_daycred;
	DROP TABLE IF EXISTS tmp_account_daycred;
	
END$$

DELIMITER ;