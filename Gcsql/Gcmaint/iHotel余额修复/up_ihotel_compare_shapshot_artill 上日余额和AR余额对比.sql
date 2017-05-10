DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_compare_shapshot_artill`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_compare_shapshot_artill`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT
)
BEGIN 
 	-- ==================================================================
	-- 用途：用于AR余额表与AR主单上日余额对比
	-- 解释: 
	-- 范例:     
	-- 作者：张惠  2015-12-27
	-- ================================================================== 	
	DECLARE var_bdate DATETIME;
	
	SELECT DATE_ADD(set_value,INTERVAL  -1 DAY) INTO var_bdate FROM sys_option 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog = 'system' AND item = 'biz_date';
	
	DROP TEMPORARY TABLE IF EXISTS tmp_snapshot_artill;
	CREATE TEMPORARY TABLE tmp_snapshot_artill(
		biz_date	 DATETIME 		DEFAULT NULL,
		snap_accnt   BIGINT(20) 	DEFAULT NULL,
		arname	     VARCHAR(100) 	DEFAULT NULL,
		snap_bal 	 DECIMAL(12,2) 	NOT NULL DEFAULT '0.00',
		ar_accnt 	 BIGINT(20) 	DEFAULT NULL,
		ar_bal 	     DECIMAL(12,2) 	NOT NULL DEFAULT '0.00',
		till_bl 	 DECIMAL(12,2) 	NOT NULL DEFAULT '0.00',
		KEY index1 (snap_accnt),
		KEY index2 (biz_date)
	);
	
	INSERT INTO tmp_snapshot_artill(biz_date,snap_accnt,arname,snap_bal)
	SELECT var_bdate,a.master_id,a.name,a.till_balance 
	FROM master_snapshot a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.master_type = 'armaster'
	AND (a.last_balance<>0 OR a.till_balance<>0 OR a.charge_ttl<>0 OR a.pay_ttl<>0)
	AND a.biz_date_begin < var_bdate AND a.biz_date_end >= var_bdate ORDER BY a.master_id;

	UPDATE tmp_snapshot_artill a,(SELECT id,SUM(charge - pay) balance FROM ar_master_till 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id GROUP BY id) b 
		SET a.ar_accnt = b.id,a.ar_bal = b.balance WHERE a.snap_accnt = b.id AND a.biz_date=var_bdate;

	SELECT snap_accnt,arname,snap_bal,ar_bal,(snap_bal - ar_bal) AS till FROM tmp_snapshot_artill WHERE snap_bal - ar_bal <> 0 AND biz_date=var_bdate;	
		
	DROP TEMPORARY TABLE IF EXISTS tmp_snapshot_artill;
	
 END$$

DELIMITER ;