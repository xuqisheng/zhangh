-- 导入营业日报表(上报集团)
SELECT * FROM  migrate_xmhy.jour_map2 ORDER BY code_new;
SELECT * FROM portal.rep_jour WHERE hotel_group_id = 1 AND hotel_id = 5 AND CODE > '90000' AND biz_date='2015.11.04' ORDER BY list_order;
SELECT * FROM migrate_xmhy.jourrep_xmyh ;
-- 增加西软中code , list_order 做导入对照
ALTER TABLE  migrate_xmhy.jourrep_xmyh DROP COLUMN CODE; -- 确定没code
ALTER TABLE  migrate_xmhy.jourrep_xmyh DROP COLUMN list_order; -- 确定没list_order
ALTER TABLE  migrate_xmhy.jourrep_xmyh ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;
ALTER TABLE  migrate_xmhy.jourrep_xmyh ADD list_order INT;


SELECT * FROM portal.rep_jour a, migrate_xmhy.jour_map2 b WHERE a.hotel_group_id = 1 AND a.hotel_id = 5  AND a.code > '90000' AND TRIM(a.descript) = TRIM(b.des_old); 
-- 营业日报没有代码，根据描述更新
-- update  portal.rep_jour a, migrate_xmhy.jour_map2 b  set b.class = a.code
-- 	WHERE a.hotel_group_id = 1 AND a.hotel_id = 5AND a.code > '9'
-- 	AND TRIM(a.descript) = TRIM(b.ref); 

-- 根据对照表开始更新代码
UPDATE migrate_xmhy.jourrep_xmyh a,migrate_xmhy.jour_map2 b SET a.code = b.code_new WHERE a.class = b.code_old;

--  检查
SELECT * FROM  migrate_xmhy.jour_map2 WHERE code_old IS NULL;
SELECT * FROM migrate_xmhy.jourrep_xmyh  WHERE CODE = '' AND YEAR <> 0 ORDER BY DATE,class;
SELECT * FROM portal.rep_jour WHERE hotel_group_id = 1 AND hotel_id = 5AND CODE > '90000';

SELECT * FROM migrate_xmhy.jourrep_xmyh GROUP BY CODE HAVING COUNT(1) > 1;

SELECT * FROM portal.rep_jour WHERE hotel_group_id = 1 AND hotel_id = 5  AND biz_date = '2015.11.04' AND CODE > '90000' AND 
CODE NOT IN(SELECT CODE FROM migrate_xmhy.jourrep_xmyh);  
 
SELECT * FROM rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 5  AND biz_date='2015.11.04';
SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date='2015.11.04';
 



UPDATE portal.rep_jour SET DAY = 0,MONTH = 0,YEAR = 0,rebate_day = 0,rebate_month = 0,rebate_year = 0 
WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date = '2015.11.04' AND CODE > '90000';

SELECT * FROM portal.rep_jour WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date = '2015.11.04' AND CODE > '90000';
SELECT * FROM migrate_xmhy.jourrep_xmyh ; 

-- 跟新list_order
UPDATE migrate_xmhy.jourrep_xmyh a,portal.rep_jour b SET a.list_order = b.list_order WHERE a.code = b.code AND b.hotel_group_id = 1 AND b.hotel_id = 5 AND b.code > '90000';

-- 跟新rep_jour表
UPDATE portal.rep_jour a,migrate_xmhy.jourrep_xmyh b SET a.day = b.day,a.month = b.month ,a.year = b.year WHERE a.hotel_group_id = 1 AND a.hotel_id = 5 AND a.biz_date = '2015.11.04' AND a.code > '90000' AND a.biz_date = b.date AND a.code = b.code;

UPDATE portal.rep_jour a,(SELECT DATE,CODE,ref,SUM(DAY) DAY,SUM(MONTH) MONTH,SUM(YEAR) YEAR
 FROM migrate_xmhy.jourrep_xmyh GROUP BY DATE,CODE ORDER BY DATE,CODE ) b 
SET a.day = b.day,a.month = b.month,a.year = b.year
WHERE a.hotel_group_id = 1 AND a.hotel_id = 5 AND a.biz_date = '2015.11.04' AND b.date = '2015.11.04' 
AND a.code = b.code;


SELECT * FROM portal.rep_jour  WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date ='2015.11.04' AND CODE > '90000' ORDER BY list_order;

