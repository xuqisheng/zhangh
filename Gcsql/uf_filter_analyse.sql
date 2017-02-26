DELIMITER $$

DROP FUNCTION IF EXISTS `uf_filter_analyse`$$

CREATE DEFINER=`root`@`%` FUNCTION `uf_filter_analyse`(
	arg_filter_codes	VARCHAR(1024),
	arg_column			VARCHAR(20)
)
	RETURNS VARCHAR(100)
    DETERMINISTIC
    SQL SECURITY INVOKER
BEGIN
 	-- ==================================================================
	-- 用途：函数 | 复杂窗口Filter参数解析
	-- Rmtype:ST,SD,SK#ta_code:9000,9001,9005#RateCode:FIT,COR,RACK#code:ALL#	
	-- 解释: 
	-- 范例: SELECT uf_filter_analyse('Rmtype:ST,SD,SK#ta_code:9000,9001,9005#RateCode:FIT,COR,RACK#code:ALL#','Rmtype')
	-- 作者：张惠 2016/08/10
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
			IF arg_column = var_filter_name THEN
				RETURN var_filter_code;
			ELSE
				RETURN 'ALL';
			END IF;
			
			SET arg_filter_codes = TRIM(INSERT(arg_filter_codes,1,var_pos,''));
			SET var_pos = INSTR(arg_filter_codes,'#');		
		END;
	END WHILE;

END$$

DELIMITER ;