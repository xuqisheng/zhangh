ALTER TABLE migrate_xmyh.trial_balance ADD item_code CHAR(15) NOT NULL DEFAULT '' AFTER CODE;

UPDATE  migrate_xmyh.trial_balance  SET item_code = CODE;

SELECT * FROM migrate_xmyh.trial_balance a,up_map_code b WHERE b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.code IN('pccode','paymth') AND a.code = b.code_old;

SELECT * FROM migrate_xmyh.trial_balance a WHERE a.code NOT IN
(SELECT code_old FROM up_map_code WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE IN('pccode','paymth')) 

UPDATE migrate_xmyh.trial_balance a,up_map_code b 
SET a.item_code = b.code_new  WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code IN('pccode','paymth') AND a.item_code = b.code_old;


SELECT * FROM migrate_xmyh.trial_balance WHERE item_code = '{{{{{';
UPDATE migrate_xmyh.trial_balance SET item_code = '}}}}}'  WHERE item_code = '{{{{{';

SELECT MAX(id) FROM rep_trial_balance;
SELECT MAX(id) FROM rep_trial_balance_history;
DELETE FROM rep_trial_balance WHERE hotel_id = 1 ORDER BY item_type,item_code;
DELETE FROM rep_trial_balance_history WHERE hotel_id = 1 ORDER BY item_type,item_code;


INSERT INTO `portal_tr`.`rep_trial_balance` 
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
SELECT  1, 
	1, 
 	DATE, 
	TYPE, 
	TRIM(item_code), 
	descript, 
	descript1, 
	SUM(DAY), 
	SUM(MONTH), 
	SUM(YEAR) 
	FROM migrate_xmyh.trial_balance WHERE item_code <> '' GROUP BY TYPE,item_code ORDER BY TYPE,item_code

SELECT * FROM migrate_xmyh.trial_balance;
SELECT * FROM rep_trial_balance WHERE hotel_group_id = 1 AND hotel_id = 1 ORDER BY item_type,item_code;
SELECT * FROM rep_dai  WHERE hotel_id = 1;

SELECT * FROM rep_trial_balance_history WHERE hotel_id = 1;
 
INSERT INTO rep_trial_balance_history
SELECT * FROM rep_trial_balance WHERE hotel_id = 1 AND biz_date = '2014.04.20' ORDER BY item_type,item_code;

DELETE FROM rep_trial_balance WHERE hotel_id = 1 AND biz_date = '2014.04.20' ORDER BY item_type,item_code;




