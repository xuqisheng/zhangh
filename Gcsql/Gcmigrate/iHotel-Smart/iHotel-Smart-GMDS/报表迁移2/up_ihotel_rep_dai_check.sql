DELIMITER $$

USE `portal_pms`$$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_dai_check`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `up_ihotel_rep_dai_check`(
	IN arg_hotel_group_id 	BIGINT(16),
	IN arg_hotel_id 	BIGINT(16),
	IN arg_type	 	VARCHAR(20),
	IN arg_biz_date		DATETIME
    )
    SQL SECURITY INVOKER
label_out:
BEGIN	
	
	
	
	
	DECLARE var_d1	DECIMAL(12,2);
	DECLARE var_d2	DECIMAL(12,2);
	DECLARE var_d3	DECIMAL(12,2);
	DECLARE var_d4	DECIMAL(12,2);
	DECLARE var_m1	DECIMAL(12,2);
	DECLARE var_m2	DECIMAL(12,2);
	DECLARE var_m3	DECIMAL(12,2);
	DECLARE var_m4	DECIMAL(12,2);	
	DECLARE var_r1	DECIMAL(12,2);
	DECLARE var_r2	DECIMAL(12,2);
	DECLARE var_r3	DECIMAL(12,2);
	DECLARE var_r4	DECIMAL(12,2);
	DECLARE var_i1	DECIMAL(12,2);
	DECLARE var_i2	DECIMAL(12,2);
	DECLARE var_t1	DECIMAL(12,2);
	DECLARE var_t2	DECIMAL(12,2);
	DECLARE var_t3	DECIMAL(12,2);
	DECLARE var_t4	DECIMAL(12,2);
	DECLARE var_f1	DECIMAL(12,2);
	DECLARE var_f2	DECIMAL(12,2);	
	
	IF arg_type='AR' THEN
		SELECT last_bl INTO var_d1  FROM rep_dai_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND classno='03000';
		SELECT debit   INTO var_d2  FROM rep_dai_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND classno='03000';
		SELECT credit  INTO var_d3  FROM rep_dai_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND classno='03000';
		SELECT till_bl INTO var_d4  FROM rep_dai_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND classno='03000';
		SELECT  SUM(last_balance) INTO var_m1  FROM master_snapshot    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date_begin<arg_biz_date AND biz_date_end >=arg_biz_date AND master_type='armaster';
		SELECT  SUM(charge_ttl)   INTO var_m2  FROM master_snapshot    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date_begin<arg_biz_date AND biz_date_end >=arg_biz_date AND master_type='armaster';
		SELECT  SUM(pay_ttl)      INTO var_m3  FROM master_snapshot    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date_begin<arg_biz_date AND biz_date_end >=arg_biz_date AND master_type='armaster';
		SELECT  SUM(till_balance) INTO var_m4  FROM master_snapshot    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date_begin<arg_biz_date AND biz_date_end >=arg_biz_date AND master_type='armaster';
		
		SELECT amount INTO var_t1  FROM rep_trial_balance_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND item_type='60' AND item_code='1*';
		SELECT amount INTO var_t2  FROM rep_trial_balance_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND item_type='60' AND item_code='30';
		SELECT ABS(amount) INTO var_t3  FROM rep_trial_balance_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND item_type='60' AND item_code='40';
		SELECT amount INTO var_t4  FROM rep_trial_balance_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND item_type='60' AND item_code='60';
	
	
	SELECT arg_hotel_group_id,arg_hotel_id,arg_biz_date,'repdai',var_d1,var_d2,var_d3,var_d4
	UNION 
	SELECT arg_hotel_group_id,arg_hotel_id,arg_biz_date,'snapshot',var_m1,var_m2,var_m3,var_m4
	UNION 
	SELECT arg_hotel_group_id,arg_hotel_id,arg_biz_date,'rep_trial_balance',var_t1,var_t2,var_t3,var_t4;
	ELSEIF 	arg_type = 'BK' THEN 
	
	SELECT last_bl INTO var_d1  FROM rep_dai_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND classno='02000';
	SELECT debit   INTO var_d2  FROM rep_dai_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND classno='02000';
	SELECT credit  INTO var_d3  FROM rep_dai_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND classno='02000';
	SELECT till_bl INTO var_d4  FROM rep_dai_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND classno='02000';
	SELECT  SUM(last_balance) INTO var_m1  FROM master_snapshot    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date_begin<arg_biz_date AND biz_date_end >=arg_biz_date AND master_type<>'armaster';
	SELECT  SUM(charge_ttl)   INTO var_m2  FROM master_snapshot    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date_begin<arg_biz_date AND biz_date_end >=arg_biz_date AND master_type<>'armaster';
	SELECT  SUM(pay_ttl)      INTO var_m3  FROM master_snapshot    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date_begin<arg_biz_date AND biz_date_end >=arg_biz_date AND master_type<>'armaster';
	SELECT  SUM(till_balance) INTO var_m4  FROM master_snapshot    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date_begin<arg_biz_date AND biz_date_end >=arg_biz_date AND master_type<>'armaster';
	SELECT amount INTO var_t1  FROM rep_trial_balance_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND item_type='10' AND item_code='*';
	SELECT amount   INTO var_t2  FROM rep_trial_balance_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND item_type='20' AND item_code='}}}}}';
	SELECT amount  INTO var_t3  FROM rep_trial_balance_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND item_type='40' AND item_code='}}}}}';
	SELECT amount INTO var_t4  FROM rep_trial_balance_history    WHERE hotel_group_id=arg_hotel_group_id AND  hotel_id=arg_hotel_id  AND biz_date=arg_biz_date AND item_type='50' AND item_code='10';
	
	
	
	SELECT arg_hotel_group_id,arg_hotel_id,arg_biz_date,'rep_dai',var_d1,var_d2,var_d3,var_d4
	UNION 
	SELECT arg_hotel_group_id,arg_hotel_id,arg_biz_date,'master_snapshot',var_m1,var_m2,var_m3,var_m4
	UNION
	SELECT arg_hotel_group_id,arg_hotel_id,arg_biz_date,'rep_trial_balance',var_t1,var_t2,var_t3,var_t4;
	
	END IF;
	
	
	
END$$

DELIMITER ;