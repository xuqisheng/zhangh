SELECT * FROM rep_jour WHERE hotel_id = 13 ORDER BY CODE;
SELECT * FROM rep_jour_rule WHERE hotel_id = 13 ORDER BY CODE;
SELECT * FROM rep_jour_rule WHERE hotel_id = 15 ORDER BY CODE;

SELECT * FROM migrate_xsw.jourrep ORDER BY DATE,class;

SELECT * FROM rep_jour_rule a, migrate_xsw.jourrep b WHERE a.code = b.class AND b.rectype = 'C';

UPDATE rep_jour_rule a, migrate_xsw.jourrep b SET a.level = '1'
WHERE a.code = b.class AND b.rectype = 'C';

INSERT INTO `portal`.`rep_jour_rule` 
	(`hotel_group_id`, 
	`hotel_id`, 
 	`code`, 
	`descript`, 
	`descript_en`, 
	`level`, 
	`is_show`, 
	`source`, 
	`rebate`, 
	`list_order`
	)
SELECT  2, 
	13, 
 	class, 
	descript, 
	descript1, 
	0, 
	'T', 
	'', 
	'', 
	1
	FROM  migrate_xsw.jourrep;
