-- 导入营业日报表
SELECT * FROM migrate_xmyh.jourrep ORDER BY DATE,class;
ALTER TABLE  migrate_xmyh.jourrep DROP COLUMN CODE;
ALTER TABLE  migrate_xmyh.jourrep DROP COLUMN list_order;
ALTER TABLE  migrate_xmyh.jourrep ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;
ALTER TABLE migrate_xmyh.jourrep ADD list_order INT;
CREATE INDEX index1 ON migrate_xmyh.jour_map(class);
CREATE INDEX index2 ON migrate_xmyh.jour_map(class1);
-- 检查
SELECT * FROM migrate_xmyh.jour_map WHERE class NOT IN(SELECT CODE FROM portal.rep_jour WHERE hotel_id = 1);
SELECT * FROM migrate_xmyh.jour_map WHERE class1 NOT IN(SELECT class FROM migrate_xmyh.jourrep);
SELECT * FROM migrate_xmyh.jourrep WHERE class IN
(SELECT class1 FROM migrate_xmyh.jour_map WHERE class NOT IN(SELECT CODE FROM portal.rep_jour WHERE hotel_id = 1));

SELECT DATE,class,descript,DAY,MONTH,YEAR FROM migrate_xmyh.jourrep WHERE class IN
(SELECT class1 FROM migrate_xmyh.jour_map WHERE class NOT IN(SELECT CODE FROM portal.rep_jour WHERE hotel_id = 1))
AND (DAY<>0 OR MONTH<>0 OR YEAR <> 0) ORDER BY DATE,class;


SELECT * FROM  migrate_xmyh.jour_map;
UPDATE migrate_xmyh.jourrep a,migrate_xmyh.jour_map b SET a.code = b.class WHERE a.class = b.class1;
SELECT * FROM migrate_xmyh.jourrep ORDER BY DATE,class;
SELECT * FROM  migrate_xmyh.jour_map;
SELECT * FROM migrate_xmyh.jourrep  WHERE CODE = '' AND YEAR <> 0 ORDER BY DATE,class;

SELECT * FROM migrate_xmyh.jourrep GROUP BY CODE HAVING COUNT(1) > 1
 
SELECT * FROM rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE <'9';
SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE < '9' ORDER BY CODE;
 
SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07' AND CODE < '9'
AND CODE NOT IN(SELECT CODE FROM migrate_xmyh.jourrep);

UPDATE rep_jour SET DAY = 0,MONTH = 0,YEAR = 0,rebate_day = 0,rebate_month = 0,rebate_year = 0 WHERE hotel_group_id = 1 AND hotel_id = 1  AND biz_date = '2014.12.07';

SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07' AND CODE < '9' ORDER BY list_order;
SELECT * FROM migrate_xmyh.jourrep ; 
UPDATE migrate_xmyh.jourrep a,rep_jour b SET a.list_order = b.list_order WHERE a.code = b.code AND b.hotel_group_id = 1 AND b.hotel_id = 1;

UPDATE rep_jour a,(SELECT DATE,CODE,SUM(DAY) DAY,SUM(MONTH) MONTH,SUM(YEAR) YEAR,SUM(day_rebate) day_rebate,SUM(month_rebate) month_rebate,SUM(year_rebate) year_rebate FROM migrate_xmyh.jourrep WHERE CODE <> '' GROUP BY DATE,CODE) b 
	SET a.day = b.day,a.month = b.month ,a.year = b.year,a.rebate_day = b.day_rebate,a.rebate_month = b.month_rebate,a.rebate_year = b.year_rebate
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.biz_date = '2014.12.07' AND a.biz_date = b.date AND a.code = b.code;

SELECT * FROM rep_jour  WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date ='2014.12.07' AND CODE < '9' ORDER BY list_order;
SELECT * FROM rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE < '9';
DELETE FROM rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE < '9';
-- 历史营业日报
ALTER TABLE  migrate_xmyh.yjourrep DROP COLUMN CODE;
ALTER TABLE  migrate_xmyh.yjourrep DROP COLUMN list_order;
ALTER TABLE  migrate_xmyh.yjourrep ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;
ALTER TABLE migrate_xmyh.yjourrep ADD list_order INT;
CREATE INDEX index1 ON migrate_xmyh.yjourrep(CODE);
SELECT * FROM migrate_xmyh.yjourrep ORDER BY DATE,class;
SELECT * FROM  migrate_xmyh.jour_map;
-- '000010','000020','030005','000011','030006','000012','000021','030007'
SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE < '9';

SELECT * FROM migrate_xmyh.yjourrep WHERE DATE = '2014.12.07' GROUP BY CODE HAVING COUNT(1) > 1

SELECT * FROM migrate_xmyh.yjourrep WHERE DATE = '2014.12.07' AND CODE = '60'

SELECT * FROM  rep_jour WHERE hotel_id = 1 AND CODE < '9';
SELECT * FROM  migrate_xmyh.jour_map;
SELECT * FROM  migrate_xmyh.yjourrep WHERE class = '000045';
SELECT * FROM  rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE < '9' ORDER BY list_order;

UPDATE migrate_xmyh.yjourrep a,migrate_xmyh.jour_map b SET a.code = b.class WHERE a.class = b.class1;
SELECT MAX(DATE)  FROM migrate_xmyh.yjourrep;
SELECT * FROM migrate_xmyh.yjourrep WHERE DATE = '2014.11.25' AND CODE = '' AND YEAR <> 0;

-- 检查代码是否在对照表中存在
SELECT * FROM  migrate_xmyh.jour_map WHERE class1 NOT IN(SELECT class FROM migrate_xmyh.yjourrep WHERE DATE = '2014.11.25');
SELECT * FROM  migrate_xmyh.yjourrep WHERE class NOT IN(SELECT class1 FROM migrate_xmyh.jour_map);


UPDATE  migrate_xmyh.yjourrep a,rep_jour b SET a.list_order = b.list_order
WHERE b.hotel_group_id  = 1 AND b.hotel_id = 1 AND a.code = b.code  AND b.code < '9';





SELECT * FROM migrate_xmyh.yjourrep  WHERE DATE = '2014.11.25' GROUP BY CODE HAVING COUNT(1) > 1;
SELECT * FROM migrate_xmyh.yjourrep WHERE DATE = '2014.11.03' AND CODE = '60';
DELETE FROM rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE < '9';

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
SELECT  1, 
	1, 
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
FROM migrate_xmyh.yjourrep WHERE DATE <= '2014.11.25' AND CODE <> '' GROUP BY DATE,CODE;
DELETE FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.11.25' AND id > 238810;
SELECT * FROM  rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07';
DELETE FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date < '2014.11.25';
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
	descript, 
	descript, 
	SUM(DAY), 
	SUM(MONTH), 
	SUM(YEAR), 
	SUM(day_rebate),
	SUM(month_rebate),
	SUM(year_rebate),
	list_order
FROM migrate_xmyh.yjourrep WHERE DATE <= '2014.12.06' AND CODE <> '' GROUP BY DATE,CODE;

  
DELETE FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <  '2014.11.25' AND CODE < '9';
SELECT DISTINCT biz_date FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1;
SELECT MAX(id) FROM rep_jour;
SELECT MAX(id) FROM rep_jour_history;

 SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 1 AND CODE < '9' ORDER BY list_order;
 SELECT * FROM rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07' AND CODE < '9' ORDER BY list_order;

 