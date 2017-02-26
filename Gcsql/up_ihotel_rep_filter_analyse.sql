DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_filter_analyse`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_filter_analyse`(
	IN  arg_filter_codes	VARCHAR(1024)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
 	-- ==================================================================
	-- 用途：复杂窗口Filter参数解析
	-- 第一种方法，是以窗口的描述为例子
	-- Room Type:ST,SD,SK#Pay Method:9000,9001,9005#Rate Code:FIT,COR,RACK#
	-- 第二种方法，是iHotel系统中字段名为例子
	-- Rmtype:ST,SD,SK#ta_code:9000,9001,9005#RateCode:FIT,COR,RACK#code:ALL#	
	-- 解释: 
	-- 范例: 
	-- 作者：
	-- ==================================================================
	DECLARE var_pos				INT;
	DECLARE var_index			INT;
	DECLARE var_filter_index	VARCHAR(100);
	DECLARE var_filter_name		VARCHAR(30);
	DECLARE var_filter_code		VARCHAR(90);
	
	-- 分解变量字符串至单个变量
	SET var_pos = INSTR(TRIM(arg_filter_codes),'#');
	WHILE var_pos > 1 DO
		BEGIN
			SET var_filter_index =  SUBSTR(arg_filter_codes,1,var_pos - 1);
			
			-- 分解变量及变量值
			SET var_index = INSTR(TRIM(var_filter_index),':');
			SET var_filter_name = SUBSTR(var_filter_index,1,var_index - 1);
			SET var_filter_code = SUBSTR(var_filter_index,var_index + 1);
			
			-- SELECT var_filter_index,var_filter_name,var_filter_code;
			
			SET arg_filter_codes = TRIM(INSERT(arg_filter_codes,1,var_pos,''));
			SET var_pos = INSTR(arg_filter_codes,'#');		
		END;
	END WHILE;

END$$

DELIMITER ;