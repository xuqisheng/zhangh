DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_getchinanumber`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_getchinanumber`(
	IN arg_count			INT,
	IN arg_mode				CHAR(1),
	OUT arg_number			CHAR(2)
    )
	
	SQL SECURITY INVOKER
label_0:
BEGIN
	-- =============================================================================
	-- 用途:被调用产生中文数字
	-- 解释:
	-- 作者:张惠 2015-04-29
	-- =============================================================================
	SET arg_count = arg_count % 10;
	
	IF arg_mode = 'F' THEN
		IF arg_count = 0 THEN
			SET arg_number = '零';
		ELSEIF arg_count = 1 THEN
			SET arg_number = '一';
		ELSEIF arg_count = 2 THEN
			SET arg_number = '二';
		ELSEIF arg_count = 3 THEN
			SET arg_number = '三';			
		ELSEIF arg_count = 4 THEN
			SET arg_number = '四';
		ELSEIF arg_count = 5 THEN
			SET arg_number = '五';
		ELSEIF arg_count = 6 THEN
			SET arg_number = '六';
		ELSEIF arg_count = 7 THEN
			SET arg_number = '七';
		ELSEIF arg_count = 8 THEN
			SET arg_number = '八';
		ELSEIF arg_count = 9 THEN
			SET arg_number = '九';
		END IF;
	ELSE
		IF arg_count = 0 THEN
			SET arg_number = '零';
		ELSEIF arg_count = 1 THEN
			SET arg_number = '壹';
		ELSEIF arg_count = 2 THEN
			SET arg_number = '贰';
		ELSEIF arg_count = 3 THEN
			SET arg_number = '叁';			
		ELSEIF arg_count = 4 THEN
			SET arg_number = '肆';
		ELSEIF arg_count = 5 THEN
			SET arg_number = '伍';
		ELSEIF arg_count = 6 THEN
			SET arg_number = '陆';
		ELSEIF arg_count = 7 THEN
			SET arg_number = '柒';
		ELSEIF arg_count = 8 THEN
			SET arg_number = '捌';
		ELSEIF arg_count = 9 THEN
			SET arg_number = '玖';
		END IF;	
	END IF;
	
END$$

DELIMITER ;