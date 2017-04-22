DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_statistic_save_year`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_statistic_save_year`(
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
	--  夜审报表 -- statistic_y 年统计调用过程
	-- 
	-- 作者：zhangh
	-- =========================================================
	DECLARE var_byear		INT;
	DECLARE var_bmonth		INT;
	
	SET var_byear 	= YEAR(arg_bdate);
	SET var_bmonth 	= MONTH(arg_bdate);
	
	IF NOT EXISTS(SELECT 1 FROM statistic_y WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat = arg_cat AND grp = arg_grp AND code = arg_code AND YEAR = var_byear ) THEN
		INSERT INTO statistic_y(hotel_group_id,hotel_id,YEAR,cat,grp,CODE) 
			VALUES (arg_hotel_group_id,arg_hotel_id,var_byear,arg_cat,arg_grp,arg_code);
	END IF;		
	
	CASE var_bmonth
		WHEN 1 THEN	
			UPDATE statistic_y SET month01 = month01 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear; 
		WHEN 2 THEN	
			UPDATE statistic_y SET month02 = month02 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear; 
		WHEN 3 THEN	
			UPDATE statistic_y SET month03 = month03 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear; 
		WHEN 4 THEN	
			UPDATE statistic_y SET month04 = month04 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear; 
		WHEN 5 THEN	
			UPDATE statistic_y SET month05 = month05 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear; 
		WHEN 6 THEN	
			UPDATE statistic_y SET month06 = month06 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear; 
		WHEN 7 THEN	
			UPDATE statistic_y SET month07 = month07 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear; 
		WHEN 8 THEN	
			UPDATE statistic_y SET month08 = month08 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear; 
		WHEN 9 THEN	
			UPDATE statistic_y SET month09 = month09 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear; 
		WHEN 10 THEN	
			UPDATE statistic_y SET month10 = month10 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear; 
		WHEN 11 THEN	
			UPDATE statistic_y SET month11 = month11 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear; 
		WHEN 12 THEN	
			UPDATE statistic_y SET month12 = month12 + arg_value WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat=arg_cat AND grp=arg_grp AND code = arg_code AND YEAR = var_byear; 
	END CASE;

END$$

DELIMITER ;