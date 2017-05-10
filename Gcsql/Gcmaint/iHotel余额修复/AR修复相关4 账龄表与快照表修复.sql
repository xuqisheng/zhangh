DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_maint_snapshot_ageing`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_maint_snapshot_ageing`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_biz_date			DATETIME,
	IN arg_ar_accnt			INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==================================================================
	-- 用途：用于账龄表的修复,此过程为方法一	
	-- 解释: 
	-- 范例: 
	-- 作者：
	-- ==================================================================
	/*
		-- 此SQL为方法二
		-- 用于检查ar_account与ar_detail数据不一致问题，解决AR账龄表与余额不一致问题
		-- 检查指定账号
		SELECT a.accnt,a.number,DATE(a.gen_date),a.biz_date,(a.charge+a.charge0) AS charge,(a.pay+a.pay0) AS pay,a.charge9,a.pay9,b.ar_accnt,b.charge,b.pay,b.charge9,b.credit9 
		FROM ar_account a 
		LEFT JOIN (SELECT ar_accnt,ar_inumber,SUM(charge) charge,SUM(pay) pay,SUM(charge9) charge9,SUM(credit9) credit9 FROM ar_detail WHERE 
		hotel_group_id = 2 AND hotel_id = 9 AND ar_subtotal = 'F' GROUP BY ar_accnt,ar_inumber) b ON b.ar_accnt = a.accnt AND b.ar_inumber = a.number
		 WHERE a.hotel_group_id = 2 AND a.hotel_id = 9 AND a.act_tag<>'A' AND a.accnt=358 
		 AND ((a.charge+a.charge0)<>b.charge OR a.charge9<>b.charge9 OR (a.pay+a.pay0)<>b.pay OR a.pay9<>b.credit9);

		-- 检查整个 
		SELECT a.hotel_id,a.accnt,a.number,DATE(a.gen_date),a.biz_date,(a.charge+a.charge0) AS charge,(a.pay+a.pay0) AS pay,a.charge9,a.pay9,b.ar_accnt,b.charge,b.pay,b.charge9,b.credit9 
		FROM ar_account a 
		LEFT JOIN (SELECT ar_accnt,ar_inumber,SUM(charge) charge,SUM(pay) pay,SUM(charge9) charge9,SUM(credit9) credit9 FROM ar_detail WHERE 
		hotel_group_id = 1 AND hotel_id = 102 AND ar_subtotal = 'F' GROUP BY ar_accnt,ar_inumber) b ON b.ar_accnt = a.accnt AND b.ar_inumber = a.number
		 WHERE a.hotel_group_id = 1 AND a.hotel_id = 102 AND a.act_tag<>'A' 
		 AND ((a.charge+a.charge0)<>b.charge OR a.charge9<>b.charge9 OR (a.pay+a.pay0)<>b.pay OR a.pay9<>b.credit9)
		 GROUP BY a.accnt 
	*/
	
	DECLARE done_cursor 		INT DEFAULT 0;
	DECLARE var_ar_inumber		INT;
	DECLARE var_charge			DECIMAL(12,2);
	DECLARE var_pay				DECIMAL(12,2);
	
	DECLARE c_cursor CURSOR FOR
		SELECT ar_inumber,SUM(charge) AS charge,SUM(pay) AS pay FROM
			temp_snapshot_ageing GROUP BY ar_inumber HAVING (charge-pay)<>0;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;			
	
	DROP TEMPORARY TABLE IF EXISTS temp_snapshot_ageing;
	CREATE TEMPORARY TABLE temp_snapshot_ageing(
		ar_accnt		INT,
		ar_inumber		INT,
		charge			DECIMAL(12,2),
		pay				DECIMAL(12,2),
		KEY index1(ar_inumber,ar_accnt)
	);
		
	INSERT INTO temp_snapshot_ageing
		SELECT a.ar_accnt,a.ar_inumber,(a.charge - a.charge9) AS charge,(a.pay - a.credit9) AS pay 
		FROM ar_detail a,ar_account c 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
			AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id 
			AND c.gen_date < DATE_ADD(arg_biz_date,INTERVAL 1 DAY) AND a.ar_accnt = c.accnt 
			AND a.ar_inumber = c.number AND ((a.charge - a.charge9)<>0 OR (a.pay - a.credit9)<>0)
			AND a.ar_accnt=arg_ar_accnt AND NOT (c.charge+c.charge0<>c.charge9 OR (c.pay+c.pay0)<>c.pay9);
	
	OPEN c_cursor ;
	SET done_cursor = 0 ;
	FETCH c_cursor INTO var_ar_inumber,var_charge,var_pay; 
	
	WHILE done_cursor = 0 DO
		BEGIN
			UPDATE ar_detail SET charge9 = charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND ar_accnt = arg_ar_accnt AND ar_inumber = var_ar_inumber AND charge<>0;

			UPDATE ar_detail SET credit9 = pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND ar_accnt = arg_ar_accnt AND ar_inumber = var_ar_inumber AND pay<>0;		
								
		SET done_cursor = 0 ;
		FETCH c_cursor INTO var_ar_inumber,var_charge,var_pay;  
		END ;
	END WHILE ;
	CLOSE c_cursor ;
	
	DROP TEMPORARY TABLE IF EXISTS temp_snapshot_ageing;
	
END$$

DELIMITER ;

-- CALL up_ihotel_maint_snapshot_ageing(2,18,'2015-11-30',11718);

-- DROP PROCEDURE IF EXISTS `up_ihotel_maint_snapshot_ageing`;