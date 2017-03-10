-- 导入迁移当天营业日报表 
-- 先检查
SELECT * FROM migrate_db.jourrep ORDER BY DATE,class;
ALTER TABLE  migrate_db.jourrep DROP COLUMN CODE; 
ALTER TABLE  migrate_db.jourrep DROP COLUMN list_order; 
ALTER TABLE  migrate_db.jourrep ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;  -- 加字段
ALTER TABLE migrate_db.jourrep ADD list_order INT; -- 加字段
CREATE INDEX index1 ON migrate_db.jour_map(code_old); -- class1 
CREATE INDEX index2 ON migrate_db.jour_map(code_new); -- class 
-- 检查
SELECT * FROM portal_pms.rep_jour WHERE hotel_id = 13 ORDER BY CODE
-- 确认对照表准确性
SELECT * FROM migrate_db.jour_map WHERE code_new NOT IN(SELECT CODE FROM portal_pms.rep_jour WHERE hotel_id = 13);
SELECT * FROM migrate_db.jour_map WHERE code_old  NOT IN(SELECT class FROM migrate_db.jourrep);
SELECT * FROM migrate_db.jourrep WHERE class IN
(SELECT code_new FROM migrate_db.jour_map WHERE code_new NOT IN(SELECT CODE FROM portal_pms.rep_jour WHERE hotel_id = 13));

SELECT DATE,class,descript,DAY,MONTH,YEAR FROM migrate_db.jourrep WHERE class IN
(SELECT code_old FROM migrate_db.jour_map WHERE code_new NOT IN(SELECT CODE FROM portal_pms.rep_jour WHERE hotel_id = 13))
AND (DAY<>0 OR MONTH<>0 OR YEAR <> 0) ORDER BY DATE,class;

-- 更新代码到中间库
UPDATE migrate_db.jourrep a,migrate_db.jour_map b SET a.code = b.code_new WHERE a.class = b.code_old;

-- 检查有金额的没对应的
SELECT * FROM migrate_db.jourrep  WHERE CODE = '' AND YEAR <> 0 ORDER BY DATE,class;
SELECT * FROM migrate_db.jour_map;
-- 检查多对一的
SELECT * FROM migrate_db.jourrep GROUP BY CODE HAVING COUNT(1) > 1
 
SELECT * FROM portal_pms.rep_jour_history WHERE hotel_group_id = 2 AND hotel_id = 13 AND CODE <'9'  ;
SELECT * FROM portal_pms.rep_jour WHERE hotel_group_id = 2 AND hotel_id = 13 AND CODE < '9' ORDER BY CODE;
 
SELECT * FROM portal_pms.rep_jour WHERE hotel_group_id = 2 AND hotel_id = 13 AND biz_date = '2016.09.09' AND CODE < '9'
AND CODE NOT IN(SELECT CODE FROM migrate_db.jourrep);
-- 清空绿云营业日报 准备导入
UPDATE portal_pms.rep_jour SET DAY = 0,MONTH = 0,YEAR = 0,rebate_day = 0,rebate_month = 0,rebate_year = 0 
WHERE hotel_group_id = 2 AND hotel_id = 13 AND CODE<'90000' AND biz_date = '2016.09.09';

SELECT * FROM portal_pms.rep_jour WHERE hotel_group_id = 2 AND hotel_id = 13 AND biz_date = '2016.09.09' AND CODE < '9' ORDER BY list_order;
SELECT * FROM migrate_db.jourrep ; 

UPDATE migrate_db.jourrep a,portal_pms.rep_jour b SET a.list_order = b.list_order WHERE a.code = b.code 
AND b.hotel_group_id = 2 AND b.hotel_id = 13;

UPDATE portal_pms.rep_jour a,(SELECT DATE,CODE,SUM(DAY) DAY,SUM(MONTH) MONTH,SUM(YEAR) YEAR,SUM(day_rebate) day_rebate,SUM(month_rebate) month_rebate,SUM(year_rebate) year_rebate FROM migrate_db.jourrep WHERE CODE <> '' GROUP BY DATE,CODE) b 
SET a.day = b.day,a.month = b.month ,a.year = b.year,a.rebate_day = b.day_rebate,a.rebate_month = b.month_rebate,a.rebate_year = b.year_rebate
WHERE a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.biz_date = '2016.09.09' AND a.biz_date = b.date AND a.code = b.code;


SELECT * FROM rep_jour WHERE hotel_group_id = 2 AND hotel_id = 13 
SELECT * FROM migrate_db.jour_map ;
-- 跟新客房其他合计
UPDATE portal_pms.rep_jour a,
(SELECT SUM(DAY) DAY,SUM(MONTH) MONTH,SUM(YEAR) YEAR,SUM(rebate_day) rebate_day,SUM(rebate_month) rebate_month,SUM(rebate_year) rebate_year FROM portal_pms.rep_jour WHERE hotel_group_id = 2 AND hotel_id = 13 AND biz_date = '2016.09.09' AND CODE IN (010010,010020,010030,010040,010031) ) b 
SET a.day = b.day,a.month = b.month ,a.year = b.year,a.rebate_day = b.rebate_day,a.rebate_month = b.rebate_month,a.rebate_year = b.rebate_year
WHERE a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.biz_date = '2016.09.09' 
AND a.code=010000
;





