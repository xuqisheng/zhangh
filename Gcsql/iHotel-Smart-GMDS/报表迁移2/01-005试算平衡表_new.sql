
-- 导入新格式,试算平衡表只保证当前的余额，不导入历史数据
-- 对中间表migrate_xmhy.trial_balance  根据对照表跟新
-- 将正式库的up_map_code 拷贝到中间库migrate_xmhy
-- 由于新代码、老代码有重复，需要对中间表up_map_code code_old 加个特殊符号
SELECT * FROM migrate_xmhy.up_map_code WHERE hotel_group_id = 1 AND hotel_id = 5  AND CODE IN('pccode','paymth') ;

UPDATE migrate_xmhy.up_map_code SET code_new=CONCAT('@',code_new) WHERE hotel_group_id = 1 AND hotel_id = 5  AND CODE IN('pccode','paymth') ;

--  跟新代码
UPDATE migrate_xmhy.trial_balance a,migrate_xmhy.up_map_code b SET a.code =b.code_new
WHERE  b.hotel_group_id = 1 AND b.hotel_id = 5 AND b.code IN('pccode','paymth') AND a.code = b.code_old  ;

-- 跟新描述

UPDATE migrate_xmhy.trial_balance a,portal.code_transaction b 
SET a.descript = b.descript  
WHERE b.hotel_group_id = 1 AND b.hotel_id = 5
AND  REPLACE(a.code,'@','') = b.code;


-- 去除特殊符号
UPDATE  migrate_xmhy.trial_balance SET  CODE=REPLACE(CODE,'@','')  WHERE CODE LIKE '%@%';

-- 开始汇总插入正式库
SELECT * FROM migrate_xmhy.trial_balance ORDER BY TYPE,CODE;

SELECT * FROM portal.trial_balance WHERE hotel_group_id = 1 AND  hotel_id = 5;

DELETE FROM portal.trial_balance WHERE hotel_group_id = 1 AND  hotel_id = 5;

INSERT INTO portal.trial_balance
	(`hotel_group_id`, 
	`hotel_id`, 
 	`biz_date`, 
	`item_type`, 
	`item_code`, 
	`descript`, 
	`descript_en`, 
	`amount`, 
	`amount_m`, 
	`amount_y`
	)
SELECT   1, 
	5, 
 	DATE, 
	TYPE, 
	CODE, 
	descript, 
	descript1, 
	SUM(DAY), 
	SUM(MONTH), 
	SUM(YEAR)
	FROM migrate_xmhy.trial_balance GROUP BY DATE,TYPE,CODE;
	
UPDATE portal.trial_balance SET item_code = TRIM(item_code) WHERE hotel_group_id = 1 AND hotel_id = 5 AND INSTR(item_code,'*') > 0;

UPDATE portal.trial_balance SET item_code = TRIM(item_code)WHERE hotel_group_id = 1 AND hotel_id = 5 AND INSTR(item_code,'#') > 0;

UPDATE portal.trial_balance SET item_code = '}}}}}'  WHERE hotel_group_id = 1 AND hotel_id = 5 AND item_code = '{{{{{';

UPDATE portal.trial_balance SET item_type = '62',item_code = '}}}}}' WHERE hotel_group_id = 1 AND hotel_id = 5 AND item_type = '60' AND item_code = '30';

UPDATE portal.trial_balance SET item_type = '63',item_code = '}}}}}' WHERE hotel_group_id = 1 AND hotel_id = 5 AND item_type = '60' AND item_code = '40';

UPDATE portal.trial_balance SET item_type = '65' WHERE hotel_group_id = 1 AND hotel_id = 5 AND item_type = '60' AND item_code IN('50','60','60A','60C','60D');



-- 插入历史
DELETE FROM portal.trial_balance_history   WHERE  hotel_group_id = 1 AND  hotel_id = 5; 
INSERT INTO portal.trial_balance_history SELECT * FROM portal.trial_balance WHERE hotel_group_id = 1 AND hotel_id = 5;


-- 修改

 SELECT * FROM portal.trial_balance  WHERE hotel_group_id = 1 AND  hotel_id = 5 AND item_type=40 AND item_code='';
 SELECT * FROM portal.trial_balance_history  WHERE hotel_group_id = 1 AND  hotel_id = 5 AND item_type=40 AND item_code='';
 
 UPDATE portal.trial_balance  SET item_code='#' WHERE hotel_group_id = 1 AND  hotel_id = 5 AND item_type=40 AND item_code='';
 UPDATE portal.trial_balance_history  SET item_code='#' WHERE hotel_group_id = 1 AND  hotel_id = 5 AND item_type=40 AND item_code='';


