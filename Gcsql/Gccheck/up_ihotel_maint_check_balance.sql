DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_maint_check_balance`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_maint_check_balance`(
	IN arg_hotel_group_id	INT,	-- 集团id
	IN arg_hotel_id			INT		-- 酒店id
)
    SQL SECURITY INVOKER
label_0:
BEGIN

	DECLARE var_group_name  VARCHAR(60);
	DECLARE var_hotel_name  VARCHAR(60);
	DECLARE var_group_code  VARCHAR(20);
	DECLARE var_hotel_code  VARCHAR(20);
	-- ======================================================
	-- 余额相关检查
	-- 2017.3.28
	-- ======================================================

	SELECT descript,code INTO var_group_name,var_group_code FROM hotel_group WHERE id = arg_hotel_group_id;
	SELECT descript,code INTO var_hotel_name,var_hotel_code FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id=arg_hotel_id;

	-- 余额检查结果集
  	DROP TEMPORARY TABLE IF EXISTS tmp_check_balance;
	CREATE TEMPORARY TABLE tmp_check_balance(
		check_msg			VARCHAR(1000),
		biz_date 			VARCHAR(20) DEFAULT '',
		dai_last_bl			VARCHAR(10) DEFAULT '',
		dai_till_bl			VARCHAR(10) DEFAULT '',
		snap_last_bl		VARCHAR(10) DEFAULT '',
		snap_till_bl		VARCHAR(10) DEFAULT '',
		diff_last_bl		VARCHAR(10) DEFAULT '',
		diff_till_bl		VARCHAR(10) DEFAULT '',
		KEY index1(biz_date)
	);

	INSERT INTO tmp_check_balance(check_msg) SELECT CONCAT('检查日期：',DATE(NOW()),' 酒店 : ',var_hotel_code,' & ',var_hotel_name,' 集团 : ',var_group_code,' & ',var_group_name);
	INSERT INTO tmp_check_balance(check_msg) SELECT GROUP_CONCAT('\n---------------------------------------------------------------------');
    INSERT INTO tmp_check_balance(check_msg) SELECT '底表余额和快照表余额不一致';
	-- 检查底表余额和快照表余额不一致
	INSERT INTO tmp_check_balance
	SELECT
		'优先级 A : rep_dai_history & master_snapshot', 
		DATE(a.biz_date) biz_date,
		IFNULL(SUM(a.last_bl),0) rep_dai_last_bl,
		IFNULL(SUM(a.till_bl),0) rep_dai_till_bl,

		(SELECT IFNULL(SUM(b.last_charge - b.last_pay),0) FROM master_snapshot b WHERE b.hotel_group_id=a.hotel_group_id AND b.hotel_id=a.hotel_id  AND b.biz_date_end>=a.biz_date AND b.biz_date_begin<a.biz_date)
		AS snapshot_last_bl,
		(SELECT IFNULL(SUM(b.till_charge - b.till_pay),0) FROM master_snapshot b WHERE b.hotel_group_id=a.hotel_group_id AND b.hotel_id=a.hotel_id  AND b.biz_date_begin < a.biz_date AND b.biz_date_end >=a.biz_date)
		AS snapshot_till_bl,

		IFNULL(SUM(a.last_bl),0) 
		- 
		(SELECT IFNULL(SUM(b.last_charge - b.last_pay),0) FROM master_snapshot b WHERE b.hotel_group_id=a.hotel_group_id AND b.hotel_id=a.hotel_id  AND b.biz_date_end>=a.biz_date AND b.biz_date_begin<a.biz_date)
		AS diff_last_bl,

		IFNULL(SUM(a.till_bl),0) 
		- 
		(SELECT IFNULL(SUM(b.till_charge - b.till_pay),0) FROM master_snapshot b WHERE b.hotel_group_id=a.hotel_group_id AND b.hotel_id=a.hotel_id  AND b.biz_date_begin < a.biz_date AND b.biz_date_end >=a.biz_date)
		AS diff_till_bl

		FROM rep_dai_history a
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND (a.classno='02000' OR a.classno='03000') AND a.biz_date>=(SELECT SUBDATE(biz_date,30) FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id)
		GROUP BY a.biz_date
		HAVING diff_last_bl <> 0 OR diff_till_bl <> 0
		ORDER BY a.biz_date;

	INSERT INTO tmp_check_balance(check_msg) SELECT '底表的本日发生收回和快照表不一致';
	-- 检查底表的本日发生收回是否和快照表一致
	INSERT INTO tmp_check_balance
	SELECT 
		'优先级 A : rep_dai_history & master_snapshot',	
		DATE(a.biz_date) biz_date,
		IFNULL(SUM(a.debit),0) rep_dai_debit,

		IFNULL(SUM(a.credit),0) rep_dai_credit,

		(SELECT IFNULL(SUM(b.charge_ttl),0) FROM master_snapshot b WHERE b.hotel_group_id=a.hotel_group_id AND b.hotel_id=a.hotel_id AND b.biz_date_begin = a.biz_date - INTERVAL 1 DAY) AS snapshot_charge,

		(SELECT IFNULL(SUM(b.pay_ttl),0) FROM master_snapshot b WHERE b.hotel_group_id=a.hotel_group_id AND b.hotel_id=a.hotel_id AND b.biz_date_begin = a.biz_date - INTERVAL 1 DAY ) AS snapshot_pay,

		IFNULL(SUM(a.debit),0) - 
		(SELECT IFNULL(SUM(b.charge_ttl),0) FROM master_snapshot b WHERE b.hotel_group_id=a.hotel_group_id AND b.hotel_id=a.hotel_id AND b.biz_date_begin = a.biz_date - INTERVAL 1 DAY)
		AS diff_debit_charge,

		IFNULL(SUM(a.credit),0) - 
		(SELECT IFNULL(SUM(b.pay_ttl),0) FROM master_snapshot b WHERE b.hotel_group_id=a.hotel_group_id AND b.hotel_id=a.hotel_id AND b.biz_date_begin = a.biz_date - INTERVAL 1 DAY )
		AS diff_credit_pay

		FROM rep_dai_history a
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND (a.classno='02000' OR a.classno='03000') AND a.biz_date>=(SELECT SUBDATE(biz_date,30) FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id)
		GROUP BY a.biz_date
		HAVING diff_debit_charge <> 0 OR diff_credit_pay <> 0
		ORDER BY a.biz_date;

		INSERT INTO tmp_check_balance(check_msg) SELECT '检查底表余额是否连贯';
		-- 检查底表余额是否连贯
		INSERT INTO tmp_check_balance(check_msg,biz_date,dai_till_bl,snap_till_bl,diff_till_bl)
		SELECT 
			'优先级 A :rep_dai_history',
			DATE(a.biz_date) biz_date,
			IFNULL(SUM(a.last_bl),0) AS lastbl_of_thisday,
			(SELECT IFNULL(SUM(b.till_bl),0) FROM rep_dai_history b WHERE b.hotel_group_id=a.hotel_group_id AND b.hotel_id=a.hotel_id AND (b.classno='02000' OR b.classno='03000') AND b.biz_date=ADDDATE(a.biz_date,-1))
			AS tillbl_of_lastday,

			IFNULL(SUM(a.last_bl),0) - 
			(SELECT IFNULL(SUM(b.till_bl),0) FROM rep_dai_history b WHERE b.hotel_group_id=a.hotel_group_id AND b.hotel_id=a.hotel_id AND (b.classno='02000' OR b.classno='03000') AND b.biz_date=ADDDATE(a.biz_date,-1))
			AS diff_2balances

			FROM rep_dai_history a
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND (a.classno='02000' OR a.classno='03000') AND a.biz_date>=(SELECT SUBDATE(biz_date,30) FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id)
			GROUP BY a.biz_date
			HAVING diff_2balances <> 0
			ORDER BY a.biz_date;

	INSERT INTO tmp_check_balance(check_msg) SELECT '本日余额=上日余额+本日发生-本日收回 不成立';
	-- 检查 本日余额=上日余额+本日发生-本日收回
	INSERT INTO tmp_check_balance
	SELECT 
			'优先级 A :rep_dai_history',
			DATE(a.biz_date) biz_date,
			IFNULL(SUM(last_bl),0) AS lastbl,
			IFNULL(SUM(debit ),0)  AS debit,
			IFNULL(SUM(credit),0)  AS credit,
			IFNULL(SUM(last_bl+debit-credit),0)  AS computed_tillbl,
			IFNULL(SUM(till_bl),0) AS tillbl,
			IFNULL(SUM(last_bl+debit-credit-till_bl),0) AS diff
			FROM rep_dai_history a
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND (a.classno='02000' OR a.classno='03000') AND a.biz_date>=(SELECT SUBDATE(biz_date,30) FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id)
			GROUP BY a.biz_date
			HAVING diff <> 0
			ORDER BY a.biz_date;


	INSERT INTO tmp_check_balance(check_msg) SELECT '上日余额和实际余额不一致';
	-- 检查快照表的上日余额是否和实际余额一致
	INSERT INTO tmp_check_balance(check_msg,biz_date,dai_till_bl,snap_till_bl,diff_till_bl)
	SELECT CONCAT('优先级 A :宾客余额 帐号: ',a.master_id,' 名字: ',a.name),
		a.biz_date_begin,a.till_balance,(b.charge-b.pay) AS master_balance,a.till_balance - (b.charge-b.pay) AS diff FROM master_snapshot a,master_base_till b 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date_begin<(SELECT SUBDATE(biz_date,1) FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id) AND a.biz_date_end>=(SELECT SUBDATE(biz_date,1) FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id) 
		AND a.master_type<>'armaster' AND a.master_id=b.id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.till_balance<>b.charge-b.pay;

	INSERT INTO tmp_check_balance(check_msg,biz_date,dai_till_bl,snap_till_bl,diff_till_bl)
	SELECT CONCAT('优先级 A :应收余额 帐号: ',a.master_id,' 名字: ',a.name),
		a.biz_date_begin,a.till_balance,(b.charge-b.pay) AS master_balance,a.till_balance - (b.charge-b.pay) AS diff FROM master_snapshot a,master_base_till b 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date_begin<(SELECT SUBDATE(biz_date,1) FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id) AND a.biz_date_end>=(SELECT SUBDATE(biz_date,1) FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id) 
		AND a.master_type<>'armaster' AND a.master_id=b.id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.till_balance<>b.charge-b.pay;

	INSERT INTO tmp_check_balance(check_msg) SELECT GROUP_CONCAT('\n---------------------------------------------------------------------');
	INSERT INTO tmp_check_balance(check_msg) SELECT '检查结束...';

	IF EXISTS (SELECT 1 FROM tmp_check_balance) THEN
		SELECT * FROM tmp_check_balance;
	END IF;

 	DROP TEMPORARY TABLE IF EXISTS tmp_check_balance;

END$$

DELIMITER ;

-- CALL up_ihotel_maint_check_balance(2,9);

-- DROP PROCEDURE IF EXISTS `up_ihotel_maint_check_balance`;