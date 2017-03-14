DELIMITER $$
SET sql_notes = 0$$
DROP PROCEDURE IF EXISTS `up_ihotel_room_status_dirty_room`$$
CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_room_status_dirty_room`(
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
	-- 实时房情统计指标 >> 脏房
	-- ---------------------------------------------------------------
	
	DECLARE rmtype_amount INT DEFAULT 0;
	DECLARE done_cursor INT DEFAULT 0;
	DECLARE var_biz_date DATE;
	
	SET arg_result1 = '0';
	SET arg_result2 = '0';
	SET arg_result3 = '0';
	SET arg_result_table = 'room_status_dirty_room_temp';
	
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
	
	SELECT DATE(set_value) INTO var_biz_date FROM sys_option WHERE catalog = 'system' AND item = 'biz_date' AND hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	IF arg_date = var_biz_date THEN
		SELECT SUM(c.sta_occ = 'O'), SUM(c.sta_occ = 'V') INTO arg_result1, arg_result2
		FROM room_no b
		JOIN room_sta c ON c.rmno = b.code AND c.sta = 'D' AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id 
		WHERE b.is_villa <> 'B' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
		AND (rmtype_amount = 0 OR b.rmtype IN (SELECT code FROM rmtypes_temp));
	END IF;
	
	IF arg_action <> 0 THEN
		CREATE TEMPORARY TABLE IF NOT EXISTS room_status_dirty_room_temp (
			rmtype VARCHAR(10) DEFAULT NULL,
			rmclass VARCHAR(10) DEFAULT NULL,
			rmno VARCHAR(10) DEFAULT NULL,
			rmnoSon VARCHAR(10) DEFAULT NULL,
			sta CHAR(2) DEFAULT NULL,
			building VARCHAR(10) DEFAULT NULL,
			floor VARCHAR(10) DEFAULT NULL,
			staTmp VARCHAR(50) DEFAULT NULL,
			remark VARCHAR(255) DEFAULT NULL
		);

		TRUNCATE TABLE room_status_dirty_room_temp;
	END IF;
	
	IF arg_date = var_biz_date THEN
		IF arg_action = 1 THEN
			INSERT INTO room_status_dirty_room_temp(rmtype, rmclass, rmno, rmnoSon, sta, building, floor, staTmp, remark)
			SELECT b.rmtype,b.rmclass,b.code,'',c.sta,b.building,b.floor,IFNULL(g.descript,IFNULL(c.sta_tmp,'')),IFNULL(f.remark,'')
			FROM room_no b
			JOIN room_sta c ON c.rmno = b.code AND c.sta = 'D' AND c.sta_occ = 'O' AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id 
			LEFT JOIN room_sta_chg f ON f.rmno = c.rmno AND f.bill_sta = 'I' AND f.chg_type = 'TMP' AND f.hotel_group_id = arg_hotel_group_id AND f.hotel_id = arg_hotel_id 
			LEFT JOIN code_room_tmp g ON g.code = c.sta_tmp AND g.hotel_group_id = arg_hotel_group_id AND g.hotel_id = arg_hotel_id 
			WHERE b.is_villa <> 'B' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
			AND (rmtype_amount = 0 OR b.rmtype IN (SELECT code FROM rmtypes_temp));
		ELSEIF arg_action = 2 THEN
			INSERT INTO room_status_dirty_room_temp(rmtype, rmclass, rmno, rmnoSon, sta, building, floor, staTmp, remark)
			SELECT b.rmtype,b.rmclass,b.code,'',c.sta,b.building,b.floor,IFNULL(g.descript,IFNULL(c.sta_tmp,'')),IFNULL(f.remark,'')
			FROM room_no b
			JOIN room_sta c ON c.rmno = b.code AND c.sta = 'D' AND c.sta_occ = 'V' AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id 
			LEFT JOIN room_sta_chg f ON f.rmno = c.rmno AND f.bill_sta = 'I' AND f.chg_type = 'TMP' AND f.hotel_group_id = arg_hotel_group_id AND f.hotel_id = arg_hotel_id 
			LEFT JOIN code_room_tmp g ON g.code = c.sta_tmp AND g.hotel_group_id = arg_hotel_group_id AND g.hotel_id = arg_hotel_id 
			WHERE b.is_villa <> 'B' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
			AND (rmtype_amount = 0 OR b.rmtype IN (SELECT code FROM rmtypes_temp));
		END IF;
	END IF;
	
	BEGIN
		LEAVE label_0;
	END;
END$$
DELIMITER ;