DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_bal_maint_smart`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_bal_maint_smart`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT
)
    SQL SECURITY INVOKER
label_0:
   /*================================
   1.以数据导入实际余额修复余额表
   2.西软系统夜审后开始数据迁移
   3.此步骤在iHotel第一个夜审后使用
   ================================*/
BEGIN
 	DECLARE var_bdate		DATETIME;
	DECLARE var_bdate1		DATETIME;
	DECLARE var_bdate2		DATETIME;
	DECLARE var_amount		DECIMAL(12,2); 
	DECLARE var_amount1		DECIMAL(12,2); 
	DECLARE var_amount2		DECIMAL(12,2); 
	DECLARE var_amount3		DECIMAL(12,2); 
	DECLARE var_amount4		DECIMAL(12,2); 	 
	 
	DROP TABLE IF EXISTS tmp_dairep_bal;
	CREATE TABLE  tmp_dairep_bal (
		hotel_group_id  INT,
		hotel_id	 	INT,
		biz_date		DATETIME,
		classno			VARCHAR(10),
		descript		VARCHAR(20),
		last_bl			DECIMAL(20,2) NOT NULL DEFAULT '0.00',
		till_bl			DECIMAL(20,2) NOT NULL DEFAULT '0.00',
		last_charge		DECIMAL(20,2) NOT NULL DEFAULT '0.00',
		till_charge		DECIMAL(20,2) NOT NULL DEFAULT '0.00',
		KEY index1 (hotel_group_id,hotel_id,classno)
	);
	
	DROP TABLE IF EXISTS tmp_master_bal;
	CREATE TABLE tmp_master_bal(
		hotel_group_id  INT,
		hotel_id 		INT,
		accnt_type 		VARCHAR(10) DEFAULT NULL,
		accnt 			BIGINT(20) DEFAULT NULL,
		balance 		DECIMAL(12,2) DEFAULT NULL,
		accnt_old 		VARCHAR(10) DEFAULT NULL,
		KEY index1 (hotel_group_id,hotel_id,accnt_type,accnt)
	) ENGINE=INNODB DEFAULT CHARSET=utf8;
	
	SELECT ADDDATE(biz_date,-1) INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	
	DELETE FROM tmp_master_bal WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	-- 前台部分(master)
	INSERT INTO tmp_master_bal
	SELECT arg_hotel_group_id,arg_hotel_id,'master',a.accnt,SUM(a.charge-a.pay),'' FROM account a 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date <= var_bdate GROUP BY a.accnt;

	-- AR部分(armaster)
	INSERT INTO tmp_master_bal
	SELECT arg_hotel_group_id,arg_hotel_id,'armaster',a.id, SUM(a.charge-a.pay),'' FROM ar_master_till a 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id GROUP BY a.id;
		
	UPDATE master_snapshot SET till_balance=0 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND sta IN ('O','N','X','D') AND till_balance<>0;
	
	UPDATE master_snapshot b ,tmp_master_bal a SET b.till_balance =  a.balance WHERE a.accnt = b.master_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
		AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.biz_date_begin < var_bdate AND b.biz_date_end >= var_bdate AND
		a.accnt_type ='master' AND b.master_type IN('master','consume') AND b.sta <>'O';
 	UPDATE master_snapshot b ,tmp_master_bal a SET b.till_balance =  a.balance WHERE a.accnt = b.master_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
		AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.biz_date_begin < var_bdate AND b.biz_date_end >= var_bdate AND
		a.accnt_type ='armaster' AND b.master_type ='armaster' AND b.sta <>'O';

	UPDATE master_snapshot SET last_balance = till_balance -charge_ttl + pay_ttl WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date_begin < var_bdate AND  biz_date_end >= var_bdate; 
	
	INSERT INTO  tmp_dairep_bal(hotel_group_id,hotel_id,biz_date,classno,descript) 
	VALUES
		(arg_hotel_group_id,arg_hotel_id,var_bdate,'02000','宾客帐'),
		(arg_hotel_group_id,arg_hotel_id,var_bdate,'03000','AR帐'),
		(arg_hotel_group_id,arg_hotel_id,var_bdate,'03A','应收帐'),
		(arg_hotel_group_id,arg_hotel_id,var_bdate,'02G','团体'),
		(arg_hotel_group_id,arg_hotel_id,var_bdate,'02C','消费帐'),
		(arg_hotel_group_id,arg_hotel_id,var_bdate,'02F','宾客');
	-- 宾客帐上日余额，本日余额
	SELECT IFNULL(SUM(last_balance),0) ,IFNULL(SUM(till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot WHERE hotel_id = arg_hotel_id AND hotel_group_id = arg_hotel_group_id
		AND master_type <>'armaster' AND biz_date_begin < var_bdate AND biz_date_end >= var_bdate;
 	UPDATE tmp_dairep_bal SET last_bl = var_amount1,till_bl = var_amount2 WHERE classno = '02000';
 	-- AR账上日余额，本日余额
	SELECT IFNULL(SUM(last_balance),0) ,IFNULL(SUM(till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot WHERE hotel_id = arg_hotel_id AND hotel_group_id = arg_hotel_group_id
		AND master_type = 'armaster' AND biz_date_begin < var_bdate AND biz_date_end >= var_bdate;
 	UPDATE tmp_dairep_bal SET last_bl = var_amount1,till_bl = var_amount2 WHERE classno = '03000';
 	-- 应收帐上日余额，本日余额 
	SELECT IFNULL(SUM(last_balance),0) ,IFNULL(SUM(till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot WHERE hotel_id = arg_hotel_id AND hotel_group_id = arg_hotel_group_id
		AND master_type = 'armaster' AND biz_date_begin < var_bdate AND biz_date_end >= var_bdate;
 	UPDATE tmp_dairep_bal SET last_charge = var_amount1,till_charge = var_amount2 WHERE classno = '03A';
 	-- 消费帐上日余额，本日余额
	SELECT IFNULL(SUM(last_balance),0) ,IFNULL(SUM(till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot WHERE hotel_id = arg_hotel_id AND hotel_group_id = arg_hotel_group_id
		AND master_type = 'consume' AND biz_date_begin < var_bdate AND biz_date_end >= var_bdate;
 	UPDATE tmp_dairep_bal SET last_charge = var_amount1,till_charge = var_amount2 WHERE classno = '02C';
        -- 团队上日余额，本日余额
    SELECT IFNULL(SUM(a.last_balance),0) ,IFNULL(SUM(a.till_balance),0) INTO var_amount1,var_amount2 FROM master_snapshot a ,master_base b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
		AND a.hotel_id = b.hotel_id AND a.master_id = b.id AND b.rsv_class = 'G' AND a.biz_date_begin < var_bdate AND a.biz_date_end >= var_bdate;
  	UPDATE tmp_dairep_bal SET last_charge = var_amount1 ,till_charge = var_amount2  WHERE classno = '02G';
	-- 宾客上日余额，本日余额
  	SELECT  IFNULL(SUM(last_bl),0),IFNULL(SUM(till_bl),0) INTO var_amount3,var_amount4 FROM tmp_dairep_bal WHERE hotel_id = arg_hotel_id AND hotel_group_id = arg_hotel_group_id AND classno ='02000';
	SELECT IFNULL(SUM(last_charge),0) ,IFNULL(SUM(till_charge),0) INTO var_amount1,var_amount2 FROM tmp_dairep_bal WHERE hotel_id = arg_hotel_id AND hotel_group_id = arg_hotel_group_id AND classno IN('02C','02G');
	UPDATE  tmp_dairep_bal SET last_charge = var_amount3 - var_amount1,till_charge = var_amount4 - var_amount2 WHERE classno = '02F' AND hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	
	UPDATE rep_dai_history a,tmp_dairep_bal b  SET a.last_bl = IFNULL(b.last_bl,0),a.till_bl = IFNULL(b.till_bl,0) WHERE a.hotel_group_id = b.hotel_group_id AND
	a.hotel_id = b.hotel_id  AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = b.biz_date AND a.biz_date = var_bdate AND a.classno = b.classno;
	UPDATE rep_jiedai_history a,tmp_dairep_bal b SET a.last_charge = IFNULL(b.last_charge,0) + IFNULL(a.last_credit,0),a.till_charge = IFNULL(b.till_charge,0) + IFNULL(a.till_credit,0) WHERE a.hotel_group_id = b.hotel_group_id AND	
	a.hotel_id = b.hotel_id  AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = b.biz_date AND a.biz_date = var_bdate AND a.classno = b.classno;
	 
	UPDATE rep_dai a,tmp_dairep_bal b  SET a.last_bl = IFNULL(b.last_bl,0),a.till_bl = IFNULL(b.till_bl,0) WHERE a.hotel_group_id = b.hotel_group_id AND
	a.hotel_id = b.hotel_id  AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = b.biz_date AND a.biz_date = var_bdate AND a.classno = b.classno;
	UPDATE rep_jiedai a,tmp_dairep_bal b SET a.last_charge = IFNULL(b.last_charge,0) + IFNULL(a.last_credit,0),a.till_charge = IFNULL(b.till_charge,0) + IFNULL(a.till_credit,0) WHERE a.hotel_group_id = b.hotel_group_id AND	
	a.hotel_id = b.hotel_id  AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = b.biz_date AND a.biz_date = var_bdate AND a.classno = b.classno;
	
END$$

DELIMITER ;