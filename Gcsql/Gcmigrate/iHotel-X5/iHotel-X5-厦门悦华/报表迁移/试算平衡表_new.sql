SELECT * FROM trial_balance ORDER BY item_type,item_code;

SELECT * FROM migrate_xmyh.trial_balance ORDER BY TYPE,CODE;


INSERT INTO `portal_tr`.`trial_balance` 
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
SELECT 1, 
	1, 
 	DATE, 
	TYPE, 
	CODE, 
	descript, 
	descript1, 
	DAY, 
	MONTH, 
	YEAR
	FROM migrate_xmyh.ytrial_balance WHERE DATE <'2014.11.26';
DELETE FROM trial_balance_history WHERE hotel_id = 1;
INSERT INTO trial_balance_history SELECT * FROM trial_balance;
DELETE FROM trial_balance WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <'2014.11.26';

SELECT * FROM trial_balance ORDER BY item_type,item_code;

SELECT * FROM migrate_xmyh.trial_balance ORDER BY TYPE,CODE;


