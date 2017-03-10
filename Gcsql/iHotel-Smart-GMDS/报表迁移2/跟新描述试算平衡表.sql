-- select * from migrate_wysyh.trial_balance_history  where hotel_group_id=1 and hotel_id=3  gtoup by biz_date,item_type,item_code

-- 删除中间库migrate_wysyh.trial_balance_history 
DELETE FROM migrate_wysyh.trial_balance_history WHERE hotel_group_id=1 AND hotel_id=3 ;

INSERT INTO migrate_wysyh.trial_balance_history (hotel_group_id,hotel_id,biz_date,item_type,item_code,descript,descript_en,amount,amount_m,amount_y)
SELECT  hotel_group_id,hotel_id,biz_date,item_type,item_code,descript,descript_en,amount,amount_m,amount_y
FROM portal.trial_balance_history_20150912 WHERE hotel_group_id=1 AND hotel_id=3 ;


SELECT * FROM migrate_wysyh.trial_balance_history WHERE hotel_group_id=1 AND hotel_id=3  AND amount='871' ;

-- 由于新代码、老代码有重复，需要对中间表up_map_code code_old 加个特殊符号
SELECT * FROM migrate_wysyh.up_map_code WHERE hotel_group_id=1 AND hotel_id=3  AND CODE IN('pccode','paymth') ;

UPDATE migrate_wysyh.up_map_code SET code_new=CONCAT('@',code_new) WHERE hotel_group_id=1 AND hotel_id=3  AND CODE IN('pccode','paymth') ;


-- 跟新代码migrate_wysyh.trial_balance_history
SELECT a.* FROM migrate_wysyh.trial_balance_history a,up_map_code b WHERE 
a.hotel_group_id = 1 AND a.hotel_id = 3 AND a.biz_date='2015.09.09'AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.code IN('pccode','paymth') AND a.item_code = b.code_old;

UPDATE migrate_wysyh.trial_balance_history a,up_map_code b 
SET a.item_code =b.code_new WHERE 
a.hotel_group_id = 1 AND a.hotel_id = 3 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.code IN('pccode','paymth') AND a.item_code = b.code_old  ;



SELECT  * FROM migrate_wysyh.trial_balance_history WHERE  hotel_group_id=1 AND hotel_id=3  ;

-- 根据历史表做汇总插入到中间表

SELECT * FROM migrate_wysyh.trial_balance_history WHERE hotel_group_id=1 AND hotel_id=3 AND biz_date='2015.09.09';

DELETE FROM migrate_wysyh.trial_balance  WHERE hotel_group_id=1 AND hotel_id=3;

INSERT INTO migrate_wysyh.trial_balance (hotel_group_id,hotel_id,biz_date,item_type,item_code,descript,descript_en,amount,amount_m,amount_y)
SELECT  hotel_group_id,hotel_id,biz_date,item_type,item_code,descript,descript_en,SUM(amount),SUM(amount_m),SUM(amount_y)
FROM migrate_wysyh.trial_balance_history WHERE hotel_group_id=1 AND hotel_id=3  GROUP BY biz_date,item_type,item_code;

-- 根据中间表的code 跟新描述
SELECT * FROM migrate_wysyh.trial_balance WHERE hotel_group_id=1 AND hotel_id=3 AND biz_date='2015.09.11';

SELECT REPLACE(item_code,'@','') FROM migrate_wysyh.trial_balance;

UPDATE migrate_wysyh.trial_balance a,portal.code_transaction b 
SET a.descript = b.descript  WHERE 
a.hotel_group_id = 1 AND a.hotel_id = 3 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND  REPLACE(item_code,'@','') = b.code;

-- 跟新回去code，注select * from migrate_wysyh.trial_balance where hotel_group_id = 1 AND hotel_id = 3意去索引
SELECT * FROM migrate_wysyh.trial_balance WHERE hotel_group_id = 1 AND hotel_id = 3  AND item_code LIKE '%@%';

UPDATE migrate_wysyh.trial_balance SET  item_code=REPLACE(item_code,'@','')  WHERE hotel_group_id = 1 AND hotel_id = 3  AND item_code LIKE '%@%';

-- 根据中间表插入到portal.trial_balance
SELECT * FROM portal.trial_balance WHERE hotel_group_id=1 AND hotel_id=3  ;

DELETE FROM portal.trial_balance WHERE hotel_group_id=1 AND hotel_id=3 ;

INSERT INTO portal.trial_balance (hotel_group_id,hotel_id,biz_date,item_type,item_code,descript,descript_en,amount,amount_m,amount_y)
SELECT  hotel_group_id,hotel_id,biz_date,item_type,item_code,descript,descript_en,amount,amount_m,amount_y
FROM migrate_wysyh.trial_balance WHERE hotel_group_id=1 AND hotel_id=3 ;

-- 插入正式库的
SELECT * FROM portal.trial_balance_history WHERE hotel_group_id=1 AND hotel_id=3 ;

DELETE FROM portal.trial_balance_history WHERE hotel_group_id=1 AND hotel_id=3 ;

INSERT INTO portal.trial_balance_history SELECT * FROM portal.trial_balance WHERE hotel_group_id=1 AND hotel_id=3 ;

-- 删除当前表
DELETE FROM portal.trial_balance WHERE hotel_group_id=1 AND hotel_id=3  AND biz_date<='2015.09.10';

SELECT * FROM portal.trial_balance WHERE hotel_group_id=1 AND hotel_id=3 ;


