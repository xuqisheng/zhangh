DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_mstbalance_x5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_mstbalance_x5`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_bdate			DATETIME
)
    SQL SECURITY INVOKER
label_0:

BEGIN
	-- ==================================
	-- 夜审后数据导入修复
	-- ==================================
	DECLARE var_bfdate			DATETIME;
	DECLARE var_amount			DECIMAL(12,2); 
	DECLARE var_amount1			DECIMAL(12,2); 
	DECLARE var_amount2			DECIMAL(12,2); 
	DECLARE var_amount3			DECIMAL(12,2); 
	DECLARE var_amount4			DECIMAL(12,2); 	
	
	SET var_bfdate = DATE_ADD(arg_bdate,INTERVAL -1 DAY);
	 
	DROP TABLE IF EXISTS tmp_repdai_bal;
	CREATE TABLE  tmp_repdai_bal (
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
	
	DROP TABLE IF EXISTS tmp_ihotel_bal;
	CREATE TABLE tmp_ihotel_bal(
		hotel_group_id  INT,
		hotel_id		INT,
		accnt_type 	VARCHAR(10) DEFAULT NULL,
		accnt_new 	BIGINT(16) 	DEFAULT NULL,
		charge 		DECIMAL(12,2) DEFAULT NULL,
		pay			DECIMAL(12,2) DEFAULT NULL,
		balance 	DECIMAL(12,2) DEFAULT NULL,
		accnt_old 	VARCHAR(10) DEFAULT NULL,
		KEY index1 (hotel_id,accnt_type,accnt_new)
	);	
	
	DELETE FROM tmp_ihotel_bal WHERE hotel_group_id =arg_hotel_group_id AND hotel_id = arg_hotel_id;
	-- 前台部分(master) | 消费账 在住 预订
	INSERT INTO tmp_ihotel_bal
	SELECT arg_hotel_group_id,arg_hotel_id,'master',accnt,SUM(charge),SUM(pay),SUM(charge-pay),'' FROM account 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date <=var_bfdate GROUP BY accnt;

	INSERT INTO tmp_ihotel_bal
	SELECT arg_hotel_group_id,arg_hotel_id,'armaster',accnt,SUM(charge+charge0),SUM(pay+pay0),SUM(charge+charge0-pay-pay0),'' FROM ar_account 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date <=var_bfdate GROUP BY accnt;		
	-- AR部分(armaster) 此句适用于两边夜审前导数据
	/*
	INSERT INTO tmp_ihotel_bal
	SELECT arg_hotel_id,'armaster',a.id, SUM(a.charge-a.pay),'' FROM ar_master_till a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id GROUP BY a.id;

	SELECT b.* FROM up_map_accnt a,tmp_ihotel_bal b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_id=arg_hotel_id
	AND a.accnt_new=b.accnt AND a.accnt_type IN ('master_si','master_r','consume') AND b.accnt_type='master';

	UPDATE up_map_accnt a,tmp_ihotel_bal b SET b.accnt_old=a.accnt_old 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_id=arg_hotel_id AND a.accnt_new=b.accnt AND a.accnt_type IN ('master_si','master_r','consume') AND b.accnt_type='master';
	
	UPDATE up_map_accnt a,tmp_ihotel_bal b SET b.accnt_old=a.accnt_old 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_id=arg_hotel_id AND a.accnt_new=b.accnt AND a.accnt_type='armst' AND b.accnt_type='armaster';

	-- 判断是否存在不等
	SELECT a.accnt,a.accnt_old,a.balance,b.tillbl FROM tmp_ihotel_bal a LEFT JOIN migrate_db.mstbalrep b ON a.accnt_old=b.accnt
		WHERE a.hotel_id=arg_hotel_id AND a.accnt_type='master' AND a.balance<>b.tillbl;
	
	SELECT a.accnt,a.accnt_old,a.balance,b.tillbl FROM tmp_ihotel_bal a LEFT JOIN migrate_db.mstbalrep b ON a.accnt_old=b.accnt
		WHERE a.hotel_id=arg_hotel_id AND a.accnt_type='armaster' AND a.balance<>b.tillbl;
	*/
	UPDATE master_snapshot a,tmp_ihotel_bal b SET a.last_charge = b.charge,a.last_pay = b.pay,a.last_balance = b.balance 
		WHERE a.master_id = b.accnt_new AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
		AND a.biz_date_begin < arg_bdate AND a.biz_date_end >= arg_bdate AND b.accnt_type ='master' AND a.master_type IN ('master','consume');
	
 	UPDATE master_snapshot a,tmp_ihotel_bal b SET a.last_charge = b.charge,a.last_pay = b.pay,a.last_balance = b.balance 
		WHERE a.master_id = b.accnt_new AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
		AND a.biz_date_begin < arg_bdate AND a.biz_date_end >= arg_bdate AND b.accnt_type ='armaster' AND a.master_type = 'armaster';
	
	UPDATE master_snapshot SET till_charge 	= last_charge  + till_charge  WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date_begin < arg_bdate AND biz_date_end >= arg_bdate;
	UPDATE master_snapshot SET till_pay 	= last_pay 	   + till_pay 	  WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date_begin < arg_bdate AND biz_date_end >= arg_bdate;
	UPDATE master_snapshot SET till_balance = last_balance + till_balance WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date_begin < arg_bdate AND biz_date_end >= arg_bdate;

	INSERT INTO  tmp_repdai_bal(hotel_group_id,hotel_id,biz_date,classno,descript) VALUES
	(arg_hotel_group_id,arg_hotel_id,arg_bdate,'02000','宾客帐'),
	(arg_hotel_group_id,arg_hotel_id,arg_bdate,'03000','AR帐'),
	(arg_hotel_group_id,arg_hotel_id,arg_bdate,'03A','应收帐'),
	(arg_hotel_group_id,arg_hotel_id,arg_bdate,'02G','团体'),
	(arg_hotel_group_id,arg_hotel_id,arg_bdate,'02C','消费帐'),
	(arg_hotel_group_id,arg_hotel_id,arg_bdate,'02F','宾客');
	-- 宾客帐上日余额，本日余额
	SELECT IFNULL(SUM(last_balance),0),IFNULL(SUM(till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND master_type <>'armaster' AND biz_date_begin < arg_bdate AND biz_date_end >= arg_bdate;
 	UPDATE tmp_repdai_bal SET last_bl = var_amount1,till_bl = var_amount2 WHERE classno = '02000';
 	
	-- AR账上日余额，本日余额
	SELECT IFNULL(SUM(last_balance),0),IFNULL(SUM(till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND master_type = 'armaster' AND biz_date_begin < arg_bdate AND biz_date_end >= arg_bdate;
 	UPDATE tmp_repdai_bal SET last_bl = var_amount1,till_bl = var_amount2 WHERE classno = '03000';
 	
	-- 应收帐上日余额，本日余额 
	SELECT IFNULL(SUM(last_balance),0) ,IFNULL(SUM(till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND master_type = 'armaster' AND biz_date_begin < arg_bdate AND biz_date_end >= arg_bdate;
 	UPDATE tmp_repdai_bal SET last_charge = var_amount1,till_charge = var_amount2 WHERE classno = '03A';
 	
	-- 消费帐上日余额，本日余额
	SELECT IFNULL(SUM(last_balance),0) ,IFNULL(SUM(till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND master_type = 'consume' AND biz_date_begin < arg_bdate AND biz_date_end >= arg_bdate;
 	UPDATE tmp_repdai_bal SET last_charge = var_amount1,till_charge = var_amount2 WHERE classno = '02C';
    
	-- 团队上日余额，本日余额
    SELECT IFNULL(SUM(a.last_balance),0) ,IFNULL(SUM(a.till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot a ,master_base b 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.rsv_class = 'G' AND a.biz_date_begin < arg_bdate AND a.biz_date_end >= arg_bdate;
  	UPDATE tmp_repdai_bal SET last_charge = var_amount1 ,till_charge = var_amount2  WHERE classno = '02G';
	
	-- 宾客上日余额，本日余额
  	SELECT  IFNULL(SUM(last_bl),0),IFNULL(SUM(till_bl),0) INTO var_amount3,var_amount4  FROM tmp_repdai_bal 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno ='02000';
	SELECT IFNULL(SUM(last_charge),0) ,IFNULL(SUM(till_charge),0) INTO var_amount1,var_amount2 FROM tmp_repdai_bal 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno IN('02C','02G');
	UPDATE tmp_repdai_bal SET last_charge = var_amount3 - var_amount1,till_charge = var_amount4 - var_amount2 
		WHERE classno = '02F' AND hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	
	UPDATE rep_dai_history a,tmp_repdai_bal b SET a.last_bl = IFNULL(b.last_bl,0),a.till_bl = IFNULL(b.till_bl,0) 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.biz_date = b.biz_date AND a.biz_date = arg_bdate AND a.classno = b.classno;
	UPDATE rep_jiedai_history a,tmp_repdai_bal b SET a.last_charge = IFNULL(b.last_charge,0) + IFNULL(a.last_credit,0),a.till_charge = IFNULL(b.till_charge,0) + IFNULL(a.till_credit,0) 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = b.biz_date AND a.biz_date = arg_bdate AND a.classno = b.classno;
	 
	UPDATE rep_dai a,tmp_repdai_bal b  SET a.last_bl = IFNULL(b.last_bl,0),a.till_bl = IFNULL(b.till_bl,0) 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.biz_date = b.biz_date AND a.biz_date = arg_bdate AND a.classno = b.classno;
	UPDATE rep_jiedai a,tmp_repdai_bal b SET a.last_charge = IFNULL(b.last_charge,0) + IFNULL(a.last_credit,0),a.till_charge = IFNULL(b.till_charge,0) + IFNULL(a.till_credit,0) 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.biz_date = b.biz_date AND a.biz_date = arg_bdate AND a.classno = b.classno;
	
	
END$$

DELIMITER ;