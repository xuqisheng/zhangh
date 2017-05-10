DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_up_map_code_maint`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_map_code_maint`(
	IN arg_hid_fm INT, 
	IN arg_hid_to INT
	)
label_0:
BEGIN
	-- =========================================================
	-- FUNCTION: 根据特定的酒店映射对照代码修订指定的酒店映射代码
	-- =========================================================
	-- 修正的含义
	-- 		其实就是补充那些统一的代码。程序写死
	-- 		针对艳阳天，除了ratecode, rmtype 每个酒店不一样，其他都一样的 
	-- =========================================================
	-- 参数
	-- 从哪个酒店提取数据	arg_hid_fm 
	-- 修正哪个酒店数据		arg_hid_to
	-- =========================================================
	DECLARE arg_gid_fm INT; 
	DECLARE arg_gid_to INT; 

	SET arg_gid_fm=NULL; 
	SET arg_gid_to=NULL; 
	
	-- 参数检查 
	SELECT hotel_group_id INTO arg_gid_fm FROM hotel WHERE id=arg_hid_fm; 
	IF arg_gid_fm IS NULL THEN 
		SELECT '来源酒店 id 错误！'; 
		LEAVE label_0;
	END IF; 
	SELECT hotel_group_id INTO arg_gid_to FROM hotel WHERE id=arg_hid_fm; 
	IF arg_gid_to IS NULL THEN 
		SELECT '目标酒店 id 错误！'; 
		LEAVE label_0;
	END IF; 
	
	-- 处理1：补充记录    
	INSERT INTO up_map_code (hotel_group_id,hotel_id, cat, code_old, code_old_des, code_new, code_new_des, remark)
		SELECT b.hotel_group_id,b.id, a.cat, a.code_old, a.code_old_des, a.code_new, a.code_new_des,  a.remark
		FROM up_map_code a, hotel b 
		WHERE a.hotel_id=arg_hid_fm AND b.hotel_group_id=arg_gid_to AND b.id=arg_hid_to AND a.cat IN ('ratecode', 'rmtype')
			AND CONCAT(CONVERT(b.id, CHAR(10)), a.cat, a.code_old) 
				NOT IN (SELECT CONCAT(CONVERT(f.hotel_id, CHAR(10)), f.cat, f.code_old) FROM up_map_code f); 
				
	-- 处理2：纠正 up_map_code.code_new_id 
	-- 目前还没有必要，暂时不处理 
	
END$$

DELIMITER ;
