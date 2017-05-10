
INSERT INTO `portal`.`jour_other` 
	(`hotel_group_id`, 
	`hotel_id`, 
 	`biz_date`, 
	`CODE`, 
	`descript`, 
	`day_h`, 
	`day_t`, 
	`day_x`, 
	`day_v`, 
	`day_w`, 
	`day_p`, 
	`day_ot`, 
	`day_ttl`, 
	`month_h`, 
	`month_t`, 
	`month_x`, 
	`month_v`, 
	`month_w`, 
	`month_p`, 
	`month_ot`, 
	`month_ttl`, 
	`year_h`, 
	`year_t`, 
	`year_x`, 
	`year_v`, 
	`year_w`, 
	`year_p`, 
	`year_ot`, 
	`year_ttl`, 
	`list_order`
	)
SELECT  1, 
	1, 
 	DATE, 
	class, 
	descript, 
	day_h, 
	day_t, 
	day_x, 
	day_v, 
	day_w, 
	day_p, 
	day_ot, 
	day_ttl, 
	month_h, 
	month_t, 
	month_x, 
	month_v, 
	month_w, 
	month_p, 
	month_ot, 
	month_ttl, 
	year_h, 
	year_t, 
	year_x, 
	year_v, 
	year_w, 
	year_p, 
	year_ot, 
	year_ttl, 
	''
	FROM migrate_xmyh.yjourrep_other;

UPDATE jour_other SET CODE = '611',list_order = 5 WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE = '30';
UPDATE jour_other SET CODE = '111',list_order = 10 WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE = '39';
UPDATE jour_other SET CODE = '115',list_order = 15 WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE = '40';
UPDATE jour_other SET CODE = '112',list_order = 20 WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE = '42';
UPDATE jour_other SET CODE = '113',list_order = 25 WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE = '43';
UPDATE jour_other SET CODE = '114',list_order = 30 WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE = '44';
UPDATE jour_other SET CODE = '301',list_order = 35 WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE = '50';

SELECT * FROM jour_other_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.7'; 
DELETE FROM jour_other_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.7'; 
INSERT INTO jour_other_history SELECT * FROM jour_other WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <='2014.12.7';
DELETE FROM jour_other WHERE  hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.7';
DELETE FROM jour_other_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date > '2014.12.7'; 

SELECT * FROM jour_other WHERE  hotel_group_id = 1 AND hotel_id = 1 ORDER BY list_order;

CALL up_ihotel_audit_jour_oth(1,1,@ret,@msg)