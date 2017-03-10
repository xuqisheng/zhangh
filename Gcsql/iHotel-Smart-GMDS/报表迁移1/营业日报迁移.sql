-- -- 导入营业日报表
-- SELECT * FROM migrate_db.jourrep ORDER BY DATE,class;
-- ALTER TABLE  migrate_db.jourrep DROP COLUMN CODE;
-- ALTER TABLE  migrate_db.jourrep DROP COLUMN list_order;
-- ALTER TABLE  migrate_db.jourrep ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;
-- ALTER TABLE migrate_db.jourrep ADD list_order INT;
-- 
-- SELECT * FROM portal_f_pms.up_map_code WHERE hotel_id = 10 AND CODE = 'jourrep';
-- UPDATE migrate_db.jourrep a,portal_ipms.jour_map b SET a.code = b.code_new WHERE a.class = b.code_old ;
-- SELECT * FROM migrate_db.jourrep ORDER BY DATE,class;
-- SELECT * FROM migrate_db.jourrep  WHERE CODE = '' AND YEAR <> 0 ORDER BY DATE,class;
-- 
-- SELECT * FROM migrate_db.jourrep GROUP BY CODE HAVING COUNT(1) > 1
-- SELECT * FROM migrate_db.jourrep  WHERE CODE = '01040' 
-- SELECT * FROM rep_jour_history WHERE hotel_group_id = 2 AND hotel_id = 10 ;
-- SELECT * FROM rep_jour WHERE hotel_group_id = 2 AND hotel_id = 10 ;
--  
-- SELECT * FROM rep_jour WHERE hotel_group_id = 2 AND hotel_id = 10 AND biz_date = '2016.08.02' 
-- AND CODE NOT IN(SELECT CODE FROM migrate_db.jourrep);
-- 
-- UPDATE rep_jour SET DAY = 0,MONTH = 0,YEAR = 0,rebate_day = 0,rebate_month = 0,rebate_year = 0 WHERE hotel_group_id = 242 AND hotel_id = 10288  AND biz_date = '2016.08.02';
-- 
-- SELECT * FROM rep_jour WHERE hotel_group_id = 2 AND hotel_id = 10 AND biz_date = '2016.08.02' ;
-- SELECT * FROM migrate_db.jourrep ; 
-- UPDATE migrate_db.jourrep a,rep_jour b SET a.list_order = b.list_order WHERE a.code = b.code AND b.hotel_group_id = 242 AND b.hotel_id = 10288;
-- 
 UPDATE rep_jour a,(SELECT DATE,CODE,SUM(DAY) DAY,SUM(MONTH) MONTH,SUM(YEAR) YEAR,SUM(day_rebate) day_rebate,SUM(month_rebate) month_rebate,SUM(year_rebate) year_rebate   FROM migrate_db.jourrep  WHERE CODE <> '' GROUP BY DATE,CODE) b SET a.day = b.day,a.month = b.month ,a.year = b.year,a.rebate_day = b.day_rebate,a.rebate_month = b.month_rebate,a.rebate_year = b.year_rebate
 WHERE a.hotel_group_id = 242 AND a.hotel_id = 10288 AND a.biz_date = '2016.08.02' AND a.biz_date = b.date AND a.code = b.code;
-- 
-- SELECT * FROM migrate_db.jourrep ORDER BY DATE,class; 
-- SELECT * FROM rep_jour  WHERE hotel_group_id = 2 AND hotel_id = 10 AND biz_date ='2016.08.02' ;
-- SELECT * FROM rep_jour_history WHERE hotel_group_id = 2 AND hotel_id = 10 ;
-- DELETE FROM rep_jour_history WHERE hotel_group_id = 2 AND hotel_id = 10 ;
-- -- 历史营业日报
ALTER TABLE  migrate_db.yjourrep DROP COLUMN CODE;
ALTER TABLE  migrate_db.yjourrep DROP COLUMN list_order;
ALTER TABLE  migrate_db.yjourrep ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;
ALTER TABLE migrate_db.yjourrep ADD list_order INT;
CREATE INDEX index1 ON migrate_db.yjourrep(CODE);
CREATE INDEX index2 ON migrate_db.yjourrep(class);
UPDATE migrate_db.yjourrep a,portal_f_pms.up_map_code b SET a.code = b.code_new WHERE a.class = b.code_old AND b.hotel_group_id = 2 AND b.hotel_id = 10 AND b.code = 'jourrep';