SELECT * FROM portal_pms.rep_jour_history WHERE hotel_group_id = 2 AND hotel_id = 13 AND CODE < '9' AND biz_date ='2016.09.09' ORDER BY list_order;
DELETE FROM portal_pms.rep_jour_history WHERE hotel_group_id = 2 AND hotel_id = 13 AND CODE < '9' AND biz_date ='2016.09.09' ORDER BY list_order;

INSERT INTO portal_pms.rep_jour_history(hotel_group_id,hotel_id,biz_date,CODE,descript,descript_en,DAY,MONTH,YEAR,rebate_day,rebate_month,rebate_year,is_show,list_order) 
SELECT hotel_group_id,hotel_id,biz_date,CODE,descript,descript_en,DAY,MONTH,YEAR,rebate_day,rebate_month,rebate_year,is_show,list_order FROM
portal_pms.rep_jour  WHERE hotel_group_id = 2 AND hotel_id = 13  AND CODE < '9' AND biz_date ='2016.09.09'  ORDER BY list_order;


-- 
-- 导历史营业日报  迁移历史的营业日报 不含迁移当天的营业日报
ALTER TABLE  migrate_db.yjourrep DROP COLUMN CODE;
ALTER TABLE  migrate_db.yjourrep DROP COLUMN list_order;
ALTER TABLE  migrate_db.yjourrep ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;
ALTER TABLE migrate_db.yjourrep ADD list_order INT;
CREATE INDEX index1 ON migrate_db.yjourrep(CODE);

SELECT * FROM migrate_db.yjourrep WHERE DATE = '2016.09.09' GROUP BY CODE HAVING COUNT(1) > 1
SELECT * FROM migrate_db.yjourrep WHERE DATE = '2016.09.09' AND CODE = '60'

-- 跟新到中间库
UPDATE migrate_db.yjourrep a,migrate_db.jour_map b SET a.code = b.code_new WHERE a.class = b.code_old;
SELECT MAX(DATE)  FROM migrate_db.yjourrep;
SELECT * FROM migrate_db.yjourrep WHERE DATE = '2016.09.09' AND CODE = '' AND YEAR <> 0;

-- 检查代码是否在对照表中存在
SELECT * FROM  migrate_db.jour_map WHERE code_old NOT IN(SELECT class FROM migrate_db.yjourrep WHERE DATE = '2016.09.09');
SELECT * FROM  migrate_db.yjourrep WHERE code_new NOT IN(SELECT code_old FROM migrate_db.jour_map);

-- 跟新list_order
UPDATE  migrate_db.yjourrep a,portal_pms.rep_jour b SET a.list_order = b.list_order WHERE b.hotel_group_id  = 1 AND
 b.hotel_id = 13 AND a.code = b.code  AND b.code < '9';


-- 查看删除历史记录 
SELECT * FROM portal_pms.rep_jour_history WHERE hotel_group_id = 2 AND hotel_id = 13 AND CODE < '9' AND  biz_date <'2016.09.09';
DELETE FROM portal_pms.rep_jour_history WHERE hotel_group_id = 2 AND hotel_id = 13 AND CODE < '9' AND biz_date <'2016.09.09' ORDER BY list_order;

INSERT INTO portal_pms.rep_jour_history
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
SELECT  2, 
	13, 
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
FROM migrate_db.yjourrep WHERE DATE>='2013.01.01'  AND DATE < '2016.09.09' AND CODE <> '' GROUP BY DATE,CODE;



-- 跟新合计明细
UPDATE portal_pms.rep_jour_history a, portal_pms.rep_jour_history b 
SET a.day = b.day,a.month = b.month ,a.year = b.year,a.rebate_day = b.rebate_day,a.rebate_month = b.rebate_month,a.rebate_year = b.rebate_month
WHERE a.hotel_group_id = 2 AND a.hotel_id = 13  AND a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.biz_date = b.biz_date 
AND a.code='18880' AND b.code='18890';

SELECT MAX(id) FROM rep_jour;
SELECT MAX(id) FROM rep_jour_history;

SELECT * FROM rep_jour WHERE hotel_group_id = 2 AND hotel_id = 13 AND CODE < '9' ORDER BY list_order;
SELECT * FROM rep_jour_history WHERE hotel_group_id = 2 AND hotel_id = 13 AND biz_date = '2016.09.09' AND CODE < '9' ORDER BY list_order;

 