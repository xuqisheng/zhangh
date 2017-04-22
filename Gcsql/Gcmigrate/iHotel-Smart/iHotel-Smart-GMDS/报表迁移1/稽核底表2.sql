SELECT * FROM migrate_db.yyjierep ORDER BY DATE,class;
ALTER TABLE migrate_db.yjierep ADD CODE CHAR(10) NOT NULL DEFAULT ''  AFTER class;
UPDATE migrate_db.yjierep a, portal.up_map_code b SET a.code = b.code_new WHERE a.class = b.code_old AND b.hotel_group_id = 1 AND b.hotel_id = 2 AND b.code = 'jierep';

SELECT * FROM migrate_db.yjierep WHERE CODE = '' AND day99 <> 0 ORDER BY DATE,class;

SELECT DISTINCT biz_date FROM rep_jie_history WHERE hotel_id = 2;
INSERT INTO `portal`.`rep_jie_history` 
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
	2, 
 	DATE, 
	'F', 
	NULL, 
	MODE, 
	CODE, 
	descript, 
	descript1, 
	rectype, 
	toop, 
	toclass, 
	sequence, 
	SUM(day01), 
	SUM(day02), 
	SUM(day03), 
	SUM(day04), 
	SUM(day05), 
	SUM(day06), 
	SUM(day07), 
	SUM(day08), 
	SUM(day09), 
	SUM(day99), 
	SUM(month01), 
	SUM(month02), 
	SUM(month03), 
	SUM(month04), 
	SUM(month05), 
	SUM(month06), 
	SUM(month07), 
	SUM(month08), 
	SUM(month09), 
	SUM(month99)
FROM migrate_db.yjierep WHERE DATE >='2014.01.01' AND DATE < '2014.11.23' GROUP BY DATE,CODE;

SELECT * FROM rep_jie_history WHERE hotel_id = 2 AND biz_date = '2014.1.1'

ALTER TABLE migrate_db.ydairep ADD CODE CHAR(10) NOT NULL DEFAULT ''  AFTER class;
SELECT * FROM  migrate_db.ydairep WHERE DATE = '2014.01.01';
UPDATE migrate_db.ydairep SET CODE = class;
UPDATE migrate_db.ydairep SET CODE = '01998' WHERE CODE = '0120';
UPDATE  migrate_db.ydairep  SET CODE = '' WHERE class IN('01998','0810','0820','0881');
SELECT * FROM  migrate_db.ydairep WHERE DATE = '2014.01.01';
SELECT * FROM portal.rep_dai_history WHERE hotel_id = 2 ORDER BY biz_date,classno;

SELECT DISTINCT biz_date FROM rep_dai_history WHERE hotel_id = 2 ORDER BY biz_date,classno;


SELECT DISTINCT biz_date FROM rep_dai_history WHERE hotel_id = 2;
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
	2, 
 	DATE, 
	order_, 
	itemno, 
	MODE, 
	CODE, 
	descript, 
	descript1, 
	sequence, 
	credit01, 
	credit02, 
	credit03, 
	credit04, 
	credit05, 
	credit06, 
	credit07, 
	sumcre, 
	last_bl, 
	debit, 
	credit, 
	till_bl, 
	credit01m, 
	credit02m, 
	credit03m, 
	credit04m, 
	credit05m, 
	credit06m, 
	credit07m, 
	sumcrem, 
	last_blm, 
	debitm, 
	creditm, 
	till_blm
FROM migrate_db.ydairep WHERE DATE>='2014.01.01' AND DATE<'2014.11.23' AND CODE <> '';
 

 
SELECT * FROM rep_dai_history  WHERE hotel_group_id = 1 AND hotel_id = 2 AND biz_date = '2014.01.01';
SELECT * FROM migrate_db.dairep ORDER BY DATE,class;
SELECT * FROM migrate_db.jiedai ORDER BY DATE,class;

-- 借贷表
SELECT * FROM migrate_db.yjiedai ORDER BY DATE,class;

ALTER TABLE migrate_db.yjiedai ADD CODE CHAR(10) NOT NULL DEFAULT ''  AFTER class;
UPDATE migrate_db.yjiedai SET CODE = class;
UPDATE migrate_db.yjiedai  SET CODE = '03A' WHERE class IN('03C','03D');
 
SELECT * FROM migrate_db.yjiedai WHERE DATE = '2014.01.01';

  
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
	2, 
 	DATE, 
	order_, 
	itemno, 
	MODE, 
	CODE, 
	descript, 
	descript1, 
	sequence, 
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
FROM migrate_db.yjiedai WHERE DATE>= '2014.01.01' AND DATE<'2014.11.23' GROUP BY DATE,CODE ; 
-- UPDATE rep_jiedai SET last_charge = 0,charge = 0,credit = 0,till_charge = 0,till_credit = 0,last_chargem = 0,chargem = 0,
-- creditm = 0,till_chargem = 0,till_creditm = 0 WHERE hotel_group_id = 1 AND hotel_id = 2 AND biz_date = 2014.04.20

 

 
 