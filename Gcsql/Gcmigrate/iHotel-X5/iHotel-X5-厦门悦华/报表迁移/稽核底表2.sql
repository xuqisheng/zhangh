/*SELECT * FROM migrate_xmyh.yjierep ORDER BY DATE,class;
ALTER TABLE yjierep ADD CODE CHAR(10) NOT NULL DEFAULT  AFTER class;
SELECT * FROM migrate_xmyh.yjierep ORDER BY DATE,class;
SELECT biz_date,classno,descript,toclass FROM portal.rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 ORDER BY biz_date,classno;
UPDATE migrate_xmyh.yjierep a,migrate_xmyh.jierep b SET a.code = b.code WHERE a.class = b.class;
-- 修改code
SELECT * FROM rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 ORDER BY biz_date,classno
SELECT a.*,b.* FROM rep_jie a,migrate_xmyh.yjierep b WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.biz_date = 2014.04.20
AND a.biz_date = b.date AND a.classno = b.code;
SELECT * FROM rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 AND classno NOT IN(SELECT CODE FROM migrate_xmyh.yjierep) 
ORDER BY biz_date,classno

SELECT * FROM rep_jie WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = 2014.04.20;
UPDATE rep_jie SET day01 = 0,day09 = 0,day99 = 0,month01 = 0 ,month99 = 0 WHERE hotel_group_id = 1 AND hotel_id = 1 
AND biz_date = 2014.04.20;

SELECT DISTINCT biz_date FROM rep_jie WHERE hotel_id = 1;*/
SELECT * FROM rep_jie WHERE hotel_id = 1;
DELETE FROM rep_jie_history WHERE  hotel_group_id = 1 AND hotel_id = 1 AND biz_date <= '2014.12.06';
SELECT * FROM migrate_xmyh.yjierep WHERE DATE = '2014.11.14' AND class = '001';

SELECT * FROM rep_jie WHERE hotel_id = 1;
INSERT INTO `rep_jie_history` 
	(`hotel_group_id`, 
	`hotel_id`, 
 	`biz_date`, 
	`orderno`, 
	`itemno`, 
	`modeno`, 
	`classno`, 
	`descript`, 
	`descript1`, 
	`rectype`, 
	`toop`, 
	`toclass`, 
	`sequence`, 
	`day01`, 
	`day02`, 
	`day03`, 
	`day04`, 
	`day05`, 
	`day06`, 
	`day07`, 
	`day08`, 
	`day09`, 
	`day99`, 
	`month01`, 
	`month02`, 
	`month03`, 
	`month04`, 
	`month05`, 
	`month06`, 
	`month07`, 
	`month08`, 
	`month09`, 
	`month99`
	)
SELECT  1, 
	1, 
 	DATE, 
	'F', 
	NULL, 
	MODE, 
	class, 
	descript, 
	descript1, 
	rectype, 
	toop, 
	toclass, 
	NULL, 
	day01, 
	day02, 
	day03, 
	day04, 
	day05, 
	day06, 
	day07, 
	day08, 
	day09, 
	day99, 
	month01, 
	month02, 
	month03, 
	month04, 
	month05, 
	month06, 
	month07, 
	month08, 
	month09, 
	month99
FROM migrate_xmyh.yjierep  
WHERE DATE >='2013.01.01' AND DATE <= '2014.12.06';

SELECT * FROM rep_jie_history WHERE hotel_group_id = 1 AND  hotel_id = 1;
 

SELECT * FROM rep_jie_history WHERE hotel_id = 1   AND  biz_date <= '2014.12.06' ORDER BY biz_date,classno;
SELECT * FROM rep_jie_history WHERE hotel_id = 1   AND  biz_date >= '2014.12.06' ORDER BY biz_date,classno;

SELECT * FROM migrate_xmyh.ydairep WHERE DATE = '2014.12.07';
SELECT MAX(DATE) FROM migrate_xmyh.ydairep;
SELECT * FROM portal.rep_dai WHERE hotel_group_id = 1 AND hotel_id = 1;

SELECT * FROM rep_dai_history WHERE hotel_group_id = 1 AND hotel_id = 1 ORDER BY biz_date,classno;

SELECT DISTINCT biz_date FROM rep_dai_history WHERE hotel_id = 1;
DELETE FROM rep_dai_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <='2014.11.25';
ALTER TABLE migrate_xmyh.ydairep ADD CODE CHAR(10) NOT NULL DEFAULT ''  AFTER class;
UPDATE migrate_xmyh.ydairep SET CODE = class;
UPDATE migrate_xmyh.ydairep SET CODE = '01998' WHERE CODE IN('0120','0130');
UPDATE  migrate_xmyh.ydairep  SET CODE = '' WHERE class IN('01998','0810','0820','0881');


