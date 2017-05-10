DELIMITER $$

USE `portal`$$

DROP PROCEDURE IF EXISTS `ihotel_up_mstbalance`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_mstbalance`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_bdate			DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==================================
	-- 夜审前数据导入修复
	-- ==================================
	DECLARE var_bfdate			DATETIME;
	DECLARE var_amount			DECIMAL(12,2); 
	DECLARE var_amount1			DECIMAL(12,2); 
	DECLARE var_amount2			DECIMAL(12,2); 
	DECLARE var_amount3			DECIMAL(12,2); 
	DECLARE var_amount4			DECIMAL(12,2); 	
	
	SET var_bfdate = DATE_ADD(arg_bdate,INTERVAL -1 DAY);
	 
	DROP TABLE IF EXISTS tmp_balance;
	CREATE TABLE tmp_balance (
		hotel_group_id   INT,
		hotel_id	INT,
		biz_date	DATETIME,
		classno		VARCHAR(10),
		descript	VARCHAR(20),
		last_bl		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		till_bl		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		last_charge	DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		till_charge	DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		KEY index1 (hotel_group_id,hotel_id,classno)
	);
	
	INSERT INTO  tmp_balance(hotel_group_id,hotel_id,biz_date,classno,descript) VALUES
	(arg_hotel_group_id,arg_hotel_id,arg_bdate,'02000','宾客帐'),
	(arg_hotel_group_id,arg_hotel_id,arg_bdate,'03000','AR帐'),
	(arg_hotel_group_id,arg_hotel_id,arg_bdate,'03A','应收帐'),
	(arg_hotel_group_id,arg_hotel_id,arg_bdate,'02G','团体'),
	(arg_hotel_group_id,arg_hotel_id,arg_bdate,'02C','消费帐'),
	(arg_hotel_group_id,arg_hotel_id,arg_bdate,'02F','宾客');
	-- 宾客帐上日余额，本日余额
	SELECT IFNULL(SUM(last_balance),0),IFNULL(SUM(till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND sta IN ("I","S","O","R","X") AND master_type <>'armaster' AND biz_date_begin < arg_bdate AND biz_date_end >= arg_bdate;
 	UPDATE tmp_balance SET last_bl = var_amount1,till_bl = var_amount2 WHERE classno = '02000';
 	
	-- AR账上日余额，本日余额
	SELECT IFNULL(SUM(last_balance),0),IFNULL(SUM(till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND sta IN ("I","S","O","R","X") AND master_type = 'armaster' AND biz_date_begin < arg_bdate AND biz_date_end >= arg_bdate;
 	UPDATE tmp_balance SET last_bl = var_amount1,till_bl = var_amount2 WHERE classno = '03000';
 	
	-- 应收帐上日余额，本日余额 
	SELECT IFNULL(SUM(last_balance),0) ,IFNULL(SUM(till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND sta IN ("I","S","O","R","X") AND master_type = 'armaster' AND biz_date_begin < arg_bdate AND biz_date_end >= arg_bdate;
 	UPDATE tmp_balance SET last_charge = var_amount1,till_charge = var_amount2 WHERE classno = '03A';
 	
	-- 消费帐上日余额，本日余额
	SELECT IFNULL(SUM(last_balance),0) ,IFNULL(SUM(till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND sta IN ("I","S","O","R","X") AND master_type = 'consume' AND biz_date_begin < arg_bdate AND biz_date_end >= arg_bdate;
 	UPDATE tmp_balance SET last_charge = var_amount1,till_charge = var_amount2 WHERE classno = '02C';
    
	-- 团队上日余额，本日余额
    SELECT IFNULL(SUM(a.last_balance),0) ,IFNULL(SUM(a.till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot a ,master_base b 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.rsv_class = 'G' AND a.biz_date_begin < arg_bdate AND a.biz_date_end >= arg_bdate;
  	UPDATE tmp_balance SET last_charge = var_amount1 ,till_charge = var_amount2  WHERE classno = '02G';
	
	-- 宾客上日余额，本日余额
  	SELECT  IFNULL(SUM(last_bl),0),IFNULL(SUM(till_bl),0) INTO var_amount3,var_amount4  FROM tmp_balance 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno ='02000';
	SELECT IFNULL(SUM(last_charge),0) ,IFNULL(SUM(till_charge),0) INTO var_amount1,var_amount2 FROM tmp_balance 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno IN('02C','02G');
	UPDATE tmp_balance SET last_charge = var_amount3 - var_amount1,till_charge = var_amount4 - var_amount2 
		WHERE classno = '02F' AND hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	
	UPDATE rep_dai_history a,tmp_balance b SET a.last_bl = IFNULL(b.last_bl,0),a.till_bl = IFNULL(b.till_bl,0) 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.biz_date = b.biz_date AND a.biz_date = arg_bdate AND a.classno = b.classno;
	UPDATE rep_jiedai_history a,tmp_balance b SET a.last_charge = IFNULL(b.last_charge,0) + IFNULL(a.last_credit,0),a.till_charge = IFNULL(b.till_charge,0) + IFNULL(a.till_credit,0) 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = b.biz_date AND a.biz_date = arg_bdate AND a.classno = b.classno;
	 
	UPDATE rep_dai a,tmp_balance b  SET a.last_bl = IFNULL(b.last_bl,0),a.till_bl = IFNULL(b.till_bl,0) 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.biz_date = b.biz_date AND a.biz_date = arg_bdate AND a.classno = b.classno;
	UPDATE rep_jiedai a,tmp_balance b SET a.last_charge = IFNULL(b.last_charge,0) + IFNULL(a.last_credit,0),a.till_charge = IFNULL(b.till_charge,0) + IFNULL(a.till_credit,0) 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.biz_date = b.biz_date AND a.biz_date = arg_bdate AND a.classno = b.classno;
	
	
END$$

DELIMITER ;