SELECT * FROM portal.rep_jour_history  WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date ='2015.11.04' AND CODE > '90000' ORDER BY list_order;
-- 清空当日历史表
DELETE FROM portal.rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date ='2015.11.04' AND CODE > '90000' ;
-- 导入历史当日表
INSERT INTO portal.rep_jour_history
(hotel_group_id,hotel_id,biz_date,CODE,descript,descript_en,DAY,MONTH,YEAR,rebate_day,rebate_month,rebate_year,is_show,list_order) 
SELECT hotel_group_id,hotel_id,biz_date,CODE,descript,descript_en,DAY,MONTH,YEAR,rebate_day,rebate_month,rebate_year,is_show,list_order 
FROM portal.rep_jour WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date = '2015.11.04' AND  CODE > '90000' ;
-- 检查
SELECT * FROM portal.rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date = '2015.11.04' AND CODE > '9' ;



-- 历史集团营业日报
ALTER TABLE  migrate_xmhy.yjourrep_xmyh DROP COLUMN CODE;
ALTER TABLE  migrate_xmhy.yjourrep_xmyh DROP COLUMN list_order;
ALTER TABLE  migrate_xmhy.yjourrep_xmyh ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;
ALTER TABLE migrate_xmhy.yjourrep_xmyh ADD list_order INT;


UPDATE migrate_xmhy.yjourrep_xmyh a,migrate_xmhy.jour_map2 b SET a.code = b.code_new WHERE a.class = b.code_old;

SELECT * FROM migrate_xmhy.yjourrep_xmyh WHERE DATE = '2015.11.03' ORDER BY DATE,class;
SELECT * FROM  migrate_xmhy.jour_map2;
SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 5 AND CODE > '9';
-- '000010','000015','000020'
SELECT * FROM migrate_xmhy.yjourrep_xmyh  WHERE  CODE = '' AND YEAR <> 0 ORDER BY DATE,class;

SELECT * FROM portal.rep_jour WHERE hotel_group_id = 1 AND hotel_id = 5 AND CODE > '9';

SELECT * FROM migrate_xmhy.yjourrep_xmyh WHERE DATE = '2015.11.03' GROUP BY CODE HAVING COUNT(1) > 1

SELECT * FROM migrate_xmhy.yjourrep_xmyh WHERE DATE = '2015.11.03' AND CODE = ' '

-- 跟新list_order
UPDATE  migrate_xmhy.yjourrep_xmyh a,portal.rep_jour b SET a.list_order = b.list_order WHERE b.hotel_group_id  = 1 AND b.hotel_id = 5 AND a.code = b.code  AND b.code > '90000';

SELECT MAX(id) FROM portal.rep_jour;
SELECT MAX(id) FROM portal.rep_jour_history;

-- 查询 删除
SELECT * FROM portal.rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND CODE > '90000' AND  biz_date <='2015.11.03';
DELETE FROM  portal.rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND CODE >'90000' AND biz_date <='2015.11.03' ORDER BY list_order;

INSERT INTO portal.rep_jour_history
	(hotel_group_id, 
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
	)
SELECT  1, 
	5, 
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
FROM migrate_xmhy.yjourrep_xmyh WHERE DATE >= '2013.01.01' AND DATE <= '2015.11.03' AND CODE <> '' GROUP BY DATE,CODE;

 
SELECT MAX(biz_date) FROM  rep_jour  WHERE hotel_group_id = 1 AND hotel_id = 5  AND CODE > '9';
SELECT DISTINCT biz_date FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 8;
SELECT MAX(id) FROM rep_jour;
SELECT MAX(id) FROM rep_jour_history;


-- 跟新 is_show
UPDATE portal.rep_jour a ,portal.rep_jour_history b SET b.is_show = a.is_show WHERE a.hotel_group_id = 1 AND a.hotel_id = 5 AND a.code = b.code AND  b.hotel_group_id = 1 AND b.hotel_id = 5;

SELECT * FROM rep_jour_history WHERE hotel_id = 5AND biz_date = '2015.11.03' AND CODE > '9';

UPDATE rep_jour_history SET is_show = 'F'  WHERE hotel_id = 5 AND biz_date <= '2015.11.03' AND CODE > '9';

UPDATE rep_jour SET is_show = 'F'  WHERE hotel_id = 5 AND biz_date <= '2015.11.03' AND CODE > '9';

SELECT * FROM rep_jour WHERE hotel_group_id = 1 AND hotel_id = 5 AND CODE > '9' ORDER BY list_order;
SELECT * FROM rep_jour_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date ='2015.11.03' AND CODE > '9' ORDER BY list_order;




 