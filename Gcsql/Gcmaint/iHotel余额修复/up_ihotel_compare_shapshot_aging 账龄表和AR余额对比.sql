DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_compare_shapshot_aging`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_compare_shapshot_aging`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_biz_date			DATETIME,
	IN arg_accnt			INT
)
BEGIN 
 	-- ==================================================================
	-- 用途：用于AR余额表与账龄表对比
	-- 解释: 
	-- 范例: CALL up_ihotel_compare_shapshot_aging(2,18,'2015-12-25',0) 
	--       arg_accnt 为零表示全部比较 或指定哪个AR账号
	-- 作者：张惠  2015-12-27
	-- ================================================================== 	
	
	DECLARE var_arrange	VARCHAR(10);
	
 	SET @procresult = 0 ;	
	SET var_arrange = 'ZZZZZ';

   	DROP TEMPORARY TABLE IF EXISTS tmp_arrepo_aging;
	CREATE TEMPORARY TABLE tmp_arrepo_aging(
		hotel_group_id	INT,
		hotel_id		INT,
		accnt			INT,
		arno			VARCHAR(20),
		arname			VARCHAR(50),
		amount_all		DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		snapshot_all	DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		KEY index1(hotel_group_id,hotel_id,accnt),
		KEY index2(accnt)
	);
	INSERT INTO tmp_arrepo_aging(hotel_group_id,hotel_id,accnt,arno,arname)
	SELECT a.hotel_group_id,a.hotel_id,a.id,a.arno,b.name FROM ar_master a,ar_master_guest b 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.id = b.id AND IF(arg_accnt=0,1=1,a.id=arg_accnt);
	 
	DROP TEMPORARY TABLE IF EXISTS tmp_ar_account1;
	CREATE TEMPORARY TABLE tmp_ar_account1(
		hotel_group_id	INT,
		hotel_id		INT,
		accnt			INT,
		number			INT,
 		charge			DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		charge9			DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		credit			DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		credit9			DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		ta_code			VARCHAR(10) NOT NULL DEFAULT '',
		arrange_code	VARCHAR(10) NOT NULL DEFAULT '',
		subtotal		CHAR(1),
		KEY index1 (hotel_group_id,hotel_id,accnt,ta_code,arrange_code),
		KEY index2 (hotel_group_id,hotel_id,subtotal)
	);	
		
	INSERT INTO tmp_ar_account1(hotel_group_id,hotel_id,accnt,number,charge,charge9,credit,credit9,ta_code,arrange_code,subtotal)
	SELECT a.hotel_group_id,a.hotel_id,a.ar_accnt,a.ar_inumber,a.charge - a.charge9,a.charge9,a.pay - a.credit9,a.credit9,a.ta_code,a.arrange_code,a.ar_subtotal FROM ar_detail a,tmp_arrepo_aging b,ar_account c 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
		AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND IF(arg_accnt=0,1=1,b.accnt=arg_accnt)
		AND c.gen_date < DATE_ADD(arg_biz_date,INTERVAL 1 DAY) AND a.ar_accnt = b.accnt AND a.ar_accnt = c.accnt AND a.ar_inumber = c.number;
	
	INSERT INTO tmp_ar_account1(hotel_group_id,hotel_id,accnt,number,charge,charge9,credit,credit9,ta_code,arrange_code,subtotal)
	SELECT a.hotel_group_id,a.hotel_id,a.ar_accnt,a.ar_inumber,c.charge,0,c.pay,0,a.ta_code,a.arrange_code,a.ar_subtotal 
		FROM ar_detail a,tmp_arrepo_aging b,ar_apply c,ar_account d 
		WHERE a.hotel_group_id = arg_hotel_group_id  AND a.hotel_id = arg_hotel_id AND a.ar_accnt = c.accnt AND a.ar_number = c.number AND b.hotel_group_id = arg_hotel_group_id 
		AND b.hotel_id = arg_hotel_id AND b.accnt = a.ar_accnt AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND d.number =  a.ar_inumber
		AND d.hotel_group_id = arg_hotel_group_id AND d.hotel_id = arg_hotel_id AND d.accnt = a.ar_accnt AND d.gen_date <= DATE_ADD(arg_biz_date,INTERVAL 1 DAY) AND IF(arg_accnt=0,1=1,b.accnt=arg_accnt)
		AND c.close_id IN (SELECT DISTINCT(id) FROM ar_apply WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND close_flag='B' AND biz_date > arg_biz_date) ;
 
 	DELETE FROM tmp_ar_account1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND subtotal = 'T';
	UPDATE tmp_ar_account1 a,code_transaction b SET a.arrange_code = b.arrange_code WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
		AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.ta_code = '' AND a.ta_code = b.code;
  
  	UPDATE tmp_arrepo_aging SET amount_all = IFNULL((SELECT SUM(a.charge - a.credit) FROM tmp_ar_account1 a,code_transaction b 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id 
		AND b.hotel_id = arg_hotel_id AND a.accnt = tmp_arrepo_aging.accnt AND a.ta_code = b.code AND a.arrange_code < var_arrange),0)
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
		
	-- 使用余额表更新临时表
	UPDATE tmp_arrepo_aging a,master_snapshot b SET a.snapshot_all = IFNULL(b.till_balance,0)
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id
			AND a.accnt = b.master_id AND b.master_type = 'armaster' AND b.biz_date_begin < arg_biz_date AND b.biz_date_end >= arg_biz_date;	
 
	-- 将有误的账号插入一张表中，作为另一过程参数;
	/*
	
	DROP TABLE IF EXISTS tmp_accnt;
	CREATE TABLE tmp_accnt(
		accnt			INT,
		KEY index1(accnt)
	);
	INSERT INTO tmp_accnt SELECT accnt FROM tmp_arrepo_aging 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (amount_all - snapshot_all)<>0 
			AND IF(arg_accnt=0,1=1,accnt=arg_accnt) ORDER BY accnt;			
	*/
 
  	SELECT accnt,arname,amount_all,snapshot_all,(snapshot_all - amount_all) AS balance FROM tmp_arrepo_aging 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (amount_all - snapshot_all)<>0 AND IF(arg_accnt=0,1=1,accnt=arg_accnt) ORDER BY accnt;
	
	

	
	DROP TEMPORARY TABLE IF EXISTS tmp_arrepo_aging;
 	DROP TEMPORARY TABLE IF EXISTS tmp_ar_account1;
	
 END$$

DELIMITER ;