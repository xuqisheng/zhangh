DELIMITER $$

USE `portal_pms`$$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_mrmrsv_forecast`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_mrmrsv_forecast`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_biz_date			DATETIME	
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	DECLARE var_mdate 		DATETIME;
	DECLARE var_bdate 		DATETIME;
	DECLARE var_biz_date 	DATETIME;
	DECLARE var_amount		VARCHAR(10);
	DECLARE var_amount1		DECIMAL(10,2);
	DECLARE var_amount2		DECIMAL(10,2);
	DECLARE var_amount91	DECIMAL(10,2);
	DECLARE var_amount92	DECIMAL(10,2);
	
	SELECT biz_date1 INTO var_biz_date FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	DROP TEMPORARY TABLE IF EXISTS tmp_mrmrsv_forecast;
	CREATE TEMPORARY TABLE tmp_mrmrsv_forecast(
		item_code		VARCHAR(10) NOT NULL,	
		item_des		VARCHAR(50) NOT NULL,
		day01			VARCHAR(10) NOT NULL DEFAULT '0',
		day02			VARCHAR(10) NOT NULL DEFAULT '0',
		day03			VARCHAR(10) NOT NULL DEFAULT '0',
		day04			VARCHAR(10) NOT NULL DEFAULT '0',
		day05			VARCHAR(10) NOT NULL DEFAULT '0',
		day06			VARCHAR(10) NOT NULL DEFAULT '0',
		day07			VARCHAR(10) NOT NULL DEFAULT '0',
		day08			VARCHAR(10) NOT NULL DEFAULT '0',
		day09			VARCHAR(10) NOT NULL DEFAULT '0',
		day10			VARCHAR(10) NOT NULL DEFAULT '0',
		day11			VARCHAR(10) NOT NULL DEFAULT '0',
		day12			VARCHAR(10) NOT NULL DEFAULT '0',
		day13			VARCHAR(10) NOT NULL DEFAULT '0',
		day14			VARCHAR(10) NOT NULL DEFAULT '0',
		day15			VARCHAR(10) NOT NULL DEFAULT '0',
		day16			VARCHAR(10) NOT NULL DEFAULT '0',
		day17			VARCHAR(10) NOT NULL DEFAULT '0',
		day18			VARCHAR(10) NOT NULL DEFAULT '0',
		day19			VARCHAR(10) NOT NULL DEFAULT '0',
		day20			VARCHAR(10) NOT NULL DEFAULT '0',
		day21			VARCHAR(10) NOT NULL DEFAULT '0',
		day22			VARCHAR(10) NOT NULL DEFAULT '0',
		day23			VARCHAR(10) NOT NULL DEFAULT '0',
		day24			VARCHAR(10) NOT NULL DEFAULT '0',
		day25			VARCHAR(10) NOT NULL DEFAULT '0',
		day26			VARCHAR(10) NOT NULL DEFAULT '0',
		day27			VARCHAR(10) NOT NULL DEFAULT '0',
		day28			VARCHAR(10) NOT NULL DEFAULT '0',
		day29			VARCHAR(10) NOT NULL DEFAULT '0',
		day30			VARCHAR(10) NOT NULL DEFAULT '0',
		day31			VARCHAR(10) NOT NULL DEFAULT '0',
		day99			VARCHAR(10) NOT NULL DEFAULT '0',
		KEY index1(item_code)
	);
	INSERT INTO tmp_mrmrsv_forecast(item_code,item_des) VALUES
		('001','Sellable Rooms'),
		('B01','Total On Reservation For Group(Booking)'),
		('B02','FIT(Mem Inc.)'),
		('B03','Total On Reservation'),
		('B04','Rooms Available'),
		('B05','Occ. Of the day(%)'),
		('B06','Monthly Occ(%)');
		
	SET var_mdate = DATE_ADD(arg_biz_date,INTERVAL -(DAYOFMONTH(arg_biz_date)-1) DAY);
	SET var_bdate = var_mdate;
	
	-- 可用房
	WHILE var_bdate <= LAST_DAY(arg_biz_date) DO
		BEGIN
			SET var_amount = '0';
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,var_bdate,'%','Room to Rent',var_amount);
			IF DAY(var_bdate) = 1 THEN
				UPDATE tmp_mrmrsv_forecast SET day01 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 2 THEN
				UPDATE tmp_mrmrsv_forecast SET day02 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 3 THEN
				UPDATE tmp_mrmrsv_forecast SET day03 = var_amount WHERE item_code = '001';				
			ELSEIF DAY(var_bdate) = 4 THEN
				UPDATE tmp_mrmrsv_forecast SET day04 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 5 THEN
				UPDATE tmp_mrmrsv_forecast SET day05 = var_amount WHERE item_code = '001';			
			ELSEIF DAY(var_bdate) = 6 THEN
				UPDATE tmp_mrmrsv_forecast SET day06 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 7 THEN
				UPDATE tmp_mrmrsv_forecast SET day07 = var_amount WHERE item_code = '001';				
			ELSEIF DAY(var_bdate) = 8 THEN
				UPDATE tmp_mrmrsv_forecast SET day08 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 9 THEN
				UPDATE tmp_mrmrsv_forecast SET day09 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 10 THEN
				UPDATE tmp_mrmrsv_forecast SET day10 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 11 THEN
				UPDATE tmp_mrmrsv_forecast SET day11 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 12 THEN
				UPDATE tmp_mrmrsv_forecast SET day12 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 13 THEN
				UPDATE tmp_mrmrsv_forecast SET day13 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 14 THEN
				UPDATE tmp_mrmrsv_forecast SET day14 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 15 THEN
				UPDATE tmp_mrmrsv_forecast SET day15 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 16 THEN
				UPDATE tmp_mrmrsv_forecast SET day16 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 17 THEN
				UPDATE tmp_mrmrsv_forecast SET day17 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 18 THEN
				UPDATE tmp_mrmrsv_forecast SET day18 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 19 THEN
				UPDATE tmp_mrmrsv_forecast SET day19 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 20 THEN
				UPDATE tmp_mrmrsv_forecast SET day20 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 21 THEN
				UPDATE tmp_mrmrsv_forecast SET day21 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 22 THEN
				UPDATE tmp_mrmrsv_forecast SET day22 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 23 THEN
				UPDATE tmp_mrmrsv_forecast SET day23 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 24 THEN
				UPDATE tmp_mrmrsv_forecast SET day24 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 25 THEN
				UPDATE tmp_mrmrsv_forecast SET day25 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 26 THEN
				UPDATE tmp_mrmrsv_forecast SET day26 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 27 THEN
				UPDATE tmp_mrmrsv_forecast SET day27 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 28 THEN
				UPDATE tmp_mrmrsv_forecast SET day28 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 29 THEN
				UPDATE tmp_mrmrsv_forecast SET day29 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 30 THEN
				UPDATE tmp_mrmrsv_forecast SET day30 = var_amount WHERE item_code = '001';
			ELSEIF DAY(var_bdate) = 31 THEN
				UPDATE tmp_mrmrsv_forecast SET day31 = var_amount WHERE item_code = '001';				
			END IF;
						
			SET var_bdate = ADDDATE(var_bdate,INTERVAL 1 DAY);
		END;		
	END WHILE;
	
	-- Total On Reservation For Group(Booking)
	SET var_bdate = var_mdate;
	WHILE var_bdate <= LAST_DAY(arg_biz_date) DO
		BEGIN
			SET var_amount = '0';
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,var_bdate,'%','Occupied In Sta GRP',var_amount);
			IF DAY(var_bdate) = 1 THEN
				UPDATE tmp_mrmrsv_forecast SET day01 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 2 THEN
				UPDATE tmp_mrmrsv_forecast SET day02 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 3 THEN
				UPDATE tmp_mrmrsv_forecast SET day03 = var_amount WHERE item_code = 'B01';				
			ELSEIF DAY(var_bdate) = 4 THEN
				UPDATE tmp_mrmrsv_forecast SET day04 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 5 THEN
				UPDATE tmp_mrmrsv_forecast SET day05 = var_amount WHERE item_code = 'B01';			
			ELSEIF DAY(var_bdate) = 6 THEN
				UPDATE tmp_mrmrsv_forecast SET day06 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 7 THEN
				UPDATE tmp_mrmrsv_forecast SET day07 = var_amount WHERE item_code = 'B01';				
			ELSEIF DAY(var_bdate) = 8 THEN
				UPDATE tmp_mrmrsv_forecast SET day08 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 9 THEN
				UPDATE tmp_mrmrsv_forecast SET day09 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 10 THEN
				UPDATE tmp_mrmrsv_forecast SET day10 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 11 THEN
				UPDATE tmp_mrmrsv_forecast SET day11 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 12 THEN
				UPDATE tmp_mrmrsv_forecast SET day12 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 13 THEN
				UPDATE tmp_mrmrsv_forecast SET day13 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 14 THEN
				UPDATE tmp_mrmrsv_forecast SET day14 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 15 THEN
				UPDATE tmp_mrmrsv_forecast SET day15 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 16 THEN
				UPDATE tmp_mrmrsv_forecast SET day16 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 17 THEN
				UPDATE tmp_mrmrsv_forecast SET day17 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 18 THEN
				UPDATE tmp_mrmrsv_forecast SET day18 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 19 THEN
				UPDATE tmp_mrmrsv_forecast SET day19 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 20 THEN
				UPDATE tmp_mrmrsv_forecast SET day20 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 21 THEN
				UPDATE tmp_mrmrsv_forecast SET day21 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 22 THEN
				UPDATE tmp_mrmrsv_forecast SET day22 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 23 THEN
				UPDATE tmp_mrmrsv_forecast SET day23 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 24 THEN
				UPDATE tmp_mrmrsv_forecast SET day24 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 25 THEN
				UPDATE tmp_mrmrsv_forecast SET day25 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 26 THEN
				UPDATE tmp_mrmrsv_forecast SET day26 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 27 THEN
				UPDATE tmp_mrmrsv_forecast SET day27 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 28 THEN
				UPDATE tmp_mrmrsv_forecast SET day28 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 29 THEN
				UPDATE tmp_mrmrsv_forecast SET day29 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 30 THEN
				UPDATE tmp_mrmrsv_forecast SET day30 = var_amount WHERE item_code = 'B01';
			ELSEIF DAY(var_bdate) = 31 THEN
				UPDATE tmp_mrmrsv_forecast SET day31 = var_amount WHERE item_code = 'B01';				
			END IF;
			
			SET var_bdate = ADDDATE(var_bdate,INTERVAL 1 DAY);
		END;		
	END WHILE;	
	
	-- FIT(Mem Inc.)
	SET var_bdate = var_mdate;
	WHILE var_bdate <= LAST_DAY(arg_biz_date) DO
		BEGIN
			SET var_amount = '0';
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,var_bdate,'%','Occupied In Sta FIT',var_amount);
			IF DAY(var_bdate) = 1 THEN
				UPDATE tmp_mrmrsv_forecast SET day01 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 2 THEN
				UPDATE tmp_mrmrsv_forecast SET day02 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 3 THEN
				UPDATE tmp_mrmrsv_forecast SET day03 = var_amount WHERE item_code = 'B02';				
			ELSEIF DAY(var_bdate) = 4 THEN
				UPDATE tmp_mrmrsv_forecast SET day04 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 5 THEN
				UPDATE tmp_mrmrsv_forecast SET day05 = var_amount WHERE item_code = 'B02';			
			ELSEIF DAY(var_bdate) = 6 THEN
				UPDATE tmp_mrmrsv_forecast SET day06 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 7 THEN
				UPDATE tmp_mrmrsv_forecast SET day07 = var_amount WHERE item_code = 'B02';				
			ELSEIF DAY(var_bdate) = 8 THEN
				UPDATE tmp_mrmrsv_forecast SET day08 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 9 THEN
				UPDATE tmp_mrmrsv_forecast SET day09 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 10 THEN
				UPDATE tmp_mrmrsv_forecast SET day10 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 11 THEN
				UPDATE tmp_mrmrsv_forecast SET day11 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 12 THEN
				UPDATE tmp_mrmrsv_forecast SET day12 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 13 THEN
				UPDATE tmp_mrmrsv_forecast SET day13 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 14 THEN
				UPDATE tmp_mrmrsv_forecast SET day14 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 15 THEN
				UPDATE tmp_mrmrsv_forecast SET day15 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 16 THEN
				UPDATE tmp_mrmrsv_forecast SET day16 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 17 THEN
				UPDATE tmp_mrmrsv_forecast SET day17 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 18 THEN
				UPDATE tmp_mrmrsv_forecast SET day18 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 19 THEN
				UPDATE tmp_mrmrsv_forecast SET day19 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 20 THEN
				UPDATE tmp_mrmrsv_forecast SET day20 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 21 THEN
				UPDATE tmp_mrmrsv_forecast SET day21 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 22 THEN
				UPDATE tmp_mrmrsv_forecast SET day22 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 23 THEN
				UPDATE tmp_mrmrsv_forecast SET day23 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 24 THEN
				UPDATE tmp_mrmrsv_forecast SET day24 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 25 THEN
				UPDATE tmp_mrmrsv_forecast SET day25 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 26 THEN
				UPDATE tmp_mrmrsv_forecast SET day26 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 27 THEN
				UPDATE tmp_mrmrsv_forecast SET day27 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 28 THEN
				UPDATE tmp_mrmrsv_forecast SET day28 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 29 THEN
				UPDATE tmp_mrmrsv_forecast SET day29 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 30 THEN
				UPDATE tmp_mrmrsv_forecast SET day30 = var_amount WHERE item_code = 'B02';
			ELSEIF DAY(var_bdate) = 31 THEN
				UPDATE tmp_mrmrsv_forecast SET day31 = var_amount WHERE item_code = 'B02';				
			END IF;
			
			SET var_bdate = ADDDATE(var_bdate,INTERVAL 1 DAY);
		END;		
	END WHILE;
	
	-- Total On Reservation
	SET var_bdate = var_mdate;
	WHILE var_bdate <= LAST_DAY(arg_biz_date) DO
		BEGIN
			SET var_amount = '0';
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,var_bdate,'%','Occupied In Sta',var_amount);
			IF DAY(var_bdate) = 1 THEN
				UPDATE tmp_mrmrsv_forecast SET day01 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 2 THEN
				UPDATE tmp_mrmrsv_forecast SET day02 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 3 THEN
				UPDATE tmp_mrmrsv_forecast SET day03 = var_amount WHERE item_code = 'B03';				
			ELSEIF DAY(var_bdate) = 4 THEN
				UPDATE tmp_mrmrsv_forecast SET day04 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 5 THEN
				UPDATE tmp_mrmrsv_forecast SET day05 = var_amount WHERE item_code = 'B03';			
			ELSEIF DAY(var_bdate) = 6 THEN
				UPDATE tmp_mrmrsv_forecast SET day06 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 7 THEN
				UPDATE tmp_mrmrsv_forecast SET day07 = var_amount WHERE item_code = 'B03';				
			ELSEIF DAY(var_bdate) = 8 THEN
				UPDATE tmp_mrmrsv_forecast SET day08 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 9 THEN
				UPDATE tmp_mrmrsv_forecast SET day09 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 10 THEN
				UPDATE tmp_mrmrsv_forecast SET day10 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 11 THEN
				UPDATE tmp_mrmrsv_forecast SET day11 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 12 THEN
				UPDATE tmp_mrmrsv_forecast SET day12 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 13 THEN
				UPDATE tmp_mrmrsv_forecast SET day13 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 14 THEN
				UPDATE tmp_mrmrsv_forecast SET day14 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 15 THEN
				UPDATE tmp_mrmrsv_forecast SET day15 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 16 THEN
				UPDATE tmp_mrmrsv_forecast SET day16 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 17 THEN
				UPDATE tmp_mrmrsv_forecast SET day17 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 18 THEN
				UPDATE tmp_mrmrsv_forecast SET day18 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 19 THEN
				UPDATE tmp_mrmrsv_forecast SET day19 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 20 THEN
				UPDATE tmp_mrmrsv_forecast SET day20 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 21 THEN
				UPDATE tmp_mrmrsv_forecast SET day21 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 22 THEN
				UPDATE tmp_mrmrsv_forecast SET day22 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 23 THEN
				UPDATE tmp_mrmrsv_forecast SET day23 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 24 THEN
				UPDATE tmp_mrmrsv_forecast SET day24 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 25 THEN
				UPDATE tmp_mrmrsv_forecast SET day25 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 26 THEN
				UPDATE tmp_mrmrsv_forecast SET day26 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 27 THEN
				UPDATE tmp_mrmrsv_forecast SET day27 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 28 THEN
				UPDATE tmp_mrmrsv_forecast SET day28 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 29 THEN
				UPDATE tmp_mrmrsv_forecast SET day29 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 30 THEN
				UPDATE tmp_mrmrsv_forecast SET day30 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 31 THEN
				UPDATE tmp_mrmrsv_forecast SET day31 = var_amount WHERE item_code = 'B03';				
			END IF;
			
			SET var_bdate = ADDDATE(var_bdate,INTERVAL 1 DAY);
		END;		
	END WHILE;	
	-- Rooms Available
	SET var_bdate = var_mdate;
	WHILE var_bdate <= LAST_DAY(arg_biz_date) DO
		BEGIN
			SET var_amount = '0';
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,var_bdate,'%','Available Rooms',var_amount);
			IF DAY(var_bdate) = 1 THEN
				UPDATE tmp_mrmrsv_forecast SET day01 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 2 THEN
				UPDATE tmp_mrmrsv_forecast SET day02 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 3 THEN
				UPDATE tmp_mrmrsv_forecast SET day03 = var_amount WHERE item_code = 'B04';				
			ELSEIF DAY(var_bdate) = 4 THEN
				UPDATE tmp_mrmrsv_forecast SET day04 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 5 THEN
				UPDATE tmp_mrmrsv_forecast SET day05 = var_amount WHERE item_code = 'B04';			
			ELSEIF DAY(var_bdate) = 6 THEN
				UPDATE tmp_mrmrsv_forecast SET day06 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 7 THEN
				UPDATE tmp_mrmrsv_forecast SET day07 = var_amount WHERE item_code = 'B04';				
			ELSEIF DAY(var_bdate) = 8 THEN
				UPDATE tmp_mrmrsv_forecast SET day08 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 9 THEN
				UPDATE tmp_mrmrsv_forecast SET day09 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 10 THEN
				UPDATE tmp_mrmrsv_forecast SET day10 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 11 THEN
				UPDATE tmp_mrmrsv_forecast SET day11 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 12 THEN
				UPDATE tmp_mrmrsv_forecast SET day12 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 13 THEN
				UPDATE tmp_mrmrsv_forecast SET day13 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 14 THEN
				UPDATE tmp_mrmrsv_forecast SET day14 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 15 THEN
				UPDATE tmp_mrmrsv_forecast SET day15 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 16 THEN
				UPDATE tmp_mrmrsv_forecast SET day16 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 17 THEN
				UPDATE tmp_mrmrsv_forecast SET day17 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 18 THEN
				UPDATE tmp_mrmrsv_forecast SET day18 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 19 THEN
				UPDATE tmp_mrmrsv_forecast SET day19 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 20 THEN
				UPDATE tmp_mrmrsv_forecast SET day20 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 21 THEN
				UPDATE tmp_mrmrsv_forecast SET day21 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 22 THEN
				UPDATE tmp_mrmrsv_forecast SET day22 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 23 THEN
				UPDATE tmp_mrmrsv_forecast SET day23 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 24 THEN
				UPDATE tmp_mrmrsv_forecast SET day24 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 25 THEN
				UPDATE tmp_mrmrsv_forecast SET day25 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 26 THEN
				UPDATE tmp_mrmrsv_forecast SET day26 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 27 THEN
				UPDATE tmp_mrmrsv_forecast SET day27 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 28 THEN
				UPDATE tmp_mrmrsv_forecast SET day28 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 29 THEN
				UPDATE tmp_mrmrsv_forecast SET day29 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 30 THEN
				UPDATE tmp_mrmrsv_forecast SET day30 = var_amount WHERE item_code = 'B04';
			ELSEIF DAY(var_bdate) = 31 THEN
				UPDATE tmp_mrmrsv_forecast SET day31 = var_amount WHERE item_code = 'B04';				
			END IF;
			
			SET var_bdate = ADDDATE(var_bdate,INTERVAL 1 DAY);
		END;		
	END WHILE;
	
	-- Total On Reservation
	SET var_bdate = var_mdate;
	WHILE var_bdate <= LAST_DAY(arg_biz_date) DO
		BEGIN
		
			SET var_amount = '0';
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,var_bdate,'%','Occupied In Sta',var_amount);
			IF DAY(var_bdate) = 1 THEN
				UPDATE tmp_mrmrsv_forecast SET day01 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 2 THEN
				UPDATE tmp_mrmrsv_forecast SET day02 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 3 THEN
				UPDATE tmp_mrmrsv_forecast SET day03 = var_amount WHERE item_code = 'B03';				
			ELSEIF DAY(var_bdate) = 4 THEN
				UPDATE tmp_mrmrsv_forecast SET day04 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 5 THEN
				UPDATE tmp_mrmrsv_forecast SET day05 = var_amount WHERE item_code = 'B03';			
			ELSEIF DAY(var_bdate) = 6 THEN
				UPDATE tmp_mrmrsv_forecast SET day06 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 7 THEN
				UPDATE tmp_mrmrsv_forecast SET day07 = var_amount WHERE item_code = 'B03';				
			ELSEIF DAY(var_bdate) = 8 THEN
				UPDATE tmp_mrmrsv_forecast SET day08 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 9 THEN
				UPDATE tmp_mrmrsv_forecast SET day09 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 10 THEN
				UPDATE tmp_mrmrsv_forecast SET day10 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 11 THEN
				UPDATE tmp_mrmrsv_forecast SET day11 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 12 THEN
				UPDATE tmp_mrmrsv_forecast SET day12 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 13 THEN
				UPDATE tmp_mrmrsv_forecast SET day13 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 14 THEN
				UPDATE tmp_mrmrsv_forecast SET day14 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 15 THEN
				UPDATE tmp_mrmrsv_forecast SET day15 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 16 THEN
				UPDATE tmp_mrmrsv_forecast SET day16 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 17 THEN
				UPDATE tmp_mrmrsv_forecast SET day17 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 18 THEN
				UPDATE tmp_mrmrsv_forecast SET day18 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 19 THEN
				UPDATE tmp_mrmrsv_forecast SET day19 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 20 THEN
				UPDATE tmp_mrmrsv_forecast SET day20 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 21 THEN
				UPDATE tmp_mrmrsv_forecast SET day21 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 22 THEN
				UPDATE tmp_mrmrsv_forecast SET day22 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 23 THEN
				UPDATE tmp_mrmrsv_forecast SET day23 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 24 THEN
				UPDATE tmp_mrmrsv_forecast SET day24 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 25 THEN
				UPDATE tmp_mrmrsv_forecast SET day25 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 26 THEN
				UPDATE tmp_mrmrsv_forecast SET day26 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 27 THEN
				UPDATE tmp_mrmrsv_forecast SET day27 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 28 THEN
				UPDATE tmp_mrmrsv_forecast SET day28 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 29 THEN
				UPDATE tmp_mrmrsv_forecast SET day29 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 30 THEN
				UPDATE tmp_mrmrsv_forecast SET day30 = var_amount WHERE item_code = 'B03';
			ELSEIF DAY(var_bdate) = 31 THEN
				UPDATE tmp_mrmrsv_forecast SET day31 = var_amount WHERE item_code = 'B03';				
			END IF;
			
			SET var_bdate = ADDDATE(var_bdate,INTERVAL 1 DAY);
		END;		
	END WHILE;	
	-- Occ. Of the day(%)
	SET var_bdate = var_mdate,var_amount91 = 0,var_amount92=0;
	WHILE var_bdate <= LAST_DAY(arg_biz_date) DO
		BEGIN
			SET var_amount1 = 0,var_amount2=0;
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,var_bdate,'%','Total Rooms',var_amount1);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,var_bdate,'%','Occupied In Sta',var_amount2);
			SET var_amount91 = var_amount91 + var_amount1,var_amount92 = var_amount92 + var_amount2;
			IF DAY(var_bdate) = 1 THEN
				UPDATE tmp_mrmrsv_forecast SET day01 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 2 THEN
				UPDATE tmp_mrmrsv_forecast SET day02 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 3 THEN
				UPDATE tmp_mrmrsv_forecast SET day03 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';				
			ELSEIF DAY(var_bdate) = 4 THEN
				UPDATE tmp_mrmrsv_forecast SET day04 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 5 THEN
				UPDATE tmp_mrmrsv_forecast SET day05 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';			
			ELSEIF DAY(var_bdate) = 6 THEN
				UPDATE tmp_mrmrsv_forecast SET day06 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 7 THEN
				UPDATE tmp_mrmrsv_forecast SET day07 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';				
			ELSEIF DAY(var_bdate) = 8 THEN
				UPDATE tmp_mrmrsv_forecast SET day08 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 9 THEN
				UPDATE tmp_mrmrsv_forecast SET day09 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 10 THEN
				UPDATE tmp_mrmrsv_forecast SET day10 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 11 THEN
				UPDATE tmp_mrmrsv_forecast SET day11 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 12 THEN
				UPDATE tmp_mrmrsv_forecast SET day12 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 13 THEN
				UPDATE tmp_mrmrsv_forecast SET day13 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 14 THEN
				UPDATE tmp_mrmrsv_forecast SET day14 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 15 THEN
				UPDATE tmp_mrmrsv_forecast SET day15 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 16 THEN
				UPDATE tmp_mrmrsv_forecast SET day16 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 17 THEN
				UPDATE tmp_mrmrsv_forecast SET day17 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 18 THEN
				UPDATE tmp_mrmrsv_forecast SET day18 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 19 THEN
				UPDATE tmp_mrmrsv_forecast SET day19 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 20 THEN
				UPDATE tmp_mrmrsv_forecast SET day20 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 21 THEN
				UPDATE tmp_mrmrsv_forecast SET day21 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 22 THEN
				UPDATE tmp_mrmrsv_forecast SET day22 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 23 THEN
				UPDATE tmp_mrmrsv_forecast SET day23 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 24 THEN
				UPDATE tmp_mrmrsv_forecast SET day24 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 25 THEN
				UPDATE tmp_mrmrsv_forecast SET day25 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 26 THEN
				UPDATE tmp_mrmrsv_forecast SET day26 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 27 THEN
				UPDATE tmp_mrmrsv_forecast SET day27 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 28 THEN
				UPDATE tmp_mrmrsv_forecast SET day28 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 29 THEN
				UPDATE tmp_mrmrsv_forecast SET day29 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 30 THEN
				UPDATE tmp_mrmrsv_forecast SET day30 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';
			ELSEIF DAY(var_bdate) = 31 THEN
				UPDATE tmp_mrmrsv_forecast SET day31 = IFNULL(ROUND(var_amount2*100/var_amount1,2),0) WHERE item_code = 'B05';			
			END IF;
			
			UPDATE tmp_mrmrsv_forecast SET day99 = IFNULL(ROUND(var_amount92*100/var_amount91,2),0) WHERE item_code = 'B06';
			SET var_bdate = ADDDATE(var_bdate,INTERVAL 1 DAY);
		END;		
	END WHILE;	
	
	DROP TEMPORARY TABLE IF EXISTS tmp_mrmrsv;
	CREATE TEMPORARY TABLE tmp_mrmrsv(
		company_id 		INT,
		company_mode	CHAR(1),
		biz_date		DATETIME,
		amount			DECIMAL(12,2) DEFAULT '0.0',
		KEY index1(company_id,company_mode,biz_date)
	);	
	
	SET var_bdate = var_mdate;
	WHILE var_bdate <= LAST_DAY(arg_biz_date) DO
		BEGIN
			INSERT INTO tmp_mrmrsv(company_id,company_mode,biz_date,amount)
			SELECT a.company_id,'C',var_bdate,COUNT(DISTINCT a.master_id,a.rmno) FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='I' AND a.rsv_class IN ('F','D') AND a.grp_accnt<>0 AND DATE(a.arr) <= var_bdate AND DATE(a.dep) > var_bdate AND a.company_id<>0 GROUP BY a.company_id;
			INSERT INTO tmp_mrmrsv(company_id,company_mode,biz_date,amount)		
			SELECT a.agent_id,'A',var_bdate,COUNT(DISTINCT a.master_id,a.rmno) FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='I' AND a.rsv_class IN ('F','D') AND a.grp_accnt<>0 AND DATE(a.arr) <= var_bdate AND DATE(a.dep) > var_bdate AND a.agent_id<>0 GROUP BY a.agent_id;
			INSERT INTO tmp_mrmrsv(company_id,company_mode,biz_date,amount)
			SELECT a.source_id,'S',var_bdate,COUNT(DISTINCT a.master_id,a.rmno) FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='I' AND a.rsv_class IN ('F','D') AND a.grp_accnt<>0 AND DATE(a.arr) <= var_bdate AND DATE(a.dep) > var_bdate AND a.source_id<>0 GROUP BY a.source_id;
			INSERT INTO tmp_mrmrsv(company_id,company_mode,biz_date,amount)
			SELECT a.grp_accnt,'G',var_bdate,COUNT(DISTINCT a.master_id,a.rmno) FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='I' AND a.rsv_class IN ('F','D') AND a.grp_accnt<>0 AND DATE(a.arr) <= var_bdate AND DATE(a.dep) > var_bdate AND a.company_id=0 AND a.agent_id=0 AND a.source_id=0 GROUP BY a.grp_accnt;
			
			INSERT INTO tmp_mrmrsv(company_id,company_mode,biz_date,amount)
			SELECT a.company_id,'C',var_bdate,COUNT(DISTINCT a.master_id,a.rmno) FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='R' AND a.rsv_class='F' AND DATE(a.arr) <= var_bdate AND DATE(a.dep) > var_bdate AND a.company_id<>0 GROUP BY a.company_id;
			INSERT INTO tmp_mrmrsv(company_id,company_mode,biz_date,amount)
			SELECT a.agent_id,'A',var_bdate,COUNT(DISTINCT a.master_id,a.rmno) FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='R' AND a.rsv_class='F' AND DATE(a.arr) <= var_bdate AND DATE(a.dep) > var_bdate AND a.agent_id<>0 GROUP BY a.agent_id;
			INSERT INTO tmp_mrmrsv(company_id,company_mode,biz_date,amount)
			SELECT source_id,'S',var_bdate,COUNT(DISTINCT a.master_id,a.rmno) FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='R' AND a.rsv_class='F' AND DATE(a.arr) <= var_bdate AND DATE(a.dep) > var_bdate AND a.source_id<>0 GROUP BY a.source_id;
			INSERT INTO tmp_mrmrsv(company_id,company_mode,biz_date,amount)
			SELECT grp_accnt,'G',var_bdate,COUNT(DISTINCT a.master_id,a.rmno) FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='R' AND a.rsv_class='F' AND a.grp_accnt<>0 AND DATE(a.arr) <= var_bdate AND DATE(a.dep) > var_bdate AND a.company_id=0 AND a.agent_id=0 AND a.source_id=0 GROUP BY a.grp_accnt;		
			
			INSERT INTO tmp_mrmrsv(company_id,company_mode,biz_date,amount)	
			SELECT a.company_id,'C',var_bdate,IFNULL(SUM(b.rmnum),0) FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.id=b.accnt AND b.occ_flag IN ('RF','RG') AND a.sta IN ('R','I') AND a.rsv_class IN ('F','G') AND a.grp_accnt<>0 AND a.id=a.rsv_id AND b.arr_date <= var_bdate AND b.dep_date > var_bdate AND a.company_id<>0 GROUP BY a.company_id;
			INSERT INTO tmp_mrmrsv(company_id,company_mode,biz_date,amount)
			SELECT a.agent_id,'A',var_bdate,IFNULL(SUM(b.rmnum),0) FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.id=b.accnt AND b.occ_flag IN ('RF','RG') AND a.sta IN ('R','I') AND a.rsv_class IN ('F','G') AND a.grp_accnt<>0 AND a.id=a.rsv_id AND b.arr_date <= var_bdate AND b.dep_date > var_bdate AND a.agent_id<>0 GROUP BY a.agent_id;
			INSERT INTO tmp_mrmrsv(company_id,company_mode,biz_date,amount)
			SELECT a.source_id,'S',var_bdate,IFNULL(SUM(b.rmnum),0) FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.id=b.accnt AND b.occ_flag IN ('RF','RG') AND a.sta IN ('R','I') AND a.rsv_class IN ('F','G') AND a.grp_accnt<>0 AND a.id=a.rsv_id AND b.arr_date <= var_bdate AND b.dep_date > var_bdate AND a.source_id<>0 GROUP BY a.source_id;
			INSERT INTO tmp_mrmrsv(company_id,company_mode,biz_date,amount)
			SELECT a.grp_accnt,'G',var_bdate,IFNULL(SUM(b.rmnum),0) FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.id=b.accnt AND b.occ_flag IN ('RF','RG') AND a.sta IN ('R','I') AND a.rsv_class IN ('F','G') AND a.grp_accnt<>0 AND a.id=a.rsv_id AND b.arr_date <= var_bdate AND b.dep_date > var_bdate AND a.company_id=0 AND a.agent_id=0 AND a.source_id=0 GROUP BY a.grp_accnt;		

			SET var_bdate = ADDDATE(var_bdate,INTERVAL 1 DAY);
		END;		
	END WHILE;		
	
	DROP TEMPORARY TABLE IF EXISTS tmp_mrmrsv1;
	CREATE TEMPORARY TABLE tmp_mrmrsv1(
		company_id 		INT,
		company_mode	CHAR(1),
		biz_date		DATETIME,
		amount			DECIMAL(12,2) DEFAULT '0.0',
		KEY index1(company_id,biz_date)
	);	
	
	INSERT INTO tmp_mrmrsv_forecast(item_code,item_des)
		SELECT company_id,'' FROM tmp_mrmrsv GROUP BY company_id,company_mode;
	INSERT INTO tmp_mrmrsv1 SELECT company_id,company_mode,biz_date,amount FROM tmp_mrmrsv GROUP BY company_id,company_mode,biz_date;
	
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day01 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 1;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day02 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 2;	
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day03 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 3;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day04 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 4;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day05 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 5;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day06 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 6;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day07 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 7;	
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day08 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 8;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day09 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 9;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day10 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 10;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day11 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 11;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day12 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 12;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day13 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 13;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day14 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 14;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day15 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 15;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day16 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 16;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day17 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 17;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day18 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 18;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day19 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 19;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day20 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 20;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day21 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 21;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day22 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 22;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day23 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 23;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day24 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 24;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day25 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 25;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day26 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 26;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day27 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 27;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day28 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 28;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day29 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 29;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day30 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 30;
	UPDATE tmp_mrmrsv_forecast a,tmp_mrmrsv1 b SET a.day31 = IFNULL(b.amount,0) WHERE a.item_code = b.company_id AND DAY(b.biz_date) = 31;
	
	UPDATE tmp_mrmrsv_forecast a,company_base b SET a.item_des = b.name WHERE a.item_code = b.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = 0 AND a.item_des = '';
	UPDATE tmp_mrmrsv_forecast a,master_guest b SET a.item_des = b.name WHERE a.item_code = b.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.item_des = '';	
	
	UPDATE tmp_mrmrsv_forecast SET day99 = day01 + day02 + day03 + day04 + day05 + day06 + day07 + day08 + day09 + day10
	 + day11 + day12 + day13 + day14 + day15 + day16 + day17 + day18 + day19 + day20 + day21 + day22 + day23 + day24
	 + day25 + day26 + day27 + day28 + day29 + day30 + day31 WHERE item_code NOT IN ('B05','B06');
	 
	 UPDATE tmp_mrmrsv_forecast SET day01 = '' WHERE day01 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day02 = '' WHERE day02 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day03 = '' WHERE day03 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day04 = '' WHERE day04 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day05 = '' WHERE day05 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day06 = '' WHERE day06 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day07 = '' WHERE day07 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day08 = '' WHERE day08 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day09 = '' WHERE day09 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day10 = '' WHERE day10 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day11 = '' WHERE day11 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day12 = '' WHERE day12 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day13 = '' WHERE day13 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day14 = '' WHERE day14 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day15 = '' WHERE day15 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day16 = '' WHERE day16 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day17 = '' WHERE day17 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day18 = '' WHERE day18 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day19 = '' WHERE day19 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day20 = '' WHERE day20 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day21 = '' WHERE day21 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day22 = '' WHERE day22 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day23 = '' WHERE day23 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day24 = '' WHERE day24 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day25 = '' WHERE day25 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day26 = '' WHERE day26 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day27 = '' WHERE day27 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day28 = '' WHERE day28 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day29 = '' WHERE day29 = 0;	
	 UPDATE tmp_mrmrsv_forecast SET day30 = '' WHERE day30 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day31 = '' WHERE day31 = 0;
	 UPDATE tmp_mrmrsv_forecast SET day99 = '' WHERE day99 = 0;
	 
	SELECT item_des,day01,day02,day03,day04,day05,day06,day07,day08,day09,
		day10,day11,day12,day13,day14,day15,day16,day17,day18,day19,day20,
		day21,day22,day23,day24,day25,day26,day27,day28,day29,day30,day31,day99 FROM tmp_mrmrsv_forecast ORDER BY item_code;
	
	DROP TEMPORARY TABLE IF EXISTS tmp_mrmrsv;
	DROP TEMPORARY TABLE IF EXISTS tmp_mrmrsv_forecast;
		
END$$

DELIMITER ;