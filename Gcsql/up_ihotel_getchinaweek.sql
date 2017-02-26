DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_getchinaweek`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_getchinaweek`(
	IN 	arg_date			DATETIME,
	OUT arg_week			VARCHAR(10) 
    )
	
	SQL SECURITY INVOKER
label_0:
BEGIN
	-- =============================================================================
	-- 用途:被调用产生中文星期名
	-- 解释:
	-- 作者:zhangh 2016-05-19
	-- =============================================================================

	IF DAYOFWEEK(arg_date) = 1 THEN
		SET arg_week = '星期日';
	ELSEIF DAYOFWEEK(arg_date) = 2 THEN
		SET arg_week = '星期一';
	ELSEIF DAYOFWEEK(arg_date) = 3 THEN
		SET arg_week = '星期二';
	ELSEIF DAYOFWEEK(arg_date) = 4 THEN
		SET arg_week = '星期三';
	ELSEIF DAYOFWEEK(arg_date) = 5 THEN
		SET arg_week = '星期四';
	ELSEIF DAYOFWEEK(arg_date) = 6 THEN
		SET arg_week = '星期五';		
	ELSEIF DAYOFWEEK(arg_date) = 7 THEN
		SET arg_week = '星期六';	
	END IF;
		
END$$

DELIMITER ;