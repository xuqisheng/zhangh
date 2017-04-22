DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_repjie_day`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_repjie_day`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_biz_date			DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- =============================================================================
	-- 用途:个性底表某日子项数据,重新计算合计项数据
	-- 解释:CALL up_ihotel_reb_repjie_day(集团id,酒店id,开始日期,结束日期)
	-- 作者:zhangh 2015-03-26
	-- 注意:只能针对rectype='B'的内容进行修改
	-- =============================================================================
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_index		VARCHAR(8);
	DECLARE var_classno		VARCHAR(8);
	DECLARE var_toop		CHAR(1);
	DECLARE var_toclass		VARCHAR(8);
	DECLARE var_day01		DECIMAL(12,2);
	DECLARE var_day02		DECIMAL(12,2);
	DECLARE var_day03		DECIMAL(12,2);
	DECLARE var_day04		DECIMAL(12,2);
	DECLARE var_day05		DECIMAL(12,2);
	DECLARE var_day06		DECIMAL(12,2);
	DECLARE var_day07		DECIMAL(12,2);
	DECLARE var_day08		DECIMAL(12,2);
	DECLARE var_day09		DECIMAL(12,2);	
	
	DECLARE c_cursor CURSOR FOR 	
		SELECT classno,toop,toclass,day01,day02,day03,day04,day05,day06,day07,day08,day09
			FROM rep_jie_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_biz_date AND rectype = 'B' ORDER BY classno;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	UPDATE rep_jie_history SET day01 = 0,day02 = 0,day03 = 0,day04 = 0,day05 = 0,day06 = 0,day07 = 0,day08 = 0,day09 = 0,day99 = 0
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_biz_date AND rectype = 'C';
	
	OPEN c_cursor ;
	SET done_cursor = 0 ;
	FETCH c_cursor INTO var_classno,var_toop,var_toclass,var_day01,var_day02,var_day03,var_day04,var_day05,var_day06,var_day07,var_day08,var_day09; 
	
	WHILE done_cursor = 0 DO
		BEGIN		
			WHILE var_toclass <> SPACE(8) DO
				BEGIN
					UPDATE rep_jie_history SET
						day01 = day01 + var_day01, day02 = day02 + var_day02, day03 = day03 + var_day03,
						day04 = day04 + var_day04, day05 = day05 + var_day05, day06 = day06 + var_day06,
						day07 = day07 + var_day07, day08 = day08 + var_day08, day09 = day09 + var_day09
					WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_biz_date AND classno = var_toclass;
					
					SELECT toclass,toop INTO var_toclass,var_toop FROM rep_jie_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_biz_date AND classno = var_toclass;
					IF FOUND_ROWS() = 0	THEN
						SET var_toclass = SPACE(8);
					END IF;		
				END;
			END WHILE;	
		SET done_cursor = 0 ;
		FETCH c_cursor INTO var_classno,var_toop,var_toclass,var_day01,var_day02,var_day03,var_day04,var_day05,var_day06,var_day07,var_day08,var_day09;
		END ;
	END WHILE ;
	CLOSE c_cursor ;

	UPDATE rep_jie_history SET day99 = day01 + day02 + day03 + day04 + day05 + day06 + day07 + day08 + day09
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_biz_date;
	
		
END$$

DELIMITER ;

-- CALL up_ihotel_reb_repjie_day(1,1,'2015-3-26');

-- DROP PROCEDURE IF EXISTS `up_ihotel_reb_repjie_day`;