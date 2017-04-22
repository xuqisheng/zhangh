DELIMITER $$

USE `portal`$$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_ar_classlist`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_ar_classlist`(
	IN arg_hotel_group_id   INT,
	IN arg_hotel_id         INT,
	IN arg_date_begin		DATETIME,
	IN arg_date_end			DATETIME
	)
    SQL SECURITY INVOKER
label_0:
BEGIN
 	-- =======================================================================================
	-- 用途：AR账明细数据，与底表借贷保持一致(但与真实账户会存在出入，因为存在转账、核销等存在)
	-- 解释: 
	-- 范例: 
	-- 作者：
	-- ========================================================================================                                                              	
	DROP TEMPORARY TABLE IF EXISTS tmp_ar_classlist;
	CREATE TEMPORARY TABLE tmp_ar_classlist
	(
		hotel_group_id		INT,
		hotel_id			INT,
		ar_accnt   			INT NOT NULL,
		ar_name				VARCHAR(50) NOT NULL DEFAULT '',
		close_id			INT NOT NULL,
		biz_date  			DATETIME,
		ta_code   			VARCHAR(10) NOT NULL,
		ta_descript 		VARCHAR(60) NOT NULL,
		charge     			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		pay        			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		accnt   			INT NOT NULL,			
		rmno        		VARCHAR(10) NOT NULL DEFAULT '',
		accnt_type			VARCHAR(10) NOT NULL DEFAULT '',
		KEY index1 (hotel_group_id,hotel_id,ar_accnt),
		KEY index2 (hotel_group_id,hotel_id,accnt_type),
		KEY index3 (hotel_group_id,hotel_id,close_id)
	);	
	-- 分摊表里取数
	INSERT INTO tmp_ar_classlist(hotel_group_id,hotel_id,ar_accnt,ar_name,close_id,biz_date,ta_code,ta_descript,charge,pay,accnt,rmno,accnt_type)
		SELECT hotel_group_id,hotel_id,0,'',close_id,biz_date,ta_code1,ta_descript1,apportion_amount,0,accnt1,'',''
			FROM apportion_detail_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date >= arg_date_begin AND biz_date <= arg_date_end AND ta_code2 IN (SELECT CODE FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting='TA');
	
	UPDATE tmp_ar_classlist a,account b SET a.ar_accnt=b.trans_accnt,a.accnt_type='A' WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
		AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.close_id=b.close_id 
			AND b.ta_code IN (SELECT CODE FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting='TA');		
	UPDATE tmp_ar_classlist a,account_history b SET a.ar_accnt=b.trans_accnt,a.accnt_type='B' WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
		AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.close_id=b.close_id AND a.accnt_type=''
			AND b.ta_code IN (SELECT CODE FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting='TA');
	UPDATE tmp_ar_classlist a,pos_dish b SET a.ar_accnt=b.accnt,a.accnt_type='C' WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
		AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.close_id=CONVERT(b.menu_id, CHAR(20)) AND a.accnt_type=''
			AND b.code IN (SELECT CODE FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting='TA');				
	
	UPDATE tmp_ar_classlist a,master_base b SET a.rmno = b.rmno WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
		AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.accnt=b.id AND a.accnt_type='A';
	UPDATE tmp_ar_classlist a,master_base_history b SET a.rmno = b.rmno WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
		AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.accnt=b.id AND a.accnt_type='B';
		
	-- AR账入账取数	
	INSERT INTO tmp_ar_classlist(hotel_group_id,hotel_id,ar_accnt,ar_name,close_id,biz_date,ta_code,ta_descript,charge,pay,accnt,rmno,accnt_type)		
		SELECT hotel_group_id,hotel_id,ar_accnt,'',0,biz_date,ta_code,ta_descript,charge,pay,accnt,rmno,'D'
			FROM ar_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND ar_tag='A' AND ar_subtotal='F' 
			AND biz_date >= arg_date_begin AND biz_date <= arg_date_end;

	UPDATE tmp_ar_classlist a,ar_master_guest b SET a.ar_name = b.name
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.ar_accnt=b.id;				
	SELECT ar_accnt,ar_name,biz_date,ta_descript,SUM(charge) AS charge,SUM(pay) AS pay,rmno
		FROM tmp_ar_classlist GROUP BY ar_accnt,biz_date,ta_code ORDER BY ar_accnt,biz_date,ta_code;
	
	DROP TEMPORARY TABLE IF EXISTS tmp_ar_classlist;
	
END$$

DELIMITER ;