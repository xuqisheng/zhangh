SELECT * FROM sys_option WHERE hotel_id = 13 AND item = 'creditcard_as_ar';

SELECT * FROM code_base WHERE hotel_group_id = 2 AND hotel_id = 13 AND parent_code='bankcode';

SELECT * FROM code_bankcard_link WHERE hotel_group_id = 2 AND hotel_id = 13;
SELECT * FROM code_transaction WHERE hotel_group_id = 2 AND hotel_id = 13 AND CODE > '9' AND category_code IN('C','D');
UPDATE code_bankcard_link SET arno = 3947 WHERE hotel_group_id = 2 AND hotel_id = 13 AND ta_code < '9200';
UPDATE code_bankcard_link SET arno = 3948 WHERE hotel_group_id = 2 AND hotel_id = 13 AND ta_code >= '9200';

INSERT INTO `portal_tr`.`code_bankcard_link` 
	(`hotel_group_id`, 
	`hotel_id`, 
 	`ta_code`, 
	`bank_code`, 
	`arno`, 
	`commission`, 
	`is_halt`, 
	`create_user`, 
	`create_datetime`, 
	`modify_user`, 
	`modify_datetime`, 
	`is_group`, 
	`group_code`, 
	`code_type`
	)
SELECT  2, 
	13, 
 	CODE, 
	'', 
	'', 
	0, 
	'F', 
	'ADMIN', 
	NOW(), 
	'ADMIN', 
	NOW(), 
	'', 
	'', 
	''
	FROM portal_tr.code_transaction WHERE hotel_group_id = 2 AND hotel_id = 13  AND category_code IN('C','D');
