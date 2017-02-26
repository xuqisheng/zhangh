DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_statistic_save_month`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_statistic_save_month`(
	IN arg_hotel_group_id	BIGINT(16),
	IN arg_hotel_id			BIGINT(16),
	IN arg_bdate			DATETIME,
	IN arg_cat				VARCHAR(30),
	IN arg_grp				VARCHAR(10),
	IN arg_code				VARCHAR(10),
	IN arg_value			DECIMAL(8,2)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- =========================================================
	--  夜审报表 -- statistic_m 月统计调用过程
	-- 
	-- 作者：zhangh
	-- =========================================================
	DECLARE var_byear		INT;
	DECLARE var_bmonth		INT;
	DECLARE var_bday		INT;
	
	SET var_byear 	= YEAR(arg_bdate);
	SET var_bmonth 	= MONTH(arg_bdate);
	SET var_bday 	= DAY(arg_bdate);
	
	IF NOT EXISTS(SELECT 1 FROM statistic_m WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat = arg_cat AND grp = arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth ) THEN
		INSERT INTO statistic_m(hotel_group_id,hotel_id,YEAR,MONTH,cat,grp,CODE) 
			VALUES (arg_hotel_group_id,arg_hotel_id,var_byear,var_bmonth,arg_cat,arg_grp,arg_code);
	END IF;		
	

	CASE var_bday
		WHEN 1 THEN
			UPDATE statistic_m SET day01 = day01 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 2 THEN
			UPDATE statistic_m SET day02 = day02 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 3 THEN
			UPDATE statistic_m SET day03 = day03 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 4 THEN
			UPDATE statistic_m SET day04 = day04 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 5 THEN
			UPDATE statistic_m SET day05 = day05 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 6 THEN
			UPDATE statistic_m SET day06 = day06 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 7 THEN
			UPDATE statistic_m SET day07 = day07 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 8 THEN
			UPDATE statistic_m SET day08 = day08 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 9 THEN
			UPDATE statistic_m SET day09 = day09 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 10 THEN
			UPDATE statistic_m SET day10 = day10 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 11 THEN
			UPDATE statistic_m SET day11 = day11 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 12 THEN
			UPDATE statistic_m SET day12 = day12 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 13 THEN
			UPDATE statistic_m SET day13 = day13 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 14 THEN
			UPDATE statistic_m SET day14 = day14 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 15 THEN
			UPDATE statistic_m SET day15 = day15 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 16 THEN
			UPDATE statistic_m SET day16 = day16 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 17 THEN
			UPDATE statistic_m SET day17 = day17 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 18 THEN
			UPDATE statistic_m SET day18 = day18 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 19 THEN
			UPDATE statistic_m SET day19 = day19 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 20 THEN
			UPDATE statistic_m SET day20 = day20 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 21 THEN
			UPDATE statistic_m SET day21 = day21 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 22 THEN
			UPDATE statistic_m SET day22 = day22 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 23 THEN
			UPDATE statistic_m SET day23 = day23 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 24 THEN
			UPDATE statistic_m SET day24 = day24 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 25 THEN
			UPDATE statistic_m SET day25 = day25 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 26 THEN
			UPDATE statistic_m SET day26 = day26 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 27 THEN
			UPDATE statistic_m SET day27 = day27 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 28 THEN
			UPDATE statistic_m SET day28 = day28 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 29 THEN
			UPDATE statistic_m SET day29 = day29 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 30 THEN
			UPDATE statistic_m SET day30 = day30 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
		WHEN 31 THEN
			UPDATE statistic_m SET day31 = day31 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear AND MONTH = var_bmonth; 
	END CASE;

END$$

DELIMITER ;