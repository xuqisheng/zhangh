DELIMITER $$

DROP PROCEDURE IF EXISTS `up_pos_kitchen_get_data`$$

CREATE DEFINER=`gc_eng`@`%` PROCEDURE `up_pos_kitchen_get_data`(
	IN p_accnt CHAR(15),
	IN p_code CHAR(10),
	IN p_changed CHAR(1),
	IN p_hotel_group_id BIGINT,
	IN p_hotel_id BIGINT
	)
    SQL SECURITY INVOKER
BEGIN
	DECLARE var_printer_name    CHAR(20);   	-- 打印机名称
	DECLARE	var_print_type_des  VARCHAR(20); 	-- 打印小单类型
	DECLARE print_times    		INT;   			-- 最多重复打印的次数
	DECLARE var_shift_des 		VARCHAR(10);
	DECLARE var_tables 			INT;
	DECLARE var_gsts 			INT;
	DECLARE var_amount 			DECIMAL(12,2);
	DECLARE var_avg 			DECIMAL(12,2);
	
	SET print_times = 2;
	IF p_changed= '1' THEN
		SET var_print_type_des ='传菜总单';
	ELSEIF p_changed = '2' THEN
		SET var_print_type_des ='清单总单';
	ELSEIF p_changed = '3' THEN
		SET var_print_type_des ='厨师总单';
	ELSEIF p_changed = 'F' THEN
		SET var_print_type_des ='厨房分单';
	ELSEIF p_changed = 'H' THEN
		SET var_print_type_des ='合并打单';
	ELSEIF p_changed = 'C' THEN
		SET var_print_type_des ='厨房消息';
	END IF;
	
	IF SUBSTR(p_accnt,1,1) = 'P' THEN	-- 登记单
		SELECT MAX(shift) INTO var_shift_des FROM pos_master WHERE hotel_group_id = p_hotel_group_id AND hotel_id = p_hotel_id AND accnt = p_accnt;
		SELECT IFNULL(COUNT(DISTINCT tableno),0) INTO var_tables FROM pos_account WHERE hotel_group_id = p_hotel_group_id AND hotel_id = p_hotel_id AND accnt = p_accnt AND number = 1;
		
		SELECT IFNULL(MAX(gsts),0) INTO var_gsts FROM pos_master WHERE hotel_group_id = p_hotel_group_id AND hotel_id = p_hotel_id AND accnt = p_accnt;	
		SELECT IFNULL(SUM(amount),0) INTO var_amount FROM pos_detail WHERE hotel_group_id = p_hotel_group_id AND hotel_id = p_hotel_id AND accnt = p_accnt AND SUBSTR(flag,1,1)=1;
	END IF;
	
	IF SUBSTR(p_accnt,1,1) = 'R' THEN	-- 预订单
		SELECT MAX(shift),IFNULL(numb,0) INTO var_shift_des,var_tables FROM pos_res WHERE hotel_group_id = p_hotel_group_id AND hotel_id = p_hotel_id AND accnt = p_accnt;		
		SELECT IFNULL(MAX(gsts),0),IFNULL(SUM(amount),0) INTO var_gsts,var_amount FROM pos_res WHERE hotel_group_id = p_hotel_group_id AND hotel_id = p_hotel_id AND accnt = p_accnt;
	END IF;	
	
	SET var_avg = IFNULL(ROUND(var_amount/var_gsts,2),0);	
	
	IF var_shift_des = '1' THEN
		SET var_shift_des = '早班';
	ELSEIF var_shift_des = '2' THEN
		SET var_shift_des = '中班';
	ELSEIF var_shift_des = '3' THEN
		SET var_shift_des = '晚班';
	ELSEIF var_shift_des = '4' THEN
		SET var_shift_des = '夜班';
	ELSE
		SET var_shift_des = '';
	END IF;
	
	-- 获取传入打印机编码对应的打印机描述
	SELECT IFNULL(MAX(descript),'') INTO var_printer_name FROM pos_printer WHERE hotel_group_id = p_hotel_group_id AND hotel_id = p_hotel_id AND CODE = p_code;
	
	SELECT a.id,a.p_number1 AS p_number1,a.descript AS descript,a.descript_en AS descript_en,a.number AS number,a.unit AS unit,a.price AS price,a.cook AS cook,a.printid AS printid,
	a.type AS TYPE,a.accnt AS accnt,a.modify_datetime AS modify_datetime,a.foliono AS foliono,a.sta AS sta,a.modify_user AS modify_user,a.changed AS CHANGED, NULL AS top01, 
	IF(p_changed IN ('1','2','3') AND var_avg <> 0,CONCAT('桌号:',a.table_name,'  ',a.table_code,'  班次:',var_shift_des,'  餐标:',CAST(IFNULL(var_avg,0) AS CHAR),'  元/人'),CONCAT('桌号:',a.table_name,'  ',a.table_code,'  班次:',var_shift_des)) AS top02,  
	-- CONCAT('桌号:',a.table_name,'  ',a.table_code,'  班次:',var_shift_des) AS top02, 
	CONCAT('档口:',var_printer_name,'    人数:',CAST(IFNULL(a.gsts,0) AS CHAR),'    桌数:',CAST(IFNULL(var_tables,0) AS CHAR)) AS top03,
	-- CONCAT('营业点:',pccode_name,'    ','单号:',accnt,'*',var_print_type_des,'*',p_number) AS top03, 
	CONCAT('整单备注:',a.cook_all) AS top04,
	NULL AS top05,  
	NULL AS top06, 
	NULL AS top07, 
	NULL AS top08, 
	NULL AS top09, 
	NULL AS top10, 
	'' AS tail1, 	
	CONCAT('点菜员:',IFNULL(b.name,'   '),'  点菜时间:',IFNULL(DATE_FORMAT(a.create_datetime, '%Y-%m-%d %H:%i:%s'),'   ')) AS tail2, 
	'--' AS tail3
	FROM pos_dishcard a LEFT JOIN USER b ON b.hotel_group_id = p_hotel_group_id AND b.hotel_id = p_hotel_id AND a.create_user = b.code
	WHERE a.hotel_group_id = p_hotel_group_id AND a.hotel_id = p_hotel_id AND a.accnt= p_accnt
	AND FIND_IN_SET(p_code,a.printer)> 0
	AND a.changed = p_changed
	AND a.times < print_times
	AND a.p_number > 0 
	ORDER BY a.id ;
	
END$$

DELIMITER ;