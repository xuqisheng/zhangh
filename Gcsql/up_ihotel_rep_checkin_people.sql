DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_checkin_people`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_checkin_people`(
	IN arg_hotel_group_id	BIGINT(16),
	IN arg_hotel_id			BIGINT(16),
	IN arg_begin_date		DATETIME,
	IN arg_end_date			DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
    -- ===========================================
	-- 房务前台宾客入住时间调查表
	-- 作者：zhangh
	-- 时间：2013.4.26
    -- ===========================================	
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE	var_bdate		DATETIME;
	DECLARE var_arr			DATETIME;
	DECLARE var_market		VARCHAR(10);
	DECLARE var_src			VARCHAR(10);
	DECLARE var_channel		VARCHAR(10);
	DECLARE var_ratecode	VARCHAR(10);
	DECLARE var_rsv_type	VARCHAR(10);
	
	DECLARE c_cursor CURSOR FOR 	
		SELECT biz_date, arr,market,src,channel,ratecode,rsv_type
			FROM master_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date >= arg_begin_date AND biz_date <= arg_end_date
		UNION ALL
		SELECT biz_date, arr,market,src,channel,ratecode,rsv_type
			FROM master_base_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date >= arg_begin_date AND biz_date <= arg_end_date
		ORDER BY biz_date,arr;
		
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	DROP TEMPORARY TABLE IF EXISTS tmp_checkin_people;
	CREATE TEMPORARY TABLE tmp_checkin_people (
		hotel_group_id 	BIGINT(16) 	NOT NULL,
		hotel_id 		BIGINT(16) 	NOT NULL,
		biz_date		DATETIME	NOT NULL,
		parent_code		VARCHAR(20)	NOT NULL,
		code			VARCHAR(10)	NOT NULL,
		descript		VARCHAR(50)	DEFAULT '' NOT NULL,
		amount1 		DECIMAL(10,2) DEFAULT 0 NOT NULL,
		amount2			DECIMAL(10,2) DEFAULT 0 NOT NULL,
		amount3 		DECIMAL(10,2) DEFAULT 0 NOT NULL,
		amount4			DECIMAL(10,2) DEFAULT 0 NOT NULL,
		amount5			DECIMAL(10,2) DEFAULT 0 NOT NULL,
		amount6			DECIMAL(10,2) DEFAULT 0 NOT NULL,
		amount7			DECIMAL(10,2) DEFAULT 0 NOT NULL,
		amount8			DECIMAL(10,2) DEFAULT 0 NOT NULL,
		amount9			DECIMAL(10,2) DEFAULT 0 NOT NULL,
		amount 			DECIMAL(10,2) DEFAULT 0 NOT NULL,
		KEY index1 (hotel_group_id,hotel_id,biz_date,code,parent_code)
	);
	
	SET var_bdate = arg_begin_date;
	
	WHILE var_bdate <= arg_end_date DO
		BEGIN
			INSERT INTO tmp_checkin_people(hotel_group_id,hotel_id,biz_date,parent_code,code,descript)
				SELECT hotel_group_id,hotel_id,var_bdate,parent_code,CODE,descript 
					FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code ='market_code';
		
			SET var_bdate = ADDDATE(var_bdate,1);
		END;
	END WHILE;
	
	OPEN c_cursor ;
	FETCH c_cursor INTO var_bdate,var_arr,var_market,var_src,var_channel,var_ratecode,var_rsv_type; 
		WHILE done_cursor = 0 DO
			BEGIN
				-- 0:00 到 8:00 时段
				IF HOUR(var_arr) >= 0 AND HOUR(var_arr) < 8 THEN
					UPDATE tmp_checkin_people SET amount1 = amount1 + 1
						WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id
							AND biz_date = var_bdate AND parent_code = 'market_code' AND code = var_market;				
				-- 8:00 到 10:00 时段
				ELSEIF HOUR(var_arr) >= 8 AND HOUR(var_arr) < 10 THEN
					UPDATE tmp_checkin_people SET amount2 = amount2 + 1
						WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id
							AND biz_date = var_bdate AND parent_code = 'market_code' AND code = var_market;				
				-- 10:00 到 12:00 时段
				ELSEIF HOUR(var_arr) >= 10 AND HOUR(var_arr) < 12 THEN
					UPDATE tmp_checkin_people SET amount3 = amount3 + 1
						WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id
							AND biz_date = var_bdate AND parent_code = 'market_code' AND code = var_market;				
				-- 12:00 到 14:00 时段
				ELSEIF HOUR(var_arr) >= 12 AND HOUR(var_arr) < 14 THEN
					UPDATE tmp_checkin_people SET amount4 = amount4 + 1
						WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id
							AND biz_date = var_bdate AND parent_code = 'market_code' AND code = var_market;				
				-- 14:00 到 16:00 时段
				ELSEIF HOUR(var_arr) >= 14 AND HOUR(var_arr) < 16 THEN
					UPDATE tmp_checkin_people SET amount5 = amount5 + 1
						WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id
							AND biz_date = var_bdate AND parent_code = 'market_code' AND code = var_market;				
				-- 16:00 到 18:00 时段
				ELSEIF HOUR(var_arr) >= 16 AND HOUR(var_arr) < 18 THEN
					UPDATE tmp_checkin_people SET amount6 = amount6 + 1
						WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id
							AND biz_date = var_bdate AND parent_code = 'market_code' AND code = var_market;				
				-- 18:00 到 20:00 时段
				ELSEIF HOUR(var_arr) >= 18 AND HOUR(var_arr) < 20 THEN
					UPDATE tmp_checkin_people SET amount7 = amount7 + 1
						WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id
							AND biz_date = var_bdate AND parent_code = 'market_code' AND code = var_market;				
				-- 20:00 到 22:00 时段
				ELSEIF HOUR(var_arr) >= 20 AND HOUR(var_arr) < 22 THEN
					UPDATE tmp_checkin_people SET amount8 = amount8 + 1
						WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id
							AND biz_date = var_bdate AND parent_code = 'market_code' AND code = var_market;				
				-- 22:00 到 24:00 时段
				ELSEIF HOUR(var_arr) >= 22 THEN
					UPDATE tmp_checkin_people SET amount9 = amount9 + 1
						WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id
							AND biz_date = var_bdate AND parent_code = 'market_code' AND code = var_market;				
				END IF;	
				
					UPDATE tmp_checkin_people SET amount = amount + 1
						WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id
							AND biz_date = var_bdate AND parent_code = 'market_code' AND code = var_market;					
			END;
	SET done_cursor = 0 ;
	FETCH c_cursor INTO var_bdate,var_arr,var_market,var_src,var_channel,var_ratecode,var_rsv_type; 
	END WHILE ;
	CLOSE c_cursor ;

	DELETE FROM tmp_checkin_people WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND amount = 0;
	SELECT * FROM tmp_checkin_people WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id ORDER BY biz_date,code;
		
END$$

DELIMITER ;

-- DROP PROCEDURE up_ihotel_rep_checkin_people;