DELIMITER $$

DROP PROCEDURE IF EXISTS `up_pos_res_input_dishcard`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_pos_res_input_dishcard`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_accnt			VARCHAR(20),		-- 预订单单号
	IN arg_work_station		VARCHAR(50)			-- 哪些站点走厨房打印

	)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- 餐饮预订单从厨房打印里出单

	DECLARE	var_tableno			VARCHAR(10);
	DECLARE	var_tableno_desc	VARCHAR(10);
	DECLARE	var_pccode			VARCHAR(10);
	DECLARE	var_pccode_desc		VARCHAR(50);
	DECLARE var_pos				INT;
	DECLARE var_printer			VARCHAR(10);
	DECLARE var_station			VARCHAR(10);
	DECLARE var_printer_codes	VARCHAR(50);

	-- 获取桌号及营业点，及桌号中的清单和总单设置
	SELECT a.tableno,a.pccode,b.descript INTO var_tableno,var_pccode,var_pccode_desc FROM pos_res a,pos_pccode b WHERE a.accnt = arg_accnt AND a.pccode = b.code AND a.hotel_id = arg_hotel_id AND a.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id;

	SELECT descript INTO var_tableno_desc FROM pos_pccode_table WHERE CODE = var_tableno AND pccode = var_pccode AND hotel_id = arg_hotel_id AND hotel_group_id = arg_hotel_group_id;

	-- 使用站点的 descript_en 来增加要打印的机子
	SELECT MIN(descript_en) INTO var_station FROM work_station WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code = arg_work_station;
	-- 需要出厨房预订排菜总单的打印机集
	SELECT GROUP_CONCAT(CODE) INTO var_printer_codes FROM pos_printer WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND descript_en IN ('P','p');

	-- 获取桌号描述，如果为空则和桌号一致
	IF var_tableno_desc = '' OR var_tableno_desc IS NULL THEN
		SET var_tableno_desc = var_tableno;
	END IF;

	IF SUBSTR(var_printer_codes,CHAR_LENGTH(var_printer_codes),1) <> ',' THEN
		SET var_printer_codes = CONCAT(var_printer_codes,',');
	END IF;

	SET var_pos = INSTR(TRIM(var_printer_codes),',');

	DELETE FROM pos_dishcard WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt = arg_accnt AND isprint = 'F';


   	WHILE var_pos >=1 DO
  		BEGIN
			SET var_printer = SUBSTR(var_printer_codes,1,var_pos - 1);

			-- changed = '3' 厨师总单
			IF var_station = 'P' THEN	-- 是否同时要走厨房打印方式
				INSERT INTO pos_dishcard (hotel_group_id,hotel_id,accnt,inumber,tnumber,mnumber,biz_date,pccode,pccode_name,table_code,table_name,gsts,printid,TYPE,sta,code,descript,descript_en,unit,price,number,amount,cook_all,cook,printer,printer1,p_number,p_number1,CHANGED,times,isprint,station,class1,p_sort,foliono,siteno,create_user,create_datetime,modify_user,modify_datetime)
					SELECT arg_hotel_group_id,arg_hotel_id,arg_accnt,a.inumber,a.tnumber,a.mnumber,b.biz_date,b.pccode,var_pccode_desc,b.tableno,var_tableno_desc,b.gsts,a.id,'1',a.sta,a.plu_code,IF(SUBSTR(flag,10,1)=1,SUBSTR(a.descript,3),a.descript),IF(SUBSTR(flag,10,1)=1=1,SUBSTR(a.descript_en,3),a.descript_en),
					a.unit,a.price,a.number,a.amount,CONCAT('厨房备菜  就餐日:',DATE(b.biz_date)),a.cook,var_printer,var_printer,1,1,'3',0,'F','',NULL,a.sort_code,'0',a.siteno,a.create_user,a.create_datetime,NULL,NULL
					FROM pos_res_order a,pos_res b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
						AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.accnt = arg_accnt
						AND b.accnt = arg_accnt AND a.sta <> 'X' AND b.sta IN ('R','I','G')	AND SUBSTR(flag,1,1)='0' ORDER BY a.sort_code,a.plu_code;
			END IF;

			SET var_printer_codes = SUBSTR(var_printer_codes,var_pos + 1);
			SET var_pos = INSTR(TRIM(var_printer_codes),',');
 		END;
 	END WHILE;

	SELECT a.accnt AS res_accnt,a.res_name AS res_name,a.biz_date AS biz_date,a.phone AS res_phone,a.res_date AS res_date,a.pccode AS res_pccode,a.gsts,a.numb,a.info,a.amount,c.descript AS res_pccode_des,IF(a.shift=1,"早餐",IF(a.shift=2,"中餐",IF(a.shift=3,"晚餐","夜宵"))) AS res_shift,IFNULL(SUM(b.credit),0) AS res_credit,CONCAT(IFNULL(tableno,''),IFNULL(exttableno,'')) AS tablenos,a.paytype AS res_paytype,a.create_user AS create_user
	,a.create_datetime AS create_datetime,CONCAT(a.tableno,' ',d.descript) AS tableno
	FROM pos_res a
	LEFT JOIN pos_pay b ON a.accnt = b.accnt AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id
	LEFT JOIN pos_pccode_table d ON d.hotel_group_id = arg_hotel_group_id AND d.hotel_id = arg_hotel_id AND a.tableno = d.code
	,pos_pccode c
	WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND c.hotel_group_id = arg_hotel_group_id
	AND c.hotel_id = arg_hotel_id AND a.pccode = c.code AND a.accnt =  arg_accnt GROUP BY a.accnt,a.name,a.phone,a.res_date,a.pccode,a.shift;


END$$

DELIMITER ;