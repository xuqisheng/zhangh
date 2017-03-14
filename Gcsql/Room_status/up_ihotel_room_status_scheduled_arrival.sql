DELIMITER $$
SET sql_notes = 0$$
DROP PROCEDURE IF EXISTS `up_ihotel_room_status_scheduled_arrival`$$
CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_room_status_scheduled_arrival`(
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
	-- 实时房情统计指标 >> 预计到达
	-- ---------------------------------------------------------------
	
	DECLARE rmtype_amount INT DEFAULT 0;
	DECLARE done_cursor INT DEFAULT 0;
	
	SET arg_result1 = '0';
	SET arg_result2 = '0';
	SET arg_result3 = '0';
	SET arg_result_table = 'room_status_scheduled_arrival_temp';
	
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
	
	SELECT IFNULL(SUM(c.rmnum), 0), IFNULL(SUM(c.adult * c.rmnum), 0) INTO arg_result1, arg_result2
	FROM master_base a 
	JOIN rsv_src c ON c.accnt = a.id AND c.occ_flag IN ('RF','RG') AND c.arr_date = arg_date AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id
	WHERE a.is_resrv = 'T' AND a.rsv_class IN ('F','G') AND a.sta IN ('R','I') AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
	AND (rmtype_amount = 0 OR a.rmtype IN (SELECT code FROM rmtypes_temp));
	
	SELECT arg_result1 + COUNT(DISTINCT a.master_id, a.rmno), arg_result2 + COUNT(1) INTO arg_result1, arg_result2
	FROM master_base a 
	JOIN rsv_src c ON c.accnt = a.id AND c.occ_flag = 'MF' AND c.arr_date = arg_date AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id
	WHERE a.is_resrv = 'F' AND a.rsv_class = 'F' AND a.sta = 'R' AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
	AND (rmtype_amount = 0 OR a.rmtype IN (SELECT code FROM rmtypes_temp));
	
	IF arg_action <> 0 THEN
		CREATE TEMPORARY TABLE IF NOT EXISTS room_status_scheduled_arrival_temp (
			accnt BIGINT(16) DEFAULT NULL,
			sta CHAR(2) DEFAULT NULL,
			grpAccnt BIGINT(16) DEFAULT NULL,
			`name` VARCHAR(20) DEFAULT NULL,
			vip VARCHAR(10) DEFAULT NULL,
			occFlag VARCHAR(10) DEFAULT NULL,
			rmtype VARCHAR(10) DEFAULT NULL,
			rmno VARCHAR(10) DEFAULT NULL,
			rmnoSon VARCHAR(10) DEFAULT NULL,
			realRate DECIMAL(8,2) DEFAULT NULL,
			rmnum MEDIUMINT(9) DEFAULT NULL,
			peopleNum MEDIUMINT(9) DEFAULT NULL,
			isSure CHAR(2) DEFAULT NULL,
			market VARCHAR(10) DEFAULT NULL,
			src VARCHAR(10) DEFAULT NULL,
			rsvType VARCHAR(10) DEFAULT NULL,
			arrDate DATETIME DEFAULT NULL,
			depDate DATETIME DEFAULT NULL,
			grpComName VARCHAR(60) DEFAULT NULL,
			ageSouName VARCHAR(60) DEFAULT NULL,
			rsvNo VARCHAR(20) DEFAULT NULL,
			rsvId BIGINT(16) DEFAULT NULL,
			masterId BIGINT(16) DEFAULT NULL,
			rsvClass CHAR(2) DEFAULT NULL
		);
		
		TRUNCATE TABLE room_status_scheduled_arrival_temp;
	END IF;
	
	IF arg_action = 1 THEN
		INSERT INTO room_status_scheduled_arrival_temp(accnt, sta, grpAccnt, name, vip, occFlag, rmtype, rmno, rmnoSon, realRate, rmnum, peopleNum, isSure, market, src, rsvType, arrDate, depDate, grpComName, ageSouName, rsvNo, rsvId, masterId, rsvClass)
		SELECT a.id, 'R', a.grp_accnt, b.name, b.vip, c.occ_flag, c.rmtype, '', '', c.real_rate, c.rmnum, c.adult, a.is_sure, c.market, c.src, a.rsv_type, c.rsv_arr_date, c.rsv_dep_date, CONCAT(IFNULL(g.name,'-'),'/',IFNULL(cp1.name,'-')), CONCAT(IFNULL(cp2.name,'-'),'/',IFNULL(cp3.name,'-')), a.rsv_no, a.rsv_id, a.master_id, a.rsv_class 
		FROM master_base a 
		JOIN master_guest b ON b.id = a.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id
		JOIN rsv_src c ON c.accnt = a.id AND c.occ_flag IN ('RF','RG') AND c.arr_date = arg_date AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id
		LEFT JOIN master_guest AS g ON g.id = a.grp_accnt AND g.hotel_group_id = arg_hotel_group_id AND g.hotel_id = arg_hotel_id
		LEFT JOIN company_base AS cp1 ON cp1.id = a.company_id AND cp1.hotel_group_id = arg_hotel_group_id
		LEFT JOIN company_base AS cp2 ON cp2.id = a.agent_id AND cp2.hotel_group_id = arg_hotel_group_id
		LEFT JOIN company_base AS cp3 ON cp3.id = a.source_id AND cp3.hotel_group_id = arg_hotel_group_id
		WHERE a.is_resrv = 'T' AND a.rsv_class IN ('F','G') AND a.sta IN ('R','I') AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
		AND (rmtype_amount = 0 OR a.rmtype IN (SELECT code FROM rmtypes_temp));
		
		INSERT INTO room_status_scheduled_arrival_temp(accnt, sta, grpAccnt, name, vip, occFlag, rmtype, rmno, rmnoSon, realRate, rmnum, peopleNum, isSure, market, src, rsvType, arrDate, depDate, grpComName, ageSouName, rsvNo, rsvId, masterId, rsvClass)
		SELECT a.id, a.sta, a.grp_accnt, b.name, b.vip, 'MF', a.rmtype, a.rmno, a.rmno_son, a.real_rate, a.rmnum, a.adult, a.is_sure, a.market, a.src, a.rsv_type, a.arr, a.dep, CONCAT(IFNULL(g.name,'-'),'/',IFNULL(cp1.name,'-')), CONCAT(IFNULL(cp2.name,'-'),'/',IFNULL(cp3.name,'-')), a.rsv_no, a.rsv_id, a.master_id, a.rsv_class 
		FROM master_base a 
		JOIN master_guest b ON b.id = a.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id
		JOIN rsv_src c ON c.accnt = a.id AND c.occ_flag = 'MF' AND c.arr_date = arg_date AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id
		LEFT JOIN master_guest AS g ON g.id = a.grp_accnt AND g.hotel_group_id = arg_hotel_group_id AND g.hotel_id = arg_hotel_id
		LEFT JOIN company_base AS cp1 ON cp1.id = a.company_id AND cp1.hotel_group_id = arg_hotel_group_id
		LEFT JOIN company_base AS cp2 ON cp2.id = a.agent_id AND cp2.hotel_group_id = arg_hotel_group_id
		LEFT JOIN company_base AS cp3 ON cp3.id = a.source_id AND cp3.hotel_group_id = arg_hotel_group_id
		WHERE a.is_resrv = 'F' AND a.rsv_class = 'F' AND a.sta = 'R' AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
		AND (rmtype_amount = 0 OR a.rmtype IN (SELECT code FROM rmtypes_temp));
	END IF;
	
	BEGIN
		LEAVE label_0;
	END;
END$$
DELIMITER ;