UPDATE  migrate_db.yjourrep a,rep_jour b SET a.list_order = b.list_order
WHERE b.hotel_group_id  = 1 AND b.hotel_id = 10 AND a.code = b.code;

SELECT * FROM migrate_db.yjourrep ORDER BY DATE,class;
 -- '000010','000020','030005','000011','030006','000012','000021','030007'
SELECT * FROM portal_f_pms.rep_jour WHERE hotel_group_id = 2 AND hotel_id = 10 ;

SELECT * FROM migrate_db.yjourrep WHERE DATE = '2014.11.11' GROUP BY CODE HAVING COUNT(1) > 1

SELECT * FROM migrate_db.yjourrep WHERE DATE = '2014.11.11' AND CODE = '60'
-- 检查代码是否在对照表中存在
SELECT * FROM  migrate_db.jourrep WHERE class NOT IN(SELECT code_old FROM portal_f_pms.up_map_code WHERE hotel_group_id = 2 AND hotel_id = 10 AND CODE = 'jourrep');
SELECT * FROM  migrate_db.yjourrep WHERE class NOT IN(SELECT code_old FROM portal_f_pms.up_map_code WHERE hotel_group_id = 2 AND hotel_id = 10 AND CODE = 'jourrep');


SELECT * FROM  migrate_db.jour_map;
SELECT * FROM  migrate_db.yjourrep WHERE class = '000045';
SELECT * FROM rep_jour WHERE hotel_group_id = 2 AND hotel_id = 10  ORDER BY CODE;

UPDATE  migrate_db.yjourrep a,rep_jour b SET a.list_order = b.list_order
WHERE b.hotel_group_id  = 1 AND b.hotel_id = 10 AND a.code = b.code  ;

SELECT * FROM rep_jour_history WHERE hotel_group_id = 2 AND hotel_id = 10  ORDER BY CODE;
 
DELETE FROM rep_jour_history WHERE hotel_group_id = 242 AND hotel_id = 10288 ;

INSERT INTO `rep_jour` 
	(`hotel_group_id`, 
	`hotel_id`, 
 	`biz_date`, 
	`code`, 
	`descript`, 
	`descript_en`, 
	`day`, 
	`month`, 
	`year`, 
	`rebate_day`, 
	`rebate_month`, 
	`rebate_year`, 	
	`list_order`
	)
SELECT  242, 
	10288, 
 	DATE, 
	CODE, 
	descript, 
	descript, 
	SUM(DAY), 
	SUM(MONTH), 
	SUM(YEAR), 
	SUM(day_rebate),
	SUM(month_rebate),
	SUM(year_rebate),
	list_order
FROM migrate_db.jourrep WHERE DATE >='2014.01.01' AND DATE < '2016.08.02' AND CODE <> '' GROUP BY DATE,CODE;

INSERT INTO `rep_jour_history` 
	(`hotel_group_id`, 
	`hotel_id`, 
 	`biz_date`, 
	`code`, 
	`descript`, 
	`descript_en`, 
	`day`, 
	`month`, 
	`year`, 
	`rebate_day`, 
	`rebate_month`, 
	`rebate_year`, 	
	`list_order`
	)
SELECT  hotel_group_id, 
	hotel_id, 
 	biz_date, 
	CODE, 
	descript, 
	descript_en, 
	DAY, 
	MONTH, 
	YEAR, 
	rebate_day,
	rebate_month,
	rebate_year,
	list_order
FROM rep_jour  WHERE hotel_group_id = 242 AND hotel_id = 10288   ;

  
DELETE FROM rep_jour WHERE hotel_group_id = 2 AND hotel_id = 10 AND biz_date <  '2016.08.02' ;
SELECT DISTINCT biz_date FROM rep_jour WHERE hotel_group_id = 2 AND hotel_id = 10;
SELECT MAX(id) FROM rep_jour;
SELECT MAX(id) FROM rep_jour_history;

 SELECT * FROM rep_jour WHERE hotel_group_id = 2 AND hotel_id = 10  ORDER BY list_order;
 SELECT * FROM rep_jour_history WHERE hotel_group_id = 2 AND hotel_id = 10 AND biz_date = '2014.11.11'  ORDER BY list_order;

 