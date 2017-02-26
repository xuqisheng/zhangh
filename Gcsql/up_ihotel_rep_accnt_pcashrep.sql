DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_accnt_pcashrep`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_accnt_pcashrep`(
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
	-- 用途:现金汇总表 权责发生制
	-- 解释:
	-- 作者:张惠 2015-05-13
	-- =============================================================================
	DECLARE done_cursor INT DEFAULT 0;
	DECLARE var_count 	INT;
	DECLARE var_code	VARCHAR(10);
	DECLARE var_number	CHAR(1);
	DECLARE var_tor		VARCHAR(10);

	-- DECLARE c_cursor CURSOR FOR SELECT code FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code='payment_category' ORDER BY code;

	DECLARE c_cursor CURSOR FOR SELECT ta_class FROM tmp_accnt_daycred WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY ta_class ORDER BY ta_class;	

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	

	
END$$

DELIMITER ;