DELIMITER $$

DROP FUNCTION IF EXISTS `uf_ihotel_get_weekname`$$

CREATE DEFINER=`root`@`%` FUNCTION `uf_ihotel_get_weekname`(
	arg_biz_date		DATETIME
) RETURNS VARCHAR(50) CHARSET utf8
    DETERMINISTIC
    SQL SECURITY INVOKER
BEGIN 
		
	DECLARE var_weekname VARCHAR(50);
	
	IF WEEKDAY(arg_biz_date) = 0 THEN
		SET var_weekname = CONCAT(MONTH(arg_biz_date),'/',DAY(arg_biz_date),'(周一)');
	ELSEIF WEEKDAY(arg_biz_date) = 1 THEN
		SET var_weekname = CONCAT(MONTH(arg_biz_date),'/',DAY(arg_biz_date),'(周二)');	
	ELSEIF WEEKDAY(arg_biz_date) = 2 THEN
		SET var_weekname = CONCAT(MONTH(arg_biz_date),'/',DAY(arg_biz_date),'(周三)');
	ELSEIF WEEKDAY(arg_biz_date) = 3 THEN
		SET var_weekname = CONCAT(MONTH(arg_biz_date),'/',DAY(arg_biz_date),'(周四)');
	ELSEIF WEEKDAY(arg_biz_date) = 4 THEN
		SET var_weekname = CONCAT(MONTH(arg_biz_date),'/',DAY(arg_biz_date),'(周五)');
	ELSEIF WEEKDAY(arg_biz_date) = 5 THEN
		SET var_weekname = CONCAT(MONTH(arg_biz_date),'/',DAY(arg_biz_date),'(周六)');
	ELSEIF WEEKDAY(arg_biz_date) = 6 THEN
		SET var_weekname = CONCAT(MONTH(arg_biz_date),'/',DAY(arg_biz_date),'(周日)');
	END IF;	
			
	RETURN var_weekname;
	
END$$

DELIMITER ;