INSERT INTO `rep_dai_history` 
	(`hotel_group_id`, 
	`hotel_id`, 
 	`biz_date`, 
	`orderno`, 
	`itemno`, 
	`modeno`, 
	`classno`, 
	`descript`, 
	`descript1`, 
	`sequence`, 
	`credit01`, 
	`credit02`, 
	`credit03`, 
	`credit04`, 
	`credit05`, 
	`credit06`, 
	`credit07`, 
	`sumcre`, 
	`last_bl`, 
	`debit`, 
	`credit`, 
	`till_bl`, 
	`credit01m`, 
	`credit02m`, 
	`credit03m`, 
	`credit04m`, 
	`credit05m`, 
	`credit06m`, 
	`credit07m`, 
	`sumcrem`, 
	`last_blm`, 
	`debitm`, 
	`creditm`, 
	`till_blm`
	)
SELECT  1, 
	1, 
 	DATE, 
	order_, 
	itemno, 
	MODE, 
	CODE, 
	descript, 
	descript1, 
	NULL, 
	SUM(credit01), 
	SUM(credit02), 
	SUM(credit03), 
	SUM(credit04), 
	SUM(credit05), 
	SUM(credit06), 
	SUM(credit07), 
	SUM(sumcre), 
	SUM(last_bl), 
	SUM(debit), 
	SUM(credit), 
	SUM(till_bl), 
	SUM(credit01m), 
	SUM(credit02m), 
	SUM(credit03m), 
	SUM(credit04m), 
	SUM(credit05m), 
	SUM(credit06m), 
	SUM(credit07m), 
	SUM(sumcrem), 
	SUM(last_blm), 
	SUM(debitm), 
	SUM(creditm), 
	SUM(till_blm)
FROM migrate_xmyh.ydairep WHERE DATE>='2013.01.01' AND DATE<='2014.12.06' AND CODE <> '' GROUP BY DATE,CODE; 

SELECT * FROM migrate_xmyh.dairep ORDER BY DATE,class;
SELECT * FROM migrate_xmyh.jiedai ORDER BY DATE,class;

-- 借贷表
ALTER TABLE migrate_xmyh.yjiedai ADD CODE CHAR(10) NOT NULL DEFAULT '' AFTER class;
UPDATE migrate_xmyh.yjiedai a,migrate_xmyh.jiedai b SET a.code = b.code WHERE a.class = b.class;
 SELECT * FROM migrate_xmyh.yjiedai WHERE DATE = '2014.12.6';
DELETE FROM   rep_jiedai_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <='2014.11.25';
INSERT INTO `rep_jiedai_history` 
	(`hotel_group_id`, 
	`hotel_id`, 
 	`biz_date`, 
	`orderno`, 
	`itemno`, 
	`modeno`, 
	`classno`, 
	`descript`, 
	`descript1`, 
	`sequence`, 
	`last_charge`, 
	`last_credit`, 
	`charge`, 
	`credit`, 
	`apply`, 
	`till_charge`, 
	`till_credit`, 
	`last_chargem`, 
	`last_creditm`, 
	`chargem`, 
	`creditm`, 
	`applym`, 
	`till_chargem`, 
	`till_creditm`
	)
SELECT  1, 
	1, 
 	DATE, 
	order_, 
	itemno, 
	MODE, 
	CODE, 
	descript, 
	descript1, 
	NULL, 
	SUM(last_charge), 
	SUM(last_credit), 
	SUM(charge), 
	SUM(credit), 
	SUM(apply), 
	SUM(till_charge), 
	SUM(till_credit), 
	SUM(last_chargem), 
	SUM(last_creditm), 
	SUM(chargem), 
	SUM(creditm), 
	SUM(applym), 
	SUM(till_chargem), 
	SUM(till_creditm)
FROM migrate_xmyh.yjiedai WHERE DATE>= '2013.01.01' AND DATE<= '2014.12.06' GROUP BY DATE,CODE; 
-- UPDATE rep_jiedai SET last_charge = 0,charge = 0,credit = 0,till_charge = 0,till_credit = 0,last_chargem = 0,chargem = 0,
-- creditm = 0,till_chargem = 0,till_creditm = 0 WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = 2014.04.20

 

 
 