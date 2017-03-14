DELIMITER $$
SET sql_notes = 0$$
DROP PROCEDURE IF EXISTS `up_ihotel_room_status_room_revenue`$$
CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_room_status_room_revenue`(
	IN arg_hotel_group_id		INT,		-- 集团ID
	IN arg_hotel_id			INT,		-- 酒店ID
	IN arg_date			DATE,		-- 日期
	IN arg_rmtypes			VARCHAR(255),	-- 房类
	IN arg_action			INT,		-- 0：统计 1\2\3：穿透
	IN arg_seq			VARCHAR(50),	-- 请求序列标识（避免公共临时表重复初始化）
	OUT arg_result1			VARCHAR(10),	-- 统计结果1
	OUT arg_result2			VARCHAR(10),	-- 统计结果2
	OUT arg_result3			VARCHAR(10),	-- 统计结果3
	OUT arg_result_table		VARCHAR(50)	-- 穿透查询临时表名称
)
SQL SECURITY INVOKER # added by mode utility
label_0:
BEGIN
	-- ---------------------------------------------------------------
	-- 实时房情统计指标 >> 预计客房收入
	-- ---------------------------------------------------------------
	
	DECLARE rmtype_amount INT DEFAULT 0;
	DECLARE done_cursor INT DEFAULT 0;
	DECLARE use_daily_rsv_rate VARCHAR(20) DEFAULT 'T';
	
	SET arg_result1 = '0';
	SET arg_result2 = '0';
	SET arg_result3 = '0';
	SET arg_result_table = '';
	
	IF arg_rmtypes IS NOT NULL AND TRIM(arg_rmtypes) != '' THEN
		SET rmtype_amount = 1 + (LENGTH(arg_rmtypes) - LENGTH(REPLACE(arg_rmtypes, ',', '')));
	END IF;
	
	CREATE TEMPORARY TABLE IF NOT EXISTS seq_temp (
		seq VARCHAR(50)
	);
	
	CREATE TEMPORARY TABLE IF NOT EXISTS rmtypes_temp (
		code VARCHAR(10)
	);
	
	IF arg_seq IS NULL OR TRIM(arg_seq) = '' OR NOT EXISTS(SELECT 1 FROM seq_temp WHERE seq = arg_seq) THEN
		IF arg_seq IS NOT NULL AND TRIM(arg_seq) != '' THEN
			TRUNCATE TABLE seq_temp;
			
			INSERT INTO seq_temp(seq) VALUES (arg_seq);
		END IF;
		
		TRUNCATE TABLE rmtypes_temp;
		
		WHILE done_cursor < rmtype_amount DO
			SET done_cursor = done_cursor + 1;
			INSERT INTO rmtypes_temp(code) VALUES (REVERSE(SUBSTRING_INDEX(REVERSE(SUBSTRING_INDEX(arg_rmtypes,',',done_cursor)),',',1)));
		END WHILE;
	END IF;
	
	SELECT set_value INTO use_daily_rsv_rate FROM sys_option WHERE catalog = 'system' AND item = 'use_daily_rsv_rate' AND hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	IF use_daily_rsv_rate = 'T' THEN
		SELECT IFNULL(SUM(IFNULL(f.real_share_rate,c.real_rate) * c.rmnum),0) INTO arg_result1
		FROM master_base a 
		JOIN rsv_src c ON c.accnt = a.id AND c.occ_flag IN ('RF','RG') AND c.arr_date <= arg_date AND c.dep_date > arg_date AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id
		LEFT JOIN rsv_rate f ON f.master_id = a.id AND f.rsv_src_id = c.id AND f.rsv_date = arg_date AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id 
		WHERE a.is_resrv = 'T' AND a.rsv_class IN ('F','G') AND a.sta IN ('R','I') AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
		AND (rmtype_amount = 0 OR a.rmtype IN (SELECT CODE FROM rmtypes_temp));
		
		SELECT arg_result1 + IFNULL(SUM(IFNULL(f.real_share_rate,a.real_rate)),0) INTO arg_result1
		FROM master_base a 
		JOIN rsv_src c ON c.accnt = a.id AND c.occ_flag = 'MF' AND c.arr_date <= arg_date AND c.dep_date > arg_date AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id
		LEFT JOIN rsv_rate f ON f.master_id = a.id AND f.rsv_src_id = c.id AND f.rsv_date = arg_date AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id 		
		WHERE a.is_resrv = 'F' AND a.rsv_class IN ('F','D') AND a.sta IN ('R','I') AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
		AND (rmtype_amount = 0 OR a.rmtype IN (SELECT CODE FROM rmtypes_temp));
	ELSE
		SELECT IFNULL(SUM(c.real_rate * c.rmnum),0) INTO arg_result1
		FROM master_base a 
		JOIN rsv_src c ON c.accnt = a.id AND c.occ_flag IN ('RF','RG') AND c.arr_date <= arg_date AND c.dep_date > arg_date AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id
		WHERE a.is_resrv = 'T' AND a.rsv_class IN ('F','G') AND a.sta IN ('R','I') AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
		AND (rmtype_amount = 0 OR a.rmtype IN (SELECT CODE FROM rmtypes_temp));
		
		SELECT arg_result1 + IFNULL(SUM(a.real_rate),0) INTO arg_result1
		FROM master_base a 
		WHERE a.is_resrv = 'F' AND a.rsv_class IN ('F','D') AND a.sta IN ('R','I') AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
		AND (rmtype_amount = 0 OR a.rmtype IN (SELECT CODE FROM rmtypes_temp));
	END IF;
	
	BEGIN
		LEAVE label_0;
	END;
END$$
DELIMITER ;