DELETE FROM log_info WHERE hotel_group_id = 1 AND hotel_id = 1;
INSERT INTO `log_info` 
	(`hotel_group_id`, 
	`hotel_id`, 
 	`entity_name`, 
	`entity_id`, 
	`column_name`, 
	`descript`, 
	`descript_en`, 
	`old_value`, 
	`new_value`, 
	`station_code`, 
	`need_translate`, 
	`create_user`, 
	`create_datetime`
	)
SELECT  1, 
	1, 
 	'MASTER_BASE', 
	b.id, 
	'', 
	c.descript, 
	'', 
	a.old, 
	a.new, 
	'111', 
	'N', 
	a.empno, 
	a.date
	FROM migrate_xmyh.lgfl a LEFT JOIN migrate_xmyh.lgfl_des c ON a.columnname = c.columnname,master_base b
	WHERE a.accnt = b.sc_flag AND b.hotel_group_id = 1 AND b.hotel_id = 1  
	 ;
SELECT * FROM log_info WHERE hotel_group_id = 1 AND hotel_id = 1 AND entity_id = 11787;
