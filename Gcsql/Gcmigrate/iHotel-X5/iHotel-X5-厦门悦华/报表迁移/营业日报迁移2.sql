-- 导入营业日报表
SELECT * FROM  migrate_xmyh.jour_map2;
SELECT * FROM portal.rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE > '9';
ALTER TABLE  migrate_xmyh.jourrep_xmyh DROP COLUMN CODE;
ALTER TABLE  migrate_xmyh.jourrep_xmyh DROP COLUMN list_order;
ALTER TABLE  migrate_xmyh.jourrep_xmyh ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;
ALTER TABLE  migrate_xmyh.jourrep_xmyh ADD list_order INT;

SELECT * FROM  migrate_xmyh.jour_map2;
SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE > '9' ORDER BY list_order;
SELECT * FROM migrate_xmyh.jourrep_xmyh ORDER BY class; 
SELECT * FROM rep_jour a, migrate_xmyh.jour_map2 b WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.code > '9'
AND TRIM(a.descript) = TRIM(b.ref); 
-- 营业日报没有代码，根据描述更新
-- update  portal.rep_jour a, migrate_xmyh.jour_map2 b  set b.class = a.code
-- 	WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.code > '9'
-- 	AND TRIM(a.descript) = TRIM(b.ref); 

UPDATE migrate_xmyh.jourrep_xmyh a,migrate_xmyh.jour_map2 b SET a.code = b.class WHERE a.class = b.class1;

SELECT * FROM  migrate_xmyh.jour_map2 WHERE class IS NULL;
SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE > '9' ORDER BY list_order;



SELECT * FROM migrate_xmyh.jourrep_xmyh ORDER BY DATE,class;
 
SELECT * FROM  migrate_xmyh.jour_map2;
UPDATE migrate_xmyh.jourrep_xmyh a,migrate_xmyh.jour_map2 b SET a.code = b.class WHERE a.class = b.class1;

SELECT * FROM migrate_xmyh.jourrep_xmyh ORDER BY DATE,class;
SELECT * FROM migrate_xmyh.jour_map2;
SELECT * FROM portal.rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE > '9';

-- '000010','000020','030005','000011','030006','000012','000021','030007'
SELECT * FROM migrate_xmyh.jourrep_xmyh  WHERE class NOT IN('000010','000020','030005','000011','030006','000012','000021','030007') AND CODE = '' AND YEAR <> 0 ORDER BY DATE,class;
SELECT * FROM portal.rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE > '9';

 SELECT * FROM migrate_xmyh.jourrep_xmyh GROUP BY CODE HAVING COUNT(1) > 1
 
SELECT * FROM rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 1;
SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1;
 
SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07' AND CODE > '9'
AND CODE NOT IN(SELECT CODE FROM migrate_xmyh.jourrep_xmyh);
UPDATE rep_jour SET DAY = 0,MONTH = 0,YEAR = 0,rebate_day = 0,rebate_month = 0,rebate_year = 0 WHERE hotel_group_id = 1 AND hotel_id = 1  AND biz_date = '2014.12.07' AND CODE > '9';

SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07' AND CODE > '9';
SELECT * FROM migrate_xmyh.jourrep_xmyh ; 
UPDATE migrate_xmyh.jourrep_xmyh a,rep_jour b SET a.list_order = b.list_order WHERE a.code = b.code AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code > '9';

UPDATE rep_jour a,migrate_xmyh.jourrep_xmyh b SET a.day = b.day,a.month = b.month ,a.year = b.year 
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.biz_date = '2014.12.07' AND a.code > '9' AND a.biz_date = b.date AND a.code = b.code;

SELECT * FROM rep_jour  WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date ='2014.12.07' AND CODE > '9' ORDER BY list_order;
DELETE FROM rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date ='2014.12.07';
INSERT INTO rep_jour_history SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1;
SELECT * FROM rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07' ;
DELETE FROM rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE > '9';
-- 历史集团营业日报
ALTER TABLE  migrate_xmyh.yjourrep_xmyh DROP COLUMN CODE;
ALTER TABLE  migrate_xmyh.yjourrep_xmyh DROP COLUMN list_order;
ALTER TABLE  migrate_xmyh.yjourrep_xmyh ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;
ALTER TABLE migrate_xmyh.yjourrep_xmyh ADD list_order INT;

UPDATE migrate_xmyh.yjourrep_xmyh a,migrate_xmyh.jour_map2 b SET a.code = b.class WHERE a.class = b.class1;
SELECT * FROM migrate_xmyh.yjourrep_xmyh WHERE DATE = '2014.11.25' ORDER BY DATE,class;
SELECT * FROM  migrate_xmyh.jour_map2;
SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE > '9';
-- '000010','000020','030005','000011','030006','000012','000021','030007'
SELECT * FROM migrate_xmyh.yjourrep_xmyh  WHERE class NOT IN('000010','000020','030005','000011','030006','000012','000021','030007') AND CODE = '' AND YEAR <> 0 ORDER BY DATE,class;
SELECT * FROM portal_tr.rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE > '9';

SELECT * FROM migrate_xmyh.yjourrep_xmyh WHERE DATE = '2014.11.25' GROUP BY CODE HAVING COUNT(1) > 1

SELECT * FROM migrate_xmyh.yjourrep_xmyh WHERE DATE = '2014.11.11' AND CODE = '90410'

UPDATE  migrate_xmyh.yjourrep_xmyh a,portal.rep_jour b SET a.list_order = b.list_order
WHERE b.hotel_group_id  = 1 AND b.hotel_id = 1 AND a.code = b.code  AND b.code > '9';


SELECT MAX(id) FROM rep_jour;
SELECT MAX(id) FROM rep_jour_history;
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
SELECT  1, 
	1, 
 	DATE, 
	CODE, 
	ref, 
	ref, 
	SUM(DAY), 
	SUM(MONTH), 
	SUM(YEAR), 
	0,
	0,
	0,
	list_order
FROM migrate_xmyh.yjourrep_xmyh WHERE DATE <= '2014.12.06' AND CODE <> '' GROUP BY DATE,CODE;

 
 
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
FROM rep_jour  WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.7'
 
SELECT MAX(biz_date) FROM  rep_jour  WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE > '9';
DELETE FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date < '2014.12.07' AND CODE > '9';
SELECT DISTINCT biz_date FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1;
SELECT MAX(id) FROM rep_jour;
SELECT MAX(id) FROM rep_jour_history;

SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1;

UPDATE rep_jour a ,rep_jour_history b SET b.is_show = a.is_show
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1
AND a.code = b.code AND  b.hotel_group_id = 1 AND b.hotel_id = 1;

SELECT * FROM rep_jour_history WHERE hotel_id = 1 AND biz_date = '2014.12.7' AND CODE > '9';
UPDATE rep_jour_history SET is_show = 'F'  
WHERE hotel_id = 1 AND biz_date <= '2014.12.7' AND CODE > '9';

UPDATE rep_jour SET is_show = 'F'  
WHERE hotel_id = 1 AND biz_date <= '2014.12.7' AND CODE > '9';

SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE > '9' ORDER BY list_order;
SELECT * FROM rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date ='2014.12.7' AND CODE > '9' ORDER BY list_order;




 